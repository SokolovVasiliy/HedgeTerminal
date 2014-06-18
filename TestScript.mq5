//+------------------------------------------------------------------+
//|                                                   TestScript.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#define MeTest _xskd
class MeTest
{
   public:
   MeTest(){;}
   ~MeTest(){;}
};
void OnStart()
{
   MeTest t;
   printf(GetTypeName(t));
}

template<typename T>
string GetTypeName(const T &t)
  {
//--- вернем тип в виде строки
   return(typename(T));
//---
  }
