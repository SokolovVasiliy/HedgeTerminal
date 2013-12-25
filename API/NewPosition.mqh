#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"

///
/// ������ �������.
///
enum POSITION_STATUS
{
   ///
   /// ������� �������.
   ///
   POSITION_NULL,
   ///
   /// �������� �������.
   ///
   POSITION_ACTIVE,
   ///
   /// ������ �������� �������, ������� ���� ���������
   /// ��������� ���������� �������� � ��������� ������������.
   ///
   POSITION_CLOSE,
   ///
   /// ������������ �������.
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
/// ������� ���������� ������� �� �������� POSITION_NULL.
///
CPosition::CPosition() : Transaction(TRANS_POSITION)
{
   status = POSITION_NULL;
}

///
/// � ������ ������ ������� �������� �������. � ������ �������
/// ����� ������� ������� �� �������� POSITION_NULL.
///
CPosition::CPosition(Order* inOrder) : Transaction(TRANS_POSITION)
{
   AddInitialOrder(inOrder);
}

///
/// � ������ ������ ������� ������������ �������. � ������ �������
/// ����� ������� ������� �� �������� POSITION_NULL.
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
/// ��������� ����������� ����� � �������� �������.
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
/// ���������, �������� �� ������ ����������� ������ ����������� � ��������.
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
/// ���������� ��������� ��������� ���������� �������.
///
string CPosition::LastMessage()
{
   string msg = lastMessage;
   lastMessage = "";
   return msg;
}

