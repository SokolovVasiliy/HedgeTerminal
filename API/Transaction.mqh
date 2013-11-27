#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Trade\Trade.mqh>
#include "..\Time.mqh"
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
   /// Транзакция является сделкой.
   ///
   TRANS_DEAL
};

///
/// Направление в котором совершена транзакция.
///
enum ENUM_DIRECTION_TYPE
{
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
         return 0.0;
      }
      ///
      /// Возвращает профит в пунктах инструмента.
      ///
      virtual double ProfitInPips()
      {
         double delta = 0.0;
         delta = CurrentPrice() - EntryPriceExecuted();
         if(Direction() == DIRECTION_SHORT)
            delta *= -1.0;
         return delta;
      }
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         return DIRECTION_LONG;
      }
      ///
      /// Возвращает профит в виде текстового представления.
      ///
      string ProfitAsString()
      {
         double d = ProfitInPips();
         int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
         double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
         string points = DoubleToString(d/point, 0) + "p.";
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
   protected:
      ///
      /// Возвращает цену входа трназакции на рынок.
      ///
      virtual double EntryPriceExecuted(){return 0.0;}
      ///
      /// Возвращает тип транзакции.
      ///
      Transaction(ENUM_TRANSACTION_TYPE trType){transType = trType;}
      ///
      /// Получает уникальный идентификатор транзакции.
      ///
      ulong GetId(){return currId;}
      ///
      /// Устанавливает уникальный идентификатор транзакции.
      ///
      void SetId(ulong id){currId = id;}
      ///
      /// Функция возвращает цену, по которой была совершена сделка, либо цену, на которую было установлено срабатывание ордера.
      /// \param isPending - истина, если ордер необходимо искать среди отложенных, активных ордеров, и ложь, если ордер уже сработал,
      /// и информацию о нем необходимо искать в списки исторических ордеров.
      double Price(bool isPending = false)
      {
         double price = 0.0;
         if(!isPending){
            SelectHistoryTransaction();
            switch(transType)
            {
               case TRANS_DEAL:
                  return HistoryDealGetDouble(currId, DEAL_PRICE);
               case TRANS_POSITION:
                  return HistoryOrderGetDouble(currId, ORDER_PRICE_OPEN);
               default:
                  return 0.0;
            }
         }
         else
         {
            SelectPendingTransaction();
            switch(transType)
            {
               case TRANS_POSITION:
                  return OrderGetDouble(ORDER_PRICE_OPEN);
               // Отложенными могут быть только ордера, поэтому прочие торговые операции
               // искать в активных ордерах бессмысленно.
               default:
                  return 0.0;
            }
         }
      }
      ///
      /// Возвращает время срабатывания ордера/совершения сделки.
      ///
      CTime* TimeExecuted()
      {
         CTime* ctime = NULL;
         SelectHistoryTransaction();
         if(transType == TRANS_POSITION)
         {
            long msc = HistoryOrderGetInteger(currId, ORDER_TIME_DONE_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
         if(transType == TRANS_DEAL)
         {
            long msc = HistoryDealGetInteger(currId, DEAL_TIME_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
         return NULL;
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
         if(transType == TRANS_POSITION)
            OrderSelect(currId);
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
   private:
      
      ///
      /// Загружает историю ордеров и сделок.
      ///
      void LoadHistory(void)
      {
         HistorySelect(D'1970.01.01', TimeCurrent());
      }
      ///
      /// Тип транзакции.
      ///
      ENUM_TRANSACTION_TYPE transType;
      ///
      /// Текущий идентификатор транзакции, с которым работают функции.
      ///
      ulong currId;
      
      
      
      
};

///
/// Статус позиции/Сделки.
///
enum ENUM_POSITION_STATUS
{
   ///
   /// Позиция не определена.
   ///
   POSITION_STATUS_NULL,
   ///
   /// Позиция открыта.
   ///
   POSITION_STATUS_OPEN,
   ///
   /// Позиция закрыта.
   ///
   POSITION_STATUS_CLOSED,
   ///
   /// Позиция отложена.
   ///
   POSITION_STATUS_PENDING
};

///
/// Класс представляет позицию.
///
class Position : public Transaction
{
   public:
      ///
      /// Инициирует отложенную позицию.
      ///
      Position(ulong in_ticket) : Transaction(TRANS_POSITION)
      {
         InitPosition(in_ticket);
      }
      ///
      /// Инициирует активную позицию.
      ///
      Position(ulong in_ticket, CArrayLong* in_deals) : Transaction(TRANS_POSITION)
      {
         InitPosition(in_ticket, in_deals);
      }
      ///
      /// Инициирует завершенную позицию.
      ///
      Position(ulong in_ticket, CArrayLong* in_deals, ulong out_ticket, CArrayLong* out_deals) : Transaction(TRANS_POSITION)
      {
         InitPosition(in_ticket, in_deals, out_ticket, out_deals);
      }
      ///
      /// Возвращает направление, в котором совершена транзакция
      ///
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         if(PositionType() % 2 == 0)
            return DIRECTION_LONG;
         return DIRECTION_SHORT;
      }
      ///
      /// Возвращает сделки совершенные при входе в позицию.
      ///
      CArrayObj* EntryDeals()
      {
         return GetPointer(entryDeals);
      }
      ///
      /// Возвращает сделки совершенные при выходе из позиции.
      ///
      CArrayObj* ExitDeals()
      {
         return GetPointer(exitDeals);
      }
      ///
      /// Возвращает магический номер позиции/сделки.
      ///
      virtual ulong Magic()
      {
         Context(TRANS_IN);
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return OrderGetInteger(ORDER_MAGIC);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            return HistoryOrderGetInteger(GetId(), ORDER_MAGIC);
         }
         return 0;
      }
      ///
      /// Возвращает магический номер позиции/сделки.
      ///
      virtual ulong ExitMagic()
      {
         Context(TRANS_OUT);
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return OrderGetInteger(ORDER_MAGIC);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            return HistoryOrderGetInteger(GetId(), ORDER_MAGIC);
         }
         return 0;
      }
      ///
      /// Закрывает текущую позицию асинхронно.
      ///
      void AsynchClose(string comment = NULL)
      {
         trading.SetAsyncMode(true);
         trading.SetExpertMagicNumber(EntryOrderID());
         if(Direction() == DIRECTION_LONG)
            trading.Sell(VolumeExecuted(), NULL, 0.0, 0.0, 0.0, comment);
         else if(Direction() == DIRECTION_SHORT)
            trading.Buy(VolumeExecuted(), Symbol(), 0.0, 0.0, 0.0, comment);
         
      }
      ///
      /// Возвращает название символа, по которому была совершена сделка.
      ///
      virtual string Symbol()
      {
         if(isSymbol)return symbol;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            symbol = OrderGetString(ORDER_SYMBOL);
            isSymbol = true;
            return symbol;
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            symbol = HistoryOrderGetString(GetId(), ORDER_SYMBOL);
            isSymbol = true;
            return symbol;
         }
         return "";
      }
      ///
      /// Возвращает профит в пунктах инструмента.
      ///
      virtual double ProfitInPips()
      {
         
         double delta = 0.0;
         if(posStatus == POSITION_STATUS_NULL ||
            posStatus == POSITION_STATUS_PENDING)
            return 0.0;
         if(posStatus == POSITION_STATUS_OPEN)
            delta = CurrentPrice() - EntryPriceExecuted();
         if(posStatus == POSITION_STATUS_CLOSED)
            delta = ExitPriceExecuted() - EntryPriceExecuted();
         if(Direction() == DIRECTION_SHORT)
            delta *= -1.0;
         return delta;
      }
      ///
      /// Возвращает тип позиции.
      ///
      ENUM_ORDER_TYPE PositionType()
      {
         Context(TRANS_IN);
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            return (ENUM_ORDER_TYPE)HistoryOrderGetInteger(GetId(), ORDER_TYPE);
         }
         return (ENUM_ORDER_TYPE)0;
      }
      ///
      /// Возвращает тип позиции в виде текстовой строки.
      ///
      string PositionTypeAsString()
      {
         ENUM_ORDER_TYPE posType = PositionType();
         string type = EnumToString(posType);
         type = StringSubstr(type, 11);
         StringReplace(type, "_", " ");
         //StringReplace(type, "STOP LIMIT", "SL");
         //StringReplace(type, "STOP", "S");
         //StringReplace(type, "LIMIT", "L");
         return type;
         //ORDER_TYPE_
      }
      ///
      /// Возвращает статус позиции.
      ///
      ENUM_POSITION_STATUS PositionStatus()
      {
         return posStatus;
      }
      ///
      /// Комментарий входа в позицию.
      ///
      string EntryComment()
      {
         Context(TRANS_IN);
         return GetComment();
      }
      ///
      /// Комментарий входа в позицию.
      ///
      string ExitComment()
      {
         Context(TRANS_OUT);
         return GetComment();
      }
      ///
      /// Возвращает идентификатор ордера, открывающего позицию.
      ///
      ulong EntryOrderID()
      {
         Context(TRANS_IN);
         return GetId();
      }
      ///
      /// Возвращает идентификатор ордера, закрывающего позицию.
      ///
      ulong ExitOrderID()
      {
         Context(TRANS_OUT);
         return GetId();
      }
      ///
      /// Возвращает цену, по которой был размещен ОТЛОЖЕННЫЙ ордер на вход в позицию.
      /// Если ордер на вход в позицию рыночный будет возвращено 0.0.
      ///
      double EntryPricePlaced()
      {
         Context(TRANS_IN);
         return GetPricePlaced();
      }
      ///
      /// Возвращает цену, по которой фактически произошло срабатывания ордера.
      ///
      virtual double EntryPriceExecuted()
      {
         Context(TRANS_IN);
         return GetPriceExecuted();
      }
      ///
      /// Возвращает цену, по которой был размещен ордер на выход из позиции.
      ///
      double ExitPricePlaced()
      {
         Context(TRANS_OUT);
         return GetPricePlaced();
      }
      ///
      /// Возвращает цену, по которой фактически произошло срабатывания ордера.
      ///
      virtual double ExitPriceExecuted()
      {
         if(posStatus != POSITION_STATUS_CLOSED)return 0.0;
         Context(TRANS_OUT);
         return GetPriceExecuted();
      }
      ///
      /// Возвращает время установки ордера.
      ///
      CTime* EntrySetupDate()
      {
         Context(TRANS_IN);
         return SetupTime();
      }
      ///
      /// Возвращает время установки ордера.
      ///
      CTime* ExitSetupDate()
      {
         // Если позиция еще не закрылась, то и времени размещения закрывающего
         // ее ордера у нее нет.
         if(POSITION_STATUS_CLOSED)
         {
            Context(TRANS_OUT);
            return SetupTime();
         }
         else return NULL;
      }
      ///
      /// Возвращает время фактического выполнения ордера. Ордер, чье время исполнения существует, должен быть исполненным.
      ///
      CTime* EntryExecutedDate()
      {
         Context(TRANS_IN);
         if(posStatus == POSITION_STATUS_NULL || posStatus == POSITION_STATUS_PENDING)return NULL;
         return TimeExecuted();
      }
      ///
      /// Возвращает время фактического выхода из позиции. Позиция должна быть закрыта.
      ///
      CTime* ExitExecutedDate()
      {
         Context(TRANS_OUT);
         if(posStatus == POSITION_STATUS_NULL ||
            posStatus != POSITION_STATUS_CLOSED)return NULL;
         return TimeExecuted();
      }
      ///
      /// Возвращает первоначальный размещенный объем
      ///
      double VolumeInit()
      {
         Context(TRANS_IN);
         double vol = 0.0;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            vol = OrderGetDouble(ORDER_VOLUME_INITIAL);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            vol = HistoryOrderGetDouble(GetId(), ORDER_VOLUME_INITIAL);
         }
         return vol;
      }
      ///
      /// Невыполненный объем ордера.
      ///
      double VolumeReject()
      {
         Context(TRANS_IN);
         double vol = 0.0;
         //Не активные позиции по определению не имеют невыполненого объема ?
         //if(posStatus == NULL || posStatus == POSITION_STATUS_PENDING)return 0;
         if(posStatus == NULL)return vol;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            vol = OrderGetDouble(ORDER_VOLUME_CURRENT);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            vol = HistoryOrderGetDouble(GetId(), ORDER_VOLUME_CURRENT);
         }
         return vol;
      }
      ///
      /// Выполненный объем позиции.
      ///
      double VolumeExecuted()
      {
         return VolumeInit() - VolumeReject();
      }
      ///
      /// Возвращает текущую цену инструмента, по которому совершена транзакция.
      ///
      virtual double CurrentPrice()
      {
         double price = 0.0;
         //Имеем дело с покупками?
         if(PositionType() % 2 == 0)
            price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         else
            price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         return price;
      }
      ///
      /// Возвращает позицию, ассоциированную с защитной остановкой StopLoss
      ///
      Position* StopLoss()
      {
         return stopLoss;
      }
      ///
      /// Возвращает позицию, ассоциированную с защитной остановкой TakeProfit
      ///
      Position* TakeProfit()
      {
         return takeProfit;
      }
      ///
      /// Возвращает истину, если используется стоп-лосс.
      ///
      bool UsingStopLoss()
      {
         if(CheckPointer(stopLoss) != POINTER_INVALID)return true;
         return false;
      }
      ///
      /// Возвращает истину, если используется тейк-профит.
      ///
      bool UsingTakeProfit()
      {
         if(CheckPointer(takeProfit) != POINTER_INVALID)return true;
         return false;
      }
      ///
      /// Возвращает уровень защитной остановки stoploss.
      ///
      double StopLossLevel()
      {
         if(CheckPointer(stopLoss) == POINTER_INVALID)return 0.0;
         return stopLoss.EntryPricePlaced();
      }
      ///
      /// Устанавливает новый уровень защитной остановки stoploss.
      ///
      void StopLossLevel(double level)
      {
         ;
      }
      ///
      /// Устанавливает новый уровень взятия прибыли takeprofit.
      ///
      void TakeProfitLevel(double level)
      {
         ;
      }
      ///
      /// Возвращает уровень защитной остановки takeprofit.
      ///
      double TakeProfitLevel()
      {
         if(CheckPointer(takeProfit) == POINTER_INVALID)return 0.0;
         return takeProfit.EntryPricePlaced();
      }
      ///
      /// Удаляет защитную остановку stoploss.
      ///
      void DeleteStopLoss()
      {
         ;
      }
      ///
      /// Удаляет уровень взятия прибыли takeprofit.
      ///
      void DeleteTakeProfit()
      {
         ;
      }
   private:
      enum ENUM_TRANSACTION_CONTEXT
      {
         TRANS_IN,
         TRANS_OUT
      };
      ///
      /// Инициализирует новую отрытую позицию
      ///
      void InitPosition(ulong in_ticket, CArrayLong* in_deals = NULL, ulong out_ticket = 0, CArrayLong* out_deals = NULL)
      {
         if(in_ticket == 0)
         {
            posStatus = POSITION_STATUS_NULL;
            return;
         }
         if(CheckPointer(in_deals) == POINTER_INVALID || in_deals.Total() == 0)
            posStatus = POSITION_STATUS_PENDING;
         else if(out_ticket == 0 || CheckPointer(out_deals) == POINTER_INVALID)
            posStatus = POSITION_STATUS_OPEN;
         else if(out_deals.Total() != 0)
            posStatus = POSITION_STATUS_CLOSED;
         inOrderId = in_ticket;
         
         //Добавляем сделки инициирующего ордера.
         if(posStatus == POSITION_STATUS_OPEN ||
            posStatus == POSITION_STATUS_CLOSED)
         {
            for(int i = 0; i < in_deals.Total(); i++)
            {
               ulong id = in_deals.At(i);
               Deal* deal = new Deal(id);
               entryDeals.Add(deal);
            }
         }
         //Добавляем сделки закрывающего ордера.
         if(posStatus == POSITION_STATUS_CLOSED)
         {
            for(int i = 0; i < out_deals.Total(); i++)
            {
               ulong id = out_deals.At(i);
               Deal* deal = new Deal(id);
               exitDeals.Add(deal);
            }
         }
         outOrderId = out_ticket;
      }
      
      ///
      /// Возвращает время установки открывающего/закрывающего ордера. Если время установки ордера не известно, например, ордер не инициализирован,
      /// будет возвращено NULL.
      ///
      CTime* SetupTime()
      {
         CTime* ctime = NULL;
         if(posStatus == POSITION_STATUS_NULL)return ctime;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            long msc = OrderGetInteger(ORDER_TIME_SETUP_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
         else
         {
            SelectHistoryTransaction();
            long msc = HistoryOrderGetInteger(GetId(), ORDER_TIME_SETUP_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
      }
      ///
      /// Получает комментарий, ассоциированный с текущим оредром.
      ///
      string GetComment()
      {
         if(posStatus == POSITION_STATUS_NULL)return "not def.";
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return OrderGetString(ORDER_COMMENT);
         }
         else
         {
            SelectHistoryTransaction();
            return HistoryOrderGetString(GetId(), ORDER_COMMENT);
         }
      }
      ///
      /// Возвращает цену, по которой был размещен ордер.
      ///
      double GetPricePlaced()
      {
         if(posStatus != POSITION_STATUS_PENDING)
            return Price();
         else
            return Price(true);
      }
      ///
      /// Возвращает цену, по которой был размещен ордер.
      ///
      double GetPriceExecuted()
      {
         if(Context() == TRANS_IN && isEntryPriceExecuted)
            return entryPriceExecuted;
         //Считаем среднюю эффективную цену входа
         CArrayObj* deals = NULL;
         if(Context() == TRANS_IN)
            deals = GetPointer(entryDeals);
         else
            deals = GetPointer(exitDeals);
         double vol_total = 0.0;
         double price_total = 0.0;
         for(int i = 0; i < deals.Total(); i++)
         {
            Deal* deal = deals.At(i);
            vol_total += deal.VolumeExecuted();
            price_total += deal.VolumeExecuted() * deal.EntryPriceExecuted();
         }
         double avrg_price = vol_total == 0 ? 0.0 : price_total / vol_total;
         if(Context() == TRANS_IN)
         {
            entryPriceExecuted = avrg_price;
            isEntryPriceExecuted = true;
         }
         return avrg_price;
      }
      ///
      /// Устанавливает контекст - идентификатор входящей или исходящей транзакции, с которым производится работа.
      ///
      void Context(ENUM_TRANSACTION_CONTEXT context)
      {
         currContext = context;
         ulong id = currContext == TRANS_IN ? inOrderId : outOrderId;
         SetId(id);
      }
      ///
      /// Возвращает текущий контекст.
      ///
      ENUM_TRANSACTION_CONTEXT Context(){return currContext;}
      ///
      /// Статус позиции.
      ///
      ENUM_POSITION_STATUS posStatus;
      ///
      /// Текущий установленный контекст.
      ///
      ENUM_TRANSACTION_CONTEXT currContext;
      ///
      /// Уникальный идентификатор ордера, открывающего сделку.
      ///
      ulong inOrderId;
      ///
      /// Уникальный идентификатор ордера, закрывающего сделку.
      ///
      ulong outOrderId;
      ///
      /// Связанная с этой позицией другая позиция, представляющая защитную остановку stoploss.
      ///
      Position* stopLoss;
      ///
      /// Связанная с этой позицией другая позиция, представляющая уровень взятия прибыли takeprofit.
      ///
      Position* takeProfit;
      ///
      /// Содержит сделки инициирующие выход из позиции.
      ///
      CArrayObj entryDeals;
      ///
      /// Содержит сделки инициирующие выход из позиции.
      ///
      CArrayObj exitDeals;
      ///
      /// Класс, для совершения торговых операций.
      ///
      CTrade trading;
   
};

class Deal : public Transaction
{
   public:
      Deal(ulong inId) : Transaction(TRANS_DEAL)
      {
         SetId(inId);
      }
      ///
      /// Возвращает уникальный идентификатор эксперта, которому принадлежит данная сделка.
      ///
      virtual ulong Magic()
      {
         SelectHistoryTransaction();
         return HistoryDealGetInteger(GetId(), DEAL_MAGIC);
      }
      ///
      /// Возвращает название символа, по которому была совершена сделка.
      ///
      virtual string Symbol()
      {
         if(isSymbol)return symbol;
         SelectHistoryTransaction();
         symbol = HistoryDealGetString(GetId(), DEAL_SYMBOL);
         isSymbol = true;
         return symbol;
      }
      ///
      /// Возвращает тип сделки.
      ///
      ENUM_DEAL_TYPE DealType()
      {
         SelectHistoryTransaction();
         return (ENUM_DEAL_TYPE)HistoryDealGetInteger(GetId(), DEAL_TYPE);
      }
      ///
      /// Возвращает направление, в котором совершена транзакция
      ///
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         if(DealType() == DEAL_TYPE_BUY)
            return DIRECTION_LONG;
         else
            return DIRECTION_SHORT;
      }
      ///
      /// Возвращает тип сделки, в виде строки.
      ///
      string DealTypeAsString()
      {
         ENUM_DEAL_TYPE eType = DealType();
         string type = EnumToString(eType);
         type = StringSubstr(type, 10);
         StringReplace(type, "_", " ");
         return type;
      }
      ///
      /// Возвращает цену, по которой была выполнина сделка.
      ///
      virtual double EntryPriceExecuted()
      {
         if(isEntryPriceExecuted)
            return entryPriceExecuted;
         entryPriceExecuted = Price();
         isEntryPriceExecuted = true;
         return entryPriceExecuted;
      }
      ///
      /// Возвращает время совершения сделки.
      ///
      CTime* Date()
      {
         return TimeExecuted();
      }
      ///
      /// Возвращает уникальный идентификатор сделки.
      ///
      ulong Ticket(){return GetId();}
      ///
      /// Объем сделки.
      ///
      double VolumeExecuted()
      {
         SelectHistoryTransaction();
         return HistoryDealGetDouble(GetId(), DEAL_VOLUME);
      }
      ///
      /// Возвращает комментарий к сделке.
      ///
      string Comment()
      {
         SelectHistoryTransaction();
         return HistoryDealGetString(GetId(), DEAL_COMMENT);
      }
      ///
      /// Возвращает текущую цену инструмента, по которому совершена сделка.
      ///
      virtual double CurrentPrice()
      {
         double price = 0.0;
         if(DealType() == DEAL_TYPE_BUY)
            price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         if(DealType() == DEAL_TYPE_SELL)
            price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         return price;
      }
};

/*void foo()
{
   Transaction trans = new Transaction(TRANS_POSITION);
   //trans.
}*/


