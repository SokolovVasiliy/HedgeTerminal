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
      CDeal(CDeal* deal);
      void Init(ulong dealId);
      ulong OrderId();
      DEAL_STATUS Status();
      virtual double ExecutedVolume();
      void ExecutedVolume(double vol);
      ENUM_DEAL_TYPE DealType();
      CDeal* Clone();
      void LinqWithOrder(Order* parOrder);
      void Refresh();
      Order* Order(){return order;}
   private:
      ///
      /// Если сделка принадлежит к ордеру, содержит ссылку на него.
      ///
      Order* order;
      void RefreshStatus1();
      virtual bool MTContainsMe();
      void ClearMe1();
      ulong orderId;
      double volume;
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
/// Создает новый экзмепляр сделки - полную копию deal.
///
CDeal::CDeal(CDeal* deal) : Transaction(TRANS_DEAL)
{
   status = deal.Status();
   volume = deal.ExecutedVolume();
   type = deal.DealType();
   SetId(deal.GetId());
   orderId = deal.OrderId();
   order = deal.Order();
}

///
/// Возвращает полную копию текущей сделки.
///
CDeal* CDeal::Clone(void)
{
   return new CDeal(GetPointer(this));
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
   volume = HistoryDealGetDouble(dealId, DEAL_VOLUME);
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
/// Связывает текущую сделку с ордером, которому она принадлежит.
/// Идентификатор ордера выставившего сделку и id ордера должен совпадать.
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
/// Совершенный объем сделки.
///
double CDeal::ExecutedVolume()
{
   return volume;
}

///
/// Устанавливает объем сделки.
///
void CDeal::ExecutedVolume(double vol)
{
   if(vol < 0.0)return;
   volume = vol;
   Refresh();
}

///
/// Возвращает тип сделки ENUM_DEAL_TYPE.
///
ENUM_DEAL_TYPE CDeal::DealType(void)
{
   return type;
}