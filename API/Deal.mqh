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
      /// Содержит комиссию в пересчете на 1 базовый контракт.
      ///
      double commission;
   private:
      ///
      /// Истина, если свойства текущего ордера доступны в истории терминала,
      /// ложь в противном случае.
      ///
      bool IsSelected(ulong id);
      
      virtual bool IsHistory();
      ///
      /// Если сделка принадлежит к ордеру, содержит ссылку на него.
      ///
      Order* order;
      ///
      /// Время совершения трейда.
      ///
      CTime timeExecuted;
      ///
      /// Содержит идентификатор ордера, на основании которого совершена сделка.
      ///
      ulong orderId;
      ///
      /// Объем совершенной сделки.
      ///
      double volumeExecuted;
      ///
      /// Статус сделки.
      ///
      DEAL_STATUS status;
      ///
      /// Тип сделки.
      ///
      ENUM_DEAL_TYPE type;
      ///
      /// Комментарий к сделке.
      ///
      string comment;
      ///
      /// Содержит цену исполнения сделки.
      ///
      double priceExecuted;
      ///
      /// Идентификатор эксперта, которому принадлежит текущая сделка.
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
/// Создает новый экзмепляр сделки - полную копию deal.
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
   //Копируются все значения кроме ссылки на ордер.
   //order = deal.Order();
}

///
/// Возвращает полную копию текущей сделки.
///
Deal* Deal::Clone(void)
{
   return new Deal(GetPointer(this));
}
///
/// Возвращает идентификатор ордера, на основании которого произведена торговая сделка.
/// Если тип сделки DEAL_BROKERAGE или информация об ордере недоступна возвращается 0.
///
ulong Deal::OrderId()
{
   return orderId;
}

///
/// Возвращает тип сделки.
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
   //Рассчитываем комиссию на один базовый контракт.
   commission = HistoryDealGetDouble(dealId, DEAL_COMMISSION);
   if(Math::DoubleEquals(volumeExecuted, 0.0))
      commission = 0.0;
   else
      commission = commission/volumeExecuted;
   ulong msc = HistoryDealGetInteger(dealId, DEAL_TIME_MSC);
   //Из-за гребанного глюка МТ5 милисекунды недоступны из под теста.
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
/// Связывает текущую сделку с ордером, которому она принадлежит.
/// Идентификатор ордера выставившего сделку и id ордера должен совпадать.
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
/// Истина, если терминал содержит информацию о сделке с
/// с текущим идентификатором и ложь в противном случае. Перед вызовом
/// функции в терминал должна быть загружена история сделок и ордеров.
///
bool Deal::IsHistory()
{
   if(HistoryDealGetInteger(GetId(), DEAL_TIME) > 0)
      return true;
   return false;
}

///
/// Совершенный объем сделки.
///
double Deal::VolumeExecuted()
{
   return volumeExecuted;
}

///
/// Устанавливает объем сделки.
///
void Deal::VolumeExecuted(double vol)
{
   if(vol < 0.0)return;
   volumeExecuted = vol;
   Refresh();
}

///
/// Возвращает тип сделки ENUM_DEAL_TYPE.
///
ENUM_DEAL_TYPE Deal::DealType(void)
{
   return type;
}

///
/// Возвращает комментарий к сделке.
///
string Deal::Comment(void)
{
   if(comment == NULL || comment == "")
      comment = HistoryDealGetString(GetId(), DEAL_COMMENT);
   return comment;
}

///
/// Возвращает точное время исполнения сделки, в виде
/// количества тиков прошедших с 01.01.1970 года.
///
long Deal::TimeExecuted(void)
{
   return timeExecuted.Tiks();
}

///
/// Возвращает цену исполнения сделки.
///
double Deal::EntryExecutedPrice(void)
{
   return priceExecuted;
}

///
/// Направление сделки.
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
/// Возвращает комиссию за совершенную сделку.
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