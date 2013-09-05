#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include "events.mqh"


class ProtoNode : CObject
{
   public:
      ///
      /// ������������� ����� ������ �������� ������������ ����. ���������� ���������� � ���������� ������� EventResize
      ///
      void Resize(int newWidth, int newHigh)
      {
         // 1) ���������, �������� �� ����� �������� ������� �����������,
         // �� ����� �� �������� ������� ����������� ���� �� �������
         // ������ ������������� ����.
         //
         // 2) ������������� ����������� ����.
         //
         // 3) ������, ����� ������ ���� �������, ��������� �������� ������ ��� �����������.
         // ��� ����� ��������� � ���� ���� ����������� �����-�������, ������� ����������
         // ��� ������������ ������ �����������.
         //���������� ���������� � ���������� ������� "������ �������".
         EventSend(new EventResize(EVENT_EXTERN, EVENT_NODE_RESIZE, nameId, newWidth, newHigh));
         EventSend(new EventResize(EVENT_INNER, EVENT_NODE_RESIZE, nameId, newWidth, newHigh));
      }      
      ///
      /// ���� ��������� �������. ������� ����� ���������� �������� �������� ������,
      /// ����, ���� ��� ��� ���� ��� ���������������� �����������, �������� ����������� �������
      /// ������������ ������.
      ///
      void Event(Event* newEvent)
      {
         //���������� ��������� ������� ����������� ����������.
         OnEvent(newEvent);
         EventSend(newEvent);
      }
   protected:
      ///
      /// ���������� �������, ������� ��������� ���������� ��������� ������������ ����. 
      ///
      virtual void OnEvent(Event* newEvent)
      {
         ;
      }
      
      ///
      /// ��������� �� ������������ ����������� ����.
      ///
      ProtoNode *parentNode;
      ///
      /// �������� ����������� ����.
      ///
      CArrayObj childNodes;
   private:
      ///
      /// ������, ���� ������� �������� ��� ����� �������� ��� ���������.
      ///
      bool isExternCall;
      ///
      /// ���������� ���-������������� ������������ ����.
      ///
      string nameId;
      ///
      /// �������� ������� � �����������, ��������� � ��� ����.
      ///
      void EventSend(Event* event)
      {
         //������� ���� ������-����.
         if(event.Direction() == EVENT_EXTERN)
         {
            ProtoNode* node;
            for(int i = 0; i < childNodes.Total(); i++)
            {
               node = childNodes.At(i);
               node.Event(event);
            }
         }
         //������� ���� �����-�����.
         if(event.Direction() == EVENT_INNER)
         {
            if(parentNode != NULL)
               parentNode.Event(event);
         }
      }
};

class TNode : CObject
{
   public:
      ///
      /// �������� ������ �������� ������������ ���� �� �����.
      ///
      void Resize(int newWidth, int newHigh)
      {
         //���������, ��������� �� ����� ������������� ������������
         //������� �������� ������ �������� ���� �� ���������.
         //if(parentNode != NULL)
         //...
         //������ ������������ ���������� ������� ������.
         OnResize(newWidth, newHigh);
         // ���������� ������������ ����������� ������, � ���,
         // ��� ���� ������� ���� ��������. �� ������ � ��� ������,
         // ����� ��������� �������� ������������ ����� ��������.
         if(parentNode != NULL)
         {
            parentNode.OnChildResize(newWidth, newHigh, nameId);
            parentNode.nameId = "sssss";
         }
      }
      
   protected:
      ///
      /// ����������, ����� ���� �������� ������������ ������� ������� ���� ������.
      /// ������ ���� ������� ������������� ��� �������� ��������, �������� �
      /// ����������� ������-�������, � ������������ � ��� �������.
      ///
      virtual void OnResize(int newWidth, int newHigh){;}
      ///
      /// ��������� ����������� �� ��������� ������������ ��������, � ���,
      /// ��� ��� ������� ���� ��������.
      ///
      void OnChildResize(int newWidth, int newHigh, string ChildNameId)
      {
         ;
      }
      ///
      /// ����������, ����� ���� �������� ������������ ������� ���� ����� �� ������� ���
      /// ����� � ����.
      ///
      virtual void OnVisible(bool isVisible){;}
   private:
      ///
      /// ��������� �� ������������ ����������� ������.
      ///
      TNode* parentNode;
      ///
      /// ���������� ���-������������� ������������ �������, �������� ��� ���������� ��� �� �������.
      ///
      string nameId;
      
};
///
/// ����� "������������� �����".
///
class Shape : public ProtoNode
{
   ;
};

void MoveShape()
{
   Shape myShape;
   ProtoNode pNode;
   pNode.Resize(10, 20);
   myShape.Resize(10, 10);
   myShape.Resize(30, 50);
}
