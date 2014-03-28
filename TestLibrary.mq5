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
   return(INIT_SUCCEEDED);
}


void OnTick()
{
   TestAPI();
}

void TestAPI()
{
   int total = ActivePositionsTotal();
   for(int i = 0; i < ActivePositionsTotal(); i++)
   {
      if(!HedgePositionSelect(i, SELECT_BY_POS, MODE_TRADES))
         return;
      ulong magic = HedgePositionGetInteger(HEDGE_POSITION_MAGIC);
      //HedgePositionGetInteger(HEDGE_POSITION_);
      if(magic > 0)continue;
      HedgeClosingRequest request;
      //request.asynch_mode = true;
      //request.volume = 0.1;
      request.exit_comment = "exit by expert";
      if(!HedgePositionClose(request))
         printf(EnumToString(GetHedgeError()));
   }
}
