#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Order.mqh"

///
/// Класс позиции
///
class CHedge
{
   public:
      ///
      /// Принимает события
      ///
      #ifndef HLIBRARY
      void Event(Event* event)
      {
         ENUM_EVENT enEvent = event.EventId();
         switch(event.EventId())
         {
            //Обрабатываем приказ на закрытие позиции.
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
         // Удаляем список активных позиций.
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            delete pos;
         }
         ActivePos.Clear();
         delete ActivePos;
         // Удаляем список исторических позиций.
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
         
         //Можно закрыть больше чем имеется, тогда остаток - активная позиция.
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
      /// Находит уже существующую или создает новую нулевую
      /// позицию, которой может принадлежать переданный ордер.
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
         //Активной позиции нет? - значит это открывающий ордер новой позиции.
         return new CPosition();
      }
      
      ///
      /// Возвращает инициирующий ордер, либо NULL, если таковой не найден.
      /// \param outOrder - закрывающий ордер.
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
      /// Вносит в список исторических позиций новую историческую позицию.
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
      /// Возвращает количество активных позиций
      ///
      int ActivePosTotal()
      {
         return ActivePos.Total();
      }
      ///
      /// Возвращает количество исторических позиций.
      ///
      int HistoryPosTotal()
      {
         return HistoryPos.Total();
      }
      ///
      /// Возвращает активную позицию под номером n из списка позиций.
      ///
      Position* ActivePosAt(int n)
      {
         Position* pos = ActivePos.At(n);
         return pos;
      }
      
      ///
      /// Следит за поступлением новых трейдов и ордеров.
      ///
      void OnRefresh()
      {
         LoadHistory();
         int total = HistoryDealsTotal();
         //Перебираем все доступные трейды и формируем на их основе прототипы будущих позиций типа COrder
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
      /// Отправляет событие "обновление позиции".
      ///
      void SendEventRefreshPos(Position* pos)
      {
         //В библиотеке HedgeAPI панели нет, а значит нет и передваемых ей событий.
         #ifndef HLIBRARY
            EventRefreshPos* event = new EventRefreshPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
      }
      ///
      /// Отправляет событие "обновление позиции".
      ///
      void SendEventRefreshPos(CPosition* pos)
      {
         //В библиотеке HedgeAPI панели нет, а значит нет и передваемых ей событий.
         /* TODO: Написать соответсвтующий Event
         #ifndef HLIBRARY
            EventRefreshPos* event = new EventRefreshPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
         */
      }
      ///
      /// Отправляет событие удаление из списка позиций.
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
      /// Отправляет событие удаление из списка позиций.
      ///
      void SendEventDelPos(CPosition* pos)
      {
         /* TODO: Написать соответсвтующий Event
         #ifndef HLIBRARY
            EventDelPos* event = new EventDelPos(pos);
            EventExchange::PushEvent(event);
            delete event;
         #endif
         */
      }
      ///
      /// Создает активную позицию, либо добавляет новый трейд к уже существующей активной позиции.
      /// \param orderId - идентификатор ордера, создающий активную позицию.
      /// \param dealId - идентификатор трейда, совершенного на основании ордера.
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
      /// Создает историческую позицию на основании переданного ордера.
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
      /// Находит историческую позицию в списке исторических позиций, либо создает ее, если она не создана.
      /// Возвращает -1, если создать позицию не удалось.
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
      /// Находит активную позицию в списке активыных позиций, либо создает ее, если она не создана.
      /// Возвращает -1, если создать позицию не удалось.
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
      /// Находит входящий ордер позиции, если в качестве аргумента передан идентификатор
      /// ордера закрывающего позицию. Возвращает 0 - если входящий ордер не найден. 
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
      /// Возвращает идентификатор ордера, на основании которого
      /// совершен трейд с идентификатором dealId. Возвращает 0,
      /// если ордер соответсвтующий трейду не найден.
      ///
      ulong FindOrderIdByDealId(ulong dealId)
      {
         LoadHistory();
         return HistoryDealGetInteger(dealId, DEAL_ORDER);
      }
      
      ///
      /// Возвращает список идентификаторов трейдов, совершенных на основе ордера orderId.
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
      /// Загружает историю ордеров, если она не загружена.
      ///
      void LoadHistory(void)
      {
         if(HistoryDealsTotal() < 2)
            HistorySelect(0, TimeCurrent());
      }
      
      ///
      /// Тип преобразования.
      ///
      enum ENUM_REGIM_CONV
      {
         MAGIC_TO_TICKET,
         TICKET_TO_MAGIC
      };
      
      ///
      /// Преобразует magic номер закрывающей позиции в тикет отрывающей, либо
      /// тикет открывающией в magic закрывающей.
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
         //TODO: Написать функцию шифрования маджика.
         ulong inOrderId = magic;
         //LoadHistory();
         if(!HistoryOrderSelect(inOrderId))return 0;
         return inOrderId;
      }
      ///
      /// Список активных позиций.
      ///
      CArrayObj* ActivePos;
      ///
      /// Список исторических, закрытых позиций.
      ///
      CArrayObj* HistoryPos;
      ///
      /// Количество сделок, которое поступило в течении заданного периода.
      ///
      int dealsCountNow;
};