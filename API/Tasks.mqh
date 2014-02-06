#include "Position.mqh"

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
         /*if(UsingTakeProfit())
         {
            pos.TakeProfitModify(0.0);
            return;
         }*/
         // 3. Закрываем позицию.
         if(pos.Status() != POSITION_HISTORY)
         {
            pos.AsynchClose(pos.VolumeExecuted());
            return;
         }
         taskStatus = TASK_COMPLETED_SUCCESS;
         return;
      }
};

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
