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
            currTarget = targets.GetFirstNode();
         while(targets.Total())
         {
            Target* target = CurrentTarget();
            //Условия задания выполнены?
            if(target.IsSuccess())
            {
               //Все задания закончились.
               if(targets.GetNextNode() == NULL)
               {
                  status = TASK_STATUS_COMPLETE;
                  return;
               }
               //Приступаем к выполнению следущего задания.
               else continue;
            }
            //Если нет, то выполняем задание если возможно.
            else if(!target.IsFailed())
            {
               bool res = target.Execute();
               if(!res)
                  OnCrashed();
               //Ушли на выполнение.
               else
               {
                  status = TASK_EXECUTING;
                  TaskChanged();
                  return;
               }
            }
            //Сценарий восстановления задается потомком.
            OnCrashed();
         }
      }
      
      ///
      /// Перенаправляем события на текущее подзадание.
      ///
      virtual void Event(Event* event)
      {
         if(currTarget != NULL)
         {
            currTarget.Event(event);
            Execute();
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
         if(status == TASK_COMPLETED_SUCCESS || status == TASK_COMPLETED_FAILED)
            return true;
         return false;
      }
   protected:
      ///
      /// Содержит сценарий действия в случае сбоя подзадачи.
      ///
      virtual void OnCrashed()
      {
         //По-умолчанию переходим к следущему заданию.
         currTarget = targets.GetNextNode();
      }
      ///
      /// Уведомляет связанную с заданием позицию, что состояние задания было измененно.
      ///
      virtual void TaskChanged()
      {
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