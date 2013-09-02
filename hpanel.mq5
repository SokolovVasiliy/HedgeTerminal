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
/// Центральная панель
///
Panel myPanel;

///
/// Инициализирует HedgePanel
///
void OnInit(void)
{
   EventSetTimer(RefreshRate);
   Print("Инициализация...");
   myPanel.Init();
}

///
/// Деинициализирует HedgePanel
///
void OnDeinit(const int reason)
{
   LogWriter("Deinit HedgePanel©. Reason id: " + (string)reason, L2);
   myPanel.Deinit();
   EventKillTimer();
}
///
/// Вызывает логику эксперта с определенной периодичностью.
///
void OnTimer(void)
{
   
}