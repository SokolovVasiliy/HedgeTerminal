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
      ~CDeal();
      string Comment();
      void Init(ulong dealId);
      ulong OrderId();
      DEAL_STATUS Status();
      virtual double ExecutedVolume();
      CTime* CopyExecutedTime();
      void ExecutedVolume(double vol);
      ENUM_DEAL_TYPE DealType();
      CDeal* Clone();
      void LinqWithOrder(Order* parOrder);
      void Refresh();
      Order* Order(){return order;}
      
   private:
      
      ///
      /// ���� ������ ����������� � ������, �������� ������ �� ����.
      ///
      Order* order;
      ///
      /// ����� ���������� ������.
      ///
      CTime* executedTime;
      void RefreshStatus1();
      virtual bool MTContainsMe();
      ulong orderId;
      double volume;
      DEAL_STATUS status;
      ENUM_DEAL_TYPE type;
      ///
      /// ������������ � ������.
      ///
      string comment;
};

CDeal::CDeal(void) : Transaction(TRANS_DEAL)
{
   executedTime = new CTime();
}

CDeal::CDeal(ulong dealId) : Transaction(TRANS_DEAL)
{
   executedTime = new CTime();
   Init(dealId);
}

///
/// ������� ����� ��������� ������ - ������ ����� deal.
///
CDeal::CDeal(CDeal* deal) : Transaction(TRANS_DEAL)
{
   executedTime = deal.CopyExecutedTime();
   status = deal.Status();
   volume = deal.ExecutedVolume();
   type = deal.DealType();
   SetId(deal.GetId());
   orderId = deal.OrderId();
   order = deal.Order();
}

CDeal::~CDeal(void)
{
   delete executedTime;
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
   volume = HistoryDealGetDouble(dealId, DEAL_VOLUME);
   executedTime.Tiks(HistoryDealGetInteger(dealId, DEAL_TIME_MSC));
   if(!MTContainsMe())
      return;
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
bool CDeal::MTContainsMe()
{
   if(HistoryDealGetInteger(GetId(), DEAL_TIME) > 0)
      return true;
   return false;
}

///
/// ����������� ����� ������.
///
double CDeal::ExecutedVolume()
{
   return volume;
}

///
/// ������������� ����� ������.
///
void CDeal::ExecutedVolume(double vol)
{
   if(vol < 0.0)return;
   volume = vol;
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
/// ����������� � ������.
///
string CDeal::Comment(void)
{
   if(comment == NULL || comment == "")
      comment = HistoryDealGetString(GetId(), DEAL_COMMENT);
   return comment;
}

CTime* CDeal::CopyExecutedTime()
{
   return new CTime(executedTime.Tiks());
}