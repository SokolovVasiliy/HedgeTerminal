//+------------------------------------------------------------------+
//|                                                      HedgePanel© |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+

#property copyright  "2013, , Vasiliy Sokolov, St.Petersburg, Russia."
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.100"

#include  "Globals.mqh"

///
/// Скорость обновления панели
///
input int RefreshRate = 5;

CHedge* api;
MainForm* HedgePanel;

PosLine* GlobalLine;

///
/// Инициализирующая функция.
///
void OnInit(void)
{  
   //Print("Инициализация советника");
   EventSetTimer(RefreshRate);
   HedgePanel = new MainForm();
   api = new CHedge();
   EventExchange::Add(HedgePanel);
   EventExchange::Add(api);
   api.Init();
   EventRedraw* redraw = new EventRedraw(EVENT_FROM_UP, "TERMINAL WINDOW");
   HedgePanel.Event(redraw);   
   delete redraw;
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
}
void OnDeinit(const int reason)
{
   int size = sizeof(HedgePanel);
   printf("HedgePanelSize: " + (string)size);
   EventDeinit* ed = new EventDeinit();
   HedgePanel.Event(ed);
   api.Event(ed);
   delete ed;
   delete HedgePanel;
   delete api;
   EventKillTimer();
}

///
/// Вызывает логику эксперта с определенной периодичностью.
///
void OnTimer(void)
{
   EventRefresh* refresh = new EventRefresh(EVENT_FROM_UP, "TERMINAL REFRESH");
   EventExchange::PushEvent(refresh);
   delete refresh;
}
///
/// Подстраиваем размер главной формы панели под размер текущего окна
///
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
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
      /*Position* pos = new Position(POSITION_STATUS_OPEN,
                                   POSITION_TYPE_BUY,
                                   12345,
                                   Symbol(),
                                   MathRand(),
                                   0.1,
                                   TimeCurrent(),
                                   1.20394,
                                   0, 0, str);
      EventCreateNewPos* createPos = new EventCreateNewPos(EVENT_FROM_UP, "HP API", pos);
      HedgePanel.Event(createPos);
      delete pos;
      delete createPos;
      */
   }
   //Определяем, является ли событие нажатием на одну из кнопок HP
   else if (id == CHARTEVENT_OBJECT_CLICK)
   {
      EventPush* pushObj = new EventPush(sparam);
      HedgePanel.Event(pushObj);
      delete pushObj;
   }
   ChartRedraw(MAIN_WINDOW);
}

