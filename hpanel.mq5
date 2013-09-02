//+------------------------------------------------------------------+
//|                                                      HedgePanel� |
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
/// �������� ���������� ������
///
input int RefreshRate = 1;
///
/// ����������� ������
///
Panel myPanel;

///
/// �������������� HedgePanel
///
void OnInit(void)
{
   EventSetTimer(RefreshRate);
   Print("�������������...");
   myPanel.Init();
}

///
/// ���������������� HedgePanel
///
void OnDeinit(const int reason)
{
   LogWriter("Deinit HedgePanel�. Reason id: " + (string)reason, L2);
   myPanel.Deinit();
   EventKillTimer();
}
///
/// �������� ������ �������� � ������������ ��������������.
///
void OnTimer(void)
{
   
}