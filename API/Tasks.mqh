#include "Position.mqh"
#include "..\Math.mqh"
///
/// �������� �������������� �������, ������� ���� ���������.
///
enum ENUM_TASK_TYPE
{
   TASK_DELETE_PENDING_ORDER,
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
   TASK_COMPLETED_FAILED,
   ///
   /// ������� ������� ���������.
   ///
   TASK_STATUS_COMPLETE,
   ///
   /// ������� �����������.
   ///
   TASK_STATUS_FAILED
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
class Operation : public CObject
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
      
   protected:
      Operation(ENUM_OPERATION_TYPE type)
      {
         attempsAll = 1;
         opType = type;
         
      }
      ///
      /// ������ �������� � �������� ����������� �������.
      ///
      Operation(ENUM_OPERATION_TYPE type, int attemps)
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
class ClosePosition : public Operation
{
   public:
      ///
      /// ���������� �������� ���� �������.
      ///
      ClosePosition(Position* cpos, string comm) : Operation(OPERATION_POSITION_CLOSE)
      {
         pos = cpos;
         comment = comm;
         volume = pos.VolumeExecuted();
      }
      ///
      /// ���������� �������� ����� ������� � ������� vol
      ///
      ClosePosition(Position* cpos, double vol, string comm) : Operation(OPERATION_POSITION_CLOSE)
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
/// ����� ����� �����.
///
class Task : public CObject
{
   public:
      ///
      /// ������� �� ���������� �������.
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
      ///
      /// ���������� ����� ���������� ���������� �������� � �������������.
      ///
      long TimeLastExecution()
      {
         return lastExecution.Tiks();
      }
      
      ///
      /// ���������� ���������� ����������, ��������� � ������ ���������� ������.
      ///
      long TimeExecutionTotal()
      {
         if(timeEnd == 0)
            return GetTickCount() - timeBegin;
         return timeEnd - timeBegin;
      }
      
      ///
      /// ������, ���� ������� ������ ��������� � ������ �� ����� �����������,
      /// ���� � ��������� ������.
      ///
      bool IsFinished()
      {
         if(taskStatus == TASK_COMPLETED_FAILED ||
            taskStatus == TASK_COMPLETED_FAILED)
            return true;
         return false;
      }
      
      ///
      /// ������, ���� ������� ������ ������ � ���������� ��� ��� ��������� � ������
      /// ����������, ���� � ��������� ������.
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
      /// �������� �������� ������� ������.
      ///
      virtual void Script(){;}
      Task(ENUM_TASK_TYPE taskType)
      {
         type = taskType;
         message = "";
      }
      
      ///
      /// ������ �������.
      ///
      ENUM_TASK_STATUS taskStatus;
      ///
      /// �������������� ���������.
      ///
      string message;
   private:
      ///
      /// ������� �������.
      ///
      Position* position;
      ///
      /// ������������� �������.
      ///
      ENUM_TASK_TYPE type;
      ///
      /// �������� ����� ���������� ������ ������� Execute()
      ///
      CTime lastExecution;
      ///
      /// ����� ������ ���������� �������� � ������� �������� ���������
      ///
      long timeBegin;
      ///
      /// ����� ���������� ������, ���� ������ ���������, � ������� �������� ���������.
      ///
      long timeEnd;
};

///
/// ������������������ ������ ���������� � ��������.
///
class TaskPos : public Task
{
   protected:
      ///
      /// ��� ����������� �����
      ///
      TaskPos(Position* myPos, ENUM_TASK_TYPE mtype) : Task(mtype)
      {
         position = myPos;
      }
      ///
      /// ���������� �������, � ������� ��������� ������� �������.
      ///
      Position* TaskPosition(void){return position;}
      Position* position;
};

///
/// ������� "������� �������."
///
class TaskClosePos : public TaskPos
{
   public:
      TaskClosePos(Position* pos, string exitComment) : TaskPos(pos, TASK_CLOSE_POSITION)
      {
         //������� ����-���� �����.
         listOperations.Add(new ModifyStopLoss(pos, 0.0, ""));
         //��������� �������.
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
            printf("#" + (string)position.GetId() + " ������� ������: " + EnumToString(op.OperationType()));
            //������� ������� ����������? - 
            //��������� � ��������� �������.
            if(op.IsSuccess())
            {
               //... � ������ �������.
               printf("������ " + EnumToString(op.OperationType()) + " ������� ����������.");
               listOperations.Delete(0);
               continue;   
            }
            else if(op.IsPerform())
            {
               printf("�������� ������ " + EnumToString(op.OperationType()) + " �� ����������...");
               int dbg = 5;
               if(op.OperationType() == OPERATION_POSITION_CLOSE)
                  dbg = 6;
               bool res = op.Execute();
               if(!res)
               {
                  printf("������ " + EnumToString(op.OperationType()) + " �� ������� ���������.");
                  SetRestoreOP();
                  continue;
               }
               return;
            }
            else
            {
               printf("������ " + EnumToString(op.OperationType()) + " ���� ��������, �� �� ���������.");
               //���� ����������.
               //������������� �������� ��������������.               
               message = "Operation " + EnumToString(op.OperationType()) + " failed.";
               SetRestoreOP();
               continue;
            }
         }
         //��� �������� �����������? - ��������� ������.
         if(!isFailed)
            taskStatus = TASK_COMPLETED_SUCCESS;
         else
            taskStatus = TASK_COMPLETED_FAILED;
      }
      ///
      /// �������� ������������ �������������� ����-����.
      /// (������� ��������������� ����-����� ������ ���� �����������������
      /// ������� ����� ��� �������� � ���������� oldStopLoss).
      ///
      void SetRestoreOP()
      {
         printf("�������������� ���������� ���������...");
         listOperations.Clear();
         //���� ������� �� ������� - ��������������� ��� ������.
         //����� �� �������� ������� ��������.
         if(position.Status() != POSITION_ACTIVE || isFailed)
            return;
         isFailed = true;
         //���� ������ ��������� - �������.
         if(Math::DoubleEquals(position.StopLossLevel(), oldStopLoss))
            return;
         //����� ��������� ������� �� ��������� ����-�����.
         listOperations.Add(new ModifyStopLoss(position, oldStopLoss, ""));
      }
      ///
      /// ������� ��������������� ����-�����.
      ///
      double oldStopLoss;
      ///
      /// ������ ��������.
      ///
      CArrayObj listOperations;
      ///
      /// ������, ���� ��������� ���� ���������� ��������.
      ///
      bool isFailed;
};

///
/// ������� ����������/�������������� ����-����
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
/// ������� "������� ����� �������".
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
      ///
      /// �����, ������� ���������� �������.
      ///
      double exVol;
      ///
      /// ������� ����-���� ������.
      ///
      double stopLevel;
};
