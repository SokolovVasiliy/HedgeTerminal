#include "..\Math.mqh"
#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"
#include "..\Events.mqh"
#include "Tasks.mqh"
#include <Trade\SymbolInfo.mqh>
//#include "..\XML\XmlPosition.mqh"
//#include "..\XML\XmlPosition1.mqh"
//#include "..\XML\XmlPos.mqh"
#include "..\XML\XmlPos2.mqh"
#include "TralStopLoss.mqh"

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
/// State of position.
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
      void ExitComment(string comment, bool saveState, bool asynchMode=true);
      
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
      ENUM_HEDGE_ERR StopLossLevel(double level, bool asynch_mode);
      ENUM_HEDGE_ERR TakeProfitLevel(double level, bool saveState);
      bool UsingStopLoss(void);
      bool UsingTakeProfit(void);
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
      static void ExchangerOrder(ExchangerList& list);
      bool Merge(Position* pos);
      Order* EntryOrder(){return initOrder;}
      Order* ExitOrder(){return closingOrder;}
      Order* StopOrder(){return slOrder;}
      bool Compatible(Position* pos);
      virtual int Compare(  CObject* node,   int mode=0);
      void OrderChanged(Order* order);
      void Refresh();
      virtual string TypeAsString(void);
      virtual ENUM_DIRECTION_TYPE Direction(void);
      bool IsBlocked();
      void Event(Event* event);
      void SendEventChangedPos(ENUM_POSITION_CHANGED_TYPE type);
      void Unmanagment(bool isUnmng);
      bool Unmanagment(void);
      bool VirtualStopLoss(){return isVirtualStopLoss;}
      
      ENUM_HEDGE_ERR AddTask(Task2* task);
      Task2* GetTask(void);
      Order* FindOrderById(ulong id);
      void TaskChanged();
      ///
      /// ���������� ��������� �� ��� �������.
      ///
      TaskLog* GetTaskLog(){return GetPointer(taskLog);}
      ///
      /// �������� ��������� ��� �����.
      ///
      void CopyTaskLog(TaskLog* logs);
      ///
      /// ������� ������� ����-���.
      ///
      void ClearTaskLog(void){taskLog.Clear();}
      ///
      /// �������� ������� ��������� ���� �����.
      ///
      void PrintTaskLog();
      ///
      /// ������� ���� ������� �� ���� �������.
      ///
      virtual double CurrentPrice(void);
      ///
      /// ���������� ���������� �������� ��� �������.
      ///
      virtual double Commission(void);
      ///
      /// ��������� ��� ��������� ���������� xml �������� �������.
      /// \return ������, ���� ���� �� ���� �� ���������� �������� ����������
      /// �� �������� � ���� � ��������� ������.
      ///
      bool AttributesChanged(double tp, string exComment, datetime time);
      ///
      /// ��������� �� ��������� �������� ����������. ���������� ������, ���� �������� ��� �������.
      /// � ���� � ��������� ������.
      ///
      bool CheckChangesAttributes(double tp, string exComment, datetime time);
      ///
      /// �������������� ������ �� XML ���� �������� �������.
      ///
      void CreateXmlLink(void);
      ///
      /// ������� ���������� � ������� �������.
      /// \param saveState - ������, ���� ��������� ������������ ���������� ���������� � ����.
      ///
      void ResetBlocked(bool saveState);
      ///
      /// ������������� ���������� �� ������� �������.
      /// \param time - ����� ������ ����������.
      /// \param saveState - ������, ���� ��������� ������������ ���������� ���������� � ����.
      ///
      void SetBlock(datetime time, bool saveState);
      ///
      /// �������� ����-������.
      ///
      TrallStopLoss* TralStopOrder;
      ///
      /// ���������� �������� ������ ��������������� ������� � �������.
      ///
      double Slippage();
   private:
      ///
      /// ��������� ���������� � ������� � XML-���� ����� �������� �������.
      ///
      void SaveXmlActive();
      ///
      /// ���������� ������� ���������� �� XML-���� � ������� �������.
      ///
      void DeleteXmlActive();
      ///
      /// �������� ������� ���������� ��������� � ���������� �����.
      ///
      void RefreshVisualForm(ENUM_POSITION_CHANGED_TYPE type);
      void OnRefresh(void);
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
      /// ����� ������ ����������. ����� ������������ ��� ����������� ���� ���������� ��� ���.
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
      
      void OnRequestNotice(EventRequestNotice* notice);
      void OnRejected(TradeResult& result);
      void OnUpdate(ulong OrderId);
      void ExecutingTask(void);
      void NoticeTask();
      void TaskCollector(void);
      bool IsItMyPendingStop(Order* order);
      bool CheckValidTP(double tp);
      bool CheckValidSL(double sl);
      bool CheckHistSL(double sl);
      bool CheckHistTP(double tp);
      void CloseByVirtualOrder(void);
      bool AbilityTrade();
      int GetSecondsDelay(uint retcode);
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
      ///
      /// ����������� ����������� ��� �������� �������.
      ///
      string exitComment;
      ///
      /// ����������� ���� ������ ��� �������.
      ///
      double takeProfit;
      ///
      /// �������� XML ������������� �������� �������.
      ///
      XmlPos2* activeXmlPos;
      ///
      /// ������, ���� ������� ������� ���� ����������. 
      ///
      bool showed;
      ///
      /// ��� ���������� �������.
      ///
      TaskLog taskLog;
};
///
/// ���������������� �������.
///
Position::~Position()
{
   DeleteAllOrders();
   if(CheckPointer(activeXmlPos) != POINTER_INVALID)
      delete activeXmlPos;
   if(CheckPointer(TralStopOrder) != POINTER_INVALID)
      delete TralStopOrder;
}
///
/// ������� ���������� ������� �� �������� POSITION_NULL.
///
Position::Position() : Transaction(TRANS_POSITION)
{
   Init();
   status = POSITION_NULL;
}

///
/// � ������ ������ ������� �������� �������. � ������ �������
/// ����� ������� ������� �� �������� POSITION_NULL.
///
Position::Position(Order* inOrder) : Transaction(TRANS_POSITION)
{
   Init();
   InfoIntegration* info = Integrate(inOrder);
   delete info;
}
///
/// ������� ����������� �������. ������ ���������� � ��������� ������� ������ ���� �����.
///
Position::Position(Order* inOrder, Order* outOrder) : Transaction(TRANS_POSITION)
{
   Init();
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
///
/// �������������� ���� �������� ����������.
///
void Position::Init(void)
{
   TralStopOrder = new TrallStopLoss(GetPointer(this));
   exitComment = "";
   takeProfit = 0.0;
   slLevel = 0.0;
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
         exitComment = slOrder.Comment();
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
   if(initOrder.Status() == ORDER_NULL)
   {
      if(CheckPointer(activeXmlPos) != POINTER_INVALID)
         activeXmlPos.SaveState(STATE_DELETE);
      info.HistoryPosition.TakeProfitLevel(TakeProfitLevel(), true);
      info.HistoryPosition.CopyTaskLog(GetPointer(taskLog));
   }
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
   Position* histPos = new Position(histInOrder, histOutOrder);
   //������������� ������� ���������� ���� ������������� � ������������ ���������.
   if(unmanagment)
      histPos.Unmanagment(true);
   return histPos;
}

int Position::Compare(  CObject* node,   int mode=0)
{
   switch(mode)
   {
      case SORT_ORDER_ID:
      {
           Transaction* trans = node;
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
   if(CheckPointer(slOrder) != POINTER_INVALID)
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
   if(CheckPointer(slOrder) != POINTER_INVALID)
      return slOrder.Comment();
   return exitComment;
}

///
/// ������������� ��������� ����������� ��� �������� �������.
///
void Position::ExitComment(string comment, bool saveState, bool asynchMode=true)
{
   if(status != POSITION_ACTIVE)return;
   if(StringLen(comment) > 31)
      comment = StringSubstr(comment, 0, 31);
   if(exitComment == comment)return;
   exitComment = comment;
   if(UsingStopLoss() && slOrder.Comment() != comment)
      AddTask(new TaskChangeCommentStopLoss(GetPointer(this), exitComment, asynchMode));
   else if(saveState && !UsingStopLoss())
      SaveXmlActive();
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
   {
      return slOrder.PriceSetup();
   }
   if(status == POSITION_HISTORY && Math::DoubleEquals(takeProfit, 0.0))
   {
      double sl = Settings.GetLevelVirtualOrder(GetId(), VIRTUAL_STOP_LOSS);
      if(CheckHistSL(sl))
         slLevel = sl;
   }
   return slLevel;
}

///
/// ������������� ������� ����-�����.
/// \return ������, ���� ����� ������� ���������, � �� ��� ������ ����
/// ������������ ����� ������ � ���� � ��������� ������..
///
ENUM_HEDGE_ERR Position::StopLossLevel(double level, bool asynch_mode = true)
{
   ENUM_HEDGE_ERR err = HEDGE_ERR_NOT_ERROR;
   double setPrice = level;
   bool notNull = !Math::DoubleEquals(setPrice, 0.0);
   if(UsingStopLoss() && !notNull)
      err = AddTask(new TaskDeleteStopLoss(GetPointer(this), asynch_mode));
   else if(!UsingStopLoss() && notNull)
      err = AddTask(new TaskSetStopLoss(GetPointer(this), setPrice, asynch_mode));
   else if(UsingStopLoss())
   {
      if(notNull && !Math::DoubleEquals(setPrice, StopLossLevel()))
         err = AddTask(new TaskModifyStop(GetPointer(this), setPrice, asynch_mode));
   }
   SendEventChangedPos(POSITION_REFRESH);
   return err;
}

///
/// ���������� ������� ����-�������.
///
double Position::TakeProfitLevel(void)
{
   if(status == POSITION_HISTORY && Math::DoubleEquals(takeProfit, 0.0))
   {
       if(closingOrder != NULL && closingOrder.IsTakeProfit())
         return closingOrder.EntryExecutedPrice();
       double tp = Settings.GetLevelVirtualOrder(GetId(), VIRTUAL_TAKE_PROFIT);
       if(CheckHistTP(tp))
         takeProfit = tp;
   }
   return takeProfit;
}

///
/// ������������� ������� ����-�������.
/// \param level - ����� ������� TakeProfit. 
/// \param saveState - ������, ���� ��������� ��������� ���� ������� � XML ����� ������� � ���� � ��������� ������.
/// \return ���� ���������� ��������� ����� ����.
///
ENUM_HEDGE_ERR Position::TakeProfitLevel(double level, bool saveState)
{
   ENUM_HEDGE_ERR err = HEDGE_ERR_NOT_ERROR;
   bool check = CheckValidTP(level);
   if(!check)
      err = HEDGE_ERR_WRONG_PARAMETER;
   if(check && Status() == POSITION_ACTIVE)
   {
      takeProfit = level;
      if(saveState)
         SaveXmlActive();
   }
   SendEventChangedPos(POSITION_REFRESH);
   return err;
}

///
/// ������, ���� ������������ ����-����, ���� � ��������� ������.
///
bool Position::UsingStopLoss(void)
{
   return CheckPointer(slOrder) != POINTER_INVALID;
}

bool Position::UsingTakeProfit(void)
{
   return !Math::DoubleEquals(takeProfit,0.0);
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
/// ���������� ������, ���� ������� ��������� � ��������� ��������� � ���� � ��������� ������.
///
bool Position::IsBlocked(void)
{
   if(blockedTime.Tiks() == 0)
      return false;
   //� ������ ������������� ������� ���������� �� ��������.
   datetime tB = blockedTime.ToDatetime();
   if(TimeCurrent() - tB >= 180)
   {
      blockedTime.Tiks(0);
      SendEventBlockStatus(false);
      if(activeXmlPos != NULL)
         activeXmlPos.SaveState();
      return false;
   }
   return true;
}

///
/// ���������� ���������� �������.
///
void Position::ResetBlocked(bool saveState)
{
   if(IsBlocked())
   {
      //printf("Reset block");
      blockedTime.Tiks(0);
      SendEventBlockStatus(false);
      if(activeXmlPos != NULL && saveState)
         activeXmlPos.SaveState();
   }
}

///
/// ��������� ������� ��� ����� ���������.
///
void Position::SetBlock(datetime time, bool saveState)
{
   if(!IsBlocked())
   {
      //printf("SetBlock #" + (string)GetId());
      blockedTime.SetDateTime(time);
      datetime myTime = blockedTime.ToDatetime();
      SendEventBlockStatus(true);
      if(saveState)
         SaveXmlActive();
   }
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
/// ������������ ����������� �������.
///
void Position::Event(Event* event)
{
   switch(event.EventId())
   {
      case EVENT_REQUEST_NOTICE:
         OnRequestNotice(event);
         break;
      case EVENT_REFRESH:
         OnRefresh();
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
}
///
/// ��������� ������������ ����� � xml ����� ����������� �������.
///
/*void Position::SaveVirtualOrder(int ENUM_VIRTUAL_ORDER_TYPE)
{
   
}*/

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
   if(!showed && type != POSITION_SHOW)
      return;
   showed = true;
   RefreshVisualForm(type);
}

void Position::RefreshVisualForm(ENUM_POSITION_CHANGED_TYPE type)
{
   #ifdef HEDGE_PANEL
      if(type != POSITION_SHOW && positionLine == NULL)
         return;
      EventPositionChanged* event = new EventPositionChanged(GetPointer(this), type);
      HedgePanel.Event(event);
      //EventExchange.PushEvent(event);
      delete event;
   #endif
}

void Position::SaveXmlActive(void)
{
   if(MQLInfoInteger(MQL_TESTER))
      return;
   if(Status() != POSITION_ACTIVE)
      return;
   if(CheckPointer(activeXmlPos) == POINTER_INVALID)
      activeXmlPos = new XmlPos2(GetPointer(this));
   activeXmlPos.SaveState(STATE_REFRESH);
}

void Position::CreateXmlLink()
{
   if(MQLInfoInteger(MQL_TESTER))
      return;
   if(Status() != POSITION_ACTIVE)
      return;
   if(CheckPointer(activeXmlPos) == POINTER_INVALID)
      activeXmlPos = new XmlPos2(GetPointer(this));
}

void Position::DeleteXmlActive()
{
   if(MQLInfoInteger(MQL_TESTER))
      return;
   if(Status() != POSITION_ACTIVE)
      return;
   if(CheckPointer(activeXmlPos) == POINTER_INVALID)
      activeXmlPos = new XmlPos2(GetPointer(this));
   activeXmlPos.SaveState(STATE_DELETE);
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
/// �������� ������ �� ���������� � ��������� ��.
/// \return ����, ���� ������ ������ ����� ������� ����������
///
ENUM_HEDGE_ERR Position::AddTask(Task2 *ctask)
{
   if(CheckPointer(ctask) == POINTER_INVALID)
      return HEDGE_ERR_TASK_FAILED;
   // ��������� ��������.
   api.OnRefresh();
   if(IsBlocked())
   {
      #ifdef HEDGE_PANEL
      LogWriter("Current position is frozen and not be changed. Try later.", MESSAGE_TYPE_WARNING);
      SendEventChangedPos(POSITION_REFRESH);
      #endif
      delete ctask;
      taskLog.AddRedcode(TARGET_CREATE_TASK, TRADE_RETCODE_FROZEN);
      return HEDGE_ERR_POS_FROZEN;
   }
   taskLog.Clear();
   task2 = ctask;
   task2.Execute();
   if(CheckPointer(task2) == POINTER_INVALID || task2.Status() == TASK_STATUS_FAILED)
      return HEDGE_ERR_TASK_FAILED;
   else
      return HEDGE_ERR_NOT_ERROR;
}

/*ENUM_HEDGE_ERR Position::AddTask(Task2 *ctask)
{
   if(CheckPointer(ctask) == POINTER_INVALID)
      return HEDGE_ERR_TASK_FAILED;
   api.OnRefresh();
   if(IsBlocked())
   {
      #ifdef HEDGE_PANEL
      LogWriter("Current position is frozen and not be changed. Try later.", MESSAGE_TYPE_WARNING);
      SendEventChangedPos(POSITION_REFRESH);
      #endif
      delete ctask;
      taskLog.AddRedcode(TARGET_CREATE_TASK, TRADE_RETCODE_FROZEN);
      return HEDGE_ERR_POS_FROZEN;
   }
   taskLog.Clear();
   task2 = ctask;
   task2.Execute();
   //���������� ������ �� ����� ��������� �������� �����.
   for(int attemps = 0; attemps < 20; attemps++)
   {
      api.OnRefresh();
      
   }
   return HEDGE_ERR_NOT_ERROR;
}*/

///
/// ���������� ������� ������������� �������, ���� NULL, ����
/// ������� �����������.
///
Task2* Position::GetTask(void)
{
   if(CheckPointer(task2) == POINTER_INVALID)
      return NULL;
   return task2;
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
   //printf("Task Changed");
   if(CheckPointer(task2) == POINTER_INVALID ||task2.IsFinished())
   {
      task2 = NULL;
      //ResetBlocked();
      SendEventChangedPos(POSITION_REFRESH);
      #ifdef HEDGE_PANEL
         PrintTaskLog();
      #endif
   }
   //else if((task2.Status() == TASK_STATUS_EXECUTING) && !IsBlocked())
   //   SetBlock(TimeCurrent());
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
/// ��������� ������������ ���� ����-������.
///
bool Position::CheckValidTP(double tp)
{
   string info = "Bad TakeProfit Level. ";
   bool res = true;
   bool notChanges = false;
   bool isNull = false;
   if(Math::DoubleEquals(tp, 0.0))
      isNull = true;
   
   if(tp < CurrentPrice() && Direction() == DIRECTION_LONG && !isNull)
   {
      res = false;
      info = "Price of TakeProfit must be bigest current price.";
   }
   if(tp > CurrentPrice() && Direction() == DIRECTION_SHORT)
   {
      res = false;
      info = "Price of TakeProfit must be less current price";
   }
   if(tp < 0.0)
   {
      res = false;
      info = "Price of TakeProfit must be bigest or equal 0.0";
   }
   if(Math::DoubleEquals(tp, takeProfit))
   {
      res = false;
      notChanges = true;
   }
   if(!res && !notChanges)
      LogWriter(info, MESSAGE_TYPE_ERROR);
   return res || isNull;
}

///
/// ��������� �� ������������ ������� ����-�����.
///
bool Position::CheckValidSL(double sl)
{
   return true;
}
///
/// ��������� ���������� ������������ ����-����� ��� ������������ �������.
///
bool Position::CheckHistSL(double sl)
{
   if(status != POSITION_HISTORY)return false;
   bool eq = Math::DoubleEquals(sl, ExitExecutedPrice());
   if(Direction() == DIRECTION_LONG)
   {
      if(sl > ExitExecutedPrice())
         return false;
      else return true;
   }
   else
   {
      if(eq || sl > ExitExecutedPrice())
         return true;
      else return false;
   }
}

///
/// ��������� ���������� ������������ ����-������� ��� ������������ �������.
///
bool Position::CheckHistTP(double tp)
{
   if(status != POSITION_HISTORY)return false;
   bool eq = Math::DoubleEquals(tp, ExitExecutedPrice());
   if(Direction() == DIRECTION_LONG)
   {
      if(eq || tp > ExitExecutedPrice())
         return true;
      else return false;
   }
   else
   {
      if(tp > ExitExecutedPrice())
         return false;
      else return true;
   }
}

void Position::OnRefresh(void)
{
   if(!IsBlocked())
   {
      CloseByVirtualOrder();
      TralStopOrder.Trailing();
   }
   if(CheckPointer(activeXmlPos) == POINTER_INVALID &&
      api.IsInit() && !MQLInfoInteger(MQL_TESTER))
      activeXmlPos = new XmlPos2(GetPointer(this));
   if(CheckPointer(activeXmlPos) != POINTER_INVALID)
      activeXmlPos.LoadState();
   #ifdef HEDGE_PANEL
      positionLine.RefreshPrices();
   #endif
}

///
/// ��������� ������ ����������� ������� � ��������� �������, ���� ������� ������ �� ���.
/// ������������� ������� ����.
///
void Position::CloseByVirtualOrder(void)
{
   if(Math::DoubleEquals(takeProfit, 0.0))return;
   if(!AbilityTrade())return;
   if(Direction() == DIRECTION_LONG)
   {
      double cur_price = CurrentPrice();
      bool res = Math::DoubleEquals(takeProfit, cur_price) || takeProfit < cur_price;
      if(res)
         AddTask(new TaskClosePosition(GetPointer(this), MAGIC_TYPE_TP, true));
   }
   if(Direction() == DIRECTION_SHORT)
   {
      double cur_price = CurrentPrice();
      bool res = Math::DoubleEquals(takeProfit, cur_price) || takeProfit > cur_price;
      if(res)
         AddTask(new TaskClosePosition(GetPointer(this), MAGIC_TYPE_TP, true));
   }
}

///
/// ������� ������������ ���������� ���������� � ������� ������� � ������ ������������� ������.
/// \param seconds - ���������� ������, ����� ������� ����� ����� ��������� �������.
/// \return ������, ���� ������� �� �������� ��������� � ���� � ��������� ������.
///
bool Position::AbilityTrade(void)
{
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
      return false;
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
      return false;
   if(CheckPointer(task2)!=POINTER_INVALID && task2.IsActive())
      return false;
   if(taskLog.Total() > 0)
   {
      ENUM_TARGET_TYPE ttype;
      uint retcode;
      taskLog.GetRetcode(taskLog.Total()-1,  ttype, retcode);
      datetime fr = taskLog.FirstRecord();
      if(TimeCurrent() - fr < GetSecondsDelay(retcode))
         return false;
   }
   return true;
}
///
/// ���������� ����� �������� ������� ���������� ���������, ������ ���
/// ����� ����� �������� �������� ������� ��������� ����������. ����� ��������
/// ������� �� ���������� ���������� ��������� �������� � ����� ���� �� ���� �� 5 �����.
/// \param retcode - ��� ��������� ����������� ��������.
///
int Position::GetSecondsDelay(uint retcode)
{
   switch(retcode)
   {
      case TRADE_RETCODE_PLACED:
      case TRADE_RETCODE_DONE:
      case TRADE_RETCODE_DONE_PARTIAL:
         return 0;
      case TRADE_RETCODE_REQUOTE:
      case TRADE_RETCODE_PRICE_CHANGED:
      case TRADE_RETCODE_ORDER_CHANGED:
      case TRADE_RETCODE_TOO_MANY_REQUESTS:
         return 5;
      case TRADE_RETCODE_INVALID:
      case TRADE_RETCODE_TRADE_DISABLED:
      case TRADE_RETCODE_MARKET_CLOSED:
      case TRADE_RETCODE_INVALID_PRICE: 
         return 3600;
      default:
         return 300; 
   }
   return 0;
}

void Position::CopyTaskLog(TaskLog* task_log)
{
   taskLog.AddLogs(task_log);
}

void Position::PrintTaskLog(void)
{
   for(uint i = 0; i < taskLog.Total(); i++)
   {
      ENUM_TARGET_TYPE typeTarget;
      uint retcode;
      taskLog.GetRetcode(i, typeTarget, retcode);
      string strTarget = EnumToString(typeTarget);
      switch(retcode)
      {
         case 0:
         case TRADE_RETCODE_PLACED:
         case TRADE_RETCODE_DONE:
            continue;
         case TRADE_RETCODE_DONE_PARTIAL:
            printf("Warning. Task executed partial. Check volume.");
            continue;
         case TRADE_RETCODE_POSITION_CLOSED:
            printf(strTarget + ": Position closed or missing. Change is impossible.");
            continue;
         case TRADE_RETCODE_INVALID_STOPS:
            printf(strTarget + ": Missing stop order or imposible to change it.");
            continue;
         case TRADE_RETCODE_INVALID_VOLUME:
            printf(strTarget + ": Not correct volume. Volume must be bigger or equal 'SYMBOL_VOLUME_MIN' and less of current executed volume. Check it.");
            continue;
         default:
            printf("Erorr executing task: " + strTarget + " - " + (string)retcode);
            continue;
         
      }
      printf("Step " + (string)i + ": " + EnumToString(typeTarget) + " - " + (string)retcode);
   }
}

double Position::CurrentPrice(void)
{
   switch(status)
   {
      case POSITION_ACTIVE:
         return Transaction::CurrentPrice();
      case POSITION_NULL:
         return 0;
      case POSITION_HISTORY:
         return ExitExecutedPrice();
   }
   return 0.0;
}

double Position::Commission(void)
{
   if(status == POSITION_NULL)
      return 0.0;
   double commission = initOrder.Commission();
   if(status == POSITION_HISTORY)
      commission += closingOrder.Commission();
   return commission;
}
double Position::Slippage(void)
{
   if(status == POSITION_NULL)
      return 0.0;
   double slippage = initOrder.Slippage();
   if(status == POSITION_HISTORY)
      slippage += closingOrder.Slippage();
   return slippage;
}

bool Position::AttributesChanged(double tp, string exComment, datetime time)
{
   /*datetime btime = blockedTime.ToDatetime();
   string myComment = ExitComment();
   if(Math::DoubleEquals(tp, takeProfit) &&
      exComment == myComment && time == btime)
   {
      return false;
   }
   printf("Attributes changed #" + (string)GetId());*/
   TakeProfitLevel(tp, false);
   if(!UsingStopLoss())
      ExitComment(exComment, false);
   if(time > 0 && !IsBlocked())
      SetBlock(time, false);
   else if(time == 0 && IsBlocked())
      ResetBlocked(false);
   RefreshVisualForm(POSITION_REFRESH);
   return true;
}

/*bool Position::CheckChangesAttributes(double tp,string exComment,datetime time)
{
   if(exitComment == NULL)
      exitComment = "";
   if(exComment == NULL)
      exComment = "";
   if(!Math::DoubleEquals(tp, takeProfit))
   {
      printf("");
   }
}*/