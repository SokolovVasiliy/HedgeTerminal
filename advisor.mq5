//+------------------------------------------------------------------+
//|                                                      advisor.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Vasiliy Sokolov, Russia, St.-Petersburg, 2013"
#property link      "http://www.mql5.com"
#property version   "1.00"

#define MAGIC 12847
#include "Prototypes.mqh"
#include <Trade\Trade.mqh>

CTrade trade;

void OnInit(void)
{ 
   trade.SetExpertMagicNumber(MAGIC);
   EventSetMillisecondTimer(5000);
}
void OnTick(void)
{
   int myPositions = 0;
   int total = HedgePositionTotal();
   //iterate open position...
   for(int i = 0; i < total; i++)
   {
      if(!HedgePositionSelect(i))
         continue;
      if(HedgePositionGetInteger(HEDGE_POSITION_MAGIC) != MAGIC)
         continue;
      myPositions++;
      double profitTarget = SymbolInfoDouble(Symbol(), SYMBOL_POINT) * SymbolInfoInteger(Symbol(), SYMBOL_SPREAD)*2;
      if(HedgePositionGetDouble(HEDGE_POSITION_PROFIT_POINTS) > profitTarget)
      {
         printf("exit by target profit");
         HedgeTradeRequest request;
         request.action = HEDGE_ACTION_CLOSE;
         request.volume = HedgePositionGetDouble(HEDGE_POSITION_VOLUME);
         request.comment = "by target profit";
         MqlTradeResult result;
         HedgeOrderSend(request, result);
      }
   }
   //Set limit for my open position.
   if(myPositions > 10)return;
   //probability of new signal depends from magic number
   int rnd = MathRand();
   if(rnd%64 != 0)return;
   printf("Entry new signal: " + rnd + " myPos: " + myPositions);
   double vol = (MathRand()&16)*SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP)+
                     SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   if(MathRand()%2 == 0)
      trade.Buy(vol, NULL, 0.0, 0.0, 0.0, "new rand signal");
   else
      trade.Sell(vol, NULL, 0.0, 0.0, 0.0, "new rand signal");   
}

