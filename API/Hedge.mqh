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
         ActivePos = new CArrayObj();
         HistoryPos = new CArrayObj();
         ActivePos.Sort(SORT_ORDER_ID);
         HistoryPos.Sort(SORT_ORDER_ID);
         OnRefresh();
         printf("Recalc position complete.");
      }
      
      ~CHedge()
      {
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
      }
      
      
      ///
      ///
      ///
      void AddNewDeal(ulong ticket)
      {
         ulong orderId = FindOrderIdByDealId(ticket);
         //Deal is not trade? - return.
         if(orderId == 0)
            return;
         ulong inOrderId = FindInOrderId(orderId);
         if(inOrderId == 0)
            CreateActivePos(orderId, ticket);
         else
            CreateHistoryPos(inOrderId, orderId, ticket);
      }
      
      //test new addDeal.
      void NewAddNewDeal(ulong ticket)
      {
         CDeal* deal = new CDeal(ticket);
         Order* order = new Order(deal);
         if(order.Status() == ORDER_NULL)
         {
            delete order;
            return;
         }
         
         CPosition* actPos = FindOrCreateActivePosForOrder(order);
         InfoIntegration* result = actPos.Integrate(order);
         int iActive = ActivePos.Search(actPos);
         if(actPos.Status() == POSITION_CLOSE)
         {
            //SendEventDelPos(actPos);
            if(iActive != -1)
               ActivePos.Delete(iActive);
         }
         else
         {
            //SendEventRefreshPos(actPos);
            if(iActive == -1)
               ActivePos.InsertSort(actPos);
         }
         
         //����� ������� ������ ��� �������, ����� ������� - �������� �������.
         if(result.ActivePosition.Status() == POSITION_ACTIVE)
         {
            ActivePos.InsertSort(result.ActivePosition);
            SendEventRefreshPos(result.ActivePosition);
         }
         else
            delete result.ActivePosition;
         if(result.HistoryPosition.Status() == POSITION_HISTORY)
            IntegrateHistoryPos(result.HistoryPosition);
         else
            delete result.HistoryPosition;
         delete result;
      }
      
      ///
      /// ������� ��� ������������ ��� ������� ����� �������
      /// �������, ������� ����� ������������ ���������� �����.
      ///
      CPosition* FindOrCreateActivePosForOrder(Order* order)
      {
         CPosition* actPos = NULL;
         ulong posId = order.PositionId();
         ulong currId = order.GetId();
         if(posId != 0)
         {
            int total = ActivePos.Total();
            Order* inOrder = new Order(posId);
            int iActive = ActivePos.Search(inOrder);
            delete inOrder;
            if(iActive != -1)
               return ActivePos.At(iActive);
         }
         //�������� ������� ���? - ������ ��� ����������� ����� ����� �������.
         return new CPosition();
      }
      
      ///
      /// ���������� ������������ �����, ���� NULL, ���� ������� �� ������.
      /// \param outOrder - ����������� �����.
      ///
      /*Order* GetInOrderOrNull(Order* outOrder)
      {
         ulong posId = outOrder.PositionId();
         int dbg = 3;
         if(posId != 0)
            dbg = 4;
         Order* inOrder = new Order(outOrder.PositionId());
         switch(inOrder.Status())
         {
            case ORDER_NULL:
               delete inOrder;
               return NULL;
            case ORDER_EXECUTING:
               //TODO: Write function find deals for order.
               //inOrder.FindDeals();
               if(inOrder.Status() == ORDER_HISTORY)
                  return inOrder;
            case ORDER_PENDING:
               //TODO: write delete function active order.
               //DeleteActiveOrder(inOrder);
               delete inOrder;
               return NULL;
         }
         return NULL;
      }*/
      ///
      /// ������ � ������ ������������ ������� ����� ������������ �������.
      ///
      void IntegrateHistoryPos(CPosition* histPos)
      {
         int iHist = HistoryPos.Search(histPos);
         if(iHist != -1)
         {
            CPosition* pos = HistoryPos.At(iHist);
            pos.Merge(histPos);
            delete histPos;
         }
         else
            HistoryPos.InsertSort(histPos);
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
         LoadHistory();
         int total = HistoryDealsTotal();
         //���������� ��� ��������� ������ � ��������� �� �� ������ ��������� ������� ������� ���� COrder
         for(; dealsCountNow < total; dealsCountNow++)
         {  
            //LoadHistory();
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            NewAddNewDeal(ticket);
         }
      }
   private:
      /*CreateOrderById(ulong orderId)
      {
         Order* order = new Order();
         for(i = dealsCountNow; i < HistoryDealsTotal(); i++)      
         {
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            Deal* deal = new Deal(ticket);
            if(deal.OrderId() != orderId)
            {
               delete deal;
               continue;
            }
            order.AddDeal(deal);
         }
         return order;
      }*/
      ///
      /// ���������� ������� "���������� �������".
      ///
      void SendEventRefreshPos(Position* pos)
      {
         //� ���������� HedgeAPI ������ ���, � ������ ��� � ����������� �� �������.
         #ifndef HLIBRARY
            EventRefreshPos* event = new EventRefreshPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
      }
      ///
      /// ���������� ������� "���������� �������".
      ///
      void SendEventRefreshPos(CPosition* pos)
      {
         //� ���������� HedgeAPI ������ ���, � ������ ��� � ����������� �� �������.
         /* TODO: �������� ��������������� Event
         #ifndef HLIBRARY
            EventRefreshPos* event = new EventRefreshPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
         */
      }
      ///
      /// ���������� ������� �������� �� ������ �������.
      ///
      void SendEventDelPos(Position* pos)
      {
         #ifndef HLIBRARY
            EventDelPos* event = new EventDelPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
      }
      
      ///
      /// ���������� ������� �������� �� ������ �������.
      ///
      void SendEventDelPos(CPosition* pos)
      {
         /* TODO: �������� ��������������� Event
         #ifndef HLIBRARY
            EventDelPos* event = new EventDelPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
         */
      }
      ///
      /// ������� �������� �������, ���� ��������� ����� ����� � ��� ������������ �������� �������.
      /// \param orderId - ������������� ������, ��������� �������� �������.
      /// \param dealId - ������������� ������, ������������ �� ��������� ������.
      ///
      void CreateActivePos(ulong orderId, ulong dealId)
      {
         CArrayLong* deals = new CArrayLong();
         deals.Add(dealId);
         Position* pos = new Position(orderId, deals);
         int iActive = ActivePos.Search(pos);
         if(iActive == -1)
            ActivePos.InsertSort(pos);
         else
         {
            delete pos;
            pos = ActivePos.At(iActive);
            pos.AddActiveDeal(dealId);
         }
         SendEventRefreshPos(pos);
      }
      
      /*void CreateActivePos(Order* order)
      {
         CPosition* pos = new CPosition(order);
         int iActive = ActivePos.Search(pos);
         if(iActive == -1)
            ActivePos.InsertSort(pos);
         else
         {
            delete pos;
            pos = ActivePos.At(iActive);
            pos.AddInitialOrder(order);
         }
         SendEventRefreshPos(pos);
      }*/
      ///
      /// ������� ������������ ������� �� ��������� ����������� ������.
      ///
      void CreateHistoryPos(ulong inOrderId, ulong outOrderId, ulong dealId)      
      {
         int iActive = FindOrCreateActivePos(inOrderId, outOrderId, dealId);
         if(iActive == -1)return;
         Position* actPos = ActivePos.At(iActive);
         CArrayObj* resDeals = actPos.AnnihilationDeal(dealId);
         CArrayObj* entryDeals = actPos.EntryDeals();
         if(entryDeals.Total() == 0)
         {
            SendEventDelPos(actPos);
            ActivePos.Delete(iActive);
         }
         else
            SendEventRefreshPos(actPos);
         
         int iHistory = FindOrCreateHistPos(inOrderId, outOrderId);
         if(iHistory == -1)return;
         Position* histPos = HistoryPos.At(iHistory);
         histPos.MergeDeals(resDeals, dealId);
         SendEventRefreshPos(histPos);
      }
      
      /*void CreateHistoryPos(Order* closeOrder)
      {
         int iActive = FindOrCreateActivePosByCloseOrder(closeOrder);
         if(iActive == -1)return;
         CPosition* actPos = ActivePos.At(iActive);
         CPosition* histPos = actPos.AddClosingOrder(closeOrder);
         if(actPos.Status() == POSITION_CLOSE)
         {
            SendEventDelPos(actPos);
            ActivePos.Delete(iActive);
         }
         else
            SendEventRefreshPos(actPos);
         if(histPos.Status() == POSITION_NULL)
         {
            delete histPos;
            return;
         }
         int iHistory = HistoryPos.Search(histPos);
         if(iHistory != -1)
         {
            CPosition* oldPos = HistoryPos.At(iHistory);
            //oldPos.MergePosition(histPos);
            delete histPos;
            return;
         }
         HistoryPos.InsertSort(histPos);
      }*/
      
      ///
      /// ������� ������������ ������� � ������ ������������ �������, ���� ������� ��, ���� ��� �� �������.
      /// ���������� -1, ���� ������� ������� �� �������.
      ///
      int FindOrCreateHistPos(ulong inOrderId, ulong orderId)
      {
         CArrayObj* exitDeals = new CArrayObj();
         Position* npos = new Position(inOrderId, new CArrayObj(), orderId, new CArrayObj());
         HistoryPos.InsertSort(npos);
         int iHistory = HistoryPos.Search(npos);
         if(iHistory == -1)
         {
            LogWriter("Failed to create a historical position with closed order #" +
                      (string)orderId + " New deal will be ignored!", MESSAGE_TYPE_ERROR);
            delete npos;
         }
         return iHistory;
      }
      
      ///
      /// ������� �������� ������� � ������ ��������� �������, ���� ������� ��, ���� ��� �� �������.
      /// ���������� -1, ���� ������� ������� �� �������.
      ///
      int FindOrCreateActivePos(ulong inOrderId, ulong orderId, ulong dealId)
      {
         Position* pos = new Position(inOrderId, new CArrayLong(), orderId, new CArrayLong);
         int iActive = ActivePos.Search(pos);
         if(iActive == -1)
         {
            LoadHistory();
            //Active order find, but class of position not build.
            if(HistoryOrderSelect(inOrderId))
            {
               CArrayLong* trades = FindDealsIdByOrderId(inOrderId);
               for(int i = 0; i < trades.Total(); i++)
               {
                  ulong id = trades.At(i);
                  CreateActivePos(inOrderId, id);
               }
               iActive = ActivePos.Search(pos);
            }
            else
            {
               LogWriter("Close order detected, but active position not find. Creating active position by closed order #"
                         + (string)dealId + ".", MESSAGE_TYPE_WARNING);
               CreateActivePos(orderId, dealId);
            }
         }
         delete pos;
         return iActive;
      }
      
      ///
      /// ������� �������� ����� �������, ���� � �������� ��������� ������� �������������
      /// ������ ������������ �������. ���������� 0 - ���� �������� ����� �� ������. 
      ///
      ulong FindInOrderId(ulong outOrderId)
      {
         LoadHistory();
         ulong magic = HistoryOrderGetInteger(outOrderId, ORDER_MAGIC);
         if(magic == 0)return 0;
         ulong inOrderId = FaeryMagic(magic, MAGIC_TO_TICKET);
         //LoadHistory();
         if(inOrderId == 0 ||
            !HistoryOrderSelect(inOrderId))return 0;
         return inOrderId;
      }
      
      ///
      /// ���������� ������������� ������, �� ��������� ��������
      /// �������� ����� � ��������������� dealId. ���������� 0,
      /// ���� ����� ��������������� ������ �� ������.
      ///
      ulong FindOrderIdByDealId(ulong dealId)
      {
         LoadHistory();
         return HistoryDealGetInteger(dealId, DEAL_ORDER);
      }
      
      ///
      /// ���������� ������ ��������������� �������, ����������� �� ������ ������ orderId.
      ///
      CArrayLong* FindDealsIdByOrderId(ulong orderId)
      {
         CArrayLong* trades = new CArrayLong();
         LoadHistory();
         int total = HistoryDealsTotal();
         for(int i = 0; i < total; i++)
         {
            ulong ticket = HistoryDealGetTicket(i);
            ulong currOrderId = HistoryDealGetInteger(ticket, DEAL_ORDER);
            if(currOrderId == orderId)
               trades.Add(currOrderId);
         }
         return trades;
      }
      
      ///
      /// ��������� ������� �������, ���� ��� �� ���������.
      ///
      void LoadHistory(void)
      {
         if(HistoryDealsTotal() < 2)
            HistorySelect(0, TimeCurrent());
      }
      
      ///
      /// ��� ��������������.
      ///
      enum ENUM_REGIM_CONV
      {
         MAGIC_TO_TICKET,
         TICKET_TO_MAGIC
      };
      
      ///
      /// ����������� magic ����� ����������� ������� � ����� ����������, ����
      /// ����� ������������ � magic �����������.
      ///
      ulong FaeryMagic(ulong value, ENUM_REGIM_CONV typeConv)
      {        
         switch(typeConv)
         {
            case MAGIC_TO_TICKET:
               return MagicToTicket(value);
            case TICKET_TO_MAGIC:
               return value;
         }
         return 0;
      }
      
      ulong MagicToTicket(ulong magic)
      {
         if(magic == 0)return 0;
         //TODO: �������� ������� ���������� �������.
         ulong inOrderId = magic;
         //LoadHistory();
         if(!HistoryOrderSelect(inOrderId))return 0;
         return inOrderId;
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
      /// ���������� ������, ������� ��������� � ������� ��������� �������.
      ///
      int dealsCountNow;
};