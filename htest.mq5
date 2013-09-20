//+------------------------------------------------------------------+
//|                                                        htest.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Object.mqh>

class A
{
   public:
      int GetA(){return a;};
   private:
      int a;
};

class B
{
   public:
      void MoveA(A* aclass)
      {
         Move(aclass);
      }
      virtual void Move(A* aclass)
      {
         int i = aclass.GetA();
      }
};

class C : public B
{
   virtual void Move(A* aclass)
   {
      int l = aclass.GetA()+2;
   }
};

void OnStart()
{
   ;
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

