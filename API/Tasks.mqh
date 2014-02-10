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
         attempsMade++;
         timeBegin.SetDateTime(TimeCurrent());
         return Script();
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
      /// ���������� ������������� ��������.
      ///
      ENUM_OPERATION_TYPE OperationType(){return opType;}
      ///
      /// ���������� ����� ������ ���������� �������� � ������������.
      ///
      long TimeBegin(){return timeBegin.Tiks();}
   protected:
      PrimitiveOP(ENUM_OPERATION_TYPE type)
      {
         attempsAll = 1;
      }
      ///
      /// ������ �������� � �������� ����������� �������.
      ///
      PrimitiveOP(ENUM_OPERATION_TYPE type, int attemps)
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
      CTime timeBegin;
      ///
      /// �������� ������������� ��������.
      ///
      ENUM_OPERATION_TYPE opType;
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
      ClosePosition(Position* cpos, string comm) : PrimitiveOP(OPERATION_POSITION_CLOSE)
      {
         pos = cpos;
         comment = comm;
         volume = pos.VolumeExecuted();
      }
      ///
      /// ���������� �������� ����� ������� � ������� vol
      ///
      ClosePosition(Position* cpos, double vol, string comm) : PrimitiveOP(OPERATION_POSITION_CLOSE)
      {
         pos = cpos;
         comment = comm;
         volume = vol;
      }
      ///
      /// ������, ���� ������� ������� �� �������.
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
      ModifyStopLoss(Position* cpos, double slLevel, string comm) : PrimitiveOP(OPERATION_SL_MODIFY)
      {
         pos = cpos;
         comment = comm;
         stopLevel = slLevel;
      }
      ///
      /// ������, ���� ������� ������� ����-����� ��������� � ������������� �������.
      ///
      virtual bool IsSuccess()
      {
         if(Math::DoubleEquals(pos.StopLossLevel(), stopLevel))return true;
         return false;
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
class Task : public CObject
{
   public:
      ///
      /// ������� �� ���������� �������.
      ///
      virtual void Execute(void){;}
      ///
      /// ���������� ������� ������ �������.
      ///
      virtual ENUM_TASK_STATUS Status(){return taskStatus;}
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
      /*bool checkValidExecute(void)
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
      }*/
      ///
      /// ������, ���� ������� ���������� ����-���� �����.
      ///
      /*bool UsingStopLoss(void)
      {
         Order* slOrder = position.StopOrder();
         if(slOrder != NULL && slOrder.IsPending())
            return true;
         return false;
      }*/
      ///
      /// ������, ���� ������� ���������� ����-������ �����.
      ///
      /*bool UsingTakeProfit(void)
      {
         //������ ����-������ ������ �� �����������, �������
         //������� �� ������� �� ����������.
         return false;
      }*/
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
         position = pos;
         //������� ����-���� �����.
         listOperations.Add(new ModifyStopLoss(pos, 0.0, ""));
         //��������� �������.
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
            //������� ������� ����������? - 
            //��������� � ��������� �������.
            if(op.IsSuccess())
            {
               //... � ������ �������.
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
               //���� ����������.
               //������������� �������� ��������������.
               //������������� ���� ����.
               //taskStatus = TASK_COMPLETED_FAILED;
               message = "operation " + EnumToString(op.OperationType()) + " failed.";
               SetRestoreOP();
               continue;
            }
         }
         if(taskStatus != TASK_COMPLETED_FAILED)
            taskStatus = TASK_COMPLETED_SUCCESS;
         //������� ���? - ��� ������� ��������� ������.
         message = "Task completed successfully.";
      }
   private:
      ///
      /// �������� ������������ �������������� ����-����.
      /// (������� ��������������� ����-����� ������ ���� �����������������
      /// ������� ����� ��� �������� � ���������� oldStopLoss).
      ///
      void SetRestoreOP()
      {
         taskStatus = TASK_COMPLETED_FAILED;
         listOperations.Clear();
         //���� ������� �� ������� - ��������������� ��� ������.
         if(position.Status() != POSITION_ACTIVE || isRestore)
            return;
         isRestore = true;
         //���� ������ ��������� - �������.
         if(Math::DoubleEquals(position.StopLossLevel(), oldStopLoss))
            return;
         //����� ��������� ������� �� ��������� ����-�����.
         listOperations.Add(new ModifyStopLoss(position, oldStopLoss, ""));
      }
      ///
      /// �������.
      ///
      Position* position;
      ///
      /// ������� ��������������� ����-�����.
      ///
      double oldStopLoss;
      ///
      /// ������ ��������.
      ///
      CArrayObj listOperations;
      ///
      /// ���� ����������� �� ��, ��� ������� �������������� ��� ����������, � �������� �������� ������������ 
      /// ��������� ��� �� �����.
      ///
      bool isRestore;
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
         //if(!checkValidExecute())return;
         //taskStatus = TASK_EXECUTING;
         Position* pos = TaskPosition();
         //������� ����-���� �����, ���� �� ����.
         /*if(UsingStopLoss())
         {
            stopLevel = pos.StopLossLevel();
            pos.StopLossModify(0.0);
            return;
         }*/
         //2. ��������� ����� ������ ������� �������.
         if(pos.Status() != POSITION_HISTORY)
         {
            pos.AsynchClose(exVol);
            return;
         }
         //������ ����� ����-����, �� ������� ������, � �������, ������ ������� �������.
         //(� ��������� �������� ����� � ����������� ������ ������).
         pos.StopLossModify(stopLevel);
         //taskStatus = TASK_COMPLETED_SUCCESS;
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
