#include "Targets.mqh"
#include <Arrays\List.mqh>
#include <Arrays\ArrayInt.mqh>
///
/// Содержит текущий статус выполнения задания.
///
enum ENUM_TASK_STATUS
{
   ///
   /// Задание в режиме ожидания.
   ///
   TASK_STATUS_WAITING,
   ///
   /// Задание в процессе выполнения.
   ///
   TASK_STATUS_EXECUTING,
   ///
   /// Задание успешно завершено.
   ///
   TASK_STATUS_COMPLETE,
   ///
   /// Задание провалилось.
   ///
   TASK_STATUS_FAILED
};

enum ENUM_LAST_OPERATION_STATUS
{
   //DELETE_STOP_LOSS
};
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
         if(targets.Total() == 0)
         {
            TaskChanged();
            return;
         }
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
               retcodes.Add(target.Retcode());
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
               retcodes.Add(target.Retcode());
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
         if(status == TASK_STATUS_WAITING || status == TASK_STATUS_EXECUTING)
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
      ///
      /// Возвращает указатель на позицию, которая ассоциирована с данным заданием.
      /// Существование позиции не гарантируется.
      ///
      Position* GetPosition(){return position;}
   protected:
      ///
      /// Последовательность кодов результатов выполнения операций.
      ///
      CArrayInt retcodes;
      ///
      /// Содержит сценарий действия в случае сбоя подзадачи.
      ///
      virtual void OnCrashed(){}
      ///
      /// Уведомляет связанную с заданием позицию, что состояние задания было измененно.
      ///
      virtual void TaskChanged()
      {
         if(CheckPointer(currTarget) != POINTER_INVALID)
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
         }
         if(CheckPointer(position) != POINTER_INVALID)
            position.TaskChanged();
      }
      
      Task2()
      {
         HedgeManager* hm = EventExchange::GetAPI();
         hm.AddTask(GetPointer(this));
      }
      
      Task2(Position* pos)
      {
         position = pos;
         HedgeManager* hm = EventExchange::GetAPI();
         hm.AddTask(GetPointer(this));
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
///
/// Удаляет стоп-лосс позиции.
///
class TaskChangeCommentStopLoss : public Task2
{
   public:
      TaskChangeCommentStopLoss(Position* pos, bool asynch_mode) : Task2(pos)
      {
         ulong stopId = 0;
         Order* stopOrder;
         if(pos.UsingStopLoss())
         {
            stopOrder = pos.StopOrder();
            stopId = stopOrder.GetId();
         }
         else
         {
            LogWriter("Position not use stop-order.", MESSAGE_TYPE_ERROR);
            status = TASK_STATUS_FAILED;
            return;
         }
         double price = stopOrder.PriceSetup();
         AddTarget(new TargetDeletePendingOrder(stopId, asynch_mode));
         ENUM_ORDER_TYPE orderType = ORDER_TYPE_SELL;
         if(pos.Direction() == DIRECTION_LONG)
            orderType = ORDER_TYPE_SELL_STOP;
         if(pos.Direction() == DIRECTION_SHORT)
            orderType = ORDER_TYPE_BUY_STOP;
         Order* initOrder = pos.EntryOrder();
         ulong magic = initOrder.GetMagic(MAGIC_TYPE_SL);
         AddTarget(new TargetSetPendingOrder(pos.Symbol(), orderType, pos.VolumeExecuted(), price, pos.ExitComment(), magic, true));
      }  
      private:
         string oldComment;
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
         ENUM_ORDER_TYPE orderType = ORDER_TYPE_SELL;
         if(pos.Direction() == DIRECTION_LONG)
            orderType = ORDER_TYPE_SELL_STOP;
         if(pos.Direction() == DIRECTION_SHORT)
            orderType = ORDER_TYPE_BUY_STOP;
         Order* initOrder = pos.EntryOrder();
         ulong magic = initOrder.GetMagic(MAGIC_TYPE_SL);
         AddTarget(new TargetSetPendingOrder(pos.Symbol(), orderType, pos.VolumeExecuted(), price, pos.ExitComment(), magic, true));
      }
};

///
/// Модифицирует уровень нового стоп-лосса.
///
class TaskModifyStop : Task2
{
   public:
      TaskModifyStop(Position* pos, double newPrice, bool asynchMode) : Task2(pos)
      {
         ulong stopId = 0;
         Order* stopOrder;
         if(pos.UsingStopLoss())
         {
            stopOrder = pos.StopOrder();
            stopId = stopOrder.GetId();
         }
         AddTarget(new TargetModifyPendingOrder(stopId, newPrice, asynchMode));
      }
};

///
/// Закрывает активную позицию.
///
class TaskClosePosition : Task2
{
   public:
      TaskClosePosition(Position* pos, ENUM_MAGIC_TYPE type) : Task2(pos)
      {
         ENUM_DIRECTION_TYPE dir = pos.Direction() == DIRECTION_LONG ? DIRECTION_SHORT: DIRECTION_LONG;
         Order* initOrder = pos.EntryOrder();
         ulong magic = initOrder.GetMagic(type);
         AddTarget(new TargetTradeByMarket(pos.Symbol(), dir, pos.VolumeExecuted(), pos.ExitComment(), magic, true));
         if(pos.UsingStopLoss())
         {
            Order* slOrder = pos.StopOrder();
            AddTarget(new TargetDeletePendingOrder(slOrder.GetId(), true));
         }
      }
};

///
/// Закрывает часть активной позиции.
///
class TaskClosePartPosition : Task2
{
   public:
      ///
      /// Формирует задачу по закрытию части активной позиции.
      /// \param pos - Позиция, часть объема которой требуется закрыть.
      /// \param volume - объем, который требуется закрыть.
      ///
      TaskClosePartPosition(Position* pos, double volume) : Task2(pos)
      {
         if(volume > pos.VolumeExecuted())
         {
            status = TASK_STATUS_FAILED;
            LogWriter("Incorrect volume.", MESSAGE_TYPE_ERROR);
            return;
         }
         Order* slOrder;
         if(pos.UsingStopLoss())
         {
            stopLevel = pos.StopLossLevel();
            slOrder = pos.StopOrder();
            AddTarget(new TargetDeletePendingOrder(slOrder.GetId(), true));
         }
         ENUM_DIRECTION_TYPE dir = pos.Direction() == DIRECTION_LONG ? DIRECTION_SHORT: DIRECTION_LONG;
         Order* initOrder = pos.EntryOrder();
         ulong magic = initOrder.GetMagic(MAGIC_TYPE_MARKET);
         AddTarget(new TargetTradeByMarket(pos.Symbol(), dir, volume, pos.ExitComment(), magic, true));
         if(pos.UsingStopLoss())
         {
            ENUM_ORDER_TYPE type = pos.Direction() == DIRECTION_LONG ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_BUY_STOP;
            magic = initOrder.GetMagic(MAGIC_TYPE_SL);
            double nVol = pos.VolumeExecuted() - volume;
            AddTarget(new TargetSetPendingOrder(pos.Symbol(), type, nVol, stopLevel, slOrder.Comment(),  magic, true));
         }
      }
   private:
      ///
      /// Запомненный уровень стоп-лосса.
      ///
      double stopLevel;
};