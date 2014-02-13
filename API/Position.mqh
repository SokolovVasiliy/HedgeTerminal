#include "..\Math.mqh"
#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"
#include "..\Events.mqh"
#include "Tasks.mqh"
#include <Trade\SymbolInfo.mqh>
 
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
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
      static void ExchangerOrder(ExchangerList& list);
      bool Merge(Position* pos);
      Order* EntryOrder(){return initOrder;}
      Order* ExitOrder(){return closingOrder;}
      Order* StopOrder(){return slOrder;}
      bool Compatible(Position* pos);
      virtual int Compare(const CObject* node, const int mode=0);
      void OrderChanged(Order* order);
      void Refresh();
      bool AsynchClose(double vol, string comment = NULL);
      virtual string TypeAsString(void);
      virtual ENUM_DIRECTION_TYPE Direction(void);
      bool IsBlocked();
      void NoticeModify(void);
      void Event(Event* event);
      void SendEventChangedPos(ENUM_POSITION_CHANGED_TYPE type);
      void Unmanagment(bool isUnmng);
      bool Unmanagment(void);
      bool StopLossModify(double newLevel, string comment, bool asynchMode = true);
      bool CheckValidLevelSL(double newLevel);
      bool VirtualStopLoss(){return isVirtualStopLoss;}
      void AddTask(Task* task);
      Order* FindOrderById(ulong id);
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
         /// Ордер защитной остановки.
         ///
         CHANGED_ORDER_SL,
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
      /// Содержит статус, показывающий, является ли эта позиция управляемой.
      ///
      bool unmanagment;
      ///
      /// Содержит список тикетов ордеров принадлежащих текущей позиции, которые находятся в процессе обработки.
      ///
      //CArrayLong processingOrders;
      ENUM_CHANGED_ORDER DetectChangedOrder(Order* order);
      void ChangedInitOrder();
      void AddCanceledOrder(Order* order);
      void DeleteAllOrders();
      Position* OrderManager(Order* openOrder, Order* cloingOrder);
      bool CompatibleForInit(Order* order);
      bool CompatibleForClose(Order* order);
      InfoIntegration* AddClosingOrder(Order* outOrder);
      void AddInitialOrder(Order* inOrder);
      void AddNewStopLossOrder(Order* order);
      POSITION_STATUS CheckStatus(void);
      void ResetBlocked(void);
      void SetBlock(void);
      void OnRequestNotice(EventRequestNotice* notice);
      void OnRejected(TradeResult& result);
      void OnUpdate(ulong OrderId);
      void ExecutingTask(void);
      void TaskCollector(void);
      ///
      /// Инициирующий позицию ордер.
      ///
      Order* initOrder;
      ///
      /// Закрывающий ордер позицию.
      ///
      Order* closingOrder;
      ///
      /// Стоп-лосс ордер, который связан с текущей позицией.
      ///
      Order* slOrder;
      ///
      /// Виртуальный уровень стоп-лосс ордера.
      ///
      double slLevel;
      ///
      /// Флаг, указывающий, является ли текущий стоп-лосс ордер виртуальным.
      ///
      bool isVirtualStopLoss;
      POSITION_STATUS status;
      void SendEventBlockStatus(bool status);
      #ifdef HEDGE_PANEL
         PosLine* positionLine;
      #endif
      CSymbolInfo infoSymbol;
      ///
      /// Текущее задание которое необходимо выполнить.
      ///
      Task* task;
      ///
      /// Флаг указывающий, что текущее задание имеет ограничение по времени.
      ///
      bool usingTimeOut;
};
///
/// Деинициализирует позицию.
///
Position::~Position()
{
   DeleteAllOrders();
   if(task != NULL)
      delete task;
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
   Refresh();
   order = pos.ExitOrder();
   if(order == NULL)
      return true;
   while(order.DealsTotal())
   {
      Deal* ndeal = new Deal(order.DealAt(0));
      closingOrder.AddDeal(ndeal);
      order.DeleteDealAt(0);
   }
   Refresh();
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
   if(order.IsStopLoss() && order.PositionId() == GetId() && (order.IsPending() || order.IsCanceled()))
   {
      AddNewStopLossOrder(order);
      return info;
   }
   if(CompatibleForInit(order))
   {
      AddInitialOrder(order);
      info = new InfoIntegration();
   }
   else if(CompatibleForClose(order))
   {
      info = AddClosingOrder(order);
   }
   else
   {
      info = new InfoIntegration();
      info.InfoMessage = "Proposed order #" + (string)order.GetId() +
      "can not be integrated in position #" + (string)GetId() +
      ". Position and order has not compatible types";
   }
   ResetBlocked();
   //Запрос обработан, продолжаем выполнять задания.
   ExecutingTask();
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
   if(order.PositionId() == GetId() &&
      order.Status() == ORDER_HISTORY)
      return true;
   return false;
}

void Position::AddNewStopLossOrder(Order *order)
{
   // Если ордер был отменен клиентом - запоминаем его стоп, в случаи текущей цены
   // лучше этого стопа.
   /*if(order.IsCanceled())
   {
      AddCanceledOrder(order);
      return;
   }*/
   //Если отложенный ордер еще существует, а позиция историческая -
   //необходимо удалить отложенный ордер.
   if(order.IsPending() && status == POSITION_HISTORY)
   {
      AddTask(new TaskModifyOrSetStopLoss(GetPointer(this), 0.0, "canceled by wrong magic"));
      delete order;
      return;
   }
   if(slOrder != NULL)
      delete slOrder;
   slOrder = order;
   slOrder.LinkWithPosition(GetPointer(this));
   ENUM_ORDER_STATUS st = slOrder.Status();
   ResetBlocked();
}

///
/// Добавляет отмененный стоп-тейк профит ордер в позицию если это возможно.
///
/*void Position::AddCanceledOrder(Order* order)
{
   
   if(Status() == POSITION_NULL)
   {
      delete order;
      return;
   }
   if(slOrder != NULL)
      delete slOrder;
   slOrder = order;
   bool goodStop = false;
   if(order.Direction() == DIRECTION_LONG)
      goodStop = order.PriceSetup() < ExitExecutedPrice();
   else
      goodStop = order.PriceSetup() > ExitExecutedPrice();
   if(goodStop)
   {
      if(slOrder != NULL)
         delete slOrder;
      slOrder = order;
   }
   else
      delete order;
   
}*/

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
   //Т.к. ордера заведомо одинаковы, то это означает что пришел новый трейд
   //инициирующего ордера и этот трейд надо включить в первоначальный ордер.
   else
   {
      for(int i = 0; i < inOrder.DealsTotal(); i++)
      {
         Deal* deal = inOrder.DealAt(i);
         initOrder.AddDeal(deal.Clone());
      }
      delete inOrder;
   }
}

///
/// Добавляте закрывающий ордер в актинвую позицию.
///
InfoIntegration* Position::AddClosingOrder(Order* outOrder)
{
   InfoIntegration* info = new InfoIntegration();
   double initVol = initOrder.VolumeExecuted();
   double outVol = outOrder.VolumeExecuted();
   ulong iT = initOrder.GetId();
   ulong oT = outOrder.GetId();
   info.HistoryPosition = OrderManager(initOrder, outOrder);
   outVol = outOrder.VolumeExecuted();
   int dT = outOrder.DealsTotal();
   if(outOrder.Status() != ORDER_NULL)
   {
      info.ActivePosition = new Position(outOrder);
      info.ActivePosition.Unmanagment(true);
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
   SendEventChangedPos(POSITION_REFRESH);
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
   //Неуправляемая позиция продолжает быть неуправляемой в историческом состоянии.
   if(unmanagment)
      histPos.Unmanagment(true);
   //Проверяем, нет ли к этому моменту отмененного стопа
   if(UsingStopLoss() && slOrder.IsCanceled())
      histPos.Integrate(new Order(slOrder));
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
   if(UsingStopLoss() && slOrder.GetId() == order.GetId())
      return CHANGED_ORDER_SL;
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
    Refresh();
}

///
/// Обрабатывает изменения инициирующего ордера.
///
void Position::ChangedInitOrder()
{
   if(initOrder.Status() == ORDER_EXECUTING)
      SetBlock();
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
   if(slOrder != NULL)
   {
      delete slOrder;
      slOrder = NULL;
   }
}

///
/// Закрывает текущую позицию либо ее часть асинхронно.
/// \param vol - объем, который необходимо закрыть.
/// \param comment - комментарий, который необходимо присвоить закрывающей сделке.
///
bool Position::AsynchClose(double vol, string comment = NULL)
{
   infoSymbol.Name(Symbol());
   vol = NormalizeDouble(vol, infoSymbol.Digits());
   if(IsBlocked())
   {
      printf("Position is blocked. Try letter");
      return false;
   }
   trading.SetAsyncMode(true);
   trading.SetExpertMagicNumber(initOrder.GetMagic(MAGIC_TYPE_MARKET));
   #ifndef DEBUG
      trading.LogLevel(0);
   #endif
   bool resTrans = false;
   if(Direction() == DIRECTION_LONG)
      resTrans = trading.Sell(vol, Symbol(), 0.0, 0.0, 0.0, comment);
   else if(Direction() == DIRECTION_SHORT)
      resTrans = trading.Buy(vol, Symbol(), 0.0, 0.0, 0.0, comment);
   if(resTrans)
   {
      SetBlock();
      //SetTask();
   }
   else
   {
      printf("Rejected current operation by reason: " + trading.ResultRetcodeDescription());
      ResetBlocked();
   }
   return resTrans;
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
   if(slOrder != NULL/* && slOrder.Status() != ORDER_HISTORY*/)
      return slOrder.PriceSetup();
   return slLevel;
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
   return CheckPointer(slOrder) != POINTER_INVALID;
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
   SendEventChangedPos(POSITION_REFRESH);
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
   TradeTransaction* trans = notice.GetTransaction();
   if(result.IsRejected())
      OnRejected(result);
   else if(trans.IsUpdate())
      OnUpdate(trans.order);
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
   ExecutingTask();
}

///
/// Обновляет изменившейся ордер.
/// \param OrderId - идентификатор ордера, который изменился.
///
void Position::OnUpdate(ulong OrderId)
{
   Order* changeOrder = FindOrderById(OrderId);
   if(changeOrder != NULL)
   {
      changeOrder.Refresh();
      ResetBlocked();
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

///
/// Уведомляет графическое представление позиции на панели о том,
/// что состояние позиции изменилось.
///
void Position::SendEventChangedPos(ENUM_POSITION_CHANGED_TYPE type)
{
   //Только для визуальной панели.
   #ifdef HEDGE_PANEL
      if(type != POSITION_SHOW && positionLine == NULL)
         return;
      EventPositionChanged* event = new EventPositionChanged(GetPointer(this), type);
      EventExchange::PushEvent(event);
      delete event;
   #endif
}

///
/// Устанавливает статус неуправляемой позиции.
///
void Position::Unmanagment(bool isUnmng)
{
   unmanagment = isUnmng;
}

///
/// Возвращает статус управляемости позиции.
///
bool Position::Unmanagment()
{
   return unmanagment;
}

///
/// Модифицирует текущий уровень стоп-лосса.
///
bool Position::StopLossModify(double newLevel, string comment=NULL, bool asynchMode = true)
{
   infoSymbol.Name(Symbol());
   newLevel = NormalizeDouble(newLevel, infoSymbol.Digits());
   bool res = false;
   trading.SetAsyncMode(asynchMode);
   SetBlock();
   //Неправильные уровни необрабатываем.
   if(!CheckValidLevelSL(newLevel))
   {
      ResetBlocked();
      return false;
   }
   //Приказ на удаление Stop-Loss ордера.
   if(Math::DoubleEquals(newLevel, 0.0))
   {
      if(slOrder != NULL)
         res = trading.OrderDelete(slOrder.GetId());
      else
      {
         slLevel = 0.0;
         ResetBlocked();
         return true;
      }
   }
   //Виртуальный ордер обрабатываем моментально.
   if(isVirtualStopLoss)
   {
      slLevel = newLevel;
      ResetBlocked();
      return true;
   }
   if(slOrder == NULL || slOrder.Status() == ORDER_HISTORY)
   {
      double vol = VolumeExecuted();
      //if(!CheckVolume(vol))
      ulong magic = initOrder.GetMagic(MAGIC_TYPE_SL);
      trading.SetExpertMagicNumber(initOrder.GetMagic(MAGIC_TYPE_SL));
      if(Direction() == DIRECTION_LONG)
         res = trading.SellStop(VolumeExecuted(), newLevel, Symbol(), 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
      else if(Direction() == DIRECTION_SHORT)
         res = trading.BuyStop(VolumeExecuted(), newLevel, Symbol(), 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
   }
   else
      res = trading.OrderModify(slOrder.GetId(), newLevel, 0.0, 0.0, ORDER_TIME_GTC, 0, 0);
   if(!res)
   {
      LogWriter("Failed to set or modify stop-loss order. Reason: " +
                 trading.ResultRetcodeDescription(), MESSAGE_TYPE_ERROR);
      ResetBlocked();
      
      return false;
   }
   return res;
}

///
/// Проверяет на правильность новый уровень стоп-лосса.
///
bool Position::CheckValidLevelSL(double newLevel)
{
   infoSymbol.Name(Symbol());
   infoSymbol.RefreshRates();
   if(newLevel < 0.0)
   {
      string msg = "Position #" + (string)GetId() + ": New Stop-Loss level must be bigger null.";
      LogWriter(msg, MESSAGE_TYPE_ERROR);
      return false;
   }
   if(Math::DoubleEquals(newLevel, 0.0))
      return true;
   if(Direction() == DIRECTION_LONG)
   {
      double last = infoSymbol.Last();
      if(infoSymbol.Last() < newLevel)
      {
         string msg = "Position #" + (string)GetId() + ": New stop-loss must be less current price.";
         LogWriter(msg, MESSAGE_TYPE_ERROR);
         return false;
      }
      /*if(newLevel >= (infoSymbol.Last() - infoSymbol.FreezeLevel()))
      {
         string msg = "Position #" + (string)GetId() + ": New stop-loss must be less level of freeze.";
         LogWriter(msg, MESSAGE_TYPE_ERROR);
         return false;
      }*/
   }
   if(Direction() == DIRECTION_SHORT)
   {
      double last = infoSymbol.Last();
      if(infoSymbol.Last() > newLevel)
      {
         string msg = "Position #" + (string)GetId() + ": New stop-loss must be bigger current price.";
         LogWriter(msg, MESSAGE_TYPE_ERROR);
         return false;
      }
      /*if(newLevel <= (infoSymbol.Last() + infoSymbol.FreezeLevel()))
      {
         string msg = "Position #" + (string)GetId() + ": New stop-loss must be bigger level of freeze.";
         LogWriter(msg, MESSAGE_TYPE_ERROR);
         return false;
      }*/
   }
   return true;
}

///
/// Добавляет новое задание в очередь заданий.
/// Добавленное задание будет существовать в списке заданий,
/// пока не будет выполенно или отменено позицией.
///
void Position::AddTask(Task *ctask)
{
   if(IsBlocked())
   {
      LogWriter("Position #" + (string)GetId() + " is blocked. Try letter.", MESSAGE_TYPE_ERROR);
      delete ctask;
      ctask = NULL;
   }
   //Старую задачу удаляем.
   if(CheckPointer(task) != POINTER_INVALID)
      delete task;
   task = ctask;
   task.Execute();
   Refresh();
}

///
/// Сборщик отработанных заданий.
///
void Position::TaskCollector(void)
{
   if(task == NULL)return;
   ENUM_TASK_STATUS status = task.Status();
   //Удаляем завершенные задачипо их завершению.
   if(status == TASK_COMPLETED_SUCCESS ||
      status == TASK_COMPLETED_FAILED)
      delete task;
   else if(task.TimeLastExecution() > 180000)
   {
      delete task;
      ResetBlocked();
   }
   else if(task.TimeLastExecution() == 0)
      task.Execute();
}

///
/// Выполняет задания из списка заданий.
///
void Position::ExecutingTask(void)
{
   if(task == NULL)return;
   //Отработанную задачу удаляем.
   if(task.Status() != TASK_COMPLETED_FAILED ||
      task.Status() != TASK_COMPLETED_SUCCESS)
   {
      delete task;
      task = NULL;
      return;
   }
   //Либо продолжаем выполнять.
   usingTimeOut = true;
   task.Execute();
}

///
/// Пытается найти один из ордеров позиции, чей идентификатор
/// равен указанному. Возвращает найденый ордер, либо NULL
/// в случае неудачи.
///
Order* Position::FindOrderById(ulong id)
{
   bool uSl = UsingStopLoss();
   ulong sId;
   if(uSl)
      sId = slOrder.GetId();
   if(Status() == POSITION_NULL)return NULL;
   if(initOrder.GetId() == id)return initOrder;
   if(UsingStopLoss() && slOrder.GetId() == id)return slOrder;
   //if(UsingTakeProfit() && tpOrder.GetId() == id)return tpOrder;
   return NULL;
}