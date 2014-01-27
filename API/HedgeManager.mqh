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
      /// Возвращает идентификатор позиции которой может принадлежать транзакция с магическим номером magic_id.
      /// Фактически позиции может не существовать.
      ///
      static ulong CanPositionId(ulong magic_id)
      {
         return magic_id;
      }
      
      ///
      /// Перенаправляет торговые события на конкретные активные позиции,
      /// к которым они относятся.
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
      /// Следит за поступлением новых трейдов и ордеров.
      ///
      void OnRefresh()
      {
         //LoadHistory();
         datetime t_now = TimeCurrent();
         HistorySelect(timeBegin, t_now);
         //TODO.
         //timeBegin = t_now;
         int total = HistoryDealsTotal();
         //Перебираем все доступные трейды и формируем на их основе прототипы будущих позиций типа COrder
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
         }
         CheckModifyOrders();
      }
      ///
      /// Находит среди активных ордеров изменяющие свой статус и
      /// уведомляет об этом позиции, к которым они могут принадлежать.
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
      /// Возвращает истину, если статус ордера указывает на то, что он находится
      /// в процессе модификации.
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
      /// Находит активную позицию в списке активных позиций, чей
      /// id равен posId.
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
      ///
      /// Время, с которого происходит загрузка иситории.
      ///
      datetime timeBegin;
};