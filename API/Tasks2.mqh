#include "Transaction.mqh"
#include "Methods.mqh"


///
/// ����������� ������. ������ - ��� ����� �������������������� ������. 
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
      /// ������, ���� �������� ����� ���������, ���� - � ��������� ������.
      ///
      bool IsPerform()
      {
         return attempsMade < attempsAll;
      }
      ///
      /// ���������� ������, ���� ��������� ������� ������������� ���� ��������.
      /// ��������, ���� ��������� ������� ����-���� ����� � �������, � ������� ���
      /// �� ����� ����-���� �����, IsSuccess ������ ������.
      ///
      virtual bool IsSuccess()
      {
         return true;
      }
      ///
      /// ���������� ������������� �������.
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
      /// ������������� �������.
      ///
      ENUM_TASK_TYPE type;
      ///
      /// �������� ���������� ����������� �������.
      ///
      int attempsMade;
      ///
      /// �������� ���������� ����������� �������.
      ///
      int attempsAll;
};

///
/// ������ - ������� ���������� �����.
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
      /// ������� ���������� �����.
      ///
      virtual bool OnExecute()
      {
         return method.Execute();
      }
      MethodDeletePendingOrder* method;
};
