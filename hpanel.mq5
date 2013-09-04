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

///
/// Скорость обновления панели
///
input int RefreshRate = 1;

///
/// Центральная форма панели.
///
GeneralForm PanelForm;

///
/// Инициализирующая функция.
///
void OnInit(void)
{
   Print("Инициализация советника");
   // Инициализируем систему логирования.
   EventSetTimer(RefreshRate);
   long X;     // Текущая ширина окна индикатора
   long Y;     // Текущая высота окна индикатора
   X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
   Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
   PanelForm.Resize(X, Y);
   //PanelForm.SetVisible(true);
}

///
/// Деинициализирует HedgePanel
///
void OnDeinit(const int reason)
{
   EventKillTimer();
}
///
/// Вызывает логику эксперта с определенной периодичностью.
///
void OnTimer(void)
{
   
}
///
/// Подстраиваем размер главной формы панели под размер текущего окна
///
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   long X;     // Текущая ширина окна индикатора
   long Y;     // Текущая высота окна индикатора
   switch(id)
   {
      case CHARTEVENT_CHART_CHANGE:
         X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
         Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
         Print("Получены новые размеры окна: " + (string)X + ":" + (string)Y);
         PanelForm.Resize(X, Y); 
   }
}