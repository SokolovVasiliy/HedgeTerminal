//+------------------------------------------------------------------+
//|                                                      advisor.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Vasiliy Sokolov, Russia, St.-Petersburg, 2013"
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "Prototypes.mqh"
#include <Trade\Trade.mqh>
#include <Arrays\ArrayInt.mqh>
#define MAGIC  20131111

input int periodFastSma = 1;   //Period fast SMA
input int periodSlowSma = 3;   //Period slow SMA
///
/// Handle of indicator fast iMA.
///
int handleFastMA;
///
/// Handle of indicator fast iMA.
///
int handleSlowMA;
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
///
/// Minimum lot of deal. 
///
double minLot;
///
/// Class for easy entry into the market.
///
CTrade trade;
///
/// Contains an index of long positions.
///
CArrayInt indexMyLongPos;
///
/// Contains an index of short positions
///
CArrayInt indexMyShortPos;
///
/// Initialize handles of MA indicators.
///
void OnInit()
{
   handleFastMA = iMA(Symbol(), PERIOD_M1, 3, 0, MODE_SMA, PRICE_CLOSE);
   handleSlowMA = iMA(Symbol(), PERIOD_M1, 3, 0, MODE_SMA, PRICE_CLOSE);
}
///
/// Check the conditions of each tick.
///
void OnTick(void)
{
   if(DetectNewBar() == false)return;
   if(MyShortPositionsCount())
      TryCloseShortPos();
   else
      TryOpenShortPos();
   if(MyLongPositionsCount())
      TryCloseLongPos();
   else
      TryOpenLongPos();
}
///
/// Return count positions has long direction type.
///
void RecalcCountPosition()
{
   longsPos=0;
   shortsPos = 0;
   indexMyLongPos.Clear();
   indexMyShortPos.Clear();
   for(int i = 0; i < HistoryPositionsTotal(); i++)
   {
      if(HedgePositionSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         continue;
      int magic = (int)HedgePositionGetInteger(HEDGE_POSITION_MAGIC);
      string symbol = HedgePositionGetString(HEDGE_POSITION_SYMBOL);
      if (magic != MAGIC || symbol != Symbol())continue;
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

///
/// Return true if long entry is executed, otherwise false.
///
bool TryOpenShortPos()
{
   bool res = false;
   if(CrossUnder())
      res = trade.Sell(minLot, NULL, 0.0, 0.0, 0.0, "");
   return res;
}
///
/// Return true if short entry is executed, otherwise false.
///
bool TryOpenLongPos()
{
   bool res = false;
   if(CrossOver())
      res = trade.Buy(minLot, NULL, 0.0, 0.0, 0.0, "");
   return res;
}
///
/// 
///
void TryCloseShortPos()
{
   for(int i = 0; i < indexMyShortPos.Total(); i++)
   {
      //if(HedgePositionSelect(indexMyShortPos.At(i) == false))continue;
      //TryCloseCurrentPos();
   }
}
///
/// 
///
void TryCloseLongPos()
{
   
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

///
/// Return true if fast sma cross over slow sma, otherwise false.
///
bool CrossOver()
{
   if(handleFastMA == -1 || handleSlowMA == -1)
      return false;
   double fastSma[2];
   CopyBuffer(handleFastMA, 0, 0, 2, fastSma);
   double slowSma[2];
   CopyBuffer(handleSlowMA, 0, 0, 2, slowSma);
   if(fastSma[0] < slowSma[0] &&
      fastSma[1] > slowSma[1])
      return true;
   return false;
}

///
/// Return true if fast sma cross under slow sma, otherwise true;
///
bool CrossUnder()
{
   if(handleFastMA == -1 || handleSlowMA == -1)
      return false;
   return !CrossOver();
}
///
/// Return lot of deal.
///
double GetLot()
{
   return minLot;
}
///
/// Try close selected position.
///
bool TryCloseCurrPos()
{
   //_LastError = 65938;
   return true;   
}

