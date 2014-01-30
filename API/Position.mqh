#include "..\Math.mqh"
#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"
#include "..\Events.mqh"

class Position;

///
/// Info about the Integration.
///
class InfoIntegration
{
   public:
      /*InfoIntegration();
      ~InfoIntegration();*/
      bool IsSuccess;
      string InfoMessage;
      Position* ActivePosition;
      Position* HistoryPosition;
};


/*InfoIntegration::InfoIntegration(void)
{
   printf("create infoIntegr.");
   //ActivePosition = new Position();
   //HistoryPosition = new Position();
   //InfoMessage = "";
}

InfoIntegration::~InfoIntegration(void)
{
   printf("delete infoIntegr.");
}*/

///
/// Статус позиции.
///
enum POSITION_STATUS
{
   ///
   /// Нулевая позиция.
   ///
   POSITION_NULL,
   ///
   /// Активная позиция.
   ///
   POSITION_ACTIVE,
   ///
   /// Историческая позиция.
   ///
   POSITION_HISTORY,
};

///
/// Используется для компановки ордеров как параметр функции ExchangerOrder.
///
struct ExchangerList
{
   public:
      Order* inOrder;
      Order* outOrder;
      Order* histInOrder;
      Order* histOutOrder;
};

class Position : public Transaction
{
   public:
      Position(void);
      Position(Order* inOrder);
      Position(Order* inOrder, Order* outOrder);
      ~Position();
      
      #ifdef HEDGE_PANEL
         /// Возвращает указатель на графическое представление текущей позиции. 
         PosLine* PositionLine(){return positionLine;}
         /// Устанавливает указатель на графическое представление текущей позиции.
         void PositionLine(CObject* pLine){positionLine = pLine;}
      #endif
      ulong EntryOrderId(void);
      ulong ExitOrderId(void);
      
      ulong EntryMagic(void);
      ulong ExitMagic(void);
      virtual ulong Magic(void);
      
      string EntryComment(void);
      string ExitComment(void);
      
      long EntryExecutedTime(void);
      long ExitExecutedTime(void);
      
      long EntrySetupTime(void);
      long ExitSetupTime(void);
      
      double EntryExecutedPrice(void);
      double ExitExecutedPrice(void);
      
      double EntrySetupPrice(void);
      double ExitSetupPrice(void);
      
      double VolumeSetup(void);
      double VolumeRejected(void);
      virtual double VolumeExecuted(void);
      bool IsValidNewVolume(double setVol);
      
      string Symbol(void);
      
      double StopLossLevel(void);
      double TakeProfitLevel(void);
      void StopLossLevel(double level);
      void TakeProfitLevel(double level);
      bool UsingStopLoss(void);
      void UsingStopLoss(bool useStopLoss);
      
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
      static void ExchangerOrder(ExchangerList& list);
      bool Merge(Position* pos);
      Order* EntryOrder(){return initOrder;}
      Order* ExitOrder(){return closingOrder;}
      bool Compatible(Position* pos);
      virtual int Compare(const CObject* node, const int mode=0);
      void OrderChanged(Order* order);
      void Refresh();
      void AsynchClose(double vol, string comment = NULL);
      virtual string TypeAsString(void);
      virtual ENUM_DIRECTION_TYPE Direction(void);
      void ProcessingNewOrder(long ticket);
      bool IsBlocked();
      void NoticeModify(void);
      void Event(Event* event);
   private:
      ///
      /// Класс, для совершения торговых операций.
      ///
      CTrade trading;
      void Init();
      ///
      /// Определяет тип ордера, который был изменен.
      ///
      enum ENUM_CHANGED_ORDER
      {
         ///
         /// Этот ордер не принадлежит к текущей позиции.
         ///
         CHANGED_ORDER_NDEF,
         ///
         /// Этот ордер инициализурет позицию. 
         ///
         CHANGED_ORDER_INIT,
         ///
         /// Этот ордер закрывает позицию.
         ///
         CHANGED_ORDER_CLOSED
      };
      ///
      /// Флаг блокировки, истина, если позиция находится в процессе изменения.
      ///
      bool blocked;
      ///
      /// Показывает, находится ли позиция в состоянии модификации.
      ///
      bool isModify;
      ///
      /// Время начала блокировки.
      ///
      CTime blockedTime;
      ///
      /// Содержит список тикетов ордеров принадлежащих текущей позиции, которые находятся в процессе обработки.
      ///
      //CArrayLong processingOrders;
      ENUM_CHANGED_ORDER DetectChangedOrder(Order* order);
      void ChangedInitOrder();
      void DeleteAllOrders();
      Position* OrderManager(Order* openOrder, Order* cloingOrder);
      bool CompatibleForInit(Order* order);
      bool CompatibleForClose(Order* order);
      InfoIntegration* AddClosingOrder(Order* outOrder);
      void AddInitialOrder(Order* inOrder);
      POSITION_STATUS CheckStatus(void);
      void ResetBlocked(void);
      void SetBlock(void);
      void OnRequestNotice(EventRequestNotice* notice);
      void OnRejected(TradeResult& result);
      Order* initOrder;
      Order* closingOrder;
      POSITION_STATUS status;
      void SendEventBlockStatus(bool status);
      #ifdef HEDGE_PANEL
         PosLine* positionLine;
      #endif
      
};
///
/// Деинициализирует позицию.
///
Position::~Position()
{
   DeleteAllOrders();
}
///
/// Создает неактивную позицию со статусом POSITION_NULL.
///
Position::Position() : Transaction(TRANS_POSITION)
{
   status = POSITION_NULL;
}

///
/// В случае успеха создает активную позицию. В случае неудачи
/// будет создана позиция со статусом POSITION_NULL.
///
Position::Position(Order* inOrder) : Transaction(TRANS_POSITION)
{
   
   InfoIntegration* info = Integrate(inOrder);
   delete info;
}
///
/// Создает историческу позицию. Объемы исходящего и входящего ордеров должны быть равны.
///
Position::Position(Order* inOrder, Order* outOrder) : Transaction(TRANS_POSITION)
{
   if(inOrder == NULL || outOrder == NULL)
      return;
   if(inOrder.VolumeExecuted() != outOrder.VolumeExecuted())
      return;
   ulong in_id = inOrder.GetId();
   ulong out_id = outOrder.PositionId();
   if(inOrder.GetId() != outOrder.PositionId())
      return;
   status = POSITION_HISTORY;
   initOrder = inOrder;
   Refresh();
   initOrder.LinkWithPosition(GetPointer(this));
   closingOrder = outOrder;
   Refresh();
   closingOrder.LinkWithPosition(GetPointer(this));
}

bool Position::Compatible(Position *pos)
{
   if(pos.Status() == POSITION_NULL)
      return false;
   if(pos.GetId() != GetId())
      return false;
   if(pos.Status() != pos.Status())
      return false;
   if(pos.Status() == POSITION_HISTORY)
   {
      Order* clOrder = pos.ExitOrder();
      if(clOrder.GetId() != closingOrder.GetId())
         return false;
   }
   return true;
}
///
/// Объединяет переданную позицию с текущей позицией.
/// После удачного объеденения переданная позиция лишается всех ее сделок
/// и переходит в состояние POSITION_NULL.
///
bool Position::Merge(Position *pos)
{
   if(!Compatible(pos))
      return false;
   //Merge init deals.
   Order* order = pos.EntryOrder();
   //CArrayObj inDeals = in.D
   while(order.DealsTotal())
   {
      Deal* ndeal = new Deal(order.DealAt(0));
      initOrder.AddDeal(ndeal);
      order.DeleteDealAt(0);
   }
   order = pos.ExitOrder();
   if(order == NULL)
      return true;
   while(order.DealsTotal())
   {
      Deal* ndeal = new Deal(order.DealAt(0));
      closingOrder.AddDeal(ndeal);
      order.DeleteDealAt(0);
   }
   return true;
}

///
/// Интегрирует ордер в текущую позицию. После успешной интеграции статус позиции
/// и все ее свойства могут измениться. Результатом интеграции могут стать
/// новые созданные позиции, как активные так и исторические.
/// \return Класс содержит информацию об интеграции и может быть уничтожен внешним
/// объектом.
///
InfoIntegration* Position::Integrate(Order* order)
{
   InfoIntegration* info = NULL;
   if(CompatibleForInit(order))
   {
      AddInitialOrder(order);
      info = new InfoIntegration();
      ResetBlocked();
   }
   else if(CompatibleForClose(order))
   {
      info = AddClosingOrder(order);
      ResetBlocked();
   }
   else
   {
      info = new InfoIntegration();
      info.InfoMessage = "Proposed order #" + (string)order.GetId() +
      "can not be integrated in position #" + (string)GetId() +
      ". Position and order has not compatible types";
   }
   return info;
}

///
/// Возвращает истину, если ордер может быть добавлен в позицию как открывающий.
///
bool Position::CompatibleForInit(Order *order)
{
   if(status == POSITION_NULL)
      return true;
   if(initOrder.GetId() == order.GetId())
      return true;
   else
      return false;
}

///
/// Возвращает истину, если ордер может быть закрывающим ордером позиции.
///
bool Position::CompatibleForClose(Order *order)
{
   //Закрыть можно только активную позицию.
   if(status != POSITION_ACTIVE)
      return false;
   if(order.PositionId() == GetId())
      return true;
   return false;
}

///
/// Добавляет инициирующий ордер в позицию.
///
void Position::AddInitialOrder(Order *inOrder)
{
   if(status == POSITION_NULL)
   {
      initOrder = inOrder;
      Refresh();
      inOrder.LinkWithPosition(GetPointer(this));
   }
   else
   {
      string msg = "Order #" + (string)inOrder.GetId() + " can not be inserted as init order because init Order already exits.";
      LogWriter(msg, MESSAGE_TYPE_WARNING);
   }
}

///
/// Добавляте закрывающий ордер в актинвую позицию.
///
InfoIntegration* Position::AddClosingOrder(Order* outOrder)
{
   InfoIntegration* info = new InfoIntegration();
   info.HistoryPosition = OrderManager(initOrder, outOrder);
   if(outOrder.Status() != ORDER_NULL)
   {
      //Position* nPos = new Position(outOrder);
      info.ActivePosition = new Position(outOrder);
   }
   else
   {
      delete outOrder;
      outOrder = NULL;
   }
   return info;
}

///
/// Проверяет, является ли статус переданного ордера совместимым с понятием "позиция".
/// \return Истина, если ордер может принадлежать позиции, ложь в противном случае.
///
static bool Position::CheckOrderType(Order* checkOrder)
{
   bool isNull = CheckPointer(checkOrder) == POINTER_INVALID;
   if(isNull || checkOrder.Type() == ORDER_NULL ||
      checkOrder.Type() == ORDER_PENDING)
   {
      return false;
   }
   return true;
}

///
///
///
void Position::Refresh(void)
{
   CheckStatus();
   if(initOrder != NULL)
      SetId(initOrder.GetId());
   else
      SetId(0);
}

///
/// Обновляет статус позиции.
///
POSITION_STATUS Position::CheckStatus()
{
   if(CheckPointer(initOrder) == POINTER_INVALID ||
      initOrder.DealsTotal() == 0 || initOrder.VolumeExecuted() == 0.0)
   {
      status = POSITION_NULL;
      return status;
   }
   if(CheckPointer(closingOrder) != POINTER_INVALID)
      status = POSITION_HISTORY;
   else
      status = POSITION_ACTIVE;
   return status;
}

POSITION_STATUS Position::Status()
{
   return status;
}


///
/// Преобразует инициирующий и закрывающий позицию ордера в новую
/// историческую позицию. После преобразования входящий и исходящий
/// ордера изменяют свое содержимое, как правило становясь нулевыми.
/// Изменения inOrder отражают изменения активной позиции. В случае,
/// если после преобразования outOrder содержит какой-либо объем,
/// его необходимо преобразовать в активную позицию.
/// \param inOrder - Входящий ордер активной позиции.
/// \param outOrder - Исходящий, закрывающий активную позицию ордер.
/// \return Историческая позиция которая была создана.
///
Position* Position::OrderManager(Order* inOrder, Order* outOrder)
{
   //Точность (знаков после запятой), с которой будет округляться вычисления с объемами. 
   int digits = 4;
   //Создаем прототипы входящего и исходящего ордеров, которые будут образовывать
   //историческую позицию.
   Order* histInOrder = new Order();
   Order* histOutOrder = new Order();
   while(true)
   {
      //Трейды закончились, больше разбирать нечего.
      if(!inOrder.DealsTotal() ||
         !outOrder.DealsTotal())
         break;
      Deal* inDeal = inOrder.DealAt(0);
      Deal* outDeal = outOrder.DealAt(0);
      //Из двух сделок выбираем наименьший объем.
      double inVol = NormalizeDouble(inDeal.VolumeExecuted(), digits);
      double outVol = NormalizeDouble(outDeal.VolumeExecuted(), digits);
      double vol = MathMin(inVol, outVol);
      vol = NormalizeDouble(vol, digits);
      //Делаем клоны этих двух сделок с объемом, который вычтем из активных.
      Deal* histInDeal = new Deal(inDeal);
      histInDeal.VolumeExecuted(vol);
      Deal* histOutDeal = new Deal(outDeal);
      histOutDeal.VolumeExecuted(vol);
      //Размещаем получившиеся сделки в ордерах для исторической позиции.
      histInOrder.AddDeal(histInDeal);
      histOutOrder.AddDeal(histOutDeal);
      //Уменьшаем каждую из переданных сделок на этот объем.
      inDeal.VolumeExecuted(inVol-vol);
      outDeal.VolumeExecuted(outVol-vol);
      //Если у одной из сделок объема больше не осталось, - удаяляем ее.
      if(inDeal.Status() == DEAL_NULL)
         inOrder.DeleteDealAt(0);
      if(outDeal.Status() == DEAL_NULL)
         outOrder.DeleteDealAt(0);
   }
   //Создаем историческую позицию, которая получилась в результате
   //преобразования двух ордеров.
   //histInOrder.CompressDeals();
   //histOutOrder.CompressDeals();
   Position* histPos = new Position(histInOrder, histOutOrder);
   return histPos;
}

int Position::Compare(const CObject* node, const int mode=0)
{
   switch(mode)
   {
      case SORT_ORDER_ID:
      {
         const Transaction* trans = node;
         ulong my_id = GetId();
         ulong trans_id = trans.GetId();
         if(GetId() == trans.GetId())
            return EQUAL;
         if(GetId() < trans.GetId())
            return LESS;
         return GREATE;
      }
   }
   return 0;
}

///
/// Определяет тип ордера, который был изменен.
///
ENUM_CHANGED_ORDER Position::DetectChangedOrder(Order *order)
{
   if(status == POSITION_NULL)
      return CHANGED_ORDER_NDEF;
   if(initOrder.GetId() == order.GetId())
      return CHANGED_ORDER_INIT;
   if(status == POSITION_HISTORY &&
      closingOrder.GetId() == order.GetId())
      return CHANGED_ORDER_CLOSED;      
   return CHANGED_ORDER_INIT;
}

void Position::OrderChanged(Order* order)
{
    ENUM_CHANGED_ORDER changedType = DetectChangedOrder(order);
    switch(changedType)
    {
      case CHANGED_ORDER_NDEF:
         return;
      case CHANGED_ORDER_INIT:
         ChangedInitOrder();
         break;
      case CHANGED_ORDER_CLOSED:
         break;
    }
}

///
/// Обрабатывает изменения инициирующего ордера.
///
void Position::ChangedInitOrder()
{
   if(initOrder.Status() == ORDER_EXECUTING)
      blocked = true;
   Refresh();
}

///
/// Удаляет все ордера.
///
void Position::DeleteAllOrders(void)
{
   if(initOrder != NULL)
   {
      delete initOrder;
      initOrder = NULL;
   }
   if(closingOrder != NULL)
   {
      delete closingOrder;
      closingOrder = NULL;
   }
}

///
/// Закрывает текущую позицию либо ее часть асинхронно.
/// \param vol - объем, который необходимо закрыть.
/// \param comment - комментарий, который необходимо присвоить закрывающей сделке.
///
void Position::AsynchClose(double vol, string comment = NULL)
{
   if(IsBlocked())
   {
      printf("Position is blocked. Try letter");
      return;
   }
   trading.SetAsyncMode(true);
   trading.SetExpertMagicNumber(initOrder.GetMagicForClose());
   bool resTrans = false;
   if(Direction() == DIRECTION_LONG)
      resTrans = trading.Sell(vol, Symbol(), 0.0, 0.0, 0.0, comment);
   else if(Direction() == DIRECTION_SHORT)
      resTrans = trading.Buy(vol, Symbol(), 0.0, 0.0, 0.0, comment);
   if(resTrans)
      SetBlock();
   else
   {
      printf("Rejected current operation by reason: " + trading.ResultRetcodeDescription());
      ResetBlocked();
   }
}

///
/// Возвращает входищий комментарий позиции.
///
string Position::EntryComment(void)
{
   if(initOrder != NULL)
      return initOrder.Comment();
   return "";
}

///
/// Возвращает исходящий комментарий позиции.
///
string Position::ExitComment(void)
{
   if(closingOrder != NULL)
      return closingOrder.Comment();
   return "";
}

///
/// Возвращает точное время установки позиции, в виде
/// количества тиков прошедших с 01.01.1970 года.
///
long Position::EntrySetupTime(void)
{
   if(initOrder != NULL)
      return initOrder.TimeSetup();
   return 0;
}

///
/// Возвращает точное время приказа на закрытие позиции, в виде
/// количества тиков прошедших с 01.01.1970 года.
///
long Position::ExitSetupTime(void)
{
   if(closingOrder != NULL)
      return closingOrder.TimeSetup();
   return 0;
}

///
/// Возвращает точное время исполнения позиции, в виде
/// количества тиков прошедших с 01.01.1970 года.
///
long Position::EntryExecutedTime(void)
{
   if(initOrder != NULL)
      return initOrder.TimeExecuted();
   return 0;
}

///
/// Возвращает точное время фактического закрытия позиции, в виде
/// количества тиков прошедших с 01.01.1970 года.
///
long Position::ExitExecutedTime(void)
{
   if(closingOrder != NULL)
      return closingOrder.TimeExecuted();
   return 0;
}

///
/// Возвращает фактическую цену входа в позицию.
///
double Position::EntryExecutedPrice(void)
{
   if(initOrder != NULL)
      return initOrder.EntryExecutedPrice();
   return 0.0;
}

///
/// Возвращает фактическую цену выхода из позиции.
///
double Position::ExitExecutedPrice(void)
{
   if(closingOrder != NULL)
      return closingOrder.EntryExecutedPrice();
   return 0.0;
}

///
/// Возвращает размещенную цену входа в позицию.
///
double Position::EntrySetupPrice(void)
{
   if(initOrder != NULL)
      return initOrder.PriceSetup();
   return 0.0;
}

///
/// Возвращает размещенную цену выхода из позиции.
///
double Position::ExitSetupPrice(void)
{
   if(closingOrder != NULL)
      return closingOrder.PriceSetup();
   return 0.0;
}

///
/// Возвращает фактический исполненный объем позиции.
///
double Position::VolumeExecuted(void)
{
   if(initOrder != NULL)
      return initOrder.VolumeExecuted();
   return 0.0;
}

///
/// Возвращает идентификатор входящящего ордера позиции.
///
ulong Position::EntryOrderId()
{
   if(initOrder != NULL)
      return initOrder.GetId();
   return 0;
}

///
/// Возвращает идентификатор исходящего ордера позиции.
///
ulong Position::ExitOrderId()
{
   if(closingOrder != NULL)
      return closingOrder.GetId();
   return 0;
}

///
/// Возвращает магический номер входящего ордера.
///
ulong Position::EntryMagic(void)
{
   if(initOrder != NULL)
      return initOrder.Magic();
   return 0;
}

ulong Position::Magic()
{
   return EntryMagic();
}
///
/// Возвращает магический номер закрывающего ордера.
///
ulong Position::ExitMagic(void)
{
   if(closingOrder != NULL)
      return closingOrder.Magic();
   return 0;
}

///
/// Возвращает уровень стоп-лосса.
///
double Position::StopLossLevel(void)
{
   return 0.0;
}

///
/// Устанавливает уровень стоп-лосса.
///
void Position::StopLossLevel(double level)
{
}

///
/// Возвращает уровень тейк-профита.
///
double Position::TakeProfitLevel(void)
{
   return 0.0;
}

///
/// Устанавливает уровень тейк-профита.
///
void Position::TakeProfitLevel(double level)
{
}

///
/// Истина, если используется стоп-лосс, ложь в противном случае.
///
bool Position::UsingStopLoss(void)
{
   return false;
}

///
/// Включает (useStopLoss=true) или отключает (useStopLoss=false) использования стоп-лосса.
///
void Position::UsingStopLoss(bool useStopLoss)
{
}

///
/// Возвращает символ, по которому открыта позиция.
///
string Position::Symbol()
{
   if(initOrder != NULL)
      return initOrder.Symbol();
   return "";
}

///
/// Возвращает тип позиции.
///
string Position::TypeAsString(void)
{
   if(initOrder != NULL)
      return initOrder.TypeAsString();
   return this.TypeAsString();
}

///
/// Направление позиции.
///
ENUM_DIRECTION_TYPE Position::Direction()
{
   if(initOrder != NULL)
      return initOrder.Direction();
   return DIRECTION_NDEF;
}

///
/// Сбрасывает блокировку позиции.
///
void Position::ResetBlocked(void)
{
   blocked = false;
   blockedTime.Tiks(0);
   isModify = false;
   SendEventBlockStatus(false);
}

///
/// Блокирует позицию для любых изменений.
///
void Position::SetBlock(void)
{
   blocked = true;
   blockedTime.SetDateTime(TimeCurrent()*1000);
   SendEventBlockStatus(true);
}

///
/// Отправляет событие уведомляющее графическое представление позиции о том,
/// что позиция находится в стадии изменения.
///
void Position::SendEventBlockStatus(bool curStatus)
{
   #ifdef HEDGE_PANEL
   if(positionLine != NULL)
   {
      EventBlockPosition* event = new EventBlockPosition(GetPointer(this), curStatus);
      positionLine.Event(event);
      delete event;
   }
   #endif
}

///
/// Возвращает истину, если позиция находится в состоянии изменения и ложь в противном случае.
///
bool Position::IsBlocked(void)
{
   if(!isModify)
   {
      if(!blocked)
         return false;
      long elepseTime = TimeCurrent() - blockedTime.ToDatetime();
      if(elepseTime > 180)
         ResetBlocked();
   }
   return isModify || blocked;
}

///
/// Обрабатывает поступающие события.
///
void Position::Event(Event* event)
{
   switch(event.EventId())
   {
      case EVENT_REQUEST_NOTICE:
         OnRequestNotice(event);
         break;   
   }
}

///
/// Обрабатывает уведомления о изменении позиции
///
void Position::OnRequestNotice(EventRequestNotice* notice)
{
   TradeResult* result = notice.GetResult();
   if(result.IsRejected())
      OnRejected(result);
}

///
/// Обрабатывает ситуацию, когда запрос был отклонен.
///
void Position::OnRejected(TradeResult& result)
{
   if(!result.IsRejected())return;
   ResetBlocked();
   switch(result.retcode)
   {
      case TRADE_RETCODE_NO_MONEY:
         LogWriter("Position #" + (string)GetId() + ": Unmanaged hedge. Try to close parts.", MESSAGE_TYPE_INFO);
   }
}

///
/// Ордер изменяющий позицию находится в процессе модификации.
///
void Position::NoticeModify(void)
{
   isModify = true;
}

///
/// Возвращает истину, если объем текущей позиции может быть
/// изменен на новый объем setVol.
///
bool Position::IsValidNewVolume(double setVol)
{
   double curVol = VolumeExecuted();
   if(Math::DoubleEquals(curVol, 0.0))
   {
      LogWriter("Position #" + (string)GetId() + " not active. The new volume not be set.", MESSAGE_TYPE_INFO);
      return false;
   }
   if(Math::DoubleEquals(setVol, 0.0) || setVol < 0.0)
   {
      LogWriter("The new volume should be greater than zero.", MESSAGE_TYPE_INFO);   
      return false;
   }
   if(Math::DoubleEquals(setVol, curVol))
      return false;
   /*if(setVol > curVol)
   {
      LogWriter("The new volume should be less than the current volume.", MESSAGE_TYPE_INFO);
      return false;
   }*/
   return true;
}