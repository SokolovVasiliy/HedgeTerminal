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
         OnRefresh();
         printf("Recalc position complete.");
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
      /// ���������� ������������� �������, ������� ����������� ����� ��� ������ � magic_id
      ///
      static ulong PositionId(ulong magic_id)
      {
         Order* order = new Order(magic_id);
         ulong posId = 0;
         int index = ActivePos.Search(order);
         if(index > -1)
         {
            Position* actPos = ActivePos.At(index);
            posId = actPos.GetId();
         }
         index = HistoryPos.Search(order);
         if(index > -1)
         {
            Position* histPos = HistoryPos.At(index);
            posId = histPos.GetId();
         }
         delete order;
         return posId;
      }
      ///
      /// ���������� ������������� ������� ������� ����� ������������ ���������� � ���������� ������� magic_id.
      /// ���������� ������� ����� �� ������������.
      ///
      static ulong CanPositionId(ulong magic_id)
      {
         return magic_id;
      }
      ///
      /// ������������ ����������� ����� �������.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeResult* result = event.GetResult();
         //������� ���� � �������, � ������� ��������� ����������� ������.
         if(result.IsRejected())
         {
            TradeRequest* request = event.GetRequest();
            //Order* order = new Order(request.magic);
            //FindOrCreateActivePosForOrder(
         }
      }
      ///
      /// ������ �� ������������ ����� ������� � �������.
      ///
      void OnRefresh()
      {
         //LoadHistory();
         HistorySelect(0, TimeCurrent());
         int total = HistoryDealsTotal();
         //int total = 5;
         //���������� ��� ��������� ������ � ��������� �� �� ������ ��������� ������� ������� ���� COrder
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            //LoadHistory();
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
         }
         //������ status_blocked.
         total = OrdersTotal();
         //���� �����-���� �� �������� ������� ������������ � �������,
         //�� ����� �������� ���������� ����������� �������� �������.
         if(ordersCountNow > total)
            ordersCountNow = total;
         for(; ordersCountNow < total; ordersCountNow++)
         {
            ulong ticket = OrderGetTicket(ordersCountNow);
            OrderSelect(ticket);
            ProcessingOrder(ticket);
         }
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
         Position* actPos = FindOrCreateActivePosForOrder(order);
         InfoIntegration* result = actPos.Integrate(order);
         int iActive = ActivePos.Search(actPos);
         if(actPos.Status() == POSITION_NULL)
         {
            SendEventDelPos(actPos);
            if(iActive != -1)
               ActivePos.Delete(iActive);
            else
               delete actPos;
         }
         else
         {
            SendEventRefreshPos(actPos);
            if(iActive == -1)
               ActivePos.InsertSort(actPos);
         }
         
         //����� ������� ������ ��� �������, ����� ������� - �������� �������.
         if(result.ActivePosition.Status() == POSITION_ACTIVE)
         {
            ActivePos.InsertSort(result.ActivePosition);
            SendEventRefreshPos(result.ActivePosition);
         }
         else
            delete result.ActivePosition;
         if(result.HistoryPosition.Status() == POSITION_HISTORY)
            IntegrateHistoryPos(result.HistoryPosition);
         else
            delete result.HistoryPosition;
         delete result;
      }
      
      ///
      /// ������������ ����������� �����.
      ///
      void ProcessingOrder(ulong ticket)
      {
         Order* ActOrder = new Order(ticket);
         if(ActOrder.Status() == ORDER_NULL)return;
         if(ActOrder.OrderState() != ORDER_STATE_STARTED)return;
         Position* actPos = FindOrCreateActivePosForOrder(ActOrder, false);
         if(actPos == NULL)return;
         actPos.ProcessingNewOrder(ActOrder.GetId());
         delete ActOrder;
      }
      
      ///
      /// ������� ��� ������������ ��� ������� ����� �������
      /// �������, ������� ����� ������������ ���������� �����.
      /// \param order - �����, ������� ��� �������� ���������� �����.
      /// \param createPos - ����, ����������� ��� � ������, ���� ������� �� ���� �������,
      /// ���������� ������� ����� �������.
      ///
      Position* FindOrCreateActivePosForOrder(Order* order, bool createPos=true)
      {
         ulong currId = order.GetId();
         int dbg = 3;
         if(currId == 1009045374)
            dbg = 4;
         ulong posId = order.PositionId();
         if(posId != 0)
         {
            int total = ActivePos.Total();
            Order* inOrder = new Order(posId);
            int iActive = ActivePos.Search(inOrder);
            delete inOrder;
            if(iActive != -1)
               return ActivePos.At(iActive);
         }
         //�������� ������� ���? - ������ ��� ����������� ����� ����� �������.
         if(createPos)
            return new Position();
         return NULL;
      }
      
      ///
      /// ������ � ������ ������������ ������� ����� ������������ �������.
      ///
      void IntegrateHistoryPos(Position* histPos)
      {
         int iHist = HistoryPos.Search(histPos);
         if(iHist != -1)
         {
            Position* pos = HistoryPos.At(iHist);
            pos.Merge(histPos);
            delete histPos;
         }
         else
         {
            HistoryPos.InsertSort(histPos);
            SendEventRefreshPos(histPos);
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
      /// ���������� ������� "���������� �������".
      ///
      void SendEventRefreshPos(Position* pos)
      {
         //� ���������� HedgeAPI ������ ���, � ������ ��� � ����������� �� �������.
         #ifndef HLIBRARY
            EventRefreshPos* event = new EventRefreshPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
      }
      
      ///
      /// ���������� ������� �������� �� ������ �������.
      ///
      void SendEventDelPos(Position* pos)
      {
         #ifndef HLIBRARY
            EventDelPos* event = new EventDelPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
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
      /// ������ �������� �������.
      ///
      static CArrayObj* ActivePos;
      ///
      /// ������ ������������, �������� �������.
      ///
      static CArrayObj* HistoryPos;
      ///
      /// ���������� ������, ������� ��������� � ������� ��������� �������.
      ///
      int dealsCountNow;
      ///
      /// ������� ���������� ������������ �������� �������.
      ///
      int ordersCountNow;
};