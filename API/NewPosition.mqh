#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"

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
      CPosition(Order* inOrder, Order* outOrder);
      
      CPosition* AddClosingOrder(Order* outOrder);
      CPosition* AddInitialOrder(Order* inOrder);
      string LastMessage();
   private:
      CPosition* AddOrder(Order* order);
      bool checkOrderStatus(Order* checkOrder);
      void checkPositionStatus(void);
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
   AddInitialOrder(inOrder);
}

///
/// В случае успеха создает историческую позицию. В случае неудачи
/// будет создана позиция со статусом POSITION_NULL.
///
CPosition::CPosition(Order* inOrder, Order* outOrder) : Transaction(TRANS_POSITION)
{
   AddInitialOrder(inOrder);
   AddClosingOrder(outOrder);
}

CPosition* CPosition::AddInitialOrder(Order *inOrder)
{
   contextOrder = initOrder;
   return AddOrder(inOrder);
}

///
/// Добавляет закрывающий ордер в активную позицию.
///
CPosition* CPosition::AddClosingOrder(Order* outOrder)
{
   contextOrder = closingOrder;
   return AddOrder(outOrder);
}

CPosition* CPosition::AddOrder(Order* order)
{
   CPosition* historyPos = NULL;
   if(status == POSITION_HISTORY)
   {
      LogWriter("Adding order failed. Position are history" , MESSAGE_TYPE_ERROR);
      return historyPos;
   }
   if(!checkOrderStatus(order))
   {
      LogWriter("Adding order: " + LastMessage(), MESSAGE_TYPE_ERROR);
      return historyPos;
   }
   if(!checkOrderStatus(contextOrder))
   {
      contextOrder = order;
      checkPositionStatus();
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
/// Проверяет, является ли статус переданного ордера совместимым с позицией.
///
bool CPosition::checkOrderStatus(Order* checkOrder)
{
   bool isNull = CheckPointer(checkOrder) == POINTER_INVALID;
   if(isNull || checkOrder.Status() == ORDER_NULL ||
      checkOrder.Status() == ORDER_PENDING)
   {
      string statusInfo = isNull ? "POINTER INVALID" : EnumToString(initOrder.Status());
      lastMessage = "Check order failed. Order has not compatible status or invalid: " + statusInfo;
      return false;
   }
   return true;
}

///
/// 
///
void CPosition::checkPositionStatus()
{
   if(CheckPointer(initOrder) == POINTER_INVALID)
   {
      status = POSITION_NULL;
      return;
   }
   if(CheckPointer(closingOrder) != POINTER_INVALID)
      status = POSITION_HISTORY;
   else
      status = POSITION_ACTIVE;
   SetId(initOrder.GetId());
}
///
/// Возвращает последнее сообщение записанное классом.
///
string CPosition::LastMessage()
{
   string msg = lastMessage;
   lastMessage = "";
   return msg;
}

