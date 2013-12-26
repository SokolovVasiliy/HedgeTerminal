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
      void AddInitialOrder(Order* inOrder);
      string LastMessage();
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
   private:
      CPosition* AddOrder(Order* order);
      POSITION_STATUS RefreshType(void);
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

void CPosition::AddInitialOrder(Order *inOrder)
{
   contextOrder = initOrder;
   CPosition* pos = AddOrder(inOrder);
   return;
}

///
/// ��������� ����������� ����� � �������� �������.
///
CPosition* CPosition::AddClosingOrder(Order* outOrder)
{
   contextOrder = closingOrder;
   return AddOrder(outOrder);
}

///
/// �� ���������.
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
/// ���������, �������� �� ������ ����������� ������ ����������� � �������� "�������".
/// \return ������, ���� ����� ����� ������������ �������, ���� � ��������� ������.
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
/// ��������� ������ �������.
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
///
/// ���������� ��������� ��������� ���������� �������.
///
string CPosition::LastMessage()
{
   string msg = lastMessage;
   lastMessage = "";
   return msg;
}

POSITION_STATUS CPosition::Status()
{
   return status;
}