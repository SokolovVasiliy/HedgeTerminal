//+------------------------------------------------------------------+
//|                                           HedgeDemonstration.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
///
/// if this const define using Hedge API library, otherwise using classic mode for only one expert.
///
#define HEDGES
#include "MovingAverageExpert.mqh"
///
/// Array of experts.
///
CArrayObj Experts;

///
/// Init experts.
///
int OnInit()
{
   MAExpert* maexp = new MAExpert();
   maexp.SetSlowMA(3);
   Experts.Add(maexp);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Experts.Clear();
}
///
/// Run experts every tick.
///
void OnTick()
{
   for(int i = 0; i < Experts.Total(); i++)
   {
      MAExpert* expert = Experts.At(i);
      expert.Run();
   }
}

