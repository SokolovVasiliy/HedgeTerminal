#include "Transaction.mqh"

///
/// Тип сделки.
///
enum DEAL_STATUS
{
    ///
    /// Сделка отсутствует в теминале или неинициализирована.
    ///
    DEAL_NULL,
    ///
    /// Сделка является брокерской операцией на счете.
    ///
    DEAL_BROKERAGE,
    ///
    /// Сделка является торговой операцией на счете.
    ///
    DEAL_TRADE
};

///
/// Сделка (трейд).
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
/// Возвращает идентификатор ордера, на основании которого произведена торговая сделка.
/// Если тип сделки DEAL_BROKERAGE или информация об ордере недоступна возвращается 0.
///
ulong CDeal::OrderId()
{
   return orderId;
}

///
/// Возвращает тип сделки.
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
/// Истина, если терминал содержит информацию о сделке с
/// с текущим идентификатором и ложь в противном случае. Перед вызовом
/// функции в терминал должна быть загружена история сделок и ордеров.
///
bool CDeal::MTContainsMe()
{
   if(HistoryDealGetInteger(GetId(), DEAL_TIME) > 0)
      return true;
   return false;
}

///
/// Сбрасывает сделку в нулевое состояние DEAL_NULL,
/// все переменные устанавливаются в 0.
///
void CDeal::ClearMe()
{
   
   status = DEAL_NULL;
   direction = DIRECTION_NDEF;
   SetId(0);
   orderId = 0;
}
