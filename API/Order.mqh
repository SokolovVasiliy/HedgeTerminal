#include "Transaction.mqh"
#include "..\Log.mqh"
#include "..\Math\Math.mqh"
#include "..\Math\Crypto.mqh"
//#include "H.mqh"
//#include "..\Grid.mqh"
///
/// ��� ������������� �������
///
enum ENUM_MAGIC_TYPE
{
   ///
   /// ������� �������� �� �����.
   ///
   MAGIC_TYPE_MARKET,
   ///
   /// ����� �������� Stop-Loss ������� �������.
   ///
   MAGIC_TYPE_SL,
   ///
   /// ����� �������� Take-Profit ������� �������.
   ///
   MAGIC_TYPE_TP
};

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
      Order(TradeRequest& request);
      Order(Deal* deal);
      Order(Order* order);
      ~Order();
      
      Order* AnigilateOrder(Order* order);
      void AddDeal(Deal* deal);
      
      string Comment();
      long TimeSetup();
      
      ///   ��������� �������
      void TimeSetupTemp(long tiks){timeSetup.Tiks(tiks);}
      void SetIdTemp(ulong id){SetId(id);}
      ///------------------
      
      long TimeExecuted();
      long TimeCanceled();
      
      Order* Clone();
      int ContainsDeal(Deal* deal);
      void CompressDeals();
      void DeleteDealAt(int index);
      Deal* DealAt(int index);
      int DealsTotal();
      void DealChanged(Deal* deal);
      
      double PriceSetup();
      
      double EntryExecutedPrice(void);
      
      ulong GetMagic(ENUM_MAGIC_TYPE type);
      
      void Init(ulong orderId);
      bool IsPending(void);
      bool IsCanceled(void);
      
      void LinkWithPosition(Position* pos); 
      
      ulong Magic(){return magic;}
      
      ulong PositionId();
      Position* Position(){return position;}
      
      void Refresh();
      
      ENUM_ORDER_STATUS Status(void);
      
      virtual string TypeAsString(void);
      ENUM_ORDER_TYPE OrderType(void){return type;}
      ENUM_ORDER_STATE OrderState(void){return state;}
      virtual double VolumeExecuted(void);
      double VolumeSetup(void);
      double VolumeReject(void);
      
      virtual ENUM_DIRECTION_TYPE Direction(void);
      bool InProcessing();
      bool IsStopLoss();
      bool IsTakeProfit();
      bool IsExecuted();
      virtual double Commission(void);
      double Slippage();
      
   private:
      bool IsSelected(ulong id);
      ulong GetStopMask(void);
      ulong GetTakeMask(void);
      virtual bool IsHistory();
      ENUM_ORDER_STATUS RefreshStatus(void);
      void RecalcValues(void);
      void RecalcPosId(void);
      int FindActivePosById(ulong id);
      ///
      /// ���� ����� ����������� � �������, �������� ������ �� ���.
      ///
      Position* position;
      ///
      /// �������� ������������� ������������� �������, � ������� ����� ������������ ������� �����.
      ///
      ulong positionId;
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
      /// ����� ������ ��� ��������� ������.
      ///
      CTime timeCanceled;
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
      /// ��� ������.
      ///
      ENUM_ORDER_TYPE type;
      ///
      /// ��������� ������.
      ///
      ENUM_ORDER_STATE state;
      ///
      /// �������� ������ ������.
      ///
      CArrayObj deals;
      ///
      /// �������� ����������� � ������.
      ///
      string comment;
      ///
      /// ���������� ����� ��������, ������������ �����.
      ///
      ulong magic;
      ///
      /// ������, ���� �������� ��������� ������������� ������ ��� ��������.
      ///
      bool isCalc;
      /*���� � ������ ���� ����������� ������, ����� ����� ��������� ��������������.
      � ������ ����� � ��������������� ������ ������������ ����� (��� ������ ���������)
      ��� ������ ����������� ORDER_NULL*/
      ///
      /// ������, ���� ����� ���� �����-���� ����������� �����.
      ///
      bool activated;
      ///
      /// ��������/����������� �������.
      ///
      //Grid grid;
      //Crypto crypto;
      ///
      /// �������� ������� ������������� ���� ������.
      ///
      uchar bitType;
      ///
      /// ������������� ����-�������. 
      ///
      uchar id_tp(){return 0xA0;}
      ///
      /// ������������� ����-�����.
      ///
      uchar id_sl(){return 0xC0;}
      ///
      /// ������������� ��������� ������.
      ///
      uchar id_market(){return 0x80;}
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
Order::Order(Deal* deal) : Transaction(TRANS_ORDER)
{
   AddDeal(deal);
}

///
/// ������� �����, ��������� ���������� �� ��������� �������.
///
Order::Order(TradeRequest& request) : Transaction(TRANS_ORDER)
{
   SetId(request.order);
   magic = request.magic;
   volumeSetup = request.volume;
   priceSetup = request.price;
   symbol = request.symbol;
   type = request.type;
   comment = request.comment;
   //�������� �������� ������ �� �������� �������
   if(magic == 0)
   {
      bool t = OrderSelect(GetId());
      magic = OrderGetInteger(ORDER_MAGIC);
   }
   RecalcPosId();
}

///
/// ������� ������ ����� ������ order.
///
Order::Order(Order *order) : Transaction(TRANS_ORDER)
{
   SetId(order.GetId());
   for(int i = 0; i < order.DealsTotal(); i++)
   {
      Deal* deal = order.DealAt(i);
      Deal* ndeal = deal.Clone();
      ndeal.LinqWithOrder(GetPointer(this));
      AddDeal(ndeal);
   }
   comment = order.Comment();
   status = order.Status();
   priceSetup = order.PriceSetup();
   priceExecuted = order.EntryExecutedPrice();
   timeSetup = order.TimeSetup();
   timeExecuted = order.TimeExecuted();
   volumeSetup = order.VolumeSetup();
   volumeExecuted = order.VolumeExecuted();
   type = order.OrderType();
   state = order.OrderState();
   magic = order.Magic();
   if(priceExecuted > 0)
      isCalc = true;
   //���������� ��� ��������, ����� ������ �� �������.
   //position = order.Position();
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
   //delete 
   deals.Clear();
}

void Order::Init(ulong orderId)
{
   SetId(orderId);
   Refresh();
}


///
/// ���������� ������������� �������, � ������� ����� ������������ �����.
/// ���������� 0 - ���� ����� ����� ������������ ����� �������.
///
ulong Order::PositionId()
{
   return positionId;
}

///
/// ������������� ������ �� �������, � ������� ����������� ������ �����.
///
void Order::LinkWithPosition(Position* pos)
{
   if(CheckPointer(pos) == POINTER_INVALID)
      return;
   ulong posId = pos.GetId();
   ulong id = GetId();
   ulong myposId = PositionId();
   if(pos.GetId() == GetId() || PositionId() == pos.GetId())
      position = pos;
   else
   {
      LogWriter("Link order failed: this order has a different id with position id.", MESSAGE_TYPE_WARNING);
      int dbg = 5;
   }
}
///
/// ������, ������������� ����� ������, �������� ��� �������,
/// ����� �� ��������� ����������.
///
void Order::DealChanged(Deal* deal)
{
   int index = ContainsDeal(deal);
   if(index == -1)return;
   //Deal* deal = deals.At(index);
   //if(deal.VolumeExecuted() == 0)
   Refresh();
}

///
/// ������� � ������ ������, ������ ��� id �����
/// id ���������� ������ � � ������ ������ ����������
/// ������ ���� ������ � ������ ������. ���� ������ �
/// ����� id ��� - ���������� -1.
///
int Order::ContainsDeal(Deal* changeDeal)
{
   for(int i = 0; i < deals.Total(); i++)
   {
      Deal* deal = deals.At(i);
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
   //printf("Check status " + (string)GetId());
   if(IsPending())
   {
      status = ORDER_PENDING;
      //printf("   ...is pending");
      return status;
   }
   if(IsHistory())
   {
      //printf("   ...is history");
      if(TimeSetup() == 0)
      {
         status = ORDER_NULL;
         //printf("   ...time null");
      }
      else if(activated && DealsTotal() == 0)
      {
         status = ORDER_NULL;
         //printf("   ...deals null");
      }
      else
         status = ORDER_HISTORY;   
   }
   else
   {
      //printf("   ...else");
      status = ORDER_NULL;
   }
   return status;
}

///
/// ��������� ��������� ������.
///
void Order::Refresh(void)
{
   bool isSelected = true;
   if(MQLInfoInteger(MQL_TESTER))
   {
      isSelected = IsSelected(GetId());
      if(!isSelected)   
         HistoryOrderSelect(GetId());
   }
   RecalcValues();
   RefreshStatus();
   if(!isSelected)
      HistorySelect(0, TimeCurrent());
   if(status != ORDER_NULL && GetId() == 0 && deals.Total() > 0)
   {
      Deal* deal = deals.At(0);
      SetId(deal.OrderId());
   }
   if(position != NULL)
      position.OrderChanged(GetPointer(this));
}

///
/// ��������� ������ � ������ ������ ������.
///
void Order::AddDeal(Deal* deal)
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
   /* compress mode. ������ �-� CompressDeals();
   int index = ContainsDeal(deal);
   if(index != -1)
   {
      Deal* mdeal = deals.At(index);
      mdeal.VolumeExecuted(deal.VolumeExecuted());
      delete mdeal;
   }
   else*/
      deals.Add(deal);
   Refresh();
   if(!activated && VolumeExecuted() > 0)
      activated = true;
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
Deal* Order::DealAt(int index)
{
   Deal* deal = deals.At(index);
   return deal;
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
   /*bool res = HistoryOrderSelect(GetId());
   if(res)
   {
      LoadHistory();
      ulong setup = HistoryOrderGetInteger(GetId(), ORDER_TIME_SETUP_MSC);
      datetime tsetup = HistoryOrderGetInteger(GetId(), ORDER_TIME_SETUP);
      printf("Order find. Time setup: " + setup + " " + tsetup);
   }*/
   LoadHistory();
   ulong ticket = GetId();
   //printf("IsHistory(): find order " + (string)res);
   //printf("is hitory id=" + ticket + " total=" + HistoryOrdersTotal());
   if(HistoryOrderGetInteger(ticket, ORDER_TIME_SETUP) > 0)
      return true;
   return false;
}

bool Order::IsPending()
{
   return OrderSelect(GetId());
}

///
/// ������, ���� ����� �����-���� ����������. ���� � ��������� ������.
///
bool Order::IsExecuted()
{
   return activated || deals.Total();
}

///
/// ���������� ������, ���� ����� ��������� � ��������� �����������.
///
bool Order::InProcessing()
{
   if(!IsPending())return false;
   ENUM_ORDER_STATE m_state = (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE);
   switch(m_state)
   {
      case ORDER_STATE_STARTED:
      case ORDER_STATE_REQUEST_ADD:
      case ORDER_STATE_REQUEST_CANCEL:
      case ORDER_STATE_REQUEST_MODIFY:
         return true;
      default:
         return false;
   }
   return false;
}

///
/// �������� ����� ��� �������� ������� ������.
///
ulong Order::GetMagic(ENUM_MAGIC_TYPE magicType = MAGIC_TYPE_MARKET)
{
   ulong value = 0;
   switch(magicType)
   {
      case MAGIC_TYPE_MARKET:
         value = id_market();
         break;
      case MAGIC_TYPE_SL:
         value = id_sl();
         break;
      case MAGIC_TYPE_TP:
         value = id_tp();
         break;
   }
   value = value << 56;
   value = value | GetId();
   ulong m_magic = crypto.Crypt(value);
   crypto.SetBit(m_magic, 63, true);
   bool bit = crypto.GetBit(value, 62);
   crypto.SetBit(m_magic, 62, bit);
   return m_magic;
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
/// ���������� ����� ��������� ��� ������ ������. ��� ����������
/// � ��� ����������� ������� ���������� 0.
///
long Order::TimeCanceled(void)
{
   return timeCanceled.Tiks();
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
   if(status == ORDER_PENDING)
   {
      if(!OrderSelect(GetId()))
         return priceSetup;
      return OrderGetDouble(ORDER_PRICE_OPEN);
   }
   return priceSetup;
}


///
/// ���������� ���������������� ���� ���������� ������.
///
double Order::EntryExecutedPrice(void)
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
/// ���������� ��� ������ � ���� ������.
///
string Order::TypeAsString(void)
{
   string stype = EnumToString(type);
   stype = StringSubstr(stype, 11);
   StringReplace(stype, "_", " ");
   //StringReplace(type, "STOP LIMIT", "SL");
   //StringReplace(type, "STOP", "S");
   //StringReplace(type, "LIMIT", "L");
   return stype;
}

///
/// ����������� ������.
///
ENUM_DIRECTION_TYPE Order::Direction()
{
   if(type % 2 == 0)
      return DIRECTION_LONG;
   else
      return DIRECTION_SHORT;
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
      Deal* deal = deals.At(i);
      priceExecuted += deal.EntryExecutedPrice()*deal.VolumeExecuted();
      volumeExecuted += deal.VolumeExecuted();
      if(timeExecuted.Tiks() < deal.TimeExecuted())
         timeExecuted.Tiks(deal.TimeExecuted());
   }
   if(volumeExecuted > 0)
   {
      priceExecuted /= volumeExecuted;
      //priceExecuted = NormalizePrice(priceExecuted);
   }
   volumeExecuted = NormalizeDouble(volumeExecuted, 4);
   //calc setup price and comment.
   if(IsPending())
   {
      bool t = OrderSelect(GetId());
      symbol = OrderGetString(ORDER_SYMBOL);
      priceSetup = NormalizePrice(OrderGetDouble(ORDER_PRICE_OPEN));
      volumeSetup = OrderGetDouble(ORDER_VOLUME_INITIAL);
      long tSetup = OrderGetInteger(ORDER_TIME_SETUP_MSC);
      if(tSetup != 0)
         timeSetup = tSetup;
      else timeSetup = (long)OrderGetInteger(ORDER_TIME_SETUP)*1000; 
      comment = OrderGetString(ORDER_COMMENT);
      type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      state = (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE);
      magic = OrderGetInteger(ORDER_MAGIC);
      
   }
   else if((!isCalc && IsHistory()) || IsCanceled())
   {
      //printf("Calc history order");
      ulong id = GetId();
      symbol = HistoryOrderGetString(id, ORDER_SYMBOL);
      priceSetup = NormalizePrice(HistoryOrderGetDouble(id, ORDER_PRICE_OPEN));
      volumeSetup = HistoryOrderGetDouble(id, ORDER_VOLUME_INITIAL);
      if(Math::DoubleEquals(priceSetup, 0.0))
         priceSetup = priceExecuted;
      long tSetup = HistoryOrderGetInteger(id, ORDER_TIME_SETUP_MSC);
      if(tSetup != 0)
         timeSetup = tSetup;
      else timeSetup = (long)HistoryOrderGetInteger(id, ORDER_TIME_SETUP)*1000;
      comment = HistoryOrderGetString(id, ORDER_COMMENT);
      type = (ENUM_ORDER_TYPE)HistoryOrderGetInteger(id, ORDER_TYPE);
      state = (ENUM_ORDER_STATE)HistoryOrderGetInteger(id, ORDER_STATE);
      magic = HistoryOrderGetInteger(id, ORDER_MAGIC);
      isCalc = true;
      if(IsCanceled())
         timeCanceled.Tiks(HistoryOrderGetInteger(id, ORDER_TIME_DONE_MSC));
   }
   RecalcPosId();
}

///
/// ������������ ������������� �������, ������� �����
/// ������������ ������� �����.
///
void Order::RecalcPosId()
{
   positionId = 0;
   ulong unhash = 0;
   bool b1 = crypto.GetBit(magic, 63);
   bool b2 = crypto.GetBit(magic, 62);
   if(!b1)return;
   unhash = crypto.Decrypt(magic);
   crypto.SetBit(unhash, 63, b1);
   crypto.SetBit(unhash, 62, b2);
   ulong bType = 0xFC00000000000000 & unhash;
   bType = bType >> 56;
   bitType = (uchar)bType;
   // 6 ������� ����� ��������� ��� ��������� ����������.
   // ��������� - ��� �������������� ������.
   ulong mask = 0x03FFFFFFFFFFFFFF;
   ulong id = mask & unhash;
   if(FindActivePosById(id) >= 0)
      positionId = id;
}

int Order::FindActivePosById(ulong id)
{
   int total = callBack.ActivePosTotal();
   for(int i = 0; i < total; i++)
   {
      Position* pos = callBack.ActivePosAt(i);
      if(pos.GetId() == id)
         return i;
   }
   return -1;
}

///
/// ���������� ������ � ����������� id � ���� ������
/// c ����� �������.
///
void Order::CompressDeals()
{
   for(int i = 0; i < deals.Total(); i++)
   {
      Deal* curDeal = deals.At(i);
      //��� ������ "��" ���������. ���� ������ �����.
      for(int k = i+1; k < deals.Total();)
      {
         Deal* deal = deals.At(k);
         if(deal.GetId() == curDeal.GetId())
         {
            double vol = curDeal.VolumeExecuted() + deal.VolumeExecuted();
            curDeal.VolumeExecuted(vol);
            deals.Delete(k);
         }
         else
            k++;
      }
   }
}

///
/// ���������� ����� �������������� StopLoss ������.
///
ulong Order::GetStopMask(void)
{
   ulong x = 1;
   return x << 62;
}

///
/// ���������� ����� �������������� StopLoss ������.
///
ulong Order::GetTakeMask(void)
{
   ulong x = 1;
   return x << 61;
}

///
/// ���������� ������, ���� ������� ����� �������� ����-���� �������.
///
bool Order::IsStopLoss(void)
{
   return bitType == id_sl();
}

///
/// ���������� ������, ���� ������� ����� �������� ����-������ �������.
///
bool Order::IsTakeProfit(void)
{
   return bitType == id_tp();
}

///
/// ������, ���� ����� ��� �������� ��������.
///
bool Order::IsCanceled(void)
{
   if(state == ORDER_STATE_CANCELED)
      return true;
   return false;
}

///
/// ���������� �������� ���� ����������� ������ ��� ����� ������.
///
double Order::Commission(void)
{
   double commission = 0.0;
   for(int i = 0; i < deals.Total(); i++)
   {
      Deal* deal = deals.At(i);
      commission += deal.Commission();
   }
   return commission;
}

///
/// ���������� ��������������� ������ � �������.
///
double Order::Slippage(void)
{
   double slippage = priceSetup - priceExecuted;
   if(Direction() == DIRECTION_SHORT)
      slippage *= (-1);
   return slippage;
}

bool Order::IsSelected(ulong id)
{
   if(OrderSelect(id))
      return true;
   ulong time = HistoryOrderGetInteger(id, ORDER_TIME_SETUP);
   if(time > 0)return true;
   return false;
}