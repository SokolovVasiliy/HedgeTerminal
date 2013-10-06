//+------------------------------------------------------------------+
//|                                                        htest.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include "Time.mqh"



void OnStart()
{
   //CTime time(1928372823372);
   //string format = time.TimeToString(TIME_DATE | TIME_MINUTES | TIME_MSC);
   //printf(format);
   //printf(ORDER_TYPE_BUY);
   //printf(ORDER_TYPE_BUY_STOP);
   //printf(ORDER_TYPE_BUY_LIMIT);
   //printf(ORDER_TYPE_BUY_STOP_LIMIT);
   printf("CHARTEVENT_CHART_CHANGE: " + CHARTEVENT_CHART_CHANGE);
   printf("CHARTEVENT_OBJECT_CLICK: " + CHARTEVENT_OBJECT_CLICK);
   printf("CHARTEVENT_OBJECT_CHANGE: " + CHARTEVENT_OBJECT_CHANGE);
   printf("CHARTEVENT_OBJECT_CREATE: " + CHARTEVENT_OBJECT_CREATE);
   printf("CHARTEVENT_MOUSE_MOVE: " + CHARTEVENT_MOUSE_MOVE);
   printf("CHARTEVENT_CLICK: " + CHARTEVENT_CLICK);
   bool res = false;
   res = ObjectCreate(0, "button", OBJ_BUTTON, 0, 0, 0);
   res = ObjectSetInteger(0, "button", OBJPROP_STATE, true);
   res = ObjectSetInteger(0, "button", OBJPROP_BGCOLOR, clrBlack);
   int d = 5;
   //for(char ch = 0; ch < CHAR_MAX; ch++)
   //   printf(CharToString(ch));
}
/// 
/// Паттерн одиночка
///
/*class OnlyOne
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
}*/

