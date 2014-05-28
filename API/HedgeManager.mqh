#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Order.mqh"
#include "..\Events.mqh"
#include "..\XML\XmlGarbage.mqh"
#include "..\Resources\Resources.mqh"
#include "..\Math.mqh"
#include "H.mqh"

///
/// ����� �������
///
class HedgeManager
{
   public:
      ///
      /// � ������ ������ � ������ ���������� ���������� ������.
      ///
      void Event(Event* event)
      {
         
         switch(event.EventId())
         {
            case EVENT_REFRESH:
               OnRefresh();
               break;
            case EVENT_REQUEST_NOTICE:
               SendTaskEvent(event);
               OnRequestNotice(event);
               break;
         }
      }
      
      ///
      /// 
      ///
      HedgeManager()
      {
         callBack = GetPointer(this);
         bool isTester = MQLInfoInteger(MQL_TESTER);
         if(!isTester && Resources.Failed())
         {
            LogWriter("Install files to continue.", MESSAGE_TYPE_ERROR);
            ExpertRemove();
            return;
         }
         ActivePos = new CArrayObj();
         HistoryPos = new CArrayObj();
         ActivePos.Sort(SORT_ORDER_ID);
         HistoryPos.Sort(SORT_ORDER_ID);
         ticketOrders.Sort();
         listPendingOrders.Sort();
         long tick = GetTickCount();
         OnRefresh();
         if(!isTester)
         {
            XmlGarbage* xmlGarbage = new XmlGarbage();
            xmlGarbage.ClearActivePos(Resources.GetFileNameByType(RES_ACTIVE_POS_XML), ActivePos);
            delete xmlGarbage;
            Resources.WizardInstallExclude(GetPointer(this));
            RemoveExclude();
            ShowPosition();
         }
         isInit = true;
         PrintPerfomanceParsing(tick);
         //TestHashValues();
      }
      
      void TestHashValues()
      {
         Hash hashing;
         hashing.TimeHashing(true);
         Random rnd;
         /*for(int i = 0; i < 10; i++)
         {
            ulong value = rnd.Rand(0, 127);
            string str = (string)(value);
            hashing.SetHighestBit(value);
            str += " - " + (string)(value);
            hashing.ResetHighestBit(value);
            str += " - " + (string)(value);
            printf(str);
         }
         ulong key = rnd.Rand();
         for(int i = 0; i < 10; i++)
         {
            rnd.Seed(key);
            ulong value = rnd.Rand();
            printf((string)value);
         }*/
         /*int i = HistoryOrdersTotal()-20;
         if(i < 0)i=0;
         for(i = 0; i < HistoryOrdersTotal(); i++)
         {
            ulong ticket = HistoryOrderGetTicket(i);
            Order *order = new Order(ticket);
            ulong hash = hashing.GetHash(order, ticket, HASH_FROM_VALUE);
            ulong value = hashing.GetHash(order, hash, VALUE_FROM_HASH);
            printf((string)ticket + " - " +(string)hash + " - " + (string)value);
            int dbg = 3;
            delete order;
         }*/
         uint total = UINT_MAX; 
         //total = 1000000;
         int m = 42949673;
         Order* order = new Order();
         //printf("test");
         //printf("Complete " + (string)(1) + " per");
         //printf("Complete " + (string)(1) + "per");
         //printf("Complete " + (string)(1) + "%");
         //printf("Warning! Value " + (string)value + " != " + (string)ticket);
         int bad = 0;
         for(uint i = 0; i < total; i++)
         {
            ulong ticket = 1009045932 + i;
            ulong tiks = (TimeCurrent()*1000) + rnd.Rand(0, 1000);
            order.TimeSetupTemp(tiks);
            order.SetIdTemp(ticket);
            ulong hash = hashing.GetHash(order, ticket, HASH_FROM_VALUE);
            ulong value = hashing.GetHash(order, hash, VALUE_FROM_HASH);
            if(value != ticket)
            {
               printf("Warning! Value " + (string)value + " != " + (string)ticket);
               bad++;
            }
            if(i%m == 0 && i > 0)
               printf("Complete " + (string)(i/m) + " percent.");
         }
         printf("Complete. Bad converters " + (string)bad);
         delete order;
         ExpertRemove();
      }
      
      ~HedgeManager()
      {
         if(CheckPointer(ActivePos))
         {
            ActivePos.Clear();
            delete ActivePos;
         }
         if(CheckPointer(HistoryPos))
         {
            HistoryPos.Clear();
            delete HistoryPos;
         }
         
         tasks.Shutdown();
      }
      
      ///
      /// ��������� ������ � ������ �����.
      ///
      void AddTask(Task2* task)
      {
         tasks.Add(task);
      }
      
      ///
      /// ������ �� ������������ ����� ������� � �������.
      ///
      void OnRefresh()
      {
         HistorySelect(timeBegin, TimeCurrent());
         if(IsInit())
         {
            EventRefresh* refresh = new EventRefresh(EVENT_FROM_UP, "Hedge Terminal");
            SendTaskEvent(refresh);
            delete refresh;
         }
         TrackingHistoryDeals();
         TrackingHistoryOrders();
         TrackingPendingOrders();
         RefreshActPos();
         RefreshPanel();
      }
      ///
      /// ������ ����������� ���������� ������.
      ///
      void RefreshPanel()
      {
         #ifdef HEDGE_PANEL
            if(!graphRebuild)return;
            graphRebuild = false;
            EventRefreshPanel* refresh = new EventRefreshPanel();
            HedgePanel.Event(refresh);
            delete refresh;
         #endif
      }
      
      ///
      /// ������, ���� HedgeManager �������� � ������ ��������� ������� �
      /// ����, ���� ���������� ������� ������������� �������.
      ///
      bool IsInit(){return isInit;}
      
      ///
      /// For API: ���������� ���������� �������� �������
      ///
      int ActivePosTotal()
      {
         //printf("API pos total " + ActivePos.Total());
         return ActivePos.Total();
      }
      ///
      /// For API: ���������� ���������� ������������ �������.
      ///
      int HistoryPosTotal()
      {
         return HistoryPos.Total();
      }
      ///
      /// For API: ���������� �������� ������� ��� ������� n �� ������ �������.
      ///
      Position* ActivePosAt(int n)
      {
         Position* pos = ActivePos.At(n);
         return pos;
      }
      ///
      /// For API: ���������� ������������ ������� ��� ������� n �� ������ �������.
      ///
      Position* HistoryPosAt(int n)
      {
         Position* pos = HistoryPos.At(n);
         return pos;
      }
      
      
      ///
      /// ������� �������� ������� � ������ �������� �������, ���
      /// id ����� posId.
      ///
      Position* FindActivePosByOrder(Order* order)
      {
         ulong posId = order.PositionId();
         if(posId != 0)
         {
            Order* inOrder = new Order(posId);
            int iActive = ActivePos.Search(inOrder);
            delete inOrder;
            if(iActive != -1)
               return ActivePos.At(iActive);
         }
         //�������� �������� ������� ���������� � ��������������� ������� ������
         else
         {
            int iActive = ActivePos.Search(order);
            if(iActive != -1)
               return ActivePos.At(iActive);
         }
         return NULL;
      }

   private:
      
      ///
      /// �������� ����������� � ��������� ������ �������� �������.
      ///
      void RefreshActPos()
      {
         if(!isInit)return;
         EventRefresh* event = new EventRefresh(EVENT_FROM_UP, "TERMINAL API");
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            pos.Event(event);
         }
         delete event;
      }
      ///
      /// ����������� ����������� ����� ������� � ������� �������.
      ///
      void TrackingHistoryDeals()
      {
         int total = HistoryDealsTotal();
         //���������� ��� ��������� ������ � ��������� �� �� ������ ��������� ������� ������� ���� COrder
         for(; dealsCountNow < HistoryDealsTotal(); dealsCountNow++)
         {  
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
            graphRebuild = true;
         }
      }
      
      ///
      /// ����������� ����������� ����� ������������ �������.
      ///
      void TrackingHistoryOrders()
      {
         for(; historyOrdersCount < HistoryOrdersTotal(); historyOrdersCount++)
         {
            Order* order = CreateCancelOrderOrNull(historyOrdersCount);
            if(order == NULL)continue;
            bool isIntegrate = SendCancelStopAndProfitOrder(order);
            EventOrderCancel* cancelOrder = new EventOrderCancel(order);
            SendTaskEvent(cancelOrder);
            delete cancelOrder;
            if(!isIntegrate)
               delete order;
            graphRebuild = true;
         }
      }
      
      ///
      /// ����������� ����������� ����� ���������� �������� �������.
      ///
      void TrackingPendingOrders2()
      {
         int total = OrdersTotal();
         if(ordersPendingNow > total)
            ordersPendingNow = total;
         for(; ordersPendingNow < total; ordersPendingNow++)
         {
            ulong ticket = OrderGetTicket(ordersPendingNow);
            
            if(!OrderSelect(ticket))continue;
            Order* order = new Order(ticket);
            bool isIntegrate = SendPendingOrder(order);
            EventOrderPending* pendingOrder = new EventOrderPending(order);
            SendTaskEvent(pendingOrder);
            delete pendingOrder;
            if(!isIntegrate)
               delete order;
            graphRebuild = true;
         }
         ordersPendingNow = OrdersTotal();
      }
      
      void TrackingPendingOrders()
      {
         for(int i = 0; i < OrdersTotal(); i++)
         {
            ulong ticket = OrderGetTicket(i);
            if(!IsNewOrder(ticket))continue;
            if(!OrderSelect(ticket))continue;
            Order* order = new Order(ticket);
            bool isIntegrate = SendPendingOrder(order);
            EventOrderPending* pendingOrder = new EventOrderPending(order);
            SendTaskEvent(pendingOrder);
            delete pendingOrder;
            if(!isIntegrate)
               delete order;
            graphRebuild = true;
         }
      }
      ///
      /// ������, ���� ���������� ����� � ������� ������� �������� �����, ����������� �������,
      /// � ���� � ��������� ������. 
      ///
      bool IsNewOrder(ulong ticket)
      {
         int index = listPendingOrders.Search(ticket);
         if(index == -1)
            listPendingOrders.InsertSort(ticket);
         return index == -1;
      }
      ///
      /// ���������� ����������� ���������� ����� �������� �������, ������� �� �����������.
      /// \return ������, ���� ����������� ����� ��� ��������� ������� � ����, ���� ���������������
      /// ������� �� ������� � ����� �� ��� ���������.
      ///
      bool SendPendingOrder(Order* order)
      {
         Position* ActPos = FindActivePosByOrder(order);
         if(ActPos == NULL)return false;
         if(order.IsStopLoss() || order.IsTakeProfit())
         {
            InfoIntegration* info = ActPos.Integrate(order);
            bool res = info.IsSuccess;
            delete info;
            return res;
         }
         return false;
      }
      
      ///
      /// ������� ���������� �����, ���������� ������������ ������� �������.
      ///
      Order* CreateCancelOrderOrNull(int index)
      {
         ulong ticket;
         if(!isInit)
            ticket = HistoryOrderGetTicket(index);
         else
            ticket = FindAddTicket();
         int dbg = 5;
         if(ticket == 1009658190)
            dbg = 4;
         if(ticket == 0)return NULL;
         ticketOrders.InsertSort(ticket);
         ENUM_ORDER_STATE state = (ENUM_ORDER_STATE)HistoryOrderGetInteger(ticket, ORDER_STATE);
         if(state != ORDER_STATE_CANCELED)return NULL;
         Order* createOrder = new Order(ticket);
         return createOrder;
      }
      ///
      /// ���������� ���������� ���� � ������ ������ ��������, ������� ���
      /// �����������.
      /// \return ������, ���� ����� ��� ������������ � ��������������� ������� � ����
      /// � ��������� ������.
      ///
      bool SendCancelStopAndProfitOrder(Order* order)
      {
         if(!order.IsStopLoss() && !order.IsTakeProfit())return false;
         //��������� ���� � �������� ������� �� ��������.
         //���������� ���� � ������������ ������� ���� ���������.
         Position* ActPos;
         ActPos = FindActivePosByOrder(order);
         if(ActPos != NULL)
         {
            InfoIntegration* info = ActPos.Integrate(order);
            bool res = info.IsSuccess;
            delete info;
            return res;
         }
         ActPos = FindHistPosById(order.PositionId());
         if(ActPos != NULL)
         {
            InfoIntegration* info = ActPos.Integrate(order);
            bool res = info.IsSuccess;
            delete info;
            return res;
         }
         return false;
      }
      ///
      /// ������� ����� ������, ������� ��� �������� � ������� �������.
      ///
      ulong FindAddTicket()
      {
         ulong ticket;
         //������� ������ - ���� ������� ������ ������.
         if(addOrderTicket != 0 && !ContainsHistTicket(addOrderTicket))
         {
            ticket = addOrderTicket;
            addOrderTicket = 0;
         }
         //��������� ������ - ���� ������� �� ������ ��� �����������.
         else
            ticket = FindTicketInHistory();
         return ticket;
      }
      
      ///
      /// ���������� ��� ������ � �������, � ���������� ������ ����� � �����, ������� ��� �� ���
      /// ������ � ������ ������������ �������.
      ///
      ulong FindTicketInHistory()
      {
         int total = HistoryOrdersTotal();
         for(int i = 0; i < total; i++)
         {
            ulong ticket = HistoryOrderGetTicket(i);
            if(!ContainsHistTicket(ticket))
               return ticket;
         }
         return 0;
      }
      
      ///
      /// �������������� �������� ������� �� ���������� �������� �������,
      /// � ������� ��� ���������.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeTransaction* trans = event.GetTransaction();
         //�������� ����� �������.
         if(trans.IsRequest())
         {
            TradeRequest* request = event.GetRequest();
            Order* order = new Order(request);
            Position* ActPos = FindActivePosByOrder(order);
            delete order;
            if(ActPos != NULL)
               ActPos.Event(event);
         }
         //���������� ����� ���������? - �������� �� ������ � ��������.
         if(trans.IsUpdate() || trans.IsDelete())
         {
            /*if(!OrderSelect(trans.order))
               return;*/
            Order* order = new Order(trans.order);
            Position* ActPos = FindActivePosByOrder(order);
            delete order;
            if(ActPos != NULL)
               ActPos.Event(event);
         }
         //
         if(trans.type == TRADE_TRANSACTION_HISTORY_ADD)
         {
            addOrderTicket = trans.order;
         }
      }
      
      ///
      /// ������, ���� ������ ticketOrders �������� ����� � ������ �������������.
      /// ���� � ��������� ������.
      ///
      bool ContainsHistTicket(ulong ticket)
      {
         int index = ticketOrders.Search(ticket);
         if(index == -1)
            return false;
         return true;
      }
      
      ///
      /// ���������� ������, ���� ������ ������ ��������� �� ��, ��� �� ���������
      /// � �������� �����������.
      ///
      bool IsOrderModify(ENUM_ORDER_STATE state)
      {
         switch(state)
         {
            case ORDER_STATE_STARTED:
            case ORDER_STATE_REQUEST_ADD:
            case ORDER_STATE_REQUEST_CANCEL:
            case ORDER_STATE_REQUEST_MODIFY:
               return true;
            default:
               return false;
         }
         return false;
      }
      ///
      /// ���������� ����� ����� ������������� � ���������� �������� ������, � �����
      /// �������������� �� ������ �� XML ���� �������� �������.
      ///
      void ShowPosition()
      {
         #ifdef HEDGE_PANEL
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            pos.SendEventChangedPos(POSITION_SHOW);
            pos.CreateXmlLink();
         }
         CreateSummary(TABLE_POSACTIVE);
         for(int i = 0; i < HistoryPos.Total(); i++)
         {
            Position* pos = HistoryPos.At(i);
            pos.SendEventChangedPos(POSITION_SHOW);
         }
         CreateSummary(TABLE_POSHISTORY);
         #endif
      }
      ///
      /// ������� �� ������ �������� ������� ������� �������.
      ///
      void RemoveExclude()
      {
         CArrayLong* excludeOrders = Settings.GetExcludeOrders();
         if(excludeOrders == NULL)return;
         /*for(int i = 0; i < excludeOrders.Total(); i++)
            printf((string)excludeOrders.At(i));
         printf(">>>>>>>>>>>>");
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            printf((string)pos.GetId());
         }*/
         for(int i = ActivePos.Total()-1; i >= 0; i--)
         {
            Position* pos = ActivePos.At(i);
            ulong id = pos.GetId();
            int index = excludeOrders.Search(pos.GetId());
            if(index != -1)
               ActivePos.Delete(index);
         }
      }
      
      void CreateSummary(ENUM_TABLE_TYPE tType)
      {
         #ifdef HEDGE_PANEL
            if(CheckPointer(HedgePanel) != POINTER_INVALID)
            {
               EventCreateSummary* event = new EventCreateSummary(tType);
               HedgePanel.Event(event);
               delete event;
            }
         #endif
      }
      ///
      /// ����������� ����� ������ � ������� �������.
      ///
      void AddNewDeal(ulong ticket)
      {
         //printf("Add new ticket: " + (string)ticket);
         Deal* deal = new Deal(ticket);
         if(deal.Status() == DEAL_BROKERAGE)
         {
            delete deal;
            return;
         }
         Order* order = new Order(deal);
         //printf("Order #" + (string)order.GetId() + " " + EnumToString(order.Status()) + " ; Time: " + TimeToString(order.TimeSetup()/1000, TIME_DATE|TIME_MINUTES|TIME_SECONDS));
         if(order.Status() == ORDER_NULL)
         {
            printf("Order is null");
            delete order;
            return;
         }
         EventOrderExe* event = new EventOrderExe(order);
         SendTaskEvent(event);
         delete event;
         ulong magic = order.Magic();
         ulong oid = order.GetId();
         int dbg = 3;
         if(ticket == 1117343)
            dbg = 2;
         Position* actPos = FindActivePosByOrder(order);
         if(actPos == NULL)
            actPos = new Position();
         if(ticket == 1117343)
            TestPos(actPos);
         InfoIntegration* result = actPos.Integrate(order);
         int iActive = ActivePos.Search(actPos);
         if(actPos.Status() == POSITION_NULL)
         {
            if(isInit)
               actPos.SendEventChangedPos(POSITION_HIDE);
            if(iActive != -1)
               ActivePos.Delete(iActive);
            else
               delete actPos;
         }
         else
         {
            if(iActive == -1)
            {
               if(isInit)
                  actPos.SendEventChangedPos(POSITION_SHOW);
               ActivePos.InsertSort(actPos);
            }
            else
            { 
               Position* oldPos = ActivePos.At(iActive);
               if(CheckPointer(oldPos) != CheckPointer(actPos))
               {
                  InfoIntegration* nres = oldPos.Integrate(actPos.EntryOrder());
                  delete actPos;
                  delete nres;
               }
               if(isInit)
                  oldPos.SendEventChangedPos(POSITION_REFRESH);
               //return;
            }
         }
         //����� ������� ������ ��� �������, ����� ������� - �������� �������.
         if(result.ActivePosition != NULL &&
            result.ActivePosition.Status() == POSITION_ACTIVE)
         {
            ActivePos.InsertSort(result.ActivePosition);
            if(isInit)
               result.ActivePosition.SendEventChangedPos(POSITION_SHOW);
         }
         if(result.HistoryPosition != NULL &&
            result.HistoryPosition.Status() == POSITION_HISTORY)
            IntegrateHistoryPos(result.HistoryPosition);
         delete result;
      }
      
      void TestPos(Position* pos)
      {
         Order* order = pos.EntryOrder();
         int dtotal = order.DealsTotal();
         double vol_exe = pos.VolumeExecuted();
         printf("Pos #" + (string)pos.GetId() + "; Deals: " +
         (string)dtotal + "; Vol total: " + DoubleToString(vol_exe, 0));
      }
      
      ///
      /// ������� ������������ ������� � ������ �������� �������, ���
      /// id ����� posId.
      ///
      Position* FindHistPosById(ulong posId)
      {
         if(posId != 0)
         {
            Order* inOrder = new Order(posId);
            int iActive = HistoryPos.SearchLast(inOrder);
            delete inOrder;
            if(iActive != -1)
               return HistoryPos.At(iActive);
         }
         return NULL;
      }
      
      ///
      /// ������ � ������ ������������ ������� ����� ������������ �������.
      ///
      void IntegrateHistoryPos(Position* histPos)
      {
         bool isMerge = false;
         int iHist = HistoryPos.SearchLast(histPos);
         if(iHist != -1)
         {
            Position* pos = HistoryPos.At(iHist);
            if(pos.ExitOrderId() == histPos.ExitOrderId())
            {
               pos.Merge(histPos);
               delete histPos;
               isMerge = true;
            }
         }
         if(!isMerge)
            HistoryPos.InsertSort(histPos);
         if(isInit)
            histPos.SendEventChangedPos(POSITION_SHOW);         
      }
      
      
      ///
      /// �������� ����������� ������� ������� ������� �� ������ �������.
      ///
      void SendTaskEvent(Event* event)
      {
         for(int i = tasks.Total() - 1; i >= 0;i--)
         {
            CObject* obj = tasks.At(i);
            if(CheckPointer(obj) == POINTER_INVALID)
            {
               tasks.Delete(i);
               continue;
            }
            Task2* task = obj;
            if(task.IsFinished())
               tasks.Delete(i);
            else
               task.Event(event);
         }
         
      }
   
      ///
      /// ���������� ������ ��������������� �������, ����������� �� ������ ������ orderId.
      ///
      CArrayLong* FindDealsIdByOrderId(ulong orderId)
      {
         CArrayLong* trades = new CArrayLong();
         LoadHistory();
         int total = HistoryDealsTotal();
         for(int i = 0; i < total; i++)
         {
            ulong ticket = HistoryDealGetTicket(i);
            ulong currOrderId = HistoryDealGetInteger(ticket, DEAL_ORDER);
            if(currOrderId == orderId)
               trades.Add(currOrderId);
         }
         return trades;
      }
      
      ///
      /// ��������� ������� �������, ���� ��� �� ���������.
      ///
      void LoadHistory(void)
      {
         if(HistoryDealsTotal() < 2)
            HistorySelect(0, TimeCurrent());
      }
      ///
      /// ������� ������ ������������� ������������������ ��������.
      ///
      void PrintPerfomanceParsing(long tick_begin)
      {
         long delta =  GetTickCount() - tick_begin;
         double sec = delta/1000.0;
         int isec = (int)MathFloor(sec);
         int rest = (int)delta%1000;
         string srest = "";
         if(rest < 100)
            srest += "0";
         if(rest < 10)
            srest += "00";
         srest += (string)rest;
         int dTotal = HistoryDealsTotal();
         int oTotal = HistoryOrdersTotal();
         string seconds = (string)isec + "." + srest;
         int ram = MQLInfoInteger(MQL_MEMORY_USED);
         string line = "We are begin. Parsing of history deals (" + (string)dTotal +
         ") and orders (" + (string)oTotal + ") completed for " + seconds + " sec. " + (string)ram + "MB RAM used.";
         printf(line);
      }
      ///
      /// ������ �������� �������.
      ///
      CArrayObj* ActivePos;
      ///
      /// ������ ������������, �������� �������.
      ///
      CArrayObj* HistoryPos;
      ///
      /// ���������� ������, ������� ��������� � ������� ��������� �������.
      ///
      int dealsCountNow;
      ///
      /// ������� ���������� ������������ �������� �������.
      ///
      int ordersCountNow;
      ///
      /// ������� ���������� ���������� �������.
      ///
      int ordersPendingNow;
      ///
      /// ������, ���� ��������� ������������� ������.
      ///
      bool recalcModify;
      ///
      /// �����, � �������� ���������� �������� ��������.
      ///
      datetime timeBegin;      
      ///
      /// ������, ���� �������� ������������ �������.
      ///
      bool tracking;
      ///
      /// ���������� ������������ �������.
      ///
      int historyOrdersCount;
      ///
      /// ������, ���� ������������� ��������� � ����������� ������� ������ � ����� ��������� �������.
      ///
      bool isInit;
      ///
      /// ������������������ ������ ������� ����������� �������.
      ///
      CArrayLong ticketOrders;
      ///
      /// ����� ������������ � ������� ������, ������� ���������� ����� ������������ �������.
      ///
      ulong addOrderTicket;
      ///
      /// ������ �������.
      ///
      CArrayObj tasks;
      ///
      /// ������, ���� ��������� ������� ����������� � ����������� ������� � HedgePanel.
      ///
      bool graphRebuild;
      ///
      /// ������ ����������� ��������� �������.
      ///
      CArrayLong listPendingOrders;
};
///
/// ��������� ��������� ������.
///
HedgeManager* callBack;