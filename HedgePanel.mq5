//+------------------------------------------------------------------+
//|                                                      HedgePanel� |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+

#property copyright  "2013, , Vasiliy Sokolov, St.Petersburg, Russia."
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.100"

#include  "Globals.mqh"

///
/// �������� ���������� ������
///
input int RefreshRate = 200;

CHedge* api;
MainForm* HedgePanel;


///
/// ���������������� �������.
///
void OnInit(void)
{  
   //Settings* set = Settings::GetSettings1();
   Settings = PanelSettings::Init();
   EventSetMillisecondTimer(RefreshRate);
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
   //printf("HedgePanelSize: " + (string)size);
   EventDeinit* ed = new EventDeinit();
   HedgePanel.Event(ed);
   api.Event(ed);
   delete ed;
   delete HedgePanel;
   delete api;
   EventKillTimer();
   delete Settings;
}

///
/// �������� ������ �������� � ������������ ��������������.
///
void OnTimer(void)
{
   EventRefresh* refresh = new EventRefresh(EVENT_FROM_UP, "TERMINAL REFRESH");
   EventExchange::PushEvent(refresh);
   delete refresh;
   ChartRedraw(MAIN_WINDOW);
   
   //������������� ��������� ��������� (������ ��� �������� ����)
   /*long X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
   long Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
   string str = "X: " + (string)X + " Y:" + (string)Y;
   //Print("�������� ����� ������� ���� X:" + (string)X + " Y:" + (string)Y);
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
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      EventAddDeal* deal = new EventAddDeal(trans.deal);  
      api.Event(deal);
      delete deal;
   }
}
///
/// ������������ ������ ������� ����� ������ ��� ������ �������� ����
///
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   //���������� ���� ��� ���������� ������� ������ ���� ����������.
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mask = (int)StringToInteger(sparam);
      EventMouseMove* move = new EventMouseMove(lparam, (long)dparam, mask);
      HedgePanel.Event(move);
      delete move;
   }
   //������� �������� ���� ����������.
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      long X = ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW);
      long Y = ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW);
      string str = "X: " + (string)X + " Y:" + (string)Y;
      //Print("�������� ����� ������� ���� X:" + (string)X + " Y:" + (string)Y);
      EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, "TERMINAL WINDOW", true, 0, 0, X, Y);
      HedgePanel.Event(command);
      delete command;
      
   }
   //����������, �������� �� ������� �������� �� ���� �� ������ HP
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      EventObjectClick* pushObj = new EventObjectClick(sparam);
      HedgePanel.Event(pushObj);
      delete pushObj;
   }
   //������ ������.
   if(id == CHARTEVENT_KEYDOWN)
   {
      int mask = (int)StringToInteger(sparam);
      EventKeyDown* key = new EventKeyDown((int)lparam, mask);
      HedgePanel.Event(key);
      delete key;
   }
   ChartRedraw(MAIN_WINDOW);
}

