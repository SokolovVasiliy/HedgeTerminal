#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
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
            case EVENT_DEINIT:
               //OnDeinit(event);
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
         total = listOrders.Total();
         for(int i = 0; i < total; i++)
         {
            Position* npos = NULL;
            COrder* order = listOrders.At(i);
            // ���� ����� �����������, �� �� ��������� ����� � ���� �������.
            ulong fticket = FaeryMagic(order.Magic(), MAGIC_TO_TICKET);
            int pos = -1;
            //���� ����� ����� ������������ - ���� ����� � ���� �������.
            if(fticket != -1)
            {
               COrder* sorder = new COrder(fticket);
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
            //����������� ����� �� ������? - ������ ��� �������� �������
            if(fticket == -1 || pos == -1)
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
};