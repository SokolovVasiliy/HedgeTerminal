#include "defines.mqh"
#include  "gelements.mqh"

/*
  �������������� ������� � �� ���������
*/

//#define TERMINAL_IDNAME "dddd"
enum ENUM_EVENT_DIRECTION
{
   ///
   /// ������� �������. ���� �� �������� ���� � �������.
   ///
   EVENT_FROM_UP,
   ///
   /// ���������� �������. ���� �� ������� ���� � ��������.
   ///
   EVENT_FROM_DOWN
};
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
/// ������������� ������� "������������� ��������".
///
#define EVENT_INIT 4
///
/// ������������� ������� "��������������� ��������".
///
#define EVENT_DEINIT 5
///
/// ������������� ������� "��������� � ������ ������������� ���� �������"
///
#define EVENT_CHSTATUS 6
///
/// ������������� ������� "������".
///
#define EVENT_NODE_COMMAND 7
///
/// ������������� ������� "������� ����� �������".
///
#define EVENT_CREATE_NEWPOS 8
///
/// ������������� ������� �������� ������� ��������
///
#define EVENT_CHANGE_POS 9 
///
/// ������������� ������� ������.
///
#define EVENT_TIMER 10

///
/// ������������� ������� ���������� ������.
///
#define EVENT_REFRESH 11

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
      int EventId(){return eventId;}
      ///
      /// ����� ���������� ������ �� �������, ����������� �������� ���
      /// ������������ ����, ������� ��� ������� ���������������.
      ///
      string NameNodeId(){return nameNodeId;}
      ///
      /// ������� ������ ����� ������� � ���������� ������ ��� ����.
      ///
      virtual Event* Clone()
      {
         return new Event(eventDirection, eventId, nameNodeId);
      }
      
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
/// ������� EVENT_NODE_VISIBLE
///
class EventVisible : Event
{
   public:
      bool Visible(){return isVisible;}
      EventVisible(ENUM_EVENT_DIRECTION myeventDirection, string mynameId, bool visible) :
      Event(myeventDirection, EVENT_NODE_VISIBLE, mynameId)
      {
         isVisible = visible;
      }
      virtual Event* Clone()
      {
         return new EventVisible(Direction(), NameNodeId(), isVisible);
      }
   private:
      bool isVisible;
};
///
/// ������� EVENT_NODE_RESIZE
///
class EventResize : Event
{
   public:
      long NewWidth(){return myWidth;}
      long NewHigh(){return myHigh;}
      EventResize(ENUM_EVENT_DIRECTION myeventDirection, string mynameId ,long newWidth, long newHigh) :
      Event(myeventDirection, EVENT_NODE_RESIZE, mynameId)
      {
         myWidth = newWidth;
         myHigh = newHigh;
      }
      virtual Event* Clone()
      {
         return new EventResize(Direction(), NameNodeId(), myWidth, myHigh);
      }
   private:
      long myWidth;
      long myHigh;
};
///
/// ������� EVENT_NODE_MOVE
///
class EventMove : Event
{
   public:
      long XDist(){return xDist;}
      long YDist(){return yDist;}
      ENUM_COOR_CONTEXT Context(){return context;}
      EventMove(ENUM_EVENT_DIRECTION eventDir, string mynameId ,long myXDist, long myYDist, ENUM_COOR_CONTEXT myContext):
      Event(eventDir, EVENT_NODE_MOVE, mynameId)
      {
         xDist = myXDist;
         yDist = myYDist;
         context = myContext;
      }
      virtual Event* Clone()
      {
         return new EventMove(Direction(), NameNodeId(), xDist, yDist, context);
      }
   private:
      long xDist;
      long yDist;
      ENUM_COOR_CONTEXT context;
};
///
/// ������� EVENT_NEW_TICK
///
class EventNewTick : Event
{
   public:
      double GetNewTick(){return myTick;}
      EventNewTick(ENUM_EVENT_DIRECTION myeventDirection, string mynameId , double newTick) :
      Event(myeventDirection, EVENT_NEW_TICK, mynameId)
      {
         myTick = newTick;
      }
      virtual Event* Clone()
      {
         return new EventNewTick(Direction(), NameNodeId(), myTick);
      }
   private:
      double myTick;
};

class EventInit : Event
{
   public:
      virtual Event* Clone()
      {
         return new EventInit();
      }
      EventInit():
      Event(EVENT_FROM_UP, EVENT_INIT, "TERMINAL_WINDOW"){;}
};
///
/// ������� "��������������� ���������".
///
class EventDeinit : Event
{
   public:
      virtual Event* Clone()
      {
         return new EventDeinit();
      }
      EventDeinit():
      Event(EVENT_FROM_UP, EVENT_DEINIT, "TERMINAL_WINDOW"){;}
};
///
/// ������� "������ (���������, ������, ���������) ������������ ���� �������".
///
class EventNodeStatus : Event
{
   public:
      virtual Event* Clone()
      {
         return new EventNodeStatus(Direction(), NameNodeId(), visible, xDist, yDist, width, high);
      }
      long XDist(){return xDist;}
      long YDist(){return yDist;}
      long Width(){return width;}
      long High(){return high;}
      bool Visible(){return visible;}
      EventNodeStatus(ENUM_EVENT_DIRECTION myDir, string nodeId, bool isVisible, long newXDist, long newYDist, long newWidth, long newHigh):
      Event(myDir, EVENT_CHSTATUS, nodeId)
      {
         visible = isVisible;
         width = newWidth;
         high = newHigh;
         xDist = newXDist;
         yDist = newYDist;
      }
   private:
      ///
      /// ������ ��������� �������.
      ///
      bool visible;
      ///
      /// ������ ���� � �������.
      ///
      long width;
      ///
      /// ������ ���� � �������.
      ///
      long high;
      ///
      /// ���������� ������������ ����������.
      ///
      long xDist;
      ///
      /// ���������� �������������� ����������.
      ///
      long yDist;
};

///
/// ������� �������� ������ �� ��������� �������� ���� � ��������������� ���������.
///
class EventNodeCommand : public Event
{
   public:
      virtual Event* Clone()
      {
         return new EventNodeCommand(Direction(), NameNodeId(), visible, xDist, yDist, width, high);
      }
      long XDist(){return xDist;}
      long YDist(){return yDist;}
      long Width(){return width;}
      long High(){return high;}
      bool Visible(){return visible;}
      EventNodeCommand(ENUM_EVENT_DIRECTION myDir, string nodeId, bool isVisible, long newXDist, long newYDist, long newWidth, long newHigh):
      Event(myDir, EVENT_NODE_COMMAND, nodeId)
      {
         visible = isVisible;
         width = newWidth;
         high = newHigh;
         xDist = newXDist;
         yDist = newYDist;
      }
   private:
      ///
      /// ������ ��������� �������.
      ///
      bool visible;
      ///
      /// ������ ���� � �������.
      ///
      long width;
      ///
      /// ������ ���� � �������.
      ///
      long high;
      ///
      /// ���������� ������������ ����������.
      ///
      long xDist;
      ///
      /// ���������� �������������� ����������.
      ///
      long yDist;
};

///
/// ������� "��������� ������� ����������".
///
class EventChangeStatePos : public Event
{
   public:
      EventChangeStatePos(ENUM_EVENT_DIRECTION myDir, string nodeId, Position* myPos):
      Event(myDir, EVENT_CHANGE_POS, nodeId)
      {
         pos = myPos;
      }
      virtual Event* Clone()
      {
         return new EventChangeStatePos(Direction(), NameNodeId(), pos);
      }
      Position* GetPosition(){return pos;}
   private:
      Position* pos;
};

///
/// �������, ������������ � ������� ��������������. ��������� � ������� OnTimer()
///
class EventTimer : public Event
{
   public:
      EventTimer(int myRefreshRate):Event(EVENT_FROM_UP, EVENT_TIMER, "TERMINAL")
      {
         refreshRate = myRefreshRate;
      }
      virtual Event* Clone()
      {
         EventTimer* timer = new EventTimer(refreshRate);
         return timer;
      }
   private:
      int refreshRate;
};

class EventRefresh : public Event
{
   public:
      EventRefresh(ENUM_EVENT_DIRECTION Dir, string nameNodeId):
      Event(Dir, EVENT_REFRESH, nameNodeId){;}
};

