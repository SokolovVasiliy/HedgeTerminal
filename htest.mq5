//+------------------------------------------------------------------+
//|                                                        htest.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   ObjectCreate(0, "TestButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "TestButton", OBJPROP_XDISTANCE, 200);
   ObjectSetInteger(0, "TestButton", OBJPROP_YDISTANCE, 200);
   ObjectSetInteger(0, "TestButton", OBJPROP_XSIZE, 200);
   ObjectSetInteger(0, "TestButton", OBJPROP_YSIZE, 100);
   ObjectSetInteger(0, "TestButton", OBJPROP_BORDER_COLOR, clrBlack);
   ObjectSetInteger(0, "TestButton", OBJPROP_BGCOLOR, clrWhite);
   
   EventSetTimer(1);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0, "label");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   const OnlyOne *oo = OnlyOne::Instance();
   oo.Push1();
   //Print(oo.GetSum());
   //tester::i = MathRand();
   //Print(tester::i);
}

//+------------------------------------------------------------------+



/// 
/// Паттерн одиночка
///
class OnlyOne
{
   public:
        static const OnlyOne* Instance()
        {
            static OnlyOne theSingleInstance();
            return GetPointer(theSingleInstance);
        }
        void Push1(){sum++;}
        int GetSum(){return sum;}
   private:        
        OnlyOne(){};
        int sum;
};

const OnlyOne *myDD;

void OnTimer(void)
{
   const OnlyOne *myoo = OnlyOne::Instance();
   //Print("OnTimer(): " + (string)myoo.GetSum());
}

