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
      void Event(Event* event)
      {
         switch(event.EventId())
         {
            //Обрабатываем приказ на закрытие позиции.
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
      
      void Init()
      {
         LoadPosition();
      }
      
      ///
      /// Добавляет новую позицию в список позиций
      ///
      void AddNewPos(ulong ticket)
      {
         //ListTickets;
      }
      ///
      /// Обрабатывает новую сделку. Добавляет
      ///
      void AddNewDeal(ulong ticket)
      {
         
         //listOrders.Search();
      }
      ///
      /// Возвращает количество активных позиций
      ///
      int ActivePosTotal()
      {
         return ActivePos.Total();
      }
      ///
      /// Возвращает активную позицию под номером n из списка позиций.
      ///
      Position* ActivePosAt(int n)
      {
         Position* pos = ActivePos.At(n);
         return pos;
      }
   private:
      ///
      /// Обрабатывает команду закрытия позиции
      ///
      void OnClosePos(EventClosePos* event)
      {
         ulong id = event.PositionId();
         string comment = event.CloseComment();
         //Находим позицию которую необходимо закрыть по ее уникальному id.
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
         // Закрывающая сделка?
         if(order.Direction() == ORDER_OUT)
         {
            COrder* in_order = order.InOrder();
            Position* pos = new Position(in_order.OrderId(), in_order.Deals(), order.OrderId(), order.Deals());
            // Сделка закрывает активную позицию?
            int aindex = ActivePos.Search(pos);
            
            //Это сделка принадлежит ранее установленному закрывающему ордеру?
            int index = HistoryPos.Search(pos);
            //Да? - тогда сделка принадлежит к уже существующей исторической позиции.
            if(index != -1)
            {
               //delete pos;
               Position* hpos = HistoryPos.At(index);
               // В этом случае наверняка существует активный ордер, который закрывает эта сделка
               // (частично или полностью).
               //ActivePos.Search(pos);
               
            }
            //Нет? - тогда создаем новую историческую позицию.
            else
            {
               HistoryPos.InsertSort(pos);
            }
            Deal* deal = new Deal(event.DealID());
            pos.AddExitDeal(deal);
            // Обновляем отображение о позиции в существующей
            EventRefreshPos* refresh_pos = new EventRefreshPos(pos);
            EventExchange::PushEvent(refresh_pos);
            delete event;
         }
      }
      ///
      /// Обрабатываем обновление позиций
      ///
      void OnTimer(EventTimer* event)
      {
         ;
      }
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
         HistorySelect(D'1970.01.01', TimeCurrent());
      }
      
      ///
      /// Создает из списка ордеров позиции. 
      ///
      void LoadPosition()
      {
         LoadHistory();
         int total = HistoryDealsTotal();
         //ulong prev_order = -1;
         listOrders.Sort(SORT_ORDER_ID);
         //Перебираем все доступные трейды и формируем на их основе прототипы будущих позиций типа COrder
         for(int i = 0; i < total; i++)
         {  
            // Находим ордер, породивший сделку.
            LoadHistory();
            ulong ticket = HistoryDealGetTicket(i);
            HistoryDealSelect(ticket);
            if(ticket == 0)continue;
            
            //Загружаем только торговые операции
            ENUM_DEAL_TYPE op_type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
            if(op_type != DEAL_TYPE_BUY && op_type != DEAL_TYPE_SELL)
               continue;
            //Создаем ордер, к которому принадлежит сделка.
            CreateOrder(ticket);
         }
         //Теперь, когда список ордеров готов, мы можем создать список позиций на их основе.
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
      /// Создает ордер на основе идентификатора сделки.
      ///
      COrder* CreateOrder(ulong ticket)
      {
         ulong order_id;
         LoadHistory();
         if(!HistoryDealGetInteger(ticket, DEAL_ORDER, order_id))return NULL;
         //LoadHistory();
         COrder* order = new COrder(order_id);
         //Если ордер уже в списке, то повторно создавать его не надо.
         int el = listOrders.Search(order);
         if(el != -1)
         {
            delete order;
            order = listOrders.At(el);
         }
         else
            listOrders.InsertSort(order);
         order.AddDeal(ticket);
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

};