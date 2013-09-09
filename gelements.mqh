
#include "gnode.mqh"

///
/// �������� ����� ������.
///
class MainForm : public ProtoNode
{
   public:
      ///
      /// ���������� ������� �� ����������� �������.
      ///
      virtual void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_NODE_RESIZE:
                  ResizeExtern(newEvent);
                  break;
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               //������� ������� �� ����� ���������� ���������� ������ ����.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      MainForm():ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_FORM, "HedgePanel", NULL)
      {
         //������� ������� �������� �������
         TableOfOpenPos* tOpenPos = new TableOfOpenPos("TableOfOpenPos", GetPointer(this));
         childNodes.Add(tOpenPos);
      }
   private:
      ///
      /// ���������� ������� '��������� �������� ���� ��������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void ResizeExtern(EventResize* event)
      {
         //������ ����� �� ����� ���� ������ 100 ��������.
         long cwidth = event.NewWidth() < 100 ? 100 : event.NewWidth();
         //������ ����� �� ����� ���� ������ 50 ��������.
         long chigh = event.NewHigh() < 70 ? 70 : event.NewWidth();
         Resize(event.NewWidth(), event.NewHigh());
         // ������, ����� ������� ���� ������������, ������ ������� �����������,
         // � ������ ���� ������� ����� ������� "������ ����� ������������ ���� �������",
         // � �������� ��� ���� �������� ���������.
         delete event;
         EventSend(new EventResize(EVENT_FROM_UP, NameID(), Width(), High()));
      }
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         Visible(event.Visible());
         delete event;
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
};

///
/// ������� �������� �������.
///
class TableOfOpenPos : ProtoNode
{
   public:
      ///
      /// ���������� ������� �� ����������� �������.
      ///
      virtual void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_NODE_RESIZE:
                  ResizeExtern(newEvent);
                  break;
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               //������� ������� �� ����� ���������� ���������� ������ ����.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      TableOfOpenPos(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_TABLE, myName, parNode)
      {
         backgroundColor = clrDimGray;
         HeadColumn* HeadMagic = new HeadColumn("HeadMagic", GetPointer(this));
         childNodes.Add(HeadMagic);
      }
   private:
      ///
      /// ���������� ������� '������ ������������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void ResizeExtern(EventResize* event)
      {
         Resize(40, 0, 40, 0);
         EventSend(new EventResize(EVENT_FROM_UP, NameID(), Width(), High()));
         delete event;
      }
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         if(Visible(vis) && vis)
         {
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
               LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR); 
         }
         delete event;
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
      ///
      /// ���� �������� ������� �������� �������. 
      ///
      color backgroundColor;
};

class HeadColumn : ProtoNode
{
   public:
      virtual void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_NODE_RESIZE:
                  ResizeExtern(newEvent);
                  break;
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               //������� ������� �� ����� ���������� ���������� ������ ����.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      HeadColumn(string myName, ProtoNode* parNode):ProtoNode(OBJ_BUTTON, ELEMENT_TYPE_HEAD_COLUMN, myName, parNode)
      {
         Move(5, 5);
      }
   private:
      ///
      /// ���������� ������� '������ ������������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void ResizeExtern(EventResize* event)
      {
         Resize(100, 20);
         EventSend(new EventResize(EVENT_FROM_UP, NameID(), Width(), High()));
         delete event;
      }
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         Visible(vis);
         delete event;
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
};