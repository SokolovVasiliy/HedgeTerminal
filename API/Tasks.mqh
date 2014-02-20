#include "Position.mqh"
#include "..\Math.mqh"
///
/// Содержит идентификаторы заданий, которые надо выполнить.
///
enum ENUM_TASK_TYPE
{
   TASK_DELETE_PENDING_ORDER,
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
   TASK_COMPLETED_FAILED,
   ///
   /// Задание успешно завершено.
   ///
   TASK_STATUS_COMPLETE,
   ///
   /// Задание провалилось.
   ///
   TASK_STATUS_FAILED
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
class Operation : public CObject
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
      
   protected:
      Operation(ENUM_OPERATION_TYPE type)
      {
         attempsAll = 1;
         opType = type;
         
      }
      ///
      /// Задает операцию с заданным количеством попыток.
      ///
      Operation(ENUM_OPERATION_TYPE type, int attemps)
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
class ClosePosition : public Operation
{
   public:
      ///
      /// Определяет закрытие всей позиции.
      ///
      ClosePosition(Position* cpos, string comm) : Operation(OPERATION_POSITION_CLOSE)
      {
         pos = cpos;
         comment = comm;
         volume = pos.VolumeExecuted();
      }
      ///
      /// Определяет закрытие части позиции с объемом vol
      ///
      ClosePosition(Position* cpos, double vol, string comm) : Operation(OPERATION_POSITION_CLOSE)
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
class ModifyStopLoss : public Operation
{
   public:
      ModifyStopLoss(Position* cpos, double slLevel, string comm) : Operation(OPERATION_SL_MODIFY)
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
/// Общий класс задач.
///
class Task : public CObject
{
   public:
      ///
      /// Команда на выполнение задания.
      ///
      void Execute(void)
      {
         timeBegin = GetTickCount();
         lastExecution.SetDateTime(TimeCurrent());
         if(taskStatus != TASK_COMPLETED_SUCCESS ||
            TASK_COMPLETED_FAILED)
         {
            taskStatus = TASK_EXECUTING;
            Script();
         }
         else
            timeEnd = TimeCurrent();
      }
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
      ///
      /// Возвращает время последнего выполнения операции в миллисекундах.
      ///
      long TimeLastExecution()
      {
         return lastExecution.Tiks();
      }
      
      ///
      /// Возвращает количество милисекунд, прошедших с начала выполнения задачи.
      ///
      long TimeExecutionTotal()
      {
         if(timeEnd == 0)
            return GetTickCount() - timeBegin;
         return timeEnd - timeBegin;
      }
      
      ///
      /// Истина, если текущая задача завершена и больше не может выполняться,
      /// ложь в противном случае.
      ///
      bool IsFinished()
      {
         if(taskStatus == TASK_COMPLETED_FAILED ||
            taskStatus == TASK_COMPLETED_FAILED)
            return true;
         return false;
      }
      
      ///
      /// Истина, если текущая задача готова к выполнению или уже находится в стадии
      /// выполнения, ложь в противном случае.
      ///
      bool IsWorking()
      {
         if(taskStatus == TASK_QUEUED ||
            taskStatus == TASK_EXECUTING)
            return true;
         return false;
      }
   protected:
      ///
      /// Содержит действия потомка задачи.
      ///
      virtual void Script(){;}
      Task(ENUM_TASK_TYPE taskType)
      {
         type = taskType;
         message = "";
      }
      
      ///
      /// Статус задания.
      ///
      ENUM_TASK_STATUS taskStatus;
      ///
      /// Информационное сообщение.
      ///
      string message;
   private:
      ///
      /// Текущая позиция.
      ///
      Position* position;
      ///
      /// Идентификатор события.
      ///
      ENUM_TASK_TYPE type;
      ///
      /// Содержит время последнего вызова функции Execute()
      ///
      CTime lastExecution;
      ///
      /// Время начала выполнения операции с момента загрузки терминала
      ///
      long timeBegin;
      ///
      /// Время завершения задачи, если задача выполнена, с момента загрузки терминала.
      ///
      long timeEnd;
};

///
/// Специализированные задачи применимые к позициям.
///
class TaskPos : public Task
{
   protected:
      ///
      /// Это абстрактный класс
      ///
      TaskPos(Position* myPos, ENUM_TASK_TYPE mtype) : Task(mtype)
      {
         position = myPos;
      }
      ///
      /// Возвращает позицию, к которой относится текущее задание.
      ///
      Position* TaskPosition(void){return position;}
      Position* position;
};

///
/// Задание "Удалить позицию."
///
class TaskClosePos : public TaskPos
{
   public:
      TaskClosePos(Position* pos, string exitComment) : TaskPos(pos, TASK_CLOSE_POSITION)
      {
         //Удаляем стоп-лосс ордер.
         listOperations.Add(new ModifyStopLoss(pos, 0.0, ""));
         //Закрываем позицию.
         listOperations.Add(new ClosePosition(pos, exitComment));
         oldStopLoss = pos.StopLossLevel();
      }
      ~TaskClosePos()
      {
         listOperations.Clear();
      }
   private:
      virtual void Script()
      {
         while(listOperations.Total())
         {
            Operation* op = listOperations.At(0);
            ENUM_OPERATION_TYPE mtype = op.OperationType();
            printf("#" + (string)position.GetId() + " Получаю задачу: " + EnumToString(op.OperationType()));
            //Условия задания выполненны? - 
            //Переходим к следущему заданию.
            if(op.IsSuccess())
            {
               //... а старое удаляем.
               printf("Задача " + EnumToString(op.OperationType()) + " успешно выполненна.");
               listOperations.Delete(0);
               continue;   
            }
            else if(op.IsPerform())
            {
               printf("Запускаю задачу " + EnumToString(op.OperationType()) + " на выполнение...");
               int dbg = 5;
               if(op.OperationType() == OPERATION_POSITION_CLOSE)
                  dbg = 6;
               bool res = op.Execute();
               if(!res)
               {
                  printf("Задачу " + EnumToString(op.OperationType()) + " на удалось запустить.");
                  SetRestoreOP();
                  continue;
               }
               return;
            }
            else
            {
               printf("Задача " + EnumToString(op.OperationType()) + " была запущена, но не выполнена.");
               //Сбой выполнения.
               //Устанавливаем сценарий восстановления.               
               message = "Operation " + EnumToString(op.OperationType()) + " failed.";
               SetRestoreOP();
               continue;
            }
         }
         //Все операции закончились? - Завершаем задачу.
         if(!isFailed)
            taskStatus = TASK_COMPLETED_SUCCESS;
         else
            taskStatus = TASK_COMPLETED_FAILED;
      }
      ///
      /// Пытается восстановить первоначальный стоп-лосс.
      /// (Уровень первончальаного стоп-лосса должен быть предусмотрительно
      /// записан перед его удаленим в переменную oldStopLoss).
      ///
      void SetRestoreOP()
      {
         printf("Восстанавливаю предыдущее состояние...");
         listOperations.Clear();
         //Если позиция не активна - восстанавливать уже нечего.
         //Также не вызываем функцию повторно.
         if(position.Status() != POSITION_ACTIVE || isFailed)
            return;
         isFailed = true;
         //Если уровни совпадают - выходим.
         if(Math::DoubleEquals(position.StopLossLevel(), oldStopLoss))
            return;
         //Иначе формируем задание на установку стоп-лосса.
         listOperations.Add(new ModifyStopLoss(position, oldStopLoss, ""));
      }
      ///
      /// Уровень первоначального стоп-лосса.
      ///
      double oldStopLoss;
      ///
      /// Список операций.
      ///
      CArrayObj listOperations;
      ///
      /// Истина, если произошел сбой выполнения операции.
      ///
      bool isFailed;
};

///
/// Задание установить/модифицировать стоп-лосс
///
class TaskModifySL : public TaskPos
{
   public:
      TaskModifySL(Position* pos, double slLevel, string comm) : TaskPos(pos, TASK_MODIFY_STOP_LOSS)
      {
         setStop = new ModifyStopLoss(pos, slLevel, comm);
      }
      ~TaskModifySL()
      {
         delete setStop;
      }
   private:
      virtual void Script()
      {
         if(setStop.IsSuccess())
         {
            taskStatus = TASK_COMPLETED_SUCCESS;
            return;
         }
         else if(setStop.IsPerform())
         {
            if(setStop.Execute())
               return;  
         }
         taskStatus = TASK_COMPLETED_FAILED;
      }
      Operation* setStop;
};


///
/// Задание "Закрыть часть позиции".
///
class TaskClosePartPos : public TaskPos
{
   public:
      TaskClosePartPos(Position* pos, double vol) : TaskPos(pos, TASK_CLOSE_PART_POS)
      {
         exVol = vol;
      }
      
   private:
      virtual void Script()
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
      ///
      /// Объем, который необходимо закрыть.
      ///
      double exVol;
      ///
      /// Уровень стоп-лосс ордера.
      ///
      double stopLevel;
};
