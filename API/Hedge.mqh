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
            LoadHistory();
            ulong ticket = HistoryDealGetTicket(dealsCountNow);
            AddNewDeal(ticket);
         }
      }
   private:
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
                      orderId + " New deal will be ignored!", MESSAGE_TYPE_ERROR);
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
            if(OrderSelect(inOrderId))
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
               LogWriter("Close order detected, but active position not find. Creating active position by closed order #" + dealId + ".", MESSAGE_TYPE_WARNING);
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
      /// Загружает историю ордеров
      ///
      void LoadHistory(void)
      {
         HistorySelect(0, TimeCurrent());
      }
      
      ///
      /// Тип преобразования.
      ///
      enum ENYM_REGIM_CONV
      {
         MAGIC_TO_TICKET,
         TICKET_TO_MAGIC
      };
      
      ///
      /// Преобразует magic номер закрывающей позиции в тикет отрывающей, либо
      /// тикет открывающией в magic закрывающей.
      ///
      ulong FaeryMagic(ulong value, ENYM_REGIM_CONV)
      {        
         return value;
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