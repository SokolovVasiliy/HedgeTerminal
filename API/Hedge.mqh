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
         // Удаляем список тикеров
         ListTickets.Clear();
         delete ListTickets;
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
         listOrders.Clear();
      }
            
      ///
      /// Обрабатывает новую сделку. Создает/изменяет/конфигурирует/ позицию. Самая важная и сложная функция HedgePanel.  
      ///
      void AddNewDeal(ulong ticket)
      {
         //Содержит время выполнения блока в милисекундах.
         #ifdef DEBUG
            printf("Добавляю новую сделку с тикетом №" + ticket);
         #endif 
         COrder* order = NULL;
         order = CreateOrderByDeal(ticket);
         if(order == NULL)
         {
            #ifdef DEBUG
               printf("Открывающий ордер, которому принадлежит сделка с тикетом №" + ticket + " не найден.");
            #endif
            return;
         }
         order.AddDeal(ticket);
         Deal* newTrade = new Deal(ticket);
         //Закрывающая сделка?
         if(order.Direction() == ORDER_OUT)
         {
            #ifdef DEBUG
               printf("Ордер, которому принадлжети сделка №" + ticket + " закрывает старую позицию.");
            #endif
            COrder* in_order = order.InOrder();
            Position* pos = new Position(in_order.OrderId(), in_order.Tickets(), order.OrderId(), order.Tickets());
            // Индекс активной позиции, чей объем закрывается частично или полностью текущими трейдами.
            int iActive = ActivePos.Search(pos);
            // Индекс исторической позиции, к которой добавляются текущие трейды.
            int iHistory = HistoryPos.Search(pos);
            delete pos;
            //Активная позиция должна существовать всегда, потому что поступивший трейд, если он закрывающий,
            //может закрыть только активную позицию.
            if(iActive == -1)
            {
               printf("Error: Active position all closed");
               return;
            }
            //Объем трейдов активной позиции надо уменьшить на объем текущего трейда
            Position* actPos = ActivePos.At(iActive);
            CArrayObj* entryDeals = actPos.EntryDeals();
            //Объем, который необходимо сбросить с активной позиции.
            double volDel = newTrade.VolumeExecuted();
            //Трейды, которые будут перенесены в историческую позицию как входящие трейды.
            CArrayObj* resDeals = new CArrayObj();
            for(int i = 0; entryDeals.Total(); i++)
            {
               Deal* deal = entryDeals.At(i);
               Deal* resDeal = new Deal(deal.Ticket());
               resDeals.Add(resDeal);
               //Обнуляем объем сделки которую пенересем в историческую позицию.
               resDeal.AddVolume((-1)* resDeal.VolumeExecuted());
               //Объем который надо закрыть больше текущей сделки?
               if(volDel >= deal.VolumeExecuted())
               {
                  //Переносим остаток объема на следущий трейд, а текущий
                  //полностью закрываем.
                  resDeal.AddVolume(deal.VolumeExecuted());
                  volDel -= deal.VolumeExecuted();
                  entryDeals.Delete(i);
               }
               //Активная сделка продолжает существовать, а ее первая
               //сделка уменьшается на объем поступившего трейда.
               else
               {
                  resDeal.AddVolume(volDel);
                  deal.AddVolume((-1)*volDel);
                  break;
               }
            }
            //Если активная позиция закрыта полностью, то удаляем ее
            if(entryDeals.Total() == 0)
            {
               //Перед удалением, уведомляем панель о удалении позиции.
               #ifndef HLIBRARY
               EventDelPos* event = new EventDelPos(actPos);
               EventExchange::PushEvent(event);
               delete event;
               #endif
               ActivePos.Delete(iActive);
            }
            //Уведомляем панель, что свойства позиции изменились.
            #ifndef HLIBRARY
            else
            {
               EventRefreshPos* event = new EventRefreshPos(actPos);
               EventExchange::PushEvent(event);
               delete event;
            }
            #endif
            // Если историческая позиция не существует, то это первый закрывающий трейд,
            // и тогда такую позицию необходимо создать.
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
            //Уведомляем панель, что свойства исторической позиции изменились.
            #ifndef HLIBRARY
            EventRefreshPos* event = new EventRefreshPos(histPos);
            EventExchange::PushEvent(event);
            delete event;
            #endif
         }
         //Этот трейд относится к открытой позиции, либо инициирует ее. 
         else
         {
            #ifdef DEBUG
               printf("Ордер, которому принадлжети сделка №" + ticket + " открывает новую позицию.");
            #endif
            ulong orderId = order.OrderId();
            Position* pos = new Position(order.OrderId(), order.Tickets());
            int iActive = ActivePos.Search(pos);
            //Если позиции нет, ее нужно добавить в список.
            if(iActive == -1)
            {
               ActivePos.InsertSort(pos);
               #ifdef DEBUG
                  printf("Создаю новую позицию и добавляю ее в список.");
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
                  printf("Обновляю существующую активную позицию.");
               #endif
            }
            #ifdef DEBUG
               printf("Отправляю уведомление о создании новой позиции.");
            #endif
            //Обновляем информацию о позиции на панели.
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
               printf("Уведомление отправлено. Функция успешно завершена");
            #endif
         }
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
         HistorySelect(0, TimeCurrent());
         int total = HistoryDealsTotal();
         //Перебираем все доступные трейды и формируем на их основе прототипы будущих позиций типа COrder
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
      /// Обрабатывает команду закрытия позиции
      ///
      /*void OnClosePos(EventClosePos* event)
      {
         ulong id = event.PositionId();
         string comment = event.CloseComment();
         //Находим позицию которую необходимо закрыть по ее уникальному id.
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
      /// Тип преобразования
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
      /// Преобразует magic номер закрывающей позиции в тикет отрывающей, либо
      /// тикет открывающией в magic закрывающей.
      ///
      ulong FaeryMagic(ulong value, ENYM_REGIM_CONV)
      {
         ///
         ///
         ///        
         return value;
      }
      ///
      /// Загружает историю ордеров
      ///
      void LoadHistory(void)
      {
         HistorySelect(0, TimeCurrent());
      }
      
      
      ///
      /// Создает ордер на основе идентификатора сделки.
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
      /// Создает ордер на основании его Id.
      ///
      COrder* CreateOrderById(ulong order_id)
      {
         LoadHistory();
         COrder* order = new COrder(order_id);
         ulong mg = order.Magic();
         //Если ордер уже в списке, то повторно создавать его не надо.
         int el = listOrders.Search(order);
         if(el != -1)
         {
            delete order;
            order = listOrders.At(el);
         }
         else
            listOrders.InsertSort(order);
         //order.AddDeal(ticket);
         //Текущий ордер может быть либо открывающим либо закрывающим.
         //Если это закрывающий ордер у него должен быть открывающий ордер
         //иначе он все равно открывающий.
         ulong in_ticket = el != -1 ? 0 : FaeryMagic(order.Magic(), MAGIC_TO_TICKET);
         //Пытаемся найти открывающий ордер по его тикету
         if(in_ticket > 0)
         {
            COrder* in_order = new COrder(in_ticket);
            int index = listOrders.Search(in_order);
            delete in_order;
            //Ордер уже есть в нашем списке?
            if(index != -1)
               in_order = listOrders.At(index);
            //Возможно он еще не попал с список.
            //Тогда ищем тикет в БД и создаем новый ордер на его основе.
            else
            {
               LoadHistory();
               //Открывающий ордер есть в базе?
               if(HistoryOrderSelect(in_ticket))
               {
                  in_order = new COrder(in_ticket);
                  listOrders.Add(in_order);
               }
            }
            //Открывающий ордер найден
            if(CheckPointer(in_order) != POINTER_INVALID)
            {
               in_order.OutOrder(order);
               order.InOrder(in_order);
            }
         }
         return order;
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
      /// Список тикетов всех ордеров.
      ///
      CArrayLong* ListTickets;
      ///
      /// Список всех позиций.
      ///
      CArrayObj listPos;
      ///
      /// Список ордеров и их сделок.
      ///
      CArrayObj listOrders;
      ///
      /// Количество сделок, которое поступило в течении заданного периода.
      ///
      int dealsCountNow;
};