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
      CPosition(Order* inOrder);
      //CPosition(Order* inOrder, Order* outOrder);
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
   private:
      virtual bool MTContainsMe();
      bool CompatibleForInit(Order* order);
      bool CompatibleForClose(Order* order);
      InfoIntegration* AddClosingOrder(Order* outOrder);
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
CPosition::CPosition(Order* inOrder) : Transaction(TRANS_POSITION)
{
   Integrate(inOrder);
}

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
   if(initOrder.GetId() == order.GetId() && status == POSITION_ACTIVE)
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

///
/// Добавляет инициирующий ордер в позицию.
///
void CPosition::AddInitialOrder(Order *inOrder)
{
   //contextOrder = initOrder;
   //CPosition* pos = AddOrder(inOrder);
   if(initOrder == NULL || status == POSITION_NULL)
   {
      initOrder = inOrder;
      status = POSITION_ACTIVE;
   }
   else if(status == POSITION_ACTIVE)
   {
      for(int i = 0; i < inOrder.DealsTotal(); i++)
      {
         CDeal* deal = inOrder.DealAt(i);
         initOrder.AddDeal(deal);
      }
   }
   return;
}

///
/// Добавляет закрывающий ордер в активную позицию.
///
InfoIntegration* CPosition::AddClosingOrder(Order* outOrder)
{
   InfoIntegration* info = NULL;
   if(!CompatibleForClose(outOrder))
   {
      info.InfoMessage = "Closing order has not compatible id with position id.";
      return info;
   }
   
   //initOrder.MergeOrder(outOrder);
   //initOrder.AnigilateOrder();
   if(outOrder.ExecutedVolume() > ExecutedVolume())
   {
      //Order* activeOrder = initOrder.GetActiveRestOrder(outOrder);
      //TODO: Init new pos...
      
   }
   if(outOrder.ExecutedVolume() < ExecutedVolume())
   {
      //Order* inHistoryOrder* = initOrder.GetHistoryOrder(outOrder);
      //TODO: Init new hist pos...
      
   }
   if(outOrder.ExecutedVolume() == ExecutedVolume())
   {
      closingOrder = outOrder;
      status = POSITION_HISTORY;
      //TODO: Closing all, change status on history;
   }
   return info;
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

///
/// Истина, если терминал содержит информацию об позиции с
/// с текущим идентификатором и ложь в противном случае.
///
bool CPosition::MTContainsMe()
{
   if(status == POSITION_NULL)
      return false;
   return true;
}