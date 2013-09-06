#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include "events.mqh"
#include "log.mqh"

///
/// ������������� ���� ������� �� ������� �������� ������.
///
#define MAIN_WINDOW 0
///
/// ������������� ������� �������, �� ������� �������� ������.
///
#define MAIN_SUBWINDOW 0

class ProtoNode : CObject
{
   public:
            
      ///
      /// ��������� ������� � ������������ ��� � ������������ � ���������
      /// ������������� � ������-�������. 
      ///
      virtual void Event(Event* newEvent){;}
      ///
      /// ���������� ������ ������������ ���� � �������.
      /// \return ������ ������������ ���� � �������.
      ///
      long Width(){return width;}
      ///
      /// ���������� ������ ������������ ���� � �������.
      /// \return ������ ������������ ���� � �������.
      ///
      long High(){return high;}
      ///
      /// ���������� ������ ��������� ������������ ����.
      /// \return ������, ���� ����������� ���� ������������ � ���� ���������,
      /// ���� - � ��������� ������.
      ///
      bool Visible(){return visible;}
      ///
      /// ���������� ���������� ��������� ������������� ������������ ����.
      /// \return ���������� ��������� ������������� ������������ ����.
      ///
      string NameID(){return nameId;}
      ///
      /// ���������� ���������� �� ����������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ���� ���������.
      /// \return ���������� � ������� �� ��� �.
      ///
      long AbsXDistance(){return xAbsDist;}
      ///
      /// ���������� ���������� �� ��������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ���� ���������.
      /// \return ���������� � ������� �� ��� Y.
      ///
      long AbsYDistance(){return yAbsDist;}
      ///
      /// ���������� ���������� �� ����������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ������������� ������������ ����.
      /// \return ���������� � ������� �� ��� X.
      ///
      long ParXDistance(){return xParDist;}
      ///
      /// ���������� ���������� �� ��������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ������������� ������������ ����.
      /// \return ���������� � ������� �� ��� Y.
      ///
      long ParYDistance(){return yParDist;}
   protected:
      ///
      /// ������������� ����� ������ �������� ������������ ����.
      /// \return ������, ���� ������ ������������ ���� ��� ���������� �� �����, ����
      /// � ��������� ������.
      ///
      bool Resize(long newWidth, long newHigh)
      {
         // 1) ���������, �������� �� ����� �������� ������� �����������,
         // �� ����� �� �������� ������� ����������� ���� �� �������
         // ������ ������������� ����.
         if(parentNode != NULL)
         {
            // ������ �������.
            if(newWidth > parentNode.Width())
               newWidth = parentNode.Width();
            if(newHigh > parentNode.High())
               newHigh = parentNode.High();
         }
         // ������ �� ����� ���� �������������.
         if(newWidth < 0)newWidth = 0;
         if(newHigh < 0)newHigh = 0;
         // 2) ������������� ����������� ����, ���� �� ������������ � ���� ���������.
         bool res = width != newWidth || high != newHigh;
         if(visible)
         {
            res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE, newWidth);
            if(!res)
               LogWriter("Failed resize element " + nameId + " by horizontally.", MESSAGE_TYPE_ERROR);
            else
               res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE, newHigh);
            if(!res)
               LogWriter("Failed resize element " + nameId + " by verticaly.", MESSAGE_TYPE_ERROR);
         }
         if(res)
         {
            width = newWidth;
            high = newHigh;
         }
         return res;
      }
      ///
      /// ������������� ��������� ������������ ����.
      /// \param status - ������, ���� ��������� ���������� ����������� ���� � ���� ���������,
      /// ���� - � ��������� ������.
      /// \return ������, ���� ����� ��������� ������������ ���� ������ �������, ���� -
      /// � ��������� ������.
      bool Visible(bool status)
      {
         // �������� ������������.
         if(!Visible() && status)
         {
            //���������� ����� ��� ������ ��� ����� ��������� ���������� �������, ���������� ��� ������������.
            GenNameId();
            visible = ObjectCreate(MAIN_WINDOW, nameId, ObjectType, MAIN_SUBWINDOW, xAbsDist, yAbsDist);
            if(!visible)
               LogWriter("Failed visualize element " + nameId, MESSAGE_TYPE_ERROR);
            else
               Resize(width, high);
         }
         // ��������� ������������.
         if(Visible() && !status)
         {
            visible = !ObjectDelete(MAIN_WINDOW, nameId);
         }
         if(status == visible)return true;
         else return false;
      }
      ///
      /// �������� ������� � �����������, ��������� � ��� ����.
      /// \param event - �������, ������� ��������� ��������.
      ///
      void EventSend(Event* event)
      {
         //������� ���� ������-����.
         if(event.Direction() == EVENT_FROM_UP)
         {
            ProtoNode* node;
            for(int i = 0; i < childNodes.Total(); i++)
            {
               node = childNodes.At(i);
               node.Event(event);
            }
         }
         //������� ���� �����-�����.
         if(event.Direction() == EVENT_FROM_DOWN)
         {
            if(parentNode != NULL)
               parentNode.Event(event);
         }
      }
      
      ///
      /// ��������� �� ������������ ����������� ����.
      ///
      ProtoNode *parentNode;
      ///
      /// �������� ����������� ����.
      ///
      CArrayObj childNodes;
      ///
      /// ��� �������, �������� � ������ ����.
      ///
      ENUM_OBJECT ObjectType;
      ///
      /// ��� ������������ ����, ������ ������������� � ��� ����������. ��������:
      /// "GeneralForm" ��� "TableOfOpenPosition".
      ///
      string name;
   private:
      ///
      /// ���������� ���-������������� ������������ ����.
      ///
      string nameId;
      ///
      /// �������� ������ ��������� ������������ ����. ������, ����
      /// ����������� ���� ������������ � ���� ��������� � ���� � 
      /// ��������� ������.
      ///
      bool visible;
      ///
      /// �������� ������ ������������ ���� � �������.
      ///
      long width;
      ///
      /// �������� ������ ������������ ���� � �������.
      ///
      long high;
      ///
      /// ���������� �� ����������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ���� ���������.
      ///
      long xAbsDist;
      ///
      /// ���������� �� ��������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ���� ���������.
      ///
      long yAbsDist;
      ///
      /// ���������� �� ����������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ������������� ������������ ����.
      ///
      long xParDist;
      ///
      /// ���������� �� ��������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ������������� ������������ ����.
      ///
      long yParDist;
      
      ///
      /// ���������� ���������� ��� �������
      ///
      void GenNameId(void)
      {
         //�������� ��� � ��������� ��� ����������� ������
         if(name == NULL || name == "")
            name = "VisualForm";
         nameId = name;
         //���� ������ � ����� ������ ��� ����������
         //��������� � ����� ������, �� ��� ��� ���� ��� �� ������ ����������.
         int index = 0;
         while(ObjectFind(MAIN_WINDOW, nameId + (string)index) >= 0)
         {
            index++;
         }
         nameId += (string)index;
      }
};
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
            }
         }
      }
      MainForm()
      {
         //� ������ ������� ����� ������ ����� "������������� �����";
         ObjectType = OBJ_RECTANGLE_LABEL;
         name = "HedgePanel";
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
         long chigh = event.NewHigh() < 50 ? 50 : event.NewWidth();
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

