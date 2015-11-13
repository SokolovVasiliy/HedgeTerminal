//+------------------------------------------------------------------+
//|                                                   HedgeTerminal© |
//|     Copyright 2013-2014, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+

#define NEW_TABLE
///
/// Компиляция визуальной панели терминала.
///
#define HEDGE_PANEL
///
/// Компиляция релиз версии. Имена графических объектов и локальных переменных скрыты.
///
//#define RELEASE

#include  "Globals.mqh"
#include "EnvironmentRemember.mqh"
///
/// Скорость обновления панели
///
input string SettingsPath = "Settings.xml"; //Name of file with settings.
//Скрывает демо-сообщение при первом запуске.
#ifdef DEMO
   bool useFirstTime;
#endif
uint Tiks = 0;
int rdetect;
HedgeManager* api;
MainForm* HedgePanel;
Environment Env;

///
/// Инициализирующая функция.
///
void OnInit(void)
{  
   if(Resources.Failed())
      return;
   uint rRate = Settings.GetRefreshRates();
   if(rRate < 30)
      rRate = 200;
   EventSetMillisecondTimer(rRate);
   HedgePanel = new MainForm();
   EventExchange.Add(HedgePanel);
   EventRefresh* refresh = new EventRefresh(EVENT_FROM_UP, "TERMINAL REFRESH");
   HedgePanel.Event(refresh);
   delete refresh;
   api = new HedgeManager();
   EventExchange.Add(api);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   Env.SetNewCaption();
   //PrepareChart();
   #ifdef DEMO
   if(!useFirstTime)
   {
      MessageBox("This demo version. You can test it on a demo account. Will be showed only AUDCAD, NZDCAD, AAPL* and VTBR-* position."+
      " Please purchase the full retail version for unlimited using.");
   }
   #endif
}

void OnDeinit(const int reason)
{
   if(CheckPointer(HedgePanel) != POINTER_INVALID)
   {
      EventDeinit* ed = new EventDeinit();
      HedgePanel.Event(ed);
      delete ed;
      delete HedgePanel;
   }
   if(CheckPointer(api) != POINTER_INVALID)
      delete api;
   Env.RestoreCaption();
   EventKillTimer();
   
}

///
/// Вызывает логику эксперта с определенной периодичностью.
///
void OnTimer(void)
{
   EventRefresh* refresh = new EventRefresh(EVENT_FROM_UP, "TERMINAL REFRESH");
   api.Event(refresh);
   HedgePanel.Event(refresh);
   delete refresh;
   ChartRedraw(MAIN_WINDOW);
   #ifdef DEMO
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE) != ACCOUNT_TRADE_MODE_DEMO && rdetect++==0)
   {
      string str = "Can only be shown on a demo account. Purchase a full-featured version, or use a demo account. ";
      LogWriter(str, MESSAGE_TYPE_INFO);
      MessageBox(str, VERSION);
      ExpertRemove();
   }
   #endif
}

void  OnTradeTransaction(
      const MqlTradeTransaction&    trans,
      const MqlTradeRequest&        request,
      const MqlTradeResult&         result
   )
{
   EventRequestNotice* event_request = new EventRequestNotice(trans, request, result);
   api.Event(event_request);
   delete event_request;
   ChartRedraw(MAIN_WINDOW);
}
int chartEventCount;
///
/// Подстраиваем размер главной формы панели под размер текущего окна
///
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   ulong msc = 0;
   chartEventCount++;
   //printf(id);
   //Координаты мыши или комбинация нажатых кнопок мыши изменились.
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mask = (int)StringToInteger(sparam);
      EventMouseMove* move = new EventMouseMove(lparam, (long)dparam, mask);
      
      //if(move.PushedLeftButton())
      //   printf("X:" + move.XCoord() + " Y:" + move.YCoord());
      HedgePanel.Event(move);
      delete move;
      return;
   }
   //Размеры базового окна изменились.
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      long X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
      long Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
      Y -= 1;
      //string str = "X: " + (string)X + " Y:" + (string)Y;
      //Print("Получены новые размеры окна X:" + (string)X + " Y:" + (string)Y);
      EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, "TERMINAL WINDOW", true, 0, 0, X, Y);
      HedgePanel.Event(command);
      delete command;
   }
   
   //Определяем, является ли событие нажатием на одну из кнопок HP
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      EventObjectClick* pushObj = new EventObjectClick(sparam);
      HedgePanel.Event(pushObj);
      delete pushObj;
   }
   //Нажата кнопка.
   if(id == CHARTEVENT_KEYDOWN)
   {
      int mask = (int)StringToInteger(sparam);
      EventKeyDown* key = new EventKeyDown((int)lparam, mask);
      //printf("Key press: " + key.Code());
      HedgePanel.Event(key);
      delete key;
   }
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
      EventEndEdit* endEdit = new EventEndEdit(sparam);
      HedgePanel.Event(endEdit);
      delete endEdit;
   }
   
   ChartRedraw(MAIN_WINDOW);
}

/*void CheckMe()
{
   int s = 0;
   #ifndef DEMO
   detect = false;
   #else
   HistorySelect(0, TimeCurrent());
   if(HistoryDealsTotal() > 0)
   {
      ulong id = HistoryDealGetTicket(0);
      datetime t = (datetime)HistoryDealGetInteger(id, DEAL_TIME);
      if(TimeCurrent() - t > (DEMO_PERIOD+1)*86400)
         detect = true;
   }
   if(HistoryOrdersTotal() > 0)
   {
      ulong id = HistoryOrderGetTicket(0);
      datetime t = (datetime)HistoryOrderGetInteger(id, ORDER_TIME_SETUP);
      if(TimeCurrent() - t > (DEMO_PERIOD+1)*86400)
         detect = true;
   }
   srand((uint)TimeCurrent());
   while(s < 5 && HistoryOrdersTotal())
   {
      int index = rand()%HistoryOrdersTotal();
      ulong id = HistoryOrderGetTicket(index);
      datetime t = (datetime)HistoryOrderGetInteger(id, ORDER_TIME_SETUP);
      if(t == 0)continue;
      if(TimeCurrent() - t > (DEMO_PERIOD+1)*86400)
         detect = true;
      s++;
   }
   
   #endif
}*/
