#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
#include "position.mqh"
#include "events.mqh"
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
            case EVENT_TIMER:
               OnTimer(event);
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
         LoadHistory();
         //«аносим все доступные ордера в список ордеров
         LoadHistory();
         int total = HistoryOrdersTotal();
         for(int i = 0; i < total; i++)
            ListTickets.Add(HistoryOrderGetTicket(i));
         total = OrdersTotal();
         for(int i = 0; i < total; i++)
            ListTickets.Add(OrderGetTicket(i));
         //—хлопываем ордера в открытые и закрытые
         total = ListTickets.Total();
         Position* pos = NULL;
         for(int i = 0; i < total; i++)
         {
            ulong ticket1 = ListTickets.At(i);
            for(int k = 0; k < total; k++)
            {
               if(k == i)continue;
               ulong ticket2 = ListTickets.At(i);
               // ticket2 €вл€етс€ закрывающим ордером ticket1?
               if(ticket2 == FaeryMagic(ticket1))
               {
                  pos = new Position(ticket1, ticket2);
               }
               //ticket1 €вл€етс€ закрывающим ордером ticket2
               if(ticket1 == FaeryMagic(ticket2))
               {
                  pos = new Position(ticket2, ticket1);
               }
            }
            //≈сли закрывающий ордер не найден, то это - открыта€ позици€.
            pos = new Position(ticket1);
         }
         if(pos == NULL)return;
         if(pos.Status() == POSITION_STATUS_OPEN)
            ActivePos.Add(pos);
         else
            HistoryPos.Add(pos);
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
         int total = ActivePos.Total();
         for(int i = 0; i < total; i++)
            EventChartCustom(MAIN_WINDOW, EVENT_CHANGE_POS, i, 0, "");
      }
      //
      // ¬озвращает magic закрывающего ордера. Ќоль - в случае неудачи.
      // ticket - тикет инициализирующего ордера.
      //
      ulong FaeryMagic(ulong ticket)
      {
         // јнализируем только сработавшие ордера попавшие в историю, потому что у отложенных,
         // активных ордеров не может быть закрывающего ордера.
         
         /*if(!HistoryOrderSelect(ticket))
         {
            Print("HedgePanel: Order with ticket #" +(string)ticket + " not find");
            return 0;
         }*/
         return ticket;
      }
      ///
      /// «агружает историю ордеров
      ///
      void LoadHistory(void)
      {
         HistorySelect(D'1970.01.01', TimeCurrent());
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