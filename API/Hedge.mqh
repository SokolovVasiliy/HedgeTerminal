#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
///
///  ласс позиции
///
class CHedge
{
   public:
      ///
      /// ѕринимает событи€
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
         // ”дал€ем список тикеров
         ListTickets.Clear();
         delete ListTickets;
         // ”дал€ем список активных позиций.
         for(int i = 0; i < ActivePos.Total(); i++)
         {
            Position* pos = ActivePos.At(i);
            delete pos;
         }
         ActivePos.Clear();
         delete ActivePos;
         // ”дал€ем список исторических позиций.
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
      /// ƒобавл€ет новую позицию в список позиций
      ///
      void AddNewPos(ulong ticket)
      {
         //ListTickets;
      }
      ///
      /// ¬озвращает количество активных позиций
      ///
      int ActivePosTotal()
      {
         return ActivePos.Total();
      }
      ///
      /// ¬озвращает активную позицию под номером n из списка позиций.
      ///
      Position* ActivePosAt(int n)
      {
         Position* pos = ActivePos.At(n);
         return pos;
      }
   private:
      ///
      /// ќбрабатываем обновление позиций
      ///
      void OnTimer(EventTimer* event)
      {
         ;
      }
      ///
      /// “ип преобразовани€
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
      /// ѕреобразует magic номер закрывающей позиции в тикет отрывающей, либо
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
      /// «агружает историю ордеров
      ///
      void LoadHistory(void)
      {
         HistorySelect(D'1970.01.01', TimeCurrent());
      }
      
      ///
      /// —оздает позиции из исторических сделок и ордеров.
      ///
      void LoadPosition()
      {
         LoadHistory();
         int total = HistoryDealsTotal();
         ulong prev_order = -1;
         CArrayObj listOrders;
         listOrders.Sort(1);
         //ѕеребираем все доступные трейды и формируем на их основе прототипы будущих позиций типа COrder
         for(int i = 0; i < total; i++)
         {  
            // Ќаходим ордер, породивший сделку.
            LoadHistory();
            ulong ticket = HistoryDealGetTicket(i);
            if(ticket == 0)continue;
            
            //«агружаем только торговые операции
            ENUM_DEAL_TYPE op_type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
            if(op_type != DEAL_TYPE_BUY && op_type != DEAL_TYPE_SELL)
               continue;
            //Ќаходим тикет ордера, совершивгего сделку
            ulong order_id;
            if(!HistoryDealGetInteger(ticket, DEAL_ORDER, order_id))continue;
            
            COrder* order = new COrder(order_id);
            order.AddDeal(ticket);
            int pos = listOrders.Search(order);
            // ¬ списке ордеров уже есть такой ордер?
            if(pos != -1)
            {
               delete order;
               order = listOrders.At(pos);
            }
            //≈сли нет, создаем новый
            else
               listOrders.InsertSort(order);
         }
         //Ќа основе списка ордеров собираем позиции.
         total = listOrders.Total();
         for(int i = 0; i < total; i++)
         {
            Position* npos = NULL;
            COrder* order = listOrders.At(i);
            // ≈сли ордер закрывающий, то он закрывает ордер с этим тикетом.
            ulong fticket = FaeryMagic(order.Magic(), MAGIC_TO_TICKET);
            int pos = -1;
            //≈сли тикет может существовать - ищем ордер с этим тикетом.
            if(fticket != -1)
            {
               COrder* sorder = new COrder(fticket);
               pos = listOrders.Search(sorder);
               //ќткрывающий ордер найден? - —оздаем историческую позицию.
               if(pos != -1)
               {
                  COrder* in_order = listOrders.At(pos);
                  npos = new Position(in_order.OrderId(), in_order.Deals(), order.OrderId(), order.Deals());
                  HistoryPos.Add(npos);     
               }
               delete sorder;
            }
            //ќткрывающий ордер не найден? - «начит это открыта€ позици€
            if(fticket == -1 || pos == -1)
            {
               npos = new Position(order.OrderId(), order.Deals());
               ActivePos.Add(npos);
            }
            //”ведомл€ем о создании новой позиции
            if(npos != NULL)
            {
               EventCreatePos* create_pos = new EventCreatePos(EVENT_FROM_UP, "HP API", npos);
               EventExchange::PushEvent(create_pos);
               delete create_pos;
            }
         }
      }
      
      ///
      /// —писок активных позиций.
      ///
      CArrayObj* ActivePos;
      ///
      /// —писок исторических, закрытых позиций.
      ///
      CArrayObj* HistoryPos;
      ///
      /// —писок тикетов всех ордеров.
      ///
      CArrayLong* ListTickets;
};