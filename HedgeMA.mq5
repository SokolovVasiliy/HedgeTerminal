//+------------------------------------------------------------------+
//|                                                      HedgeMA.mq5 |
//|     Copyright 2014, Vasiliy Sokolov especially for HedgeTerminal |
//|                              https://login.mql5.com/ru/users/c-4 |
//|   DESCRIPTION: This is a simple moving average expert working on |
//| multi timeframes and periods. This expert advisor show how using |
//|HedgeTerminal API. Use this example for build your expert advisor |
//| For compiling this expert copy this file in MQL5\Experts         |
//| directory your terminal. For example:                            |
//| "C:\Programm Files\MetaTrader 5\MQL5\Experts\HedgeMA.mq5\".      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Vasiliy Sokolov especially for HedgeTerminal"
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.00"

input int ma_period = 12; // MA period
input int sl_pips = 100;  //Trailing stop in pips

//#define API_INTRO
#ifdef API_INTRO
   #include ".\API\HedgeTerminalAPI.mq5"
#else
   enum ENUM_DIRECTION_TYPE
   {
      DIRECTION_NDEF,
      DIRECTION_LONG,
      DIRECTION_SHORT
   };
   #include "Prototypes.mqh"
#endif
#include <Trade\Trade.mqh>
#include <Arrays\ArrayObj.mqh>

///
/// Contains parameters for MA expert
///
class ConfigMA
{
   public:
      ///
      /// Magic of expert.
      /// 
      ulong magic;
      ///
      /// Name of symbol.
      ///
      string symbol_name;
      ///
      /// Timeframe.
      ///
      ENUM_TIMEFRAMES timeframe;
      ///
      /// Period of moving average.
      ///
      int ma_period;
      ///
      /// Shift of moving average.
      ///
      int ma_shift;
      ///
      /// Type of moving average.
      ///
      ENUM_MA_METHOD ma_method;
      ///
      /// Apple price or handle.
      ///
      int appled_price_or_handle;
      ///
      /// Contains stop level in pips
      ///
      int stop_pips;
      ///
      /// Create config by default parameters.
      ///
      ConfigMA()
      {
         symbol_name = Symbol();
         timeframe = PERIOD_CURRENT;
         ma_period = 12;
         ma_shift = 0;
         ma_method = MODE_SMA;
         appled_price_or_handle = PRICE_CLOSE;
         stop_pips = 50;
      }
      ///
      /// Define copy by value.
      ///
      void operator=(ConfigMA& config)
      {
         this.operator=(GetPointer(config));
      }
      ///
      /// Define copy by reference.
      ///
      void operator=(ConfigMA* config)
      {
         magic = config.magic;
         symbol_name = config.symbol_name;
         timeframe = config.timeframe;
         ma_period = config.ma_period;
         ma_shift = config.ma_shift;
         ma_method = config.ma_method;
         appled_price_or_handle = config.appled_price_or_handle;
         stop_pips = config.stop_pips;
      }
};

///
/// Moving Average Expert.
///
class MAExpert : public CObject
{
   public:
      ///
      /// Create expert by default parameters (see ConfigMA defaults).
      ///
      MAExpert()
      {
         CreateMA();
      }
      ///
      /// Create expert by based parameters.
      ///
      MAExpert(ulong mg, ENUM_TIMEFRAMES tf, int mperiod, int stopLevel)
      {
         config.magic = mg;
         config.timeframe = tf;
         config.ma_period = mperiod;
         config.stop_pips = stopLevel;
         CreateMA();
      }
      ///
      /// Create expert by config class.
      ///
      MAExpert(ConfigMA* cnf)
      {
         config = cnf;
         CreateMA();
      }
      void Configure(ConfigMA& cnf)
      {
         config = GetPointer(cnf);
      }
      ///
      /// Delete dinamic objects.
      ///
      ~MAExpert()
      {
         if(hMa != INVALID_HANDLE)
            IndicatorRelease(hMa);
      }
      ///
      /// Return name of expert.
      ///
      string GetName(){return "SMA-" + (string)config.ma_period;}
      ///
      /// Return count positions.
      ///
      int TotalPositions()
      {
         int count = 0;
         while(SelectPosition())
            count++;
         return count;
      }
      ///
      /// Return total volume.
      ///
      double TotalVolume()
      {
         double vol = 0.0;
         while(SelectPosition())
         {
            ENUM_DIRECTION_TYPE dirType = (ENUM_DIRECTION_TYPE)HedgePositionGetInteger(HEDGE_POSITION_DIRECTION);
            if(dirType == DIRECTION_LONG)
               vol += HedgePositionGetDouble(HEDGE_POSITION_VOLUME);
            else
               vol -= HedgePositionGetDouble(HEDGE_POSITION_VOLUME);
         }
         return vol;
      }
      ///
      /// Run this function in OnTick()
      ///
      void Run()
      {
         if(NewBarDetect())
         {
            if(CrossOver())
            {
               ExitFromDirection(DIRECTION_LONG);
               EnterDirection(DIRECTION_SHORT);
            }
            else
            {
               ExitFromDirection(DIRECTION_SHORT);
               EnterDirection(DIRECTION_LONG);
            }
         }
         TrailingStop();
      }
   private:
      ///
      /// Create indicator and show it.
      ///
      void CreateMA(void)
      {
         if(hMa != INVALID_HANDLE)
            IndicatorRelease(hMa);
         hMa = iMA(config.symbol_name, config.timeframe,
               config.ma_period, config.ma_shift, config.ma_method,
               config.appled_price_or_handle);
         if(hMa != INVALID_HANDLE)
            ChartIndicatorAdd(0, 0, hMa);
      }
      ///
      /// Return true if new bar detected, otherwise false.
      ///
      bool NewBarDetect(void)
      {
         MqlRates bars[1];
         CopyRates(Symbol(), PERIOD_M1, 0, 1, bars);
         if(bars[0].time != timeLastBar)
         {
            timeLastBar = bars[0].time;
            return true;
         }
         return false;
      }
      ///
      /// Return true if moving average crosses above price, otherwise false.
      ///
      bool CrossOver()
      {
         if(hMa == INVALID_HANDLE)
            return false;
         double ma_values[1];
         CopyBuffer(hMa, config.timeframe, 1, 1, ma_values);
         double closePrices[1];
         CopyClose(config.symbol_name, config.timeframe, 1, 1, closePrices);
         if(ma_values[0] > closePrices[0])
            return true;
         return false;
      }
      ///
      /// True if next position was selected. If list positions was end or empty return false.
      ///
      bool SelectPosition()
      {
         while(lastIndex < TransactionsTotal())
         {
            bool select = TransactionSelect(lastIndex);
            lastIndex++;
            if(!select || TransactionType() != TRANS_HEDGE_POSITION)continue;
            ulong mg = HedgePositionGetInteger(HEDGE_POSITION_MAGIC);
            if(config.magic != mg)continue;
            string symbol = HedgePositionGetString(HEDGE_POSITION_SYMBOL);
            if(config.symbol_name != symbol)continue;
            return true;
         }
         lastIndex = 0;
         return false;
      }
      ///
      /// Close all hedge position by direction 'dir'
      ///
      void ExitFromDirection(ENUM_DIRECTION_TYPE dir)
      {
         while(SelectPosition())
         {
            //printf("Закрываю текущую позицию.");
            if(HedgePositionGetInteger(HEDGE_POSITION_DIRECTION) != dir)continue;
            string comment = GetComment(false, dir);  // Get comment for exit.
            HedgeTradeRequest request;                // Create trade request.
            request.action = REQUEST_CLOSE_POSITION;  // Set action - close position.
            request.asynch_mode = false;              // Use synchronous emulator. Always using FALSE! Asynchronous mode only for professionals.
            request.volume = 0.0;                     // If request.volume equal 0.0 HedgeTerminal close all selected position.
            request.exit_comment = comment;           // Set exit comment for position.
            
            bool res = SendTradeRequest(request);     // Send request and get reault.
            if(!res)                                  // If send was failed - print task log for analize error.
               PrintTaskLog();
            //IsReopening(dir);
            //printf("Позиция закрыта.");
         }
      }
      ///
      /// Open new position by direction 'dir'.
      ///
      void EnterDirection(ENUM_DIRECTION_TYPE dir)
      {
         if(CountPositionsType(dir) > 0)return;
         if(IsReopening(dir))return;
         trade.SetExpertMagicNumber(config.magic);
         bool res = true;
         string comment = GetComment(true, dir);
         if(dir == DIRECTION_SHORT)
            res = trade.Sell(GetLot(), config.symbol_name, 0.0, 0.0, 0.0, comment);               
         if(dir == DIRECTION_LONG)
            res = trade.Buy(GetLot(), config.symbol_name, 0.0, 0.0, 0.0, comment);
         if(!res)
            printf(trade.ResultRetcodeDescription());
      }
      ///
      /// Return count positions with direction 'dir'
      ///
      int CountPositionsType(ENUM_DIRECTION_TYPE dir)
      {
         int count = 0;
         while(SelectPosition())
         {
            ENUM_DIRECTION_TYPE typeDir = (ENUM_DIRECTION_TYPE)HedgePositionGetInteger(HEDGE_POSITION_DIRECTION);
            if(HedgePositionGetInteger(HEDGE_POSITION_DIRECTION) == dir)
               count++;
         }
         return count;
      }
      ///
      /// This function prevents reopening positions after triggering stop-loss or take-profit.
      ///
      bool IsReopening(ENUM_DIRECTION_TYPE dir)
      {
         int total = TransactionsTotal(MODE_HISTORY);
         for(int i = total-1; i >=0; i--)
         {
            if(!TransactionSelect(i, SELECT_BY_POS, MODE_HISTORY))
               continue;
            if(TransactionType() != TRANS_HEDGE_POSITION)
               continue;
            ulong magic = HedgePositionGetInteger(HEDGE_POSITION_MAGIC);
            if(magic != config.magic)
               continue;
            //PrintTaskLog();
            ENUM_CLOSE_TYPE closeType = (ENUM_CLOSE_TYPE)HedgePositionGetInteger(HEDGE_POSITION_CLOSE_TYPE);
            ENUM_DIRECTION_TYPE dirType = (ENUM_DIRECTION_TYPE)HedgePositionGetInteger(HEDGE_POSITION_DIRECTION);
            if(closeType == CLOSE_AS_STOP_LOSS ||
               closeType == CLOSE_AS_TAKE_PROFIT)
            {
               if(dirType != dir)
                  return false;
               return true;
            }
            return false;
         }
         return false;
      }
      ///
      /// If 'isEntry' true - return comment for entry position.
      /// otherwise return false.
      ///
      string GetComment(bool isEntry, ENUM_DIRECTION_TYPE dir)
      {
         string name = "SMA-" + (string)config.ma_period + " ";
         string sdir = dir == DIRECTION_SHORT ? "short" : "long";
         string inOut = isEntry ? "In " : "Out ";
         string comment = inOut + name + " " + sdir;
         return comment;
      }
      ///
      /// Return lot for next position.
      ///
      double GetLot()
      {
         return 0.1; //return const lot 0.1
      }
      ///
      /// Trailing stop-loss following position.
      ///
      void TrailingStop()
      {
         int dbg = 5;
         if(config.magic == 1000)
            dbg = 4;
         if(config.stop_pips == 0)return;
         while(SelectPosition())
         {
            ENUM_DIRECTION_TYPE dirType = (ENUM_DIRECTION_TYPE)HedgePositionGetInteger(HEDGE_POSITION_DIRECTION);
            string smb = HedgePositionGetString(HEDGE_POSITION_SYMBOL);
            double stopLevel = HedgePositionGetDouble(HEDGE_POSITION_SL);
            if(dirType == DIRECTION_LONG)
            {
               double lastPrice = SymbolInfoDouble(smb, SYMBOL_BID);
               double nLevel = lastPrice - config.stop_pips*SymbolInfoDouble(smb, SYMBOL_POINT);
               if(nLevel > stopLevel)
               {
                  if(!DoubleEquals(nLevel, stopLevel))
                     ModifyStop(nLevel, dirType);
               }
            }
            if(dirType == DIRECTION_SHORT)
            {
               double lastPrice = SymbolInfoDouble(smb, SYMBOL_ASK);
               double nLevel = lastPrice + config.stop_pips*SymbolInfoDouble(smb, SYMBOL_POINT);
               bool usingStop = HedgePositionGetInteger(HEDGE_POSITION_USING_SL);
               if(nLevel < stopLevel || !usingStop)
               {
                  if(!DoubleEquals(nLevel, stopLevel))
                     ModifyStop(nLevel, dirType);
               }
            }
         }
      }
      ///
      /// Create or modify new stop loss level.
      ///
      void ModifyStop(double newLevel, ENUM_DIRECTION_TYPE dirType)
      {
         HedgeTradeRequest request;
         request.action = REQUEST_MODIFY_SLTP;
         request.sl = newLevel;
         request.exit_comment = GetComment(false, dirType);
         bool res = SendTradeRequest(request);
         if(!res)
            PrintTaskLog();
      }
      
      ///
      /// Print task log of selected position.
      ///
      void PrintTaskLog()
      {
         int totalActions = (int)HedgePositionGetInteger(HEDGE_POSITION_ACTIONS_TOTAL);
         printf("Hedge error: " + EnumToString(GetHedgeError()));
         for(int i = 0; i < totalActions; i++)
         {
            ENUM_TARGET_TYPE type;
            uint retcode;
            GetActionResult(i, type, retcode);
            printf("Step " + (string)i + ": " + EnumToString(type) + " - " + (string)retcode);
         }
      }
      ///
      /// Compares two values of double type. 
      /// \return True if two values is equal, otherwise false.
      ///
      bool DoubleEquals(double a, double b)
      {
         return(fabs(a-b)<=16*DBL_EPSILON*fmax(fabs(a),fabs(b)));
      }
      ///
      /// Handle of indicator Moving Average.
      ///
      int hMa;
      ///
      /// Contains parameters of moving average;
      ///
      ConfigMA config;
      ///
      /// Include last time bar.
      ///
      datetime timeLastBar;
      ///
      /// Last index position. Used by SelectPosition.
      ///
      int lastIndex;
      ///
      /// Trade module.
      ///
      CTrade trade;
};

///
/// Contains methods for calulate fibo levels.
///
class Fibo
{
   public:
      Fibo()
      {
         ResetFibo();
      }
      ///
      /// Reset curent fibo number.
      ///
      void ResetFibo()
      {
         firstFibo = 1;
         secondFibo = 1;
      }
      ///
      /// Get next fibo number
      ///
      int GetNextFiboNumber()
      {
         int temp = firstFibo + secondFibo;
         firstFibo = secondFibo;
         secondFibo = temp;
         return temp;
      }
   private:
      int firstFibo;
      int secondFibo;
};

//input int CountExperts = 1; // Count of experts advisor
///
/// Array of experts.
///
CArrayObj experts;

///
/// This enum define 3 sets good settings for MAExpert.
///
enum ENUM_MA_EXPERT_TYPE
{
   MA_EXPERT_SET1,
   MA_EXPERT_SET2,
   MA_EXPERT_SET3,
   MA_EXPERT_SET4,
};

ConfigMA* Configure(ENUM_MA_EXPERT_TYPE type = MA_EXPERT_SET1)
{
   ConfigMA* cnf = new ConfigMA();
   switch(type)
   {
      case MA_EXPERT_SET1:
         cnf.ma_period = 12;
         cnf.magic = 1000;
         break;
      case MA_EXPERT_SET2:
         cnf.ma_period = 22;
         cnf.magic = 1001;
         break;
      case MA_EXPERT_SET3:
         cnf.ma_period = 16;
         cnf.magic = 1002;
         break;
      case MA_EXPERT_SET4:
         cnf.ma_period = 24;
         cnf.magic = 1003;
         break;
   }
   cnf.stop_pips = sl_pips;
   cnf.symbol_name = Symbol();
   cnf.timeframe = PERIOD_CURRENT;
   return cnf;
}

///
/// Create array of experts based on moving average and configure it.
///
int OnInit()
  {
   //MAExpert expert = new MAExpert(basedMagic+period, PERIOD_M1, ,
   /*experts.Add(new MAExpert(Configure(MA_EXPERT_SET1)));
   experts.Add(new MAExpert(Configure(MA_EXPERT_SET2)));
   experts.Add(new MAExpert(Configure(MA_EXPERT_SET3)));
   experts.Add(new MAExpert(Configure(MA_EXPERT_SET4)));*/
   int total = TransactionsTotal();
   ExpertRemove();
   //experts.Add(new MAExpert(1000, PERIOD_CURRENT, ma_period, sl_pips));
   //ObjectCreate(0, "sss", OBJ_LABEL, 0, 0, 0);
   //ObjectSetInteger(0, "sss", OBJPROP_XSIZE, 200);
   //ObjectSetInteger(0, "sss", OBJPROP_YSIZE, 200);
   //ObjectSetInteger(0, "sss", OBJPROP_BGCOLOR, clrBlue);
   //Fibo fibo;
   //ulong basedMagic = 1000000; //Based magic expert class.
   //for(int i = 0; i < 100; i++)
   //   printf("i: " + (string)i + " - " + (string)fibo.GetNextFiboNumber());
   //Create 25 experts of moving average
   //experts.Add(new MAExpert(basedMagic+50, PERIOD_CURRENT, 50, 0.0025));
   //experts.Add(new MAExpert(basedMagic+200, PERIOD_CURRENT, 200, 0.0025));
   /*while(true)
   {
      //if(experts.Total() > 2)return INIT_SUCCEEDED;
      int period = fibo.GetNextFiboNumber();
      if(period > 1000)return INIT_SUCCEEDED;
      experts.Add(new MAExpert(basedMagic+period, PERIOD_CURRENT, period, 0.0025));
   }*/
   return INIT_SUCCEEDED;
  }


///
/// Run exper advisoir everty tick.
///
void OnTick()
  {
   string name = "";
   double vol = 0.0;
   for(int i = 0; i < experts.Total(); i++)
   {
      MAExpert* expert = experts.At(i);
      expert.Run();
      vol += expert.TotalVolume();
      name += expert.GetName() + "   " + (string)expert.TotalPositions() + "   " + (string)expert.TotalVolume() + "\r\n";
   }
   double pvol;
   if(PositionSelect(Symbol()))
   {
      pvol = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), 2);
      vol = NormalizeDouble(vol, 2);
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         pvol *= (-1);
      if(pvol != vol)
         name += "Warning! hedge " + DoubleToString(vol, 2) + " != " + DoubleToString(pvol, 2);
      else
         name += "Hedge " + DoubleToString(vol, 2) + " ==" + DoubleToString(pvol, 2);
   }
   Comment(name);
  }
  
void OnDeinit(const int reason)
{
   experts.Clear();
}

