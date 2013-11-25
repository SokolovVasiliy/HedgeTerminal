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
         
         //listOrder
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
         int id = event.PositionId();
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
      /// Создает позиции из исторических сделок и ордеров.
      ///
      void LoadPosition()
      {
         LoadHistory();
         int total = HistoryDealsTotal();
         ulong prev_order = -1;
         CArrayObj listOrders;
         listOrders.Sort(1);
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
            //Находим тикет ордера, совершивгего сделку
            ulong order_id;
            if(!HistoryDealGetInteger(ticket, DEAL_ORDER, order_id))continue;
            
            COrder* order = new COrder(order_id);
            order.AddDeal(ticket);
            int pos = listOrders.Search(order);
            // В списке ордеров уже есть такой ордер?
            if(pos != -1)
            {
               delete order;
               order = listOrders.At(pos);
            }
            //Если нет, создаем новый
            else
               listOrders.InsertSort(order);
         }
         //На основе списка ордеров собираем позиции.
         MergeOrders(GetPointer(listOrders));
         /*total = listOrders.Total();
         for(int i = 0; i < total; i++)
         {
            Position* npos = NULL;
            COrder* order = listOrders.At(i);
            ulong id = order.OrderId();
            // Если ордер закрывающий, то он закрывает ордер с этим тикетом.
            ulong open_ticket = FaeryMagic(order.Magic(), MAGIC_TO_TICKET);
            // Если ордер открывающий, то его закрывающим ордером будет ордер выставленный с этим магиком:
            ulong close_magic = FaeryMagic(order.OrderId(), TICKET_TO_MAGIC);
            int pos = -1;
            //Если тикет может существовать - ищем ордер с этим тикетом.
            if(open_ticket != -1)
            {
               COrder* sorder = new COrder(open_ticket);
               pos = listOrders.Search(sorder);
               //Открывающий ордер найден? - Создаем историческую позицию.
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
               //Открывающий ордер найден? - Создаем историческую позицию.
               if(pos != -1)
               {
                  COrder* out_order = listOrders.At(pos);
                  npos = new Position(order.OrderId(), order.Deals(), out_order.OrderId(), out_order.Deals());
                  HistoryPos.Add(npos);     
               }
               delete sorder;
            }
            //Открывающий ордер не найден? - Значит это открытая позиция
            if(close_magic == -1 || pos == -1)
            {
               npos = new Position(order.OrderId(), order.Deals());
               ActivePos.Add(npos);
            }
            //Уведомляем о создании новой позиции
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
      /// Создает из списка ордеров позиции. 
      ///
      void MergeOrders(CArrayObj* listOrders)
      {
         int total = listOrders.Total();
         for(int i = 0; i < total; i++)
         {
            COrder* order = listOrders.At(i);
            // Если ордер закрывающий, то он закрывает ордер с этим тикетом.
            ulong open_ticket = FaeryMagic(order.Magic(), MAGIC_TO_TICKET);
            int index = -1;
            if(open_ticket > 0)
            {
               COrder* sorder = new COrder(open_ticket);
               index = listOrders.Search(sorder);
               //Открывающий ордер найден? - Создаем историческую позицию.
               if(index != -1)
               {
                  //Цикл практически всегда будет завершатся при первой же итерации,
                  //поэтому на производительности этот перебор не сказывается.
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
            //Создаем активную позицию.
            if(open_ticket <= 0 || index == -1)
            {
               Position* pos = new Position(order.OrderId(), order.Deals());
               listPos.Add(pos);
            }
         }
         //Теперь, когда все позиции созданы, разносим их по разным спискам
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

};