#include "Tasks.mqh"
#include "Targets.mqh"
#include <Arrays\List.mqh>
/*
  Task2 - �������� ������������ ����� � ���������� �� �������� ����������.
  ����� �������� ������, ��� ������� ����� ��������� ��� ������.
  �������� ���������� ���� �����, ���������� � ������, �������� ��������� �������
  � ��������������� �� ��������, �������� ���������. ����� ������� ���� ������� ����� ����������.
  ����� ������ ������ ��������� ��� ������� ��� �����:
  1. ������ ����� (����� �������� �� ����� ������).
  2. ������, � �������� ����� ����������� ������
  3. ������������������ �������� ���������� �����.
  4. �������� ����.
 */
///
///
/// Task2 - �������� ������ �������� � �������� �� ����������.
///
class Task2 : CObject
{
   public:
      void Execute()
      {
         if(!isContinue && targets.Total())
         {
            currTarget = targets.GetFirstNode();
            isContinue = true;
            //��� ���������� ������ ������ �� ���������.
            if(status == TASK_STATUS_FAILED)
            {
               return;
               TaskChanged();
            }
         }
         while(targets.Total())
         {
            Target* target = CurrentTarget();
            if(target.Status() == TARGET_STATUS_EXECUTING)
               return;
            if(target.Status() == TARGET_STATUS_COMLETE)
            {
               //��� ������� �����������.
               if(targets.GetNextNode() == NULL)
               {
                  TaskChanged();
                  return;
               }
               //���������� � ���������� ��������� �������.
               else continue;
            }
            //���� ���, �� ��������� ������� ���� ��������.
            else if(target.Status() == TARGET_STATUS_WAITING)
            {
               bool res = target.Execute();
               if(!res)
               {
                  OnCrashed();
                  TaskChanged();
                  continue;
               }
               //���� �� ����������.
               else
               {
                  TaskChanged();
                  return;
               }
            }
            else if(target.Status() == TARGET_STATUS_FAILED)
            {
               //�������� �������������� �������� ��������.
               OnCrashed();
               TaskChanged();
            }
         }
      }
      
      ///
      /// �������������� ������� �� ������� ����������.
      ///
      virtual void Event(Event* event)
      {
         if(currTarget != NULL)
         {
            //���������� ��������� ���������.
            ENUM_TARGET_STATUS
               targetStatus = currTarget.Status();
            currTarget.Event(event);
            //��������� ����������? - ��������� ��������.
            if(currTarget.Status() != targetStatus)
            {
               Execute();
            }
         }
      }
      
      ///
      /// ������ �������.
      ///
      ENUM_TASK_STATUS Status(){return status;}
      ///
      /// ������, ���� ������� ������ ��������� � ������ ���������� � ���� � ��������� ������.
      ///
      bool IsActive()
      {
         if(status == TASK_QUEUED || status == TASK_EXECUTING)
            return true;
         return false;
      }
      ///
      /// ������, ���� ������� ������� ��������� � ���� � ��������� ������.
      ///
      bool IsFinished()
      {
         if(status == TASK_STATUS_COMPLETE || status == TASK_STATUS_FAILED)
            return true;
         return false;
      }
   protected:
      ///
      /// �������� �������� �������� � ������ ���� ���������.
      ///
      virtual void OnCrashed(){}
      ///
      /// ���������� ��������� � �������� �������, ��� ��������� ������� ���� ���������.
      ///
      virtual void TaskChanged()
      {
         if(currTarget.Status() == TARGET_STATUS_COMLETE &&
            currTarget.Next() == NULL)
            status = TASK_STATUS_COMPLETE;
         else if(currTarget.Status() == TARGET_STATUS_WAITING)
            status = TASK_STATUS_WAITING;
         else if(currTarget.Status() == TARGET_STATUS_EXECUTING)
            status = TASK_STATUS_EXECUTING;
         else if(currTarget.Status() == TARGET_STATUS_FAILED)
            status = TASK_STATUS_FAILED;
         if(position != NULL)
            position.TaskChanged();
      }
      
      Task2()
      {
         api.AddTask(GetPointer(this));
      }
      
      Task2(Position* pos)
      {
         position = pos;
         api.AddTask(GetPointer(this));
      }
      ///
      /// ��������� ����� ������� � ����� ������ ����������.
      ///
      void AddTarget(Target* target)
      {
         targets.Add(target);
      }
      ///
      /// ������� ������ ����������.
      ///
      void ClearTargets()
      {
         targets.Clear();
      }
      ///
      /// ����������� ��������� �������� ������� � ��������� �� ������ �������.
      ///
      void NextTarget()
      {
         currTarget = targets.GetNextNode();
      }
      ///
      /// ���������� ������� ����������.
      ///
      Target* CurrentTarget()
      {
         currTarget = targets.GetCurrentNode();
         return currTarget;
      }
      ///
      /// ������ ����� �������.
      ///
      ENUM_TASK_STATUS status;
      ///
      /// �������, ��� ������� ����� ����������� ������.
      ///
      Position* position;
   private:
      ///
      /// ������ ����������, ������� ���������� ���������.
      ///
      CList targets;
      ///
      /// ��������� �� ������� ���������, ������� ����������� � ������ ������.
      ///
      Target* currTarget;
      ///
      /// 
      ///
      bool isContinue;
};

///
/// ������� ����-���� �������.
///
class TaskDeleteStopLoss : public Task2
{
   public:
      TaskDeleteStopLoss(Position* pos, bool asynch_mode) : Task2(pos)
      {
         ulong stopId = 0;
         Order* stopOrder;
         if(pos.UsingStopLoss())
         {
            stopOrder = pos.StopOrder();
            stopId = stopOrder.GetId();
         }
         AddTarget(new TargetDeletePendingOrder(stopId, asynch_mode));
      }  
};

class TaskSetStopLoss : Task2
{
   public:
      TaskSetStopLoss(Position* pos, double price, bool asynch_mode) : Task2(pos)
      {
         if(pos.UsingStopLoss())
         {
            LogWriter("Position already using stop-order. Delete old stop-order and set new.", MESSAGE_TYPE_ERROR);
            status = TASK_STATUS_FAILED;
            return;
         }
         if(pos.Status() != POSITION_ACTIVE)
         {
            LogWriter("Position not active. Execute task not posiible.", MESSAGE_TYPE_ERROR);
            status = TASK_STATUS_FAILED;
            return;
         }
         ENUM_ORDER_TYPE orderType;
         if(pos.Direction() == DIRECTION_LONG)
            orderType = ORDER_TYPE_SELL_STOP;
         if(pos.Direction() == DIRECTION_SHORT)
            orderType = ORDER_TYPE_BUY_STOP;
         Order* initOrder = pos.EntryOrder();
         ulong magic = initOrder.GetMagic(MAGIC_TYPE_SL);
         AddTarget(new TargetSetPendingOrder(pos.Symbol(), orderType, pos.VolumeExecuted(), price, pos.ExitComment(), magic, true));
      }
};