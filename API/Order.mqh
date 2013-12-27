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
      void AddDeal(CDeal* deal);
      void AddVolume(int vol);
      ENUM_ORDER_STATUS Status();
      ENUM_ORDER_STATUS RefreshStatus(void);
      void Init(ulong orderId);
      ulong PositionId();
      bool IsPending();
      ~Order();
   private:
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
   if(MTConteinsMe())
   {
      if(deals == NULL || deals.Total() == 0)
      {
         SetId(0);
         status = ORDER_NULL;
      }
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
///
///
Order* AnigilateVol(int vol)
{
   Order* order = new Order();
   int dealVol = 0;
   int totalVol = 0;
   for(int i; i < deals.Total(); i++)
   {
      CDeal* deal = deals.At(i);
      dealVol = deal.Volume();
      
      CDeal* ndeal = new CDeal(deal.GetId());
      ndeal.ResetVolume();
      if(vol <= dealVol)
         ndeal.AddVolume(vol);
      else
         ndeal.AddVolume(dealVol);
      order.AddDeal(ndeal);
      
      vol *= -1;
      int balans = deal.Volume() + vol;
      deal.AddVolume(vol);
      dealVol = deal.Volume();
      totalVol += dealVol;
      if(dealVol == 0)
         deals.Delete(i);
      if(balance > 0)
         break;
      vol = MathAbs(balance);
   }
   return order;
}
///
/// ��������� ����� � ������������ �������. ���� ���������� ������� �����,
/// ������������ ������������� ��������.
/// \return ���������� ���������� ���������� ������.
///
int Order::AddVolume(int vol)
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
}
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
      LogWriter("Order ID #" + deal.OrderId() + " in the deal #" + deal.GetId() +
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
/// ������, ���� �������� �������� ���������� �� ������ �
/// � ������� ��������������� � ���� � ��������� ������. ����� �������
/// ������� � �������� ������ ���� ��������� ������� ������ � �������.
///
bool Order::MTContainsMe()
{
   if(HistoryOrderGetInteger(GetId(), ORDER_TIME_SETUP) > 0)
      return true;
   return false;
}

bool Order::IsPending()
{
   return OrderSelect(GetId());
}