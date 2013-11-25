#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Order.mqh"

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
            //������������ ������ �� �������� �������.
            case EVENT_CLOSE_POS:
               OnClosePos(event);
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
      }
      
      ~CHedge()
      {
         // ������� ������ �������
         ListTickets.Clear();
         delete ListTickets;
         // ������� ������ �������� �������.
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            delete pos;
         }
         ActivePos.Clear();
         delete ActivePos;
         // ������� ������ ������������ �������.
         for(int i = 0; i < HistoryPos.Total(); i++)
         {
            Position* pos = HistoryPos.At(i);
            delete pos;
         }
         HistoryPos.Clear();
         delete HistoryPos;
         
         //listOrder
      }
      
      void Init()
      {
         LoadPosition();
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
      /// ������������ ������� �������� �������
      ///
      void OnClosePos(EventClosePos* event)
      {
         int id = event.PositionId();
         string comment = event.CloseComment();
         //������� ������� ������� ���������� ������� �� �� ����������� id.
         for(int i = 0; ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            if(pos.EntryOrderID() == id)
            {
               pos.AsynchClose(comment);
               break;
            }
         }
      }
      ///
      /// ������������ ���������� �������
      ///
      void OnTimer(EventTimer* event)
      {
         ;
      }
      ///
      /// ��� ��������������
      ///
      enum ENYM_REGIM_CONV
      {
         ///
         /// 
         ///
         MAGIC_TO_TICKET,
         ///
         ///
         ///
         TICKET_TO_MAGIC
      };
      ///
      /// ����������� magic ����� ����������� ������� � ����� ����������, ����
      /// ����� ������������ � magic �����������.
      ///
      ulong FaeryMagic(ulong value, ENYM_REGIM_CONV)
      {
         ///
         ///
         ///        
         return value;
      }
      ///
      /// ��������� ������� �������
      ///
      void LoadHistory(void)
      {
         HistorySelect(D'1970.01.01', TimeCurrent());
      }
      
      ///
      /// ������� ������� �� ������������ ������ � �������.
      ///
      void LoadPosition()
      {
         LoadHistory();
         int total = HistoryDealsTotal();
         ulong prev_order = -1;
         CArrayObj listOrders;
         listOrders.Sort(1);
         //���������� ��� ��������� ������ � ��������� �� �� ������ ��������� ������� ������� ���� COrder
         for(int i = 0; i < total; i++)
         {  
            // ������� �����, ���������� ������.
            LoadHistory();
            ulong ticket = HistoryDealGetTicket(i);
            HistoryDealSelect(ticket);
            if(ticket == 0)continue;
            
            //��������� ������ �������� ��������
            ENUM_DEAL_TYPE op_type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
            if(op_type != DEAL_TYPE_BUY && op_type != DEAL_TYPE_SELL)
               continue;
            //������� ����� ������, ������������ ������
            ulong order_id;
            if(!HistoryDealGetInteger(ticket, DEAL_ORDER, order_id))continue;
            
            COrder* order = new COrder(order_id);
            order.AddDeal(ticket);
            int pos = listOrders.Search(order);
            // � ������ ������� ��� ���� ����� �����?
            if(pos != -1)
            {
               delete order;
               order = listOrders.At(pos);
            }
            //���� ���, ������� �����
            else
               listOrders.InsertSort(order);
         }
         //�� ������ ������ ������� �������� �������.
         MergeOrders(GetPointer(listOrders));
         /*total = listOrders.Total();
         for(int i = 0; i < total; i++)
         {
            Position* npos = NULL;
            COrder* order = listOrders.At(i);
            ulong id = order.OrderId();
            // ���� ����� �����������, �� �� ��������� ����� � ���� �������.
            ulong open_ticket = FaeryMagic(order.Magic(), MAGIC_TO_TICKET);
            // ���� ����� �����������, �� ��� ����������� ������� ����� ����� ������������ � ���� �������:
            ulong close_magic = FaeryMagic(order.OrderId(), TICKET_TO_MAGIC);
            int pos = -1;
            //���� ����� ����� ������������ - ���� ����� � ���� �������.
            if(open_ticket != -1)
            {
               COrder* sorder = new COrder(open_ticket);
               pos = listOrders.Search(sorder);
               //����������� ����� ������? - ������� ������������ �������.
               if(pos != -1)
               {
                  COrder* in_order = listOrders.At(pos);
                  npos = new Position(in_order.OrderId(), in_order.Deals(), order.OrderId(), order.Deals());
                  HistoryPos.Add(npos);     
               }
               delete sorder;
            }
            if(close_magic != -1)
            {
               COrder* sorder = new COrder(close_magic);
               pos = listOrders.Search(sorder);
               //����������� ����� ������? - ������� ������������ �������.
               if(pos != -1)
               {
                  COrder* out_order = listOrders.At(pos);
                  npos = new Position(order.OrderId(), order.Deals(), out_order.OrderId(), out_order.Deals());
                  HistoryPos.Add(npos);     
               }
               delete sorder;
            }
            //����������� ����� �� ������? - ������ ��� �������� �������
            if(close_magic == -1 || pos == -1)
            {
               npos = new Position(order.OrderId(), order.Deals());
               ActivePos.Add(npos);
            }
            //���������� � �������� ����� �������
            if(npos != NULL)
            {
               EventCreatePos* create_pos = new EventCreatePos(EVENT_FROM_UP, "HP API", npos);
               EventExchange::PushEvent(create_pos);
               delete create_pos;
            }
         }*/
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            EventCreatePos* create_pos = new EventCreatePos(EVENT_FROM_UP, "HP API", pos);
            EventExchange::PushEvent(create_pos);
            delete create_pos;
         }
         for(int i = 0; i < HistoryPos.Total(); i++)
         {
            Position* pos = HistoryPos.At(i);
            EventCreatePos* create_pos = new EventCreatePos(EVENT_FROM_UP, "HP API", pos);
            EventExchange::PushEvent(create_pos);
            delete create_pos;
         }
      }
      ///
      /// ������� �� ������ ������� �������. 
      ///
      void MergeOrders(CArrayObj* listOrders)
      {
         int total = listOrders.Total();
         for(int i = 0; i < total; i++)
         {
            COrder* order = listOrders.At(i);
            // ���� ����� �����������, �� �� ��������� ����� � ���� �������.
            ulong open_ticket = FaeryMagic(order.Magic(), MAGIC_TO_TICKET);
            int index = -1;
            if(open_ticket > 0)
            {
               COrder* sorder = new COrder(open_ticket);
               index = listOrders.Search(sorder);
               //����������� ����� ������? - ������� ������������ �������.
               if(index != -1)
               {
                  //���� ����������� ������ ����� ���������� ��� ������ �� ��������,
                  //������� �� ������������������ ���� ������� �� �����������.
                  for(int p = index; p < listPos.Total(); p++)
                  {
                     Position* entry_pos = listPos.At(p);
                     if(entry_pos.EntryOrderID() != open_ticket)continue;
                     listPos.Delete(p);
                     COrder* in_order = listOrders.At(p);
                     Position* close_pos = new Position(in_order.OrderId(), in_order.Deals(), order.OrderId(), order.Deals());
                     listPos.Add(close_pos);
                     break;
                  }
               }
            }
            //������� �������� �������.
            if(open_ticket <= 0 || index == -1)
            {
               Position* pos = new Position(order.OrderId(), order.Deals());
               listPos.Add(pos);
            }
         }
         //������, ����� ��� ������� �������, �������� �� �� ������ �������
         total = listPos.Total();
         for(int i = 0; i < total; i++)
         {
            Position* pos = listPos.At(i);
            if(pos.PositionStatus() == POSITION_STATUS_OPEN)
               ActivePos.Add(pos);
            if(pos.PositionStatus() == POSITION_STATUS_CLOSED)
               HistoryPos.Add(pos);
         }
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
      ///
      /// ������ ���� �������.
      ///
      CArrayObj listPos;

};