//+------------------------------------------------------------------+
//|                                                      TestAPI.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#define API_INTRO
#include "\API\HedgePanelAPI.mq5"
#include "Prototypes.mqh"
void OnTick()
{
   //printf((string)ERR_INDICATOR_DATA_NOT_FOUND);
   int total = ActivePositionsTotal();   
   if(total == 0)return;
   if(!HedgePositionSelect(0, SELECT_BY_POS, MODE_TRADES))return;
   HedgeClosingRequest request;
   request.asynch_mode = true;
   //request.volume = HedgePositionGetDouble(HEDGE_POSITION_VOLUME);
   request.exit_comment = "exit by expert";
   printf("Try closing 0 position");
   if(!HedgePositionClose(request))
      printf(EnumToString(GetHedgeError()));
}



