#include "Transaction.mqh"
#include "..\Log.mqh"
///
/// ������ ������.
///
enum ENUM_ORDER_STATUS
{
   ///
   /// ��������� �����, �� ������������ � ���� ������ ���������, ���� �����,
   /// ��� ������ ���� ��������� ����������.
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
      ~Order();
      
      Order* AnigilateOrder(Order* order);
      void AddDeal(CDeal* deal);
      
      string Comment();
      long TimeSetup();
      long TimeExecuted();
      
      Order* Clone();
      int ContainsDeal(CDeal* deal);
      
      void DeleteDealAt(int index);
      CDeal* DealAt(int index);
      int DealsTotal();
      void DealChanged(CDeal* deal);
      
      double PriceSetup();
      double PriceExecuted();
      
      ulong GetMagicForClose();
      
      void Init(ulong orderId);
      bool IsPending();
      
      void LinkWithPosition(CPosition* pos); 
      
      ulong PositionId();
      CPosition* Position(){return position;}
      
      void Refresh();
      
      ENUM_ORDER_STATUS Status();
      
      
      virtual double VolumeExecuted(void);
      double VolumeSetup(void);
      double VolumeReject(void);
      
   private:
      virtual bool IsHistory();
      ENUM_ORDER_STATUS RefreshStatus(void);
      void RecalcValues(void);
      
      ///
      ///���� ����� ����������� � �������, �������� ������ �� ���.
      ///
      CPosition* position;
      ///
      /// �������� �������������� �����, ��� ���������� ������.
      ///
      double volumeSetup;
      ///
      /// �������� ����������� ����� ������.
      ///
      double volumeExecuted;
      ///
      /// �������� ����� ��������� ������.
      ///
      CTime timeSetup;
      ///
      /// �������� ����� ���������� ������.
      ///
      CTime timeExecuted;
      ///
      /// �������� ���� ��������� ������.
      ///
      double priceSetup;
      ///
      /// �������� ���������������� ���� �����.
      ///
      double priceExecuted;
      ///
      /// �������� ������ ������.
      ///
      ENUM_ORDER_STATUS status;
      
      ///
      /// �������� ������ ������.
      ///
      CArrayObj deals;
      ///
      /// �������� ����������� � ������.
      ///
      string comment;
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
   AddDeal(deal);
}

///
/// ������� ������ ����� ������ order.
///
Order::Order(Order *order) : Transaction(TRANS_ORDER)
{
   SetId(order.GetId());
   for(int i = 0; i < order.DealsTotal(); i++)
   {
      CDeal* deal = order.DealAt(i);
      CDeal* ndeal = deal.Clone();
      ndeal.LinqWithOrder(GetPointer(this));
      deals.Add(ndeal);
   }
   status = order.Status();
   position = order.Position();
   priceSetup = order.PriceSetup();
   priceExecuted = order.PriceExecuted();
   timeSetup = order.TimeSetup();
   timeExecuted = order.TimeExecuted();
   volumeSetup = order.VolumeSetup();
   volumeExecuted = order.VolumeExecuted();
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
   deals.Clear();
}

void Order::Init(ulong orderId)
{
   SetId(orderId);
   Refresh();
}


///
/// ���������� ������������� �������, � ������� ����� ������������ �����.
///
ulong Order::PositionId()
{
   //����� �����������?
   ulong posId = HistoryOrderGetInteger(GetId(), ORDER_MAGIC);
   if(HistoryOrderGetInteger(posId, ORDER_TIME_DONE) > 0)
      return posId;
   //����� �����������.
   return GetId();
}

///
/// ������������� ������ �� �������, � ������� ����������� ������ �����.
///
void Order::LinkWithPosition(CPosition* pos)
{
   if(CheckPointer(pos) == POINTER_INVALID)
      return;
   if(pos.GetId() > 0 && pos.GetId() != PositionId())
   {
      LogWriter("Link order failed: this order has a different id with position id.", MESSAGE_TYPE_WARNING);
      return;
   }
   position = pos;
}

///
/// ������, ������������� ����� ������, �������� ��� �������,
/// ����� �� ��������� ����������.
///
void Order::DealChanged(CDeal* deal)
{
   int index = ContainsDeal(deal);
   if(index == -1)return;
   //CDeal* deal = deals.At(index);
   //if(deal.VolumeExecuted() == 0)
   Refresh();
}

///
/// ������� � ������ ������, ������ ��� id �����
/// id ���������� ������ � � ������ ������ ����������
/// ������ ���� ������ � ������ ������. ���� ������ �
/// ����� id ��� - ���������� -1.
///
int Order::ContainsDeal(CDeal* changeDeal)
{
   for(int i = 0; i < deals.Total(); i++)
   {
      CDeal* deal = deals.At(i);
      if(changeDeal.GetId() == deal.GetId())
         return i;
   }
   return -1;
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
   if(IsHistory())
   {
      if(deals.Total() == 0)
         status = ORDER_NULL;
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
/// ��������� ��������� ������.
///
void Order::Refresh(void)
{
   RefreshStatus();
   RecalcValues();
   if(status != ORDER_NULL && GetId() == 0 && deals.Total() > 0)
   {
      CDeal* deal = deals.At(0);
      SetId(deal.OrderId());
   }
   //TODO: RefreshPriceAndVol();
   if(position != NULL)
      position.OrderChanged(GetPointer(this));
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
      LogWriter("Order ID #" + (string)deal.OrderId() + " in the deal #" + (string)deal.GetId() +
                " is not equal order id. Adding failed.", MESSAGE_TYPE_WARNING);
      return;
   }
   if(GetId() == 0)
      SetId(deal.OrderId());
   deal.LinqWithOrder(GetPointer(this));
   int index = ContainsDeal(deal);
   if(index != -1)
   {
      CDeal* mdeal = deals.At(index);
      mdeal.VolumeExecuted(deal.VolumeExecuted());
      delete mdeal;
   }
   else
      deals.Add(deal);
   Refresh();
}

///
/// ������� ������ �� ������ ������.
///
void Order::DeleteDealAt(int index)
{
   if(deals.Total() <= index)return;
   deals.Delete(index);
   Refresh();
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
   return deals.Total();
}

///
/// ������, ���� �������� �������� ���������� �� ������ �
/// � ������� ��������������� � ���� � ��������� ������.
///
bool Order::IsHistory()
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

///
/// �������� ����� ��� �������� ������� ������.
///
ulong Order::GetMagicForClose(void)
{
   return GetId();
}

///
/// ���������� ����������� � ������.
///
string Order::Comment()
{
   return comment;
}

///
/// ���������� ������ ����� ��������� ������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long Order::TimeSetup()
{
   return timeSetup.Tiks();
}

///
/// ���������� ������ ����� ���������� ������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long Order::TimeExecuted()
{
   return timeExecuted.Tiks();
}

///
/// ���������� ���� ���� ���������� ������.
///
double Order::PriceSetup(void)
{
   return priceSetup;
}

///
/// ���������� ���������������� ���� ���������� ������.
///
double Order::PriceExecuted(void)
{
   return priceExecuted;
}

///
/// ���������� �������������� ����� ��� ���������� ������.
///
double Order::VolumeSetup(void)
{
   return volumeSetup;
}

///
/// ���������� ����������� �����.
///
double Order::VolumeExecuted(void)
{
   return volumeExecuted;
}

///
/// ���������� ������������� �����.
///
double Order::VolumeReject(void)
{
   return volumeSetup - volumeExecuted;
}



///
/// ������������ ���������������� ���� �����.
///
void Order::RecalcValues(void)
{
   priceExecuted = 0.0;
   volumeExecuted = 0.0;
   timeExecuted.Tiks(0);
   //calc avrg price, executed volume and time.
   for(int i = 0; i < deals.Total(); i++)
   {
      CDeal* deal = deals.At(i);
      priceExecuted += deal.PriceExecuted()*deal.VolumeExecuted();
      volumeExecuted += deal.VolumeExecuted();
      if(timeExecuted.Tiks() < deal.TimeExecuted())
         timeExecuted.Tiks(deal.TimeExecuted());
   }
   if(volumeExecuted > 0)
      priceExecuted /= volumeExecuted;
   //calc setup price and comment.
   if(IsPending())
   {
      OrderSelect(GetId());
      priceSetup = OrderGetDouble(ORDER_PRICE_OPEN);
      volumeSetup = OrderGetDouble(ORDER_VOLUME_INITIAL);
      timeSetup = OrderGetInteger(ORDER_TIME_SETUP_MSC);
      comment = OrderGetString(ORDER_COMMENT);
   }
   else if(IsHistory())
   {
      priceSetup = HistoryOrderGetDouble(GetId(), ORDER_PRICE_OPEN);
      volumeSetup = HistoryOrderGetDouble(GetId(), ORDER_VOLUME_INITIAL);
      timeSetup = HistoryOrderGetInteger(ORDER_TIME_SETUP_MSC);
      comment = HistoryOrderGetString(GetId(), ORDER_COMMENT);
   }
}