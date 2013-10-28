#include <Arrays\ArrayObj.mqh>
/*
  �������������� ������� � �� ���������
*/
///
/// �����-������� ����������� ������������ ��������� ���� ����������� �������.
///
class EventExchange
{
   public:
      static void PushEvent(Event* myEvent)
      {
         if(api != NULL)
            api.Event(myEvent);
         if(panel != NULL)
            panel.Event(myEvent);
      }
      static Event* PopEvent()
      {
         return event;
      }
      static void DeleteEvent()
      {
         event = NULL;
      }
      static void Add(CHedge* myHedge)
      {
         api = myHedge;
      }
      static void Add(ProtoNode* node)
      {
         panel = node;
      }
   private:
      void ExecuteEvent()
      {
         ;
      }
      static Event* event;
      static CHedge* api;
      static ProtoNode* panel;
};

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
enum ENUM_EVENT
{
   ///
   /// ������������� ������� "������ ������������ ���� �������".
   ///
   EVENT_NODE_RESIZE,
   ///
   /// ������������� ������� "����������� ���� ����������".
   ///   
   EVENT_NODE_MOVE,
   ///
   /// ������������� ������� "��������� ������������ ���� ��������".
   ///
   EVENT_NODE_VISIBLE,
   ///
   /// ������������� ������� "����� ���".
   ///  
   EVENT_NEW_TICK,
   ///
   /// ������������� ������� "������������� ��������".
   ///   
   EVENT_INIT,
   ///
   /// ������������� ������� "��������������� ��������".
   ///
   EVENT_DEINIT,
   ///
   /// ������������� ������� "������".
   ///
   EVENT_NODE_COMMAND,
   ///
   /// ������������� ������� "������� ����� �������".
   ///
   EVENT_CREATE_NEWPOS,
   ///
   /// ������������� ������� �������� ������� ��������.
   ///
   EVENT_CHANGE_POS,
   ///
   /// ������� �� �������� �������.
   ///
   EVENT_DEL_POS,
   ///
   /// ������������� ������� "������� ���������".
   ///
   EVENT_CLOSE_POS,
   ///
   /// ������������� ������� ������.
   ///
   EVENT_TIMER,
   ///
   /// ������������� ������� ���������� ������.
   ///
   EVENT_REFRESH,
   ///
   /// ������������� ������� "������ ������".
   ///
   EVENT_PUSH,
   ///
   /// ������������� ������� "������ ��������/�������".
   ///
   EVENT_COLLAPSE_TREE,
   ///
   /// ������������� ������� �������� ����������� ����.
   ///
   EVENT_REDRAW,
   ///
   /// ������������� ������� "��������� ���� ��������".
   ///
   EVENT_MOUSE_MOVE,
   ///
   /// ������������� ������� "������ ������������ �������� CheckBox ��������".
   ///
   EVENT_CHECK_BOX_CHANGED
};


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
      /// ���������� ��������� �� ����, ��������������� �������. ������� ����� �� �����
      /// ���������������� ��� ���� (�������� ��� ��������� ������� OnChartEvent), ���
      /// ���� ����� �� ���� ������ �� ����. � ���� ������, ����� ������ �������� NULL.
      ///
      ProtoNode* Node(){return node;}
      ///
      /// ������� ������ ����� ������� � ���������� ������ ��� ����.
      ///
      virtual Event* Clone()
      {
         return new Event(eventDirection, eventId, nameNodeId);
      }
      ///
      /// ���������� ���������� ���������� ��������� � ������� ������� ��������� �� ������� �������� �������.
      ///
      uint TickCount(){return tickCount;}
   // �������������� ������� ����� ����� ������ ��� �������, �.�. ����� �������� ����������� �
   // ��� ����������� ������� �� �������� ������.
   protected:
      ///
      /// ��� �������� ���������� ������ �� �������, ���������� ��� �������,
      /// ������� ���������� ������������� ������� � ��� ������������ ����
      /// ������� ��� ���������������.
      ///
      Event(ENUM_EVENT_DIRECTION myeventDirection ,ENUM_EVENT myeventId, string nameNode)
      {
         eventDirection = myeventDirection;
         eventId = myeventId;
         nameNodeId = nameNode;
         tickCount = GetTickCount();
      }
      ///
      /// ������� ����� �������, � ���������� �� ����, ������� ��� ������������.
      /// \param myDirection - �����������, �� �������� ���������������� �������.
      /// \param myEventId - ������������� �������.
      /// \param myNode - �������� ��������� �� ����, ��������������� �������.
      ///
      Event(ENUM_EVENT_DIRECTION myDirection, ENUM_EVENT myEventId, ProtoNode* myNode)
      {
         eventDirection = myDirection;
         eventId = myEventId;
         nameNodeId = myNode.NameID();
         node = myNode;
         tickCount = GetTickCount();
      }
   private:
      ///
      /// ����������� �������.
      ///
      ENUM_EVENT_DIRECTION eventDirection;
      ///
      /// ������������� �������.
      ///
      ENUM_EVENT eventId;
      ///
      /// ��� ����, ��������������� �������.
      ///
      string nameNodeId;
      ///
      /// ���������� ����������, ��������� � ������� ������� ��������� �� �������� �������.
      ///
      uint tickCount;
      ///
      /// ��������� �� ��������� ����, ��������������� �������.
      ///
      ProtoNode* node;
};



///
/// ������� EVENT_NODE_VISIBLE
///
class EventVisible : public Event
{
   public:
      bool Visible(){return isVisible;}
      /*EventVisible(ENUM_EVENT_DIRECTION myeventDirection, string mynameId, bool visible) :
      Event(myeventDirection, EVENT_NODE_VISIBLE, mynameId)
      {
         isVisible = visible;
      }*/
      EventVisible(ENUM_EVENT_DIRECTION myeventDirection, ProtoNode* myNode, bool visible) :
      Event(myeventDirection, EVENT_NODE_VISIBLE, myNode)
      {
         isVisible = visible;
      }
      virtual Event* Clone()
      {
         return new EventVisible(Direction(), Node(), isVisible);
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
/*class EventChangeStatePos : public Event
{
   public:
      EventChangeStatePos(ENUM_EVENT_DIRECTION myDir, string nodeId, CArrayObj* myPos):
      Event(myDir, EVENT_CHANGE_POS, nodeId)
      {
         pos = myPos;
      }
      virtual Event* Clone()
      {
         return new EventChangeStatePos(Direction(), NameNodeId(), pos);
      }
      CArrayObj* GetPositions(){return pos;}
   private:
      ///
      /// ������ ������������ �������
      ///
      CArrayObj* pos;
};*/

///
/// ������� "����� ������� �������".
///
class EventCreatePos : public Event
{
   public:
      EventCreatePos(ENUM_EVENT_DIRECTION myDir, string nodeId, Position* myPos):
      Event(myDir, EVENT_CREATE_NEWPOS, nodeId)
      {
         pos = myPos;
      }
      virtual Event* Clone()
      {
         return new EventCreatePos(Direction(), NameNodeId(), pos);
      }
      Position* GetPosition(){return pos;}
   private:
      ///
      /// ������ ������������ �������
      ///
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
      EventRefresh(ENUM_EVENT_DIRECTION Dir, string nodeId):
      Event(Dir, EVENT_REFRESH, nodeId){;}
};

class EventPush : public Event
{
   public:
      EventPush(string pushName): Event(EVENT_FROM_UP, EVENT_PUSH, "TERMINAL WINDOW")
      {
         pushObjName = pushName;
      }
      ///
      /// ���������� �������� �������, �� �������� ���� ����������� �������.
      ///
      string PushObjName(){return pushObjName;}
      virtual Event* Clone()
      {
         return new EventPush(pushObjName);
      }
   private:
      ///
      /// ������ �������� ����, �� �������� ���� ����������� �������.
      ///
      string pushObjName;
};

///
/// ������� �� �������� �������.
///
class EventDelPos : public Event
{
   public:
      EventDelPos(ulong posId, string nodeId) : Event(EVENT_FROM_DOWN, EVENT_DEL_POS, nodeId)
      {
         positionId = posId;
      }
      virtual Event* Clone()
      {
         return new EventDelPos(positionId, NameNodeId());
      }
   private:
      ulong positionId;
};

class EventCollapseTree : public Event
{
   public:
      EventCollapseTree(ENUM_EVENT_DIRECTION myDir, ProtoNode* myNode, bool isCollapse) : Event(EVENT_FROM_DOWN, EVENT_COLLAPSE_TREE, myNode)
      {
         n_line = myNode.NLine();
         status = isCollapse;
      }
      ///
      /// ���������� ��������� ������.
      /// \return ������, ���� ������ ������ � ���� � ��������� ������.
      ///
      bool IsCollapse()
      {
         return status;
      }
      int NLine(){return n_line;}
      virtual Event* Clone()
      {
         return new EventCollapseTree(Direction(), Node(), status);
      } 
   private:
      ///
      /// �������� ��������� ������. ������, ���� ������ ������ � ���� � ��������� ������.
      ///
      bool status;
      ///
      /// ����� ������ � ������ �������� ���������, ������� ���� ��������/����������
      ///
      int n_line;
};
///
/// ������� �� ���������� ������������ ���� �������� ChartRedraw();
///
class EventRedraw : public Event
{
   public:
      EventRedraw(ENUM_EVENT_DIRECTION myDir, string nameNode) : Event(myDir, EVENT_REDRAW, nameNode){;}
      virtual Event* Clone(){return new EventRedraw(Direction(), NameNodeId());}
};

///
/// ������� "��������� ���� ��������".
///
class EventMouseMove : public Event
{
   public:
      ///
      /// �������� ������� "��������� ���� ��������".
      /// \param xCoord - X ���������� ��������� ����.
      /// \param yCoord - Y ���������� ��������� ����.
      /// \param mask - �����, ����������� ���������� ������� ������.
      ///
      EventMouseMove(long XCoord, long YCoord, int Mask) : Event(EVENT_FROM_UP, EVENT_MOUSE_MOVE, "TERMINAL WINDOW")
      {
         xCoord = XCoord;
         yCoord = YCoord;
         mask = Mask;
      }
      virtual Event* Clone(){return new EventMouseMove(xCoord, yCoord, mask);}
      ///
      /// ������, ���� ������ ������ ������ ����.
      ///
      bool PushedRightButton()
      {
         bool res = (MOUSE_RIGHT_BUTTON_PUSH & mask) ==
              MOUSE_RIGHT_BUTTON_PUSH;
         return res;
      }
      ///
      /// ������, ���� ������ ����� ������ ����.
      ///
      bool PushedLeftButton()
      {
         bool res = (MOUSE_LEFT_BUTTON_PUSH & mask) ==
              MOUSE_LEFT_BUTTON_PUSH;
         return res;
      }
      ///
      /// ������, ���� ������ ����������� ������ ����.
      ///
      bool PushedCentralButton()
      {
         bool res = (MOUSE_CENTER_BUTTON_PUSH & mask) ==
              MOUSE_CENTER_BUTTON_PUSH;
         return res;
      }
      ///
      /// ������, ���� �� ������ �� ���� �� ������ ����.
      ///
      bool PushedNothing()
      {
         if(mask == 0)return true;
         return false;
      }
      ///
      /// ���������� ���������� ������� ������ ���� � ���� �����.
      ///
      int Mask(){return mask;}
      ///
      /// ���������� X ���������� ��������� ����.
      ///
      long XCoord(){return xCoord;}
      ///
      /// ���������� Y ���������� ��������� ����.
      ///
      long YCoord(){return yCoord;}
   private:
      ///
      /// X ���������� ��������� ����.
      ///
      long xCoord;
      ///
      /// Y ���������� ��������� ����.
      ///
      long yCoord;
      ///
      /// �����, ���������� ���������� ������� ������ ����.
      ///
      int mask;
};

class EventCheckBoxChanged : public Event
{
   public:
      EventCheckBoxChanged(ENUM_EVENT_DIRECTION dirEvent, CheckBox* m_checkBox, ENUM_BUTTON_STATE myState) : Event(dirEvent, EVENT_CHECK_BOX_CHANGED, m_checkBox)
      {
         checkBox = m_checkBox;
      }
      ///
      /// ���������� ��������� CheckBox.
      ///
      ENUM_BUTTON_STATE State(){return state;}
      virtual Event* Clone()
      {
         EventCheckBoxChanged* checked = new EventCheckBoxChanged(Direction(), checkBox, state);
         return checked;
      }
   private:
      CheckBox* checkBox;
      
      ENUM_BUTTON_STATE state;
};

