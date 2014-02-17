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
      /// Возвращает идентификатор позиции которой может принадлежать транзакция с магическим номером magic_id.
      /// Фактически позиции может не существовать.
      ///
      /*static ulong CanPositionId(ulong magic_id)
      {
         return magic_id;
      }*/
      
      ///
      /// Перенаправляет торговые события на конкретные активные позиции,
      /// к которым они относятся.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeTransaction* trans = event.GetTransaction();
         //Посылаем ответ позиции.
         if(trans.IsRequest())
         {
            TradeRequest* request = event.GetRequest();
            Order* order = new Order(request);
            Position* ActPos = FindActivePosById(order.PositionId());
            delete order;
            if(ActPos != NULL)
               ActPos.Event(event);
         }
         //Отложенный ордер изменился? - Возможно он связан с позицией.
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
         int dbg = 5;
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            if(dealsCountNow == 2)
               dbg = 6;
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
         }
         TrackingPendingCancel();
         CheckModifyOrders();
         CollectNewSLAndTPOrders();
      }
      
      ///
      /// Отслеживает отмененные ордера.
      ///
      int c;
      void TrackingPendingCancel()
      {
         //При первом вызове отмененные ордера не отслеживаем,
         //т.к. первый вызов это разбор истории.
         /*if(!tracking)
         {
            tracking = true;
            historyOrdersCount = HistoryOrdersTotal();
            return;
         }*/
         for(; historyOrdersCount < HistoryOrdersTotal(); historyOrdersCount++)
         {
            ulong ticket = HistoryOrderGetTicket(historyOrdersCount);
            int dbg = 3;
            if(ticket == 1009521957)
               dbg = 4;
            ENUM_ORDER_STATE state = (ENUM_ORDER_STATE)HistoryOrderGetInteger(ticket, ORDER_STATE);
            //Ордер был отменен?
            if(state != ORDER_STATE_CANCELED)
               continue;
            Order* order = new Order(ticket);
            //Возможно это стоп-лосс или тейк профит?
            if(order.IsStopLoss() || order.IsTakeProfit())
            {
               //printf(c++);
               ENUM_ORDER_STATUS st = order.Status();
               //Отмененый стоп у активных позиций не актуален.
               //Отмененный стоп у исторической позиции надо запомнить.
               ulong id = order.PositionId();
               int total = HistoryPos.Total();
               Position* ActPos;
               ActPos = FindActivePosById(order.PositionId());
               if(ActPos != NULL)
               {
                  ActPos.Integrate(order);
                  continue;
               }
               ActPos = FindHistPosById(order.PositionId());
               if(ActPos != NULL)
               {
                  ActPos.Integrate(order);
                  continue;
               }
               delete order;
               continue;
            }
            else
               delete order;
         }
      }
      
      void CollectNewSLAndTPOrders()
      {
         //if(ordersPendingNow != OrdersTotal() || recalcModify)
         if(true)
         {
            //ordersPendingNow = 0;
            int total = OrdersTotal();
            if(ordersPendingNow > total)
               ordersPendingNow = total;
            for(; ordersPendingNow < total; ordersPendingNow++)
            {
               ulong ticket = OrderGetTicket(ordersPendingNow);
               if(!OrderSelect(ticket))continue;
               ENUM_ORDER_STATE state = (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE);
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
      /// Находит среди активных ордеров изменяющие свой статус и
      /// уведомляет об этом позиции, к которым они могут принадлежать.
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
      /// Вызывается сразу после инициализации и отображает активные сделки.
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
         //Можно закрыть больше чем имеется, тогда остаток - активная позиция.
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
      /// Находит историческую позицию в списке активных позиций, чей
      /// id равен posId.
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
      /// Вносит в список исторических позиций новую историческую позицию.
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
      /// Загружает историю ордеров, если она не загружена.
      ///
      void LoadHistory(void)
      {
         if(HistoryDealsTotal() < 2)
            HistorySelect(0, TimeCurrent());
      }
      ///
      /// Выводит строку высчитывающую производительность парсинга.
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
      /// Список активных позиций.
      ///
      CArrayObj* ActivePos;
      ///
      /// Список исторических, закрытых позиций.
      ///
      CArrayObj* HistoryPos;
      ///
      /// Количество сделок, которое поступило в течении заданного периода.
      ///
      int dealsCountNow;
      ///
      /// Текущее количество обработанных активных ордеров.
      ///
      int ordersCountNow;
      ///
      /// Текущее количество отложенных ордеров.
      ///
      int ordersPendingNow;
      ///
      /// Истина, если требуется пересчитывать ордера.
      ///
      bool recalcModify;
      ///
      /// Время, с которого происходит загрузка иситории.
      ///
      datetime timeBegin;
      ///
      /// Истина, если включено отслеживание ордеров.
      ///
      bool tracking;
      ///
      /// Количество исторических ордеров.
      ///
      int historyOrdersCount;
      ///
      /// Истина, если инициализация выполнена и осуществлен переход работы в режим реального времени.
      ///
      bool isInit;
};