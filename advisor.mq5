//+------------------------------------------------------------------+
//|                                                      advisor.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Vasiliy Sokolov, Russia, St.-Petersburg, 2013"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Prototypes.mqh"
void OnInit(void)
{ 
   EventSetMillisecondTimer(5000);
}
void OnTimer(void)
{
   int total = HedgePositionTotal();
   //printf("OnTimer... " +  total);
   if(total > 0 && HedgePositionSelect(0, SELECT_BY_POS, MODE_ACTIVE))
   {
      HedgeTradeRequest request;
      request.action = HEDGE_ACTION_CLOSE;
      //Close all position
      request.volume = HedgePositionGetDouble(HEDGE_POSITION_VOLUME);
      request.comment = "exit deal by expert";
      request.asynch_mode = true;
      MqlTradeResult result;
      HedgeOrderSend(request, result);
   }   
}

