#include "..\Math.mqh"
#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"
#include "..\Events.mqh"
#include "Tasks.mqh"
#include <Trade\SymbolInfo.mqh>
 
class Position;

///
/// Info about the Integration.
///
class InfoIntegration
{
   public:
      bool IsSuccess;
      string InfoMessage;
      Position* ActivePosition;
      Position* HistoryPosition;
};

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
      virtual string TypeAsString(void);
      virtual ENUM_DIRECTION_TYPE Direction(void);
      bool IsBlocked();
      void NoticeModify(void);
      void Event(Event* event);
      void SendEventChangedPos(ENUM_POSITION_CHANGED_TYPE type);
      void Unmanagment(bool isUnmng);
      bool Unmanagment(void);
      bool VirtualStopLoss(){return isVirtualStopLoss;}
      
      void AddTask(Task2* task);
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
      void AddClosingOrder(Order* outOrder, InfoIntegration* info);
      void InitializePosition(Order* inOrder);
      POSITION_STATUS CheckStatus(void);
      void ResetBlocked(void);
      void SetBlock(void);
      void OnRequestNotice(EventRequestNotice* notice);
      void OnRejected(TradeResult& result);
      void OnUpdate(ulong OrderId);
      void ExecutingTask(void);
      void NoticeTask();
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
      /// ���� �����������, ��� ������� ������� ����� ����������� �� �������.
      ///
      bool usingTimeOut;
      ///
      /// ������� ����.
      ///
      Task2* task2;
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
   ulong orderId = order.GetId();
   InfoIntegration* info = new InfoIntegration;
   //������, ���� ����������� ����� ������� ������������.
   bool res = false;
   if(CompatibleForStop(order))
      info.IsSuccess = IntegrateStop(order);
   else if(CompatibleForInit(order))
   {
      InitializePosition(order);
      info.IsSuccess = true;
   }
   else if(CompatibleForClose(order))
      AddClosingOrder(order, info);
   else
   {
      info.InfoMessage = "Proposed order #" + (string)order.GetId() +
      "can not be integrated in position #" + (string)GetId() +
      ". Position and order has not compatible types";
   }
   //ExecutingTask();
   NoticeTask();
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
      return false;
   }
   //���������� ����� ����������� ����� ������.
   if(order.IsPending())
   {
      ChangeStopOrder(order);
      SendEventChangedPos(POSITION_REFRESH);
      return true;
   }
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
         return false;
      }
      else
         DeleteOrder(slOrder);
   }
   slOrder = order;
   order.LinkWithPosition(GetPointer(this));
   SendEventChangedPos(POSITION_REFRESH);
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
void Position::AddClosingOrder(Order* outOrder, InfoIntegration* info)
{
   info.IsSuccess = true;
   info.HistoryPosition = OrderManager(initOrder, outOrder);
   if(outOrder.Status() != ORDER_NULL)
   {
      info.ActivePosition = new Position(outOrder);
      info.ActivePosition.Unmanagment(true);
   }
   else
      DeleteOrder(outOrder);
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
   /*if(status == POSITION_ACTIVE && UsingStopLoss() &&
      slOrder.IsCanceled())
   {
      DeleteOrder(slOrder);
   }*/
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
      delete order;
      order = NULL;
   }
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
   //SendEventChangedPos(POSITION_REFRESH);
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
   //if(isReset && blocked)
   //   ResetBlocked();
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
}
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

void Position::AddTask(Task2 *ctask)
{
   if(CheckPointer(task2) != POINTER_INVALID)
   {
      if(task2.IsActive())
      {
         delete task2;
         LogWriter("Position is blocked. Try letter.", MESSAGE_TYPE_ERROR);
      }
   }
   task2 = ctask;
   task2.Execute();
}

///
/// ���������� ������ � ��������� �������.
///
void Position::NoticeTask(void)
{
   if(CheckPointer(task2) == POINTER_INVALID)
      return;
   EventPositionChanged* event = new EventPositionChanged(GetPointer(this), POSITION_REFRESH);
   task2.Event(event);
   delete event;
}

///
/// ����������, � ������ ��������� ������� ������� ������.
///
void Position::TaskChanged(void)
{
   if(CheckPointer(task2) == POINTER_INVALID)
      return;
   if(task2.IsFinished())
   {
      task2 = NULL;
      ResetBlocked();
      SendEventChangedPos(POSITION_REFRESH);
   }
   else if((task2.Status() == TASK_STATUS_EXECUTING) && !blocked)
      SetBlock();
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

