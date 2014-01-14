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

///
/// ������������ ��� ���������� ������� ��� �������� ������� ExchangerOrder.
///
struct ExchangerList
{
   public:
      Order* inOrder;
      Order* outOrder;
      Order* histInOrder;
      Order* histOutOrder;
};

class CPosition : Transaction
{
   public:
      CPosition(void);
      CPosition(Order* inOrder);
      CPosition(Order* inOrder, Order* outOrder);
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
      static void ExchangerOrder(ExchangerList& list);
      bool Merge(CPosition* pos);
      Order* InitOrder(){return initOrder;}
      Order* ClosingOrder(){return closingOrder;}
      bool Compatible(CPosition* pos);
      virtual int Compare(const CObject* node, const int mode=0);
   private:
      static void SplitOrder(ExchangerList& list);
      virtual bool MTContainsMe();
      bool CompatibleForInit(Order* order);
      bool CompatibleForClose(Order* order);
      InfoIntegration* AddClosingOrder(Order* outOrder);
      void AddInitialOrder(Order* inOrder);
      CPosition* AddOrder(Order* order);
      POSITION_STATUS RefreshType(void);
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
   Integrate(inOrder);
}
///
/// ������� ����������� �������. ������ ���������� � ��������� ������� ������ ���� �����.
///
CPosition::CPosition(Order* inOrder, Order* outOrder) : Transaction(TRANS_POSITION)
{
   if(inOrder == NULL || outOrder == NULL)
      return;
   if(inOrder.ExecutedVolume() != outOrder.ExecutedVolume())
      return;
   //if(inOrder.PositionId() != outOrder.PositionId())
   //   return;
   status = POSITION_HISTORY;
   initOrder = inOrder;
   outOrder = outOrder;
   Integrate(inOrder);
}

bool CPosition::Compatible(CPosition *pos)
{
   if(pos.Status() == POSITION_NULL ||
      pos.Status() == POSITION_CLOSE)
      return false;
   if(pos.GetId() != GetId())
      return false;
   if(pos.Status() != pos.Status())
      return false;
   if(pos.Status() == POSITION_HISTORY)
   {
      Order* clOrder = pos.ClosingOrder();
      if(clOrder.GetId() != closingOrder.GetId())
         return false;
   }
   return true;
}
///
/// ���������� ���������� ������� � ������� ��������.
/// ����� �������� ����������� ���������� ������� �������� ���� �� ������
/// � ��������� � ��������� POSITION_NULL.
///
bool CPosition::Merge(CPosition *pos)
{
   if(!Compatible(pos))
      return false;
   
   //Merge init deals.
   Order* order = pos.InitOrder();
   //CArrayObj inDeals = in.D
   while(order.DealsTotal())
   {
      CDeal* ndeal = new CDeal(order.DealAt(0));
      initOrder.AddDeal(ndeal);
      order.DeleteDealAt(0);
   }
   order = pos.ClosingOrder();
   if(order == NULL)
      return true;
   while(order.DealsTotal())
   {
      CDeal* ndeal = new CDeal(order.DealAt(0));
      closingOrder.AddDeal(ndeal);
      order.DeleteDealAt(0);
   }
   return true;
}

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
   if(initOrder.GetId() == order.GetId() && status == POSITION_ACTIVE)
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

///
/// ��������� ������������ ����� � �������.
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
/// ��������� ����������� ����� � �������� �������.
///
InfoIntegration* CPosition::AddClosingOrder(Order* outOrder)
{
   InfoIntegration* info = NULL;
   if(!CompatibleForClose(outOrder))
   {
      info.InfoMessage = "Closing order has not compatible id with position id.";
      return info;
   }
   info = new InfoIntegration();
   ExchangerList list;
   bool revers = false;
   if(outOrder.ExecutedVolume() <= initOrder.ExecutedVolume())
   {
      list.inOrder = initOrder;
      list.outOrder = outOrder;
   }
   else
   {
      list.outOrder = initOrder;
      list.inOrder = outOrder;
      revers = true;
   }
   SplitOrder(list);
   if(revers)
   {
      delete info.ActivePosition;
      info.ActivePosition = new CPosition(list.outOrder);
      Order* tmp = list.histInOrder;
      list.inOrder = list.histOutOrder;
      list.outOrder = tmp;   
   }
   delete info.HistoryPosition;
   info.HistoryPosition = new CPosition(list.histInOrder, list.histOutOrder);
   return info;
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

///
/// ������, ���� �������� �������� ���������� �� ������� �
/// � ������� ��������������� � ���� � ��������� ������.
///
bool CPosition::MTContainsMe()
{
   if(status == POSITION_NULL)
      return false;
   return true;
}

void CPosition::ExchangerOrder(ExchangerList& list)
{
   if(list.inOrder == NULL || list.outOrder == NULL)
      return;
   if(list.outOrder.ExecutedVolume() <= list.inOrder.ExecutedVolume())
   {
      SplitOrder(list);
   }
   else
   {
      ExchangerList exchList;
      exchList.inOrder = list.outOrder;
      exchList.outOrder = list.outOrder;
      SplitOrder(exchList);
      exchList.inOrder = list.outOrder;
      exchList.outOrder = list.outOrder;
   }
}

///
/// ��������� ��������� ������� � ������� �����.
///
void CPosition::SplitOrder(ExchangerList &list)
{
   //�����, ������� ����� ���������.
   double volTotal = list.outOrder.ExecutedVolume();
   if(list.inOrder.ExecutedVolume() < volTotal)
      return;
   list.histOutOrder = list.outOrder.Clone();
   if(list.histInOrder == NULL)
      list.histInOrder = new Order();
   //����������� �����
   double exVol = 0.0;
   for(int i = 0; i < list.inOrder.DealsTotal(); i++)
   {
      //�����, ������� �������� ���������.
      double rVol = volTotal - exVol;
      //���� ���� ����� �������� - �������.
      if(rVol == 0.0)break;
      CDeal* deal = list.inOrder.DealAt(i);
      double curVol = deal.ExecutedVolume();
      if(deal.ExecutedVolume() > rVol)
      {
         CDeal* hDeal = deal.Clone();
         hDeal.ExecutedVolume(rVol);
         list.histInOrder.AddDeal(hDeal);
         deal.ExecutedVolume(deal.ExecutedVolume() - rVol);
         exVol += rVol;
      }
      else if(deal.ExecutedVolume() <= rVol)
      {
         exVol += deal.ExecutedVolume();
         list.histInOrder.AddDeal(deal.Clone());
         list.inOrder.DeleteDealAt(i);
         i--;
      }
   }   
}

int CPosition::Compare(const CObject* node, const int mode=0)
{
   switch(mode)
   {
      case SORT_ORDER_ID:
      {
         const Transaction* trans = node;
         ulong m_id = GetId();
         ulong p_id = trans.GetId();
         if(GetId() == trans.GetId())
            return EQUAL;
         if(GetId() < trans.GetId())
            return LESS;
         return GREATE;
      }
   }
   return 0;
}
