//+------------------------------------------------------------------+
//|                                                     exp_test.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

string B1 = "button1";
string B2 = "button2";

#include <Arrays\ArrayObj.mqh>

int OnInit()
{
   bool res = false;
   res = ObjectCreate(0, B1, OBJ_BUTTON, 0, 0, 0);
   res = ObjectSetInteger(0, B1, OBJPROP_XDISTANCE, 100);
   res = ObjectSetInteger(0, B1, OBJPROP_YDISTANCE, 100);
   res = ObjectSetInteger(0, B1, OBJPROP_XSIZE, 70);
   res = ObjectSetInteger(0, B1, OBJPROP_YSIZE, 30);
   
   res = ObjectCreate(0, B2, OBJ_BUTTON, 0, 0, 0);
   res = ObjectSetInteger(0, B2, OBJPROP_XDISTANCE, 200);
   res = ObjectSetInteger(0, B2, OBJPROP_YDISTANCE, 100);
   res = ObjectSetInteger(0, B2, OBJPROP_XSIZE, 70);
   res = ObjectSetInteger(0, B2, OBJPROP_YSIZE, 30);
   
   res = ObjectCreate(0, "label", OBJ_EDIT, 0, 0, 0);
   res = ObjectSetInteger(0, "label", OBJPROP_XSIZE, 1200);
   res = ObjectSetInteger(0, "label", OBJPROP_YSIZE, 70);
   string concat = "";
   for(int i = 0; i < 255; i++)
   {
      if(i == 20)continue;
      string s = /*" " +(string)i + */CharToString((uchar)i);
      concat += s;
   }
   //3,25
   ObjectSetString(0, "label", OBJPROP_TEXT, concat);
   printf(concat);
   ChartRedraw(0);
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   ObjectDelete(0, B1);
   ObjectDelete(0, B2);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (id == CHARTEVENT_OBJECT_CLICK)
   {
      //Объект на который нажали - кнопка?
      ENUM_OBJECT type = (ENUM_OBJECT)ObjectGetInteger(0, sparam, OBJPROP_TYPE);
      //Создаем событие: "кнопка нажата"
      if(type == OBJ_BUTTON)
      {
         if(sparam == B1)
         {
            bool state = ObjectGetInteger(0, B1, OBJPROP_STATE);
            // Если кнопка нажата - отжимаем другую кнопку
            if(state)
            {
               ObjectSetInteger(0, B2, OBJPROP_STATE, false);
               ObjectSetString(0, B2, OBJPROP_TEXT, "Отжата B2");
               ObjectSetString(0, B1, OBJPROP_TEXT, "Нажата B1");
            }
            //Отжать кнопку может только другая кнопка
            else
            {
               //
               // Здесь надо ожидать, что 
               // 1. Кнопка нажмется несразу, а с задержкой от 0 до 2 секунд.
               // 2. Кнопка вообще не нажмется, а так и будет находится
               //    в отжатом состоянии (такое происходит в выходные дни).
               //
               printf("Принудительно перевожу B1 в нажатое состояние");
               bool res = ObjectSetInteger(0, B1, OBJPROP_STATE, true);
               // Сейчас результат изменения свойств кнопки - истна, хотя визуально она их не изменила.
               if(!res)printf("Не удалось нажать кнопку, ошибка: " + _LastError);
               else printf("Кнопка нажата!");
            }
         }
         if(sparam == B2)
         {
            bool state = ObjectGetInteger(0, B2, OBJPROP_STATE);
            // Если кнопка нажата - отжимаем другую кнопку
            if(state)
            {
               ObjectSetInteger(0, B1, OBJPROP_STATE, false);
               ObjectSetString(0, B1, OBJPROP_TEXT, "Отжата B1");
               ObjectSetString(0, B2, OBJPROP_TEXT, "Нажата B2");
            }
            //Отжать кнопку может только другая кнопка
            else
            {
               //
               // Здесь надо ожидать, что 
               // 1. Кнопка нажмется несразу, а с задержкой от 0 до 2 секунд.
               // 2. Кнопка вообще не нажмется, а так и будет находится
               //    в отжатом состоянии (такое происходит в выходные дни).
               //
               printf("Принудительно перевожу B2 в нажатое состояние");
               bool res = ObjectSetInteger(0, B2, OBJPROP_STATE, true);
               // Сейчас результат изменения свойств кнопки - истна, хотя визуально она их не изменила.
               if(!res)printf("Не удалось нажать кнопку, ошибка: " + _LastError);
               else printf("Кнопка нажата!");
            }
         }
         
      }
   }
}

