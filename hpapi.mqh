#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
#include "position.mqh"
#include "events.mqh"
///
/// ����� �������
///
class CHedge
{
   public:
      ///
      /// ��������� �������
      ///
      void Event(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_TIMER:
               OnTimer(event);
               break;
         }
      }
      ///
      ///
      ///
      CHedge()
      {
         ListTickets = new CArrayLong();
         ActivePos = new CArrayObj();
         HistoryPos = new CArrayObj();
         LoadHistory();
         //������� ��� ��������� ������ � ������ �������
         LoadHistory();
         int total = HistoryOrdersTotal();
         for(int i = 0; i < total; i++)
            ListTickets.Add(HistoryOrderGetTicket(i));
         total = OrdersTotal();
         for(int i = 0; i < total; i++)
            ListTickets.Add(OrderGetTicket(i));
         //���������� ������ � �������� � ��������
         total = ListTickets.Total();
         Position* pos = NULL;
         for(int i = 0; i < total; i++)
         {
            ulong ticket1 = ListTickets.At(i);
            for(int k = 0; k < total; k++)
            {
               if(k == i)continue;
               ulong ticket2 = ListTickets.At(i);
               // ticket2 �������� ����������� ������� ticket1?
               if(ticket2 == FaeryMagic(ticket1))
               {
                  pos = new Position(ticket1, ticket2);
               }
               //ticket1 �������� ����������� ������� ticket2
               if(ticket1 == FaeryMagic(ticket2))
               {
                  pos = new Position(ticket2, ticket1);
               }
            }
            //���� ����������� ����� �� ������, �� ��� - �������� �������.
            pos = new Position(ticket1);
         }
         if(pos == NULL)return;
         if(pos.Status() == POSITION_STATUS_OPEN)
            ActivePos.Add(pos);
         else
            HistoryPos.Add(pos);
      }
      ///
      /// ��������� ����� ������� � ������ �������
      ///
      void AddNewPos(ulong ticket)
      {
         //ListTickets;
      }
      ///
      /// ���������� ���������� �������� �������
      ///
      int ActivePosTotal()
      {
         return ActivePos.Total();
      }
      ///
      /// ���������� �������� ������� ��� ������� n �� ������ �������.
      ///
      Position* ActivePosAt(int n)
      {
         Position* pos = ActivePos.At(n);
         return pos;
      }
   private:
      ///
      /// ������������ ���������� �������
      ///
      void OnTimer(EventTimer* event)
      {
         int total = ActivePos.Total();
         for(int i = 0; i < total; i++)
            EventChartCustom(MAIN_WINDOW, EVENT_CHANGE_POS, i, 0, "");
      }
      //
      // ���������� magic ������������ ������. ���� - � ������ �������.
      // ticket - ����� ����������������� ������.
      //
      ulong FaeryMagic(ulong ticket)
      {
         // ����������� ������ ����������� ������ �������� � �������, ������ ��� � ����������,
         // �������� ������� �� ����� ���� ������������ ������.
         
         /*if(!HistoryOrderSelect(ticket))
         {
            Print("HedgePanel: Order with ticket #" +(string)ticket + " not find");
            return 0;
         }*/
         return ticket;
      }
      ///
      /// ��������� ������� �������
      ///
      void LoadHistory(void)
      {
         HistorySelect(D'1970.01.01', TimeCurrent());
      }
      ///
      /// ������ �������� �������.
      ///
      CArrayObj* ActivePos;
      ///
      /// ������ ������������, �������� �������.
      ///
      CArrayObj* HistoryPos;
      ///
      /// ������ ������� ���� �������.
      ///
      CArrayLong* ListTickets;
};