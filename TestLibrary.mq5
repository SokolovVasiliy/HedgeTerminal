//+------------------------------------------------------------------+
//|                                                  TestLibrary.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "Prototypes.mqh"

int OnInit()
{
   TestAPI();
   return(INIT_SUCCEEDED);
}


void OnTick()
{
      
}

void TestAPI()
{
   int total = ActivePositionsTotal();
   bool res = HedgePositionSelect(0, SELECT_BY_POS, MODE_TRADES);
   HedgePositionSelect();
   printf((string)total + " " + (string)res);
   HedgeClosingRequest request;
   //request.asynch_mode = true;
   //request.volume = 0.1;
   request.exit_comment = "exit by expert";
   if(!HedgePositionClose(request))
      printf(EnumToString(GetHedgeError()));
}
