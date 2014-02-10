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
         attempsMade++;
         timeBegin.SetDateTime(TimeCurrent());
         return Script();
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
      /// Возвращает идентификатор операции.
      ///
      ENUM_OPERATION_TYPE OperationType(){return opType;}
      ///
      /// Возвращает время начала выполнения операции в милисекундах.
      ///
      long TimeBegin(){return timeBegin.Tiks();}
   protected:
      PrimitiveOP(ENUM_OPERATION_TYPE type)
      {
         attempsAll = 1;
      }
      ///
      /// Задает операцию с заданным количеством попыток.
      ///
      PrimitiveOP(ENUM_OPERATION_TYPE type, int attemps)
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
      CTime timeBegin;
      ///
      /// Содержит идентификатор операции.
      ///
      ENUM_OPERATION_TYPE opType;
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
      ClosePosition(Position* cpos, string comm) : PrimitiveOP(OPERATION_POSITION_CLOSE)
      {
         pos = cpos;
         comment = comm;
         volume = pos.VolumeExecuted();
      }
      ///
      /// Определяет закрытие части позиции с объемом vol
      ///
      ClosePosition(Position* cpos, double vol, string comm) : PrimitiveOP(OPERATION_POSITION_CLOSE)
      {
         pos = cpos;
         comment = comm;
         volume = vol;
      }
      ///
      /// Истина, если текущая позиция не активна.
      ///
      virtual bool IsSuccess()
      {
         if(pos.Status() != POSITION_ACTIVE)
            return true;
         return false;
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
      ModifyStopLoss(Position* cpos, double slLevel, string comm) : PrimitiveOP(OPERATION_SL_MODIFY)
      {
         pos = cpos;
         comment = comm;
         stopLevel = slLevel;
      }
      ///
      /// Истина, если текущий уровень стоп-лосса совпадает с установленным уровнем.
      ///
      virtual bool IsSuccess()
      {
         if(Math::DoubleEquals(pos.StopLossLevel(), stopLevel))return true;
         return false;
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
class Task : public CObject
{
   public:
      ///
      /// Команда на выполнение задания.
      ///
      virtual void Execute(void){;}
      ///
      /// Возвращает текущий статус задания.
      ///
      virtual ENUM_TASK_STATUS Status(){return taskStatus;}
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
      /*bool checkValidExecute(void)
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
      }*/
      ///
      /// Истина, если позиция использует стоп-лосс ордер.
      ///
      /*bool UsingStopLoss(void)
      {
         Order* slOrder = position.StopOrder();
         if(slOrder != NULL && slOrder.IsPending())
            return true;
         return false;
      }*/
      ///
      /// Истина, если позиция использует тейк-профит ордер.
      ///
      /*bool UsingTakeProfit(void)
      {
         //Сейчас тейк-профит ордера не реализованы, поэтому
         //позиция их никогда не использует.
         return false;
      }*/
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
         position = pos;
         //Удаляем стоп-лосс ордер.
         listOperations.Add(new ModifyStopLoss(pos, 0.0, ""));
         //Закрываем позицию.
         listOperations.Add(new ClosePosition(pos, exitComment));
         oldStopLoss = pos.StopLossLevel();
      }
      
      virtual void Execute()
      {
         if(taskStatus != TASK_COMPLETED_FAILED)
            taskStatus = TASK_EXECUTING;
         while(listOperations.Total())
         {
            PrimitiveOP* op = listOperations.At(0);
            //Условия задания выполненны? - 
            //Переходим к следущему заданию.
            if(op.IsSuccess())
            {
               //... а старое удаляем.
               listOperations.Delete(0);
               continue;   
            }
            else if(op.IsPerform())
            {
               op.Execute();
               return;
            }
            else
            {
               //Сбой выполнения.
               //Устанавливаем сценарий восстановления.
               //Устанавливаем флаг сбоя.
               //taskStatus = TASK_COMPLETED_FAILED;
               message = "operation " + EnumToString(op.OperationType()) + " failed.";
               SetRestoreOP();
               continue;
            }
         }
         if(taskStatus != TASK_COMPLETED_FAILED)
            taskStatus = TASK_COMPLETED_SUCCESS;
         //Заданий нет? - все задания выполнены удачно.
         message = "Task completed successfully.";
      }
   private:
      ///
      /// Пытается восстановить первоначальный стоп-лосс.
      /// (Уровень первончальаного стоп-лосса должен быть предусмотрительно
      /// записан перед его удаленим в переменную oldStopLoss).
      ///
      void SetRestoreOP()
      {
         taskStatus = TASK_COMPLETED_FAILED;
         listOperations.Clear();
         //Если позиция не активна - восстанавливать уже нечего.
         if(position.Status() != POSITION_ACTIVE || isRestore)
            return;
         isRestore = true;
         //Если уровни совпадают - выходим.
         if(Math::DoubleEquals(position.StopLossLevel(), oldStopLoss))
            return;
         //Иначе формируем задание на установку стоп-лосса.
         listOperations.Add(new ModifyStopLoss(position, oldStopLoss, ""));
      }
      ///
      /// Позиция.
      ///
      Position* position;
      ///
      /// Уровень первоначального стоп-лосса.
      ///
      double oldStopLoss;
      ///
      /// Список операций.
      ///
      CArrayObj listOperations;
      ///
      /// Флаг указывающий на то, что функция восстановления уже вызывалась, и повторно пытаться восстановить 
      /// состояние уже не нужно.
      ///
      bool isRestore;
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
         //if(!checkValidExecute())return;
         //taskStatus = TASK_EXECUTING;
         Position* pos = TaskPosition();
         //Удаляем стоп-лосс ордер, если он есть.
         /*if(UsingStopLoss())
         {
            stopLevel = pos.StopLossLevel();
            pos.StopLossModify(0.0);
            return;
         }*/
         //2. Закрываем часть объема текущей позиции.
         if(pos.Status() != POSITION_HISTORY)
         {
            pos.AsynchClose(exVol);
            return;
         }
         //Ставим новый стоп-лосс, на прежнем уровне, с объемом, равным текущей позиции.
         //(К сожалению изменить объем у отложенного ордера нельзя).
         pos.StopLossModify(stopLevel);
         //taskStatus = TASK_COMPLETED_SUCCESS;
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
