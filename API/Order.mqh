#include "Transaction.mqh"
#include "..\Log.mqh"

///
/// Тип генерируемого маджика
///
enum ENUM_MAGIC_TYPE
{
   ///
   /// Обычное закрытие по рынку.
   ///
   MAGIC_TYPE_MARKET,
   ///
   /// Ордер является Stop-Loss ордером позиции.
   ///
   MAGIC_TYPE_SL,
   ///
   /// Ордер является Take-Profit ордером позиции.
   ///
   MAGIC_TYPE_TP
};

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
   private:
      ulong GetStopMask(void);
      ulong GetTakeMask(void);
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
      /// Время снятия или истичения ордера.
      ///
      CTime timeCanceled;
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
      ///
      /// Истина, если основные параметры исторического ордера уже получены.
      ///
      bool isCalc;
      /*Если у ордера была исполненная сделка, такой ордер считается активированным.
      В случаи когда у активированного ордера сбрасывается объем (все сделки удаляются)
      его статус становиться ORDER_NULL*/
      ///
      /// Истина, если ордер имел какой-либо исполненный объем.
      ///
      bool activated;
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
   //Пытаемся получить маджиг из аткивных ордеров
   if(magic == 0)
   {
      OrderSelect(GetId());
      magic = OrderGetInteger(ORDER_MAGIC);
   }
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
   //Копируются все значения, кроме ссылки на позицию.
   //position = order.Position();
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
/// Возвращает идентификатор позиции, к которой МОЖЕТ принадлежать ордер.
/// Возвращает 0 - если ордер может принадлежать любой позиции.
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
/// Обновляет состояние ордера.
///
void Order::Refresh(void)
{
   RecalcValues();
   RefreshStatus();
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
   /* compress mode. Смотри ф-ю CompressDeals();
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
/// Истина, если ордер когда-либо исполнялся. Ложь в противном случае.
///
bool Order::IsExecuted()
{
   return activated || deals.Total();
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
ulong Order::GetMagic(ENUM_MAGIC_TYPE magicType = MAGIC_TYPE_MARKET)
{
   switch(magicType)
   {
      case MAGIC_TYPE_MARKET:
         return GetId();
      case MAGIC_TYPE_SL:
         return GetStopMask() | GetId();
      case MAGIC_TYPE_TP:
         return GetTakeMask() | GetId();
   }
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
/// Возвращает время истечения или снятия ордера. Для отложенных
/// и уже исполненных ордеров возвращает 0.
///
long Order::TimeCanceled(void)
{
   return timeCanceled.Tiks();
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
   volumeExecuted = NormalizeDouble(volumeExecuted, 4);
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
   else if((!isCalc && IsHistory()) || IsCanceled())
   {
      //printf("Calc history order");
      ulong id = GetId();
      priceSetup = HistoryOrderGetDouble(id, ORDER_PRICE_OPEN);
      volumeSetup = HistoryOrderGetDouble(id, ORDER_VOLUME_INITIAL);
      timeSetup = HistoryOrderGetInteger(id, ORDER_TIME_SETUP_MSC);
      comment = HistoryOrderGetString(id, ORDER_COMMENT);
      symbol = HistoryOrderGetString(id, ORDER_SYMBOL);
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
/// Рассчитывает идентификатор позиции, которой может
/// принадлежать текущий ордер.
///
void Order::RecalcPosId()
{
   // 6 старших битов оставляем для служебной информации.
   // остальное - для идентификатора номера.
   ulong mask = 0x03FFFFFFFFFFFFFF;
   positionId = magic & mask;
}

///
/// Объеденяет сделки с одинаковыми id в одну сделку
/// c общим объемом.
///
void Order::CompressDeals()
{
   for(int i = 0; i < deals.Total(); i++)
   {
      Deal* curDeal = deals.At(i);
      //Все сделки "до" уникальны. Ищем только после.
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
/// Возвращает маску идентификатора StopLoss ордера.
///
ulong Order::GetStopMask(void)
{
   ulong x = 1;
   return x << 62;
}

///
/// Возвращает маску идентификатора StopLoss ордера.
///
ulong Order::GetTakeMask(void)
{
   ulong x = 1;
   return x << 61;
}

///
/// Возвращает истину, если текущий ордер является стоп-лосс ордером.
///
bool Order::IsStopLoss(void)
{
   bool res = (magic & GetStopMask()) == GetStopMask();
   //Сработавший стоп обрабатывается по-другому и стопом не считается.
   return res;
   //bool exe = IsExecuted();
   //return res && !exe;
}

///
/// Возвращает истину, если текущий ордер является тейк-профит ордером.
///
bool Order::IsTakeProfit(void)
{
   return (magic & GetTakeMask()) == GetTakeMask();
}

///
/// Истина, если ордер был отклонен клиентом.
///
bool Order::IsCanceled(void)
{
   if(state == ORDER_STATE_CANCELED)
      return true;
   return false;
}
