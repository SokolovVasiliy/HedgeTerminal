//+------------------------------------------------------------------+
//|                                          MovingAverageExpert.mq5 |
//|                                    Exclusively for HedgeTerminal.|
//|         Copyright 2014, Sokolov Vasiliy, St.-Petersburg, Russia. |
//|                              https://login.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Arrays\ArrayInt.mqh>
#ifdef HEDGES
   #include "Prototypes.mqh"  //Include export functions and enums for using HedgeTerminal API.
#endif 
///
/// Moving Average Expert.
///
class MAExpert : public CObject
{
   public:
      ///
      /// Set default params.
      ///
      MAExpert();
      ///
      /// Must be executed on every tick.
      ///
      void Run();
      ///
      /// Get magic of expert.
      ///
      uint GetMagic(void){return magic;}
      ///
      /// Set symbol for trading.
      ///
      void SetSymbol(string set_symbol);
      ///
      /// Get symbol for trading.
      ///
      string GetSymbol(void);
      ///
      /// Set period for fast moving average.
      ///
      void SetFastMA(uint period);
      ///
      /// Get period for fast moving average.
      ///
      uint GetFastMA(void){return fastMA;}
      ///
      /// Set period for slow moving average.
      ///
      void SetSlowMA(uint period);
      ///
      /// Get period for slow moving average.
      ///
      uint GetSlowMA(void){return slowMA;}
      ///
      /// Set work timeframe.
      ///
      void SetWorkTimeframe(ENUM_TIMEFRAMES set_timeframe);
      ///
      /// Get work timeframe.
      ///
      ENUM_TIMEFRAMES GetWorkTimeframe(){return timeframe;}
      ///
      /// Set shift for moving average.
      ///
      void SetShiftMA(uint set_shift);
      ///
      /// Get shift for moving average.
      ///
      uint GetShiftMA(void){return shift;}
      ///
      /// Set moving average type.
      /// \param type_ma - Type of moving average.
      ///
      void SetTypeMA(ENUM_MA_METHOD set_type_ma);
      ///
      /// Get moving average type.
      /// \return - Type of moving average.
      ///
      ENUM_MA_METHOD GetTypeMA(void){return typeMA;}
      ///
      /// Set apply prices. May be handle of indicator.
      ///
      void SetApplyPrice(int set_apply_price);
      ///
      /// Get apply prices. May be handle of indicator.
      ///
      int GetApplyPrice(void){return applyPrice;}
      ///
      /// Print last error.
      ///
      void PrintStackActions();
   private:

      ///
      /// Rebuild indicators and get new handles for it.
      ///
      void RebuildIndicators(void);
      ///
      /// Generate unique magic for this expert.
      ///
      void GenerateMagic(void);
      ///
      /// Hesh function for generate unique magic;
      ///
      uint Adler32(string buf);
      ///
      /// Recalc current count my positions.
      ///
      void RecalcCountPosition(void);
      ///
      /// Return true if new bar detected, otherwise false.
      ///
      bool DetectNewBar(void);
      ///
      /// Return true if fast ma cross over slow ma, otherwise false.
      ///
      bool CrossOver(void);
      ///
      /// Return true if fast sma cross under slow sma, otherwise true;
      ///
      bool CrossUnder();
      ///
      /// Return true if handles of indicators valid, otherwise false.
      ///
      bool CheckHandles();
      ///
      /// Return lot for deal.
      ///
      double GetLot(void);
      ///
      /// Try close all short position.
      ///
      void TryCloseAllShortPos(void);
      ///
      /// Try close all long position.
      ///
      void TryCloseAllLongPos(void);
      ///
      /// Try open long position.
      ///
      void TryOpenLongPos(void);
      ///
      /// Try open short position.
      ///
      void TryOpenShortPos(void);
      ///
      /// Try close selected hedge position.
      ///
      void TryCloseCurrentPos();
      ///
      /// Unique magic for expert.
      ///
      uint magic;
      ///
      /// Symbol for trading.
      ///
      string symbol;
      ///
      /// Period of fast ma.
      ///
      uint fastMA;
      ///
      /// Period of slow ma.
      ///
      uint slowMA;
      ///
      /// Work timeframe.
      ///
      ENUM_TIMEFRAMES timeframe;
      ///
      /// Type of moving average.
      ///
      ENUM_MA_METHOD typeMA;
      ///
      /// Shift for moving average.
      ///
      uint shift;
      ///
      /// Apply price or handle indicator.
      ///
      int applyPrice;
      ///
      /// Handle of fast moving average indicator.
      ///
      int handleFastMA;
      ///
      /// Handle of slow moving average indicator.
      ///
      int handleSlowMA;
      ///
      /// Helper class for trading.
      ///
      CTrade trade;
      ///
      /// Count of my total positions.
      ///
      int totalPos;
      ///
      /// Count of my long positions.
      ///
      int longsPos;
      ///
      /// Count of my short positions.
      ///
      int shortsPos;
      ///
      /// Indices of my long positions in the list of items.
      ///
      CArrayInt indexMyLongPos;
      ///
      /// Indices of my short positions in the list of items.
      ///
      CArrayInt indexMyShortPos;
      ///
      /// Include last time bar.
      ///
      datetime timeLastBar;
      ///
      /// Name of expert.
      ///
      string expertName;
};

///
/// Create expert by default param.
///
MAExpert::MAExpert()
{
   symbol = Symbol();
   fastMA = 1;
   slowMA = 12;
   timeframe = PERIOD_M1;
   typeMA = MODE_SMA;
   applyPrice = PRICE_CLOSE;
   expertName = "MA Expert";
   shift = 0;
   RebuildIndicators();
}

void MAExpert::RebuildIndicators(void)
{
   handleFastMA = iMA(symbol, timeframe, fastMA, shift, typeMA, applyPrice);
   handleSlowMA = iMA(symbol, timeframe, slowMA, shift, typeMA, applyPrice);
   GenerateMagic();
   ChartSetString(0, CHART_COMMENT, IntegerToString(magic)); 
}

bool MAExpert::CheckHandles(void)
{
   if(handleFastMA == -1 || handleSlowMA == -1)
      return false;
   return true;
}

void MAExpert::GenerateMagic(void)
{
   string hash = symbol;
   hash += IntegerToString(fastMA);
   hash += IntegerToString(slowMA);
   hash += IntegerToString(timeframe);
   hash += IntegerToString(typeMA);
   hash += IntegerToString(applyPrice);
   magic = Adler32(hash);
   trade.SetExpertMagicNumber(magic);
}

uint MAExpert::Adler32(string buf)
{
   uint s1 = 1;
   uint s2 = 0;
   uint buflength=StringLen(buf);
   uchar array[];
   ArrayResize(array, buflength,0);
   StringToCharArray(buf, array, 0, -1, CP_ACP);
   for (uint n=0; n<buflength; n++)
   {
      s1 = (s1 + array[n]) % 65521;
      s2 = (s2 + s1)     % 65521;
   }
   return ((s2 << 16) + s1);
}

void MAExpert::SetSymbol(string set_symbol)
{
   if(!SymbolSelect(symbol, true))
      printf(expertName + ": symbol not find");
   else
   {
      symbol = set_symbol;
      RebuildIndicators();
   }
}

void MAExpert::SetSlowMA(uint period)
{
   if(period == 0)
      printf(expertName + ": slow period must be greate 0");
   else
   {
      slowMA = period;
      RebuildIndicators();
   }
}

void MAExpert::SetFastMA(uint period)
{
   if(period == 0)
      printf(expertName + ": fast period must be greate 0");
   else
   {
      fastMA = period;
      RebuildIndicators();
   }
}

void MAExpert::SetTypeMA(ENUM_MA_METHOD set_type_ma)
{
   if(set_type_ma != typeMA)
   {
      typeMA = set_type_ma;
      RebuildIndicators();
   }
}

void MAExpert::SetShiftMA(uint set_shift)
{
   if(set_shift != shift)
   {
      shift = set_shift;
      RebuildIndicators();
   }
}

void MAExpert::SetWorkTimeframe(ENUM_TIMEFRAMES set_timeframe)
{
   if(set_timeframe != timeframe)
   {
      timeframe = set_timeframe;
      RebuildIndicators();
   }
}

void MAExpert::SetApplyPrice(int set_apply_price)
{
   if(set_apply_price != applyPrice &&
      set_apply_price > 0)
   {
      applyPrice = set_apply_price;
      RebuildIndicators();
   }
}

bool MAExpert::DetectNewBar(void)
{
   MqlRates bars[1];
   CopyRates(Symbol(), PERIOD_M1, 0, 1, bars);
   if(bars[0].time != timeLastBar)
   {
      timeLastBar = bars[0].time;
      //printf(expertName + " new bar detected: " + TimeToString(bars[0].time));
      return true;
   }
   return false;
}

void MAExpert::RecalcCountPosition()
{
   longsPos=0;
   shortsPos = 0;
   #ifdef HEDGES
   indexMyLongPos.Clear();
   indexMyShortPos.Clear();
   for(int i = 0; i < ActivePositionsTotal(); i++)
   {
      if(HedgePositionSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         continue;
      int pos_magic = (int)HedgePositionGetInteger(HEDGE_POSITION_MAGIC);
      string pos_symbol = HedgePositionGetString(HEDGE_POSITION_SYMBOL);
      if(magic != pos_magic || symbol != pos_symbol)continue;
      ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)HedgePositionGetInteger(HEDGE_POSITION_TYPE);
      if(orderType%2 == 0)
      {
         indexMyLongPos.Add(i);  //Remember indexes positions for quick access.
         longsPos++;
      }
      else
      {
         indexMyShortPos.Add(i); //Remember indexes positions for quick access.
         shortsPos++;
      }
   }
   #endif
   #ifndef HEDGES
   if(PositionSelect(symbol))
   {
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(posType == POSITION_TYPE_BUY)
         longsPos++;
      else
         shortsPos++;
   }
   #endif
}

bool MAExpert::CrossOver(void)
{
   if(!CheckHandles())
      return false;
   double fastSma[1];
   CopyBuffer(handleFastMA, 0, 1, 1, fastSma);
   double slowSma[1];
   CopyBuffer(handleSlowMA, 0, 1, 1, slowSma);
   //printf((string)fastSma[0] + " - " + (string)slowSma[0]);
   if(fastSma[0] > slowSma[0])
      return true;
   return false;
}

bool MAExpert::CrossUnder()
{
   if(CheckHandles())
      return !CrossOver();
   return false;
}

///
/// Return lot of deal.
///
double MAExpert::GetLot(void)
{
   return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
}

void MAExpert::TryOpenShortPos(void)
{
   if(CrossUnder())
   {
      //printf("Try entry short by cross under.");
      if(!trade.Sell(GetLot(), symbol, 0.0, 0.0, 0.0, "Entry short by cross over."))
         printf(trade.ResultRetcodeDescription());
   }
}

void MAExpert::TryCloseAllShortPos(void)
{
   //printf("Try close all short pos");
   if(CrossUnder())return;
   #ifdef HEDGES
      for(int i = 0; i < indexMyShortPos.Total(); i++)
      {
         if(!HedgePositionSelect(indexMyShortPos.At(i)))continue;
            TryCloseCurrentPos();
      }
   #endif
   #ifndef HEDGES
      TryCloseCurrentPos();
   #endif 
}

void MAExpert::TryOpenLongPos(void)
{
   if(CrossOver())
   {
      //printf("Try entry long by cross over.");
      if(!trade.Buy(GetLot(), symbol, 0.0, 0.0, 0.0, "Entry long by cross over."))
         printf(trade.ResultRetcodeDescription());
   }
}

void MAExpert::TryCloseAllLongPos(void)
{
   //printf("Try Close all long pos");
   if(CrossOver())return;
   #ifdef HEDGES
      for(int i = 0; i < indexMyLongPos.Total(); i++)
      {
         if(!HedgePositionSelect(indexMyLongPos.At(i)))continue;
            TryCloseCurrentPos();
      }
   #endif
   #ifndef HEDGES
      TryCloseCurrentPos();
   #endif 
}

void MAExpert::TryCloseCurrentPos()
{
   #ifdef HEDGES
   if(!HedgePositionSelect())
   {
      printf(expertName + " " + "Hedge position not seleted.");
      return;
   }
   HedgeClosingRequest request;
   request.asynch_mode = true;
   //request.volume = 0.1;
   request.exit_comment = "exit by signal";
   request.asynch_mode = false;
   //request.close_type = CLOSE_AS_MARKET; 
   ulong id = HedgePositionGetInteger(HEDGE_POSITION_ENTRY_ORDER);
   printf("Try close position #" + id);
   if(!HedgePositionClose(request))
      printf("Try closing failed: " + EnumToString(GetHedgeError()) + " " + (string)GetHedgeError());
   else
      printf("Current position " +(string)id + " was closed.");
   #endif
   #ifndef HEDGES
   PositionSelect(symbol);
   ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   if(posType == POSITION_TYPE_BUY)
      trade.Sell(GetLot(), NULL, 0.0, 0.0, 0.0, "Exit from buy");
   else
      trade.Buy(GetLot(), NULL, 0.0, 0.0, 0.0, "Exit from sell");
   #endif
}

#ifdef HEDGES
void MAExpert::PrintStackActions(void)
{
   if(!HedgePositionSelect())return;
   int totalActions = (int)HedgePositionGetInteger(HEDGE_POSITION_ACTIONS_TOTAL);
   printf(">>>> New error! >>>>");
   for(int i = 0; i < totalActions; i++)
   {
      ENUM_TARGET_TYPE type;
      uint retcode;
      GetActionResult(i, type, retcode);
      printf("Step " + (string)i + ": " + EnumToString(type) + " - " + (string)retcode);
   }
}
#endif

void MAExpert::Run(void)
{
   //printf(TestLoadApi());
   if(!DetectNewBar())return;
   RecalcCountPosition();
   if(longsPos > 0)
      TryCloseAllLongPos();
   else
      TryOpenLongPos();
   if(shortsPos > 0)
      TryCloseAllShortPos();
   else
      TryOpenShortPos();
}

