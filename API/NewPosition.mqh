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
/*CPosition::CPosition(Order* inOrder) : Transaction(TRANS_POSITION)
{
   AddInitialOrder(inOrder);
}*/

///
/// � ������ ������ ������� ������������ �������. � ������ �������
/// ����� ������� ������� �� �������� POSITION_NULL.
///
/*CPosition::CPosition(Order* inOrder, Order* outOrder) : Transaction(TRANS_POSITION)
{
   AddInitialOrder(inOrder);
   AddClosingOrder(outOrder);
}*/

///
/// ����������� ����� � ������� �������. ����� �������� ���������� ������ �������
/// � ��� �� �������� ����� ����������. ����������� ���������� ����� �����
/// ����� ��������� �������, ��� �������� ��� � ������������.
/// \return ����� �������� ���������� �� ���������� � ����� ���� ��������� �������
/// ��������.
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
/// ���������� ������, ���� ����� ����� ���� �������� � ������� ��� �����������.
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
/// ���������� ������, ���� ����� ����� ���� ����������� ������� �������.
///
bool CPosition::CompatibleForClose(Order *order)
{
   //������� ����� ������ �������� �������.
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
/// ��������� ����������� ����� � �������� �������.
///
InfoIntegration* CPosition::AddClosingOrder(Order* outOrder)
{
   InfoIntegration* info = NULL;
   
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

POSITION_STATUS CPosition::Status()
{
   return status;
}