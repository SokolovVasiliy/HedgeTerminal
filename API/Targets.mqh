#include "TaskLog.mqh"
#include "Transaction.mqh"
#include "Methods.mqh"
#include "Order.mqh"
#include "MqlTransactions.mqh"

///
/// Статус выполнения подзадачи (таргета).
///
enum ENUM_TARGET_STATUS
{
   ///
   /// Подзадача находится в режиме ожидания и готова к выполнению.
   ///
   TARGET_STATUS_WAITING,
   ///
   /// Подзадача находится в процессе выполнения. Ожидает поступления новых событий.
   ///
   TARGET_STATUS_EXECUTING,
   ///
   /// Подзадача выполнена успешно.
   ///
   TARGET_STATUS_COMLETE,
   ///
   /// Выполнение подзадачи завершилось неудачей. 
   ///
   TARGET_STATUS_FAILED,
};

///
/// Таргет - абстрактная подзадача. Подзадача - это параметризированный метод со статусом выполнения. 
///
class Target : public CObject
{
   public:
      bool Execute()
      {
         //if(status != TARGET_STATUS_WAITING)
         //   LogWriter(EnumToString(type) + ": State target (" + EnumToString(status) + ") not support executing.", MESSAGE_TYPE_ERROR);
         bool res = OnExecute();
         attempsMade++;
         return res;
      }
      ///
      /// Истина, если текущее задание завершено неудачей.
      ///
      bool IsFailed()
      {
         if(status == TARGET_STATUS_FAILED)
            return true;
         return false;
      }
      ///
      /// Возвращает истину, если состояние объекта соответствует цели действия.
      /// Например, если требуется удалить стоп-лосс ордер у позиции, а позиция уже
      /// не имеет стоп-лосс ордер, IsSuccess вернет истину.
      ///
      virtual bool IsSuccess()
      {
         return true;
      }
      ///
      /// Возвращает идентификатор подзадания.
      ///
      ENUM_TARGET_TYPE TargetType(void){return type;}
      ///
      /// Возвращает статус таргета.
      ///
      ENUM_TARGET_STATUS Status()
      {
         return status;
      }
      ///
      /// Подзадачу можно подписать на торговые события. Какие именно события обрабатывать - определяет конкретная подзадача.
      ///
      virtual void Event(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REFRESH:
               Timeout();
               break;
            default:
               OnEvent(event);
               break;
         }
      }
      
      ///
      /// Истина, если время дающиеся на завершение операции завершено и ложь и в противном случае.
      ///
      bool Timeout()
      {
         if(timeBegin <= 0)return false;
         if((TimeCurrent() - timeBegin) > timeoutSec)
         {
            status = TARGET_STATUS_FAILED;
            AddTaskLog(TRADE_RETCODE_TIMEOUT);
            return true;
         }
         return false;
      }
      ///
      /// Устанавливает ссылку на лог задания, куда необходимо записывать результат операций.
      ///
      void SetTaskLog(TaskLog* task)
      {
         taskLog = task;
      }
   protected:
      Target(ENUM_TARGET_TYPE target_type)
      {
         attempsAll = 1;
         type = target_type;
         //По-умолчанию выделяется три минуты на выполнение.
         timeoutSec = 3*60;
      }
      ///
      /// Добавляет результат операции в лог.
      ///
      void AddTaskLog(uint retcode)
      {
         if(CheckPointer(taskLog) == POINTER_INVALID)
            return;
         taskLog.AddRedcode(type, retcode);
      }
      ///
      ///
      ///
      virtual bool OnExecute(){return true;}
      ///
      ///
      ///
      virtual void OnEvent(Event* event){;}
      ///
      /// Статус таргета.
      ///
      ENUM_TARGET_STATUS status;
   private:
      ///
      /// Идентификатор события.
      ///
      ENUM_TARGET_TYPE type;
      ///
      /// Содержит количество совершенных попыток.
      ///
      int attempsMade;
      ///
      /// Содержит количество разрешенных попыток.
      ///
      int attempsAll;
      ///
      /// Время начала выполнения операции.
      ///
      datetime timeBegin;
      ///
      /// Время в секундах, которое дается на выполнение подзадачи.
      ///
      int timeoutSec;
      ///
      /// Ссылка на лог заданий.
      ///
      TaskLog* taskLog;
};

///
/// Задача - удалить отложенный ордер.
///
class TargetDeletePendingOrder : public Target
{
   public:
      TargetDeletePendingOrder(ulong order_id, bool asynch_mode) : Target(TARGET_DELETE_PENDING_ORDER)
      {
         method = new MethodDeletePendingOrder(order_id, asynch_mode);
      }
      ~TargetDeletePendingOrder()
      {
         delete method;
      }
      
   private:
      ///
      /// Удаляет отложенный ордер.
      ///
      virtual bool OnExecute()
      {
         bool res = false;
         if(!IsSuccess())
            res = method.Execute();
         if(res)
            status = TARGET_STATUS_EXECUTING;
         else
            status = TARGET_STATUS_FAILED;
         AddTaskLog(method.Retcode());
         return res;
      }
      ///
      /// Истина, если отложенного ордера с order_id не существует, и ложь в противном случае.
      ///
      virtual bool IsSuccess()
      {
         if(OrderSelect(method.OrderId()))
            return false;
         return true;
      }
      
      ///
      /// Ждем подтверждения об удалении либо отмене операции.
      ///
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
               break;
            case EVENT_ORDER_CANCEL:
               OnOrderCancel(event);
               break;
         }
      }
      ///
      /// Обрабатываем событие.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeRequest* request = event.GetRequest();
         if(request.order != method.OrderId())
            return;
         TradeResult* result = event.GetResult();
         //Запрос был отвергнут - подзадача завершена неудачно.
         if(result.IsRejected())
         {
            status = TARGET_STATUS_FAILED;
            AddTaskLog(result.retcode);
         }
      }
      
      ///
      /// Если отложенный ордер переместился в историю - задание выполненно.
      ///
      void OnOrderCancel(EventOrderCancel* event)
      {
         Order* order = event.Order();
         if(order.GetId() == method.OrderId())
         {
            status = TARGET_STATUS_COMLETE;
            AddTaskLog(TRADE_RETCODE_DONE);
         }
      }
      ///
      /// Метод удаления ордера.
      ///
      MethodDeletePendingOrder* method;
};

///
/// Установка отложенного ордера.
///
class TargetSetPendingOrder : public Target
{
   public:
      TargetSetPendingOrder(string symbol, ENUM_ORDER_TYPE orderType, double volume,
                           double price, string comment, ulong magic, bool asynchMode) :
      Target(TARGET_SET_PENDING_ORDER)
      {
         pendingOrder = new MethodSetPendingOrder(symbol, orderType, volume, price, comment, magic, asynchMode);
      }
      ~TargetSetPendingOrder()
      {
         delete pendingOrder;
      }
   private:
      ///
      /// Истина, если отложенный ордер с заданными параметрами существует и ложь в противном случае.
      ///
      virtual bool IsSuccess()
      {
         bool res = false;
         for(int i = 0; i < OrdersTotal(); i++)
         {
            ulong ticket = OrderGetTicket(i);
            if(!OrderSelect(ticket))continue;
            if(OrderGetInteger(ORDER_MAGIC) != pendingOrder.Magic())continue;
            if(OrderGetInteger(ORDER_TYPE) != pendingOrder.OrderType())continue;
            if(OrderGetString(ORDER_SYMBOL) != pendingOrder.Symbol())continue;
            res = true;
            break;
         }
         return res;
      }
      ///
      /// Удаляет отложенный ордер.
      ///
      virtual bool OnExecute()
      {
         bool res = false;
         if(IsSuccess())
         {
            status = TARGET_STATUS_COMLETE;
            AddTaskLog(TRADE_RETCODE_NO_CHANGES);
            return true;
         }
         else
            res = pendingOrder.Execute();
         if(res)
            status = TARGET_STATUS_EXECUTING;
         else
            status = TARGET_STATUS_FAILED;
         AddTaskLog(pendingOrder.Retcode());
         return res;
      }
      ///
      /// Ждем подтверждения об удалении либо отмене операции.
      ///
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
               break;
            case EVENT_ORDER_PENDING:
               OnOrderPending(event);
               break;
         }
      }
      ///
      /// Обрабатываем событие.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeRequest* request = event.GetRequest();
         if(request.magic != pendingOrder.Magic())
            return;
         TradeResult* result = event.GetResult();
         //Запрос был отвергнут - подзадача завершена неудачно.
         if(result.IsRejected())
         {
            status = TARGET_STATUS_FAILED;
            AddTaskLog(result.retcode);
         }
      }
      
      ///
      /// Обрабатываем поступившие отложенные ордера.
      ///
      void OnOrderPending(EventOrderPending* event)
      {
         Order* order = event.Order();
         if(order.Magic() == pendingOrder.Magic())
         {
            status = TARGET_STATUS_COMLETE;
            AddTaskLog(TRADE_RETCODE_DONE);
         }
      }
      ///
      /// Метод устанавливающий отложенный ордер.
      ///
      MethodSetPendingOrder* pendingOrder;
};

class TargetModifyPendingOrder : Target
{
   public:
      TargetModifyPendingOrder(ulong orderId, double newPrice, bool asynchMode) : Target(TARGET_MODIFY_PENDING_ORDER)
      {
         orderModify = new MethodModifyPendingOrder(orderId, newPrice, asynchMode);
      }
      ~TargetModifyPendingOrder()
      {
         delete orderModify;
      }
      virtual bool IsSuccess()
      {
         if(!OrderSelect(orderModify.OrderId()))return false;
         //Новая цена должна отличаться от цены отложенного ордера
         double curPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         if(!Math::DoubleEquals(curPrice, orderModify.NewPrice()))
            return false;
         return true;
      }
   private:
      ///
      /// Удаляет отложенный ордер.
      ///
      virtual bool OnExecute()
      {
         bool res = false;
         if(IsSuccess())
         {
            status = TARGET_STATUS_COMLETE;
            AddTaskLog(TRADE_RETCODE_NO_CHANGES);
            return true;
         }
         else
            res = orderModify.Execute();
         if(res)
            status = TARGET_STATUS_EXECUTING;
         else
            status = TARGET_STATUS_FAILED;
         AddTaskLog(orderModify.Retcode());
         return res;
      }
      ///
      /// Ждем подтверждения об удалении либо отмене операции.
      ///
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
               break;
         }
      }
      ///
      /// Обрабатываем событие.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeTransaction* trans = event.GetTransaction();
         TradeRequest* request = event.GetRequest();
         TradeResult* result = event.GetResult();
         switch(trans.type)
         {
            case TRADE_TRANSACTION_REQUEST:
               OnRequest(request, result);
               break;
            case TRADE_TRANSACTION_ORDER_UPDATE:
               OnUpdate(trans);
               break;
         }
      }
      ///
      /// Обрабатывает изменение ордера.
      ///
      void OnUpdate(TradeTransaction* trans)
      {
         if(trans.order != orderModify.OrderId())
            return;
         status = TARGET_STATUS_COMLETE;
         AddTaskLog(TRADE_RETCODE_DONE);
      }
      ///
      /// Обрабатывает ответ торгового сервера на запрос.
      ///
      void OnRequest(TradeRequest* request, TradeResult* result)
      {
         if(request.order != orderModify.OrderId())
            return;
         if(result.IsRejected())
         {
            status = TARGET_STATUS_FAILED;
            AddTaskLog(TRADE_RETCODE_DONE);
         }
      }
      ///
      /// Метод модификации отложенного ордера.
      ///
      MethodModifyPendingOrder* orderModify;
};

///
/// Совершает рыночные сделки.
///
class TargetTradeByMarket : Target
{
   public:
      TargetTradeByMarket(string symbol, ENUM_DIRECTION_TYPE dir, double vol, string comment, ulong magic, bool asynchMode) :
      Target(TARGET_TRADE_BY_MARKET)
      {
         tradeMarket = new MethodTradeByMarket(symbol, dir, vol, comment, magic, asynchMode);
      }
      ~TargetTradeByMarket()
      {
         delete tradeMarket;
      }
      virtual bool IsSuccess()
      {
         if(status != TARGET_STATUS_COMLETE)
            return false;
         return true;
      }
   private:
      virtual bool OnExecute()
      {
         bool res = false;
         if(status == TARGET_STATUS_WAITING)
            res = tradeMarket.Execute();
         else
            return false;
         if(res)
            status = TARGET_STATUS_EXECUTING;
         else
            status = TARGET_STATUS_FAILED;
         AddTaskLog(tradeMarket.Retcode());
         return res;
      }
      
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
               break;
            case EVENT_ORDER_EXE:
               OnOrderExe(event);
               break;
         }
      }
      ///
      /// Обрабатываем событие.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeResult* result = event.GetResult();
         TradeTransaction* trans = event.GetTransaction();
         TradeRequest* request = event.GetRequest();
         
         if(trans.type == TRADE_TRANSACTION_REQUEST &&
            result.request_id == tradeMarket.RequestId())
         {
            if(result.IsRejected())
            {
               status = TARGET_STATUS_FAILED;
               AddTaskLog(result.retcode);
            }
            else
               orderId = request.order;
         }
      }
      ///
      /// Обрабатываем срабатывания нового ордера.
      ///
      void OnOrderExe(EventOrderExe* event)
      {
         Order* order = event.Order();
         //Можно повсякому идентифицировать исполнение ордера.
         if(orderId != 0 && order.GetId() == orderId)
            status = TARGET_STATUS_COMLETE;
         else if(tradeMarket.Magic() == order.Magic())
            status = TARGET_STATUS_COMLETE;
         if(status == TARGET_STATUS_COMLETE)
            AddTaskLog(TRADE_RETCODE_DONE);
      }
      MethodTradeByMarket* tradeMarket;
      ///
      /// Идентификатор транзакции.
      ///
      ulong requestId;
      ///
      /// Идентификатор нового ордера.
      ///
      ulong orderId;
};