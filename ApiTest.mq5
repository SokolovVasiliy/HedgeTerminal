//+------------------------------------------------------------------+
//|                                                      ApiTest.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

//#define API_INTRO
#ifdef API_INTRO
   #include ".\API\HedgePanelAPI.mq5"
#else
   #include "Prototypes.mqh"
#endif
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   int total = TransactionsTotal(MODE_HISTORY);
   if(!TransactionSelect(total-1, SELECT_BY_POS, MODE_HISTORY))
      printf("Error select pos: " + EnumToString(GetHedgeError()));
   //printf("POSITION PARAMS:");
   //PrintPositionParamsInt();
   //PrintPositionParamsDbl();
   //PrintPositionParamsStr();
   if(!HedgeOrderSelect(ORDER_SELECTED_INIT))
      printf("Error select order: " + EnumToString(GetHedgeError()));
   //PrintOrderParamsInt();
   //PrintOrderParamsDbl();
   total = (int)HedgeOrderGetInteger(HEDGE_ORDER_DEALS_TOTAL);
   if(total > 0)
      if(!HedgeDealSelect(0))
         printf("Error select deal: " + EnumToString(GetHedgeError()));
   PrintDealParamsDbl();
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