//#include <Arrays\ArrayObj.mqh>
//#include <Arrays\ArrayLong.mqh>
#include <Trade\Trade.mqh>
#include "..\Time.mqh"

class Position;
class Deal;
class Order;
#ifdef HEDGE_PANEL
class PosLine;
#endif

///
/// Признаки, по которым может быть отсортирован список ордеров.
///
enum ENUM_SORT_TRANSACTION
{
   ///
   /// Сортировка по магическому номеру.
   ///
   SORT_MAGIC,
   ///
   /// Сортировка по уникальному идентификатору транзакции, получаемому от функции GetId().
   ///
   SORT_ORDER_ID,
   ///
   /// Сортировка по исходящему тикету позиции или тикиту закрывающего трейда.
   ///
   SORT_EXIT_ORDER_ID,
   ///
   /// Сортировка по времени совершения трейда, выставлению ордера, активирования позиции.
   ///
   SORT_TIME,
   ///
   /// 
   ///
   SORT_EXIT_TIME
};

//#include "..\Elements\TablePositions.mqh"
///
/// Тип транзакции.
///
enum ENUM_TRANSACTION_TYPE
{
   
   ///
   /// Транзакция является позицией.
   ///
   TRANS_POSITION,
   ///
   /// Транзакция является ордером.
   ///
   TRANS_ORDER,
   ///
   /// Транзакция является сделкой.
   ///
   TRANS_DEAL,
   ///
   /// Облегченная версия универсальной транзакции содержащая
   /// уникальный идентификатор.
   ///
   TRANS_ABSTR
};

///
/// Направление в котором совершена транзакция.
///
enum ENUM_DIRECTION_TYPE
{
   DIRECTION_NDEF,
   DIRECTION_LONG,
   DIRECTION_SHORT
};

///
/// Предоставляет абстрактную транзакцию: сделку, ордер, либо любую другую операцию на счете.
///
class Transaction : public CObject
{
   public:
      ///
      /// Возвращает тип транзакции.
      ///
      ENUM_TRANSACTION_TYPE TransactionType(){return transType;}
      
      ///
      /// Возвращает название символа, по которому была совершена сделка.
      ///
      virtual string Symbol()
      {
         return symbol;
      }
      ///
      /// Возвращает магический номер эксперта, которому принадлежит данная транзакция.
      ///
      virtual ulong Magic()
      {
         return 0;
      }
      ///
      /// Возвращает текущую цену инструмента, по которому совершена транзакция.
      ///
      virtual double CurrentPrice()
      {
         double price = 0.0;
         //Имеем дело с покупками?
         if(Direction() == DIRECTION_LONG)
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_BID);
         else if(Direction() == DIRECTION_SHORT)
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_ASK);
         else
            price = 0.0;
         return NormalizePrice(price);
      }
      ///
      /// Нормализует цену в соответствии с количеством знаков текущего инструмента.
      ///
      double NormalizePrice(double price)
      {
         if(this.Symbol() == NULL || this.Symbol() == "")
            return price;
         int digits = (int)SymbolInfoInteger(this.Symbol(), SYMBOL_DIGITS);
         return NormalizeDouble(price, digits);
      }
      ///
      /// Возвращает фактический выполненный объем транзакции.
      ///
      virtual double VolumeExecuted()
      {
         return 0.0;
      }
      ///
      /// Возвращает профит в пунктах инструмента.
      ///
      virtual double ProfitInPips()
      {
         //double cp = 
         double delta = CurrentPrice() - EntryExecutedPrice();
         if(Direction() == DIRECTION_SHORT)
            delta *= -1.0;
         return delta;
      }
      ///
      /// Возвращает профит в пунктах инструмента.
      ///
      virtual double ProfitInCurrency()
      {
         double pips = ProfitInPips();
         //Стоимость одного тика в валюте депозита.
         double tickValueCurrency = 0.0;
         double point = SymbolInfoDouble(this.Symbol(), SYMBOL_POINT);
         if(point == 0.0)return 0.0;
         pips /= point;
         symbolInfo.Name(this.Symbol());
         if(pips < 0.0)
            tickValueCurrency = symbolInfo.TickValueLoss();
         else
            tickValueCurrency = symbolInfo.TickValueProfit();
         double currency = tickValueCurrency * pips * VolumeExecuted();
         return currency;
      }
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         return DIRECTION_NDEF;
      }
      ///
      /// Комиссия за совершение транзакции.
      ///
      virtual double Commission()
      {
         return 0.0;
      }
      ///
      /// Возвращает профит в виде текстового представления.
      ///
      string ProfitAsString()
      {
         double d = ProfitInPips();
         int digits = (int)SymbolInfoInteger(this.Symbol(), SYMBOL_DIGITS);
         double point = SymbolInfoDouble(this.Symbol(), SYMBOL_POINT);
         string points = point == 0 ? "0p." : DoubleToString(d/point, 0) + "p.";
         return points;
      }
      ///
      /// Возвращает цену инструмента в виде строки.
      ///
      string PriceToString(double price)
      {
         int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
         string sprice = DoubleToString(price, digits);
         return sprice;
      }
      string VolumeToString(double vol)
      {
         double step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
         double mylog = MathLog10(step);
         string svol = mylog < 0 ? DoubleToString(vol,(int)(mylog*(-1.0))) : DoubleToString(vol, 0);
         return svol;
      }
      ///
      /// Возвращает количество знаков после запятой в цене инструмента, по которому была совершена транзакция.
      ///
      int InstrumentDigits()
      {
         return (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
      }
      ///
      /// Переопределяем сравнение.
      ///
      virtual int Compare(  CObject *node,   int mode=0)
      {
           Transaction* myTrans = node;
         ulong nodeValue = myTrans.GetCompareValueInt((ENUM_SORT_TRANSACTION)mode);
         ulong myValue = GetCompareValueInt((ENUM_SORT_TRANSACTION)mode);
         if(myValue > nodeValue)return GREATE;
         if(myValue < nodeValue)return LESS;
         return EQUAL;
      }
      
      virtual ulong GetCompareValueInt(ENUM_SORT_TRANSACTION sortType)
      {
         switch(sortType)
         {
            case SORT_MAGIC:
               return Magic();
            case SORT_ORDER_ID:
            default:
               return currId;
         }
         return 0;
      }
      ///
      /// Получает уникальный идентификатор транзакции.
      ///
      ulong GetId(){return currId;}
      
      ///
      /// Возвращает тип транзакции в виде строки.
      ///
      virtual string TypeAsString()
      {
         return "transaction";
      }
      
   protected:
      ///
      /// Возвращает цену входа трназакции на рынок.
      ///
      virtual double EntryExecutedPrice(){return 0.0;}
      ///
      /// Возвращает тип транзакции.
      ///
      Transaction(ENUM_TRANSACTION_TYPE trType){transType = trType;}
      
      ///
      /// Устанавливает уникальный идентификатор транзакции.
      ///
      void SetId(ulong id){currId = id;}
      
      ///
      /// Возвращает время срабатывания ордера/совершения сделки.
      ///
      virtual long TimeExecuted()
      {
         CTime* ctime = NULL;
         SelectHistoryTransaction();
         if(transType == TRANS_POSITION)
         {
            long msc = HistoryOrderGetInteger(currId, ORDER_TIME_DONE_MSC);
            return msc;
            //ctime = new CTime(msc);
            //return ctime;
         }
         if(transType == TRANS_DEAL)
         {
            long msc = HistoryDealGetInteger(currId, DEAL_TIME_MSC);
            return msc;
            //ctime = new CTime(msc);
            //return ctime;
         }
         return 0;
      }
      ///
      /// Выбирает текущую транзакцию для дальнейшей работы с ней.
      ///
      void SelectHistoryTransaction()
      {
         LoadHistory();
         if(transType == TRANS_DEAL)
            HistoryDealSelect(currId);
         if(transType == TRANS_POSITION)
            HistoryOrderSelect(currId);
      }
      ///
      /// Выбирает текущую транзакцию для дальнейшей работы с ней.
      ///
      void SelectPendingTransaction()
      {
         if(transType == TRANS_ORDER ||
            transType == TRANS_POSITION)
            bool t = OrderSelect(currId);   
      }
      
      /*Для ускореня рассчетов, запоминает ранее рассчитанные цены, которые в дальнейшем будут неизменны*/
      ///
      /// Средняя эффективная цена по которой была совершена сделка/транзакция.
      ///
      double entryPriceExecuted;
      ///
      /// Истина, если цена совершения транзакции была рассчитана.
      ///
      bool isEntryPriceExecuted;
      ///
      /// Символ, по которому совершена тразакция (запоминается для производительности).
      ///
      string symbol;
      ///
      /// Истина, если название инструмента было получено ранее и запомнено.
      ///
      bool isSymbol;
      ///
      /// Загружает историю ордеров и сделок, если она не загружена.
      ///
      void LoadHistory(void)
      {
         if(HistoryDealsTotal() < 2)
            HistorySelect(D'1970.01.01', TimeCurrent()+100);
      }
      //ENUM_DIRECTION_TYPE direction;
   private:
      
      ///
      /// Тип транзакции.
      ///
      ENUM_TRANSACTION_TYPE transType;
      ///
      /// Текущий идентификатор транзакции, с которым работают функции.
      ///
      ulong currId;
      ///
      /// Вспомогательный инструмент.  
      ///
      CSymbolInfo symbolInfo;
};

///
/// Виртуальная транзакция для быстрого поиска.
///
class TransId : public Transaction
{
   public:
      TransId(ulong id) : Transaction(TRANS_ABSTR)
      {
         SetId(id);
      }
};

#include "Deal.mqh"
#include "Order.mqh"
#include "Position.mqh"



