//+------------------------------------------------------------------+
//|                                          PrintMagicByOrderID.mq5 |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#property script_show_inputs
#property version   "1.00"
input ulong OrderID = 2680623;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   HistorySelect(0, TimeCurrent());
   datetime dt = (datetime)HistoryOrderGetInteger(OrderID, ORDER_TIME_DONE);
   if(dt > 0)
   {
      printf("Ордер №" + (string)OrderID + " успешно выбран. Время установки ордера: " +
             TimeToString(dt, TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   }
   else
   {
      printf("Ордер №" + (string)OrderID + " не найден. Проверьте правильность ID ордера");
      return;
   }
   ulong magic = HistoryOrderGetInteger(OrderID, ORDER_MAGIC);
   printf((string)magic);
}
//+------------------------------------------------------------------+
