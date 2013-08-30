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

///
/// Скорость обновления панели
///
input int RefreshRate = 1;

///
/// Инициализирует HedgePanel
///
void OnInit(void)
{
   EventSetTimer(RefreshRate);
}

///
/// Деинициализирует HedgePanel
///
void OnDeinit(const int reason)
{
   LogWriter("Deinit HedgePanel©. Reason id: " + reason, L2);
   EventKillTimer();
}
///
/// Вызывает логику эксперта с определенной периодичностью.
///
void OnTimer(void)
{
   
}