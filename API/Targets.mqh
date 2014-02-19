#include "Tasks2.mqh"
/*
  Target - включает совокупность задач и определяет их алгоритм исполнения.
  Также включает объект, над которым будут выполнены эти задачи.
  Успешное выполнение всех задач, включенных в таргет, изменяет состояние объекта
  с первоначального на желаемое, конечное состояние. Таким образом цель таргета будет достигнута.
  Любой таргет должен содержать как минимум три части:
  1. Список задач (может состоять из одной задачи).
  2. Объект, к которому будут применяться задачи
  3. Последовательность действий исполнения задач.
  4. Итоговую цель.
 */
 
///
/// Статус цели.
///
enum ENUM_TARGET_STATUS
{
   ///
   /// Цель может выполнятся.
   ///
   TARGET_STATUS_MAKE,
   ///
   /// Выполнения цели завершилось неудачей.
   ///
   TARGET_STATUS_FAILED,
   ///
   /// Цель успешно достигнута.
   ///
   TARGET_STATUS_COMPLETE
};

///
///
/// Target - конечная цель совокупности операций.
///
class Target
{
   public:
      bool Execute()
      {
         return OnExecute();
      }
      ///
      /// Цель можно подписать на торговые события. Какие именно события обрабатывать - определяет потомок.
      ///
      virtual void Event(Event* event){;}
      
      ENUM_TARGET_STATUS Status(){return status;}
      ///
      /// Возвращает истину, если последняя операция была выполнена успешно и ложь
      /// в противном случае.
      ///
      virtual bool SuccessLastOp(){return false;}
   protected:
      virtual bool OnExecute()
      {
         return false;
      }
      Target(){;}
      Target(Position* pos)
      {
         position = pos;
      }
      ENUM_TARGET_STATUS status;
      ///
      /// Позиция, для которой будут выполняться задачи.
      ///
      Position* position;
};

///
/// Удаляет стоп-лосс позиции.
///
class TargetDeleteStopLoss : public Target
{
   public:
      TargetDeleteStopLoss(Position* pos, bool asynch_mode) : Target(pos){;}
      ~TargetDeleteStopLoss()
      {
         if(CheckPointer(task) != POINTER_INVALID)
            delete task;
      }
   private:
      virtual bool OnExecute()
      {
         // Если позиция не использует стоп-лосс - цель таргета достигнута.
         if(CheckDeletePendingOrder())
         {
            status = TARGET_STATUS_COMPLETE;
            return true;
         }
         if(task == NULL)
         {
            Order* slOrder = position.StopOrder();
            orderId = slOrder.GetId();
            task = new TaskDeletePendingOrder(orderId, true);
         }
         if(!task.IsPerform())
         {
            status = TARGET_STATUS_FAILED;
            return false;
         }
         return task.Execute();
      }
      
      virtual bool SuccessLastOp()
      {
         switch(lastTask)
         {
            case TASK_DELETE_PENDING_ORDER:
               return CheckDeletePendingOrder();
         }
         return false;
      }
      ///
      /// Истина, если позиция не использует стоп-ордер и ложь в противном случае.
      ///
      bool CheckDeletePendingOrder()
      {
         if(position.UsingStopLoss())
            return false;
         else
            return true;
      }
      
      virtual void Event(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
               break;
            case EVENT_CHANGE_POS:
               OnChangePos(event);
               break;
         }
      }
      ///
      /// Обрабатывает изменение ордера.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeRequest* request = event.GetRequest();
         if(request.order != orderId)return;
         TradeResult* result = event.GetResult();
         //Запрос на удаление ордера был отвергнут?
         if(result.IsRejected())
         {
            status = TARGET_STATUS_FAILED;
            //position.
         }
      }
      void OnChangePos(EventPositionChanged* event)
      {
         
      }
      
      TaskDeletePendingOrder * task;
      ///
      /// Флаг, указывающий на использование асинхронного режима.
      ///
      bool asynchMode;
      ///
      /// Идентификатор последней задачи, которая была запущена на выполнение.
      ///
      ENUM_TASK_TYPE lastTask;
      ///
      /// Идентификатор ордера, который необходимо удалить.
      ///
      ulong orderId;
      
};