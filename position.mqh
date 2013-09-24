#include <Object.mqh>
#include "Log.mqh"
///
/// Статус позиции.
///
enum ENUM_POSITION_STATUS
{
   POSITION_STATUS_OPEN,
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
/// Позиция.
///
class Position : CObject
{
   public:
      Position(ENUM_POSITION_STATUS myStatus,
               ENUM_POSITION_TYPE myType,
               long myMagic,
               string mySymbol,
               long myOrderId,
               double myVolume,
               datetime myEntryTime,
               double myEntryPrice,
               datetime myExitTime,
               double myExitPrice,
               string myEntryComment)
      {
         magic = myMagic;
         status = myStatus;
         type = myType;
         symbol = mySymbol;
         entryOrderId = myOrderId;
         volume = myVolume;
         entryDate = myEntryTime;
         entryPrice = myEntryPrice;
         exitDate = myExitTime;
         exitPrice = myExitPrice;
         entryComment = myEntryComment;
      }
      ///
      /// Создает новую историческую позицию на основании входящего и исходящего ордера
      ///
      Position(ulong in_ticket, ulong out_ticket)
      {
         Init(in_ticket);
         status = POSITION_STATUS_CLOSED;
         volume = HistoryOrderGetDouble(out_ticket, ORDER_VOLUME_CURRENT);
         exitPrice = HistoryOrderGetDouble(out_ticket, ORDER_PRICE_OPEN);
         exitComment = HistoryOrderGetString(out_ticket, ORDER_COMMENT);
      }
      
      Position(ulong in_ticket)
      {
         Init(in_ticket);
      }
      ///
      /// Возвращает статус позиции.
      ///
      ENUM_POSITION_STATUS Status(){return status;}
      ///
      /// Возвращает направление позиции.
      ///
      //ENUM_POSITION_TYPE Type(){return type;}
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
      datetime EntryDate(){return entryDate;}
      ///
      /// Возвращает цену входа в позицию.
      ///
      double EntryPrice(){return entryPrice;}
      ///
      /// Возвращает дату выхода из позиции.
      /// Возвращает ноль, если позиция открыта.
      ///
      datetime ExitDate(){return exitDate;}
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
         //LoadHistory();
         //OrderSelect(entryOrderId);
         //return OrderGetDouble(ORDER_PRICE_CURRENT);
         double last_price;
         if(type == POSITION_TYPE_BUY)
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
         if(type == POSITION_TYPE_BUY)
         {
            return CurrentPrice() - EntryPrice();
         }
         if(type == POSITION_TYPE_SELL)
         {
            return EntryPrice() - CurrentPrice();
         }
         return 0.0;
      }
      ///
      /// Возвращает комментарий который был введен при открытии позиции.
      ///
      string EntryComment(){return entryComment;}
      ///
      /// Возвращает комментарий который был введен при закрытии позиции.
      ///
      string ExitComment(){return exitComment;}
      ///
      /// Список сделок открывших позицию.
      ///
      Position* ListOpenDeals;
      ///
      /// Список сделок закрывших историческую позицию.
      ///
      Position* ListClosedDeals;
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
      void Init(ulong in_ticket)
      {
         LoadHistory();
         if(!HistoryOrderSelect(in_ticket))
         {
            LogWriter("History position not find", MESSAGE_TYPE_ERROR);
            return;            
         }
         status = POSITION_STATUS_OPEN;
         magic = HistoryOrderGetInteger(in_ticket, ORDER_MAGIC);
         entryOrderId = in_ticket;
         symbol = HistoryOrderGetString(in_ticket, ORDER_SYMBOL);
         volume = HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_INITIAL) - HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_CURRENT);
         entryDate = (datetime)HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE);
         entryPrice = HistoryOrderGetDouble(in_ticket, ORDER_PRICE_OPEN);
         entryComment = HistoryOrderGetString(in_ticket, ORDER_COMMENT);
      }
      ///
      /// Загружает историю ордеров
      ///
      void LoadHistory(void)
      {
         HistorySelect(D'1970.01.01', TimeCurrent());
      }
      ENUM_POSITION_STATUS status;
      ENUM_POSITION_TYPE type;
      long magic;
      string symbol;
      ulong entryOrderId;
      ulong exitOrderId;
      double volume;
      datetime entryDate;
      double entryPrice;
      datetime exitDate;
      double exitPrice;
      double stopLoss;
      double takeProfit;
      double swap;
      double profit;
      string entryComment;
      string exitComment;
};