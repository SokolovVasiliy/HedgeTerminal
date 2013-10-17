#include <Object.mqh>
#include "..\Time.mqh"
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
///
/// Статус позиции/Сделки.
///
enum ENUM_POSITION_STATUS
{
   ///
   /// Позиция открыта.
   ///
   POSITION_STATUS_OPEN,
   ///
   /// Позиция закрыта.
   ///
   POSITION_STATUS_CLOSED
};

///
/// Возможный режим сортировки списка позиций.
///
enum ENUM_POSITION_SORT
{
   POSITION_SORT_MAGIC,
   POSITION_SORT_SYMBOL,
   POSITION_SORT_ENTRY_ORDERID,
   POSITION_SORT_ENTRY_DATE,
   POSITION_SORT_ENTRY_PRICE,
   POSITION_SORT_ENTRY_COMMENT,
   POSITION_SORT_EXIT_ORDERID,
   POSITION_SORT_EXIT_PRICE,
   POSITION_SORT_EXIT_DATE,
   POSITION_SORT_EXIT_COMMENT,
   POSITION_SORT_TYPE,
   POSITION_SORT_VOL,
   POSITION_SORT_STOPLOSS,
   POSITION_SORT_TAKEPROFIT,
   POSITION_SORT_LASTPRICE,
   POSITION_SORT_PROFIT,
   POSITION_SORT_SWAP
};
///
/// Загружает историю ордеров
///
void LoadHistory(void)
{
   HistorySelect(D'1970.01.01', TimeCurrent());
}

class Deal : CObject
{
   public:
      ///
      /// Создает новую сделку и заполняет ее параметры, на основе ее номера тикета.
      ///
      Deal(ulong dticket)
      {
         date = new CTime();
         LoadHistory();
         if(!HistoryDealSelect(dticket))
         {
            LogWriter("Deal with ticket #" + (string)dticket + " not find.", MESSAGE_TYPE_ERROR);
            return;
         }
         ticket = dticket;
         volume = HistoryDealGetDouble(dticket, DEAL_VOLUME);
         date = HistoryDealGetInteger(dticket, DEAL_TIME_MSC);
         price = HistoryDealGetDouble(dticket, DEAL_PRICE);
         commission = HistoryDealGetDouble(dticket, DEAL_COMMISSION);
         type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dticket, DEAL_TYPE);
         symbol = HistoryDealGetString(dticket, DEAL_SYMBOL);
         comment = HistoryDealGetString(dticket, DEAL_COMMENT);
      }
      ~Deal()
      {
         delete date;
      }
      ulong Ticket(){return ticket;}
      CTime* Date(){return date;}
      double Volume(){return volume;}
      double Comission(){return commission;}
      double Price(){return price;}
      ENUM_DEAL_TYPE DealType(){return type;}
      string Symbol(){return symbol;}
      ///
      /// Возвращает прибыль сделки.
      ///
      double Profit()
      {
         double profit;
         switch(type)
         {
            case DEAL_TYPE_BUY:
               return CurrentPrice() - Price();
            case DEAL_TYPE_SELL:
               return Price() - CurrentPrice();
            default:
                HistoryDealSelect(ticket);
                profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                return profit;
         }
         return 0.0;
      }
      ///
      /// Возвращает текущую цену инструмента, по которому открыта позиция
      ///
      double CurrentPrice()
      {
         double last_price;
         //Четные значения - покупка, нечетные - продажа.
         if(type == DEAL_TYPE_BUY)
            last_price = SymbolInfoDouble(symbol, SYMBOL_BID);
         else
            last_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
         return last_price;
      }
      ///
      /// Конвертирует профит позиции в строковое представление профита
      ///
      string ProfitAsString()
      {
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
         double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
         string points = DoubleToString(Profit()/point, 0) + "p.";
         return points;
      }
   private:
      ///
      /// Уникальный идентификатор сделки.
      ///
      ulong ticket;
      ///
      /// Время совершения сделки.
      ///
      CTime* date; 
      ///
      /// Объем совершенной сделки.
      ///
      double volume;
      ///
      /// Цена, по которой была совершена сделка.
      ///
      double price;
      ///
      /// Комиссия по сделки.
      ///
      double commission;
      ///
      /// Тип сделки.
      ///
      ENUM_DEAL_TYPE type;
      ///
      /// Имя символа, по кторому произведена сделка.
      ///
      string symbol;
      ///
      /// Комментарий к сделке.
      ///
      string comment;
};
///
/// Позиция.
///
class Position : CObject
{
   public:
      
      Position(ulong in_ticket, CArrayLong* in_deals, ulong out_ticket, CArrayLong* out_deals)
      {
         Init();
      }
      Position(ulong in_ticket, CArrayLong* in_deals)
      {
         Init();
         InitPosition(in_ticket, in_deals);
      }
      ~Position()
      {
         delete entryDate;
         delete exitDate;
         int total = entryDeals.Total();
         for(int i = 0; i < total; i++)
         {
            Deal* deal = entryDeals.At(i);
            delete deal;
         }
         entryDeals.Clear();
         for(int i = 0; i < exitDeals.Total(); i++)
         {
            Deal* deal = exitDeals.At(i);
            delete deal;
         }
         exitDeals.Clear();
      }
      ///
      /// Возвращает статус позиции.
      ///
      ENUM_POSITION_STATUS Status(){return status;}
      ///
      /// Возвращает направление позиции.
      ///
      ENUM_ORDER_TYPE PositionType(){return type;}
      ///
      /// Возвращает магический номер эксперта, открывшего позицию.
      ///
      long Magic(){return magic;}
      ///
      /// Возвращает название инструмента, по которому открыта позиция.
      ///
      string Symbol(){return symbol;}
      ///
      /// Возвращает идентификатор позиции.
      ///
      ulong EntryOrderID(){return entryOrderId;}
      ///
      /// Возвращает объем позиции.
      ///
      double Volume(){return volume;}
      ///
      /// Возвращает время входа в позицию.
      ///
      CTime* EntryDate(){return entryDate;}
      ///
      /// Возвращает цену входа в позицию.
      ///
      double EntryPrice(){return entryPrice;}
      ///
      /// Возвращает дату выхода из позиции.
      /// Возвращает ноль, если позиция открыта.
      ///
      CTime* ExitDate(){return exitDate;}
      ///
      /// Возвращает цену выхода из позиции.
      /// Возвращает ноль, если позиция открыта.
      ///
      double ExitPrice(){return exitPrice;}
      ///
      /// Возвращает уровень защитной остановки позиции.
      ///
      double StopLoss(){return stopLoss;}
      ///
      /// Возвращает уровень взятия прибыли позиции.
      ///
      double TakeProfit(){return takeProfit;}
      ///
      /// Возвращает текущую цену инструмента, по которому открыта позиция
      ///
      double CurrentPrice()
      {
         double last_price;
         //Четные значения - покупка, нечетные - продажа.
         if(type % 2 == 0)
            last_price = SymbolInfoDouble(symbol, SYMBOL_BID);
         else
            last_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
         return last_price;
      }
      ///
      /// Возвращает накопленный своп позиции.
      ///
      double Swap(){return swap;}
      ///
      /// Возвращает прибыль позиции.
      ///
      double Profit()
      {
         switch(type)
         {
            case ORDER_TYPE_BUY:
            case ORDER_TYPE_BUY_STOP:
            case ORDER_TYPE_BUY_LIMIT:
            case ORDER_TYPE_BUY_STOP_LIMIT:
               return CurrentPrice() - EntryPrice();
            default:
               return EntryPrice() - CurrentPrice();   
         }
         return 0.0;
      }
      ///
      /// Конвертирует профит позиции в строковое представление профита
      ///
      string ProfitAsString()
      {
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
         double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
         string points = DoubleToString(Profit()/point, 0) + "p.";
         return points;
      }
      ///
      /// Возвращает комментарий который был введен при открытии позиции.
      ///
      string EntryComment(){return entryComment;}
      ///
      /// Возвращает комментарий который был введен при закрытии позиции.
      ///
      string ExitComment(){return exitComment;}
      CArrayObj* EntryDeals()
      {
         return GetPointer(entryDeals);
      }
      CArrayObj* ExitDeals()
      {
         return GetPointer(exitDeals);
      }
      virtual int Compare(const CObject *node,const int mode=0) const
      {
         const Position* pos = node;
         int LESS = -1;
         int GREATE = 1;
         int EQUAL = 0;
         switch(mode)
         {
            case POSITION_SORT_ENTRY_ORDERID:
               if(entryOrderId > pos.EntryOrderID())
                  return GREATE;
               if(entryOrderId > pos.EntryOrderID())
                  return LESS;
               if(entryOrderId == pos.EntryOrderID())
                  return EQUAL;
               break;
            case POSITION_SORT_ENTRY_DATE:
               if(entryDate > pos.EntryDate())
                  return GREATE;
               if(entryDate > pos.EntryDate())
                  return LESS;
               if(entryDate == pos.EntryDate())
                  return EQUAL;
               break;
            default:
               return 0;
         }
         return 0;
      }
   private:
      ///
      /// Создает новую активную позицию.
      ///
      void InitPosition(ulong in_ticket, CArrayLong* deals)
      {
         LoadHistory();
         if(!HistoryOrderSelect(in_ticket))
         {
            LogWriter("History position not find", MESSAGE_TYPE_ERROR);
            return;            
         }
         magic = HistoryOrderGetInteger(in_ticket, ORDER_MAGIC);
         entryOrderId = in_ticket;
         symbol = HistoryOrderGetString(in_ticket, ORDER_SYMBOL);
         //Лучшая цена входа
         double best_price = HistoryOrderGetDouble(in_ticket, ORDER_PRICE_OPEN);
         // Если позиция имеет сделки, то ее тип меняется на sell или buy, а
         // объем и время входа узнаются из сделок.
         ENUM_ORDER_TYPE op_type = (ENUM_ORDER_TYPE)HistoryOrderGetInteger(in_ticket, ORDER_TYPE);
         if(deals != NULL && deals.Total()>0)
         {
            switch(op_type)
            {
               case ORDER_TYPE_BUY:
               case ORDER_TYPE_BUY_STOP:
               case ORDER_TYPE_BUY_LIMIT:
               case ORDER_TYPE_BUY_STOP_LIMIT:
                  type = ORDER_TYPE_BUY;
                  break;
               default:
                  type = ORDER_TYPE_SELL;
            }
            //Для стоповых и рыночных ордеров лучшая цена указана в ордере. 
            //Если лучшая цена не указана, либо используются лимитные
            //ордера, лучшая цена равна наиболее выгодной сделке.
            bool find = (NormalizeDouble(best_price, 6) == 0.000000) ||
                        (op_type == ORDER_TYPE_BUY_LIMIT) || (op_type == ORDER_TYPE_SELL_LIMIT);
            //Тикеты сделок превращаются в классы сделок.
            int total = deals.Total();
            for(int i = 0; i < total; i++)
            {
               ulong dticket = deals.At(i);
               Deal* cdeal = new Deal(dticket);
               entryDeals.Add(cdeal);
               volume += cdeal.Volume();
               //Ищем самое раннее время совершения первой сделки
               entryDate = HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE_MSC);
               /*if(op_type == ORDER_TYPE_BUY || op_type == ORDER_TYPE_SELL)
               {
                  entryDate = HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE_MSC);
               }
               else if(i == 0)entryDate.operator=(cdeal.Date());
               else if(entryDate > cdeal.Date())
                  entryDate.operator=(cdeal.Date());
               */
               //entryDate.operator<(cdeal.Date());
               //Ищем самую выгодную цену сделки
               if(find && type == ORDER_TYPE_BUY)
               {
                  if(i == 0)best_price = cdeal.Price();
                  else if(cdeal.Price() < best_price)
                     best_price = cdeal.Price();
               }
               else if(find && type == ORDER_TYPE_SELL)
               {
                  if(i == 0)best_price = cdeal.Price();
                  else if(cdeal.Price() > best_price)
                     best_price = cdeal.Price();
               }
            }
         }
         //Имеем дело с отложенными ордерами
         else
         {
            volume = HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_INITIAL) - HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_CURRENT);
            entryDate = HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE) * 1000;
         }
         entryPrice = best_price;
         entryComment = HistoryOrderGetString(in_ticket, ORDER_COMMENT);
         type = op_type;
      }
      
      void ClosePosition()
      {
         ;
      }
      void Init()
      {
         entryDate = new CTime();
         exitDate = new CTime();
      }
      ENUM_POSITION_STATUS status;
      ENUM_ORDER_TYPE type;
      long magic;
      string symbol;
      ulong entryOrderId;
      ulong exitOrderId;
      double volume;
      ///
      /// Время входа в позицию.
      ///
      CTime* entryDate;
      double entryPrice;
      CTime* exitDate;
      double exitPrice;
      double stopLoss;
      double takeProfit;
      double swap;
      double profit;
      string entryComment;
      string exitComment;
      ///
      /// Список сделок, открывающих текущую позицию.
      ///
      CArrayObj entryDeals;
      ///
      /// Список сделок, закрывающих текущую позицию.
      ///
      CArrayObj exitDeals;
};