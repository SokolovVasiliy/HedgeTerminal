#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"

class CPosition;

///
/// Info about the Integration.
///
class InfoIntegration
{
   public:
      InfoIntegration();
      bool IsSuccess;
      string InfoMessage;
      CPosition* ActivePosition;
      CPosition* HistoryPosition;
};
InfoIntegration::InfoIntegration(void)
{
   ActivePosition = new CPosition();
   HistoryPosition = new CPosition();
}

///
/// Статус позиции.
///
enum POSITION_STATUS
{
   ///
   /// Нулевая позиция.
   ///
   POSITION_NULL,
   ///
   /// Активная позиция.
   ///
   POSITION_ACTIVE,
   ///
   /// Бывшая активная позиция, которая была полностью
   /// перекрыта встречными сделками и перестала существовать.
   ///
   POSITION_CLOSE,
   ///
   /// Историческая позиция.
   ///
   POSITION_HISTORY,
};

class CPosition : Transaction
{
   public:
      CPosition(void);
      //CPosition(Order* inOrder);
      //CPosition(Order* inOrder, Order* outOrder);
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
   private:
      bool CompatibleForInit(Order* order);
      bool CompatibleForClose(Order* order);
      CPosition* AddClosingOrder(Order* outOrder);
      void AddInitialOrder(Order* inOrder);
      CPosition* AddOrder(Order* order);
      POSITION_STATUS RefreshType(void);
      Order* contextOrder;
      Order* initOrder;
      Order* closingOrder;
      POSITION_STATUS status;
      string lastMessage;
};

///
/// Создает неактивную позицию со статусом POSITION_NULL.
///
CPosition::CPosition() : Transaction(TRANS_POSITION)
{
   status = POSITION_NULL;
}

///
/// В случае успеха создает активную позицию. В случае неудачи
/// будет создана позиция со статусом POSITION_NULL.
///
/*CPosition::CPosition(Order* inOrder) : Transaction(TRANS_POSITION)
{
   AddInitialOrder(inOrder);
}*/

///
/// В случае успеха создает историческую позицию. В случае неудачи
/// будет создана позиция со статусом POSITION_NULL.
///
/*CPosition::CPosition(Order* inOrder, Order* outOrder) : Transaction(TRANS_POSITION)
{
   AddInitialOrder(inOrder);
   AddClosingOrder(outOrder);
}*/

///
/// Интегрирует ордер в текущую позицию. После успешной интеграции статус позиции
/// и все ее свойства могут измениться. Результатом интеграции могут стать
/// новые созданные позиции, как активные так и исторические.
/// \return Класс содержит информацию об интеграции и может быть уничтожен внешним
/// объектом.
///
InfoIntegration* CPosition::Integrate(Order* order)
{
   InfoIntegration* info = NULL;
   if(CompatibleForInit(order))
   {
      AddInitialOrder(order);
      info = new InfoIntegration();
   }
   else if(CompatibleForClose(order))
      /*info =*/ AddClosingOrder(order);
   else
   {
      info = new InfoIntegration();
      info.InfoMessage = "Proposed order #" + (string)order.GetId() +
      "can not be integrated in position #" + (string)GetId() +
      ". Position and order has not compatible types";
   }
   return info;
}

///
/// Возвращает истину, если ордер может быть добавлен в позицию как открывающий.
///
bool CPosition::CompatibleForInit(Order *order)
{
   if(status == POSITION_NULL)
      return true;
   if(initOrder.GetId() == order.GetId())
      return true;
   else
      return false;
}

///
/// Возвращает истину, если ордер может быть закрывающим ордером позиции.
///
bool CPosition::CompatibleForClose(Order *order)
{
   //Закрыть можно только активную позицию.
   if(status != POSITION_ACTIVE)
      return false;
   if(order.PositionId() == GetId())
      return true;
   return false;
}

void CPosition::AddInitialOrder(Order *inOrder)
{
   contextOrder = initOrder;
   CPosition* pos = AddOrder(inOrder);
   return;
}

///
/// Добавляет закрывающий ордер в активную позицию.
///
InfoIntegration* CPosition::AddClosingOrder(Order* outOrder)
{
   InfoIntegration* info = NULL;
   
}

///
/// На переписку.
///
CPosition* CPosition::AddOrder(Order* order)
{
   CPosition* historyPos = NULL;
   if(status == POSITION_HISTORY)
   {
      LogWriter("Adding order failed. Position are history" , MESSAGE_TYPE_ERROR);
      return historyPos;
   }
   if(!CheckOrderType(order))
   {
      LogWriter("Adding order has not compatible Type or invalid.", MESSAGE_TYPE_ERROR);
      return historyPos;
   }
   if(!CheckOrderType(contextOrder))
   {
      contextOrder = order;
      RefreshType();
      return historyPos;
   }
   if(contextOrder.GetId() != order.GetId())
   {
      LogWriter("Position #" + (string)GetId() + " already contains order. Order #" +
                (string)order.GetId() + " will not be added", MESSAGE_TYPE_WARNING);
      return historyPos;
   }
   //return contextOrder.AddDeals(order.Deals());
   return historyPos;
}
///
/// Проверяет, является ли статус переданного ордера совместимым с понятием "позиция".
/// \return Истина, если ордер может принадлежать позиции, ложь в противном случае.
///
static bool CPosition::CheckOrderType(Order* checkOrder)
{
   bool isNull = CheckPointer(checkOrder) == POINTER_INVALID;
   if(isNull || checkOrder.Type() == ORDER_NULL ||
      checkOrder.Type() == ORDER_PENDING)
   {
      return false;
   }
   return true;
}

///
/// Обновляет статус позиции.
///
POSITION_STATUS CPosition::RefreshType()
{
   if(CheckPointer(initOrder) == POINTER_INVALID)
   {
      status = POSITION_NULL;
      return status;
   }
   if(CheckPointer(closingOrder) != POINTER_INVALID)
      status = POSITION_HISTORY;
   else
      status = POSITION_ACTIVE;
   SetId(initOrder.GetId());
   return status;
}

POSITION_STATUS CPosition::Status()
{
   return status;
}