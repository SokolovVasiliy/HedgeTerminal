#include "Transaction.mqh"
#include "Methods.mqh"

///
/// �������������� ��������
///
enum ENUM_TARGET_TYPE
{
   ///
   /// �������� ����������� ������.
   ///
   TARGET_DELETE_PENDING_ORDER
};

///
/// ������ ���������� ��������� (�������).
///
enum ENUM_TARGET_STATUS
{
   ///
   /// ��������� ��������� � ������ �������� � ������ � ����������.
   ///
   TARGET_STATUS_WAITING,
   ///
   /// ��������� ��������� � �������� ����������. ������� ����������� ����� �������.
   ///
   TARGET_STATUS_EXECUTING,
   ///
   /// ��������� ��������� �������.
   ///
   TARGET_STATUS_COMLETE,
   ///
   /// ���������� ��������� ����������� ��������. 
   ///
   TARGET_STATUS_FAILED,
};

///
/// ������ - ����������� ���������. ��������� - ��� ������������������� ����� �� �������� ����������. 
///
class Target : CObject
{
   public:
      bool Execute()
      {
         if(status != TARGET_STATUS_WAITING)
            LogWriter(EnumToString(type) + ": State target (" + EnumToString(status) + ") not support executing.", MESSAGE_TYPE_ERROR);
         bool res = OnExecute();
         attempsMade++;
         return res;
      }
      ///
      /// ������, ���� ������� ������� ��������� ��������.
      ///
      bool IsFailed()
      {
         if(status == TARGET_STATUS_FAILED)
            return true;
         return false;
      }
      ///
      /// ������, ���� �������� ����� ���������, ���� - � ��������� ������.
      ///
      /*bool IsPerform()
      {
         return attempsMade < attempsAll;
      }*/
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
      /// ���������� ������������� ����������.
      ///
      ENUM_TARGET_TYPE TargetType(void){return type;}
      ///
      /// ���������� ������ �������.
      ///
      ENUM_TARGET_STATUS Status()
      {
         return status;
      }
      ///
      /// ��������� ����� ��������� �� �������� �������. ����� ������ ������� ������������ - ���������� ���������� ���������.
      ///
      virtual void Event(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REFRESH:
               Timeout();
               break;
            default:
               OnEvent(event);
               break;
         }
      }
      
      ///
      /// ������, ���� ����� �������� �� ���������� �������� ��������� � ���� � � ��������� ������.
      ///
      bool Timeout()
      {
         if(timeBegin <= 0)return false;
         if((TimeCurrent() - timeBegin) > timeoutSec)
         {
            status = TARGET_STATUS_FAILED;
            return true;
         }
         return false;
      }
   protected:
      Target(ENUM_TARGET_TYPE target_type)
      {
         attempsAll = 1;
         type = target_type;
         //��-��������� ���������� ��� ������ �� ����������.
         timeoutSec = 3*60;
      }
      ///
      ///
      ///
      virtual bool OnExecute(){return true;}
      ///
      ///
      ///
      virtual void OnEvent(Event* event){;}
      ///
      /// ������ �������.
      ///
      ENUM_TARGET_STATUS status;
   private:
      ///
      /// ������������� �������.
      ///
      ENUM_TARGET_TYPE type;
      ///
      /// �������� ���������� ����������� �������.
      ///
      int attempsMade;
      ///
      /// �������� ���������� ����������� �������.
      ///
      int attempsAll;
      ///
      /// ����� ������ ���������� ��������.
      ///
      datetime timeBegin;
      ///
      /// ����� � ��������, ������� ������ �� ���������� ���������.
      ///
      int timeoutSec;
};

///
/// ������ - ������� ���������� �����.
///
class TargetDeletePendingOrder : public Target
{
   public:
      TargetDeletePendingOrder(ulong order_id, bool asynch_mode) : Target(TARGET_DELETE_PENDING_ORDER)
      {
         method = new MethodDeletePendingOrder(order_id, asynch_mode);
      }
      ~TargetDeletePendingOrder()
      {
         delete method;
      }
      
   private:
      ///
      /// ������� ���������� �����.
      ///
      virtual bool OnExecute()
      {
         bool res = false;
         if(!IsSuccess())
            res = method.Execute();
         if(res)
            status = TARGET_STATUS_EXECUTING;
         else
            status = TARGET_STATUS_FAILED;
         return res;
      }
      ///
      /// ������, ���� ����������� ������ � order_id �� ����������, � ���� � ��������� ������.
      ///
      virtual bool IsSuccess()
      {
         if(OrderSelect(method.OrderId()))
            return false;
         status = TARGET_STATUS_COMLETE;
         return true;
      }
      
      ///
      /// ���� ������������� �� �������� ���� ������ ��������.
      ///
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REQUEST_NOTICE:
               OnRequestNotice(event);
               break;
            case EVENT_CHANGE_POS:
               OnPosChanged();
               break;
         }
      }
      ///
      /// ������������ �������.
      ///
      void OnRequestNotice(EventRequestNotice* event)
      {
         TradeRequest* request = event.GetRequest();
         if(request.order != method.OrderId())
            return;
         TradeResult* result = event.GetResult();
         //������ ��� ��������� - ��������� ��������� ��������.
         if(result.IsRejected())
            status = TARGET_STATUS_FAILED;
      }
      ///
      /// ��������� �� ��������� �������.
      ///
      void OnPosChanged()
      {
         if(IsSuccess())
            status = TARGET_STATUS_COMLETE;
      }
      MethodDeletePendingOrder* method;
};
