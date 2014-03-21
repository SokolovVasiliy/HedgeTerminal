#include "..\Prototypes.mqh"
#include <Arrays\ArrayInt.mqh>
///
/// Логирование событий для задачи.
///
class TaskLog
{
   public:
      ///
      /// Добавляет код выполнения таргета.
      /// \param target_type - Тип таргета.
      /// \param retcode - Код выполнения таргета.
      ///
      void AddRedcode(ENUM_TARGET_TYPE target_type, uint retcode)
      {
         if(targetTypes.Total() == 0)
            firstRecord = TimeCurrent();
         targetTypes.Add(target_type);
         targetRetcodes.Add(retcode);
      }
      ///
      /// Добавляет записи логов в существующий лог.
      ///
      void AddLogs(TaskLog* task_log)
      {
         for(uint i = 0; i < task_log.Total(); i++)
         {
            ENUM_TARGET_TYPE targetType;
            uint retcode;
            task_log.GetRetcode(i, targetType, retcode);
            AddRedcode(targetType, retcode);
         }
      }
      ///
      /// Общее количество выполненных действий.
      ///
      uint Total(){return (uint)targetTypes.Total();}
      void GetRetcode(uint index, ENUM_TARGET_TYPE& target_type, uint& retcode)
      {
         
         if(index > (uint)targetTypes.Total() || index > (uint)targetRetcodes.Total())
         {
            target_type = TARGET_NDEF;
            retcode = 0;
         }
         else
         {
            target_type = (ENUM_TARGET_TYPE)targetTypes.At(index);
            retcode = targetRetcodes.At(index);
         }
      }
      ///
      /// Очищает лог задания.
      ///
      void Clear()
      {
         targetTypes.Clear();
         targetRetcodes.Clear();
      }
      ///
      /// Время первой записи.
      ///
      datetime FirstRecord(){return firstRecord;}
   private:
      ///
      /// Время первой записи.
      ///
      datetime firstRecord;
      ///
      /// Содержит последовательность идентификаторов таргетов.
      ///
      CArrayInt targetTypes;
      ///
      /// Содержит последовательность идентификаторы
      ///
      CArrayInt targetRetcodes;
};
