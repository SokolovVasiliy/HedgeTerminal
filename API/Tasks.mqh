#include "Position.mqh"
#include "..\Math.mqh"
///
/// Содержит идентификаторы заданий, которые надо выполнить.
///
enum ENUM_TASK_TYPE
{
   ///
   /// Закрыть всю позицию.
   ///
   TASK_CLOSE_POSITION,
   ///
   /// Закрыть часть позиции.
   ///
   TASK_CLOSE_PART_POS,
   ///
   /// Удалить Stop-Loss.
   ///
   TASK_DELETE_STOP_LOSS,
   ///
   /// Модифицировать уровень Stop-Loss
   ///
   TASK_MODIFY_STOP_LOSS,
   ///
   /// Удалить Stop-Loss.
   ///
   TASK_DELETE_TAKE_PROFIT,
   ///
   /// Модифицировать уровень Stop-Loss
   ///
   TASK_MODIFY_TAKE_PROFIT,
};

///
/// Содержит текущий статус выполнения задания.
///
enum ENUM_TASK_STATUS
{
   ///
   /// Задание сформированно, но еще не начало выполняться.
   ///
   TASK_QUEUED,
   ///
   /// Задание находится в статусе выполнения.
   ///
   TASK_EXECUTING,
   ///
   /// Задание завершено
   ///
   TASK_COMPLETED_SUCCESS,
   ///
   /// Задание завершено неудачей.
   ///
   TASK_COMPLETED_FAILED
};

/* Примитивы */
///
/// Тип операции.
///
enum ENUM_OPERATION_TYPE
{
   ///
   /// Идентификатор операции "модификация стоп-лосса".
   ///
   OPERATION_SL_MODIFY,
   ///
   /// Идентификатор операции "Закрытия позиции".
   ///
   OPERATION_POSITION_CLOSE
};

///
/// Базовый класс примитивных операций.
///
class PrimitiveOP : public CObject
{
   public:
      ///
      /// Количество совершенных попыток.
      ///
      int AttempsMade(){return attempsMade;}
      ///
      /// Общее количество попыток для совершения операции, которое
      /// задается при создании операции.
      ///
      int AttempsAll(){return attempsAll;}
      ///
      /// Истина, если операцию можно выполнить, ложь - в противном случае.
      ///
      bool IsPerform()
      {
         return attempsMade < attempsAll;
      }
      ///
      /// Выполняет задание производного класса. 
      ///
      bool Execute()
      {
         return Script();
      }
      ///
      /// Возвращает истину, если состояние объекта соответствует цели действия.
      /// Например, если требуется удалить стоп-лосс ордер у позиции, а позиция уже
      /// не имеет стоп-лосс ордер IsSuccess вернет истину.
      ///
      virtual bool IsSuccess()
      {
         return true;
      }
   protected:
      PrimitiveOP()
      {
         attempsAll = 1;
      }
      ///
      /// Задает операцию с заданным количеством попыток.
      ///
      PrimitiveOP(int attemps)
      {
         attempsAll = attemps;
      }
      ///
      /// Производный класс определяет в этом методе конкретное задание,
      /// которое нужно выполнить.
      ///
      virtual bool Script()
      {
         return true;
      }
   private:
      ///
      /// Содержит количество совершенных попыток.
      ///
      int attempsMade;
      ///
      /// Содержит количество разрешенных попыток.
      ///
      int attempsAll;
};

///
/// Реализует закрытие позиции, либо ее части.
///
class ClosePosition : public PrimitiveOP
{
   public:
      ///
      /// Определяет закрытие всей позиции.
      ///
      ClosePosition(Position* cpos, string comm)
      {
         pos = cpos;
         comment = comm;
         volume = pos.VolumeExecuted();
      }
      ///
      /// Определяет закрытие части позиции с объемом vol
      ///
      ClosePosition(Position* cpos, double vol, string comm)
      {
         pos = cpos;
         comment = comm;
         volume = vol;
      }
   private:
      Position* pos;
      string comment;
      double volume;
      ///
      /// Реализует конкретный способ закрытия позиции.
      ///
      virtual bool Script()
      {
         return pos.AsynchClose(volume, comment);
      }
};

///
/// Реализует модификацию стоп-лосса.
///
class ModifyStopLoss : public PrimitiveOP
{
   public:
      ModifyStopLoss(Position* cpos, double slLevel, string comm)
      {
         pos = cpos;
         comment = comm;
         stopLevel = slLevel;
      }
   private:
      ///
      /// Реализует непосредственное создание/удаление/изменение стоп-лосса.
      ///
      virtual bool Script()
      {
         if(!pos.CheckValidLevelSL(stopLevel))return false;
         return pos.StopLossModify(stopLevel, comment);
      }
      
      Position* pos;
      string comment;
      double stopLevel;
};
///
/// Задачи.
///
class Task : CObject
{
   public:
      ///
      /// Команда на выполнение задания.
      ///
      virtual void Execute(void){;}
      ///
      /// Возвращает текущий статус задания.
      ///
      ENUM_TASK_STATUS Status(){return taskStatus;}
      ///
      /// Информационное сообщение.
      ///
      string Message(){return message;}
      ///
      /// Возвращает идентификатор задания.
      ///
      ENUM_TASK_TYPE TaskType(void){return type;}
   protected:
      Task(Position* pos, ENUM_TASK_TYPE taskType)
      {
         position = pos;
         type = taskType;
      }
      ///
      /// Возвращает позицию, к которой относится текущее задание.
      ///
      Position* TaskPosition(void){return position;}
      ///
      /// Статус задания.
      ///
      ENUM_TASK_STATUS taskStatus;
      ///
      /// Информационное сообщение.
      ///
      string message;
      ///
      /// Истина, если текущее задание возможно выполнить, ложь в противном случае.
      ///
      bool checkValidExecute(void)
      {
         //Задание нельзя применить к нулевой позиции.
         if(position.Status() == POSITION_NULL)
            return false;
         //Задание нельзя примень к заблокированной (изменяющейся) позиции.
         if(position.IsBlocked())
            return false;
         //Задание нельзя применить, если оно уже было выполненно.
         if(taskStatus == TASK_COMPLETED_SUCCESS ||
            taskStatus == TASK_COMPLETED_FAILED)
            return false;
         return true;
      }
      ///
      /// Истина, если позиция использует стоп-лосс ордер.
      ///
      bool UsingStopLoss(void)
      {
         Order* slOrder = position.StopOrder();
         if(slOrder != NULL && slOrder.IsPending())
            return true;
         return false;
      }
      ///
      /// Истина, если позиция использует тейк-профит ордер.
      ///
      bool UsingTakeProfit(void)
      {
         //Сейчас тейк-профит ордера не реализованы, поэтому
         //позиция их никогда не использует.
         return false;
      }
   private:
      ///
      /// Текущая позиция.
      ///
      Position* position;
      ///
      /// Идентификатор события.
      ///
      ENUM_TASK_TYPE type;
};
///
/// Задание "Удалить позицию."
///
class TaskClosePos : public Task
{
   public:
      TaskClosePos(Position* pos, string exitComment) : Task(pos, TASK_CLOSE_POSITION)
      {
         //closePos = new ClosePosition(pos, exitComment);
         //modifyStop = new ModifyStopLoss(pos, 0.0, "");
         position = pos;
         listOperations.Add(new ModifyStopLoss(pos, 0.0, ""));
         listOperations.Add(new ClosePosition(pos, exitComment));
      }
      virtual void Execute()
      {
         while(listOperations.Total())
         {
            PrimitiveOP* op = listOperations.At(0);
            if(op.IsPerform())
            {
               op.Execute();
               return;
            }
            //Условия задания выполненны? - 
            //Переходим к следущему заданию.
            if(op.IsSuccess())
            {
               //... а старое удаляем.
               listOperations.Delete(0);
               continue;   
            }
            // В противном случае завершаем задание неудачей.
            // Причина неудачи в последнем задании.
            taskStatus = TASK_COMPLETED_FAILED;
         }
         //Заданий нет? - все задания выполнены удачно.
         
         if(UsingStopLoss())
         {
            if(modifyStop.IsPerform())
            {
               if(!DoubleEquals(oldStopLoss, position.StopLossLevel()))
                  oldStopLoss = position.StopLossLevel();
               modifyStop.Execute();
            }
            else
            {
               taskStatus = TASK_COMPLETED_FAILED;
               message = "Failed to modify stop loss. Task canceled.";
            }
            return;
         }
         //Если дошли до сюда - стоп-лосса уже нет.
         if(position.Status() == POSITION_ACTIVE)
         {
            if(closePos.IsPerform())
               closePos.Execute();
            // По каким-то причинам, закрытие позиции завершилось неудачей.
            // Восстанавливаем стоп-лосс у этой позиции и завершаем задачу.
            else
            {
               RestoreStop();
               taskStatus = TASK_COMPLETED_FAILED;
               message = "Failed to close position. Restore Stop and task canceled.";
            }
            return;
         }
         //Если дошли до сюда - активной позиции уже нет и задание успешно выполненно.
         taskStatus = TASK_COMPLETED_SUCCESS;
         message = "Task completed successfully.";
      }
   private:
      ///
      /// Пытается восстановить первоначальный стоп-лосс.
      /// (Уровень первончальаного стоп-лосса должен быть предусмотрительно
      /// записан перед его удаленим в переменную oldStopLoss).
      ///
      void RestoreStop()
      {
         //Если информации о старом стопе нет - то и нечего восстанавливать.
         if(DoubleEquals(0.0, 0.0) ||
            oldStopLoss < 0.0)
            return;
         if(position.CheckValidLevelSL(oldStopLoss))
         {
            if(restoreStop == NULL)
               restoreStop = new ModifyStopLoss(position, oldStopLoss, "");
            restoreStop.Execute();
         }
      }
      /*Примитивыне процедуры с которыми будем работать*/
      ///
      /// Процедура закрытия позиции.
      ///
      ClosePosition* closePos;
      ///
      /// Процедура модификации стоп-лосса.
      ///
      ModifyStopLoss* modifyStop;
      ///
      /// Процедура восстановления стоп-лосса.
      ///
      ModifyStopLoss* restoreStop;
      ///
      /// Позиция, к которой будет применено задание.
      ///
      Position* position;
      ///
      /// Запоминаем уровень старого стоп-лосса, на случай, если
      /// его придется восстановить, если цикл операций по удалению
      /// позиции окажется неудачным.
      ///
      double oldStopLoss;
      ///
      /// Список операций.
      ///
      CArrayObj listOperations;
};

///
/// Задание "Удалить позицию."
///
/*class TaskClosePos : public Task
{
   public:
      TaskClosePos(Position* pos) : Task(pos, TASK_CLOSE_POSITION){;}
      virtual void Execute()
      {
         //Выполняем задание, только в том случае, если его возможно выполнить.
         if(!checkValidExecute())return;
         taskStatus = TASK_EXECUTING;
         Position* pos = TaskPosition();
         // 1. Удаляем стоп-лосс ордер, если он есть.
         if(UsingStopLoss())
         {
            pos.StopLossModify(0.0);
            return;
         }
         // 2. Удаляем тейк-профит ордер, если он есть (сейчас нереализовано).
         //if(UsingTakeProfit())
         //{
         //   pos.TakeProfitModify(0.0);
         //   return;
         //}
         // 3. Закрываем позицию.
         if(pos.Status() != POSITION_HISTORY)
         {
            pos.AsynchClose(pos.VolumeExecuted());
            return;
         }
         taskStatus = TASK_COMPLETED_SUCCESS;
         return;
      }
};*/

///
/// Задание "Закрыть часть позиции".
///
class TaskClosePartPos : public Task
{
   public:
      TaskClosePartPos(Position* pos, double vol) : Task(pos, TASK_CLOSE_PART_POS)
      {
         exVol = vol;
      }
      virtual void Execute()
      {
         //Выполняем задание, только в том случае, если его возможно выполнить.
         if(!checkValidExecute())return;
         taskStatus = TASK_EXECUTING;
         Position* pos = TaskPosition();
         //Удаляем стоп-лосс ордер, если он есть.
         if(UsingStopLoss())
         {
            stopLevel = pos.StopLossLevel();
            pos.StopLossModify(0.0);
            return;
         }
         //2. Закрываем часть объема текущей позиции.
         if(pos.Status() != POSITION_HISTORY)
         {
            pos.AsynchClose(exVol);
            return;
         }
         //Ставим новый стоп-лосс, на прежнем уровне, с объемом, равным текущей позиции.
         //(К сожалению изменить объем у отложенного ордера нельзя).
         pos.StopLossModify(stopLevel);
         taskStatus = TASK_COMPLETED_SUCCESS;
      }
   private:
      ///
      /// Объем, который необходимо закрыть.
      ///
      double exVol;
      ///
      /// Уровень стоп-лосс ордера.
      ///
      double stopLevel;
};
