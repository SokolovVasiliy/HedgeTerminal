//+------------------------------------------------------------------+
//|                                                      HedgePanel© |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+

#property copyright  "2013, Vasiliy Sokolov, St.Petersburg, Russia."
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.100"

#define HEDGE_PANEL
//#define DEBUG
//#define RELEASE
#include  "Globals.mqh"

///
/// Скорость обновления панели
///
input int RefreshRate = 200;

HedgeManager* api;
MainForm* HedgePanel;
/// Временный глобальный указатель.
//TablePositions* tableHistory;
///
/// Инициализирующая функция.
///
void OnInit(void)
{  
   //int k = 0;
   //for(int i = 10; i >=0; --i)
   //   k = i;
   //Settings* set = Settings::GetSettings1();
   Settings = PanelSettings::Init();
   EventSetMillisecondTimer(RefreshRate);
   HedgePanel = new MainForm();
   EventExchange::Add(HedgePanel);
   EventRefresh* refresh = new EventRefresh(EVENT_FROM_UP, "TERMINAL REFRESH");
   HedgePanel.Event(refresh);
   delete refresh;
   api = new HedgeManager();
   EventExchange::Add(api);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
}

void OnDeinit(const int reason)
{
   int memory = MQLInfoInteger(MQL_MEMORY_USED);
   //printf("Using memory: " + (string)memory);
   int size = sizeof(HedgePanel);
   EventDeinit* ed = new EventDeinit();
   HedgePanel.Event(ed);
   delete ed;
   delete HedgePanel;
   delete api;
   EventKillTimer();
}

///
/// Вызывает логику эксперта с определенной периодичностью.
///
int counts;
int l;
void OnTimer(void)
{
   /*if(tableHistory != NULL && counts++%5==0)
   {
      printf("table move...");
      int ind = 0;
      if(l < tableHistory.LinesTotal())
         ind = l++;
      else
         ind = tableHistory.LinesTotal();
      tableHistory.LineVisibleFirst(ind);
   }*/
   EventRefresh* refresh = new EventRefresh(EVENT_FROM_UP, "TERMINAL REFRESH");
   api.Event(refresh);
   HedgePanel.Event(refresh);
   //EventExchange::PushEvent(refresh);
   delete refresh;
   ChartRedraw(MAIN_WINDOW);
   
   //Принудительно обновляем положение (только для выходных дней)
   /*long X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
   long Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
   string str = "X: " + (string)X + " Y:" + (string)Y;
   //Print("Получены новые размеры окна X:" + (string)X + " Y:" + (string)Y);
   EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, "TERMINAL WINDOW", true, 0, 0, X, Y);
   HedgePanel.Event(command);
   delete command;*/
}

void  OnTradeTransaction(
      const MqlTradeTransaction&    trans,
      const MqlTradeRequest&        request,
      const MqlTradeResult&         result
   )
{
   
   bool isDebug = MQLInfoInteger(MQL_DEBUG);
   string debug = "";
   
   if(isDebug)debug = " (MQL_DEBUG)";
   else debug = " (MQL_EXE)";
   ENUM_TRADE_TRANSACTION_TYPE type = trans.type;
   EventRequestNotice* event_request = new EventRequestNotice(trans, request, result);
   //printf("request id: " + (string)result.request_id + "   " + EnumToString(trans.type) + " " +
   //(string)result.retcode + " magic: " + (string)request.magic + " order: " + (string)request.order +
   //" res order: " + (string)trans.order + debug);
   api.Event(event_request);
   delete event_request;
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
      string str = "X: " + (string)X + " Y:" + (string)Y;
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

