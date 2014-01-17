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
   InfoMessage = "";
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

class CPosition : public Transaction
{
   public:
      CPosition(void);
      CPosition(Order* inOrder);
      CPosition(Order* inOrder, Order* outOrder);
      ~CPosition();
      
      #ifndef HLIBRARY
         /// ���������� ��������� �� ����������� ������������� ������� �������. 
         PosLine* PositionLine(){return positionLine;}
      #endif
      #ifndef HLIBRARY
         /// ������������� ��������� �� ����������� ������������� ������� �������.
         void PositionLine(CObject* pLine){positionLine = pLine;}
      #endif
      
      string EntryComment(void);
      string ExitComment(void);
      
      long EntryExecutedTime(void);
      long ExitExecutedTime(void);
      
      long EntrySetupTime(void);
      long ExitSetupTime(void);
      
      double EntryExecutedPrice(void);
      double ExitExecutedPrice(void);
      
      double EntrySetupPrice(void);
      double ExitSetupPrice(void);
      
      double VolumeSetup(void);
      double VolumeRejected(void);
      virtual double VolumeExecuted(void);
      
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
      static void ExchangerOrder(ExchangerList& list);
      bool Merge(CPosition* pos);
      Order* InitOrder(){return initOrder;}
      Order* ClosingOrder(){return closingOrder;}
      bool Compatible(CPosition* pos);
      virtual int Compare(const CObject* node, const int mode=0);
      void OrderChanged(Order* order);
      void Refresh();
      void AsynchClose(double vol, string comment = NULL);
   private:
      ///
      /// �����, ��� ���������� �������� ��������.
      ///
      CTrade trading;
      void Init();
      ///
      /// ���������� ��� ������, ������� ��� �������.
      ///
      enum ENUM_CHANGED_ORDER
      {
         ///
         /// ���� ����� �� ����������� � ������� �������.
         ///
         CHANGED_ORDER_NDEF,
         ///
         /// ���� ����� ������������� �������. 
         ///
         CHANGED_ORDER_INIT,
         ///
         /// ���� ����� ��������� �������.
         ///
         CHANGED_ORDER_CLOSED
      };
      ///
      /// ���� ����������, ������, ���� ������� ��������� � �������� ���������.
      ///
      bool blocked;
      ///
      /// ����� ������ ����������.
      ///
      CTime* blockedTime;
      ENUM_CHANGED_ORDER DetectChangedOrder(Order* order);
      void ChangedInitOrder();
      void DeleteAllOrders();
      static void SplitOrder(ExchangerList& list);
      virtual bool MTContainsMe();
      bool CompatibleForInit(Order* order);
      bool CompatibleForClose(Order* order);
      InfoIntegration* AddClosingOrder(Order* outOrder);
      void AddInitialOrder(Order* inOrder);
      POSITION_STATUS CheckStatus(void);
      Order* initOrder;
      Order* closingOrder;
      POSITION_STATUS status;
      #ifndef HLIBRARY
         PosLine* positionLine;
      #endif
};

///
/// �������������� ������� �������.
///
void CPosition::Init()
{
   blockedTime = new CTime();
}
///
/// ���������������� �������.
///
CPosition::~CPosition()
{
   delete blockedTime;
   DeleteAllOrders();
}
///
/// ������� ���������� ������� �� �������� POSITION_NULL.
///
CPosition::CPosition() : Transaction(TRANS_POSITION)
{
   Init();
   status = POSITION_NULL;
}

///
/// � ������ ������ ������� �������� �������. � ������ �������
/// ����� ������� ������� �� �������� POSITION_NULL.
///
CPosition::CPosition(Order* inOrder) : Transaction(TRANS_POSITION)
{
   Init();
   Integrate(inOrder);
}
///
/// ������� ����������� �������. ������ ���������� � ��������� ������� ������ ���� �����.
///
CPosition::CPosition(Order* inOrder, Order* outOrder) : Transaction(TRANS_POSITION)
{
   Init();
   if(inOrder == NULL || outOrder == NULL)
      return;
   if(inOrder.VolumeExecuted() != outOrder.VolumeExecuted())
      return;
   ulong in_id = inOrder.PositionId();
   ulong out_id = outOrder.PositionId();
   if(inOrder.PositionId() != outOrder.PositionId())
      return;
   status = POSITION_HISTORY;
   initOrder = inOrder;
   initOrder.LinkWithPosition(GetPointer(this));
   closingOrder = outOrder;
   closingOrder.LinkWithPosition(GetPointer(this));
   Refresh();
}

bool CPosition::Compatible(CPosition *pos)
{
   if(pos.Status() == POSITION_NULL)
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
   {
      info = AddClosingOrder(order);
   }
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

///
/// ��������� ������������ ����� � �������.
///
void CPosition::AddInitialOrder(Order *inOrder)
{
   //contextOrder = initOrder;
   //CPosition* pos = AddOrder(inOrder);
   if(status == POSITION_NULL)
   {
      initOrder = inOrder;
      Refresh();
      inOrder.LinkWithPosition(GetPointer(this));
   }
   else if(status == POSITION_ACTIVE)
   {
      for(int i = 0; i < inOrder.DealsTotal(); i++)
      {
         CDeal* deal = inOrder.DealAt(i);
         CDeal* mDeal = deal.Clone();
         mDeal.LinqWithOrder(initOrder);
         initOrder.AddDeal(mDeal);
      }
      delete inOrder;
   }
   return;
}

///
/// ��������� ����������� ����� � �������� �������.
///
InfoIntegration* CPosition::AddClosingOrder(Order* outOrder)
{
   InfoIntegration* info = new InfoIntegration();
   if(!CompatibleForClose(outOrder))
   {
      info.InfoMessage = "Closing order has not compatible id with position id.";
      return info;
   }
   ExchangerList list;
   bool revers = false;
   if(outOrder.VolumeExecuted() <= initOrder.VolumeExecuted())
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
   //Refresh();
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
///
///
void CPosition::Refresh(void)
{
   CheckStatus();
   if(initOrder != NULL)
      SetId(initOrder.GetId());
   else
      SetId(0);
}

///
/// ��������� ������ �������.
///
POSITION_STATUS CPosition::CheckStatus()
{
   if(CheckPointer(initOrder) == POINTER_INVALID ||
      initOrder.DealsTotal() == 0 || initOrder.VolumeExecuted() == 0.0)
   {
      status = POSITION_NULL;
      return status;
   }
   if(CheckPointer(closingOrder) != POINTER_INVALID)
      status = POSITION_HISTORY;
   else
      status = POSITION_ACTIVE;
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
   if(list.outOrder.VolumeExecuted() <= list.inOrder.VolumeExecuted())
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
/// �������� ��������� ������� � ������� �����.
///
void CPosition::SplitOrder(ExchangerList &list)
{
   //�����, ������� ����� ���������.
   ulong in_id = list.inOrder.GetId();
   ulong out_id = list.outOrder.GetId();
   double volTotal = list.outOrder.VolumeExecuted();
   if(list.inOrder.VolumeExecuted() < volTotal)
      return;
   
   list.histOutOrder = list.outOrder;
   list.histInOrder = new Order();
   //����������� �����
   double exVol = 0.0;
   while(list.inOrder.DealsTotal())
   {
      //�����, ������� �������� ���������.
      double rVol = volTotal - exVol;
      //���� ���� ����� �������� - �������.
      if(rVol == 0.0)break;
      CDeal* deal = list.inOrder.DealAt(0);
      double curVol = deal.VolumeExecuted();
      if(deal.VolumeExecuted() > rVol)
      {
         CDeal* hDeal = deal.Clone();
         hDeal.VolumeExecuted(rVol);
         list.histInOrder.AddDeal(hDeal);
         deal.VolumeExecuted(deal.VolumeExecuted() - rVol);
         exVol += rVol;
      }
      else if(deal.VolumeExecuted() <= rVol)
      {
         exVol += deal.VolumeExecuted();
         list.histInOrder.AddDeal(deal.Clone());
         list.inOrder.DeleteDealAt(0);
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
         ulong my_id = GetId();
         ulong trans_id = trans.GetId();
         if(GetId() == trans.GetId())
            return EQUAL;
         if(GetId() < trans.GetId())
            return LESS;
         return GREATE;
      }
   }
   return 0;
}

///
/// ���������� ��� ������, ������� ��� �������.
///
ENUM_CHANGED_ORDER CPosition::DetectChangedOrder(Order *order)
{
   if(status == POSITION_NULL)
      return CHANGED_ORDER_NDEF;
   if(initOrder.GetId() == order.GetId())
      return CHANGED_ORDER_INIT;
   if(status == POSITION_HISTORY &&
      closingOrder.GetId() == order.GetId())
      return CHANGED_ORDER_CLOSED;      
   return CHANGED_ORDER_INIT;
}

void CPosition::OrderChanged(Order* order)
{
    ENUM_CHANGED_ORDER changedType = DetectChangedOrder(order);
    switch(changedType)
    {
      case CHANGED_ORDER_NDEF:
         return;
      case CHANGED_ORDER_INIT:
         ChangedInitOrder();
         break;
      case CHANGED_ORDER_CLOSED:
         break;
    }
}

///
/// ������������ ��������� ������������� ������.
///
void CPosition::ChangedInitOrder()
{
   if(initOrder.Status() == ORDER_EXECUTING)
      blocked = true;
   Refresh();
}

///
/// ������� ��� ������.
///
void CPosition::DeleteAllOrders(void)
{
   if(initOrder != NULL)
   {
      delete initOrder;
      initOrder = NULL;
   }
   if(closingOrder != NULL)
   {
      delete closingOrder;
      closingOrder = NULL;
   }
}

///
/// ��������� ������� ������� ����������.
///
void CPosition::AsynchClose(double vol, string comment = NULL)
{
   trading.SetAsyncMode(true);
   trading.SetExpertMagicNumber(initOrder.GetMagicForClose());
   if(Direction() == DIRECTION_LONG)
      trading.Sell(vol, Symbol(), 0.0, 0.0, 0.0, comment);
   else if(Direction() == DIRECTION_SHORT)
      trading.Buy(vol, Symbol(), 0.0, 0.0, 0.0, comment);
}

///
/// ���������� �������� ����������� �������.
///
string CPosition::EntryComment(void)
{
   if(initOrder != NULL)
      return initOrder.Comment();
   return "";
}

///
/// ���������� ��������� ����������� �������.
///
string CPosition::ExitComment(void)
{
   if(closingOrder != NULL)
      return closingOrder.Comment();
   return "";
}

///
/// ���������� ������ ����� ��������� �������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long CPosition::EntrySetupTime(void)
{
   if(initOrder != NULL)
      return initOrder.TimeSetup();
   return 0;
}

///
/// ���������� ������ ����� ������� �� �������� �������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long CPosition::ExitSetupTime(void)
{
   if(closingOrder != NULL)
      return closingOrder.TimeSetup();
   return 0;
}

///
/// ���������� ������ ����� ���������� �������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long CPosition::EntryExecutedTime(void)
{
   if(initOrder != NULL)
      return initOrder.TimeExecuted();
   return 0;
}

///
/// ���������� ������ ����� ������������ �������� �������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long CPosition::ExitExecutedTime(void)
{
   if(closingOrder != NULL)
      return closingOrder.TimeExecuted();
   return 0;
}

///
/// ���������� ����������� ���� ����� � �������.
///
double CPosition::EntryExecutedPrice(void)
{
   if(initOrder != NULL)
      return initOrder.PriceExecuted();
   return 0.0;
}

///
/// ���������� ����������� ���� ������ �� �������.
///
double CPosition::ExitExecutedPrice(void)
{
   if(closingOrder != NULL)
      return closingOrder.PriceExecuted();
   return 0.0;
}

///
/// ���������� ����������� ���� ����� � �������.
///
double CPosition::EntrySetupPrice(void)
{
   if(initOrder != NULL)
      return initOrder.PriceSetup();
   return 0.0;
}

///
/// ���������� ����������� ���� ������ �� �������.
///
double CPosition::ExitSetupPrice(void)
{
   if(closingOrder != NULL)
      return closingOrder.PriceSetup();
   return 0.0;
}

double CPosition::VolumeExecuted(void)
{
   if(closingOrder != NULL)
      return closingOrder.VolumeExecuted();
   return 0.0;
}