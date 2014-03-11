#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Order.mqh"
#include "..\Events.mqh"
#include "..\XML\XmlInfo.mqh"
#include "..\XML\XmlPosition.mqh"
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
         SendTaskEvent(event);
         switch(event.EventId())
         {
            case EVENT_REFRESH:
               OnRefresh();
               xmlInfo.Event(event);
               break;
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
               break;
            case EVENT_XML_ACTPOS_REFRESH:
               OnXmlActPosRefresh(event);
               break;
         }
      }
      
      ///
      ///
      ///
      HedgeManager()
      {
         ActivePos = new CArrayObj();
         HistoryPos = new CArrayObj();
         ActivePos.Sort(SORT_ORDER_ID);
         HistoryPos.Sort(SORT_ORDER_ID);
         ticketOrders.Sort();
         long tick = GetTickCount();
         OnRefresh();
         isInit = true;
         #ifdef HEDGE_PANEL
         ShowPosition();
         #endif
         PrintPerfomanceParsing(tick);
      }
      
      ~HedgeManager()
      {
         int total = ActivePos.Total();
         ActivePos.Clear();
         delete ActivePos;
         HistoryPos.Clear();
         delete HistoryPos;
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
         TrackingHistoryDeals();
         TrackingHistoryOrders();
         TrackingPendingOrders();
      }
   private:
      ///
      /// ����������� ����������� ����� ������� � ������� �������.
      ///
      void TrackingHistoryDeals()
      {
         int total = HistoryDealsTotal();
         //���������� ��� ��������� ������ � ��������� �� �� ������ ��������� ������� ������� ���� COrder
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
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
         }
      }
      
      ///
      /// ����������� ����������� ����� ���������� �������� �������.
      ///
      void TrackingPendingOrders()
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
         }
         ordersPendingNow = OrdersTotal();
      }
      
      ///
      /// ���������� ����������� ���������� ����� �������� �������, ������� �� �����������.
      /// \return ������, ���� ����������� ����� ��� ��������� ������� � ����, ���� ���������������
      /// ������� �� ������� � ����� �� ��� ���������.
      ///
      bool SendPendingOrder(Order* order)
      {
         Position* ActPos = FindActivePosById(order.PositionId());
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
         ActPos = FindActivePosById(order.PositionId());
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
            Position* ActPos = FindActivePosById(order.PositionId());
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
            Position* ActPos = FindActivePosById(order.PositionId());
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
      /// ���������� ��� ��������� xml �������.
      ///
      void OnXmlActPosRefresh(EventXmlActPosRefresh* event)
      {
         XmlPosition* xPos = event.GetXmlPosition();
         ulong login = AccountInfoInteger(ACCOUNT_LOGIN);
         if(login != xPos.AccountId())return;
         TransId* trans = new TransId(xPos.Id());
         int index = ActivePos.Search(trans);
         delete trans;
         if(index == -1)
         {
            //SendEventDelXmlPos(xPos);
            return;
         }
         Position* pos = ActivePos.At(index);
         pos.Event(event);
         //printf("�������� XML ������� ����������. ExitComment=" + xPos.ExitComment());
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
      /// ���������� ����� ����� ������������� � ���������� �������� ������.
      ///
      #ifdef HEDGE_PANEL
      void ShowPosition()
      {
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            pos.SendEventChangedPos(POSITION_SHOW);
         }
         for(int i = 0; i < HistoryPos.Total(); i++)
         {
            Position* pos = HistoryPos.At(i);
            pos.SendEventChangedPos(POSITION_SHOW);
         }
      }
      #endif
      
      ///
      /// ����������� ����� ������ � ������� �������.
      ///
      void AddNewDeal(ulong ticket)
      {
         Deal* deal = new Deal(ticket);
         if(deal.Status() == DEAL_BROKERAGE)
         {
            delete deal;
            return;
         }
         Order* order = new Order(deal);
         if(order.Status() == ORDER_NULL)
         {
            delete order;
            return;
         }
         EventOrderExe* event = new EventOrderExe(order);
         SendTaskEvent(event);
         delete event;
         ulong magic = order.Magic();
         ulong oid = order.GetId();
         Position* actPos = FindActivePosById(order.PositionId());
         if(actPos == NULL)
            actPos = new Position();
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
            else if(isInit)
               actPos.SendEventChangedPos(POSITION_REFRESH);
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
      
      ///
      /// ������� �������� ������� � ������ �������� �������, ���
      /// id ����� posId.
      ///
      Position* FindActivePosById(ulong posId)
      {
         if(posId != 0)
         {
            Order* inOrder = new Order(posId);
            int iActive = ActivePos.Search(inOrder);
            delete inOrder;
            if(iActive != -1)
               return ActivePos.At(iActive);
         }
         return NULL;
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
      /// For API: ���������� ���������� �������� �������
      ///
      int ActivePosTotal()
      {
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
      /// �������� ����������� ������� ������� ������� �� ������ �������.
      ///
      void SendTaskEvent(Event* event)
      {
         for(int i = 0; i < tasks.Total(); i++)
         {
            Task2* task = tasks.At(i);
            if(task.IsFinished())
            {
               tasks.Delete(i);
               i--;
               continue;
            }
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
         string line = "We are begin. Parsing of history deals (" + (string)dTotal +
         ") and orders (2x" + (string)oTotal + ") completed for " + seconds + " sec.";
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
      /// ������ xml ������.
      ///
      XmlInfo xmlInfo;
};