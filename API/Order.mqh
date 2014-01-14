#include "Transaction.mqh"
#include "..\Log.mqh"
///
/// ������ ������.
///
enum ENUM_ORDER_STATUS
{
   ///
   /// ��������� �����, �� ������������ � ���� ������ ���������.
   ///
   ORDER_NULL,
   ///
   /// ����������, ��� �� ����������� �����.
   ///
   ORDER_PENDING,
   ///
   /// ����� � �������� ����������.
   ///
   ORDER_EXECUTING,
   ///
   /// �����������, ������������ �����.
   ///
   ORDER_HISTORY
};

class Order : public Transaction
{
   public:
      Order(void);
      Order(ulong orderId);
      Order(CDeal* deal);
      Order(Order* order);
      Order* AnigilateOrder(Order* order);
      void AddDeal(CDeal* deal);
      void DeleteDealAt(int index);
      CDeal* DealAt(int index);
      int DealsTotal();
      void AddVolume(int vol);
      ENUM_ORDER_STATUS Status();
      ENUM_ORDER_STATUS RefreshStatus(void);
      void Init(ulong orderId);
      ulong PositionId();
      bool IsPending();
      Order* Clone();
      virtual double ExecutedVolume();
      ~Order();
   private:
      double executeVolume;
      bool isRefresh;
      Order* AnigilateVol(double& vol);
      virtual bool MTContainsMe();
      ENUM_ORDER_STATUS status;
      CArrayObj* deals;
};

/*PUBLIC MEMBERS*/
Order::Order() : Transaction(TRANS_ORDER)
{
   status = ORDER_NULL;
}
///
/// ������� ����� � �������������� idOrder. ����� � ��������� ���������������
/// ������ ������������ � ���� ������ ������� ���������, � ��������� ������, ������
/// ������ ENUM_ORDER_STATUS ����� ��������������� ORDER_NULL (���������������� �����).
///
Order::Order(ulong idOrder):Transaction(TRANS_ORDER)
{
   Init(idOrder);
}

///
/// ������� ����� ����� �� ����� �� ��� ������.
///
Order::Order(CDeal* deal) : Transaction(TRANS_ORDER)
{
   SetId(deal.OrderId());
   AddDeal(deal);
   RefreshStatus();
}

///
/// ������� ������ ����� ������ order.
///
Order::Order(Order *order) : Transaction(TRANS_ORDER)
{
   status = order.Status();
   deals = new CArrayObj();
   for(int i = 0; i < order.DealsTotal(); i++)
   {
      CDeal* deal = order.DealAt(i);
      deals.Add(deal.Clone());
   }
}

///
/// ���������� ������ ����� ������.
///
Order* Order::Clone(void)
{
   return new Order(GetPointer(this));
}

Order::~Order(void)
{
   if(deals != NULL)
   {
      deals.Clear();
      delete deals;
   }
}

void Order::Init(ulong orderId)
{
   SetId(orderId);
   RefreshStatus();
}

///
/// ���������� ������������� �������, � ������� ����� ������������ �����.
///
ulong Order::PositionId()
{
   ulong posId = HistoryOrderGetInteger(GetId(), ORDER_MAGIC);
   if(HistoryOrderGetInteger(posId, ORDER_TIME_DONE) > 0)
      return posId;
   return 0;
}
///
/// ���������� ��������� ��������� ������ ������. ������ ����� ���������� �� ������������.
/// ��� ������� ����������� ������� ����������� ������� Checkstatus(). 
/// \return ��������� ��������� ������ ������.
///
ENUM_ORDER_STATUS Order::Status(void)
{
   return status;
}

///
/// ���������� ������ ������ ENUM_ORDER_STATUS �� ��������� ���������� ���������� ��
/// ���� ������ ������� ���������. �������������� ��������� ��������� ��������� �������
/// ������ � ������� ����������.
///
ENUM_ORDER_STATUS Order::RefreshStatus()
{
   if(IsPending())
   {
      status = ORDER_PENDING;
      return status;
   }
   if(MTContainsMe())
   {
      if(deals == NULL || deals.Total() == 0)
         status = ORDER_EXECUTING;
      else
         status = ORDER_HISTORY;   
   }
   else
   {
      SetId(0);
      status = ORDER_NULL;
   }
   return status;
}

///
/// ���������� ����������� �����.
///
double Order::ExecutedVolume(void)
{
   if(deals == NULL)
      return 0.0;
   if(isRefresh)
      return executeVolume;
   if(!isRefresh || executeVolume == 0.0)
   {
      executeVolume = 0.0;
      for(int i = 0; i < deals.Total(); i++)
      {
         CDeal* deal = deals.At(i);
         executeVolume += deal.ExecutedVolume();
      }
   }
   return executeVolume;
}
///
/// ���������� NULL, ���� ����������� ����� ����� ������������.
/// ���������� ����� ������������ �����, ���� ����� �������� ������ ������ ������������.
/// ���������� ����� �������� �����, ���� ����� ������������ ������ ������ ��������.
///
/*Order* Order::AnigilateOrder(Order* outOrder)
{
   if(outOrder.PositionId() != PositionId())
      return NULL;
   if(outOrder.GetId() == GetId())
      return NULL;
   int total = outOrder.DealsTotal();
   //thisOrder > outOrder = thisOrder + (partThisOrder+outOrder);
   //thisOrder == outOrder = thisOrder+outOrder;
   //thisOrder < outOrder = outOrder + (thisOrder+partOutOrder);
   Order* activeOrder = NULL;
   CArrayObj* histOrders = new CArrayObj();
   for(int i = 0; i < outOrder.DealsTotal(); i++)
   {
      CDeal* deal = outOrder.DealAt(i);
      double vol = deal.ExecutedVolume();
      if(DealsTotal()>0)
      {
         Order* newHistoryOrder = AnigilateVol(vol);
         histOrders.Add(newHistoryOrder);
         if(vol > 0)
         {
            CDeal* restDeal = new CDeal(deal.GetId());
            restDeal.ExecutedVolume(vol);
            if(activeOrder == NULL)
               activeOrder = new Order();
            activeOrder.AddDeal(restDeal);
            continue;
         }
      }
      else
      {
         if(activeOrder == NULL)
            activeOrder = new Order();
         activeOrder.AddDeal(deal);
      }
   }
   
   return new Order();
}*/


///
/// \return ������������ ����� ������������ �������.
///
/*Order* Order::AnigilateVol(double& vol)
{
   Order* order = new Order();
   int dealVol = 0;
   int totalVol = 0;
   for(int i = 0; i < deals.Total(); i++)
   {
      CDeal* deal = deals.At(i);
      dealVol = deal.ExecutedVolume();
      //������� ����� ������������ �����, ������������ �������.
      COrder* histInitOrder = new CDeal(deal.GetId());
      histInitOrder.ResetVolume();
      if(vol <= dealVol)
         histInitOrder.AddVolume(vol);
      else
         histInitOrder.AddVolume(dealVol);
      order.AddDeal(histInitOrder);
      
      vol *= -1;
      int balans = deal.Volume() + vol;
      deal.AddVolume(vol);
      dealVol = deal.Volume();
      totalVol += dealVol;
      if(dealVol == 0)
      {
         deals.Delete(i);
         i--;
      }
      if(balance > 0)
         break;
      vol = MathAbs(balance);
      if(deals.Total() == 0)
         status = ORDER_NULL;
   }
   return order;
}*/

///
/// ��������� ����� � ������������ �������. ���� ���������� ������� �����,
/// ������������ ������������� ��������.
/// \return ���������� ���������� ���������� ������.
///
/*int Order::AddVolume(int vol)
{
   int redVol = 0; //���������� ����� ������.
   int exVol;  //���������� ����� ������.
   for(int i = 0; i < deals.Total(); i++)
   {
      CDeal* deal = deals.At(i);
      int balans = deal.Volume() + vol;
      deal.AddVolume(vol);
      exVol = deal.Volume();
      redVol += exVol;
      if(exVol == 0)
         deals.Delete(i);
      if(balance > 0)
         break;
      vol = MathAbs(balance);
   }
   if(deals.Total() == 0)
      status = ORDER_NULL;
   return redVol;
}*/

///
/// ��������� ������ � ������ ������ ������.
///
void Order::AddDeal(CDeal* deal)
{
   if(deal.Status() == DEAL_BROKERAGE ||
      deal.Status() == DEAL_NULL)
   {
      LogWriter("Type of the deal '" + EnumToString(deal.Status()) + "' not supported in order.", MESSAGE_TYPE_WARNING);
      return;
   }
   if(deal.OrderId() != GetId() && GetId() != 0)
   {
      LogWriter("Order ID #" + (string)deal.OrderId() + " in the deal #" + (string)deal.GetId() +
                " is not equal order id. Adding failed.", MESSAGE_TYPE_WARNING);
      return;
   }
   if(GetId() == 0)
      SetId(deal.OrderId());
   if(deals == NULL)
      deals = new CArrayObj();
   deals.Add(deal);
   RefreshStatus();
}

///
/// ������� ������ �� ������ ������.
///
void Order::DeleteDealAt(int index)
{
   if(deals.Total() <= index)return;
   deals.Delete(index);
}
///
/// ���������� ������ ����������� � ������ ������ �� ������� index.
///
CDeal* Order::DealAt(int index)
{
   return deals.At(index);
}

///
/// ���������� ���������� ������.
///
int Order::DealsTotal()
{
   if(deals == NULL)
      return 0;
   return deals.Total();
}

///
/// ������, ���� �������� �������� ���������� �� ������ �
/// � ������� ��������������� � ���� � ��������� ������.
///
bool Order::MTContainsMe()
{
   LoadHistory();
   if(HistoryOrderGetInteger(GetId(), ORDER_TIME_SETUP) > 0)
      return true;
   return false;
}

bool Order::IsPending()
{
   return OrderSelect(GetId());
}
