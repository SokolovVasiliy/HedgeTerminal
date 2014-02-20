#include "Transaction.mqh"
#include "Methods.mqh"

///
/// Идентификаторы таргетов
///
enum ENUM_TARGET_TYPE
{
   ///
   /// Удаление отложенного ордера.
   ///
   TARGET_DELETE_PENDING_ORDER
};

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
class Target : CObject
{
   public:
      bool Execute()
      {
         if(status != TARGET_STATUS_WAITING)
            LogWriter(EnumToString(type) + ": State target (" + EnumToString(status) + ") not support executing.", MESSAGE_TYPE_ERROR);
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
      /// Истина, если операцию можно выполнить, ложь - в противном случае.
      ///
      /*bool IsPerform()
      {
         return attempsMade < attempsAll;
      }*/
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
            return true;
         }
         return false;
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
         return res;
      }
      ///
      /// Истина, если отложенного ордера с order_id не существует, и ложь в противном случае.
      ///
      virtual bool IsSuccess()
      {
         if(OrderSelect(method.OrderId()))
            return false;
         status = TARGET_STATUS_COMLETE;
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
            case EVENT_CHANGE_POS:
               OnPosChanged();
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
            status = TARGET_STATUS_FAILED;
      }
      ///
      /// Реагируем на изменение позиции.
      ///
      void OnPosChanged()
      {
         if(IsSuccess())
            status = TARGET_STATUS_COMLETE;
      }
      MethodDeletePendingOrder* method;
};
