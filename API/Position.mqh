#include "..\Math.mqh"
#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"
#include "..\Events.mqh"
#include "Tasks.mqh"
#include "Targets.mqh"
#include <Trade\SymbolInfo.mqh>
 
class Position;

///
/// Info about the Integration.
///
class InfoIntegration
{
   public:
      /*InfoIntegration();
      ~InfoIntegration();*/
      bool IsSuccess;
      string InfoMessage;
      Position* ActivePosition;
      Position* HistoryPosition;
};


/*InfoIntegration::InfoIntegration(void)
{
   printf("create infoIntegr.");
   //ActivePosition = new Position();
   //HistoryPosition = new Position();
   //InfoMessage = "";
}

InfoIntegration::~InfoIntegration(void)
{
   printf("delete infoIntegr.");
}*/

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
      
      #ifdef HEDGE_PANEL
         /// ���������� ��������� �� ����������� ������������� ������� �������. 
         PosLine* PositionLine(){return positionLine;}
         /// ������������� ��������� �� ����������� ������������� ������� �������.
         void PositionLine(CObject* pLine){positionLine = pLine;}
      #endif
      ulong EntryOrderId(void);
      ulong ExitOrderId(void);
      
      ulong EntryMagic(void);
      ulong ExitMagic(void);
      virtual ulong Magic(void);
      
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
      bool IsValidNewVolume(double setVol);
      
      string Symbol(void);
      
      double StopLossLevel(void);
      double TakeProfitLevel(void);
      void StopLossLevel(double level);
      void TakeProfitLevel(double level);
      bool UsingStopLoss(void);
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
      static void ExchangerOrder(ExchangerList& list);
      bool Merge(Position* pos);
      Order* EntryOrder(){return initOrder;}
      Order* ExitOrder(){return closingOrder;}
      Order* StopOrder(){return slOrder;}
      bool Compatible(Position* pos);
      virtual int Compare(const CObject* node, const int mode=0);
      void OrderChanged(Order* order);
      void Refresh();
      bool AsynchClose(double vol, string comment = NULL);
      virtual string TypeAsString(void);
      virtual ENUM_DIRECTION_TYPE Direction(void);
      bool IsBlocked();
      void NoticeModify(void);
      void Event(Event* event);
      void SendEventChangedPos(ENUM_POSITION_CHANGED_TYPE type);
      void Unmanagment(bool isUnmng);
      bool Unmanagment(void);
      bool StopLossModify(double newLevel, string comment, bool asynchMode = true);
      bool CheckValidLevelSL(double newLevel);
      bool VirtualStopLoss(){return isVirtualStopLoss;}
      void AddTask(Task* task);
      Order* FindOrderById(ulong id);
      void TaskChanged();
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
         /// ����� �������� ���������.
         ///
         CHANGED_ORDER_SL,
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
      /// ����������, ��������� �� ������� � ��������� �����������.
      ///
      bool isModify;
      ///
      /// ����� ������ ����������.
      ///
      CTime blockedTime;
      ///
      /// �������� ������, ������������, �������� �� ��� ������� �����������.
      ///
      bool unmanagment;
      ///
      /// �������� ������ ������� ������� ������������� ������� �������, ������� ��������� � �������� ���������.
      ///
      //CArrayLong processingOrders;
      ENUM_CHANGED_ORDER DetectChangedOrder(Order* order);
      void AddCanceledOrder(Order* order);
      void DeleteAllOrders();
      void DeleteOrder(Order* order);
      Position* OrderManager(Order* openOrder, Order* cloingOrder);
      bool CompatibleForInit(Order* order);
      bool CompatibleForClose(Order* order);
      bool CompatibleForStop(Order* order);
      bool IntegrateStop(Order* order);
      bool IntegrateStopActPos(Order* order);
      bool IntegrateStopHistPos(Order* order);
      void ChangeStopOrder(Order* order);
      InfoIntegration* AddClosingOrder(Order* outOrder);
      void InitializePosition(Order* inOrder);
      POSITION_STATUS CheckStatus(void);
      void ResetBlocked(void);
      void SetBlock(void);
      void OnRequestNotice(EventRequestNotice* notice);
      void OnRejected(TradeResult& result);
      void OnUpdate(ulong OrderId);
      void ExecutingTask(void);
      void TaskCollector(void);
      bool IsItMyPendingStop(Order* order);
      ///
      /// ������������ ������� �����.
      ///
      Order* initOrder;
      ///
      /// ����������� ����� �������.
      ///
      Order* closingOrder;
      ///
      /// ����-���� �����, ������� ������ � ������� ��������.
      ///
      Order* slOrder;
      ///
      /// ����������� ������� ����-���� ������.
      ///
      double slLevel;
      ///
      /// ����, �����������, �������� �� ������� ����-���� ����� �����������.
      ///
      bool isVirtualStopLoss;
      POSITION_STATUS status;
      void SendEventBlockStatus(bool status);
      #ifdef HEDGE_PANEL
         PosLine* positionLine;
      #endif
      CSymbolInfo infoSymbol;
      ///
      /// ������� ������� ������� ���������� ���������.
      ///
      Task* task;
      ///
      /// ���� �����������, ��� ������� ������� ����� ����������� �� �������.
      ///
      bool usingTimeOut;
      ///
      /// ������� ����.
      ///
      Target* target;
};
///
/// ���������������� �������.
///
Position::~Position()
{
   DeleteAllOrders();
   if(CheckPointer(task) != POINTER_INVALID)
      delete task;
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
   InfoIntegration* info = Integrate(inOrder);
   delete info;
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
   if(inOrder.GetId() != outOrder.PositionId())
      return;
   status = POSITION_HISTORY;
   initOrder = inOrder;
   Refresh();
   initOrder.LinkWithPosition(GetPointer(this));
   closingOrder = outOrder;
   Refresh();
   closingOrder.LinkWithPosition(GetPointer(this));
   if(outOrder.IsStopLoss())
   {
      slOrder = outOrder.Clone();
      slOrder.LinkWithPosition(GetPointer(this));
      Refresh();
   }
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
   Refresh();
   order = pos.ExitOrder();
   if(order == NULL)
      return true;
   while(order.DealsTotal())
   {
      Deal* ndeal = new Deal(order.DealAt(0));
      closingOrder.AddDeal(ndeal);
      order.DeleteDealAt(0);
   }
   Refresh();
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
   if(CompatibleForStop(order))
      IntegrateStop(order);
   else if(CompatibleForInit(order))
   {
      InitializePosition(order);
      info = new InfoIntegration();
   }
   else if(CompatibleForClose(order))
      info = AddClosingOrder(order);
   else
   {
      info = new InfoIntegration();
      info.InfoMessage = "Proposed order #" + (string)order.GetId() +
      "can not be integrated in position #" + (string)GetId() +
      ". Position and order has not compatible types";
      printf("delete order #" + (string)order.GetId());
      bool res = CompatibleForStop(order);
      delete order;
   }
   //������ ���������, ���������� ��������� �������.
   ExecutingTask();
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
   if(order.PositionId() == GetId() &&
      order.Status() == ORDER_HISTORY)
      return true;
   return false;
}

///
/// ������, ���� ����� �������� ����������� � �������� ����-�������.
///
bool Position::CompatibleForStop(Order *order)
{
   // ���� ����� �� ����-���� �� �� �� ��������� ��� ����.
   if(order.IsStopLoss() && !order.IsExecuted() && order.PositionId() == GetId())
      return true;
   return false;
}

///
/// �������� ������� ����-����� ����� �������
/// \param order - �����, ������� ���������� �������� ������� ����-�����.
///
void Position::ChangeStopOrder(Order *order)
{
   DeleteOrder(slOrder);
   slOrder = order;
   slOrder.LinkWithPosition(GetPointer(this));   
}

///
/// ������, ���� ����� ��������� �� ����-������.
///
bool Position::IntegrateStop(Order *order)
{
   if(status == POSITION_ACTIVE)
      return IntegrateStopActPos(order);
   if(status == POSITION_HISTORY)
      return IntegrateStopHistPos(order);
   else
      DeleteOrder(order);
   return false;
}

///
/// ������, ���� ���� ���� ��������� � �������� ��������.
///
bool Position::IntegrateStopActPos(Order *order)
{
   //���������� ������ �� ���������� � ��������� ���������.
   ulong id = order.GetId();
   if(order.IsCanceled())
   {
      //��������� ������������ ������ �����.
      if(UsingStopLoss() && !slOrder.IsPending())
      {
         DeleteOrder(slOrder);
         SendEventChangedPos(POSITION_REFRESH);
      }
      DeleteOrder(order);
      return false;
   }
   //���������� ����� ����������� ����� ������.
   if(order.IsPending())
   {
      ChangeStopOrder(order);
      SendEventChangedPos(POSITION_REFRESH);
   }
   else
      DeleteOrder(order);
   return false;
}

///
/// ������, ���� ���� ���� ��������� � ������������ ��������.
///
bool Position::IntegrateStopHistPos(Order *order)
{
   if(status != POSITION_HISTORY)
      return false;
   if(!order.IsCanceled())
      return false;
   if(UsingStopLoss())
   {
      if(slOrder.IsExecuted())
      {
         DeleteOrder(order);
         return false;
      }
      else
         DeleteOrder(slOrder);
   }
   slOrder = order;
   order.LinkWithPosition(GetPointer(this));
   return true;
}

///
/// ������, ���� id ����������� ������ ������������� �������� ������������ �����.
///
bool Position::IsItMyPendingStop(Order* order)
{
   if(!UsingStopLoss())return false;
   if(slOrder.GetId() == order.GetId())
      return true;
   return false;
}

///
/// ��������� ������������ ����� � �������.
///
void Position::InitializePosition(Order *inOrder)
{
   if(status == POSITION_NULL)
   {
      initOrder = inOrder;
      Refresh();
      inOrder.LinkWithPosition(GetPointer(this));
   }
   //�.�. ������ �������� ���������, �� ��� �������� ��� ������ ����� �����
   //������������� ������ � ���� ����� ���� �������� � �������������� �����.
   else
   {
      for(int i = 0; i < inOrder.DealsTotal(); i++)
      {
         Deal* deal = inOrder.DealAt(i);
         initOrder.AddDeal(deal.Clone());
      }
      delete inOrder;
   }
}

///
/// ��������� ����������� ����� � �������� �������.
///
InfoIntegration* Position::AddClosingOrder(Order* outOrder)
{
   InfoIntegration* info = new InfoIntegration();
   
   info.HistoryPosition = OrderManager(initOrder, outOrder);
   if(outOrder.Status() != ORDER_NULL)
   {
      info.ActivePosition = new Position(outOrder);
      info.ActivePosition.Unmanagment(true);
   }
   else   
      DeleteOrder(outOrder);
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
   //�������� ������� �� ���������� ���������� �����.
   if(status == POSITION_ACTIVE && UsingStopLoss() &&
      slOrder.IsCanceled())
   {
      DeleteOrder(slOrder);
   }
   SendEventChangedPos(POSITION_REFRESH);
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


///
/// ����������� ������������ � ����������� ������� ������ � �����
/// ������������ �������. ����� �������������� �������� � ���������
/// ������ �������� ���� ����������, ��� ������� ��������� ��������.
/// ��������� inOrder �������� ��������� �������� �������. � ������,
/// ���� ����� �������������� outOrder �������� �����-���� �����,
/// ��� ���������� ������������� � �������� �������.
/// \param inOrder - �������� ����� �������� �������.
/// \param outOrder - ���������, ����������� �������� ������� �����.
/// \return ������������ ������� ������� ���� �������.
///
Position* Position::OrderManager(Order* inOrder, Order* outOrder)
{
   //�������� (������ ����� �������), � ������� ����� ����������� ���������� � ��������. 
   int digits = 4;
   //������� ��������� ��������� � ���������� �������, ������� ����� ������������
   //������������ �������.
   Order* histInOrder = new Order();
   Order* histOutOrder = new Order();
   while(true)
   {
      //������ �����������, ������ ��������� ������.
      if(!inOrder.DealsTotal() ||
         !outOrder.DealsTotal())
         break;
      Deal* inDeal = inOrder.DealAt(0);
      Deal* outDeal = outOrder.DealAt(0);
      //�� ���� ������ �������� ���������� �����.
      double inVol = NormalizeDouble(inDeal.VolumeExecuted(), digits);
      double outVol = NormalizeDouble(outDeal.VolumeExecuted(), digits);
      double vol = MathMin(inVol, outVol);
      vol = NormalizeDouble(vol, digits);
      //������ ����� ���� ���� ������ � �������, ������� ������ �� ��������.
      Deal* histInDeal = new Deal(inDeal);
      histInDeal.VolumeExecuted(vol);
      Deal* histOutDeal = new Deal(outDeal);
      histOutDeal.VolumeExecuted(vol);
      //��������� ������������ ������ � ������� ��� ������������ �������.
      histInOrder.AddDeal(histInDeal);
      histOutOrder.AddDeal(histOutDeal);
      //��������� ������ �� ���������� ������ �� ���� �����.
      inDeal.VolumeExecuted(inVol-vol);
      outDeal.VolumeExecuted(outVol-vol);
      //���� � ����� �� ������ ������ ������ �� ��������, - �������� ��.
      if(inDeal.Status() == DEAL_NULL)
         inOrder.DeleteDealAt(0);
      if(outDeal.Status() == DEAL_NULL)
         outOrder.DeleteDealAt(0);
   }
   //������� ������������ �������, ������� ���������� � ����������
   //�������������� ���� �������.
   //histInOrder.CompressDeals();
   //histOutOrder.CompressDeals();
   ulong id = histOutOrder.GetId();
   int dbg;
   if(id == 1009531471)
      dbg = 5;
   Position* histPos = new Position(histInOrder, histOutOrder);
   
   //������������� ������� ���������� ���� ������������� � ������������ ���������.
   if(unmanagment)
      histPos.Unmanagment(true);
   return histPos;
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
   if(UsingStopLoss() && slOrder.GetId() == order.GetId())
      return CHANGED_ORDER_SL;
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
    }
    Refresh();
}

///
/// ������� ��� ������ �������� � �������.
///
void Position::DeleteAllOrders(void)
{
   DeleteOrder(initOrder);
   DeleteOrder(closingOrder);
   if(slOrder != NULL)
   {
      delete slOrder;
      slOrder = NULL;
   }
   
}

///
/// ������� ���������� �����.
///
void Position::DeleteOrder(Order *order)
{
   if(CheckPointer(order) != POINTER_INVALID)
   {
      if(order.IsPending())
      {
         TaskModifySL* sl =
            new TaskModifySL(GetPointer(this), 0.0, "");
         AddTask(sl);
      }
      delete order;
      order = NULL;
   }
}

///
/// ��������� ������� ������� ���� �� ����� ����������.
/// \param vol - �����, ������� ���������� �������.
/// \param comment - �����������, ������� ���������� ��������� ����������� ������.
///
bool Position::AsynchClose(double vol, string comment = NULL)
{
   infoSymbol.Name(Symbol());
   vol = NormalizeDouble(vol, infoSymbol.Digits());
   if(IsBlocked())
   {
      printf("Position is blocked. Try letter");
      return false;
   }
   
   trading.SetAsyncMode(true);
   trading.SetExpertMagicNumber(initOrder.GetMagic(MAGIC_TYPE_MARKET));
   #ifndef DEBUG
      trading.LogLevel(0);
   #endif
   bool resTrans = false;
   if(Direction() == DIRECTION_LONG)
      resTrans = trading.Sell(vol, Symbol(), 0.0, 0.0, 0.0, comment);
   else if(Direction() == DIRECTION_SHORT)
      resTrans = trading.Buy(vol, Symbol(), 0.0, 0.0, 0.0, comment);
   if(resTrans)
      SetBlock();
   else
      printf("Rejected current operation by reason: " + trading.ResultRetcodeDescription());
   return resTrans;
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

ulong Position::Magic()
{
   return EntryMagic();
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
   if(UsingStopLoss())
      return slOrder.PriceSetup();
   return slLevel;
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
   return CheckPointer(slOrder) != POINTER_INVALID;
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
/// ���������� ���������� �������.
///
void Position::ResetBlocked(void)
{
   blocked = false;
   blockedTime.Tiks(0);
   isModify = false;
   SendEventBlockStatus(false);
   SendEventChangedPos(POSITION_REFRESH);
}

///
/// ��������� ������� ��� ����� ���������.
///
void Position::SetBlock(void)
{
   blocked = true;
   blockedTime.SetDateTime(TimeCurrent()*1000);
   SendEventBlockStatus(true);
}

///
/// ���������� ������� ������������ ����������� ������������� ������� � ���,
/// ��� ������� ��������� � ������ ���������.
///
void Position::SendEventBlockStatus(bool curStatus)
{
   #ifdef HEDGE_PANEL
   if(positionLine != NULL)
   {
      EventBlockPosition* event = new EventBlockPosition(GetPointer(this), curStatus);
      positionLine.Event(event);
      delete event;
   }
   #endif
}

///
/// ���������� ������, ���� ������� ��������� � ��������� ��������� � ���� � ��������� ������.
///
bool Position::IsBlocked(void)
{
   if(!isModify)
   {
      if(!blocked)
         return false;
      long elepseTime = TimeCurrent() - blockedTime.ToDatetime();
      if(elepseTime > 180)
         ResetBlocked();
   }
   return isModify || blocked;
}

///
/// ������������ ����������� �������.
///
void Position::Event(Event* event)
{
   switch(event.EventId())
   {
      case EVENT_REQUEST_NOTICE:
         OnRequestNotice(event);
         break;
   }
}

///
/// ������������ ����������� � ��������� �������
///
void Position::OnRequestNotice(EventRequestNotice* notice)
{
   
   TradeResult* result = notice.GetResult();
   TradeTransaction* trans = notice.GetTransaction();
   bool isReset;
   if(result.IsRejected())
   {
      OnRejected(result);
      isReset = true;
   }
   else if(trans.IsUpdate() || trans.IsDelete())
   {
      OnUpdate(trans.order);
      isReset = true;
   }
   if(isReset && blocked)
      ResetBlocked();
}

///
/// ������������ ��������, ����� ������ ��� ��������.
///
void Position::OnRejected(TradeResult& result)
{
   if(!result.IsRejected())return;
   switch(result.retcode)
   {
      case TRADE_RETCODE_NO_MONEY:
         LogWriter("Position #" + (string)GetId() + ": Unmanaged hedge. Try to close parts.", MESSAGE_TYPE_INFO);
   }
   ExecutingTask();
}

///
/// ������������ ��������, ����� ���������� ����� ��� ������.
///
/*void Position::OnDelete(ulong orderId)
{
   if(!result.IsRejected())return;
   switch(result.retcode)
   {
      case TRADE_RETCODE_NO_MONEY:
         LogWriter("Position #" + (string)GetId() + ": Unmanaged hedge. Try to close parts.", MESSAGE_TYPE_INFO);
   }
   ExecutingTask();
}*/

///
/// ��������� ������������ �����.
/// \param OrderId - ������������� ������, ������� ���������.
///
void Position::OnUpdate(ulong OrderId)
{
   Order* changeOrder = FindOrderById(OrderId);
   if(changeOrder != NULL)
      changeOrder.Refresh();
}

///
/// ����� ���������� ������� ��������� � �������� �����������.
///
void Position::NoticeModify(void)
{
   isModify = true;
}


///
/// ���������� ������, ���� ����� ������� ������� ����� ����
/// ������� �� ����� ����� setVol.
///
bool Position::IsValidNewVolume(double setVol)
{
   double curVol = VolumeExecuted();
   if(Math::DoubleEquals(curVol, 0.0))
   {
      LogWriter("Position #" + (string)GetId() + " not active. The new volume not be set.", MESSAGE_TYPE_INFO);
      return false;
   }
   if(Math::DoubleEquals(setVol, 0.0) || setVol < 0.0)
   {
      LogWriter("The new volume should be greater than zero.", MESSAGE_TYPE_INFO);   
      return false;
   }
   if(Math::DoubleEquals(setVol, curVol))
      return false;
   /*if(setVol > curVol)
   {
      LogWriter("The new volume should be less than the current volume.", MESSAGE_TYPE_INFO);
      return false;
   }*/
   return true;
}

///
/// ���������� ����������� ������������� ������� �� ������ � ���,
/// ��� ��������� ������� ����������.
///
void Position::SendEventChangedPos(ENUM_POSITION_CHANGED_TYPE type)
{
   //������ ��� ���������� ������.
   #ifdef HEDGE_PANEL
      if(type != POSITION_SHOW && positionLine == NULL)
         return;
      EventPositionChanged* event = new EventPositionChanged(GetPointer(this), type);
      EventExchange::PushEvent(event);
      delete event;
   #endif
}

///
/// ������������� ������ ������������� �������.
///
void Position::Unmanagment(bool isUnmng)
{
   unmanagment = isUnmng;
}

///
/// ���������� ������ ������������� �������.
///
bool Position::Unmanagment()
{
   return unmanagment;
}

///
/// ������������ ������� ������� ����-�����.
///
bool Position::StopLossModify(double newLevel, string comment=NULL, bool asynchMode = true)
{
   if(status != POSITION_ACTIVE)
      return false;
   infoSymbol.Name(Symbol());
   newLevel = NormalizeDouble(newLevel, infoSymbol.Digits());
   #ifndef DEBUG
      trading.LogLevel(0);
   #endif
   trading.SetAsyncMode(asynchMode);
   bool res = false;
   //������������ ������ ��������������.
   if(!CheckValidLevelSL(newLevel))   
      return false;
   //����������� ����� ������������ �����������.
   else if(isVirtualStopLoss)
   {
      slLevel = newLevel;
      res = true;
   }
   //������ �� �������� Stop-Loss ������.
   else if(Math::DoubleEquals(newLevel, 0.0) && UsingStopLoss() &&
      slOrder.IsPending())
      res = trading.OrderDelete(slOrder.GetId());
   else if(!UsingStopLoss())
   {
      double vol = VolumeExecuted();
      ulong magic = initOrder.GetMagic(MAGIC_TYPE_SL);
      trading.SetExpertMagicNumber(initOrder.GetMagic(MAGIC_TYPE_SL));
      if(Direction() == DIRECTION_LONG)
         res = trading.SellStop(VolumeExecuted(), newLevel, Symbol(), 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
      else if(Direction() == DIRECTION_SHORT)
         res = trading.BuyStop(VolumeExecuted(), newLevel, Symbol(), 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
   }
   else
      res = trading.OrderModify(slOrder.GetId(), newLevel, 0.0, 0.0, ORDER_TIME_GTC, 0, 0);
   if(!res)
   {
      LogWriter("Failed to set or modify stop-loss order. Reason: " +
                 trading.ResultRetcodeDescription(), MESSAGE_TYPE_ERROR);
   }
   if(res && !blocked && !isVirtualStopLoss)
      SetBlock();
   return res;
}

///
/// ��������� �� ������������ ����� ������� ����-�����.
///
bool Position::CheckValidLevelSL(double newLevel)
{
   infoSymbol.Name(Symbol());
   infoSymbol.RefreshRates();
   if(newLevel < 0.0)
   {
      string msg = "Position #" + (string)GetId() + ": New Stop-Loss level must be bigger null.";
      LogWriter(msg, MESSAGE_TYPE_ERROR);
      return false;
   }
   if(Math::DoubleEquals(newLevel, 0.0))
      return true;
   if(Direction() == DIRECTION_LONG)
   {
      double last = infoSymbol.Last();
      if(infoSymbol.Last() < newLevel)
      {
         string msg = "Position #" + (string)GetId() + ": New stop-loss must be less current price.";
         LogWriter(msg, MESSAGE_TYPE_ERROR);
         return false;
      }
      /*if(newLevel >= (infoSymbol.Last() - infoSymbol.FreezeLevel()))
      {
         string msg = "Position #" + (string)GetId() + ": New stop-loss must be less level of freeze.";
         LogWriter(msg, MESSAGE_TYPE_ERROR);
         return false;
      }*/
   }
   if(Direction() == DIRECTION_SHORT)
   {
      double last = infoSymbol.Last();
      if(infoSymbol.Last() > newLevel)
      {
         string msg = "Position #" + (string)GetId() + ": New stop-loss must be bigger current price.";
         LogWriter(msg, MESSAGE_TYPE_ERROR);
         return false;
      }
      /*if(newLevel <= (infoSymbol.Last() + infoSymbol.FreezeLevel()))
      {
         string msg = "Position #" + (string)GetId() + ": New stop-loss must be bigger level of freeze.";
         LogWriter(msg, MESSAGE_TYPE_ERROR);
         return false;
      }*/
   }
   return true;
}

///
/// ��������� ����� ������� � ������� �������.
/// ����������� ������� ����� ������������ � ������ �������,
/// ���� �� ����� ��������� ��� �������� ��������.
///
void Position::AddTask(Task *ctask)
{
   if(IsBlocked())
   {
      LogWriter("Position #" + (string)GetId() + " is blocked. Try letter.", MESSAGE_TYPE_ERROR);
      delete ctask;
      ctask = NULL;
   }
   //������ ������ ������� ���� ��� ��������.
   if(CheckPointer(task) != POINTER_INVALID)
   {
      if(task.IsFinished())
         delete task;
      else
      {
         string msg = "Position# " + (string)GetId() + ": Current operation (" + EnumToString(task.TaskType()) + ") not finished. Try Letter.";
         LogWriter(msg, MESSAGE_TYPE_ERROR);
         delete ctask;
         return;
      }
   }
   task = ctask;
   task.Execute();
   if(task.Status() == TASK_COMPLETED_FAILED || 
      task.Status() == TASK_COMPLETED_SUCCESS)
      Refresh();
}

///
/// ������� ������������ �������.
///
/*void Position::TaskCollector(void)
{
   if(task == NULL)return;
   ENUM_TASK_STATUS taskStatus = task.Status();
   //������� ����������� �������� �� ����������.
   if(taskStatus == TASK_COMPLETED_SUCCESS ||
      taskStatus == TASK_COMPLETED_FAILED)
      delete task;
   else if(task.TimeLastExecution() > 180000)
   {
      delete task;
      ResetBlocked();
   }
   else if(task.TimeLastExecution() == 0)
      task.Execute();
}*/

///
/// ��������� ������� �� ������ �������.
///
void Position::ExecutingTask(void)
{
   if(CheckPointer(task) == POINTER_INVALID)return;
   //���� ���������� ���������.
   //usingTimeOut = true;
   if(task.Status() == TASK_QUEUED ||
      task.Status() == TASK_EXECUTING)
      task.Execute();
   //������������ ������ �������.
   if(task.Status() == TASK_COMPLETED_FAILED ||
      task.Status() == TASK_COMPLETED_SUCCESS)
   {
      LogWriter("Task complete for " + (string)task.TimeExecutionTotal() + " msc.", MESSAGE_TYPE_INFO);
      delete task;
      task = NULL;
      if(blocked)
         ResetBlocked();
      return;
   }
}

///
/// �������� ����� ���� �� ������� �������, ��� �������������
/// ����� ����������. ���������� �������� �����, ���� NULL
/// � ������ �������.
///
Order* Position::FindOrderById(ulong id)
{
   bool uSl = UsingStopLoss();
   ulong sId;
   if(uSl)
      sId = slOrder.GetId();
   if(Status() == POSITION_NULL)return NULL;
   if(initOrder.GetId() == id)return initOrder;
   if(UsingStopLoss() && slOrder.GetId() == id)return slOrder;
   //if(UsingTakeProfit() && tpOrder.GetId() == id)return tpOrder;
   return NULL;
}

///
/// ����������, � ������ ���� ���� ���� ��������
///
void Position::TaskChanged(void)
{
   //if(CheckPointer())
}