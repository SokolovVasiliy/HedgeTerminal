//#include <Arrays\ArrayObj.mqh>
#include "\API\MqlTransactions.mqh"
#ifndef EVENTS_MQH
   #define EVENTS_MQH
#endif
#ifndef HEDGE_PANEL
   class ProtoNode;
#endif 

class Event;
class HedgeManager;
class Position;
/*
  �������������� ������� � �� ���������
*/
///
/// �����-������� ����������� ������������ ��������� ���� ����������� �������.
///
class CEventExchange
{
   
   public:
      void PushEvent(Event* myEvent)
      {
         if(CheckPointer(api) != POINTER_INVALID)
            api.Event(myEvent);
         #ifdef HEDGE_PANEL
         if(panel != NULL)
            panel.Event(myEvent);
         #endif
      }
      
      Event* PopEvent()
      {
         return event;
      }
      void DeleteEvent()
      {
         event = NULL;
      }
      void Add(HedgeManager* myHedge)
      {
         api = myHedge;
      }
      #ifdef HEDGE_PANEL
      void Add(ProtoNode* node)
      {
         panel = node;
      }
      #endif
      HedgeManager* GetAPI(void)
      {
         return api;
      }
      HedgeManager* api;
      #ifdef HEDGE_PANEL
      ProtoNode* panel;
      #endif
   private:
      void ExecuteEvent()
      {
         ;
      }
      Event* event;
      
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
   EVENT_OBJ_CLICK,
   ///
   /// ��� ������� �������� ����������� ������, ����� ����, ��� ��� �����.
   ///
   EVENT_NODE_CLICK,
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
   EVENT_CHECK_BOX_CHANGED,
   ///
   /// ������������� ������� ���� ���� ������.
   ///
   EVENT_CHANGE_COLOR,
   ///
   /// ������� �������
   ///
   EVENT_KEYDOWN,
   ///
   /// ���������� �������������� ������.
   ///
   EVENT_END_EDIT,
   ///
   /// ����� ���������� �������������� ������, ����� EditNode ����������
   /// ��� �������.
   ///
   EVENT_END_EDIT_NODE,
   ///
   /// ������������� ������� "��������� ����� ������".
   ///
   EVENT_ADD_DEAL,
   ///
   /// ������������� �������-������� "�������� ������������� �������".
   ///
   EVENT_REFRESH_POS,
   ///
   /// ������������� ������� "����� ��������� �������".
   ///
   EVENT_REQUEST_NOTICE,
   ///
   /// ������������� ������� "������ ���������� ������� �������".
   ///
   EVENT_BLOCK_POS,
   ///
   /// ������������� ������� ����������� ����������� ������.
   ///
   EVENT_ORDER_CANCEL,
   ///
   /// ������������� ������� ����������� ������������ ������.
   ///
   EVENT_ORDER_EXE,
   ///
   /// ������������� ������� ����������� ������ ����������� ������.
   ///
   EVENT_ORDER_PENDING,
   ///
   /// ������������� ������� �������� xml ������� � �������� � ��� ������ xml ���� (31 �������).
   ///
   EVENT_DELETE_XML_POS,
   ///
   /// ������������� ������� ��������� xml ���������.
   ///
   EVENT_CHANGE_XML_ATTR,
   ///
   /// ������������� ������� ���������� ����������� ������.
   ///
   EVENT_REFRESH_PANEL,
   ///
   /// ������������� ������� ��������� ������� ����������.
   ///
   EVENT_SCROLL_CHANGED,
   ///
   /// ������������� ������� �� �������� �������� ������.
   ///
   EVENT_CREATE_SUMMARY
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
      ENUM_EVENT EventId(){return eventId;}
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
      #ifdef HEDGE_PANEL
      ProtoNode* Node(){return node;}
      #endif 
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
      #ifdef HEDGE_PANEL
      Event(ENUM_EVENT_DIRECTION myDirection, ENUM_EVENT myEventId, ProtoNode* myNode)
      {
         eventDirection = myDirection;
         eventId = myEventId;
         #ifdef HEDGE_PANEL
         nameNodeId = myNode.NameID();
         #endif
         node = myNode;
         tickCount = GetTickCount();
      }
      #endif
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
      #ifdef HEDGE_PANEL
      ProtoNode* node;
      #endif
};

/* TERMINAL EVENTS*/
///
/// ������� "�������� �������� �������".
///
class EventRequestNotice : public Event
{
   public:
      EventRequestNotice(const  MqlTradeTransaction& mqlTrans, const MqlTradeRequest& mqlRequest, const MqlTradeResult& mqlResult) :
      Event(EVENT_FROM_UP, EVENT_REQUEST_NOTICE, "WINDOW TERMINAL")
      {
         trans = new TradeTransaction(mqlTrans);
         request = new TradeRequest(mqlRequest);
         result = new TradeResult(mqlResult);
      }
      ~EventRequestNotice()
      {
         delete trans;
         delete request;
         delete result;
      }
      TradeTransaction* GetTransaction(){return trans;}
      TradeRequest* GetRequest(){return request;}
      TradeResult* GetResult(){return result;}
   private:
      TradeTransaction* trans;
      TradeRequest* request;
      TradeResult* result;
};

///
/// ������� "������ ���������� ������� �������".
///
class EventBlockPosition : public Event
{
   public:
      EventBlockPosition(Position* blockPos, bool status) : Event(EVENT_FROM_UP, EVENT_BLOCK_POS, "Position blocked")
      {
         pos = blockPos;
         statusBlock = status;
      }
      ///
      /// ���������� ��������� �� �������, ������� ���� �����������/��������������.
      ///
      Position* Position(){return pos;}
      ///
      /// ���������� ������ ���������� �������.
      ///
      bool Status(){return statusBlock;}
      virtual Event* Clone()
      {
         EventBlockPosition* ev = new EventBlockPosition(pos, statusBlock);
         return ev;
      }
   private:
      Position* pos;
      bool statusBlock;
};
///
/// ������� EVENT_NODE_VISIBLE
///
#ifdef HEDGE_PANEL
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
#endif
///
/// ������� EVENT_NODE_RESIZE
///
class EventResize : public Event
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
class EventMove : public Event
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
class EventDeinit : public Event
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

///
/// ��� ������� ������������ ���������� 
///
class EventObjectClick : public Event
{
   public:
      EventObjectClick(string pushName): Event(EVENT_FROM_UP, EVENT_OBJ_CLICK, "TERMINAL WINDOW")
      {
         pushObjName = pushName;
      }
      ///
      /// ���������� �������� �������, �� �������� ���� ����������� �������.
      ///
      string PushObjName(){return pushObjName;}
      virtual Event* Clone()
      {
         return new EventObjectClick(pushObjName);
      }
   private:
      ///
      /// ������ �������� ����, �� �������� ���� ����������� �������.
      ///
      string pushObjName;
};

///
/// ��� ������� ������������ ���������� � ������ ��������� �������������� ��������� �����.
///
class EventEndEdit : public Event
{
   public:
      EventEndEdit(string editNameNode): Event(EVENT_FROM_UP, EVENT_END_EDIT, "TERMINAL WINDOW")
      {
         nameNode = editNameNode;
      }
      
      ///
      /// ���������� �������� �������, �� �������� ���� ����������� �������.
      ///
      string EditNode(){return nameNode;}
      virtual Event* Clone()
      {
         return new EventObjectClick(nameNode);
      }
   private:
      ///
      /// ������ �������� ����, �� �������� ���� ����������� �������.
      ///
      string nameNode;
      ///
      /// ������ ����� �������� ������� ����.
      ///
      string value;
};
#ifdef HEDGE_PANEL
class EditNode;
class EventEndEditNode : public Event
{
   public:
      EventEndEditNode(EditNode* editNode, string curValue) : Event(EVENT_FROM_DOWN, EVENT_END_EDIT_NODE, editNode)
      {
         this.value = curValue;
      }
      ///
      /// ���������� �������� EditNode ����� ��������������.
      ///
      string Value(){return value;}
   private:
      string value;
};
#endif

///
/// ���������� ��� ��������� �������
///
enum ENUM_POSITION_CHANGED_TYPE
{
   ///
   ///���������, ��� ������� ������� ���������� ������.
   ///
   POSITION_HIDE,
   ///
   /// ��������� ��� ���������� ������� ���������� ����������.
   ///
   POSITION_SHOW,
   ///
   /// ���������, ��� ���������� �������� ����������� ���������� �������.
   ///
   POSITION_REFRESH,
};

///
/// ��� ������� ���� ������� � ���, ��� ����� ������ � ������������ ��������.
///
class EventPositionChanged : public Event
{
   public:
      EventPositionChanged(Position* pos, ENUM_POSITION_CHANGED_TYPE type) :
      Event(EVENT_FROM_UP, EVENT_CHANGE_POS, "Hedge API")
      {
         myPos = pos;
         chType = type;
      }
      ENUM_POSITION_CHANGED_TYPE ChangedType(){return chType;}
      Position* Position(){return myPos;}
   private:
      ENUM_POSITION_CHANGED_TYPE chType;
      Position* myPos;
};

///
/// ��� ������� �������� ������� ������� ������� (������������ ������� close).
///
class EventClosePos : public Event
{
   public:
      EventClosePos(string nodeId) : Event(EVENT_FROM_DOWN, EVENT_CLOSE_POS, nodeId){;}
      ///
      /// ������������� ������������� �������, ������� ��������� �������.
      ///
      void PositionId(ulong pos){positionId = pos;}
      ///
      /// ���������� ������������� �������, ������� ��������� �������.
      ///
      ulong PositionId(){return positionId;}
      ///
      /// ������������� ����� ������, ���������� ���������� �������������� �������.
      ///
      void NLine(int n)
      {
         n_line = n;
      }
      ///
      /// ���������� ����� ������, ���������� ���������� �������������� �������.
      ///
      int NLine(){return n_line;}
      ///
      /// ���������� ����������� �����������.
      ///
      string CloseComment(){return comment;}
      ///
      /// ���������� ����������� �����������.
      ///
      void CloseComment(string comm){comment = comm;}
      
      virtual Event* Clone()
      {
         return new EventClosePos(NameNodeId());
      }
      
   private:
      ///
      /// ������������� �������, ������� ��������� �������.
      ///
      ulong positionId;
      ///
      /// ����� ������� � ������ ���������� �������.
      ///
      int n_line;
      ///
      /// ����������� �����������.
      ///
      string comment;
};

class Order;
///
/// ��� ������� �������� HedgeManager, ����� � ������� ������� ��������
/// ����� ���������� �����.
///
class EventOrderCancel : public Event
{
   public:
      EventOrderCancel(Order* myOrder) : Event(EVENT_FROM_UP, EVENT_ORDER_CANCEL, "Terminal API")
      {
         order = myOrder;
      }
      ///
      /// ���������� ���������� �����.
      ///
      Order* Order(){return order;}
   private:
      Order* order;
};

///
/// ��� ������� �������� HedgeManager, ����� ����������� �����
/// ����������� �����.
///
class EventOrderExe : public Event
{
   public:
      EventOrderExe(Order* myOrder) : Event(EVENT_FROM_UP, EVENT_ORDER_EXE, "Terminal API")
      {
         order = myOrder;
      }
      ///
      /// ���������� ���������� �����.
      ///
      Order* Order(){return order;}
   private:
      Order* order;
};

///
/// ��� ������� �������� HedgeManager, ����� ��������� �����
/// ���������� (��������) ����� � ������ �������� �������.
///
class EventOrderPending : public Event
{
   public:
      EventOrderPending(Order* myOrder) : Event(EVENT_FROM_UP, EVENT_ORDER_PENDING, "Terminal API")
      {
         order = myOrder;
      }
      ///
      /// ���������� ���������� �����.
      ///
      Order* Order(){return order;}
   private:
      Order* order;
};

#ifdef HEDGE_PANEL
///
/// ��� ���������� ����� ����� ������������ �������������� �������.
///
enum ENUM_REFRESH_LINES
{
   ///
   /// �������� ��� �����.
   ///
   REFRESH_ALL,
   ///
   /// �������� ����� ��������������� ����� ���������/����������� �������.
   ///
   REFRESH_AFTER,
   ///
   /// �� ��������� �����.
   ///
   REFRESH_NONE
};
class EventCollapseTree : public Event
{
   public:
      EventCollapseTree(ENUM_EVENT_DIRECTION myDir, ProtoNode* myNode, bool isCollapse) : Event(EVENT_FROM_DOWN, EVENT_COLLAPSE_TREE, myNode)
      {
         n_line = myNode.NLine();
         status = isCollapse;
         needRefresh = true;
      }
      ///
      /// ���������� ������, ���� ��������� ���������� ��� ������� ������ � ���� � ��������� ������.
      ///
      bool NeedRefresh(){return needRefresh;}
      ///
      /// ������������� ����� ���������� ��� ������.
      ///
      void NeedRefresh(bool refresh){needRefresh = refresh;}
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
      ///
      /// ������, ���� ��������� ���������� � ���� � ��������� ������.
      ///
      bool needRefresh;
};
#endif
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

#ifdef HEDGE_PANEL
//class CheckBox;
class EventCheckBoxChanged : public Event
{
   public:
      EventCheckBoxChanged(ENUM_EVENT_DIRECTION dirEvent, CheckBox* m_checkBox, bool check) : Event(dirEvent, EVENT_CHECK_BOX_CHANGED, m_checkBox)
      {
         checkBox = m_checkBox;
         isChecked = check;
      }
      ///
      /// ���������� ������ ������� ������.
      ///
      bool Checked(){return isChecked;}
      ///
      /// ���������� ��������� CheckBox.
      ///
      ENUM_BUTTON_STATE State(){return state;}
      virtual Event* Clone()
      {
         EventCheckBoxChanged* checked = new EventCheckBoxChanged(Direction(), checkBox, isChecked);
         return checked;
      }
   private:
      CheckBox* checkBox;
      bool isChecked;
      ENUM_BUTTON_STATE state;
};
#endif

///
/// ��� ������� �������� ����������� ������ ����� ����, ��� ��� �����
/// (���������� ��-��������� � ProtoNode.OnPush())
///
#ifdef HEDGE_PANEL
class EventNodeClick : public Event
{
   public:
      EventNodeClick(ENUM_EVENT_DIRECTION dirEvent, ProtoNode* myNode) : Event(dirEvent, EVENT_NODE_CLICK, myNode){;}
      Event* Clone(){return new EventNodeClick(Direction(), Node());}
};
#endif
///
/// �������, ��������������� � ����� �����.
///
class EventChangeColor : public Event
{
   public:
      EventChangeColor(ENUM_EVENT_DIRECTION dirEvent, string nodeName, color clr) : Event(dirEvent, EVENT_CHANGE_COLOR, nodeName)
      {
         m_clr = clr;
      }
      ///
      /// ���������� ����, �� ������� ���������� ������� ���� ����.
      ///
      color Color(){return m_clr;}
   private:
      color m_clr;
};

///
/// ������� ������� ������� ����������.
///
class EventKeyDown : public Event
{
   public:
      ///
      /// ������� ������� "������� �������".
      /// \param keyCode - ��� ������� �������.
      /// \param keysMask - �����, ����������� ���������� ������� ������ �� ����������.
      ///
      EventKeyDown(int keyCode, int keysMask) : Event(EVENT_FROM_UP, EVENT_KEYDOWN, "TERMINAL WINDOW")
      {
         code = keyCode;
         mask = keysMask;
      }
      ///
      /// ���������� ��� ������� �������.
      ///
      ENUM_KEY_CODE Code(){return (ENUM_KEY_CODE)code;}
      ///
      /// ���������� �����, ����������� ���������� ������� ������� �� ����������.
      ///
      int Mask(){return mask;}
      Event* Clone(){return new EventKeyDown(code, mask);}
   private:
      ///
      /// �����, ����������� ���������� ������� ������ �� ����������.
      ///
      int mask;
      ///
      /// ��� ������� �������.
      ///
      int code;
      
};

///
/// ��� ������� ��������� ��� ���������� ����� ������.
///
class EventAddDeal : public Event
{
   public:
      EventAddDeal(ulong deal_id) : Event(EVENT_FROM_UP, EVENT_ADD_DEAL, "API")
      {
         dealId = deal_id;
      }
      EventAddDeal(ulong deal_id, ulong order_id) : Event(EVENT_FROM_UP, EVENT_ADD_DEAL, "API")
      {
         dealId = deal_id;
         orderId = order_id;
      }
      ///
      /// ���������� ���������� ������������� ������.
      ///
      ulong DealID(){return dealId;}
      ///
      /// ���������� �����, �� ��������� �������� ��������� �����.
      ///
      ulong OrderId(){return orderId;}
   private:
      ///
      /// ���������� ������������� ������.
      ///
      ulong dealId;
      ///
      /// �����, �� ��������� �������� �������� �����.
      ///
      ulong orderId;
};

#ifdef HEDGE_PANEL
///
/// ������� ����������� ���������� ������.
///
class EventRefreshPanel : public Event
{
   public:
      EventRefreshPanel() : Event(EVENT_FROM_UP, EVENT_REFRESH_PANEL, "HEDGE API"){;}
};
#endif

#ifdef HEDGE_PANEL
class Scroll;
///
/// ������� ������������ �� ��������� ��������� �������.
///
class EventScrollChanged : public Event
{
   public:
      EventScrollChanged(ENUM_EVENT_DIRECTION dir, Scroll* scroll) : Event(dir, EVENT_SCROLL_CHANGED, scroll){;}
      ///
      /// ���������� ��������� �� ���������� ������.
      ///
      Scroll* GetScroll(){return Node();}
};
#endif

#ifdef HEDGE_PANEL
///
/// ������� ����������� ������� �������� ������.
///
class EventCreateSummary : public Event
{
   public:
      EventCreateSummary(ENUM_TABLE_TYPE tType) : Event(EVENT_FROM_UP, EVENT_CREATE_SUMMARY, "Terminal API")
      {
         tableType = tType;
      }
      ///
      /// ���������� ��� �������, ��� ������� ���������� ������� ������� ������.
      ///
      ENUM_TABLE_TYPE TableType(){return tableType;}
   private:
      ///
      /// ��� �������� ��� ������� ���������� ������� �������� ������.
      ///
      ENUM_TABLE_TYPE tableType;
};
#endif