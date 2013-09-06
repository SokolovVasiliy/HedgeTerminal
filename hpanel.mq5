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
#include "gnode.mqh"

///
/// �������� ���������� ������
///
input int RefreshRate = 1;


MainForm form;

///
/// ���������������� �������.
///
void OnInit(void)
{
   Print("������������� ���������");
   // �������������� ������� �����������.
   EventSetTimer(RefreshRate);
   long X;     // ������� ������ ���� ����������
   long Y;     // ������� ������ ���� ����������
   X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
   Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
   form.Event(new EventResize(EVENT_FROM_UP, "TERMINAL_WINDOW", X, Y));
   form.Event(new EventVisible(EVENT_FROM_UP, "TERMINAL_WINDOW", true));
   //for(char ch = 0; ch < 256; ch++)
   //   Print(ch + " - " + CharToString(ch));
}

///
/// ���������������� HedgePanel
///
void OnDeinit(const int reason)
{
   EventKillTimer();
}
///
/// �������� ������ �������� � ������������ ��������������.
///
void OnTimer(void)
{
   //Print(TERMINAL_NAME);
}
///
/// ������������ ������ ������� ����� ������ ��� ������ �������� ����
///
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   long X;     // ������� ������ ���� ����������
   long Y;     // ������� ������ ���� ����������
   switch(id)
   {
      case CHARTEVENT_CHART_CHANGE:
         X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
         Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
         Print("�������� ����� ������� ����: " + (string)X + ":" + (string)Y);
         //PanelForm.Resize(X, Y);
         form.Event(new EventResize(EVENT_FROM_UP, "TERMINAL_WINDOW", X, Y));
   }
}