#include "Position.mqh"
#include "..\Math.mqh"
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

/* ��������� */
///
/// ��� ��������.
///
enum ENUM_OPERATION_TYPE
{
   ///
   /// ������������� �������� "����������� ����-�����".
   ///
   OPERATION_SL_MODIFY,
   ///
   /// ������������� �������� "�������� �������".
   ///
   OPERATION_POSITION_CLOSE
};

///
/// ������� ����� ����������� ��������.
///
class PrimitiveOP : public CObject
{
   public:
      ///
      /// ���������� ����������� �������.
      ///
      int AttempsMade(){return attempsMade;}
      ///
      /// ����� ���������� ������� ��� ���������� ��������, �������
      /// �������� ��� �������� ��������.
      ///
      int AttempsAll(){return attempsAll;}
      ///
      /// ������, ���� �������� ����� ���������, ���� - � ��������� ������.
      ///
      bool IsPerform()
      {
         return attempsMade < attempsAll;
      }
      ///
      /// ��������� ������� ������������ ������. 
      ///
      bool Execute()
      {
         return Script();
      }
      ///
      /// ���������� ������, ���� ��������� ������� ������������� ���� ��������.
      /// ��������, ���� ��������� ������� ����-���� ����� � �������, � ������� ���
      /// �� ����� ����-���� ����� IsSuccess ������ ������.
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
      /// ������ �������� � �������� ����������� �������.
      ///
      PrimitiveOP(int attemps)
      {
         attempsAll = attemps;
      }
      ///
      /// ����������� ����� ���������� � ���� ������ ���������� �������,
      /// ������� ����� ���������.
      ///
      virtual bool Script()
      {
         return true;
      }
   private:
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
/// ��������� �������� �������, ���� �� �����.
///
class ClosePosition : public PrimitiveOP
{
   public:
      ///
      /// ���������� �������� ���� �������.
      ///
      ClosePosition(Position* cpos, string comm)
      {
         pos = cpos;
         comment = comm;
         volume = pos.VolumeExecuted();
      }
      ///
      /// ���������� �������� ����� ������� � ������� vol
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
      /// ��������� ���������� ������ �������� �������.
      ///
      virtual bool Script()
      {
         return pos.AsynchClose(volume, comment);
      }
};

///
/// ��������� ����������� ����-�����.
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
      /// ��������� ���������������� ��������/��������/��������� ����-�����.
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
            //������� ������� ����������? - 
            //��������� � ��������� �������.
            if(op.IsSuccess())
            {
               //... � ������ �������.
               listOperations.Delete(0);
               continue;   
            }
            // � ��������� ������ ��������� ������� ��������.
            // ������� ������� � ��������� �������.
            taskStatus = TASK_COMPLETED_FAILED;
         }
         //������� ���? - ��� ������� ��������� ������.
         
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
         //���� ����� �� ���� - ����-����� ��� ���.
         if(position.Status() == POSITION_ACTIVE)
         {
            if(closePos.IsPerform())
               closePos.Execute();
            // �� �����-�� ��������, �������� ������� ����������� ��������.
            // ��������������� ����-���� � ���� ������� � ��������� ������.
            else
            {
               RestoreStop();
               taskStatus = TASK_COMPLETED_FAILED;
               message = "Failed to close position. Restore Stop and task canceled.";
            }
            return;
         }
         //���� ����� �� ���� - �������� ������� ��� ��� � ������� ������� ����������.
         taskStatus = TASK_COMPLETED_SUCCESS;
         message = "Task completed successfully.";
      }
   private:
      ///
      /// �������� ������������ �������������� ����-����.
      /// (������� ��������������� ����-����� ������ ���� �����������������
      /// ������� ����� ��� �������� � ���������� oldStopLoss).
      ///
      void RestoreStop()
      {
         //���� ���������� � ������ ����� ��� - �� � ������ ���������������.
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
      /*����������� ��������� � �������� ����� ��������*/
      ///
      /// ��������� �������� �������.
      ///
      ClosePosition* closePos;
      ///
      /// ��������� ����������� ����-�����.
      ///
      ModifyStopLoss* modifyStop;
      ///
      /// ��������� �������������� ����-�����.
      ///
      ModifyStopLoss* restoreStop;
      ///
      /// �������, � ������� ����� ��������� �������.
      ///
      Position* position;
      ///
      /// ���������� ������� ������� ����-�����, �� ������, ����
      /// ��� �������� ������������, ���� ���� �������� �� ��������
      /// ������� �������� ���������.
      ///
      double oldStopLoss;
      ///
      /// ������ ��������.
      ///
      CArrayObj listOperations;
};

///
/// ������� "������� �������."
///
/*class TaskClosePos : public Task
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
         //if(UsingTakeProfit())
         //{
         //   pos.TakeProfitModify(0.0);
         //   return;
         //}
         // 3. ��������� �������.
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
