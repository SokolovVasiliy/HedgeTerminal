#include "Transaction.mqh"
#include "..\Log.mqh"
///
/// Статус ордера.
///
enum ENUM_ORDER_STATUS
{
   ///
   /// Фиктивный ордер, не существующий в базе данных терминала, либо ордер,
   /// чьи сделки были полностью уничтожены.
   ///
   ORDER_NULL,
   ///
   /// Отложенный, еще не исполненный ордер.
   ///
   ORDER_PENDING,
   ///
   /// Ордер в процессе исполнения.
   ///
   ORDER_EXECUTING,
   ///
   /// Исполненный, исторический ордер.
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
      ///Если ордер принадлежит к позиции, содержит ссылку на нее.
      ///
      CPosition* position;
      ///
      /// Содержит выполненный объем ордера.
      ///
      double executeVolume;
      ///
      /// Содержит время исполнения ордера.
      ///
      CTime executedTime;
      ///
      /// Содержит статус ордера.
      ///
      ENUM_ORDER_STATUS status;
      ///
      /// Содержит сделки ордера.
      ///
      CArrayObj* deals;
      ///
      /// Содержит Комментарий к ордеру.
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
/// Создает ордер с идентификтором idOrder. Ордер с указанным идентификатором
/// должен существовать в базе данных ордеров терминала, в противном случае, статус
/// ордера ENUM_ORDER_STATUS будет соответствовать ORDER_NULL (недействительный ордер).
///
Order::Order(ulong idOrder):Transaction(TRANS_ORDER)
{
   deals = new CArrayObj();
   Init(idOrder);
}

///
/// Создает новый ордер на одной из его сделок.
///
Order::Order(CDeal* deal) : Transaction(TRANS_ORDER)
{
   deals = new CArrayObj();
   AddDeal(deal);
}

///
/// Создает полную копию ордера order.
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
/// Возвращает полную копию ордера.
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
/// Возвращает идентификатор позиции, к которой может принадлежать ордер.
///
ulong Order::PositionId()
{
   //Ордер закрывающий?
   ulong posId = HistoryOrderGetInteger(GetId(), ORDER_MAGIC);
   if(HistoryOrderGetInteger(posId, ORDER_TIME_DONE) > 0)
      return posId;
   //Ордер открывающий.
   return GetId();
}

///
/// Устанавливает ссылку на позицию, к которой принадлежит данный ордер.
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
/// Сделка, принадлежащая этому ордеру, вызывает эту функцию,
/// когда ее состояние изменилось.
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
/// Находит в списке сделок, сделку чей id равен
/// id переданной сделки и в случае успеха возвращает
/// индекс этой сделки в списке сделок. Если сделки с
/// таким id нет - возвращает -1.
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
/// Возвращает последний известный статус ордера. Статус может отличаться от фактического.
/// Для точного определения статуса используйте функцию Checkstatus(). 
/// \return Последний известный статус ордера.
///
ENUM_ORDER_STATUS Order::Status(void)
{
   return status;
}

///
/// Возвращает статус ордера ENUM_ORDER_STATUS на основании информации полученной из
/// базы данных ордеров терминала. Синхранизирует последнее известное состояние статуса
/// ордера с текущим состоянием.
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
/// Обновляет состояние ордера.
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
/// Возвращает исполненный объем.
///
double Order::ExecutedVolume(void)
{
   return 1.0;
}
///
/// Добавляет сделку в список сделок ордера.
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
/// Удаляет сделку из списка сделок.
///
void Order::DeleteDealAt(int index)
{
   if(deals.Total() <= index)return;
   deals.Delete(index);
   Refresh();
}
///
/// Возвращает сделку находящуюся в списке сделок по индексу index.
///
CDeal* Order::DealAt(int index)
{
   return deals.At(index);
}

///
/// Возвращает количество сделок.
///
int Order::DealsTotal()
{
   if(deals == NULL)
      return 0;
   return deals.Total();
}

///
/// Истина, если терминал содержит информацию об ордере с
/// с текущим идентификатором и ложь в противном случае.
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
/// Возвращает комментарий к ордеру.
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
/// Получает магик для закрытия данного ордера.
///
ulong Order::GetMagicForClose(void)
{
   return GetId();
}

///
/// Возвращает копию времени исполнения ордера.
///
CTime* Order::CopyExecutedTime()
{
   return new CTime(executedTime.Tiks());
}

///
/// Пересчитывает все параметры ордера.
///
void Order::RecalcValues(void)
{
   RecalcExecutedVolume();
   RecalcExecutedDate();
}

///
/// Пересчитывает выполненный объем
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
/// Пересчитывает дату исполнения сделки.
///
void Order::RecalcExecutedDate()
{
   // У отложенного ордера нет даты исполнения.
   if(status == ORDER_PENDING)
      return;
   // Время исполнения ордера - это время исполнения самой
   // последней его сделки.
   for(int i = 0; i < deals.Total(); i++)
   {
      CDeal* mdeal = deals.At(i);
      CTime* exTime = mdeal.CopyExecutedTime();
      if(exTime.Tiks() > executedTime.Tiks())
         executedTime.Tiks(exTime.Tiks());
      delete exTime;
   }
}