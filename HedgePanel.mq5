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

///
/// Инициализирующая функция.
///
void OnInit(void)
{  
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
   
   //EventRedraw* redraw = new EventRedraw(EVENT_FROM_UP, "TERMINAL WINDOW");
   //HedgePanel.Event(redraw);
   //delete redraw;
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   //OnTimer();
}

void OnDeinit(const int reason)
{
   int size = sizeof(HedgePanel);
   //printf("HedgePanelSize: " + (string)size);
   EventDeinit* ed = new EventDeinit();
   HedgePanel.Event(ed);
   api.Event(ed);
   delete ed;
   delete HedgePanel;
   delete api;
   EventKillTimer();
   delete Settings;
   //printf("Count: " + (string)chartEventCount);
}

///
/// Вызывает логику эксперта с определенной периодичностью.
///
void OnTimer(void)
{
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
   
   EventRequestNotice* event_request = new EventRequestNotice(trans, request, result);
   printf(EnumToString(trans.order_state) + "   " + EnumToString(trans.type) + " " +
   (string)result.retcode + " magic: " + (string)request.magic + " order: " + (string)request.order +
   " res order: " + (string)trans.order);
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
   //Координаты мыши или комбинация нажатых кнопок мыши изменились.
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mask = (int)StringToInteger(sparam);
      EventMouseMove* move = new EventMouseMove(lparam, (long)dparam, mask);
      HedgePanel.Event(move);
      delete move;
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

