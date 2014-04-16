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
#define API_INTRO
#include "\API\HedgePanelAPI.mq5"
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
   PrintResult();
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

void PrintResult()
{
   int total = api.HistoryPosTotal();
   //ExpertRemove();
   /*for(int i = 0; i < total; i++)
   {
      Transaction* trans = api.HistoryPosAt(i);
      if(trans.TransactionType() != TRANS_POSITION)
         continue;
      Position* pos = trans;
      string profit = DoubleToString(pos.ProfitInCurrency(), 2);
      string timeEntry = TimeToString(pos.EntryExecutedTime()/1000, TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      string id = IntegerToString(pos.EntryOrderId());
      printf(id + "\t" + timeEntry + "\t" + profit);
   }*/
}

