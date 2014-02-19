#include "Tasks2.mqh"
/*
  Target - �������� ������������ ����� � ���������� �� �������� ����������.
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
/// ������ ����.
///
enum ENUM_TARGET_STATUS
{
   ///
   /// ���� ����� ����������.
   ///
   TARGET_STATUS_MAKE,
   ///
   /// ���������� ���� ����������� ��������.
   ///
   TARGET_STATUS_FAILED,
   ///
   /// ���� ������� ����������.
   ///
   TARGET_STATUS_COMPLETE
};

///
///
/// Target - �������� ���� ������������ ��������.
///
class Target
{
   public:
      bool Execute()
      {
         return OnExecute();
      }
      ///
      /// ���� ����� ��������� �� �������� �������. ����� ������ ������� ������������ - ���������� �������.
      ///
      virtual void Event(Event* event){;}
      
      ENUM_TARGET_STATUS Status(){return status;}
      ///
      /// ���������� ������, ���� ��������� �������� ���� ��������� ������� � ����
      /// � ��������� ������.
      ///
      virtual bool SuccessLastOp(){return false;}
   protected:
      virtual bool OnExecute()
      {
         return false;
      }
      Target(){;}
      Target(Position* pos)
      {
         position = pos;
      }
      ENUM_TARGET_STATUS status;
      ///
      /// �������, ��� ������� ����� ����������� ������.
      ///
      Position* position;
};

///
/// ������� ����-���� �������.
///
class TargetDeleteStopLoss : public Target
{
   public:
      TargetDeleteStopLoss(Position* pos, bool asynch_mode) : Target(pos){;}
      ~TargetDeleteStopLoss()
      {
         if(CheckPointer(task) != POINTER_INVALID)
            delete task;
      }
   private:
      virtual bool OnExecute()
      {
         // ���� ������� �� ���������� ����-���� - ���� ������� ����������.
         if(CheckDeletePendingOrder())
         {
            status = TARGET_STATUS_COMPLETE;
            return true;
         }
         if(task == NULL)
         {
            Order* slOrder = position.StopOrder();
            orderId = slOrder.GetId();
            task = new TaskDeletePendingOrder(orderId, true);
         }
         if(!task.IsPerform())
         {
            status = TARGET_STATUS_FAILED;
            return false;
         }
         return task.Execute();
      }
      
      virtual bool SuccessLastOp()
      {
         switch(lastTask)
         {
            case TASK_DELETE_PENDING_ORDER:
               return CheckDeletePendingOrder();
         }
         return false;
      }
      ///
      /// ������, ���� ������� �� ���������� ����-����� � ���� � ��������� ������.
      ///
      bool CheckDeletePendingOrder()
      {
         if(position.UsingStopLoss())
            return false;
         else
            return true;
      }
      
      virtual void Event(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
               break;
            case EVENT_CHANGE_POS:
               OnChangePos(event);
               break;
         }
      }
      ///
      /// ������������ ��������� ������.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeRequest* request = event.GetRequest();
         if(request.order != orderId)return;
         TradeResult* result = event.GetResult();
         //������ �� �������� ������ ��� ���������?
         if(result.IsRejected())
         {
            status = TARGET_STATUS_FAILED;
            //position.
         }
      }
      void OnChangePos(EventPositionChanged* event)
      {
         
      }
      
      TaskDeletePendingOrder * task;
      ///
      /// ����, ����������� �� ������������� ������������ ������.
      ///
      bool asynchMode;
      ///
      /// ������������� ��������� ������, ������� ���� �������� �� ����������.
      ///
      ENUM_TASK_TYPE lastTask;
      ///
      /// ������������� ������, ������� ���������� �������.
      ///
      ulong orderId;
      
};