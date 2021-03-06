#include "Transaction.mqh"
#include "..\Prototypes.mqh"

///
/// Òèï ñäåëêè.
///
enum DEAL_STATUS
{
    ///
    /// Ñäåëêà îòñóòñòâóåò â òåðìèíàëå èëè íåèíèöèàëèçèðîâàíà.
    ///
    DEAL_NULL,
    ///
    /// Ñäåëêà ÿâëÿåòñÿ áðîêåðñêîé îïåðàöèåé íà ñ÷åòå.
    ///
    DEAL_BROKERAGE,
    ///
    /// Ñäåëêà ÿâëÿåòñÿ òîðãîâîé îïåðàöèåé íà ñ÷åòå.
    ///
    DEAL_TRADE,
    ///
    /// Ñäåëêà ÿâëÿåòñÿ êîíâåðñèîííîé îïåðàöèåé ïî íà÷èñëåíèþ ñâîïà
    ///
    DEAL_BROKERAGE_SWAP
};

///
/// Ñäåëêà (òðåéä).
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
      double Swap();
   protected:
      ///
      /// Ñîäåðæèò êîìèññèþ â ïåðåñ÷åòå íà 1 áàçîâûé êîíòðàêò.
      ///
      double commission;
   private:
      ///
      /// Îïðåäåëÿåò ñòàòóñ.
      ///
      void DetectStatus();
      bool IsRolloverDeal();
      ///
      /// Èñòèíà, åñëè ñâîéñòâà òåêóùåãî îðäåðà äîñòóïíû â èñòîðèè òåðìèíàëà,
      /// ëîæü â ïðîòèâíîì ñëó÷àå.
      ///
      bool IsSelected(ulong id);
      
      virtual bool IsHistory();
      ///
      /// Åñëè ñäåëêà ïðèíàäëåæèò ê îðäåðó, ñîäåðæèò ññûëêó íà íåãî.
      ///
      Order* order;
      ///
      /// Âðåìÿ ñîâåðøåíèÿ òðåéäà.
      ///
      CTime timeExecuted;
      ///
      /// Ñîäåðæèò èäåíòèôèêàòîð îðäåðà, íà îñíîâàíèè êîòîðîãî ñîâåðøåíà ñäåëêà.
      ///
      ulong orderId;
      ///
      /// Îáúåì ñîâåðøåííîé ñäåëêè.
      ///
      double volumeExecuted;
      ///
      /// Ñòàòóñ ñäåëêè.
      ///
      DEAL_STATUS status;
      ///
      /// Òèï ñäåëêè.
      ///
      ENUM_DEAL_TYPE type;
      ///
      /// Êîììåíòàðèé ê ñäåëêå.
      ///
      string comment;
      ///
      /// Ñîäåðæèò öåíó èñïîëíåíèÿ ñäåëêè.
      ///
      double priceExecuted;
      ///
      /// Èäåíòèôèêàòîð ýêñïåðòà, êîòîðîìó ïðèíàäëåæèò òåêóùàÿ ñäåëêà.
      ///
      ulong magic;
      ///
      /// Ñîäåðæèò íàêîïëåííûé ñâîï.
      ///
      double swap;
      
};

Deal::Deal(void) : Transaction(TRANS_DEAL)
{
}

Deal::Deal(ulong dealId) : Transaction(TRANS_DEAL)
{
   Init(dealId);
}

///
/// Ñîçäàåò íîâûé ýêçìåïëÿð ñäåëêè - ïîëíóþ êîïèþ deal.
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
   swap = deal.Swap();
   //Êîïèðóþòñÿ âñå çíà÷åíèÿ êðîìå ññûëêè íà îðäåð.
   //order = deal.Order();
}

///
/// Âîçâðàùàåò ïîëíóþ êîïèþ òåêóùåé ñäåëêè.
///
Deal* Deal::Clone(void)
{
   return new Deal(GetPointer(this));
}
///
/// Âîçâðàùàåò èäåíòèôèêàòîð îðäåðà, íà îñíîâàíèè êîòîðîãî ïðîèçâåäåíà òîðãîâàÿ ñäåëêà.
/// Åñëè òèï ñäåëêè DEAL_BROKERAGE èëè èíôîðìàöèÿ îá îðäåðå íåäîñòóïíà âîçâðàùàåòñÿ 0.
///
ulong Deal::OrderId()
{
   return orderId;
}

///
/// Âîçâðàùàåò òèï ñäåëêè.
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
   //Ðàññ÷èòûâàåì êîìèññèþ íà îäèí áàçîâûé êîíòðàêò.
   commission = HistoryDealGetDouble(dealId, DEAL_COMMISSION);
   swap += HistoryDealGetDouble(dealId, DEAL_SWAP);
   if(Math::DoubleEquals(volumeExecuted, 0.0))
      commission = 0.0;
   else
      commission = commission/volumeExecuted;
   ulong msc = HistoryDealGetInteger(dealId, DEAL_TIME_MSC);
   //Èç-çà ãðåáàííîãî ãëþêà ÌÒ5 ìèëèñåêóíäû íåäîñòóïíû èç ïîä òåñòà.
   if(msc != 0)
      timeExecuted.Tiks(msc);
   else
      timeExecuted.Tiks(HistoryDealGetInteger(dealId, DEAL_TIME)*1000);
   priceExecuted = NormalizePrice(HistoryDealGetDouble(dealId, DEAL_PRICE));
   type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dealId, DEAL_TYPE);
   comment = HistoryDealGetString(dealId, DEAL_COMMENT);
   magic = HistoryDealGetInteger(dealId, DEAL_MAGIC);
   DetectStatus();
   if(!isSelected)
      HistorySelect(0, TimeCurrent());
}

double Deal::Swap(void)
{
   return swap;
}
///
/// Îïðåäåëÿåò ñòàòóñ (DEAL_STATUS) ñäåëêè è
/// èäåíòèôèêàòîð åå èíèöèàëèçèðóþùåãî îðäåðà, åñëè
/// ýòî âîçìîæíî.
///
void Deal::DetectStatus(void)
{
   orderId = HistoryDealGetInteger(GetId(), DEAL_ORDER);
   if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
   {
      if(orderId > 0)status = DEAL_TRADE;
      else if(IsRolloverDeal())
         status = DEAL_BROKERAGE_SWAP;
   }
   else
      status = DEAL_BROKERAGE;
}
bool Deal::IsRolloverDeal(void)
{
   string lower_comment = comment;
   StringToLower(lower_comment);
   int index = StringFind(lower_comment, "rollover");
   int index2 = StringFind(lower_comment, "variation margin");
   if(index == -1 && index2 == -1)
      return false;
   return true;
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
/// Ñâÿçûâàåò òåêóùóþ ñäåëêó ñ îðäåðîì, êîòîðîìó îíà ïðèíàäëåæèò.
/// Èäåíòèôèêàòîð îðäåðà âûñòàâèâøåãî ñäåëêó è id îðäåðà äîëæåí ñîâïàäàòü.
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
/// Èñòèíà, åñëè òåðìèíàë ñîäåðæèò èíôîðìàöèþ î ñäåëêå ñ
/// ñ òåêóùèì èäåíòèôèêàòîðîì è ëîæü â ïðîòèâíîì ñëó÷àå. Ïåðåä âûçîâîì
/// ôóíêöèè â òåðìèíàë äîëæíà áûòü çàãðóæåíà èñòîðèÿ ñäåëîê è îðäåðîâ.
///
bool Deal::IsHistory()
{
   if(HistoryDealGetInteger(GetId(), DEAL_TIME) > 0)
      return true;
   return false;
}

///
/// Ñîâåðøåííûé îáúåì ñäåëêè.
///
double Deal::VolumeExecuted()
{
   return volumeExecuted;
}

///
/// Óñòàíàâëèâàåò îáúåì ñäåëêè.
///
void Deal::VolumeExecuted(double vol)
{
   if(vol < 0.0)return;
   volumeExecuted = vol;
   Refresh();
}

///
/// Âîçâðàùàåò òèï ñäåëêè ENUM_DEAL_TYPE.
///
ENUM_DEAL_TYPE Deal::DealType(void)
{
   return type;
}

///
/// Âîçâðàùàåò êîììåíòàðèé ê ñäåëêå.
///
string Deal::Comment(void)
{
   if(comment == NULL || comment == "")
      comment = HistoryDealGetString(GetId(), DEAL_COMMENT);
   return comment;
}

///
/// Âîçâðàùàåò òî÷íîå âðåìÿ èñïîëíåíèÿ ñäåëêè, â âèäå
/// êîëè÷åñòâà òèêîâ ïðîøåäøèõ ñ 01.01.1970 ãîäà.
///
long Deal::TimeExecuted(void)
{
   return timeExecuted.Tiks();
}

///
/// Âîçâðàùàåò öåíó èñïîëíåíèÿ ñäåëêè.
///
double Deal::EntryExecutedPrice(void)
{
   return priceExecuted;
}

///
/// Íàïðàâëåíèå ñäåëêè.
///
ENUM_DIRECTION_TYPE Deal::Direction()
{
   if(type == DEAL_TYPE_BUY)
      return DIRECTION_LONG;
   if(type == DEAL_TYPE_SELL)
      return DIRECTION_SHORT;
   else
      return DIRECTION_UNDEFINED;
}

///
/// Âîçâðàùàåò êîìèññèþ çà ñîâåðøåííóþ ñäåëêó.
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