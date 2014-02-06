#include "Position.mqh"

///
/// �������� �������������� �������, ������� ���� ���������.
///
enum ENUM_TASK_TYPE
{
   ///
   /// ������� ��� �������.
   ///
   TASK_CLOSE_POSITION,
   ///
   /// ������� ����� �������.
   ///
   TASK_CLOSE_PART_POS,
   ///
   /// ������� Stop-Loss.
   ///
   TASK_DELETE_STOP_LOSS,
   ///
   /// �������������� ������� Stop-Loss
   ///
   TASK_MODIFY_STOP_LOSS,
   ///
   /// ������� Stop-Loss.
   ///
   TASK_DELETE_TAKE_PROFIT,
   ///
   /// �������������� ������� Stop-Loss
   ///
   TASK_MODIFY_TAKE_PROFIT,
};

///
/// �������� ������� ������ ���������� �������.
///
enum ENUM_TASK_STATUS
{
   ///
   /// ������� �������������, �� ��� �� ������ �����������.
   ///
   TASK_QUEUED,
   ///
   /// ������� ��������� � ������� ����������.
   ///
   TASK_EXECUTING,
   ///
   /// ������� ���������
   ///
   TASK_COMPLETED_SUCCESS,
   ///
   /// ������� ��������� ��������.
   ///
   TASK_COMPLETED_FAILED
};


///
/// ������.
///
class Task : CObject
{
   public:
      ///
      /// ������� �� ���������� �������.
      ///
      virtual void Execute(void){;}
      ///
      /// ���������� ������� ������ �������.
      ///
      ENUM_TASK_STATUS Status(){return taskStatus;}
      ///
      /// �������������� ���������.
      ///
      string Message(){return message;}
      ///
      /// ���������� ������������� �������.
      ///
      ENUM_TASK_TYPE TaskType(void){return type;}
   protected:
      Task(Position* pos, ENUM_TASK_TYPE taskType)
      {
         position = pos;
         type = taskType;
      }
      ///
      /// ���������� �������, � ������� ��������� ������� �������.
      ///
      Position* TaskPosition(void){return position;}
      ///
      /// ������ �������.
      ///
      ENUM_TASK_STATUS taskStatus;
      ///
      /// �������������� ���������.
      ///
      string message;
      ///
      /// ������, ���� ������� ������� �������� ���������, ���� � ��������� ������.
      ///
      bool checkValidExecute(void)
      {
         //������� ������ ��������� � ������� �������.
         if(position.Status() == POSITION_NULL)
            return false;
         //������� ������ ������� � ��������������� (������������) �������.
         if(position.IsBlocked())
            return false;
         //������� ������ ���������, ���� ��� ��� ���� ����������.
         if(taskStatus == TASK_COMPLETED_SUCCESS ||
            taskStatus == TASK_COMPLETED_FAILED)
            return false;
         return true;
      }
      ///
      /// ������, ���� ������� ���������� ����-���� �����.
      ///
      bool UsingStopLoss(void)
      {
         Order* slOrder = position.StopOrder();
         if(slOrder != NULL && slOrder.IsPending())
            return true;
         return false;
      }
      ///
      /// ������, ���� ������� ���������� ����-������ �����.
      ///
      bool UsingTakeProfit(void)
      {
         //������ ����-������ ������ �� �����������, �������
         //������� �� ������� �� ����������.
         return false;
      }
   private:
      ///
      /// ������� �������.
      ///
      Position* position;
      ///
      /// ������������� �������.
      ///
      ENUM_TASK_TYPE type;
};

///
/// ������� "������� �������."
///
class TaskClosePos : public Task
{
   public:
      TaskClosePos(Position* pos) : Task(pos, TASK_CLOSE_POSITION){;}
      virtual void Execute()
      {
         //��������� �������, ������ � ��� ������, ���� ��� �������� ���������.
         if(!checkValidExecute())return;
         taskStatus = TASK_EXECUTING;
         Position* pos = TaskPosition();
         // 1. ������� ����-���� �����, ���� �� ����.
         if(UsingStopLoss())
         {
            pos.StopLossModify(0.0);
            return;
         }
         // 2. ������� ����-������ �����, ���� �� ���� (������ �������������).
         /*if(UsingTakeProfit())
         {
            pos.TakeProfitModify(0.0);
            return;
         }*/
         // 3. ��������� �������.
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
/// ������� "������� ����� �������".
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
         //��������� �������, ������ � ��� ������, ���� ��� �������� ���������.
         if(!checkValidExecute())return;
         taskStatus = TASK_EXECUTING;
         Position* pos = TaskPosition();
         //������� ����-���� �����, ���� �� ����.
         if(UsingStopLoss())
         {
            stopLevel = pos.StopLossLevel();
            pos.StopLossModify(0.0);
            return;
         }
         //2. ��������� ����� ������ ������� �������.
         if(pos.Status() != POSITION_HISTORY)
         {
            pos.AsynchClose(exVol);
            return;
         }
         //������ ����� ����-����, �� ������� ������, � �������, ������ ������� �������.
         //(� ��������� �������� ����� � ����������� ������ ������).
         pos.StopLossModify(stopLevel);
         taskStatus = TASK_COMPLETED_SUCCESS;
      }
   private:
      ///
      /// �����, ������� ���������� �������.
      ///
      double exVol;
      ///
      /// ������� ����-���� ������.
      ///
      double stopLevel;
};
