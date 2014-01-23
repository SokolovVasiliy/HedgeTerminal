#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"

class Position;

///
/// Info about the Integration.
///
class InfoIntegration
{
   public:
      InfoIntegration();
      bool IsSuccess;
      string InfoMessage;
      Position* ActivePosition;
      Position* HistoryPosition;
};


InfoIntegration::InfoIntegration(void)
{
   ActivePosition = new Position();
   HistoryPosition = new Position();
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

class Position : public Transaction
{
   public:
      Position(void);
      Position(Order* inOrder);
      Position(Order* inOrder, Order* outOrder);
      ~Position();
      
      #ifndef HLIBRARY
         /// ���������� ��������� �� ����������� ������������� ������� �������. 
         PosLine* PositionLine(){return positionLine;}
      #endif
      #ifndef HLIBRARY
         /// ������������� ��������� �� ����������� ������������� ������� �������.
         void PositionLine(CObject* pLine){positionLine = pLine;}
      #endif
      ulong EntryOrderId(void);
      ulong ExitOrderId(void);
      
      ulong EntryMagic(void);
      ulong ExitMagic(void);
      
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
      
      string Symbol(void);
      
      double StopLossLevel(void);
      double TakeProfitLevel(void);
      void StopLossLevel(double level);
      void TakeProfitLevel(double level);
      bool UsingStopLoss(void);
      void UsingStopLoss(bool useStopLoss);
      
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
      static void ExchangerOrder(ExchangerList& list);
      bool Merge(Position* pos);
      Order* EntryOrder(){return initOrder;}
      Order* ExitOrder(){return closingOrder;}
      bool Compatible(Position* pos);
      virtual int Compare(const CObject* node, const int mode=0);
      void OrderChanged(Order* order);
      void Refresh();
      void AsynchClose(double vol, string comment = NULL);
      virtual string TypeAsString(void);
      virtual ENUM_DIRECTION_TYPE Direction(void);
      void ProcessingNewOrder(long ticket);
      bool IsBlocked();
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
      CTime blockedTime;
      ///
      /// �������� ������ ������� ������� ������������� ������� �������, ������� ��������� � �������� ���������.
      ///
      CArrayLong processingOrders;
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
/// ���������������� �������.
///
Position::~Position()
{
   DeleteAllOrders();
}
///
/// ������� ���������� ������� �� �������� POSITION_NULL.
///
Position::Position() : Transaction(TRANS_POSITION)
{
   
   status = POSITION_NULL;
}

///
/// � ������ ������ ������� �������� �������. � ������ �������
/// ����� ������� ������� �� �������� POSITION_NULL.
///
Position::Position(Order* inOrder) : Transaction(TRANS_POSITION)
{
   
   Integrate(inOrder);
}
///
/// ������� ����������� �������. ������ ���������� � ��������� ������� ������ ���� �����.
///
Position::Position(Order* inOrder, Order* outOrder) : Transaction(TRANS_POSITION)
{
   
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

bool Position::Compatible(Position *pos)
{
   if(pos.Status() == POSITION_NULL)
      return false;
   if(pos.GetId() != GetId())
      return false;
   if(pos.Status() != pos.Status())
      return false;
   if(pos.Status() == POSITION_HISTORY)
   {
      Order* clOrder = pos.ExitOrder();
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
bool Position::Merge(Position *pos)
{
   if(!Compatible(pos))
      return false;
   //Merge init deals.
   Order* order = pos.EntryOrder();
   //CArrayObj inDeals = in.D
   while(order.DealsTotal())
   {
      Deal* ndeal = new Deal(order.DealAt(0));
      initOrder.AddDeal(ndeal);
      order.DeleteDealAt(0);
   }
   order = pos.ExitOrder();
   if(order == NULL)
      return true;
   while(order.DealsTotal())
   {
      Deal* ndeal = new Deal(order.DealAt(0));
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
InfoIntegration* Position::Integrate(Order* order)
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
bool Position::CompatibleForInit(Order *order)
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
bool Position::CompatibleForClose(Order *order)
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
void Position::AddInitialOrder(Order *inOrder)
{
   //contextOrder = initOrder;
   //Position* pos = AddOrder(inOrder);
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
         Deal* deal = inOrder.DealAt(i);
         Deal* mDeal = deal.Clone();
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
InfoIntegration* Position::AddClosingOrder(Order* outOrder)
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
      info.ActivePosition = new Position(list.outOrder);
      Order* tmp = list.histInOrder;
      list.inOrder = list.histOutOrder;
      list.outOrder = tmp;   
   }
   delete info.HistoryPosition;
   info.HistoryPosition = new Position(list.histInOrder, list.histOutOrder);
   return info;
}

///
/// ���������, �������� �� ������ ����������� ������ ����������� � �������� "�������".
/// \return ������, ���� ����� ����� ������������ �������, ���� � ��������� ������.
///
static bool Position::CheckOrderType(Order* checkOrder)
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
void Position::Refresh(void)
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
POSITION_STATUS Position::CheckStatus()
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

POSITION_STATUS Position::Status()
{
   return status;
}

void Position::ExchangerOrder(ExchangerList& list)
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
void Position::SplitOrder(ExchangerList &list)
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
      Deal* deal = list.inOrder.DealAt(0);
      double curVol = deal.VolumeExecuted();
      if(deal.VolumeExecuted() > rVol)
      {
         Deal* hDeal = deal.Clone();
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

int Position::Compare(const CObject* node, const int mode=0)
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
ENUM_CHANGED_ORDER Position::DetectChangedOrder(Order *order)
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

void Position::OrderChanged(Order* order)
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
void Position::ChangedInitOrder()
{
   if(initOrder.Status() == ORDER_EXECUTING)
      blocked = true;
   Refresh();
}

///
/// ������� ��� ������.
///
void Position::DeleteAllOrders(void)
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
void Position::AsynchClose(double vol, string comment = NULL)
{
   if(IsBlocked())
   {
      printf("Position is blocked. Try letter");
      return;
   }
   trading.SetAsyncMode(true);
   trading.SetExpertMagicNumber(initOrder.GetMagicForClose());
   if(Direction() == DIRECTION_LONG)
      trading.Sell(vol, Symbol(), 0.0, 0.0, 0.0, comment);
   else if(Direction() == DIRECTION_SHORT)
      trading.Buy(vol, Symbol(), 0.0, 0.0, 0.0, comment);
   blocked = true;
   blockedTime.SetDateTime(TimeCurrent());
}

///
/// ���������� �������� ����������� �������.
///
string Position::EntryComment(void)
{
   if(initOrder != NULL)
      return initOrder.Comment();
   return "";
}

///
/// ���������� ��������� ����������� �������.
///
string Position::ExitComment(void)
{
   if(closingOrder != NULL)
      return closingOrder.Comment();
   return "";
}

///
/// ���������� ������ ����� ��������� �������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long Position::EntrySetupTime(void)
{
   if(initOrder != NULL)
      return initOrder.TimeSetup();
   return 0;
}

///
/// ���������� ������ ����� ������� �� �������� �������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long Position::ExitSetupTime(void)
{
   if(closingOrder != NULL)
      return closingOrder.TimeSetup();
   return 0;
}

///
/// ���������� ������ ����� ���������� �������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long Position::EntryExecutedTime(void)
{
   if(initOrder != NULL)
      return initOrder.TimeExecuted();
   return 0;
}

///
/// ���������� ������ ����� ������������ �������� �������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long Position::ExitExecutedTime(void)
{
   if(closingOrder != NULL)
      return closingOrder.TimeExecuted();
   return 0;
}

///
/// ���������� ����������� ���� ����� � �������.
///
double Position::EntryExecutedPrice(void)
{
   if(initOrder != NULL)
      return initOrder.EntryExecutedPrice();
   return 0.0;
}

///
/// ���������� ����������� ���� ������ �� �������.
///
double Position::ExitExecutedPrice(void)
{
   if(closingOrder != NULL)
      return closingOrder.EntryExecutedPrice();
   return 0.0;
}

///
/// ���������� ����������� ���� ����� � �������.
///
double Position::EntrySetupPrice(void)
{
   if(initOrder != NULL)
      return initOrder.PriceSetup();
   return 0.0;
}

///
/// ���������� ����������� ���� ������ �� �������.
///
double Position::ExitSetupPrice(void)
{
   if(closingOrder != NULL)
      return closingOrder.PriceSetup();
   return 0.0;
}

///
/// ���������� ����������� ����������� ����� �������.
///
double Position::VolumeExecuted(void)
{
   if(initOrder != NULL)
      return initOrder.VolumeExecuted();
   return 0.0;
}

///
/// ���������� ������������� ����������� ������ �������.
///
ulong Position::EntryOrderId()
{
   if(initOrder != NULL)
      return initOrder.GetId();
   return 0;
}

///
/// ���������� ������������� ���������� ������ �������.
///
ulong Position::ExitOrderId()
{
   if(closingOrder != NULL)
      return closingOrder.GetId();
   return 0;
}

///
/// ���������� ���������� ����� ��������� ������.
///
ulong Position::EntryMagic(void)
{
   if(initOrder != NULL)
      return initOrder.Magic();
   return 0;
}

///
/// ���������� ���������� ����� ������������ ������.
///
ulong Position::ExitMagic(void)
{
   if(closingOrder != NULL)
      return closingOrder.Magic();
   return 0;
}

///
/// ���������� ������� ����-�����.
///
double Position::StopLossLevel(void)
{
   return 0.0;
}

///
/// ������������� ������� ����-�����.
///
void Position::StopLossLevel(double level)
{
}

///
/// ���������� ������� ����-�������.
///
double Position::TakeProfitLevel(void)
{
   return 0.0;
}

///
/// ������������� ������� ����-�������.
///
void Position::TakeProfitLevel(double level)
{
}

///
/// ������, ���� ������������ ����-����, ���� � ��������� ������.
///
bool Position::UsingStopLoss(void)
{
   return false;
}

///
/// �������� (useStopLoss=true) ��� ��������� (useStopLoss=false) ������������� ����-�����.
///
void Position::UsingStopLoss(bool useStopLoss)
{
}

///
/// ���������� ������, �� �������� ������� �������.
///
string Position::Symbol()
{
   if(initOrder != NULL)
      return initOrder.Symbol();
   return "";
}

///
/// ���������� ��� �������.
///
string Position::TypeAsString(void)
{
   if(initOrder != NULL)
      return initOrder.TypeAsString();
   return this.TypeAsString();
}

///
/// ����������� �������.
///
ENUM_DIRECTION_TYPE Position::Direction()
{
   if(initOrder != NULL)
      return initOrder.Direction();
   return DIRECTION_NDEF;
}

///
/// ������������ ��� �� ����������� ������, ������� ��������� � ������ �������,
///
void Position::ProcessingNewOrder(long ticket)
{
   Order* order = new Order(ticket);
   if(order.Status() == ORDER_NULL || order.PositionId() != GetId())
      return;
   if(!order.InProcessing())return;
   int index = processingOrders.Search(order.GetId());
   if(index == -1)
      processingOrders.InsertSort(order.GetId());
   delete order;
}

///
/// ���������� ������, ���� ������� ��������� � ��������� ��������� � ���� � ��������� ������.
///
bool Position::IsBlocked(void)
{
   if(processingOrders.Total())
   {
      blocked = false;
      blockedTime.Tiks(0);
      for(int i = 0; i < processingOrders.Total(); i++)
      {
         ulong ticket = processingOrders.At(i);
         Order* order = new Order(ticket);
         if(!order.InProcessing())
            processingOrders.Delete(i);
         delete order;
      }
   }
   if(blocked)
   {
      datetime elepseTime = TimeCurrent() - blockedTime.ToDatetime();
      if(elepseTime > 180)
      {
         blocked = false;
         blockedTime.Tiks(0);
      }
   }
   if(blocked || processingOrders.Total() > 0)
      return true;
   return false;
}