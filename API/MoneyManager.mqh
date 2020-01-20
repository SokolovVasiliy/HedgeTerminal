#include "Transaction.mqh"
#include "Order.mqh"
#include "Deal.mqh"
#include "Position.mqh"


class MoneyManager
{
   private:
      ///
      /// Транзакция для рассчета.
      ///
      Position* pos;
      ///
      /// Режим вычисления прибыли и маржи.
      ///
      ENUM_SYMBOL_CALC_MODE calcMode;
      
      ///
      /// Возвращает тип расчетного тика.
      /// \return SYMBOL_TRADE_TICK_VALUE_PROFIT или SYMBOL_TRADE_TICK_VALUE_LOSS в
      /// зависимости от того, является позиция прибыльной или убыточной.
      ///
      ENUM_SYMBOL_INFO_DOUBLE TypeTick(void);
      ///
      /// Истина, если текущий инструмент кросс и ложь в противном случае.
      ///
      bool IsCross(void);
      ///
      /// Рассчитывает стоимость тика для forex режима.
      ///
      double CalcTickValueForForex(void);
      ///
      /// Рассчитывает профит для форекс позиций.
      ///
      double GetProfitValueForex();
      ///
      /// Рассчитывает профит для фортс позиций.
      ///
      double GetProfitValueForts();
   public:
      ///
      /// Рассчеты могут производится только над конкретной транзакцией.
      ///
      MoneyManager(Position* pos);
      ///
      /// Возвращает финансовый итог позиции.
      ///
      double GetProfitValue(void);
      ///
      /// Возвращает стоимость тика для транзакции.
      ///
      double GetTickValue();
      ///
      /// Возвращает бар на дату time в переменную bar. Если бара соответствующему этому времени нет
      /// возвращает последний известный бар, предшествующий этому времени.
      ///
      bool GetBarOnTime(datetime time, ENUM_TIMEFRAMES period, MqlRates& bar);
      bool DetectFortsModeByBrokerName(void);
};

MoneyManager::MoneyManager(Position* currPos)
{
   this.pos = currPos;
   calcMode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(pos.Symbol(), SYMBOL_TRADE_CALC_MODE);
   if(DetectFortsModeByBrokerName())
      calcMode = SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS;
}
///
/// Определяет режим работы на FORTS, по имени брокера
///
bool MoneyManager::DetectFortsModeByBrokerName(void)
{
   string companyName = AccountInfoString(ACCOUNT_COMPANY);
   if(StringFind(companyName, "ОТКРЫТИЕ")>-1 ||
      StringFind(companyName, "BCS Broker")>-1)
      return true;
   return false;
}

ENUM_SYMBOL_INFO_DOUBLE MoneyManager::TypeTick(void)
{
   if(pos.ProfitInPips() > 0)
      return SYMBOL_TRADE_TICK_VALUE_PROFIT;
   return SYMBOL_TRADE_TICK_VALUE_LOSS;
}

double MoneyManager::GetTickValue(void)
{
   
   //return SymbolInfoDouble("RTS-6.15", SYMBOL_TRADE_TICK_SIZE);
   if(pos.Status() == POSITION_ACTIVE)
      return SymbolInfoDouble(pos.Symbol(), TypeTick());
   switch(calcMode)
   {
      case SYMBOL_CALC_MODE_FOREX:
         return CalcTickValueForForex();
      default:
         return SymbolInfoDouble(pos.Symbol(), TypeTick());
   }
   return 0.0;
}

double MoneyManager::CalcTickValueForForex(void)
{
   if(pos.Status() == POSITION_ACTIVE/* ||
      !IsCross()*/)
   {
      string symbol = pos.Symbol();
      double value = SymbolInfoDouble(pos.Symbol(), TypeTick());
      return SymbolInfoDouble(pos.Symbol(), TypeTick());
   }
   //Пробуем получить доступ к прямому курсу.
   bool revert = false; //Признак перевернутого курса.
   string profitCurrency = SymbolInfoString(pos.Symbol(), SYMBOL_CURRENCY_PROFIT);
   string accCurrency = AccountInfoString(ACCOUNT_CURRENCY);
   string symbol = profitCurrency + accCurrency;
   string pSymbol = pos.Symbol();
   if(SymbolInfoInteger(symbol, SYMBOL_TIME) == 0)
   {
      revert = true;
      symbol = accCurrency + profitCurrency;
      if(SymbolInfoInteger(symbol, SYMBOL_TIME) == 0)
         return SymbolInfoDouble(pos.Symbol(), TypeTick());
   }
   //Копируем цены прямого курса на момент выхода из позиции.
   MqlRates rates[];
   //MqlRates inBar;
   //MqlRates outBar;
   /*if(!GetBarOnTime(pos.EntryExecutedTime()/1000, PERIOD_M1, inBar))
      return SymbolInfoDouble(pos.Symbol(), TypeTick());
   if(!GetBarOnTime(pos.ExitExecutedTime()/1000, PERIOD_M1, outBar))
      return SymbolInfoDouble(pos.Symbol(), TypeTick());*/
   datetime in_time = (datetime)pos.ExitExecutedTime()/1000 - 3600;
   datetime out_time = (datetime)pos.ExitExecutedTime()/1000 + 1;
   int count = CopyRates(symbol, PERIOD_M1, in_time, out_time, rates);
   if(count == -1 || count == 0)
      return SymbolInfoDouble(pos.Symbol(), TypeTick());
   int i = ArraySize(rates)-1;
   double spread = rates[i].spread * SymbolInfoDouble(pos.Symbol(), SYMBOL_POINT);
   //if(pos.Direction() == DIRECTION_LONG)
   //   spread *= (-1);
   //double tickValue = (inBar.close + outBar.close)/2;
   //double in = (inBar.close);
   //double out = (outBar.close);
   //double spread = outBar.spread * SymbolInfoDouble(pos.Symbol(), SYMBOL_POINT);
   double tickValue = 0.0;
   //double tickValue = ((in + out)/2);
   //MqlDateTime dts;
   //TimeToStruct(out_time, dts);
   /*if(dts.sec < 30)
      tickValue = rates[i].open + spread;
   else
      tickValue = rates[i].close + spread;*/
   if(pos.Direction() == DIRECTION_LONG)
      tickValue = rates[i].low + spread;
   else
      tickValue = rates[i].high - spread;
   if(revert)
   {
      double contractSize = SymbolInfoDouble(pos.Symbol(), SYMBOL_TRADE_CONTRACT_SIZE);
      double point = SymbolInfoDouble(pos.Symbol(), SYMBOL_POINT);
      double curs = Math::DoubleEquals(point,0.0) ? 1 : contractSize*point;
      tickValue = curs/tickValue;
   }
   return tickValue;
}


bool MoneyManager::IsCross(void)
{
   if(calcMode != SYMBOL_CALC_MODE_FOREX)
      return false;
   string accCurrency = AccountInfoString(ACCOUNT_CURRENCY);
   string profitCurrency = SymbolInfoString(pos.Symbol(), SYMBOL_CURRENCY_PROFIT);
   string marginCurrency = SymbolInfoString(pos.Symbol(), SYMBOL_CURRENCY_MARGIN);
   if(accCurrency != profitCurrency &&
      accCurrency != marginCurrency)
      return true;
   return false;
}

double MoneyManager::GetProfitValue(void)
{
   switch(calcMode)
   {
      case SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS:
         return GetProfitValueForts();
      default:
         return GetProfitValueForex();
   }
   return 0.0;
}

double MoneyManager::GetProfitValueForex(void)
{
   //>>>>>>>>>>>>>>>>>>>>>> Simple forex calculation >>>>>>>>>>>>>>>>>>>>>>>
   double t_size = SymbolInfoDouble(pos.Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double t_cost = SymbolInfoDouble(pos.Symbol(), SYMBOL_TRADE_TICK_VALUE);
   double volume = pos.VolumeExecuted();
   if(t_size == 0.0)t_size = 1.0;
   double price_step = pos.ProfitInPips() / t_size;
   double profit = price_step * t_cost * volume;
   return profit;
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   /*double pips = pos.ProfitInPips();
   double point = SymbolInfoDouble(pos.Symbol(), SYMBOL_POINT);
   if(point == 0.0)return 0.0;
   double contractSize = SymbolInfoDouble(pos.Symbol(), SYMBOL_TRADE_CONTRACT_SIZE);
   double tValue = GetTickValue();
   double vol = pos.VolumeExecuted();
   double currency = 0.0;
   calcMode = calcMode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(pos.Symbol(), SYMBOL_TRADE_CALC_MODE);
   currency = tValue * (pips/point) * pos.VolumeExecuted();
   return currency;*/
}

double MoneyManager::GetProfitValueForts(void)
{
   double t_value = GetTickValue();
   double t_size = SymbolInfoDouble(pos.Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double currency = 0.0;
   if(t_size != 0.0)
      currency = pos.ProfitInPips()*GetTickValue()*pos.VolumeExecuted()/t_size;
   return currency;
}

bool MoneyManager::GetBarOnTime(datetime time, ENUM_TIMEFRAMES period, MqlRates& bar)
{
   MqlRates bars[];
   CopyRates(pos.Symbol(), period, time-3600, time, bars);
   int i = ArraySize(bars)-1;
   if(i < 0)return false;
   bar = bars[i];
   return true;
}