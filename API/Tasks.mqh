#include "Targets.mqh"
#include <Arrays\List.mqh>
#include <Arrays\ArrayInt.mqh>
///
/// �������� ������� ������ ���������� �������.
///
/*enum ENUM_TASK_STATUS
{
   ///
   /// ������� � ������ ��������.
   ///
   TASK_STATUS_WAITING,
   ///
   /// ������� � �������� ����������.
   ///
   TASK_STATUS_EXECUTING,
   ///
   /// ������� ������� ���������.
   ///
   TASK_STATUS_COMPLETE,
   ///
   /// ������� �����������.
   ///
   TASK_STATUS_FAILED
};*/

enum ENUM_LAST_OPERATION_STATUS
{
   //DELETE_STOP_LOSS
};
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
class Task2 : public CObject
{
   public:
      void Execute()
      {
         if(targets.Total() == 0)
         {
            TaskChanged();
            return;
         }
         if(!isContinue && targets.Total())
         {
            if(CheckPointer(position) != POINTER_INVALID)
               position.SetBlock(TimeCurrent(), true);
            CObject* obj = targets.GetFirstNode();
            int type = obj.Type();
            currTarget = obj;
            isContinue = true;
            //��� ���������� ������ ������ �� ���������.
            if(status == TASK_STATUS_FAILED)
            {
               TaskChanged();
               return;
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
                  return;
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
               return;
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
      /// ������������� ������������� ������ �������.
      ///
      void Status(ENUM_TASK_STATUS st){status = st;}
      ///
      /// ������, ���� ������� ������ ��������� � ������ ���������� � ���� � ��������� ������.
      ///
      bool IsActive()
      {
         if(status == TASK_STATUS_WAITING || status == TASK_STATUS_EXECUTING)
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
      ///
      /// ���������� ��������� �� �������, ������� ������������� � ������ ��������.
      /// ������������� ������� �� �������������.
      ///
      Position* GetPosition(){return position;}
      ///
      /// ������, ���� ������� ����������� � ����������� ������. ���� � ��������� ������.
      ///
      bool AsynchMode(){return asynch_mode;}
   protected:
      ///
      /// ������������������ ����� ����������� ���������� ��������.
      ///
      CArrayInt retcodes;
      ///
      /// �������� �������� �������� � ������ ���� ���������.
      ///
      virtual void OnCrashed(){}
      ///
      /// ���������� ��������� � �������� �������, ��� ��������� ������� ���� ���������.
      ///
      virtual void TaskChanged()
      {
         if(CheckPointer(currTarget) != POINTER_INVALID)
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
         }
         if(CheckPointer(position) != POINTER_INVALID)
         {
            if(IsFinished())
               position.ResetBlocked(true);
            position.TaskChanged();
         }
      }
      
      Task2(Position* pos, bool asynchMode)
      {
         position = pos;
         taskLog = pos.GetTaskLog();
         taskLog.Clear();
         //HedgeManager* hm = EventExchange::GetAPI();
         api.AddTask(GetPointer(this));
         asynch_mode = asynchMode;
      }
      ///
      /// ��������� ����� ������� � ����� ������ ����������.
      ///
      void AddTarget(Target* target)
      {
         target.SetTaskLog(position.GetTaskLog());
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
      /// ������, ���� ������� �� ������� ��� ������ �� ��� �����������, � ���� � ��������� ������.
      ///
      bool FailedIfNotActivePos()
      {
         if(position == NULL || (position.Status() != POSITION_ACTIVE))
         {
            status = TASK_STATUS_FAILED;
            taskLog.Status(status);
            taskLog.AddRedcode(TARGET_CREATE_TASK, TRADE_RETCODE_POSITION_CLOSED);   
            return true;
         }
         return false;
      }
      ///
      /// ������ ����� �������.
      ///
      ENUM_TASK_STATUS status;
      ///
      /// �������, ��� ������� ����� ����������� ������.
      ///
      Position* position;
      ///
      /// ��� ���������� �������.
      ///
      TaskLog* taskLog;
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
      ///
      /// ������, ���� ������� ����������� � ����������� ������. ���� � ��������� ������.
      ///
      bool asynch_mode;
};

///
/// ������� ����-���� �������.
///
class TaskDeleteStopLoss : public Task2
{
   public:
      TaskDeleteStopLoss(Position* pos, bool asynchMode) : Task2(pos, asynchMode)
      {
         ulong stopId = 0;
         Order* stopOrder;
         if(FailedIfNotActivePos())
            return;
         if(pos.UsingStopLoss())
         {
            stopOrder = pos.StopOrder();
            stopId = stopOrder.GetId();
            AddTarget(new TargetDeletePendingOrder(stopId, asynchMode));
         }
         else
         {
            status = TASK_STATUS_FAILED;
            taskLog.Status(status);
            taskLog.AddRedcode(TARGET_CREATE_TASK, TRADE_RETCODE_INVALID_STOPS);
         }
      }  
};
///
/// ������� ����-���� �������.
///
class TaskChangeCommentStopLoss : public Task2
{
   public:
      TaskChangeCommentStopLoss(Position* pos, string comment, bool asynchMode) : Task2(pos, asynchMode)
      {
         ulong stopId = 0;
         Order* stopOrder;
         if(FailedIfNotActivePos())
            return;
         if(pos.UsingStopLoss())
         {
            stopOrder = pos.StopOrder();
            stopId = stopOrder.GetId();
         }
         else
         {
            status = TASK_STATUS_FAILED;
            taskLog.Status(status);
            taskLog.AddRedcode(TARGET_CREATE_TASK, TRADE_RETCODE_INVALID_STOPS);
            return;
         }
         double price = stopOrder.PriceSetup();
         AddTarget(new TargetDeletePendingOrder(stopId, asynchMode));
         ENUM_ORDER_TYPE orderType = ORDER_TYPE_SELL;
         if(pos.Direction() == DIRECTION_LONG)
            orderType = ORDER_TYPE_SELL_STOP;
         if(pos.Direction() == DIRECTION_SHORT)
            orderType = ORDER_TYPE_BUY_STOP;
         Order* initOrder = pos.EntryOrder();
         ulong magic = initOrder.GetMagic(MAGIC_TYPE_SL);
         AddTarget(new TargetSetPendingOrder(pos.Symbol(), orderType, pos.VolumeExecuted(), price, comment, magic, true));
      }  
      private:
         string oldComment;
};

class TaskSetStopLoss : public Task2
{
   public:
      TaskSetStopLoss(Position* pos, double price, bool asynchMode) : Task2(pos, asynchMode)
      {
         if(FailedIfNotActivePos())
            return;
         if(pos.UsingStopLoss())
         {
            status = TASK_STATUS_FAILED;
            taskLog.Status(status);
            taskLog.AddRedcode(TARGET_CREATE_TASK, TRADE_RETCODE_INVALID_STOPS);
            return;
         }
         ENUM_ORDER_TYPE orderType = ORDER_TYPE_SELL;
         if(pos.Direction() == DIRECTION_LONG)
            orderType = ORDER_TYPE_SELL_STOP;
         if(pos.Direction() == DIRECTION_SHORT)
            orderType = ORDER_TYPE_BUY_STOP;
         Order* initOrder = pos.EntryOrder();
         ulong magic = initOrder.GetMagic(MAGIC_TYPE_SL);
         AddTarget(new TargetSetPendingOrder(pos.Symbol(), orderType, pos.VolumeExecuted(), price, pos.ExitComment(), magic, asynchMode));
      }
};

///
/// ������������ ������� ������ ����-�����.
///
class TaskModifyStop : public Task2
{
   public:
      TaskModifyStop(Position* pos, double newPrice, bool asynchMode) : Task2(pos, asynchMode)
      {
         ulong stopId = 0;
         Order* stopOrder;
         if(FailedIfNotActivePos())
            return;
         if(pos.UsingStopLoss())
         {
            stopOrder = pos.StopOrder();
            stopId = stopOrder.GetId();
            AddTarget(new TargetModifyPendingOrder(stopId, newPrice, asynchMode));
         }
         else
         {
            status = TASK_STATUS_FAILED;
            taskLog.Status(status);
            taskLog.AddRedcode(TARGET_CREATE_TASK, TRADE_RETCODE_INVALID_STOPS);
         }
      }
};

///
/// ��������� �������� �������.
///
class TaskClosePosition : public Task2
{
   public:
      TaskClosePosition(Position* pos, ENUM_MAGIC_TYPE type, ulong deviation, bool asynchMode) : Task2(pos, asynchMode)
      {
         ENUM_DIRECTION_TYPE dir = pos.Direction() == DIRECTION_LONG ? DIRECTION_SHORT: DIRECTION_LONG;
         Order* initOrder = pos.EntryOrder();
         ulong magic = initOrder.GetMagic(type);
         if(FailedIfNotActivePos())
            return;
         if(pos.UsingStopLoss())
         {
            Order* slOrder = pos.StopOrder();
            AddTarget(new TargetDeletePendingOrder(slOrder.GetId(), asynchMode));
         }
         AddTarget(new TargetTradeByMarket(pos.Symbol(), dir, pos.VolumeExecuted(), deviation, pos.ExitComment(), magic, true));
      }
};

///
/// ��������� ����� �������� �������.
///
class TaskClosePartPosition : public Task2
{
   public:
      ///
      /// ��������� ������ �� �������� ����� �������� �������.
      /// \param pos - �������, ����� ������ ������� ��������� �������.
      /// \param volume - �����, ������� ��������� �������.
      ///
      TaskClosePartPosition(Position* pos, double volume, ulong deviation, bool asynchMode, ENUM_CLOSE_TYPE closeType = CLOSE_AS_MARKET) : Task2(pos, asynchMode)
      {
         if(FailedIfNotActivePos())
            return;
         if(volume > pos.VolumeExecuted())
         {
            status = TASK_STATUS_FAILED;
            taskLog.Status(status);
            taskLog.AddRedcode(TARGET_CREATE_TASK, TRADE_RETCODE_INVALID_VOLUME);
            return;
         }
         Order* slOrder;
         if(pos.UsingStopLoss())
         {
            stopLevel = pos.StopLossLevel();
            slOrder = pos.StopOrder();
            AddTarget(new TargetDeletePendingOrder(slOrder.GetId(), asynchMode));
         }
         ENUM_DIRECTION_TYPE dir = pos.Direction() == DIRECTION_LONG ? DIRECTION_SHORT: DIRECTION_LONG;
         Order* initOrder = pos.EntryOrder();
         ENUM_MAGIC_TYPE mgType = MAGIC_TYPE_MARKET;
         switch(closeType)
         {
            case CLOSE_AS_MARKET:
               mgType = MAGIC_TYPE_MARKET;
               break;
            case CLOSE_AS_STOP_LOSS:
               mgType = MAGIC_TYPE_SL;
               break;
            case CLOSE_AS_TAKE_PROFIT:
               mgType = MAGIC_TYPE_TP;
               break;
         }
         ulong magic = initOrder.GetMagic(mgType);
         AddTarget(new TargetTradeByMarket(pos.Symbol(), dir, volume, deviation, pos.ExitComment(), magic, asynchMode));
         //��������������� ���� ����� ���� ����������.
         if(pos.UsingStopLoss() && volume < pos.VolumeExecuted())
         {
            ENUM_ORDER_TYPE type = pos.Direction() == DIRECTION_LONG ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_BUY_STOP;
            magic = initOrder.GetMagic(MAGIC_TYPE_SL);
            double nVol = pos.VolumeExecuted() - volume;
            AddTarget(new TargetSetPendingOrder(pos.Symbol(), type, nVol, stopLevel, slOrder.Comment(),  magic, asynchMode));
         }
      }
   private:
      ///
      /// ����������� ������� ����-�����.
      ///
      double stopLevel;
};