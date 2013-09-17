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
   
   ObjectCreate(0, "cell", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "cell", OBJPROP_XDISTANCE, 15);
   ObjectSetInteger(0, "cell", OBJPROP_YDISTANCE, 60);
   ObjectSetInteger(0, "cell", OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, "cell", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "cell", OBJPROP_BORDER_COLOR, clrBlack);
   ObjectSetInteger(0, "cell", OBJPROP_BACK, false);
   //ObjectSetInteger(0, "cell", OBJPROP_SELECTED, false);
   
   ObjectCreate(0, "edittext", OBJ_EDIT, 0, 30, 30);
   ObjectSetInteger(0, "edittext", OBJPROP_XDISTANCE, 40);
   ObjectSetInteger(0, "edittext", OBJPROP_YDISTANCE, 50);
   ObjectSetInteger(0, "edittext", OBJPROP_BGCOLOR, clrNONE);
   ObjectSetInteger(0, "edittext", OBJPROP_BORDER_COLOR, clrNONE);
   //ObjectSetInteger(0, "edittext", OBJPROP_WIDTH, 3);
   ObjectSetString(0, "edittext", OBJPROP_TEXT, "edit text");
   ObjectSetInteger(0, "edittext", OBJPROP_BACK, false);
   
   
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

