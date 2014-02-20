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
            currTarget = targets.GetFirstNode();
         while(targets.Total())
         {
            Target* target = CurrentTarget();
            //������� ������� ���������?
            if(target.IsSuccess())
            {
               //��� ������� �����������.
               if(targets.GetNextNode() == NULL)
               {
                  status = TASK_STATUS_COMPLETE;
                  return;
               }
               //���������� � ���������� ��������� �������.
               else continue;
            }
            //���� ���, �� ��������� ������� ���� ��������.
            else if(!target.IsFailed())
            {
               bool res = target.Execute();
               if(!res)
                  OnCrashed();
               //���� �� ����������.
               else
               {
                  status = TASK_EXECUTING;
                  TaskChanged();
                  return;
               }
            }
            //�������� �������������� �������� ��������.
            OnCrashed();
         }
      }
      
      ///
      /// �������������� ������� �� ������� ����������.
      ///
      virtual void Event(Event* event)
      {
         if(currTarget != NULL)
         {
            currTarget.Event(event);
            Execute();
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
         if(status == TASK_COMPLETED_SUCCESS || status == TASK_COMPLETED_FAILED)
            return true;
         return false;
      }
   protected:
      ///
      /// �������� �������� �������� � ������ ���� ���������.
      ///
      virtual void OnCrashed()
      {
         //��-��������� ��������� � ��������� �������.
         currTarget = targets.GetNextNode();
      }
      ///
      /// ���������� ��������� � �������� �������, ��� ��������� ������� ���� ���������.
      ///
      virtual void TaskChanged()
      {
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