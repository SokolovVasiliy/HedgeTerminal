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
      /// ���������� ������������� ������� ������� ����� ������������ ���������� � ���������� ������� magic_id.
      /// ���������� ������� ����� �� ������������.
      ///
      static ulong CanPositionId(ulong magic_id)
      {
         return magic_id;
      }
      
      ///
      /// �������������� �������� ������� �� ���������� �������� �������,
      /// � ������� ��� ���������.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeRequest* request = event.GetRequest();
         Order* order = new Order(request);
         Position* ActPos = FindActivePosById(order.PositionId());
         delete order;
         if(ActPos != NULL)
            ActPos.Event(event);
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
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
         }
         CheckModifyOrders();
      }
      ///
      /// ������� ����� �������� ������� ���������� ���� ������ �
      /// ���������� �� ���� �������, � ������� ��� ����� ������������.
      ///
      void CheckModifyOrders()
      {
         if(ordersCountNow != OrdersTotal())
         {
            for(int i = 0; i < OrdersTotal(); i++)
            {
               ulong ticket = OrderGetTicket(i);
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
         Position* actPos = FindActivePosById(order.PositionId());
         if(actPos == NULL)
            actPos = new Position();
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
      ///
      /// �����, � �������� ���������� �������� ��������.
      ///
      datetime timeBegin;
};