//+------------------------------------------------------------------+
//|                                                Adler32_Sample.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
  }
//+------------------------------------------------------------------+

ulong adler32(string buf)
  {
     ulong s1 = 1;
     ulong s2 = 0;
     uint buflength=StringLen(buf);
     uchar array[];
     ArrayResize(array, buflength,0);
     StringToCharArray(buf, array, 0, -1, CP_ACP);
     for (uint n=0; n<buflength; n++)
     {
        s1 = (s1 + array[n]) % 65521;
        s2 = (s2 + s1)     % 65521;
     }
     return ((s2 << 16) + s1);
  }