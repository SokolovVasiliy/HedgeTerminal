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
         listOrders.Clear();
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
      /// ������������ ����� ������. ���������
      ///
      void AddNewDeal(ulong ticket)
      {
         
         //listOrders.Search();
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
      /// ������� �� ������ ������� �������. 
      ///
      void LoadPosition()
      {
         LoadHistory();
         int total = HistoryDealsTotal();
         //ulong prev_order = -1;
         listOrders.Sort(SORT_ORDER_ID);
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
            //ulong order_id;
            //if(!HistoryDealGetInteger(ticket, DEAL_ORDER, order_id))continue;
            CreateOrder(ticket);
         }
         //������, ����� ������ ������� �����, �� ����� ������� ������ ������� �� �� ������.
         total = listOrders.Total();
         for(int i = 0; i < total; i++)
         {
            COrder* in_order = listOrders.At(i);
            int dbg = 4;
            if(in_order.OrderId() == 1006304669)
               dbg = 3;
            COrder* out_order = in_order.OutOrder();
            Position* pos = NULL;
            //ulong out_id = out_order.OrderId();
            if(CheckPointer(in_order.InOrder()) != POINTER_INVALID)
               continue;
            if(CheckPointer(out_order) == POINTER_INVALID)
            {
               pos = new Position(in_order.OrderId(), in_order.Deals());
               ActivePos.Add(pos);
            }
            else
            {
               pos = new Position(in_order.OrderId(), in_order.Deals(), out_order.OrderId(), out_order.Deals());
               ulong dMagic = out_order.Magic();
               ulong exMagic = pos.ExitMagic();
               HistoryPos.Add(pos);
            }
            EventCreatePos* create_pos = new EventCreatePos(EVENT_FROM_UP, "HP API", pos);
            EventExchange::PushEvent(create_pos);
            delete create_pos;
         }
      }
      ///
      /// ������� ����� �� ������ �������������� ������.
      ///
      void CreateOrder(ulong ticket)
      {
         ulong order_id;
         LoadHistory();
         if(!HistoryDealGetInteger(ticket, DEAL_ORDER, order_id))return;
         int dbg = 4;
         if(order_id == 1008611488)
            dbg = 5;
         //LoadHistory();
         COrder* order = new COrder(order_id);
         
         //���� ����� ��� � ������, �� �������� ��������� ��� �� ����.
         int el = listOrders.Search(order);
         if(el != -1)
         {
            delete order;
            order = listOrders.At(el);
         }
         else
            listOrders.InsertSort(order);
         order.AddDeal(ticket);
         //������� ����� ����� ���� ���� ����������� ���� �����������.
         //���� ��� ����������� ����� � ���� ������ ���� ����������� �����
         //����� �� ��� ����� �����������.
         ulong in_ticket = el != -1 ? 0 : FaeryMagic(order.Magic(), MAGIC_TO_TICKET);
         //�������� ����� ����������� ����� �� ��� ������
         if(in_ticket > 0)
         {
            COrder* in_order = new COrder(in_ticket);
            int index = listOrders.Search(in_order);
            delete in_order;
            //����� ��� ���� � ����� ������?
            if(index != -1)
               in_order = listOrders.At(index);
            //�������� �� ��� �� ����� � ������.
            //����� ���� ����� � �� � ������� ����� ����� �� ��� ������.
            else
            {
               LoadHistory();
               //����������� ����� ���� � ����?
               if(HistoryOrderSelect(in_ticket))
               {
                  in_order = new COrder(in_ticket);
                  listOrders.Add(in_order);
               }
            }
            //����������� ����� ������
            if(CheckPointer(in_order) != POINTER_INVALID)
            {
               in_order.OutOrder(order);
               order.InOrder(in_order);
            }
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
      ///
      /// ������ ������� � �� ������.
      ///
      CArrayObj listOrders;

};