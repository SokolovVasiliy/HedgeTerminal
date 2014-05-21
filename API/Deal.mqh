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
class Deal : public Transaction
{
   public:
      Deal(); 
      Deal(ulong dealId);
      Deal(Deal* deal);
      string Comment();
      void Init(ulong dealId);
      ulong OrderId();
      DEAL_STATUS Status();
      virtual double VolumeExecuted();
      void VolumeExecuted(double vol);
      long TimeExecuted();
      double EntryExecutedPrice(void);
      ENUM_DEAL_TYPE DealType();
      Deal* Clone();
      void LinqWithOrder(Order* parOrder);
      void Refresh();
      Order* Order(){return order;}
      virtual ulong Magic(){return magic;}
      virtual ENUM_DIRECTION_TYPE Direction(void);
      virtual double Commission();
   protected:
      ///
      /// �������� �������� � ��������� �� 1 ������� ��������.
      ///
      double commission;
   private:
      ///
      /// ������, ���� �������� �������� ������ �������� � ������� ���������,
      /// ���� � ��������� ������.
      ///
      bool IsSelected(ulong id);
      
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
      ///
      /// ������������� ��������, �������� ����������� ������� ������.
      ///
      ulong magic;
      
};

Deal::Deal(void) : Transaction(TRANS_DEAL)
{
}

Deal::Deal(ulong dealId) : Transaction(TRANS_DEAL)
{
   Init(dealId);
}

///
/// ������� ����� ��������� ������ - ������ ����� deal.
///
Deal::Deal(Deal* deal) : Transaction(TRANS_DEAL)
{
   SetId(deal.GetId());
   orderId = deal.OrderId();
   status = deal.Status();
   symbol = deal.Symbol();
   timeExecuted.Tiks(deal.TimeExecuted());
   volumeExecuted = deal.VolumeExecuted();
   priceExecuted = deal.EntryExecutedPrice();
   type = deal.DealType();
   magic = deal.Magic();
   commission = deal.commission;
   //���������� ��� �������� ����� ������ �� �����.
   //order = deal.Order();
}

///
/// ���������� ������ ����� ������� ������.
///
Deal* Deal::Clone(void)
{
   return new Deal(GetPointer(this));
}
///
/// ���������� ������������� ������, �� ��������� �������� ����������� �������� ������.
/// ���� ��� ������ DEAL_BROKERAGE ��� ���������� �� ������ ���������� ������������ 0.
///
ulong Deal::OrderId()
{
   return orderId;
}

///
/// ���������� ��� ������.
///
DEAL_STATUS Deal::Status()
{
   return status;
}

void Deal::Init(ulong dealId)
{
   bool isSelected = IsSelected(dealId);
   if(!isSelected)
      HistoryOrderSelect(dealId);
   SetId(dealId);
   if(!IsHistory())
      return;
   symbol = HistoryDealGetString(dealId, DEAL_SYMBOL);
   volumeExecuted = HistoryDealGetDouble(dealId, DEAL_VOLUME);
   //������������ �������� �� ���� ������� ��������.
   commission = HistoryDealGetDouble(dealId, DEAL_COMMISSION);
   if(Math::DoubleEquals(volumeExecuted, 0.0))
      commission = 0.0;
   else
      commission = commission/volumeExecuted;
   ulong msc = HistoryDealGetInteger(dealId, DEAL_TIME_MSC);
   //��-�� ���������� ����� ��5 ����������� ���������� �� ��� �����.
   if(msc != 0)
      timeExecuted.Tiks(msc);
   else
      timeExecuted.Tiks(HistoryDealGetInteger(dealId, DEAL_TIME)*1000);
   priceExecuted = NormalizePrice(HistoryDealGetDouble(dealId, DEAL_PRICE));
   type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dealId, DEAL_TYPE);
   comment = HistoryDealGetString(dealId, DEAL_COMMENT);
   magic = HistoryDealGetInteger(dealId, DEAL_MAGIC);
   if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
   {
      status = DEAL_TRADE;
      orderId = HistoryDealGetInteger(GetId(), DEAL_ORDER);
   }
   else
      status = DEAL_BROKERAGE;
   if(!isSelected)
      HistorySelect(0, TimeCurrent());
}

///
///
///
void Deal::Refresh(void)
{
   if(Math::DoubleEquals(volumeExecuted, 0.0))
      status = DEAL_NULL;
   if(order != NULL)
      order.DealChanged(GetPointer(this));
}
///
/// ��������� ������� ������ � �������, �������� ��� �����������.
/// ������������� ������ ������������ ������ � id ������ ������ ���������.
///
void Deal::LinqWithOrder(Order* parOrder)
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
bool Deal::IsHistory()
{
   if(HistoryDealGetInteger(GetId(), DEAL_TIME) > 0)
      return true;
   return false;
}

///
/// ����������� ����� ������.
///
double Deal::VolumeExecuted()
{
   return volumeExecuted;
}

///
/// ������������� ����� ������.
///
void Deal::VolumeExecuted(double vol)
{
   if(vol < 0.0)return;
   volumeExecuted = vol;
   Refresh();
}

///
/// ���������� ��� ������ ENUM_DEAL_TYPE.
///
ENUM_DEAL_TYPE Deal::DealType(void)
{
   return type;
}

///
/// ���������� ����������� � ������.
///
string Deal::Comment(void)
{
   if(comment == NULL || comment == "")
      comment = HistoryDealGetString(GetId(), DEAL_COMMENT);
   return comment;
}

///
/// ���������� ������ ����� ���������� ������, � ����
/// ���������� ����� ��������� � 01.01.1970 ����.
///
long Deal::TimeExecuted(void)
{
   return timeExecuted.Tiks();
}

///
/// ���������� ���� ���������� ������.
///
double Deal::EntryExecutedPrice(void)
{
   return priceExecuted;
}

///
/// ����������� ������.
///
ENUM_DIRECTION_TYPE Deal::Direction()
{
   if(type == DEAL_TYPE_BUY)
      return DIRECTION_LONG;
   if(type == DEAL_TYPE_SELL)
      return DIRECTION_SHORT;
   else
      return DIRECTION_NDEF;
}

///
/// ���������� �������� �� ����������� ������.
///
double Deal::Commission()
{
   return commission*volumeExecuted;
}


bool Deal::IsSelected(ulong id)
{
   long time = HistoryDealGetInteger(id, DEAL_TIME);
   if(time == 0)return false;
   return true;
}