#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Order.mqh"
#include "..\Events.mqh"
#include "..\XML\XmlGarbage.mqh"
#include "..\Resources\Resources.mqh"
#include "..\Math\Math.mqh"
#include "LoadingProgressBar.mqh"
#include "..\Globals.mqh"
#include <Trade\Trade.mqh>
//#define __DEBUG__
//#include "H.mqh"
class PosVol;
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
            return;
         ActivePos = new CArrayObj();
         HistoryPos = new CArrayObj();
         ActivePos.Sort(SORT_ORDER_ID);
         HistoryPos.Sort(SORT_ORDER_ID);
         ticketOrders.Sort();
         listPendingOrders.Sort();
         long tick = GetTickCount();
         OnRefresh();
         int total1 = HistoryPos.Total();
         if(!isTester)
         {
            XmlGarbage* xmlGarbage = new XmlGarbage();
            xmlGarbage.ClearActivePos(Resources.GetFileNameByType(RES_ACTIVE_POS_XML), ActivePos);
            delete xmlGarbage;
            Resources.WizardInstallExclude(GetPointer(this));
            RemoveExclude();
            
            ShowPosition();
         }
         else
            Resources.InstallMissingFiles();
         isInit = true;
         PrintPerfomanceParsing(tick);
         if(!isTester)
            TestAsynch();
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
         datetime tc = TimeCurrent();
         datetime tn = TimeLocal();
         datetime t_end = tc > tn ? tc+20 : tn+20;
         //HistorySelect(0, D'2015.11.05 16:32:20');
         HistorySelect(0, t_end);
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
      /// Истина, если HedgeManager работает в режиме реального времени и
      /// ложь, если происходит парсинг историческиих позиций.
      ///
      bool IsInit(){return isInit;}
      
      ///
      /// Истина, если если произошел сбой установки ресурсов.
      ///
      bool IsFailed(){return Resources.Failed();}
      
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
      Position* FindActivePosById(ulong posId)
      {
         Order* inOrder = new Order(posId);
         int iActive = ActivePos.Search(inOrder);
         delete inOrder;
         if(iActive != -1)
               return ActivePos.At(iActive);
         return NULL;
      }
      
      ///
      /// Находит активную позицию в списке активных позиций, чей
      /// id равен posId.
      ///
      Position* FindActivePosByOrder(Order* order)
      {
         ulong posId = order.PositionId();
         if(posId != 0)
         {
            //Order* inOrder = new Order(posId);
            TransId* trans = new TransId(posId);
            //int iActive = ActivePos.Search(inOrder);
            int iActive = ActivePos.Search(trans);
            //delete inOrder;
            delete trans;
            if(iActive != -1)
               return ActivePos.At(iActive);
         }
         //Возможно активная позиция существует с идентификатором данного ордера
         else
         {
            int iActive = ActivePos.Search(order);
            if(iActive != -1)
               return ActivePos.At(iActive);
         }
         return NULL;
      }
      
      void HideHedgePositions()
      {
         if(PositionsTotal() > 0)
         {
            printf("Close your netto-positions and try letter.");
            return;
         }
         //Удаялем возможные стоп-лоссы перед скрытием позиции
         for(int i = ActivePos.Total()-1; i >= 0; i--)
         {
            Position* position = ActivePos.At(i);
            ENUM_HEDGE_ERR err = position.StopLossLevel(0.0, false);
            if(err != HEDGE_ERR_NOT_ERROR)
            {
               printf("Delete SL failed. Hide hedge position aborted.");
               return;
            }
         }
         Resources.AddExcludeOrders(GetPointer(this));
         //Скрываем активные позиции из панели
         #ifdef HEDGE_PANEL
         for(int i = ActivePos.Total()-1; i >= 0; i--)
         {
            Position* position = ActivePos.At(i);
            position.SendEventChangedPos(POSITION_HIDE);
         }
         #endif
         //Удаляем позиции из списка
         ActivePos.Clear();
      }
      
      ///
      /// Возвращает флаг успешности пройденного теста на асинхронность.
      ///
      bool Asyncronize(){return asynchTest;}
      ///
      /// Возвращает истину, если символ был экспирирован и ложь в противном случае.
      ///
      bool IsExpiration(string symbol)
      {
         datetime expTime = (datetime)SymbolInfoInteger(symbol, SYMBOL_EXPIRATION_TIME);
         if(TimeCurrent() > expTime && expTime > 0)return true;
         return false;
      }
   private:
      
      ///
      /// Посылает уведомление о изменении каждой активной позиции.
      ///
      void RefreshActPos()
      {
         if(!isInit)return;
         EventRefresh* event = new EventRefresh(EVENT_FROM_UP, "TERMINAL API");
         int t = ActivePos.Total();
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            pos.Event(event);
         }
         ChartRedraw();
         delete event;
      }
      ///
      /// Отслеживает поступление новых трейдов в истории трейдов.
      ///
      void TrackingHistoryDeals()
      {
         int total = HistoryDealsTotal();
         //Выводим статус бар
         double onePercent = total/100.0;
         int lastPercent = 0;
         if(!isInit)
         {
            loading = new ProgressBar();
            loading.ShowProgressBar();
         }
         //Перебираем все доступные трейды и формируем на их основе прототипы будущих позиций типа COrder
         for(; dealsCountNow < HistoryDealsTotal(); dealsCountNow++)
         {  
            #ifdef __DEBUG__
            if(isInit)
               printf("Счетчик сделок сработал. Старое значение " + (string)dealsCountNow +
               " Новое значение " + (string)HistoryDealsTotal());
            #endif 
            if(!isInit)
            {
               int percent = (int)MathRound((dealsCountNow/(double)total)*100.0);
               if(percent != lastPercent)
               {
                  lastPercent = percent;
                  loading.SetPercentProgress(percent);
               }
            }
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
            graphRebuild = true;
         }
         
         //Обнуляем статус бар.
         if(!isInit)
         {
            loading.HideProgressBar();
            delete loading;
         }
         //if(!isInit)
         //   ChartSetInteger(ChartID(), CHART_COLOR_FOREGROUND, clrWhiteSmoke);
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
      
      void TrackingPendingOrders2()
      {
         for(int i = 0; i < OrdersTotal(); i++)
         {
            ulong ticket = OrderGetTicket(i);
            if(!OrderSelect(ticket))
            {
               LogWriter("Could not select pending order #" + (string)ticket + ". Reason: " + (string)GetLastError(), MESSAGE_TYPE_ERROR);
               continue;
            }
            Order* order = new Order(ticket);
            //Обрабатываем только стоп и тейк-профит ордера
            if(!order.IsStopLoss() && !order.IsTakeProfit())
            {
               delete order;
               continue;
            }
            Position* pos = FindActivePosById(order.PositionId());
            if(pos == NULL)
            {
               delete order;
               m_trade.OrderDelete(ticket);
               continue;
            }
            Order* sl_order = pos.StopOrder();
            bool isIntegrate = false;
            if(sl_order == NULL && order.IsStopLoss())
            {
               isIntegrate = SendPendingOrder(order);
               EventOrderPending* pendingOrder = new EventOrderPending(order);
               SendTaskEvent(pendingOrder);
               delete pendingOrder;
               if(!isIntegrate)
               {
                  string text = "Failed to integrate order #" + (string)order.GetId() + ". Reason: " + EnumToString(GetHedgeError());
                  LogWriter(text, MESSAGE_TYPE_ERROR);
               }
               graphRebuild = true;
            }
            if(!isIntegrate)
            {
               delete order;
               m_trade.OrderDelete(ticket);
               continue;
            }
            
         }
      }
      ///
      /// Тестирует активные позиции на асинхронность с позициями терминала.
      /// Устанавливает флаг asynchTest  в истину, если тест пройден, и в ложь
      /// в противном случае.
      ///
      void TestAsynch()
      {
         if(GetMicrosecondCount() < 200000)
            Sleep(200);
         asynchTest = true;
         int total = ActivePos.Total();
         PosVol symbols[];
         //Сортируем виртуальные позиции по символам и суммируем их объем.
         for(int i = 0; i < total; i++)
         {
            Transaction* trans = ActivePos.At(i);
            if(trans.TransactionType() != TRANS_POSITION)continue;
            Position* pos = trans;
            int dir = pos.Direction() == DIRECTION_SHORT ? -1 : 1;
            int index = SymbolFind(symbols, pos.Symbol());
            if(index == -1)
            {
               ArrayResize(symbols, ArraySize(symbols)+1);
               index = ArraySize(symbols)-1;
               symbols[index].Name = pos.Symbol();
               symbols[index].Vol = 0.0;
            }
            symbols[index].Vol += pos.VolumeExecuted()*dir;
         }
         //Сопоставляем объем отсортированных позиций с объемом реальных позиций.
         for(int i = 0; i < ArraySize(symbols); i++)
         {
            string name = symbols[i].Name;
            double mvol = NormalizeDouble(symbols[i].Vol, 3);
            if(RealPosFind(symbols[i].Name))
            {
               double vol = PositionGetDouble(POSITION_VOLUME);
               ENUM_POSITION_TYPE pType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               if(pType == POSITION_TYPE_SELL)
                  vol *= (-1); 
               if(!Math::DoubleEquals(symbols[i].Vol, vol))
               {
                  string text = "Warning! Total net position HT by "+ name +
                              " not equal net position in MetaTrader 5 for this symbol ( HT Volume: " + 
                              DoubleToString(symbols[i].Vol, 2) + " MT5 Voleme: " + DoubleToString(vol, 2) + ")";
                  printf(text);
                  asynchTest = false;
               }
            }
            else if(!Math::DoubleEquals(mvol, 0.0))
            {
               string text = "Warning! Total net position HT by "+ name +
                              " not equal to zero, however, in MetaTrader 5 there is no position for this symbol";
               printf(text);
               asynchTest = false;
            }
         }
         //Есть ли реальные позиции, которые не отображены в виртуальных позициях?
         for(int i = 0; i < PositionsTotal(); i++)
         {
            string smb = PositionGetSymbol(i);
            #ifdef DEMO 
            if(CheckDemoSymbol(smb) == false)
               continue;
            #endif
            if(SymbolFind(symbols, smb) == -1)
            {
               string text = "Warning! In MetaTrader 5 there is a net position by " + smb +
                              ", but in HT there is no active position on this symbol";
               printf(text);
               asynchTest = false;
            }
         }
         if(!asynchTest)
         {
            string text = "Warning! Net positions not equal. Check file 'ExcludeOrders.xml' and fix it. MT5 Positions:" +
            (string)PositionsTotal() + " HT Position : " + (string)ActivePosTotal();
            printf(text);
         }
      }
      
      #ifdef DEMO
      bool CheckDemoSymbol(string symbol)
      {
         string symbols[] = {"VTBR-", "AUDCAD", "NZDCAD", "AAPL"};
         bool check = false;
         for(int i = 0; i < ArraySize(symbols); i++)
         {
            if(StringFind(symbol, symbols[i]) != -1)
               check = true;
         }
         return check;
      }
      #endif
      
      ///
      /// Находит инструмент с именем symbol в списке символов.
      /// \return -1 Если инструмент с таким именем не найден, и индекс
      /// инструмента если найден.
      int SymbolFind(PosVol& symbols[], string smb)
      {
         for(int i = 0; i < ArraySize(symbols); i++)
         {
            if(symbols[i].Name == smb)
               return i;
         }
         return -1;
      }
      ///
      /// Возвращает истину, если позиция с заданным символом существует и ложь в противном случае.
      ///
      bool RealPosFind(string symbol)
      {
         for(int k = 0; k < PositionsTotal(); k++)
         {
            string smb = PositionGetSymbol(k);
            if(symbol != smb)continue;
            PositionSelect(smb);
            return true;
         }
         return false;
      }
      ///
      /// Истина, если отложенный ордер с текущим тикетом является новым, появившемся ордером,
      /// и ложь в противном случае. 
      ///
      bool IsNewOrder(ulong ticket)
      {
         int index = listPendingOrders.Search(ticket);
         if(index == -1)
            listPendingOrders.InsertSort(ticket);
         return index == -1;
      }
      ///
      /// Отправляет поступивший отложенный ордер активной позиции, которой он принадлежит.
      /// \return Истина, если поступивший ордер был отправлен позиции и ложь, если соответствующая
      /// позиция не нашлась и ордер не был отправлен.
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
      /// Создает отмененный ордер, анализируя изменившуюся историю ордеров.
      ///
      Order* CreateCancelOrderOrNull(int index)
      {
         ulong ticket;
         if(!isInit)
            ticket = HistoryOrderGetTicket(index);
         else
            ticket = FindAddTicket();
         if(ticket == 0)return NULL;
         ticketOrders.InsertSort(ticket);
         ENUM_ORDER_STATE state = (ENUM_ORDER_STATE)HistoryOrderGetInteger(ticket, ORDER_STATE);
         if(state != ORDER_STATE_CANCELED && state != ORDER_STATE_EXPIRED)return NULL;
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
            Position* ActPos = FindActivePosByOrder(order);
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
      /// Вызывается сразу после инициализации и отображает активные сделки, а также
      /// инициализирует их ссылки на XML файл активных позиций.
      ///
      void ShowPosition()
      {
         #ifdef HEDGE_PANEL
         ProgressBar panel_loading;
         panel_loading.ShowPanelBuilding();
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
         panel_loading.HideProgressBar();
         #endif
      }
      ///
      /// Удаляет из списка активных позиций скрытые позиции.
      ///
      void RemoveExclude()
      {
         CArrayLong* excludeOrders = Settings.GetExcludeOrders();
         if(excludeOrders == NULL)return;
         for(int i = ActivePos.Total()-1; i >= 0; i--)
         {
            Position* pos = ActivePos.At(i);
            ulong id = pos.GetId();
            if(IsExpiration(pos.Symbol()) || excludeOrders.Search(pos.GetId()) != -1)
               ActivePos.Delete(i);
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
      /// Интегрирует новую сделку в систему позиций.
      ///
      void AddNewDeal(ulong ticket)
      {
         #ifdef DEMO
         string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         if(CheckDemoSymbol(symbol) == false)
         {
             if(IsInit())
             {
               bool res = MessageBox("HedgeTerminalDemo detect new deal, but the demo version does not support that symbol. " +
               "Please purchase the full version of the panel. For work in demo mode you can only use AUDCAD, NZDCAD, AAPL* and VTBR-* symbols",
               "HedgeTerminal Demo");
             }
             return;
         }
         #endif
         int dbg = 5;
         if(ticket == 3999377)
            dbg = 3;
         Deal* deal = new Deal(ticket);
         #ifdef __DEBUG__
            if(isInit)
               printf("Создана новая сделка, на основе тикета №" + (string)ticket);
         #endif
         if(deal.Status() == DEAL_BROKERAGE || deal.Status() == DEAL_NULL)
         {
            delete deal;
            return;
         }
         else if(deal.Status() == DEAL_BROKERAGE_SWAP)
         {
            CreateHistorySwap(deal);
            return;
         }
         Order* order = new Order(deal);
         #ifdef __DEBUG__
         if(isInit)
            printf("Создан новый ордер №" + (string)order.GetId() + ", со статусом " + EnumToString(order.Status()));
         #endif
         if(order.Status() == ORDER_NULL)
         {
            if(isInit)
               printf("Ордер №" + (string)order.GetId() + " был удален");
            delete order;
            return;
         }
         
         EventOrderExe* event = new EventOrderExe(order);
         SendTaskEvent(event);
         delete event;
         Position* actPos = FindActivePosByOrder(order);
         if(actPos == NULL)
         {
            actPos = new Position();
            #ifdef __DEBUG__
            if(isInit)
               printf("Активной позиции относящейся к одреру №" + (string)order.GetId() + " не найдено. Создана новая позиция");
            #endif
         }
         #ifdef __DEBUG__
         else if(isInit)
            printf("Найдена активная позиция №" + (string)actPos.GetId() + ", к которой принадлежит ордер №" + (string)order.GetId());
         #endif
         InfoIntegration* result = actPos.Integrate(order);
         #ifdef __DEBUG__
         if(isInit)
         {
            if(result.IsSuccess)
               printf("Ордер " + " проинтегрирован удачно");
            else
               printf("Ордер " + " не проинтегрирован с позицией");
         }
         #endif
         bool resSucess = result.IsSuccess;
         int iActive = ActivePos.Search(actPos);
         if(actPos.Status() == POSITION_NULL)
         {
            if(isInit)
            {
               #ifdef __DEBUG__
               if(isInit)
                  printf("Активная позиция №" + (string)actPos.GetId() + " была удалена");
               #endif
               actPos.SendEventChangedPos(POSITION_HIDE);
            }
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
               {
                  actPos.SendEventChangedPos(POSITION_SHOW);
                  #ifdef __DEBUG__
                  if(isInit)
                     printf("Активная позиция №" + (string)actPos.GetId() + " начинает существовать");
                  #endif
               }
               ActivePos.InsertSort(actPos);
            }
            else
            { 
               #ifdef __DEBUG__
               if(isInit)
                  printf("Активная позиция №" + (string)actPos.GetId() + " продолжает существовать, но изменилась");
               #endif
               Position* oldPos = ActivePos.At(iActive);
               if(CheckPointer(oldPos) != CheckPointer(actPos))
               {
                  #ifdef __DEBUG__
                  if(isInit)
                     printf("Непонятная манипуляция с позицией №" + (string)oldPos.GetId());
                  #endif
                  InfoIntegration* nres = oldPos.Integrate(actPos.EntryOrder());
                  delete actPos;
                  delete nres;
               }
               if(isInit)
                  oldPos.SendEventChangedPos(POSITION_REFRESH);
               //return;
            }
         }
         //Можно закрыть больше чем имеется, тогда остаток - активная позиция.
         if(result.ActivePosition != NULL &&
            result.ActivePosition.Status() == POSITION_ACTIVE)
         {
            #ifdef __DEBUG__
            if(isInit)
               printf("В результате интеграции была создана новая позиция по остатку №" + (string)result.ActivePosition.GetId());
            #endif
            ActivePos.InsertSort(result.ActivePosition);
            if(isInit)
               result.ActivePosition.SendEventChangedPos(POSITION_SHOW);
         }
         if(result.HistoryPosition != NULL &&
            result.HistoryPosition.Status() == POSITION_HISTORY)
         {
            #ifdef __DEBUG__
            if(isInit)
               printf("В результате интеграции была создана новая историческая позиция №" + (string)result.HistoryPosition.GetId());
            #endif
            IntegrateHistoryPos(result.HistoryPosition);
         }
         delete result;
      }
      ///
      /// Создает своп исторической позиции
      ///
      void CreateHistorySwap(Deal* deal)
      {
         delete deal;
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
         {
            #ifdef DEMO
            int total = HistoryPos.Total();
            for(int i = total-10; i >= 0; i--)
            {
               Position* pos = HistoryPos.At(i);
               pos.SendEventChangedPos(POSITION_HIDE);
               HistoryPos.Delete(i);
               delete pos;
            }
            #endif
            HistoryPos.InsertSort(histPos);
            //HistoryPos.Add(histPos);
         }
         if(isInit && !isMerge)
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
         int ram = MQLInfoInteger(MQL_MEMORY_USED);
         string line = "Start HedgeTerminal. Parsing of history deals (" + (string)dTotal +
         ") and orders (" + (string)oTotal + ") completed in " + seconds + " sec. " + (string)ram + "MB RAM used.";
         printf(line);
      }
      ///
      /// Прогресс бар.
      ///
      ProgressBar* loading;
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
      /// Истина, если требуется послать уведомление о перестройки графики в HedgePanel.
      ///
      bool graphRebuild;
      ///
      /// Список запомненных отложеных ордеров.
      ///
      CArrayLong listPendingOrders;
      ///
      /// Истина, если тест на ассиметрию пройден и ложь в противном случае.
      ///
      bool asynchTest;
      ///
      /// Содержит название инструмента и его объем
      ///
      class PosVol : public CObject
      {
         public:
            ///
            /// Название инструмента.
            ///
            string Name;
            ///
            /// Объем инструмента.
            ///
            double Vol;
            PosVol()
            {
               Name = "";
               Vol = 0.0;
            }
      };
      ///
      /// Торговая логика.
      ///
      CTrade m_trade;
};
///
/// Интерфейс обратного вызова.
///
HedgeManager* callBack;