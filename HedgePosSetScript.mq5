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
   string a="mesage 1: Hello word";
   string b="message 2: It's simple code";
   string c="message 2: It's simple codes";
   string d = "lsdkjfr skdjhf jhdkfjh ei473847t5y7 sdfjkhghui939 39485 598456789839845 jskldfmn, skdkldjf 093u4u88573975y vkjwkdejf skjfkj 09485785757 9837475 274356 ";
   string e = "1";
   Print(adler32(a)); // 573139109
   Print(adler32(b)); // 2169506126
   Print(adler32(c)); // 2333149633
   Print(adler32(d)); // 2333149633
   Print(adler32(e)); // 2333149633
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