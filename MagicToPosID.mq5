//+------------------------------------------------------------------+
//|                                                 MagicToPosID.mq5 |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property script_show_inputs
#include "\Math\Crypto.mqh"
input ulong Magic;
input ulong OrderId;
Crypto crypto;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   ulong magic = 0;
   if(OrderId > 0)
   {
      HistorySelect(0, TimeCurrent());
      magic = HistoryOrderGetInteger(OrderId, ORDER_MAGIC);
      printf("Selecet magic " + (string)magic);
   }
   else
      magic = Magic;
   ulong unhash = 0;
   bool b1 = crypto.GetBit(magic, 63);
   bool b2 = crypto.GetBit(magic, 62);
   if(!b1)return;
   ulong mg = magic;
   unhash = crypto.Decrypt(mg);
   crypto.SetBit(unhash, 63, b1);
   crypto.SetBit(unhash, 62, b2);
   ulong bType = 0xFC00000000000000 & unhash;
   bType = bType >> 56;
   uchar bitType = (uchar)bType;
   // 6 старших битов оставл€ем дл€ служебной информации.
   // остальное - дл€ идентификатора номера.
   ulong mask = 0x03FFFFFFFFFFFFFF;
   ulong id = mask & unhash;
   int dbg = 5;
   printf((string)id);
}
//+------------------------------------------------------------------+
