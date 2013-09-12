//+------------------------------------------------------------------+
//|                                                      HedgePanel© |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+

#property copyright   "2013, , Vasiliy Sokolov, St.Petersburg, Russia."
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.001"

#include "Log.mqh"
#include "hpgui.mqh"
#include "gelements.mqh"

///
/// Скорость обновления панели
///
input int RefreshRate = 1;


MainForm* HedgePanel;
//Table TableOfOpenPos("op", GetPointer(form));

///
/// Инициализирующая функция.
///
void OnInit(void)
{
   Print("Инициализация советника");
   // Инициализируем систему логирования.
   EventSetTimer(RefreshRate);
   HedgePanel = new MainForm();
   long X;     // Текущая ширина окна индикатора
   long Y;     // Текущая высота окна индикатора
   X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
   Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
   EventInit* ei = new EventInit();
   HedgePanel.Event(ei);
   delete ei;
}
void OnDeinit(const int reason)
{
   EventDeinit* ed = new EventDeinit();
   HedgePanel.Event(ed);
   delete ed;
   delete HedgePanel;
   EventKillTimer();
}

///
/// Вызывает логику эксперта с определенной периодичностью.
///
void OnTimer(void)
{
   //Print(TERMINAL_NAME);
}
///
/// Подстраиваем размер главной формы панели под размер текущего окна
///
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   //Размеры базового окна изменились.
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      long X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
      long Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
      Print("Получены новые размеры окна X:" + (string)X + " Y:" + (string)Y);
      //EventResize* er = new EventResize(EVENT_FROM_UP, "TERMINAL_WINDOW", X, Y);
      EventNodeStatus* er = new EventNodeStatus(EVENT_FROM_UP, "TERMINAL WINDOW", true, 0, 0, X, Y);
      HedgePanel.Event(er);
      delete er;
   }
}