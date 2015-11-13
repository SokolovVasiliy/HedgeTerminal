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
      /// ������ ����������� ���������� ������.
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
      /// ������, ���� HedgeManager �������� � ������ ��������� ������� �
      /// ����, ���� ���������� ������� ������������� �������.
      ///
      bool IsInit(){return isInit;}
      
      ///
      /// ������, ���� ���� ��������� ���� ��������� ��������.
      ///
      bool IsFailed(){return Resources.Failed();}
      
      ///
      /// For API: ���������� ���������� �������� �������
      ///
      int ActivePosTotal()
      {
         //printf("API pos total " + ActivePos.Total());
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
      /// For API: ���������� ������������ ������� ��� ������� n �� ������ �������.
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
      /// ������� �������� ������� � ������ �������� �������, ���
      /// id ����� posId.
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
         //�������� �������� ������� ���������� � ��������������� ������� ������
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
         //������� ��������� ����-����� ����� �������� �������
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
         //�������� �������� ������� �� ������
         #ifdef HEDGE_PANEL
         for(int i = ActivePos.Total()-1; i >= 0; i--)
         {
            Position* position = ActivePos.At(i);
            position.SendEventChangedPos(POSITION_HIDE);
         }
         #endif
         //������� ������� �� ������
         ActivePos.Clear();
      }
      
      ///
      /// ���������� ���� ���������� ����������� ����� �� �������������.
      ///
      bool Asyncronize(){return asynchTest;}
      ///
      /// ���������� ������, ���� ������ ��� ������������ � ���� � ��������� ������.
      ///
      bool IsExpiration(string symbol)
      {
         datetime expTime = (datetime)SymbolInfoInteger(symbol, SYMBOL_EXPIRATION_TIME);
         if(TimeCurrent() > expTime && expTime > 0)return true;
         return false;
      }
   private:
      
      ///
      /// �������� ����������� � ��������� ������ �������� �������.
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
      /// ����������� ����������� ����� ������� � ������� �������.
      ///
      void TrackingHistoryDeals()
      {
         int total = HistoryDealsTotal();
         //������� ������ ���
         double onePercent = total/100.0;
         int lastPercent = 0;
         if(!isInit)
         {
            loading = new ProgressBar();
            loading.ShowProgressBar();
         }
         //���������� ��� ��������� ������ � ��������� �� �� ������ ��������� ������� ������� ���� COrder
         for(; dealsCountNow < HistoryDealsTotal(); dealsCountNow++)
         {  
            #ifdef __DEBUG__
            if(isInit)
               printf("������� ������ ��������. ������ �������� " + (string)dealsCountNow +
               " ����� �������� " + (string)HistoryDealsTotal());
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
         
         //�������� ������ ���.
         if(!isInit)
         {
            loading.HideProgressBar();
            delete loading;
         }
         //if(!isInit)
         //   ChartSetInteger(ChartID(), CHART_COLOR_FOREGROUND, clrWhiteSmoke);
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
            //������������ ������ ���� � ����-������ ������
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
      /// ��������� �������� ������� �� ������������� � ��������� ���������.
      /// ������������� ���� asynchTest  � ������, ���� ���� �������, � � ����
      /// � ��������� ������.
      ///
      void TestAsynch()
      {
         if(GetMicrosecondCount() < 200000)
            Sleep(200);
         asynchTest = true;
         int total = ActivePos.Total();
         PosVol symbols[];
         //��������� ����������� ������� �� �������� � ��������� �� �����.
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
         //������������ ����� ��������������� ������� � ������� �������� �������.
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
         //���� �� �������� �������, ������� �� ���������� � ����������� ��������?
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
      /// ������� ���������� � ������ symbol � ������ ��������.
      /// \return -1 ���� ���������� � ����� ������ �� ������, � ������
      /// ����������� ���� ������.
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
      /// ���������� ������, ���� ������� � �������� �������� ���������� � ���� � ��������� ������.
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
      /// ������, ���� ���������� ����� � ������� ������� �������� �����, ����������� �������,
      /// � ���� � ��������� ������. 
      ///
      bool IsNewOrder(ulong ticket)
      {
         int index = listPendingOrders.Search(ticket);
         if(index == -1)
            listPendingOrders.InsertSort(ticket);
         return index == -1;
      }
      ///
      /// ���������� ����������� ���������� ����� �������� �������, ������� �� �����������.
      /// \return ������, ���� ����������� ����� ��� ��������� ������� � ����, ���� ���������������
      /// ������� �� ������� � ����� �� ��� ���������.
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
      /// ������� ���������� �����, ���������� ������������ ������� �������.
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
            Position* ActPos = FindActivePosByOrder(order);
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
      /// ���������� ����� ����� ������������� � ���������� �������� ������, � �����
      /// �������������� �� ������ �� XML ���� �������� �������.
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
      /// ������� �� ������ �������� ������� ������� �������.
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
      /// ����������� ����� ������ � ������� �������.
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
               printf("������� ����� ������, �� ������ ������ �" + (string)ticket);
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
            printf("������ ����� ����� �" + (string)order.GetId() + ", �� �������� " + EnumToString(order.Status()));
         #endif
         if(order.Status() == ORDER_NULL)
         {
            if(isInit)
               printf("����� �" + (string)order.GetId() + " ��� ������");
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
               printf("�������� ������� ����������� � ������ �" + (string)order.GetId() + " �� �������. ������� ����� �������");
            #endif
         }
         #ifdef __DEBUG__
         else if(isInit)
            printf("������� �������� ������� �" + (string)actPos.GetId() + ", � ������� ����������� ����� �" + (string)order.GetId());
         #endif
         InfoIntegration* result = actPos.Integrate(order);
         #ifdef __DEBUG__
         if(isInit)
         {
            if(result.IsSuccess)
               printf("����� " + " ��������������� ������");
            else
               printf("����� " + " �� ��������������� � ��������");
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
                  printf("�������� ������� �" + (string)actPos.GetId() + " ���� �������");
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
                     printf("�������� ������� �" + (string)actPos.GetId() + " �������� ������������");
                  #endif
               }
               ActivePos.InsertSort(actPos);
            }
            else
            { 
               #ifdef __DEBUG__
               if(isInit)
                  printf("�������� ������� �" + (string)actPos.GetId() + " ���������� ������������, �� ����������");
               #endif
               Position* oldPos = ActivePos.At(iActive);
               if(CheckPointer(oldPos) != CheckPointer(actPos))
               {
                  #ifdef __DEBUG__
                  if(isInit)
                     printf("���������� ����������� � �������� �" + (string)oldPos.GetId());
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
         //����� ������� ������ ��� �������, ����� ������� - �������� �������.
         if(result.ActivePosition != NULL &&
            result.ActivePosition.Status() == POSITION_ACTIVE)
         {
            #ifdef __DEBUG__
            if(isInit)
               printf("� ���������� ���������� ���� ������� ����� ������� �� ������� �" + (string)result.ActivePosition.GetId());
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
               printf("� ���������� ���������� ���� ������� ����� ������������ ������� �" + (string)result.HistoryPosition.GetId());
            #endif
            IntegrateHistoryPos(result.HistoryPosition);
         }
         delete result;
      }
      ///
      /// ������� ���� ������������ �������
      ///
      void CreateHistorySwap(Deal* deal)
      {
         delete deal;
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
      /// �������� ����������� ������� ������� ������� �� ������ �������.
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
         int ram = MQLInfoInteger(MQL_MEMORY_USED);
         string line = "Start HedgeTerminal. Parsing of history deals (" + (string)dTotal +
         ") and orders (" + (string)oTotal + ") completed in " + seconds + " sec. " + (string)ram + "MB RAM used.";
         printf(line);
      }
      ///
      /// �������� ���.
      ///
      ProgressBar* loading;
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
      /// ������, ���� ��������� ������� ����������� � ����������� ������� � HedgePanel.
      ///
      bool graphRebuild;
      ///
      /// ������ ����������� ��������� �������.
      ///
      CArrayLong listPendingOrders;
      ///
      /// ������, ���� ���� �� ���������� ������� � ���� � ��������� ������.
      ///
      bool asynchTest;
      ///
      /// �������� �������� ����������� � ��� �����
      ///
      class PosVol : public CObject
      {
         public:
            ///
            /// �������� �����������.
            ///
            string Name;
            ///
            /// ����� �����������.
            ///
            double Vol;
            PosVol()
            {
               Name = "";
               Vol = 0.0;
            }
      };
      ///
      /// �������� ������.
      ///
      CTrade m_trade;
};
///
/// ��������� ��������� ������.
///
HedgeManager* callBack;