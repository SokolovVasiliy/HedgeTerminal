#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Order.mqh"
#include "..\Events.mqh"
#include "..\XML\XmlGarbage.mqh"
#include "..\Resources\Resources.mqh"
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
         SendTaskEvent(event);
         switch(event.EventId())
         {
            case EVENT_REFRESH:
               OnRefresh();
               RefreshActPos(event);
               break;
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
               break;
            case EVENT_XML_ACTPOS_REFRESH:
               //OnXmlActPosRefresh(event);
               break;
         }
      }
      
      ///
      /// 
      ///
      HedgeManager()
      {
         if(Settings == NULL)
            Settings = PanelSettings::Init();
         if(Settings == NULL)
            ExpertRemove();
         ActivePos = new CArrayObj();
         HistoryPos = new CArrayObj();
         ActivePos.Sort(SORT_ORDER_ID);
         HistoryPos.Sort(SORT_ORDER_ID);
         ticketOrders.Sort();
         long tick = GetTickCount();
         //printf(tick + " " + HistoryPos.Total());
         OnRefresh();
         //printf(tick + " " + HistoryPos.Total());
         xmlGarbage.ClearActivePos(Resources::GetFileNameByType(RES_ACTIVE_POS_XML), ActivePos);
         isInit = true;
         ShowPosition();
         PrintPerfomanceParsing(tick);
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
         if(CheckPointer(Settings) != POINTER_INVALID)
            delete Settings;
         tasks.Shutdown();
      }
      
      ///
      /// Добавляет задачу в список задач.
      ///
      void AddTask(Task2* task)
      {
         tasks.Add(task);
      }
      
      ///
      /// Следит за поступлением новых трейдов и ордеров.
      ///
      void OnRefresh()
      {
         HistorySelect(timeBegin, TimeCurrent());
         TrackingHistoryDeals();
         TrackingHistoryOrders();
         TrackingPendingOrders();
         RefreshPanel();
      }
      ///
      /// Делает графическое обновление панели.
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
      /// For API: Возвращает количество активных позиций
      ///
      int ActivePosTotal()
      {
         //printf("API pos total " + ActivePos.Total());
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
      ///
      /// For API: Возвращает историческую позицию под номером n из списка позиций.
      ///
      Position* HistoryPosAt(int n)
      {
         Position* pos = HistoryPos.At(n);
         return pos;
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
   private:
      ///
      /// Посылает уведомление о изменении каждой активной позиции.
      ///
      void RefreshActPos(EventRefresh* event)
      {
         if(!isInit)return;
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            pos.Event(event);
         }
      }
      ///
      /// Отслеживает поступление новых трейдов в истории трейдов.
      ///
      void TrackingHistoryDeals()
      {
         int total = HistoryDealsTotal();
         //Перебираем все доступные трейды и формируем на их основе прототипы будущих позиций типа COrder
         for(; dealsCountNow < HistoryDealsTotal(); dealsCountNow++)
         {  
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
            graphRebuild = true;
         }
      }
      
      ///
      /// Отслеживает поступление новых исторических ордеров.
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
      /// Отслеживает поступление новых отложенных активных ордеров.
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
            graphRebuild = true;
         }
         ordersPendingNow = OrdersTotal();
      }
      
      ///
      /// Отправляет поступивший отложенный ордер активной позиции, которой он принадлежит.
      /// \return Истина, если поступивший ордер был отправлен позиции и ложь, если соответствующая
      /// позиция не нашлась и ордер не был отправлен.
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
      /// Создает отмененный ордер, анализируя изменившуюся историю ордеров.
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
      /// Пересылает отложенные стоп и профит ордера позициям, которым они
      /// принадлежат.
      /// \return Истина, если ордер был интегрирован в соответствующую позицию и ложь
      /// в противном случае.
      ///
      bool SendCancelStopAndProfitOrder(Order* order)
      {
         if(!order.IsStopLoss() && !order.IsTakeProfit())return false;
         //Отмененый стоп у активных позиций не актуален.
         //Отмененный стоп у исторической позиции надо запомнить.
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
      /// Находит тикет ордера, который был добавлен в историю ордеров.
      ///
      ulong FindAddTicket()
      {
         ulong ticket;
         //Быстрый способ - если событие пришло раньше.
         if(addOrderTicket != 0 && !ContainsHistTicket(addOrderTicket))
         {
            ticket = addOrderTicket;
            addOrderTicket = 0;
         }
         //Медленный способ - если событие не пришло или задержалось.
         else
            ticket = FindTicketInHistory();
         return ticket;
      }
      
      ///
      /// Перебирает все ордера в истории, и возвращает первый ордер с конца, который еще не был
      /// внесен в список обработанных ордеров.
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
         //
         if(trans.type == TRADE_TRANSACTION_HISTORY_ADD)
         {
            addOrderTicket = trans.order;
         }
      }
      
      ///
      /// Истина, если список ticketOrders содержит тикет с данным модификатором.
      /// Ложь в противном случае.
      ///
      bool ContainsHistTicket(ulong ticket)
      {
         int index = ticketOrders.Search(ticket);
         if(index == -1)
            return false;
         return true;
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
      void ShowPosition()
      {
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            pos.SendEventChangedPos(POSITION_SHOW);
         }
         CreateSummary(TABLE_POSACTIVE);
         for(int i = 0; i < HistoryPos.Total(); i++)
         {
            Position* pos = HistoryPos.At(i);
            pos.SendEventChangedPos(POSITION_SHOW);
         }
         CreateSummary(TABLE_POSHISTORY);
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
      /// Посылает поступившее событие каждому заданию из списка заданий.
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
         /*for(int i = 0; i < tasks.Total();i++)
         {
            int total = tasks.Total();
            CObject* obj = tasks.At(i);
            Task2* task = obj;
            if(task.IsFinished())
            {
               tasks.Delete(i);
               //i--;
               //continue;
               break;
            }
            task.Event(event);
            //i++;
         }*/
      }
   
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
         ") and orders (" + (string)oTotal + ") completed for " + seconds + " sec.";
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
      ///
      /// Проанализированный список тикетов проверенных ордеров.
      ///
      CArrayLong ticketOrders;
      ///
      /// Тикет добавляемого в историю ордера, который записывает метод отслеживания событий.
      ///
      ulong addOrderTicket;
      ///
      /// Список заданий.
      ///
      CArrayObj tasks;
      ///
      /// Сборщик неиспользованных узлов.
      ///
      XmlGarbage xmlGarbage;
      ///
      /// Истина, если требуется послать уведомление о перестройки графики в HedgePanel.
      ///
      bool graphRebuild;
};