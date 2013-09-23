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
#include "gelements.mqh"
#include "hpapi.mqh"

///
/// �������� ���������� ������
///
input int RefreshRate = 5;
CHedge hedge;

MainForm* HedgePanel;
//Table TableOfOpenPos("op", GetPointer(form));

///
/// ���������������� �������.
///
void OnInit(void)
{
   Print("������������� ���������");
   // �������������� ������� �����������.
   EventSetTimer(RefreshRate);
   HedgePanel = new MainForm();
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
/// �������� ������ �������� � ������������ ��������������.
///
void OnTimer(void)
{
   EventTimer* et = new EventTimer(RefreshRate);
   hedge.Event(et);
   delete et;
}
///
/// ������������ ������ ������� ����� ������ ��� ������ �������� ����
///
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   //������� �������� ���� ����������.
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      long X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
      long Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
      string str = "X: " + (string)X + " Y:" + (string)Y;
      Print("�������� ����� ������� ���� X:" + (string)X + " Y:" + (string)Y);
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
   if(id == CHARTEVENT_CUSTOM+EVENT_CHANGE_POS)
   {
      Position* pos = hedge.ActivePosAt((int)lparam);
      EventChangeStatePos* changePos = new EventChangeStatePos(EVENT_FROM_UP, "HP API", pos);
      HedgePanel.Event(changePos);
      delete changePos;
   }
}
