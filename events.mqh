/*
  �������������� ������� � �� ���������
*/
enum ENUM_EVENT_DIRECTION
{
   ///
   /// ������� �������. ���� �� �������� ���� �� �������.
   ///
   EVENT_EXTERN,
   ///
   /// ���������� �������. ���� �� ������� ���� � ����� �������� ��������.
   ///
   EVENT_INNER
};
///
/// 
///
#define EVENT_INER 1
///
/// ������������� ������� "������ ������������ ���� �������".
///
#define EVENT_NODE_RESIZE 0
///
/// ������������� ������� "����������� ���� ����������".
///
#define EVENT_NODE_MOVE 1
///
/// ������������� ������� "��������� ������������ ���� ��������".
///
#define EVENT_NODE_VISIBLE 2
///
/// ������������� ������� "����� ���".
///
#define EVENT_NEW_TICK 3

///
/// <b>����������� ������� ����� �������.</b> ����� ������������ ������� ������ ����� ���� ���������� �������������,
/// � ����� ���������� ��� ������������ ����, ������� ��� ������� ��������.
///
class Event
{
   public:
      ///
      /// ���������� ����������� �������� �������.
      ///
      ENUM_EVENT_DIRECTION Direction()
      {
         return eventDirection;
      }
      int GetEventId(){return eventId;}
      ///
      /// ����� ���������� ������ �� �������, ����������� �������� ���
      /// ������������ ����, ������� ��� ������� ���������������.
      ///
      string GetNameNodeId(){return nameNodeId;}
   // �������������� ������� ����� ����� ������ ��� �������, �.�. ����� �������� ����������� �
   // ��� ����������� ������� �� �������� ������.
   protected:
      ///
      /// ��� �������� ���������� ������ �� �������, ���������� ��� �������,
      /// ������� ���������� ������������� ������� � ��� ������������ ����
      /// ������� ��� ���������������.
      ///
      Event(ENUM_EVENT_DIRECTION myeventDirection ,int myeventId, string nameNode)
      {
         eventDirection = myeventDirection;
         eventId = myeventId;
         nameNodeId = nameNode;
      }
   private:
      ENUM_EVENT_DIRECTION eventDirection;
      int eventId;
      string nameNodeId;
};
///
/// ��������� ������� EVENT_NODE_VISIBLE
///
class EventVisible : Event
{
   public:
      bool GetVisible(){return isVisible;}
      EventVisible(ENUM_EVENT_DIRECTION myeventDirection, int myEventId, string mynameId, bool visible) :
      Event(myeventDirection, myEventId, mynameId)
      {
         isVisible = visible;
      }
   private:
      bool isVisible;
};
///
/// ��������� ������� EVENT_NODE_RESIZE
///
class EventResize : Event
{
   public:
      long GetNewWidth(){return myWidth;}
      long GetNewHigh(){return myHigh;}
      EventResize(ENUM_EVENT_DIRECTION myeventDirection, int myEventId, string mynameId ,long newWidth, long newHigh) :
      Event(myeventDirection, myEventId, mynameId)
      {
         myWidth = newWidth;
         myHigh = newHigh;
      }
   private:
      long myWidth;
      long myHigh;
};
///
/// ��������� ������� EVENT_NEW_TICK
///
class EventNewTick : Event
{
   public:
      double GetNewTick(){return myTick;}
      EventNewTick(ENUM_EVENT_DIRECTION myeventDirection, int myEventId, string mynameId , double newTick) :
      Event(myeventDirection, myEventId, mynameId)
      {
         myTick = newTick;
      }
   private:
      double myTick;
};