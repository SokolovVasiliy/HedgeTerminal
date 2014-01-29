/*#define LESS -1;
#define GREATE 1;
#define EQUAL 0;
#define HLIBRARY*/
//#include "Globals.mqh"
#include "\API\Transaction.mqh"
#include "\API\Order.mqh"
#include "\API\Position.mqh"

#define IN_DEAL_ID 1008050925
#define  OUT_DEAL_ID 1008051235

#define MANUAL

void OnStart()
{
   HistorySelect(0, TimeCurrent());
   ExchangerList list;
   list.inOrder = GenManualInOrder();
   list.outOrder = GenManualOutOrder();
   Position::ExchangerOrder(list);
   Order* hInOrder = list.histInOrder;
   Order* hOutOrder = list.histOutOrder;
   int k = 6;
   for(int i = 0; i < list.inOrder.DealsTotal(); i++)
   {
      Deal* in_deal = list.inOrder.DealAt(i);
      printf("in: " + (string)in_deal.VolumeExecuted());
   }
   /*for(int i = 0; i < exch.histInOrder.DealsTotal(); i++)
   {
      Deal* in_deal = exch.histInOrder.DealAt(i);
      printf("hist_in: " + (string)in_deal.ExecutedVolume());
   }
   for(int i = 0; i < exch.histOutOrder.DealsTotal(); i++)
   {
      Deal* out_deal = exch.histOutOrder.DealAt(i);
      printf("hist_out: " + (string)out_deal.ExecutedVolume());
   }*/
   delete list.histInOrder;
   delete list.histOutOrder;
   delete list.inOrder;
   delete list.outOrder;
   
}
///
/// Генерирует входящий ордер.
///
Order* GenManualInOrder()
{
   Order* order = new Order();
   order.AddDeal(GetDeal(3));
   order.AddDeal(GetDeal(7));
   order.AddDeal(GetDeal(1));
   return order;
}

///
/// Генерирует входящий ордер.
///
Order* GenManualOutOrder()
{
   Order* order = new Order();
   order.AddDeal(GetDeal(4));
   order.AddDeal(GetDeal(2));
   return order;
}


///
/// Генерирует входящий ордер.
///
Order* GenRandomOrder()
{
   Order* order = new Order();
   order.AddDeal(GetDeal(3));
   order.AddDeal(GetDeal(7));
   order.AddDeal(GetDeal(1));
   return order;
}

Deal* GetDeal(double vol)
{
   Deal* deal = new Deal(IN_DEAL_ID);
   deal.VolumeExecuted(vol);
   return deal;
}



