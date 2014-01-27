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
      Order(TradeRequest& request);
      Order(Deal* deal);
      Order(Order* order);
      ~Order();
      
      Order* AnigilateOrder(Order* order);
      void AddDeal(Deal* deal);
      
      string Comment();
      long TimeSetup();
      long TimeExecuted();
      
      Order* Clone();
      int ContainsDeal(Deal* deal);
      
      void DeleteDealAt(int index);
      Deal* DealAt(int index);
      int DealsTotal();
      void DealChanged(Deal* deal);
      
      double PriceSetup();
      double EntryExecutedPrice(void);
      
      ulong GetMagicForClose();
      
      void Init(ulong orderId);
      bool IsPending();
      
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
   private:
      virtual bool IsHistory();
      ENUM_ORDER_STATUS RefreshStatus(void);
      void RecalcValues(void);
      void RecalcPosId(void);
      ///
      /// Если ордер принадлежит к позиции, содержит ссылку на нее.
      ///
      Position* position;
      ///
      /// Содержит теоретический идентификатор позиции, к которой может принадлежать текущий ордер.
      ///
      ulong positionId;
      ///
      /// Содержит первоначальный объем, при постановки ордера.
      ///
      double volumeSetup;
      ///
      /// Содержит выполненный объем ордера.
      ///
      double volumeExecuted;
      ///
      /// Содержит время установки ордера.
      ///
      CTime timeSetup;
      ///
      /// Содержит время исполнения ордера.
      ///
      CTime timeExecuted;
      ///
      /// Содержит цену установки ордера.
      ///
      double priceSetup;
      ///
      /// Содержит средневзвешенную цену входа.
      ///
      double priceExecuted;
      ///
      /// Содержит статус ордера.
      ///
      ENUM_ORDER_STATUS status;
      ///
      /// Тип ордера.
      ///
      ENUM_ORDER_TYPE type;
      ///
      /// Состояние ордера.
      ///
      ENUM_ORDER_STATE state;
      ///
      /// Содержит сделки ордера.
      ///
      CArrayObj deals;
      ///
      /// Содержит Комментарий к ордеру.
      ///
      string comment;
      ///
      /// Магический номер эксперта, выставившего ордер.
      ///
      ulong magic;
};

/*PUBLIC MEMBERS*/
Order::Order() : Transaction(TRANS_ORDER)
{
   
   status = ORDER_NULL;
}
///
/// Создает ордер с идентификтором idOrder. Ордер с указанным идентификатором
/// должен существовать в базе данных ордеров терминала, в противном случае, статус
/// ордера ENUM_ORDER_STATUS будет соответствовать ORDER_NULL (недействительный ордер).
///
Order::Order(ulong idOrder):Transaction(TRANS_ORDER)
{
   Init(idOrder);
}

///
/// Создает новый ордер на одной из его сделок.
///
Order::Order(Deal* deal) : Transaction(TRANS_ORDER)
{
   AddDeal(deal);
}

///
/// Создает ордер, используя информацию из торгового запроса.
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
   RecalcPosId();
}

///
/// Создает полную копию ордера order.
///
Order::Order(Order *order) : Transaction(TRANS_ORDER)
{
   SetId(order.GetId());
   for(int i = 0; i < order.DealsTotal(); i++)
   {
      Deal* deal = order.DealAt(i);
      Deal* ndeal = deal.Clone();
      ndeal.LinqWithOrder(GetPointer(this));
      deals.Add(ndeal);
   }
   comment = order.Comment();
   status = order.Status();
   position = order.Position();
   priceSetup = order.PriceSetup();
   priceExecuted = order.EntryExecutedPrice();
   timeSetup = order.TimeSetup();
   timeExecuted = order.TimeExecuted();
   volumeSetup = order.VolumeSetup();
   volumeExecuted = order.VolumeExecuted();
   type = order.OrderType();
   state = order.OrderState();
   magic = order.Magic();
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
   deals.Clear();
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
   return positionId;
}

///
/// Устанавливает ссылку на позицию, к которой принадлежит данный ордер.
///
void Order::LinkWithPosition(Position* pos)
{
   if(CheckPointer(pos) == POINTER_INVALID)
      return;
   ulong posId = pos.GetId();
   if(posId == 0 || pos.GetId() == GetId() || pos.GetId() == HedgeManager::CanPositionId(magic))
      position = pos;
   else
      LogWriter("Link order failed: this order has a different id with position id.", MESSAGE_TYPE_WARNING);
   /*if(pos.GetId() > 0 && pos.GetId() != PositionId())
   {
      LogWriter("Link order failed: this order has a different id with position id.", MESSAGE_TYPE_WARNING);
      return;
   }
   position = pos;*/
}

///
/// Сделка, принадлежащая этому ордеру, вызывает эту функцию,
/// когда ее состояние изменилось.
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
/// Находит в списке сделок, сделку чей id равен
/// id переданной сделки и в случае успеха возвращает
/// индекс этой сделки в списке сделок. Если сделки с
/// таким id нет - возвращает -1.
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
   if(IsHistory())
   {
      if(deals.Total() == 0)
         status = ORDER_NULL;
      else
         status = ORDER_HISTORY;   
   }
   else
      status = ORDER_NULL;
   return status;
}

///
/// Обновляет состояние ордера.
///
void Order::Refresh(void)
{
   RefreshStatus();
   RecalcValues();
   if(status != ORDER_NULL && GetId() == 0 && deals.Total() > 0)
   {
      Deal* deal = deals.At(0);
      SetId(deal.OrderId());
   }
   //TODO: RefreshPriceAndVol();
   if(position != NULL)
      position.OrderChanged(GetPointer(this));
}

///
/// Добавляет сделку в список сделок ордера.
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
   int index = ContainsDeal(deal);
   if(index != -1)
   {
      Deal* mdeal = deals.At(index);
      mdeal.VolumeExecuted(deal.VolumeExecuted());
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
Deal* Order::DealAt(int index)
{
   Deal* deal = deals.At(index);
   return deal;
}

///
/// Возвращает количество сделок.
///
int Order::DealsTotal()
{
   return deals.Total();
}

///
/// Истина, если терминал содержит информацию об ордере с
/// с текущим идентификатором и ложь в противном случае.
///
bool Order::IsHistory()
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
/// Возвращает истину, если ордер находится в состоянии модификации.
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
/// Получает магик для закрытия данного ордера.
///
ulong Order::GetMagicForClose(void)
{
   return GetId();
}

///
/// Возвращает комментарий к ордеру.
///
string Order::Comment()
{
   return comment;
}

///
/// Возвращает точное время установки ордера, в виде
/// количества тиков прошедших с 01.01.1970 года.
///
long Order::TimeSetup()
{
   return timeSetup.Tiks();
}

///
/// Возвращает точное время исполнения ордера, в виде
/// количества тиков прошедших с 01.01.1970 года.
///
long Order::TimeExecuted()
{
   return timeExecuted.Tiks();
}

///
/// Возвращает цену цену исполнения ордера.
///
double Order::PriceSetup(void)
{
   return priceSetup;
}

///
/// Возвращает средневзвешенную цену исполнения ордера.
///
double Order::EntryExecutedPrice(void)
{
   return priceExecuted;
}

///
/// Возвращает первоначальный объем при постановке ордера.
///
double Order::VolumeSetup(void)
{
   return volumeSetup;
}

///
/// Возвращает исполненный объем.
///
double Order::VolumeExecuted(void)
{
   return volumeExecuted;
}

///
/// Возвращает неисполненный объем.
///
double Order::VolumeReject(void)
{
   return volumeSetup - volumeExecuted;
}

///
/// Возвращает тип ордера в виде строки.
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
/// Направление ордера.
///
ENUM_DIRECTION_TYPE Order::Direction()
{
   if(type % 2 == 0)
      return DIRECTION_LONG;
   else
      return DIRECTION_SHORT;
}

///
/// Рассчитывает средневзвешенную цену входа.
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
      priceExecuted /= volumeExecuted;
   //calc setup price and comment.
   if(IsPending())
   {
      OrderSelect(GetId());
      priceSetup = OrderGetDouble(ORDER_PRICE_OPEN);
      volumeSetup = OrderGetDouble(ORDER_VOLUME_INITIAL);
      timeSetup = OrderGetInteger(ORDER_TIME_SETUP_MSC);
      comment = OrderGetString(ORDER_COMMENT);
      symbol = OrderGetString(ORDER_SYMBOL);
      type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      state = (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE);
      magic = OrderGetInteger(ORDER_MAGIC);
   }
   else if(IsHistory())
   {
      priceSetup = HistoryOrderGetDouble(GetId(), ORDER_PRICE_OPEN);
      volumeSetup = HistoryOrderGetDouble(GetId(), ORDER_VOLUME_INITIAL);
      timeSetup = HistoryOrderGetInteger(GetId(), ORDER_TIME_SETUP_MSC);
      comment = HistoryOrderGetString(GetId(), ORDER_COMMENT);
      symbol = HistoryOrderGetString(GetId(), ORDER_SYMBOL);
      type = (ENUM_ORDER_TYPE)HistoryOrderGetInteger(GetId(), ORDER_TYPE);
      state = (ENUM_ORDER_STATE)HistoryOrderGetInteger(GetId(), ORDER_STATE);
      magic = HistoryOrderGetInteger(GetId(), ORDER_MAGIC);
   }
   RecalcPosId();
}

///
/// Рассчитывает идентификатор позиции, которой может
/// принадлежать текущий ордер.
///
void Order::RecalcPosId()
{
   positionId = magic;
}