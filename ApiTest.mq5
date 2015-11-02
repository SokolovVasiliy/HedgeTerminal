//+------------------------------------------------------------------+
//|                                                      ApiTest.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
string VERSION = "HT";
#define API_INTRO
#ifdef API_INTRO
   #include ".\API\HedgeTerminalAPI.mq5"
#else
   #include <Prototypes.mqh>
#endif
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   double ts =  SymbolInfoDouble("RTS-6.15", SYMBOL_TRADE_TICK_SIZE);
   FOREACH_POSITION
   {
      TransactionSelect(i);
      double profit = HedgePositionGetDouble(HEDGE_POSITION_PROFIT_CURRENCY);
      printf(profit);   
   }
}


void PrintPositionParamsInt()
{
   printf("--Print Integer:");
   int maxValue = HEDGE_POSITION_ACTIONS_TOTAL;
   for(int i = 0; i <= maxValue; i++)
   {
      ENUM_HEDGE_POSITION_PROP_INTEGER type = (ENUM_HEDGE_POSITION_PROP_INTEGER)i;
      ulong value = HedgePositionGetInteger(type);
      printf("----" + EnumToString(type) + ": " + (string)value);
   }
   
}

void PrintPositionParamsDbl()
{
   printf("--Print Double:");
   int maxValue = HEDGE_POSITION_PROFIT_POINTS;
   for(int i = 0; i <= maxValue; i++)
   {
      ENUM_HEDGE_POSITION_PROP_DOUBLE type = (ENUM_HEDGE_POSITION_PROP_DOUBLE)i;
      double value = HedgePositionGetDouble(type);
      printf("----" + EnumToString(type) + ": " + DoubleToString(value, 5));
   }
}

void PrintPositionParamsStr()
{
   printf("--Print String:");
   int maxValue = 3;
   for(int i = 0; i <= maxValue; i++)
   {
      ENUM_HEDGE_POSITION_PROP_STRING type = (ENUM_HEDGE_POSITION_PROP_STRING)i;
      string value = HedgePositionGetString(type);
      printf("----" + EnumToString(type) + ": " + value);
   }
}

void PrintOrderParamsInt()
{
   printf("--Print Integer:");
   int maxValue = HEDGE_ORDER_TIME_CANCELED_MSC;
   for(int i = 0; i <= maxValue; i++)
   {
      ENUM_HEDGE_ORDER_PROP_INTEGER type = (ENUM_HEDGE_ORDER_PROP_INTEGER)i;
      ulong value = HedgeOrderGetInteger(type);
      printf("----" + EnumToString(type) + ": " + (string)value);
   }
}

void PrintOrderParamsDbl()
{
   printf("--Print Integer:");
   int maxValue = HEDGE_ORDER_SLIPPAGE;
   int dbg  = 4;
   for(int i = 0; i <= maxValue; i++)
   {
      ENUM_HEDGE_ORDER_PROP_DOUBLE type = (ENUM_HEDGE_ORDER_PROP_DOUBLE)i;
      double value = HedgeOrderGetDouble(type);
      printf("----" + EnumToString(type) + ": " + DoubleToString(value, 5));
   }
}

void PrintDealParamsInt()
{
   printf("--Print Integer:");
   int maxValue = 1;
   for(int i = 0; i <= maxValue; i++)
   {
      ENUM_HEDGE_DEAL_PROP_INTEGER type = (ENUM_HEDGE_DEAL_PROP_INTEGER)i;
      ulong value = HedgeDealGetInteger(type);
      printf("----" + EnumToString(type) + ": " + (string)value);
   }
}

void PrintDealParamsDbl()
{
   printf("--Print Integer:");
   int maxValue = 2;
   for(int i = 0; i <= maxValue; i++)
   {
      ENUM_HEDGE_DEAL_PROP_DOUBLE type = (ENUM_HEDGE_DEAL_PROP_DOUBLE)i;
      double value = HedgeDealGetDouble(type);
      printf("----" + EnumToString(type) + ": " + DoubleToString(value, 5));
   }
}

void DrawSLTP()
{
   FOREACH_POSITION
   {
      if(!TransactionSelect(i))continue;
      //if(!Environment.IsMainPosition())continue;
      double sl = HedgePositionGetDouble(HEDGE_POSITION_SL);
      double tp = HedgePositionGetDouble(HEDGE_POSITION_TP);
      string name_tp = "ilan_tp " + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      //string name_sl = "ilan_sl " + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      if(ObjectCreate(ChartID(), name_tp, OBJ_TEXT, 0, TimeCurrent(), tp))
      {
         Comment("Create point");
         ObjectSetInteger(ChartID(), name_tp, OBJPROP_COLOR, clrGreen);
         ObjectSetString(ChartID(), name_tp, OBJPROP_TEXT, CharToString(0x95));
      }
      break;
   }
}

void TestHistoryTransTotal()
{
   int i = TransactionsTotal(MODE_HISTORY);
   printf("Trans total: " + (string)i);
}