#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Order.mqh"

///
///  ласс позиции
///
class HedgeManager
{
   public:
      ///
      /// ¬ режиме работы в панеле подключаем событийную модель.
      ///
      #ifndef HLIBRARY
      void Event(Event* event)
      {
         ENUM_EVENT enEvent = event.EventId();
         switch(event.EventId())
         {
            case EVENT_REFRESH:
               OnRefresh();
               break;
         }
      }
      #endif
      
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
      /// —ледит за поступлением новых трейдов и ордеров.
      ///
      void OnRefresh()
      {
         LoadHistory();
         int total = HistoryDealsTotal();
         //int total = 5;
         //ѕеребираем все доступные трейды и формируем на их основе прототипы будущих позиций типа COrder
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            //LoadHistory();
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
         }
         //анализ status_blocked.
         total = OrdersTotal();
         for(; ordersCountNow < total; ordersCountNow++)
         {
            ulong ticket = OrderGetTicket(ordersCountNow);
            OrderSelect(ticket);
            ProcessingOrder(ticket);
         }
      }
      
      ///
      /// »нтегрирует новую сделку в систему позиций.
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
         
         //ћожно закрыть больше чем имеетс€, тогда остаток - активна€ позици€.
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
      /// ќбрабатывает исполн€ющий ордер.
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
      /// Ќаходит уже существующую или создает новую нулевую
      /// позицию, которой может принадлежать переданный ордер.
      /// \param order - ордер, позицию дл€ которого необходимо найти.
      /// \param createPos - флаг, указывающий что в случае, если позици€ не была найдена,
      /// необходимо создать новую позицию.
      ///
      Position* FindOrCreateActivePosForOrder(Order* order, bool createPos=true)
      {
         
         ulong posId = order.PositionId();
         ulong currId = order.GetId();
         if(posId != 0)
         {
            int total = ActivePos.Total();
            Order* inOrder = new Order(posId);
            int iActive = ActivePos.Search(inOrder);
            delete inOrder;
            if(iActive != -1)
               return ActivePos.At(iActive);
         }
         //јктивной позиции нет? - значит это открывающий ордер новой позиции.
         if(createPos)
            return new Position();
         return NULL;
      }
      
      ///
      /// ¬носит в список исторических позиций новую историческую позицию.
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
      /// For API: ¬озвращает количество активных позиций
      ///
      int ActivePosTotal()
      {
         return ActivePos.Total();
      }
      ///
      /// For API: ¬озвращает количество исторических позиций.
      ///
      int HistoryPosTotal()
      {
         return HistoryPos.Total();
      }
      ///
      /// For API: ¬озвращает активную позицию под номером n из списка позиций.
      ///
      Position* ActivePosAt(int n)
      {
         Position* pos = ActivePos.At(n);
         return pos;
      }
      
      
   private:
      ///
      /// ¬озвращает список идентификаторов трейдов, совершенных на основе ордера orderId.
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
      /// ќтправл€ет событие "обновление позиции".
      ///
      void SendEventRefreshPos(Position* pos)
      {
         //¬ библиотеке HedgeAPI панели нет, а значит нет и передваемых ей событий.
         #ifndef HLIBRARY
            EventRefreshPos* event = new EventRefreshPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
      }
      
      ///
      /// ќтправл€ет событие удаление из списка позиций.
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
      /// «агружает историю ордеров, если она не загружена.
      ///
      void LoadHistory(void)
      {
         if(HistoryDealsTotal() < 2)
            HistorySelect(0, TimeCurrent());
      }
      
      ///
      /// —писок активных позиций.
      ///
      CArrayObj* ActivePos;
      ///
      /// —писок исторических, закрытых позиций.
      ///
      CArrayObj* HistoryPos;
      ///
      ///  оличество сделок, которое поступило в течении заданного периода.
      ///
      int dealsCountNow;
      ///
      /// “екущее количество обработанных активных ордеров.
      ///
      int ordersCountNow;
};