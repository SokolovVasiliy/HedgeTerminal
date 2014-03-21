#include "..\Prototypes.mqh"
#include <Arrays\ArrayInt.mqh>
///
/// ����������� ������� ��� ������.
///
class TaskLog
{
   public:
      ///
      /// ��������� ��� ���������� �������.
      /// \param target_type - ��� �������.
      /// \param retcode - ��� ���������� �������.
      ///
      void AddRedcode(ENUM_TARGET_TYPE target_type, uint retcode)
      {
         if(targetTypes.Total() == 0)
            firstRecord = TimeCurrent();
         targetTypes.Add(target_type);
         targetRetcodes.Add(retcode);
      }
      ///
      /// ��������� ������ ����� � ������������ ���.
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
      /// ����� ���������� ����������� ��������.
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
      /// ������� ��� �������.
      ///
      void Clear()
      {
         targetTypes.Clear();
         targetRetcodes.Clear();
      }
      ///
      /// ����� ������ ������.
      ///
      datetime FirstRecord(){return firstRecord;}
   private:
      ///
      /// ����� ������ ������.
      ///
      datetime firstRecord;
      ///
      /// �������� ������������������ ��������������� ��������.
      ///
      CArrayInt targetTypes;
      ///
      /// �������� ������������������ ��������������
      ///
      CArrayInt targetRetcodes;
};
