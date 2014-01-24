#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Order.mqh"
#include "..\Events.mqh"
///
/// Класс позиции
///
class HedgeManager
{
   public:
      
      ///
      /// В режиме работы в панеле подключаем событийную модель.
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
      /// Возвращает идентификатор позиции, которой принадлежит ордер или сделка с magic_id
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
      /// Возвращает идентификатор позиции которой может принадлежать транзакция с магическим номером magic_id.
      /// Фактически позиции может не существовать.
      ///
      static ulong CanPositionId(ulong magic_id)
      {
         return magic_id;
      }
      ///
      /// Обрабатывает поступление новых событий.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeResult* result = event.GetResult();
         //Снимаем блок с позиций, к которым относятся отклоненные ордера.
         if(result.IsRejected())
         {
            TradeRequest* request = event.GetRequest();
            //Order* order = new Order(request.magic);
            //FindOrCreateActivePosForOrder(
         }
      }
      ///
      /// Следит за поступлением новых трейдов и ордеров.
      ///
      void OnRefresh()
      {
         //LoadHistory();
         HistorySelect(0, TimeCurrent());
         int total = HistoryDealsTotal();
         //int total = 5;
         //Перебираем все доступные трейды и формируем на их основе прототипы будущих позиций типа COrder
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            //LoadHistory();
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
         }
         //анализ status_blocked.
         total = OrdersTotal();
         //Если какой-либо из активных ордеров переместился в историю,
         //то также изменяем количество запомненных активных ордеров.
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
      /// Интегрирует новую сделку в систему позиций.
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
         
         //Можно закрыть больше чем имеется, тогда остаток - активная позиция.
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
      /// Обрабатывает исполняющий ордер.
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
      /// Находит уже существующую или создает новую нулевую
      /// позицию, которой может принадлежать переданный ордер.
      /// \param order - ордер, позицию для которого необходимо найти.
      /// \param createPos - флаг, указывающий что в случае, если позиция не была найдена,
      /// необходимо создать новую позицию.
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
         //Активной позиции нет? - значит это открывающий ордер новой позиции.
         if(createPos)
            return new Position();
         return NULL;
      }
      
      ///
      /// Вносит в список исторических позиций новую историческую позицию.
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
      /// For API: Возвращает количество активных позиций
      ///
      int ActivePosTotal()
      {
         return ActivePos.Total();
      }
      ///
      /// For API: Возвращает количество исторических позиций.
      ///
      int HistoryPosTotal()
      {
         return HistoryPos.Total();
      }
      ///
      /// For API: Возвращает активную позицию под номером n из списка позиций.
      ///
      Position* ActivePosAt(int n)
      {
         Position* pos = ActivePos.At(n);
         return pos;
      }
      
      
   private:
      ///
      /// Возвращает список идентификаторов трейдов, совершенных на основе ордера orderId.
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
      /// Отправляет событие "обновление позиции".
      ///
      void SendEventRefreshPos(Position* pos)
      {
         //В библиотеке HedgeAPI панели нет, а значит нет и передваемых ей событий.
         #ifndef HLIBRARY
            EventRefreshPos* event = new EventRefreshPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
      }
      
      ///
      /// Отправляет событие удаление из списка позиций.
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
      /// Загружает историю ордеров, если она не загружена.
      ///
      void LoadHistory(void)
      {
         if(HistoryDealsTotal() < 2)
            HistorySelect(0, TimeCurrent());
      }
      
      ///
      /// Список активных позиций.
      ///
      static CArrayObj* ActivePos;
      ///
      /// Список исторических, закрытых позиций.
      ///
      static CArrayObj* HistoryPos;
      ///
      /// Количество сделок, которое поступило в течении заданного периода.
      ///
      int dealsCountNow;
      ///
      /// Текущее количество обработанных активных ордеров.
      ///
      int ordersCountNow;
};