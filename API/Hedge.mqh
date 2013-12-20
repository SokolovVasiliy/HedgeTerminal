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
      #ifndef HLIBRARY
      void Event(Event* event)
      {
         ENUM_EVENT enEvent = event.EventId();
         switch(event.EventId())
         {
            //������������ ������ �� �������� �������.
            //case EVENT_CLOSE_POS:
            //   OnClosePos(event);
            //   break;
            case EVENT_REFRESH:
               OnRefresh();
               break;
         }
      }
      #endif
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
         OnRefresh();
         printf("Recalc position complete.");
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
            
      ///
      /// ������������ ����� ������. �������/��������/�������������/ �������. ����� ������ � ������� ������� HedgePanel.  
      ///
      void AddNewDeal(ulong ticket)
      {
         //�������� ����� ���������� ����� � ������������.
         #ifdef DEBUG
            printf("�������� ����� ������ � ������� �" + ticket);
         #endif 
         COrder* order = NULL;
         order = CreateOrderByDeal(ticket);
         if(order == NULL)
         {
            #ifdef DEBUG
               printf("����������� �����, �������� ����������� ������ � ������� �" + ticket + " �� ������.");
            #endif
            return;
         }
         order.AddDeal(ticket);
         Deal* newTrade = new Deal(ticket);
         //����������� ������?
         if(order.Direction() == ORDER_OUT)
         {
            #ifdef DEBUG
               printf("�����, �������� ����������� ������ �" + ticket + " ��������� ������ �������.");
            #endif
            COrder* in_order = order.InOrder();
            Position* pos = new Position(in_order.OrderId(), in_order.Tickets(), order.OrderId(), order.Tickets());
            // ������ �������� �������, ��� ����� ����������� �������� ��� ��������� �������� ��������.
            int iActive = ActivePos.Search(pos);
            // ������ ������������ �������, � ������� ����������� ������� ������.
            int iHistory = HistoryPos.Search(pos);
            delete pos;
            //�������� ������� ������ ������������ ������, ������ ��� ����������� �����, ���� �� �����������,
            //����� ������� ������ �������� �������.
            if(iActive == -1)
            {
               printf("Error: Active position all closed");
               return;
            }
            //����� ������� �������� ������� ���� ��������� �� ����� �������� ������
            Position* actPos = ActivePos.At(iActive);
            CArrayObj* entryDeals = actPos.EntryDeals();
            //�����, ������� ���������� �������� � �������� �������.
            double volDel = newTrade.VolumeExecuted();
            //������, ������� ����� ���������� � ������������ ������� ��� �������� ������.
            CArrayObj* resDeals = new CArrayObj();
            for(int i = 0; entryDeals.Total(); i++)
            {
               Deal* deal = entryDeals.At(i);
               Deal* resDeal = new Deal(deal.Ticket());
               resDeals.Add(resDeal);
               //�������� ����� ������ ������� ��������� � ������������ �������.
               resDeal.AddVolume((-1)* resDeal.VolumeExecuted());
               //����� ������� ���� ������� ������ ������� ������?
               if(volDel >= deal.VolumeExecuted())
               {
                  //��������� ������� ������ �� �������� �����, � �������
                  //��������� ���������.
                  resDeal.AddVolume(deal.VolumeExecuted());
                  volDel -= deal.VolumeExecuted();
                  entryDeals.Delete(i);
               }
               //�������� ������ ���������� ������������, � �� ������
               //������ ����������� �� ����� ������������ ������.
               else
               {
                  resDeal.AddVolume(volDel);
                  deal.AddVolume((-1)*volDel);
                  break;
               }
            }
            //���� �������� ������� ������� ���������, �� ������� ��
            if(entryDeals.Total() == 0)
            {
               //����� ���������, ���������� ������ � �������� �������.
               #ifndef HLIBRARY
               EventDelPos* event = new EventDelPos(actPos);
               EventExchange::PushEvent(event);
               delete event;
               #endif
               ActivePos.Delete(iActive);
            }
            //���������� ������, ��� �������� ������� ����������.
            #ifndef HLIBRARY
            else
            {
               EventRefreshPos* event = new EventRefreshPos(actPos);
               EventExchange::PushEvent(event);
               delete event;
            }
            #endif
            // ���� ������������ ������� �� ����������, �� ��� ������ ����������� �����,
            // � ����� ����� ������� ���������� �������.
            if(iHistory == -1)
            {
               CArrayObj* exitDeals = new CArrayObj();
               ulong o_id = in_order.OrderId();
               int dbg = 5;
               if(o_id == 1008917622)
                  dbg = 6;
               Position* npos = new Position(in_order.OrderId(), new CArrayObj(), order.OrderId(), new CArrayObj());
               HistoryPos.InsertSort(npos);
               iHistory = HistoryPos.Search(npos);
               if(iHistory == -1)return;
            }
            Position* histPos = HistoryPos.At(iHistory);
            CArrayObj* exitDeals = histPos.ExitDeals();
            exitDeals.Add(new Deal(newTrade.Ticket()));
            entryDeals = histPos.EntryDeals();
            for(int i = 0; i < resDeals.Total(); i++)
            {
               Deal* addDeal = resDeals.At(i);
               int iDeal = entryDeals.Search(addDeal);
               if(iDeal == -1)
                  entryDeals.InsertSort(addDeal);
               else
               {
                  Deal* histDeal = entryDeals.At(iDeal);
                  histDeal.AddVolume(addDeal.VolumeExecuted());
               }
            }
            //���������� ������, ��� �������� ������������ ������� ����������.
            #ifndef HLIBRARY
            EventRefreshPos* event = new EventRefreshPos(histPos);
            EventExchange::PushEvent(event);
            delete event;
            #endif
         }
         //���� ����� ��������� � �������� �������, ���� ���������� ��. 
         else
         {
            #ifdef DEBUG
               printf("�����, �������� ����������� ������ �" + ticket + " ��������� ����� �������.");
            #endif
            ulong orderId = order.OrderId();
            Position* pos = new Position(order.OrderId(), order.Tickets());
            int iActive = ActivePos.Search(pos);
            //���� ������� ���, �� ����� �������� � ������.
            if(iActive == -1)
            {
               ActivePos.InsertSort(pos);
               #ifdef DEBUG
                  printf("������ ����� ������� � �������� �� � ������.");
               #endif
            }
            else
            {
               delete pos;
               pos = ActivePos.At(iActive);
               CArrayObj* entryDeals = pos.EntryDeals();
               Deal* deal = new Deal(newTrade.Ticket());
               entryDeals.Add(deal);
               #ifdef DEBUG
                  printf("�������� ������������ �������� �������.");
               #endif
            }
            #ifdef DEBUG
               printf("��������� ����������� � �������� ����� �������.");
            #endif
            //��������� ���������� � ������� �� ������.
            //if(HedgePanel != NULL)
            //{
               #ifndef HLIBRARY
               EventRefreshPos* event = new EventRefreshPos(pos);
               EventExchange::PushEvent(event);
               //HedgePanel.Event(event);
               delete event;
               #endif
            //}
            #ifdef DEBUG
               printf("����������� ����������. ������� ������� ���������");
            #endif
         }
      }
      ///
      /// ���������� ���������� �������� �������
      ///
      int ActivePosTotal()
      {
         return ActivePos.Total();
      }
      ///
      /// ���������� ���������� ������������ �������.
      ///
      int HistoryPosTotal()
      {
         return HistoryPos.Total();
      }
      ///
      /// ���������� �������� ������� ��� ������� n �� ������ �������.
      ///
      Position* ActivePosAt(int n)
      {
         Position* pos = ActivePos.At(n);
         return pos;
      }
      
      ///
      /// ������ �� ������������ ����� ������� � �������.
      ///
      void OnRefresh()
      {
         HistorySelect(0, TimeCurrent());
         int total = HistoryDealsTotal();
         //���������� ��� ��������� ������ � ��������� �� �� ������ ��������� ������� ������� ���� COrder
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            HistorySelect(0, TimeCurrent());
            //printf("dealsCount: " + dealsCountNow + " Deals Total: " + HistoryDealsTotal());
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
         }
      }
   private:
      ///
      /// ������������ ������� �������� �������
      ///
      /*void OnClosePos(EventClosePos* event)
      {
         ulong id = event.PositionId();
         string comment = event.CloseComment();
         //������� ������� ������� ���������� ������� �� �� ����������� id.
         for(int i = 0; ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            if(pos.EntryOrderID() == id)
            {
               pos.AsynchClose(pos.VolumeExecuted(), comment);
               break;
            }
         }
      }*/
      
      //void OnAddDeal(EventAddDeal* event){;}
      /*void OnAddDeal(EventAddDeal* event)
      {
         AddNewDeal(event.DealID(), event.OrderId());
      }*/
      
      
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
         HistorySelect(0, TimeCurrent());
      }
      
      
      ///
      /// ������� ����� �� ������ �������������� ������.
      ///
      COrder* CreateOrderByDeal(ulong ticket)
      {
         
         LoadHistory();
         ulong order_id = HistoryDealGetInteger(ticket, DEAL_ORDER);
         if(order_id == 0)
            return NULL;
         return CreateOrderById(order_id);
      }
      ///
      /// ������� ����� �� ��������� ��� Id.
      ///
      COrder* CreateOrderById(ulong order_id)
      {
         LoadHistory();
         COrder* order = new COrder(order_id);
         ulong mg = order.Magic();
         //���� ����� ��� � ������, �� �������� ��������� ��� �� ����.
         int el = listOrders.Search(order);
         if(el != -1)
         {
            delete order;
            order = listOrders.At(el);
         }
         else
            listOrders.InsertSort(order);
         //order.AddDeal(ticket);
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
      ///
      /// ���������� ������, ������� ��������� � ������� ��������� �������.
      ///
      int dealsCountNow;
};