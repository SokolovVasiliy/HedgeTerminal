#include "Transaction.mqh"

///
/// ��� ������.
///
enum DEAL_STATUS
{
    ///
    /// ������ ����������� � �������� ��� ������������������.
    ///
    DEAL_NULL,
    ///
    /// ������ �������� ���������� ��������� �� �����.
    ///
    DEAL_BROKERAGE,
    ///
    /// ������ �������� �������� ��������� �� �����.
    ///
    DEAL_TRADE
};

///
/// ������ (�����).
///
class CDeal : public Transaction
{
   public:
      CDeal(); 
      CDeal(ulong dealId);
      CDeal(CDeal* deal);
      string Comment();
      void Init(ulong dealId);
      ulong OrderId();
      DEAL_STATUS Status();
      virtual double VolumeExecuted();
      void VolumeExecuted(double vol);
      long TimeExecuted();
      double PriceExecuted();
      ENUM_DEAL_TYPE DealType();
      CDeal* Clone();
      void LinqWithOrder(Order* parOrder);
      void Refresh();
      Order* Order(){return order;}
      
   private:
      virtual bool IsHistory();
      ///
      /// ���� ������ ����������� � ������, �������� ������ �� ����.
      ///
      Order* order;
      ///
      /// ����� ���������� ������.
      ///
      CTime timeExecuted;
      ///
      /// �������� ������������� ������, �� ��������� �������� ��������� ������.
      ///
      ulong orderId;
      ///
      /// ����� ����������� ������.
      ///
      double volumeExecuted;
      ///
      /// ������ ������.
      ///
      DEAL_STATUS status;
      ///
      /// ��� ������.
      ///
      ENUM_DEAL_TYPE type;
      ///
      /// ����������� � ������.
      ///
      string comment;
      ///
      /// �������� ���� ���������� ������.
      ///
      double priceExecuted;
};

CDeal::CDeal(void) : Transaction(TRANS_DEAL)
{
}

CDeal::CDeal(ulong dealId) : Transaction(TRANS_DEAL)
{
   Init(dealId);
}

///
/// ������� ����� ��������� ������ - ������ ����� deal.
///
CDeal::CDeal(CDeal* deal) : Transaction(TRANS_DEAL)
{
   SetId(deal.GetId());
   orderId = deal.OrderId();
   status = deal.Status();
   timeExecuted.Tiks(deal.TimeExecuted());
   volumeExecuted = deal.VolumeExecuted();
   priceExecuted = deal.PriceExecuted();
   type = deal.DealType();
   order = deal.Order();
}


///
/// ���������� ������ ����� ������� ������.
///
CDeal* CDeal::Clone(void)
{
   return new CDeal(GetPointer(this));
}
///
/// ���������� ������������� ������, �� ��������� �������� ����������� �������� ������.
/// ���� ��� ������ DEAL_BROKERAGE ��� ���������� �� ������ ���������� ������������ 0.
///
ulong CDeal::OrderId()
{
   return orderId;
}

///
/// ���������� ��� ������.
///
DEAL_STATUS CDeal::Status()
{
   return status;
}

void CDeal::Init(ulong dealId)
{
   SetId(dealId);
   if(!IsHistory())
      return;
   volumeExecuted = HistoryDealGetDouble(dealId, DEAL_VOLUME);
   timeExecuted.Tiks(HistoryDealGetInteger(dealId, DEAL_TIME_MSC));
   priceExecuted = HistoryDealGetDouble(dealId, DEAL_PRICE);
   type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(GetId(), DEAL_TYPE);
   if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
   {
      status = DEAL_TRADE;
      orderId = HistoryDealGetInteger(GetId(), DEAL_ORDER);
      if(type == DEAL_TYPE_BUY)
         direction = DIRECTION_LONG;
      else
         direction = DIRECTION_SHORT;
   }
   else
   {
      status = DEAL_BROKERAGE;
      direction = DIRECTION_NDEF;
   }
}

///
///
///
void CDeal::Refresh(void)
{
   if(order != NULL)
      order.DealChanged(GetPointer(this));
}
///
/// ��������� ������� ������ � �������, �������� ��� �����������.
/// ������������� ������ ������������ ������ � id ������ ������ ���������.
///
void CDeal::LinqWithOrder(Order* parOrder)
{
   if(CheckPointer(parOrder) == POINTER_INVALID)
      return;
   if(parOrder.GetId() > 0 && orderId != parOrder.GetId())
      return;
   order = parOrder;
}

///
/// ������, ���� �������� �������� ���������� � ������ �
/// � ������� ��������������� � ���� � ��������� ������. ����� �������
/// ������� � �������� ������ ���� ��������� ������� ������ � �������.
///
bool CDeal::IsHistory()
{
   if(HistoryDealGetInteger(GetId(), DEAL_TIME) > 0)
      return true;
   return false;
}

///
/// ����������� ����� ������.
///
double CDeal::VolumeExecuted()
{
   return volumeExecuted;
}

///
/// ������������� ����� ������.
///
void CDeal::VolumeExecuted(double vol)
{
   if(vol < 0.0)return;
   volumeExecuted = vol;
   Refresh();
}

///
/// ���������� ��� ������ ENUM_DEAL_TYPE.
///
ENUM_DEAL_TYPE CDeal::DealType(void)
{
   return type;
}

///
/// ���������� ����������� � ������.
///
string CDeal::Comment(void)
{
   if(comment == NULL || comment == "")
      comment = HistoryDealGetString(GetId(), DEAL_COMMENT);
   return comment;
}

///
/// ���������� ������ ����� ���������� ������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long CDeal::TimeExecuted(void)
{
   return timeExecuted.Tiks();
}

///
/// ���������� ���� ���������� ������.
///
double CDeal::PriceExecuted(void)
{
   return priceExecuted;
}