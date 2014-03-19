//+------------------------------------------------------------------+
//|                                                      advisor.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Vasiliy Sokolov, Russia, St.-Petersburg, 2013"
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "Prototypes.mqh"

#define MAGIC  20131111
///
/// Handle of indicator iMA.
///
int handleMA;
///
/// Count of all positions.
///
int totalPos;
///
/// Count of short positions.
///
int shortsPos;
///
/// Count of long positions
///
int longsPos;
///
/// Include last time new bar.
///
datetime lastShortBar;
///
/// Include last time bar.
///
datetime timeLastBar;

void OnInit()
{
   handleMA = iMA(Symbol(), PERIOD_M1, 3, 0, MODE_SMA, PRICE_CLOSE);
}

void OnTick(void)
{
   if(DetectNewBar() == false)return;
   if(MyShortPositionsCount())
      CheckCloseShortPos();
   else
      CheckOpenShortPos();
   if(MyLongPositionsCount())
      CheckCloseLongPos();
   else
      CheckOpenLongPos();
}
///
/// Return count positions has long direction type.
///
void RecalcCountPosition()
{
   longsPos=0;
   shortsPos = 0;
   for(int i = 0; i < HistoryPositionsTotal(); i++)
   {
      if(HedgePositionSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         continue;
      int magic = (int)HedgePositionGetInteger(HEDGE_POSITION_MAGIC);
      string symbol = HedgePositionGetString(HEDGE_POSITION_SYMBOL);
      if (magic != MAGIC || symbol != Symbol())continue;
      ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)HedgePositionGetInteger(HEDGE_POSITION_TYPE);
      if(orderType%2 == 0)
         longsPos++;
      else
         shortsPos++;
   }
}

///
/// Return count positions has long direction type.
///
int MyShortPositionsCount()
{
   if(HistoryPositionsTotal() != totalPos)
   {
      RecalcCountPosition();
      totalPos = HistoryPositionsTotal();
   }
   return longsPos;
}
///
/// Return count positions has short direction type.
///
int MyLongPositionsCount()
{
   if(HistoryPositionsTotal() != totalPos)
   {
      RecalcCountPosition();
      totalPos = HistoryPositionsTotal();
   }
   return shortsPos;
}

void CheckOpenShortPos()
{
   double values[2];
   CopyBuffer(handleMA, 0, 0, 2, values);
   double currentPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   if(currentPrice < values[0])
      //SendShortPosition;
}

void CheckCloseShortPos()
{

}

void CheckCloseLongPos()
{

}

void CheckOpenLongPos()
{
   double values[2];
   CopyBuffer(handleMA, 0, 0, 2, values);
   double currentPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   if(currentPrice > values[0])
      //SendShortPosition;
}

///
/// Return true if new bar detected, otherwise false.
///
bool DetectNewBar()
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

