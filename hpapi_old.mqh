//+------------------------------------------------------------------+
//|                                                       hpanel.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2013, Vasiliy Sokolov, Hedge Panel©"
//#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Arrays\List.mqh>
//#include <hpfdef.mqh>
//
// Информация о текущей открытой позиции
//
class ActivePosition : CObject
{
   public:
      //Тикет ордера
      ulong TicketEntry;
      //Текущий объем позиции
      double VolumeCurrent;
};

class HistoryPosition : CObject
{
   public:
      //Тикет ордера инициализирующий позицию.
      ulong TicketEntry;
      //Тикет ордера закрывающий позицию.
      ulong TicketExit;
      //Объем позиции
      double Volume;
};


class CHedge
{
   public:
                  CHedge(void);
      int         PositionsCount(void);                  // Возвращает количество активных позиций.
      int         HistoryPositionsCount(void);           // Возвращает количество исторических позиций.
      ulong       OrderGetTicketEntry(int index);        // Возвращает тикет входящего ордера активной позиции с индексом index.
      ulong       HistoryOrderGetTicketEntry(int index); // Возвращает тикет входящего ордера исторической позиции с индексом index.
      ulong       HistoryOrderGetTicketExit(int index);  // Возвращает тикет исходящего ордера исторической позиции с индексом indrx.
      bool        PositionClose(int index,               // Закрывает открытую позицию противоположенным ордером.
                                MqlTradeRequest &treq,
                                MqlTradeResult &trez); 
   private:
      string      Label;
      CList       ListActivePos;                         // Заполненный список активных позиций.
      CList       ListHistoryPos;                        // Заполненный список исторических позиций.
      
      ulong       IsHistoryEnterOrder(ulong ticket);    
      ulong       IsHistoryExitOrder(ulong ticket);
      bool        AddActivePos(ulong ticket);   
      
      ulong       FaeryMagic(ulong ticket);             // Возвращает magic инициализурующего ордера.
      ulong       FaeryTicket(ulong magic);             // Возвращает ticket соответствующий маджику.
      void        LoadHistory();                         // Загружает историю ордеров.   
};

//
// Конструктор
//
void CHedge::CHedge()
{
      Label = "HedgePanel©";
      Print(__FUNCTION__);
      // Анализируем только исторические ордера, т.к. все текущие ордера являются отложенными 
      // и не являются ордерами позиций.
      LoadHistory();
      //Разносим все исторические ордера в активные и исторические
      int total = HistoryOrdersTotal();
      Print("Загружаю " + (string)total + " позиций.");
      int i = 0;
      while(i < total)
      {
         LoadHistory();
         total = HistoryOrdersTotal();
         ulong ticket = HistoryOrderGetTicket(i);
         i++;
         if(ticket == 0)
         {
            Print("HedgePanel::CHedge: order with ticket #" + (string)ticket + " not find");
            continue;
         }
         //Если текущий ордер не принадлежит к открывающим и закрывающим ордерам
         //исторических позиций, значит он ордер активной позиции.
         if(IsHistoryEnterOrder(ticket) == 0 &&
            IsHistoryExitOrder(ticket) == 0)
         {
            AddActivePos(ticket);
         }
      }
      Print("Из них активных: " + (string)ListActivePos.Total(), " завершенных: " + (string)ListHistoryPos.Total());
}

///
/// Загружает историю ордеров
///
void CHedge::LoadHistory(void)
{
   HistorySelect(D'1970.01.01', TimeCurrent());
}
//
// Закрывает текущую позицию торговым приказом описанным в структуре treq.
// treq - структура, описывающая закрывающий ордер.
// trez - структура ответа после выставления закрывающего ордера.
// Истина, если закрывающий ордер заполнен верно и непротиворечет открытой позиции.
//
bool CHedge::PositionClose(int index, MqlTradeRequest &treq, MqlTradeResult &trez)
{
   // 1. Позиция должна существовать
   if(ListActivePos.Total() <= index)
   {
      Print(Label + ": Position with index " + (string)index + " not find");
   }
   // 1. Направление должно быть противоположено открывающему ордеру.
   LoadHistory();
   ActivePosition *pos = ListActivePos.GetNodeAtIndex(index);
   if(!HistoryOrderSelect(pos.TicketEntry))
   {
      Print(Label + ": Error! ticket #" + pos.TicketEntry + " not find");
      return false;
   }
   int mode = (int)HistoryOrderGetInteger(pos.TicketEntry, ORDER_TYPE);
   //Направление текущей позиции (тип инициализирующего ордера может быть любым)
   int posdir = 0;
   switch(mode)
   {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_STOP_LIMIT:
         posdir = 1;
         break;
      default:
         posdir = -1;
         break;   
   }
   //направление поступившего приказа (только либо покупка либо продажа по рынку)
   int reqdir = 0;
   if(treq.type == ORDER_TYPE_BUY)
      reqdir = 1;
   else if(treq.type == ORDER_TYPE_SELL)
      reqdir = -1;
   if(reqdir == 0)
   {
      Print(Label + ": Pending orders are not supported");
      return false;
   }
   // Оба направления должны быть различны по знаку
   if((posdir > 0 && reqdir > 0) ||
      (posdir <0 && reqdir < 0))
   {
      Print(Label + ": Error! Your request must be closing the opposite direction than the position.");
      return false;
   }
   // 2. Объем должен быть не больше объема открвающего ордера
   double vol_init = HistoryOrderGetDouble(pos.TicketEntry, ORDER_VOLUME_INITIAL);
   double vol_notinit = HistoryOrderGetDouble(pos.TicketEntry, ORDER_VOLUME_CURRENT);
   double vol_fact = vol_init - vol_notinit;
   double vol_req = treq.volume;
   ulong ticket = pos.TicketEntry;
   if(vol_fact < treq.volume)
   {
      Print(Label + ": Error! The volume of closing of the transaction must not be greater than the volume position.");
      return false;
   }
   // 3. Меняем маджик на правильный. Узнаем тикет открывающего ордера и шифруем его в маджиг закрывающего.
   treq.magic = FaeryMagic(pos.TicketEntry);
   bool res = OrderSend(treq, trez);
   //Переносим закрытую позицию в список исторических позиций.
   Print("Position close done! result = " + (string)res);
   if(res)
   {
      string posdirs = "none";
      string reqdirs = "none";
      if(posdir == 1)posdirs = "buy";
      else posdirs = "sell"; 
      if(reqdir == 1)reqdirs = "buy";
      else reqdirs = "sell"; 
      Print("Pos. " + posdirs + " #" + pos.TicketEntry + " with vol.: " + vol_fact + " was closed by order " + reqdirs + " #" + trez.order + " with vol.: " + trez.volume);
      //Если позиция закрыта полностью, удаляем ее из списка активных позиций
      if(vol_fact == trez.volume)
         ListActivePos.Delete(index);
      //Иначе, уменьшаяем ее текущий объем на объем зделки
      else
         pos.VolumeCurrent = pos.VolumeCurrent - trez.volume;
      //Теперь добавляем закрытую позицию в историю.
      HistoryPosition *hpos = new HistoryPosition();
      hpos.TicketEntry = pos.TicketEntry;
      hpos.TicketExit = trez.order;
      hpos.Volume = trez.volume;
      ListHistoryPos.Add(hpos);
   }
   return res;
}
//
// Возвращает тикет входящего ордера активной позиции по индексу index. 0 - если такой позиции нет.
// index - номер активной позиции в списке активных позиций.
//
ulong CHedge::OrderGetTicketEntry(int index)
{
   
   if(ListActivePos.Total() < index)
   {
      Print("HedgePanel: Position with #" + (string)index + " not find");
      return(0);
   }
   ActivePosition *pos = ListActivePos.GetNodeAtIndex(index);
   return(pos.TicketEntry);
}

//
// Возвращает тикет входящего ордера исторической позиции с индексом index. 0 - если такой позиции нет. 
// index - номер исторической позиции.
//
ulong CHedge::HistoryOrderGetTicketEntry(int index)
{
   if(ListHistoryPos.Total() <= index)
   {
      Print("HedgePanel: History position with #" + (string)index + " not find");
      return(0);
   }
   HistoryPosition *pos = ListHistoryPos.GetNodeAtIndex(index);
   return(pos.TicketEntry);
}
//
// Возвращает тикет исходящего ордера исторической позиции с индексом index. 0 - если такой позиции нет. 
// index - номер исторической позиции.
//
ulong CHedge::HistoryOrderGetTicketExit(int index)
{
   if(ListHistoryPos.Total() < index)
   {
      Print("HedgePanel: History position with #" + (string)index + " not find");
      return(0);
   }
   HistoryPosition *pos = ListHistoryPos.GetNodeAtIndex(index);
   return(pos.TicketExit);
}
//
// Возвращает количество активных позиций.
//
int CHedge::PositionsCount()
{
   return(ListActivePos.Total());
}

//
// Возвращает количество исторических позиций.
//
int CHedge::HistoryPositionsCount(void)
{
   return(ListActivePos.Total());
}

//
// Опредяляет, является ли текущий ордер, ордером открытия исторической позиции.
// Если текущий ордер является ордером открытия исторической позиции, возвращает
// тикет ордера закрывающего историческую позицию. В противном случае возвращает 0.
//
ulong CHedge::IsHistoryEnterOrder(ulong ticket)
{   
   // Если мы найдем ордер, чей Magic будет равен зашифрованному тикету текущего ордера,
   // то значит текущий ордер закрывающий.
   
   //Получаем magic который нам надо будет найти
   ulong magic = FaeryMagic(ticket);
   // Прежде убеждаемся, что текущий тикет еще не был найден
   int tfind = ListHistoryPos.Total();
   for(int i = 0; i < tfind; i++)
   {
      HistoryPosition *pos = ListHistoryPos.GetNodeAtIndex(i);
      if(pos.TicketEntry == ticket)
      {
         return (pos.TicketExit);
      }
   }
   LoadHistory();
   int total = HistoryOrdersTotal();
   for(int i = 0; i < total; i++)
   {
      ulong currt = HistoryOrderGetTicket(i);
      if(currt == 0)
      {
         Print("HedgePanel: Order with ticket #" + (string)ticket + " not find.");
         return 0;
      }
      //Закрывающий ордер найден, текущий ордер принадлежит исторической позиции.
      if(magic == OrderGetInteger(ORDER_MAGIC))
      {
         HistoryPosition *pos = new HistoryPosition();
         pos.TicketEntry = ticket;
         pos.TicketExit = currt;
         int rez = ListHistoryPos.Add(pos);
         if(rez == -1)
            Print("HedgePanel: Error! History position with opened order #" + (string)ticket + " not added.");
         return currt;
      }
   }
   return 0;
}

//
// Определяет, является ли текущий ордер, ордером закрытия исторической позиции.
// Если текущий ордер является ордером закрытия исторической позиции, возвращает
// тикет ордера открывающего историческую позицию. В противном случае возвращает 0.
//
ulong CHedge::IsHistoryExitOrder(ulong ticket)
{
   // Если мы найдем ордер, чей тикет будет равен зашифрованному маджику текущего ордера,
   // значит текущий ордер закрывающий.
   LoadHistory();
   int total = HistoryOrdersTotal();
   if(!HistoryOrderSelect(ticket))return(0);
   //Получаем тикет, который нам надо будет найти
   ulong fticket = FaeryTicket(OrderGetInteger(ORDER_MAGIC));
   // Прежде убеждаемся, что текущий тикет еще не был найден
   int tfind = ListHistoryPos.Total();
   for(int i = 0; i < tfind; i++)
   {
      HistoryPosition *pos = ListHistoryPos.GetNodeAtIndex(i);
      if(pos.TicketExit == ticket)
      {
         return (pos.TicketEntry);
      }
   }
   LoadHistory();
   //int total = HistoryOrdersTotal();
   for(int i = 0; i < total; i++)
   {
      ulong currt = HistoryOrderGetTicket(i);
      if(currt == 0)
      {
         Print("HedgePanel: Error! Order with ticket #" + (string)ticket + " not find.");
         return 0;
      }
      //Открывающий ордер найден, текущий ордер принадлежит исторической позиции.
      if(fticket == currt)
      {
         HistoryPosition *pos = new HistoryPosition();
         pos.TicketEntry = fticket;
         pos.TicketExit = currt;
         int rez = ListHistoryPos.Add(pos);
         if(rez == -1)
            Print("HedgePanel: Error! History position with closed order #" + (string)ticket + " not added.");
         return currt;
      }
   }
   return 0;
}

//
// Добавляет новую позицию с инициализирующим ордером c тикетом 'ticket'.
//
bool CHedge::AddActivePos(ulong ticket)
{
   if(!HistoryOrderSelect(ticket))
   {
      Print("HedgePanel: Order with ticket #" + (string)ticket + " not find.");
      return(false);
   }
   ActivePosition *pos = new ActivePosition();
   pos.TicketEntry = ticket;
   int rez = ListActivePos.Add(pos);
   if(rez == -1)
   {
      Print("HedgePanel: Error! Active position with opened order #" + (string)ticket + " not added.");
      return (false);
   }
   return(true);
}


//
// Возвращает magic закрывающего ордера. Ноль - в случае неудачи.
// ticket - тикет инициализирующего ордера.
//
ulong CHedge::FaeryMagic(ulong ticket)
{
   // Анализируем только сработавшие ордера попавшие в историю, потому что у отложенных,
   // активных ордеров не может быть закрывающего ордера.
   if(!HistoryOrderSelect(ticket))
   {
      Print("HedgePanel: Order with ticket #" +(string)ticket + " not find");
      return 0;
   }
   return ticket;
}


//
// Возвращает тикет открывающего ордера, который должен существовать, если текущий
// ордер является закрывающим. Ноль - в случае неудачи.
// ticket - тикет текущего ордера.
//
ulong CHedge::FaeryTicket(ulong ticket)
{
   // Анализируем только сработавшие ордера попавшие в историю, потому что если у текущего ордера
   // есть открывающий ордер, то он уже сработал и лежит в истории.
   if(!HistoryOrderSelect(ticket))
   {
      return 0;
   }
   return OrderGetInteger(ORDER_MAGIC);
}

//
// Класс позиций.
//
CHedge Positions;

//
// Возвращает количество активных позиций.
//
int PositionsCount() export
{
   return(Positions.HistoryPositionsCount());
}
//
// Возвращает количество исторических позиций. 
//
int HistoryPositionsCount() export
{
   return (Positions.HistoryPositionsCount());
}

//
// Возвращает тикет инициализирующего ордера активной позиции. 0 - если такая позиция или ордер не были найдены.
// index - номер открытой позиции в списке открытых позиций.
//
ulong OrderGetTicketEntry(int index) export
{
   return(Positions.OrderGetTicketEntry(index));
}

//
// Выбирает инициализирующий ордер исторической позиции.
// index - номер исторической позиции в списке исторических позиций.
//
ulong HistoryOrderGetTicketEntry(int index) export
{
   return(Positions.HistoryOrderGetTicketEntry(index));
}

//
// Выбирает закрывающий ордер исторической позиции.
// index - номер исторической позиции в списке исторических позиций.
//
ulong HistoryOrderGetTicketExit(int index) export
{
   return(Positions.HistoryOrderGetTicketExit(index));
}
//
// Закрывает открытую позицию с индексом index торговым приказом описанным структорой MqlTradeRequest
// treq - торговый приказ, описывающий правила закрытия текущей позиции.
// trez - результат выполнения торгового приказа
// Истина, если торговый приказ был выполнен, ложь, если запрос был заполнен некорректно.
bool PositionClose(int index, MqlTradeRequest &treq, MqlTradeResult &trez) export
{
   bool rez = Positions.PositionClose(index, treq, trez);
   return(rez);
}



