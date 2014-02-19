#include "Transaction.mqh"
#include "Methods.mqh"


///
/// Абстрактная задача. Задача - это вызов параметризированного метода. 
///
class Task2
{
   public:
      bool Execute()
      {
         bool res = OnExecute();
         attempsMade++;
         return res;
      }
      ///
      /// Истина, если операцию можно выполнить, ложь - в противном случае.
      ///
      bool IsPerform()
      {
         return attempsMade < attempsAll;
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
      /// Возвращает идентификатор задания.
      ///
      ENUM_TASK_TYPE TaskType(void){return type;}
   protected:
      Task2(ENUM_TASK_TYPE task_type)
      {
         attempsAll = 1;
         type = task_type;
      }
      virtual bool OnExecute(){return false;}
   private:
      ///
      /// Идентификатор события.
      ///
      ENUM_TASK_TYPE type;
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
/// Задача - удалить отложенный ордер.
///
class TaskDeletePendingOrder : public Task2
{
   public:
      TaskDeletePendingOrder(ulong order_id, bool asynch_mode) : Task2(TASK_DELETE_PENDING_ORDER)
      {
         method = new MethodDeletePendingOrder(order_id, asynch_mode);
      }
      ~TaskDeletePendingOrder()
      {
         delete method;
      }
   private:
      ///
      /// Удаляет отложенный ордер.
      ///
      virtual bool OnExecute()
      {
         return method.Execute();
      }
      MethodDeletePendingOrder* method;
};
