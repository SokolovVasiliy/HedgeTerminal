//+------------------------------------------------------------------+
//|                                                      HedgePanel� |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+
#define NEW_TABLE
#property copyright  "2013-2014, Vasiliy Sokolov, St.Petersburg, Russia."
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.00"

///
/// ���������� ���������������� ������ ���������.
///
#define DEMO
///
/// ���������� ���������� ������ ���������.
///
#define HEDGE_PANEL
///
/// ���������� ����� ������. (����� ����������� �������� ������).
///
#define RELEASE

#include  "Globals.mqh"
///
/// �������� ���������� ������
///
input string SettingsPath = "Settings.xml"; //Name of file with settings.

bool detect;
int rdetect;
HedgeManager* api;
MainForm* HedgePanel;
/// ��������� ���������� ���������.
/// TablePositions* tableHistory;
///
/// ���������������� �������.
///
void OnInit(void)
{  
   CheckMe();
   if(Resources.Failed())
      return;
   uint rRate = Settings.GetRefreshRates();
   if(rRate < 30)
      rRate = 200;
   EventSetMillisecondTimer(rRate);
   HedgePanel = new MainForm();
   EventExchange.Add(HedgePanel);
   EventRefresh* refresh = new EventRefresh(EVENT_FROM_UP, "TERMINAL REFRESH");
   HedgePanel.Event(refresh);
   delete refresh;
   api = new HedgeManager();
   EventExchange.Add(api);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   /*if(detect)
   {
      MessageBox("Demo account is too old. The demonstration ended. Open a new demo account, or purchase the full retail version.");
      ExpertRemove();
   }*/
}

void OnDeinit(const int reason)
{
   if(CheckPointer(HedgePanel) != POINTER_INVALID)
   {
      EventDeinit* ed = new EventDeinit();
      HedgePanel.Event(ed);
      delete ed;
      delete HedgePanel;
   }
   if(CheckPointer(api) != POINTER_INVALID)
      delete api;
   EventKillTimer();
   
}

///
/// �������� ������ �������� � ������������ ��������������.
///
void OnTimer(void)
{
   EventRefresh* refresh = new EventRefresh(EVENT_FROM_UP, "TERMINAL REFRESH");
   api.Event(refresh);
   HedgePanel.Event(refresh);
   delete refresh;
   ChartRedraw(MAIN_WINDOW);
   #ifdef DEMO
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE) != ACCOUNT_TRADE_MODE_DEMO && rdetect++==0)
   {
      string str = "Can only be shown on a demo account. Purchase a full-featured version, or use a demo account. ";
      LogWriter(str, MESSAGE_TYPE_INFO);
      MessageBox(str, VERSION);
      ExpertRemove();
   }
   #endif
}

void  OnTradeTransaction(
      const MqlTradeTransaction&    trans,
      const MqlTradeRequest&        request,
      const MqlTradeResult&         result
   )
{
   
   EventRequestNotice* event_request = new EventRequestNotice(trans, request, result);
   //printf("request id: " + (string)result.request_id + "   " + EnumToString(trans.type) + " " +
   //(string)result.retcode + " magic: " + (string)request.magic + " order: " + (string)request.order +
   //" res order: " + (string)trans.order + debug);
   api.Event(event_request);
   delete event_request;
}
int chartEventCount;
///
/// ������������ ������ ������� ����� ������ ��� ������ �������� ����
///
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   chartEventCount++;
   //printf(id);
   //���������� ���� ��� ���������� ������� ������ ���� ����������.
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mask = (int)StringToInteger(sparam);
      EventMouseMove* move = new EventMouseMove(lparam, (long)dparam, mask);
      
      //if(move.PushedLeftButton())
      //   printf("X:" + move.XCoord() + " Y:" + move.YCoord());
      HedgePanel.Event(move);
      delete move;
      return;
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
      //printf("Key press: " + key.Code());
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

void CheckMe()
{
   int s = 0;
   #ifndef DEMO
   detect = false;
   #else
   HistorySelect(0, TimeCurrent());
   if(HistoryDealsTotal() > 0)
   {
      ulong id = HistoryDealGetTicket(0);
      datetime t = (datetime)HistoryDealGetInteger(id, DEAL_TIME);
      if(TimeCurrent() - t > (DEMO_PERIOD+1)*86400)
         detect = true;
   }
   if(HistoryOrdersTotal() > 0)
   {
      ulong id = HistoryOrderGetTicket(0);
      datetime t = (datetime)HistoryOrderGetInteger(id, ORDER_TIME_SETUP);
      if(TimeCurrent() - t > (DEMO_PERIOD+1)*86400)
         detect = true;
   }
   srand((uint)TimeCurrent());
   while(s < 5 && HistoryDealsTotal())
   {
      int index = rand()%HistoryDealsTotal();
      ulong id = HistoryOrderGetTicket(index);
      datetime t = (datetime)HistoryOrderGetInteger(id, ORDER_TIME_SETUP);
      if(TimeCurrent() - t > (DEMO_PERIOD+1)*86400)
         detect = true;
      s++;
   }
   
   #endif
}
