//+------------------------------------------------------------------+
//|                                           HedgeDemonstration.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
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
   Experts.Add(maexp);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Experts.Clear();
   //Shutdown();
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

