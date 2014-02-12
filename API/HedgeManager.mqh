#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Order.mqh"
#include "..\Events.mqh"
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
         ENUM_EVENT enEvent = event.EventId();
         switch(event.EventId())
         {
            case EVENT_REFRESH:
               OnRefresh();
               break;
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
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
         long tick = GetTickCount();
         OnRefresh();
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
      /// ���������� ������������� ������� ������� ����� ������������ ���������� � ���������� ������� magic_id.
      /// ���������� ������� ����� �� ������������.
      ///
      /*static ulong CanPositionId(ulong magic_id)
      {
         return magic_id;
      }*/
      
      ///
      /// �������������� �������� ������� �� ���������� �������� �������,
      /// � ������� ��� ���������.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeTransaction* trans = event.GetTransaction();
         //�������� ����� �������.
         if(trans.type == TRADE_TRANSACTION_REQUEST)
         {
            TradeRequest* request = event.GetRequest();
            Order* order = new Order(request);
            Position* ActPos = FindActivePosById(order.PositionId());
            delete order;
            if(ActPos != NULL)
               ActPos.Event(event);
         }
         //���������� ����� ���������? - �������� �� ������ � ��������.
         if(trans.type == TRADE_TRANSACTION_ORDER_UPDATE)
         {
            if(!OrderSelect(trans.order))
               return;
            Order* order = new Order(trans.order);
            Position* ActPos = FindActivePosById(order.PositionId());
            delete order;
            if(ActPos != NULL)
               ActPos.Event(event);
         }
      }
      ///
      /// ������ �� ������������ ����� ������� � �������.
      ///
      void OnRefresh()
      {
         //LoadHistory();
         datetime t_now = TimeCurrent();
         HistorySelect(timeBegin, t_now);
         //TODO.
         //timeBegin = t_now;
         int total = HistoryDealsTotal();
         //���������� ��� ��������� ������ � ��������� �� �� ������ ��������� ������� ������� ���� COrder
         int dbg = 5;
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            if(dealsCountNow == 63)
               dbg = 6;
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
         }
         TrackingPendingCancel();
         CheckModifyOrders();
         CollectNewSLAndTPOrders();
      }
      
      ///
      /// ����������� ���������� ������.
      ///
      void TrackingPendingCancel()
      {
         //��� ������ ������ ���������� ������ �� �����������,
         //�.�. ������ ����� ��� ������ �������.
         /*if(!tracking)
         {
            tracking = true;
            historyOrdersCount = HistoryOrdersTotal();
            return;
         }*/
         for(; historyOrdersCount < HistoryOrdersTotal(); historyOrdersCount++)
         {
            ulong ticket = HistoryOrderGetTicket(historyOrdersCount);
            ENUM_ORDER_STATE state = (ENUM_ORDER_STATE)HistoryOrderGetInteger(ticket, ORDER_STATE);
            if(state != ORDER_STATE_CANCELED)
               continue;
            Order* order = new Order(ticket);
            //��� ������� ����-���� ��� ���� ������?
            if(order.IsStopLoss() || order.IsTakeProfit())
            {
               ENUM_ORDER_STATUS st = order.Status();
               Position* ActPos = FindActivePosById(order.PositionId());
               if(ActPos == NULL)
               {
                  delete order;
                  continue;
               }
               InfoIntegration* ii = ActPos.Integrate(order);
               
            }
            delete order;
         }
      }
      
      void CollectNewSLAndTPOrders()
      {
         if(ordersPendingNow != OrdersTotal() || recalcModify)
         {
            ordersPendingNow = 0;
            for(; ordersPendingNow < OrdersTotal(); ordersPendingNow++)
            {
               ulong ticket = OrderGetTicket(ordersPendingNow);
               OrderSelect(ticket);
               ENUM_ORDER_STATE state = (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE);
               /*if(IsOrderModify(state))
               {
                  recalcModify = true;
                  continue;
               }*/
               Order* order = new Order(ticket);
               Position* ActPos = FindActivePosById(order.PositionId());
               if(ActPos == NULL)
               {
                  delete order;
                  continue;
               }
               if(order.IsStopLoss() || order.IsTakeProfit())
                  ActPos.Integrate(order);
               else
                  delete order;
            }
            ordersPendingNow = OrdersTotal();
         }
      }
      ///
      /// ������� ����� �������� ������� ���������� ���� ������ �
      /// ���������� �� ���� �������, � ������� ��� ����� ������������.
      ///
      void CheckModifyOrders()
      {
         if(ordersCountNow != OrdersTotal())
         {
            ordersCountNow = 0;
            for(; ordersCountNow < OrdersTotal(); ordersCountNow++)
            {
               ulong ticket = OrderGetTicket(ordersCountNow);
               OrderSelect(ticket);
               ENUM_ORDER_STATE state = (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE);
               if(!IsOrderModify(state))continue;
               Order* order = new Order(ticket);
               Position* ActPos = FindActivePosById(order.PositionId());
               delete order;
               if(ActPos == NULL)continue;
               ActPos.NoticeModify();
            }
            ordersCountNow = OrdersTotal();
         }
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
         ulong magic = order.Magic();
         ulong oid = order.GetId();
         Position* actPos = FindActivePosById(order.PositionId());
         if(actPos == NULL)
            actPos = new Position();
         InfoIntegration* result = actPos.Integrate(order);
         int iActive = ActivePos.Search(actPos);
         if(actPos.Status() == POSITION_NULL)
         {
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
               actPos.SendEventChangedPos(POSITION_SHOW);   
               ActivePos.InsertSort(actPos);
            }
            else
               actPos.SendEventChangedPos(POSITION_REFRESH);
         }
         //printf(ticket);
         //����� ������� ������ ��� �������, ����� ������� - �������� �������.
         if(result.ActivePosition != NULL &&
            result.ActivePosition.Status() == POSITION_ACTIVE)
         {
            ActivePos.InsertSort(result.ActivePosition);
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
      /// ������ � ������ ������������ ������� ����� ������������ �������.
      ///
      void IntegrateHistoryPos(Position* histPos)
      {
         bool isMerge = false;
         int iHist = HistoryPos.Search(histPos);
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
         {
            HistoryPos.InsertSort(histPos);
            histPos.SendEventChangedPos(POSITION_SHOW);
         }
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
      
      
   private:
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
         ") and orders (" + (string)oTotal + ") completed for " + seconds + " sec.";
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
};