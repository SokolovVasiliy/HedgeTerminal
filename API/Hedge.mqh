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
            case EVENT_ADD_DEAL:
               OnAddDeal(event);
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
         listOrders.Sort(SORT_ORDER_ID);
         ActivePos.Sort(SORT_ORDER_ID);
         HistoryPos.Sort(SORT_ORDER_ID);
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
         ulong id = event.PositionId();
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
      void OnAddDeal(EventAddDeal* event)
      {
         COrder* order = CreateOrder(event.DealID());
         // ����������� ������?
         if(order.Direction() == ORDER_OUT)
         {
            COrder* in_order = order.InOrder();
            Position* pos = new Position(in_order.OrderId(), in_order.Deals(), order.OrderId(), order.Deals());
            // ������ ��������� �������� �������?
            int aindex = ActivePos.Search(pos);
            
            //��� ������ ����������� ����� �������������� ������������ ������?
            int index = HistoryPos.Search(pos);
            //��? - ����� ������ ����������� � ��� ������������ ������������ �������.
            if(index != -1)
            {
               //delete pos;
               Position* hpos = HistoryPos.At(index);
               // � ���� ������ ��������� ���������� �������� �����, ������� ��������� ��� ������
               // (�������� ��� ���������).
               //ActivePos.Search(pos);
               
            }
            //���? - ����� ������� ����� ������������ �������.
            else
            {
               HistoryPos.InsertSort(pos);
            }
            Deal* deal = new Deal(event.DealID());
            pos.AddExitDeal(deal);
            // ��������� ����������� � ������� � ������������
            EventRefreshPos* refresh_pos = new EventRefreshPos(pos);
            EventExchange::PushEvent(refresh_pos);
            delete event;
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
            //������� �����, � �������� ����������� ������.
            CreateOrder(ticket);
         }
         //������, ����� ������ ������� �����, �� ����� ������� ������ ������� �� �� ������.
         total = listOrders.Total();
         for(int i = 0; i < total; i++)
         {
            COrder* in_order = listOrders.At(i);
            COrder* out_order = in_order.OutOrder();
            Position* pos = NULL;
            //ulong out_id = out_order.OrderId();
            if(CheckPointer(in_order.InOrder()) != POINTER_INVALID)
               continue;
            if(CheckPointer(out_order) == POINTER_INVALID)
            {
               pos = new Position(in_order.OrderId(), in_order.Deals());
               ActivePos.InsertSort(pos);
            }
            else
            {
               pos = new Position(in_order.OrderId(), in_order.Deals(), out_order.OrderId(), out_order.Deals());
               ulong dMagic = out_order.Magic();
               ulong exMagic = pos.ExitMagic();
               HistoryPos.InsertSort(pos);
            }
            EventCreatePos* create_pos = new EventCreatePos(EVENT_FROM_UP, "HP API", pos);
            EventExchange::PushEvent(create_pos);
            delete create_pos;
         }
      }
      ///
      /// ������� ����� �� ������ �������������� ������.
      ///
      COrder* CreateOrder(ulong ticket)
      {
         ulong order_id;
         LoadHistory();
         if(!HistoryDealGetInteger(ticket, DEAL_ORDER, order_id))return NULL;
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
         return order;
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