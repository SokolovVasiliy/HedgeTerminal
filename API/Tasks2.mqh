#include "Tasks.mqh"
#include "Targets.mqh"
#include <Arrays\List.mqh>
/*
  Task2 - включает совокупность задач и определяет их алгоритм исполнения.
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
///
/// Task2 - содержит список подзадач и алгоритм их выполнения.
///
class Task2 : CObject
{
   public:
      void Execute()
      {
         if(!isContinue && targets.Total())
         {
            currTarget = targets.GetFirstNode();
            isContinue = true;
            //Раз проваленую задачу больше не исполняем.
            if(status == TASK_STATUS_FAILED)
            {
               return;
               TaskChanged();
            }
         }
         while(targets.Total())
         {
            Target* target = CurrentTarget();
            if(target.Status() == TARGET_STATUS_EXECUTING)
               return;
            if(target.Status() == TARGET_STATUS_COMLETE)
            {
               //Все задания закончились.
               if(targets.GetNextNode() == NULL)
               {
                  TaskChanged();
                  return;
               }
               //Приступаем к выполнению следущего задания.
               else continue;
            }
            //Если нет, то выполняем задание если возможно.
            else if(target.Status() == TARGET_STATUS_WAITING)
            {
               bool res = target.Execute();
               if(!res)
               {
                  OnCrashed();
                  TaskChanged();
                  continue;
               }
               //Ушли на выполнение.
               else
               {
                  TaskChanged();
                  return;
               }
            }
            else if(target.Status() == TARGET_STATUS_FAILED)
            {
               //Сценарий восстановления задается потомком.
               OnCrashed();
               TaskChanged();
            }
         }
      }
      
      ///
      /// Перенаправляем события на текущее подзадание.
      ///
      virtual void Event(Event* event)
      {
         if(currTarget != NULL)
         {
            //Запоминаем состояние подзадачи.
            ENUM_TARGET_STATUS
               targetStatus = currTarget.Status();
            currTarget.Event(event);
            //Состояние изменилось? - выполняем алгоритм.
            if(currTarget.Status() != targetStatus)
            {
               Execute();
            }
         }
      }
      
      ///
      /// Статус задания.
      ///
      ENUM_TASK_STATUS Status(){return status;}
      ///
      /// Истина, если текущая задача находится в стадии выполнения и ложь в противном случае.
      ///
      bool IsActive()
      {
         if(status == TASK_QUEUED || status == TASK_EXECUTING)
            return true;
         return false;
      }
      ///
      /// Истина, если текущее задание завершено и ложь в противном случае.
      ///
      bool IsFinished()
      {
         if(status == TASK_STATUS_COMPLETE || status == TASK_STATUS_FAILED)
            return true;
         return false;
      }
   protected:
      ///
      /// Содержит сценарий действия в случае сбоя подзадачи.
      ///
      virtual void OnCrashed(){}
      ///
      /// Уведомляет связанную с заданием позицию, что состояние задания было измененно.
      ///
      virtual void TaskChanged()
      {
         if(currTarget.Status() == TARGET_STATUS_COMLETE &&
            currTarget.Next() == NULL)
            status = TASK_STATUS_COMPLETE;
         else if(currTarget.Status() == TARGET_STATUS_WAITING)
            status = TASK_STATUS_WAITING;
         else if(currTarget.Status() == TARGET_STATUS_EXECUTING)
            status = TASK_STATUS_EXECUTING;
         else if(currTarget.Status() == TARGET_STATUS_FAILED)
            status = TASK_STATUS_FAILED;
         if(position != NULL)
            position.TaskChanged();
      }
      
      Task2()
      {
         api.AddTask(GetPointer(this));
      }
      
      Task2(Position* pos)
      {
         position = pos;
         api.AddTask(GetPointer(this));
      }
      ///
      /// Добавляет новое задание в конец списка подзаданий.
      ///
      void AddTarget(Target* target)
      {
         targets.Add(target);
      }
      ///
      /// Очищает список подзаданий.
      ///
      void ClearTargets()
      {
         targets.Clear();
      }
      ///
      /// Передвигает указатель текущего задания к следущему по списку заданию.
      ///
      void NextTarget()
      {
         currTarget = targets.GetNextNode();
      }
      ///
      /// Возвращает текущее подзадание.
      ///
      Target* CurrentTarget()
      {
         currTarget = targets.GetCurrentNode();
         return currTarget;
      }
      ///
      /// Статус всего задания.
      ///
      ENUM_TASK_STATUS status;
      ///
      /// Позиция, для которой будет выполняться задача.
      ///
      Position* position;
   private:
      ///
      /// Список подзаданий, который необходимо выполнить.
      ///
      CList targets;
      ///
      /// Указатель на текущую подзадачу, которая выполняется в данный момент.
      ///
      Target* currTarget;
      ///
      /// 
      ///
      bool isContinue;
};

///
/// Удаляет стоп-лосс позиции.
///
class TaskDeleteStopLoss : public Task2
{
   public:
      TaskDeleteStopLoss(Position* pos, bool asynch_mode) : Task2(pos)
      {
         ulong stopId = 0;
         Order* stopOrder;
         if(pos.UsingStopLoss())
         {
            stopOrder = pos.StopOrder();
            stopId = stopOrder.GetId();
         }
         AddTarget(new TargetDeletePendingOrder(stopId, asynch_mode));
      }  
};

class TaskSetStopLoss : Task2
{
   public:
      TaskSetStopLoss(Position* pos, double price, bool asynch_mode) : Task2(pos)
      {
         if(pos.UsingStopLoss())
         {
            LogWriter("Position already using stop-order. Delete old stop-order and set new.", MESSAGE_TYPE_ERROR);
            status = TASK_STATUS_FAILED;
            return;
         }
         if(pos.Status() != POSITION_ACTIVE)
         {
            LogWriter("Position not active. Execute task not posiible.", MESSAGE_TYPE_ERROR);
            status = TASK_STATUS_FAILED;
            return;
         }
         ENUM_ORDER_TYPE orderType;
         if(pos.Direction() == DIRECTION_LONG)
            orderType = ORDER_TYPE_SELL_STOP;
         if(pos.Direction() == DIRECTION_SHORT)
            orderType = ORDER_TYPE_BUY_STOP;
         Order* initOrder = pos.EntryOrder();
         ulong magic = initOrder.GetMagic(MAGIC_TYPE_SL);
         AddTarget(new TargetSetPendingOrder(pos.Symbol(), orderType, pos.VolumeExecuted(), price, pos.ExitComment(), magic, true));
      }
};