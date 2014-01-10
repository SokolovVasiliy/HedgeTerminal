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
      void Init(ulong dealId);
      ulong OrderId();
      DEAL_STATUS Status();
   private:
      void RefreshStatus();
      virtual bool MTContainsMe();
      void ClearMe();
      ulong orderId;
      DEAL_STATUS status;
      ENUM_DEAL_TYPE type;
};

CDeal::CDeal(void) : Transaction(TRANS_DEAL)
{
   ;
}

CDeal::CDeal(ulong dealId) : Transaction(TRANS_DEAL)
{
   Init(dealId);
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
   RefreshStatus();
}

void CDeal::RefreshStatus()
{
   if(!MTContainsMe())
   {
      ClearMe();
      return;
   }
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
/// ���������� ������ � ������� ��������� DEAL_NULL,
/// ��� ���������� ��������������� � 0.
///
void CDeal::ClearMe()
{
   
   status = DEAL_NULL;
   direction = DIRECTION_NDEF;
   SetId(0);
   orderId = 0;
}
