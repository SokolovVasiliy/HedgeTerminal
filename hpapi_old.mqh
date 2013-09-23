//+------------------------------------------------------------------+
//|                                                       hpanel.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2013, Vasiliy Sokolov, Hedge Panel�"
//#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Arrays\List.mqh>
//#include <hpfdef.mqh>
//
// ���������� � ������� �������� �������
//
class ActivePosition : CObject
{
   public:
      //����� ������
      ulong TicketEntry;
      //������� ����� �������
      double VolumeCurrent;
};

class HistoryPosition : CObject
{
   public:
      //����� ������ ���������������� �������.
      ulong TicketEntry;
      //����� ������ ����������� �������.
      ulong TicketExit;
      //����� �������
      double Volume;
};


class CHedge
{
   public:
                  CHedge(void);
      int         PositionsCount(void);                  // ���������� ���������� �������� �������.
      int         HistoryPositionsCount(void);           // ���������� ���������� ������������ �������.
      ulong       OrderGetTicketEntry(int index);        // ���������� ����� ��������� ������ �������� ������� � �������� index.
      ulong       HistoryOrderGetTicketEntry(int index); // ���������� ����� ��������� ������ ������������ ������� � �������� index.
      ulong       HistoryOrderGetTicketExit(int index);  // ���������� ����� ���������� ������ ������������ ������� � �������� indrx.
      bool        PositionClose(int index,               // ��������� �������� ������� ����������������� �������.
                                MqlTradeRequest &treq,
                                MqlTradeResult &trez); 
   private:
      string      Label;
      CList       ListActivePos;                         // ����������� ������ �������� �������.
      CList       ListHistoryPos;                        // ����������� ������ ������������ �������.
      
      ulong       IsHistoryEnterOrder(ulong ticket);    
      ulong       IsHistoryExitOrder(ulong ticket);
      bool        AddActivePos(ulong ticket);   
      
      ulong       FaeryMagic(ulong ticket);             // ���������� magic ����������������� ������.
      ulong       FaeryTicket(ulong magic);             // ���������� ticket ��������������� �������.
      void        LoadHistory();                         // ��������� ������� �������.   
};

//
// �����������
//
void CHedge::CHedge()
{
      Label = "HedgePanel�";
      Print(__FUNCTION__);
      // ����������� ������ ������������ ������, �.�. ��� ������� ������ �������� ����������� 
      // � �� �������� �������� �������.
      LoadHistory();
      //�������� ��� ������������ ������ � �������� � ������������
      int total = HistoryOrdersTotal();
      Print("�������� " + (string)total + " �������.");
      int i = 0;
      while(i < total)
      {
         LoadHistory();
         total = HistoryOrdersTotal();
         ulong ticket = HistoryOrderGetTicket(i);
         i++;
         if(ticket == 0)
         {
            Print("HedgePanel::CHedge: order with ticket #" + (string)ticket + " not find");
            continue;
         }
         //���� ������� ����� �� ����������� � ����������� � ����������� �������
         //������������ �������, ������ �� ����� �������� �������.
         if(IsHistoryEnterOrder(ticket) == 0 &&
            IsHistoryExitOrder(ticket) == 0)
         {
            AddActivePos(ticket);
         }
      }
      Print("�� ��� ��������: " + (string)ListActivePos.Total(), " �����������: " + (string)ListHistoryPos.Total());
}

///
/// ��������� ������� �������
///
void CHedge::LoadHistory(void)
{
   HistorySelect(D'1970.01.01', TimeCurrent());
}
//
// ��������� ������� ������� �������� �������� ��������� � ��������� treq.
// treq - ���������, ����������� ����������� �����.
// trez - ��������� ������ ����� ����������� ������������ ������.
// ������, ���� ����������� ����� �������� ����� � �������������� �������� �������.
//
bool CHedge::PositionClose(int index, MqlTradeRequest &treq, MqlTradeResult &trez)
{
   // 1. ������� ������ ������������
   if(ListActivePos.Total() <= index)
   {
      Print(Label + ": Position with index " + (string)index + " not find");
   }
   // 1. ����������� ������ ���� ��������������� ������������ ������.
   LoadHistory();
   ActivePosition *pos = ListActivePos.GetNodeAtIndex(index);
   if(!HistoryOrderSelect(pos.TicketEntry))
   {
      Print(Label + ": Error! ticket #" + pos.TicketEntry + " not find");
      return false;
   }
   int mode = (int)HistoryOrderGetInteger(pos.TicketEntry, ORDER_TYPE);
   //����������� ������� ������� (��� ����������������� ������ ����� ���� �����)
   int posdir = 0;
   switch(mode)
   {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_STOP_LIMIT:
         posdir = 1;
         break;
      default:
         posdir = -1;
         break;   
   }
   //����������� ������������ ������� (������ ���� ������� ���� ������� �� �����)
   int reqdir = 0;
   if(treq.type == ORDER_TYPE_BUY)
      reqdir = 1;
   else if(treq.type == ORDER_TYPE_SELL)
      reqdir = -1;
   if(reqdir == 0)
   {
      Print(Label + ": Pending orders are not supported");
      return false;
   }
   // ��� ����������� ������ ���� �������� �� �����
   if((posdir > 0 && reqdir > 0) ||
      (posdir <0 && reqdir < 0))
   {
      Print(Label + ": Error! Your request must be closing the opposite direction than the position.");
      return false;
   }
   // 2. ����� ������ ���� �� ������ ������ ����������� ������
   double vol_init = HistoryOrderGetDouble(pos.TicketEntry, ORDER_VOLUME_INITIAL);
   double vol_notinit = HistoryOrderGetDouble(pos.TicketEntry, ORDER_VOLUME_CURRENT);
   double vol_fact = vol_init - vol_notinit;
   double vol_req = treq.volume;
   ulong ticket = pos.TicketEntry;
   if(vol_fact < treq.volume)
   {
      Print(Label + ": Error! The volume of closing of the transaction must not be greater than the volume position.");
      return false;
   }
   // 3. ������ ������ �� ����������. ������ ����� ������������ ������ � ������� ��� � ������ ������������.
   treq.magic = FaeryMagic(pos.TicketEntry);
   bool res = OrderSend(treq, trez);
   //��������� �������� ������� � ������ ������������ �������.
   Print("Position close done! result = " + (string)res);
   if(res)
   {
      string posdirs = "none";
      string reqdirs = "none";
      if(posdir == 1)posdirs = "buy";
      else posdirs = "sell"; 
      if(reqdir == 1)reqdirs = "buy";
      else reqdirs = "sell"; 
      Print("Pos. " + posdirs + " #" + pos.TicketEntry + " with vol.: " + vol_fact + " was closed by order " + reqdirs + " #" + trez.order + " with vol.: " + trez.volume);
      //���� ������� ������� ���������, ������� �� �� ������ �������� �������
      if(vol_fact == trez.volume)
         ListActivePos.Delete(index);
      //�����, ���������� �� ������� ����� �� ����� ������
      else
         pos.VolumeCurrent = pos.VolumeCurrent - trez.volume;
      //������ ��������� �������� ������� � �������.
      HistoryPosition *hpos = new HistoryPosition();
      hpos.TicketEntry = pos.TicketEntry;
      hpos.TicketExit = trez.order;
      hpos.Volume = trez.volume;
      ListHistoryPos.Add(hpos);
   }
   return res;
}
//
// ���������� ����� ��������� ������ �������� ������� �� ������� index. 0 - ���� ����� ������� ���.
// index - ����� �������� ������� � ������ �������� �������.
//
ulong CHedge::OrderGetTicketEntry(int index)
{
   
   if(ListActivePos.Total() < index)
   {
      Print("HedgePanel: Position with #" + (string)index + " not find");
      return(0);
   }
   ActivePosition *pos = ListActivePos.GetNodeAtIndex(index);
   return(pos.TicketEntry);
}

//
// ���������� ����� ��������� ������ ������������ ������� � �������� index. 0 - ���� ����� ������� ���. 
// index - ����� ������������ �������.
//
ulong CHedge::HistoryOrderGetTicketEntry(int index)
{
   if(ListHistoryPos.Total() <= index)
   {
      Print("HedgePanel: History position with #" + (string)index + " not find");
      return(0);
   }
   HistoryPosition *pos = ListHistoryPos.GetNodeAtIndex(index);
   return(pos.TicketEntry);
}
//
// ���������� ����� ���������� ������ ������������ ������� � �������� index. 0 - ���� ����� ������� ���. 
// index - ����� ������������ �������.
//
ulong CHedge::HistoryOrderGetTicketExit(int index)
{
   if(ListHistoryPos.Total() < index)
   {
      Print("HedgePanel: History position with #" + (string)index + " not find");
      return(0);
   }
   HistoryPosition *pos = ListHistoryPos.GetNodeAtIndex(index);
   return(pos.TicketExit);
}
//
// ���������� ���������� �������� �������.
//
int CHedge::PositionsCount()
{
   return(ListActivePos.Total());
}

//
// ���������� ���������� ������������ �������.
//
int CHedge::HistoryPositionsCount(void)
{
   return(ListActivePos.Total());
}

//
// ����������, �������� �� ������� �����, ������� �������� ������������ �������.
// ���� ������� ����� �������� ������� �������� ������������ �������, ����������
// ����� ������ ������������ ������������ �������. � ��������� ������ ���������� 0.
//
ulong CHedge::IsHistoryEnterOrder(ulong ticket)
{   
   // ���� �� ������ �����, ��� Magic ����� ����� �������������� ������ �������� ������,
   // �� ������ ������� ����� �����������.
   
   //�������� magic ������� ��� ���� ����� �����
   ulong magic = FaeryMagic(ticket);
   // ������ ����������, ��� ������� ����� ��� �� ��� ������
   int tfind = ListHistoryPos.Total();
   for(int i = 0; i < tfind; i++)
   {
      HistoryPosition *pos = ListHistoryPos.GetNodeAtIndex(i);
      if(pos.TicketEntry == ticket)
      {
         return (pos.TicketExit);
      }
   }
   LoadHistory();
   int total = HistoryOrdersTotal();
   for(int i = 0; i < total; i++)
   {
      ulong currt = HistoryOrderGetTicket(i);
      if(currt == 0)
      {
         Print("HedgePanel: Order with ticket #" + (string)ticket + " not find.");
         return 0;
      }
      //����������� ����� ������, ������� ����� ����������� ������������ �������.
      if(magic == OrderGetInteger(ORDER_MAGIC))
      {
         HistoryPosition *pos = new HistoryPosition();
         pos.TicketEntry = ticket;
         pos.TicketExit = currt;
         int rez = ListHistoryPos.Add(pos);
         if(rez == -1)
            Print("HedgePanel: Error! History position with opened order #" + (string)ticket + " not added.");
         return currt;
      }
   }
   return 0;
}

//
// ����������, �������� �� ������� �����, ������� �������� ������������ �������.
// ���� ������� ����� �������� ������� �������� ������������ �������, ����������
// ����� ������ ������������ ������������ �������. � ��������� ������ ���������� 0.
//
ulong CHedge::IsHistoryExitOrder(ulong ticket)
{
   // ���� �� ������ �����, ��� ����� ����� ����� �������������� ������� �������� ������,
   // ������ ������� ����� �����������.
   LoadHistory();
   int total = HistoryOrdersTotal();
   if(!HistoryOrderSelect(ticket))return(0);
   //�������� �����, ������� ��� ���� ����� �����
   ulong fticket = FaeryTicket(OrderGetInteger(ORDER_MAGIC));
   // ������ ����������, ��� ������� ����� ��� �� ��� ������
   int tfind = ListHistoryPos.Total();
   for(int i = 0; i < tfind; i++)
   {
      HistoryPosition *pos = ListHistoryPos.GetNodeAtIndex(i);
      if(pos.TicketExit == ticket)
      {
         return (pos.TicketEntry);
      }
   }
   LoadHistory();
   //int total = HistoryOrdersTotal();
   for(int i = 0; i < total; i++)
   {
      ulong currt = HistoryOrderGetTicket(i);
      if(currt == 0)
      {
         Print("HedgePanel: Error! Order with ticket #" + (string)ticket + " not find.");
         return 0;
      }
      //����������� ����� ������, ������� ����� ����������� ������������ �������.
      if(fticket == currt)
      {
         HistoryPosition *pos = new HistoryPosition();
         pos.TicketEntry = fticket;
         pos.TicketExit = currt;
         int rez = ListHistoryPos.Add(pos);
         if(rez == -1)
            Print("HedgePanel: Error! History position with closed order #" + (string)ticket + " not added.");
         return currt;
      }
   }
   return 0;
}

//
// ��������� ����� ������� � ���������������� ������� c ������� 'ticket'.
//
bool CHedge::AddActivePos(ulong ticket)
{
   if(!HistoryOrderSelect(ticket))
   {
      Print("HedgePanel: Order with ticket #" + (string)ticket + " not find.");
      return(false);
   }
   ActivePosition *pos = new ActivePosition();
   pos.TicketEntry = ticket;
   int rez = ListActivePos.Add(pos);
   if(rez == -1)
   {
      Print("HedgePanel: Error! Active position with opened order #" + (string)ticket + " not added.");
      return (false);
   }
   return(true);
}


//
// ���������� magic ������������ ������. ���� - � ������ �������.
// ticket - ����� ����������������� ������.
//
ulong CHedge::FaeryMagic(ulong ticket)
{
   // ����������� ������ ����������� ������ �������� � �������, ������ ��� � ����������,
   // �������� ������� �� ����� ���� ������������ ������.
   if(!HistoryOrderSelect(ticket))
   {
      Print("HedgePanel: Order with ticket #" +(string)ticket + " not find");
      return 0;
   }
   return ticket;
}


//
// ���������� ����� ������������ ������, ������� ������ ������������, ���� �������
// ����� �������� �����������. ���� - � ������ �������.
// ticket - ����� �������� ������.
//
ulong CHedge::FaeryTicket(ulong ticket)
{
   // ����������� ������ ����������� ������ �������� � �������, ������ ��� ���� � �������� ������
   // ���� ����������� �����, �� �� ��� �������� � ����� � �������.
   if(!HistoryOrderSelect(ticket))
   {
      return 0;
   }
   return OrderGetInteger(ORDER_MAGIC);
}

//
// ����� �������.
//
CHedge Positions;

//
// ���������� ���������� �������� �������.
//
int PositionsCount() export
{
   return(Positions.HistoryPositionsCount());
}
//
// ���������� ���������� ������������ �������. 
//
int HistoryPositionsCount() export
{
   return (Positions.HistoryPositionsCount());
}

//
// ���������� ����� ����������������� ������ �������� �������. 0 - ���� ����� ������� ��� ����� �� ���� �������.
// index - ����� �������� ������� � ������ �������� �������.
//
ulong OrderGetTicketEntry(int index) export
{
   return(Positions.OrderGetTicketEntry(index));
}

//
// �������� ���������������� ����� ������������ �������.
// index - ����� ������������ ������� � ������ ������������ �������.
//
ulong HistoryOrderGetTicketEntry(int index) export
{
   return(Positions.HistoryOrderGetTicketEntry(index));
}

//
// �������� ����������� ����� ������������ �������.
// index - ����� ������������ ������� � ������ ������������ �������.
//
ulong HistoryOrderGetTicketExit(int index) export
{
   return(Positions.HistoryOrderGetTicketExit(index));
}
//
// ��������� �������� ������� � �������� index �������� �������� ��������� ���������� MqlTradeRequest
// treq - �������� ������, ����������� ������� �������� ������� �������.
// trez - ��������� ���������� ��������� �������
// ������, ���� �������� ������ ��� ��������, ����, ���� ������ ��� �������� �����������.
bool PositionClose(int index, MqlTradeRequest &treq, MqlTradeResult &trez) export
{
   bool rez = Positions.PositionClose(index, treq, trez);
   return(rez);
}



