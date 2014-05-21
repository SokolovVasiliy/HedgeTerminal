//+------------------------------------------------------------------+
//|                                                    TestDeals.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "Prototypes.mqh"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   if(!TransactionSelect(4453278, SELECT_BY_TICKET, MODE_TRADES))
      printf("pos not select");
   if(!HedgeOrderSelect(ORDER_SELECTED_INIT))
      printf("order not select");
   int deal = HedgeOrderGetInteger(HEDGE_ORDER_DEALS_TOTAL);
   printf("Deals total: " + deal);
  }
//+------------------------------------------------------------------+
