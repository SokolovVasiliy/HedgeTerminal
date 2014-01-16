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
      Order* AnigilateOrder(Order* order);
      void AddDeal(CDeal* deal);
      string Comment();
      CTime* CopyExecutedTime();
      ulong GetMagicForClose();
      void DeleteDealAt(int index);
      CDeal* DealAt(int index);
      int DealsTotal();
      void AddVolume(int vol);
      ENUM_ORDER_STATUS Status();
      ENUM_ORDER_STATUS RefreshStatus(void);
      void Init(ulong orderId);
      ulong PositionId();
      CPosition* Position(){return position;}
      bool IsPending();
      Order* Clone();
      virtual double ExecutedVolume();
      void LinkWithPosition(CPosition* pos);
      void Refresh();
      void DealChanged(CDeal* deal);
      int ContainsDeal(CDeal* deal);
      
      ~Order();
   private:
      void RecalcValues(void);
      void RecalcExecutedVolume(void);
      void RecalcExecutedDate(void);
      virtual bool MTContainsMe();
      ///
      ///���� ����� ����������� � �������, �������� ������ �� ���.
      ///
      CPosition* position;
      ///
      /// �������� ����������� ����� ������.
      ///
      double executeVolume;
      ///
      /// �������� ����� ���������� ������.
      ///
      CTime executedTime;
      ///
      /// �������� ������ ������.
      ///
      ENUM_ORDER_STATUS status;
      ///
      /// �������� ������ ������.
      ///
      CArrayObj* deals;
      ///
      /// �������� ����������� � ������.
      ///
      string comment;
};

/*PUBLIC MEMBERS*/
Order::Order() : Transaction(TRANS_ORDER)
{
   deals = new CArrayObj();
   status = ORDER_NULL;
}
///
/// ������� ����� � �������������� idOrder. ����� � ��������� ���������������
/// ������ ������������ � ���� ������ ������� ���������, � ��������� ������, ������
/// ������ ENUM_ORDER_STATUS ����� ��������������� ORDER_NULL (���������������� �����).
///
Order::Order(ulong idOrder):Transaction(TRANS_ORDER)
{
   deals = new CArrayObj();
   Init(idOrder);
}

///
/// ������� ����� ����� �� ����� �� ��� ������.
///
Order::Order(CDeal* deal) : Transaction(TRANS_ORDER)
{
   deals = new CArrayObj();
   AddDeal(deal);
}

///
/// ������� ������ ����� ������ order.
///
Order::Order(Order *order) : Transaction(TRANS_ORDER)
{
   deals = new CArrayObj();
   SetId(order.GetId());
   status = order.Status();
   for(int i = 0; i < order.DealsTotal(); i++)
   {
      CDeal* deal = order.DealAt(i);
      CDeal* ndeal = deal.Clone();
      ndeal.LinqWithOrder(GetPointer(this));
      deals.Add(ndeal);
   }
   position = order.Position();
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
   if(deals != NULL)
   {
      deals.Clear();
      delete deals;
   }
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
   //if(deal.ExecutedVolume() == 0)
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
   if(MTContainsMe())
   {
      if(deals == NULL || deals.Total() == 0)
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
   //RecalcValues();
   this.Comment();
   if(status != NULL && GetId() == 0)
   {
      CDeal* deal = deals.At(0);
      SetId(deal.OrderId());
   }
   //TODO: RefreshPriceAndVol();
   if(position != NULL)
      position.OrderChanged(GetPointer(this));
}
///
/// ���������� ����������� �����.
///
double Order::ExecutedVolume(void)
{
   return 1.0;
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
   if(deals == NULL)
      deals = new CArrayObj();
   deal.LinqWithOrder(GetPointer(this));
   int index = ContainsDeal(deal);
   if(index != -1)
   {
      CDeal* mdeal = deals.At(index);
      mdeal.ExecutedVolume(deal.ExecutedVolume());
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
   if(deals == NULL)
      return 0;
   return deals.Total();
}

///
/// ������, ���� �������� �������� ���������� �� ������ �
/// � ������� ��������������� � ���� � ��������� ������.
///
bool Order::MTContainsMe()
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
/// ���������� ����������� � ������.
///
string Order::Comment()
{
   if(comment == NULL || comment == "")
   {
      if(status == ORDER_EXECUTING || status == ORDER_PENDING)
      {
         OrderSelect(GetId());
         comment = OrderGetString(ORDER_COMMENT);
      }
   }
   return comment;
}

///
/// �������� ����� ��� �������� ������� ������.
///
ulong Order::GetMagicForClose(void)
{
   return GetId();
}

///
/// ���������� ����� ������� ���������� ������.
///
CTime* Order::CopyExecutedTime()
{
   return new CTime(executedTime.Tiks());
}

///
/// ������������� ��� ��������� ������.
///
void Order::RecalcValues(void)
{
   RecalcExecutedVolume();
   RecalcExecutedDate();
}

///
/// ������������� ����������� �����
///
void Order::RecalcExecutedVolume(void)
{
   executeVolume = 0.0;
   
   /*if(!isRefresh || executeVolume == 0.0)
   {
      executeVolume = 0.0;
      for(int i = 0; i < deals.Total(); i++)
      {
         CDeal* deal = deals.At(i);
         executeVolume += deal.ExecutedVolume();
      }
   }*/
}

///
/// ������������� ���� ���������� ������.
///
void Order::RecalcExecutedDate()
{
   // � ����������� ������ ��� ���� ����������.
   if(status == ORDER_PENDING)
      return;
   // ����� ���������� ������ - ��� ����� ���������� �����
   // ��������� ��� ������.
   for(int i = 0; i < deals.Total(); i++)
   {
      CDeal* mdeal = deals.At(i);
      CTime* exTime = mdeal.CopyExecutedTime();
      if(exTime.Tiks() > executedTime.Tiks())
         executedTime.Tiks(exTime.Tiks());
      delete exTime;
   }
}