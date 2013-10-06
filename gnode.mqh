#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include "events.mqh"
#include "log.mqh"
#include "defines.mqh"


///
/// ��� �������� ������������ ����������.
///
enum ENUM_ELEMENT_TYPE
{
   ///
   /// ������� ������������ ���������� "�����".
   ///
   ELEMENT_TYPE_FORM,
   ///
   /// ������� ������������ ���������� "�������".
   ///
   ELEMENT_TYPE_TABLE,
   ///
   /// ������� ������������ ���������� "��������� �����".
   ///
   ELEMENT_TYPE_FORM_HEADER,
   ///
   /// ������� ������������ ���������� "������".
   ///
   ELEMENT_TYPE_BOTTON,
   ///
   /// ������� ������������ ���������� "�������".
   ///
   ELEMENT_TYPE_TAB,
   ///
   /// ������� ������������ ���������� "��������� ������� �������".
   ///
   ELEMENT_TYPE_HEAD_COLUMN,
   ///
   /// ������� ������������ ���������� "�������������� ���������".
   ///
   ELEMENT_TYPE_GCONTAINER,
   ///
   /// ������� ������������ ���������� "������������ ���������".
   ///
   ELEMENT_TYPE_VCONTAINER,
   ///
   /// ������� ������������ ���������� "������������� ���������".
   ///
   ELEMENT_TYPE_UCONTAINER,
   ///
   /// ������� ������������ ���������� "�������".
   ///
   ELEMENT_TYPE_SCROLL,
   ///
   /// ������� ������������ ���������� "��������� �����".
   ///
   ELEMENT_TYPE_LABEL,
   ///
   /// ������� ������������ ���������� "������ �������".
   ///
   ELEMENT_TYPE_CELL
};

class ProtoNode : public CObject
{
   public:
      ENUM_ELEMENT_TYPE TypeElement(){return elementType;}   
      ///
      /// ��������� ������� � ������������ ��� � ������������ � ���������
      /// ������������� � ������-�������. 
      ///
      void Event(Event* event)
      {
         if(event.Direction() == EVENT_FROM_UP)
         {
            switch(event.EventId())
            {
               case EVENT_NODE_MOVE:
                  Move(event);
                  break;
               case EVENT_NODE_RESIZE:
                  Resize(event);
                  break;
               case EVENT_NODE_VISIBLE:
                  Visible(event);
                  break;
               case EVENT_NODE_COMMAND:
                  ExecuteCommand(event);
                  break;
               case EVENT_DEINIT:
                  OnDeinit(event);
                  Deinit(event);
                  break;
               //��� ������� � ������� �� �� ����� - ���������� ��������.
               default:
                  OnEvent(event);
            }
         }
         else
            OnEvent(event);
      }
      virtual void OnDeinit(EventDeinit* event){;}
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
      /// ���������� ����������� ������ ������������ ��������.
      ///
      long OptimalWidth()
      {
         if(CheckPointer(bindOptWidth) != POINTER_INVALID)
            return bindOptWidth.OptimalWidth();
         return optimalWidth;
      }
      ///
      /// 
      ///
      long OptimalHigh()
      {
         if(CheckPointer(bindOptHigh) != POINTER_INVALID)
            return bindOptHigh.OptimalHigh();
         return optimalHigh;
      }
       
      void OptimalWidth(long optWidth)
      {
         if(bindOptWidth != NULL)
            bindOptWidth.OptimalWidth(optWidth);
         optimalWidth = optWidth;
      }
      
      void OptimalHigh(long optHigh)
      {
         if(bindOptHigh != NULL)
            bindOptHigh.OptimalHigh(optHigh);
         optimalHigh = optHigh;
      }
      ///
      /// ����������� ���� ����������� ������ � ����������� ������ ������� ����.
      ///
      void BindOptWidth(ProtoNode* node)
      {
         bindOptWidth = node;
         optimalWidth = node.OptimalWidth();
      }
      ///
      /// ����������� ���� ����������� ������ � ����������� ������ ������� ����.
      ///
      void BindOptHigh(ProtoNode* node)
      {
         bindOptHigh = node;
         optimalHigh = node.OptimalHigh();
      }
      ///
      /// ���������� ���������� ������ �� ������� ����.
      ///
      void UnbindOptWidth(){bindOptWidth = NULL;}
      ///
      /// ���������� ����������� ������ �� ������� ����.
      ///
      void UnbindOptHigh(){bindOptHigh = NULL;}
      ///
      /// ���������� ���������� ��������, �������� � ����������� �������.
      ///
      int ChildsTotal()
      {
         return childNodes.Total();
      }
      ///
      /// ���������� ������ �� �������� ������� ��� ������� n
      ///
      ProtoNode* ChildElementAt(int n)
      {
         ProtoNode* node = childNodes.At(n);
         return node;
      }
      ///
      /// ���������� ������ ��������� ������������ ����.
      /// \return ������, ���� ����������� ���� ������������ � ���� ���������,
      /// ���� - � ��������� ������.
      ///
      bool Visible(){return visible;}
      ///
      /// ���������� ������ ��������� ������������� ��������.
      /// ���� ������������� �������� ��� - ���������� ������.
      /// \return ������, ���� ������������ ������� �����, ���� � ��������� ������.
      ///
      bool ParVisible()
      {
         if(parentNode != NULL)
            return parentNode.Visible();
         //���� ��������� �� ����������� ������ ������.
         else return true;
      }
      ///
      /// ���������� ���������� ��������� ������������� ������������ ����.
      /// \return ���������� ��������� ������������� ������������ ����.
      ///
      string NameID(){return nameId;}
      ///
      /// ���������� ���������� �� ����������� ����� ����� �������� �������� ���� �
      /// ����� �������� ������������� ����. ���� ������������� ���� ���,
      /// ���������� ���������� ��������� �� ����� ������� ���� ���������.
      /// \return ���������� � ������� �� ��� X.
      ///
      long XLocalDistance()
      {
         return xDist - XAbsParDistance();
      }
      ///
      /// ���������� ���������� �� ��������� ����� ������� �������� �������� ���� �
      /// ������� �������� ������������� ����. ���� ������������� ���� ���,
      /// ���������� ���������� ��������� �� ������� ������� ���� ���������.
      /// \return ���������� � ������� �� ��� Y.
      ///
      long YLocalDistance()
      {
         return yDist - YAbsParDistance();
      }
      ///
      /// ���������� ���������� ���������� �� ����������� ����� ����� �������� �������� ���� �
      /// ����� �������� ���� ���������.
      /// \return ���������� � ������� �� ��� X.
      ///
      long XAbsDistance()
      {
         return xDist;
      }
      ///
      /// ���������� ���������� ���������� �� ��������� ����� ������� �������� �������� ���� �
      /// ������� �������� ���� ���������.
      /// \return ���������� � ������� �� ��� Y.
      ///
      long YAbsDistance()
      {
         return yDist;
      }
      ///
      /// ���������� ���������� ���������� �� ����������� � ������� �� ����� �������
      /// ������������� ������������ ���� �� ����� ������� ���� ���������.
      /// ���� ������������� ���� ��� - ���������� 0.
      /// \return ���������� � ������� �� ��� X.
      ///
      long XAbsParDistance()
      {
         if(parentNode != NULL)
            return parentNode.XAbsDistance();
         return 0;
      }
      ///
      /// ���������� ���������� ���������� �� ��������� � ������� �� ������� �������
      /// ������������� ������������ ���� �� ������� ������� ���� ���������.
      /// ���� ������������� ���� ��� - ���������� 0.
      /// \return ���������� � ������� �� ��� X.
      ///
      long YAbsParDistance()
      {
         if(parentNode != NULL)
            return parentNode.YAbsDistance();
         return 0;
      }
      ///
      /// ���������� ������ ������������� ������������ ����. ���� ������������
      /// ����������� ���� �� ����� - ���������� 0.
      ///
      long ParWidth()
      {
         if(parentNode != NULL)
            return parentNode.Width();
         //��������������� ��� ���� ��������� ����� ������ 32667 ��������.
         else return SHORT_MAX;
      }
      ///
      /// ���������� ������ ������������� ������������ ����. ���� ������������
      /// ����������� ���� �� ����� - ���������� 0.
      ///
      long ParHigh()
      {
         if(parentNode != NULL)
            return parentNode.High();
         //��������������� ��� ���� ��������� ����� ������ 32667 ��������.
         else return SHORT_MAX;
      }
      ///
      /// ���������� �������� ��� ����.
      ///
      string ShortName(){return shortName;}
      ///
      /// ���������� ��� ������������ ����.
      /// \retrurn name - ��� ������������ ����.
      ///
      string Name(){return name;}
      ///
      /// ����������� �������.
      /// \param mytype - ��� ������������ �������, �������� � ������ ������������ ����.
      /// \param myclassName - �����, � �������� ����������� ����������� ����.
      /// \param myname - �������� ������������ ����.
      /// \param parNode - ������������ ����, ������ �������� ������������� ������� ����.
      ///

      ProtoNode(ENUM_OBJECT mytype, ENUM_ELEMENT_TYPE myElementType, string myname, ProtoNode* parNode)
      {
         Init(mytype, myElementType, myname, parNode);
      }
      
      ProtoNode(ENUM_OBJECT mytype, ENUM_ELEMENT_TYPE myElementType, string myname, ProtoNode* parNode, long optWidth, long optHigh)
      {
         Init(mytype, myElementType, myname, parNode);
         optimalWidth = optWidth;
         optimalHigh = optHigh;
         Resize(optHigh, optHigh);
      }
      ///
      /// ������������� ���� ������� ����.
      ///
      void BackgroundColor(color clr)
      {
         bgColor = clr;
         if(visible)
            ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_BGCOLOR, bgColor);
      }
      ///
      /// ���������� ���� ������� ����.
      ///
      color BackgroundColor()
      {
         return bgColor;
      }
      ///
      /// ������������� ���� ����� ��������� �����.
      ///
      void BorderColor(color clr)
      {
         borderColor = clr;
         if(visible)
            ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_BORDER_COLOR, borderColor);
      }
      ///
      /// ���������� ���� ����� ��������� �����.
      ///
      color BorderColor()
      {
         return borderColor;
      }
      ///
      /// ��� ����� ��� ������� "������������� �����".
      ///
      void BorderType(ENUM_BORDER_TYPE bType)
      {
         borderType = bType;
         //��� �������� ������������ ������ ������������� �����.
         if(visible && typeObject == OBJ_RECTANGLE_LABEL)
            ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_BORDER_TYPE, borderType);
      }
      
   protected:
      ///
      /// ���������������� ����� �������.
      ///
      virtual void OnEvent(Event* event){EventSend(event);}
      virtual void OnVisible(EventVisible* event){EventSend(event);}
      virtual void OnResize(EventResize* event)
      {
         int total = childNodes.Total();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = childNodes.At(i);
            EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), node.Width(), node.High());
            node.Event(er);
            delete er;
         }
      }
      virtual void OnMove(EventMove* event)
      {
         int total = childNodes.Total();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = childNodes.At(i);
            EventMove* em = new EventMove(EVENT_FROM_UP, NameID(), node.XAbsDistance(), node.YAbsDistance(), COOR_GLOBAL);
            node.Event(em);
            delete em;
         }   
      }
      virtual void OnCommand(EventNodeCommand* event){;}
      
      void Resize(EventResize* event)
      {
         Resize(event.NewWidth(), event.NewHigh());
      }
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
         //������ �� ����� ��������� ������ ������� ������������� ����.
         if(YAbsParDistance() + ParHigh() < YAbsDistance() + newHigh)
         {
            //����� ������������ ������ �� ��������� ����������
            newHigh = (YAbsParDistance() + ParHigh()) - YAbsDistance();
         }
         //������ �� ����� ��������� ������ ������� ������������� ����.
         if(XAbsParDistance() + ParWidth() < XAbsDistance() + newWidth)
         {
            //����� ������������ ������ �� ��������� ����������
            newWidth = (XAbsParDistance() + ParWidth()) - XAbsDistance();
         }
         // ���� ������ ��� ����� �����������, ���� ����� ���� - �� ������� �� �����.
         if((newHigh <= 0 || newWidth <= 0) && Visible())
            Visible(false);

         // 2) ������������� ����������� ����, ���� �� ������������ � ���� ���������.
         if(visible)
         {
            if(!ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE, newWidth))
            {
               LogWriter("Failed resize element " + nameId + " by horizontally.", MESSAGE_TYPE_ERROR);
               newWidth = ObjectGetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE);
            }
            if(!ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE, newHigh))
            {
               LogWriter("Failed resize element " + nameId + " by verticaly.", MESSAGE_TYPE_ERROR);
               newHigh = ObjectGetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE);
            }
         }
         int k = 5;
         if(width != newWidth)
            k = 6;
         width = newWidth;
         high = newHigh;
         if(nameId == NULL || nameId == "")
            GenNameId();
         EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         OnResize(er);
         delete er;
         
         return true;
      }
      ///
      /// ������������� ����������� ����.
      /// \param UpBorder - ���������� ����� ������� �������� ������������ ���� � ������� �������� ������������� ������������ ����.
      /// \param LeftBorder - ���������� ����� ����� �������� ������������ ���� � ����� �������� ������������� ������������ ����.
      /// \param RightBorder - ���������� ����� ������ �������� ������������ ���� � ������ �������� ������������� ������������ ����.
      /// \param DnBorder - ���������� ����� ������ �������� ������������ ���� � ������ �������� ������������� ������������ ����.
      ///
      bool Resize(long UpBorder, long LeftBorder, long DnBorder, long RightBorder)
      {
         Move(LeftBorder, UpBorder);
         //���� ������� ������������ �������, ����� ���������� ��� ������ ������������.
         long newWidth = ParWidth() - LeftBorder - RightBorder;
         long newHigh = ParHigh() - UpBorder - DnBorder;
         return Resize(newWidth, newHigh);
      }
      void Visible(EventVisible* event)
      {
         Visible(event.Visible());
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
         if(!visible && status)
         {
            // ������� ������ ���� ���������.
            if(width <= 0 || high <= 0)
               return false;
            // 1. ���� �� ����� ������������� ���� ������� ������� ������������� ����.
            if (yDist < YAbsParDistance())
            {
                //LogWriter("Y-coordinate of node must be leter Y-coordinate parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 2. ���� �� ����� ������������� ���� ������ ������� ������������� ����.
            if (yDist + High() > YAbsParDistance() + ParHigh())
            {
                long ypar = YAbsParDistance();
                long hpar = ParHigh();
                //LogWriter("Node position must be biger down line parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 3. ���� �� ����� ���� ����� ����� ������� ������������� ����.
            if (XAbsDistance() < XAbsParDistance())
            {
                //LogWriter("X-coordinate of node must be leter X-coordinate parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 4. ���� �� ����� ���� ������ ������ ������� ������������� ����.
            if (XAbsDistance() + Width() > XAbsParDistance() + ParWidth())
            {
                //LogWriter("Node position must be biger left line parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            //���������� ����� ��� ������ ��� ����� ��������� ���������� �������, ���������� ��� ������������.
            GenNameId();
            visible = ObjectCreate(MAIN_WINDOW, nameId, typeObject, MAIN_SUBWINDOW, XAbsDistance(), YAbsDistance());
            if(!visible)
               LogWriter("Failed visualize element " + nameId, MESSAGE_TYPE_ERROR);
            else
            {
               EventVisible* ev = new EventVisible(EVENT_FROM_UP, NameID(), visible);
               //������������� ���������� ��-���������.
               BackgroundColor(bgColor);
               BorderColor(borderColor);
               BorderType(borderType);
               OnVisible(ev);
               delete ev;
               Move(xDist, yDist, COOR_GLOBAL);
               Resize(width, high);
            }
         }
         // ��������� ������������.
         if(Visible() && !status)
         {
            visible = !ObjectDelete(MAIN_WINDOW, nameId);
            //���������� �������� ��������.
            EventVisible* ev = new EventVisible(EVENT_FROM_UP, NameID(), visible);
            EventSend(ev);
            delete ev;
         }
         return visible;
      }
      void Move(EventMove* event)
      {
         Move(event.XDist(), event.YDist(), event.Context());
      }
      ///
      /// ����������� ����������� ���� �� ����� �����, ���������� ������������ �� ���� X � Y.
      /// ����� ����������� �� ����� ����������� ����������, ����������� ���� �� ������ ��������
      /// �� ������� ������������� ������������ ����.
      /// \param xCoordinate - ���������� �������� �� ������ �������� ���� ������������ ����, ��
      /// �������� ������ ���� ���� ��������� �� �������������� ���.
      /// \param yCoordinate - ���������� �������� �� ������ �������� ���� ������������ ����, ��
      /// �������� ������ ���� ���� ��������� �� �������������� ���.
      /// \param contex - �������� ���������� ���������. 
      /// \return ������, ���� ������������ ������ �������, ���� � ��������� ������.
      ///
      bool Move(long xCoordinate, long yCoordinate, ENUM_COOR_CONTEXT context = COOR_LOCAL)
      {
         //��������� ������������� ���������� � ����������.
         if(context == COOR_LOCAL)
         {
            xCoordinate = xCoordinate + XAbsParDistance();
            yCoordinate = yCoordinate + YAbsParDistance();
         }
         // 1. ���� �� ����� ������������� ���� ������� ������� ������������� ����.
         if (yCoordinate < YAbsParDistance())
         {
             // ����� ������������ ��� Y ����������
             yCoordinate = YAbsParDistance();
         }
         // 2. ���� �� ����� ������������� ���� ������ ������� ������������� ����.
         if (yCoordinate + High() > YAbsParDistance() + ParHigh())
         {
             //����� ������������ ������ �������� ����
             //���������� ��������� ���������� ������ ������� ��� �������� Y ����������
             long newHigh = (YAbsParDistance() + ParHigh()) - yCoordinate;
             //���� Y ���������� ������� �������, ��� �� ������ ��� ���� �� �������� �����������
             //�� ������������ �����, �� ������� ������ � �������.
             if (newHigh <= 0)
                 Visible(false);
             Resize(Width(), newHigh);
         }
         // 3. ���� �� ����� ���� ����� ����� ������� ������������� ����.
         if (xCoordinate < XAbsParDistance())
         {
             // ����� ������������ ��� X ����������
             xCoordinate = XAbsParDistance();
         }
         // 4. ���� �� ����� ���� ������ ������ ������� ������������� ����.
         if (xCoordinate + Width() > XAbsParDistance() + ParWidth())
         {
             //����� ������������ ������ �������� ����
             //���������� ��������� ���������� ������ ������� ��� �������� X ����������
             long newWidth = (XAbsParDistance() + ParWidth()) - xCoordinate;
             //���� Y ���������� ������� �������, ��� �� ������ ��� ���� �� �������� �����������
             //�� ������������ �����, �� ������� ������ � �������.
             if (newWidth <= 0)
                 Visible(false);
             Resize(newWidth, High());
         }
         
         xDist = xCoordinate;
         yDist = yCoordinate;
         // ���������� ���������� ���� ������ � ��� ������, ���� �� ������������.
         bool res = true;
         if(Visible())
         {
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE, xDist))
            {
               LogWriter("Failed move element " + nameId, MESSAGE_TYPE_ERROR);
               res = false;
               xDist = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE);
            }
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_YDISTANCE, yDist))
            {
               LogWriter("Failed move element " + nameId, MESSAGE_TYPE_ERROR); 
               res = false;
               yDist = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_YDISTANCE);
            }
         }
         if(nameId == NULL || nameId == "")
            GenNameId();
         EventMove* em = new EventMove(EVENT_FROM_UP, nameId, XAbsDistance(), YAbsDistance(), COOR_GLOBAL);
         OnMove(em);
         delete em;
         return res;
      }
      ///
      /// �������� ����� ����������� ������� � �����������, ��������� � ��� ����. 
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
               //��������� ������� ��� ������� �������
               //Event* ev = event.Clone();
               node.Event(event);
               //delete ev;
            }
            // ? ������������ ������� �����������.
            //delete event;
         }
         //������� ���� �����-�����.
          if(event.Direction() == EVENT_FROM_DOWN)
         {
            if(parentNode != NULL)
               parentNode.Event(event);
         }
      }
      ///
      /// ���������� ��� ��������������� �������
      ///
      virtual void Deinit(EventDeinit* event)
      {
         for(int i = 0; i < childNodes.Total(); i++)
         {
            ProtoNode* node = childNodes.At(i);
            node.Event(event);
            delete node;
         }
         childNodes.Shutdown();
         Visible(false);
      }
      ///
      /// ���������� ������� ������� �� ����� ���������� � �������� ��� �������
      /// � ������������ � ���������-��������.
      ///
      void ExecuteCommand(EventNodeCommand* newEvent)
      {
         Move(newEvent.XDist(), newEvent.YDist());
         Resize(newEvent.Width(), newEvent.High());
         Visible(newEvent.Visible());
         OnCommand(newEvent);
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
      ENUM_OBJECT typeObject;
      
      ///
      /// ��� �������� ������������ ����������, � �������� ����������� ����������� ����. 
      ///
      ENUM_ELEMENT_TYPE elementType;
   private:
      ///
      /// ��������� �� ������ ����, ��� ����������� ������ ���� ��������.
      ///
      ProtoNode* bindOptWidth;
      ///
      /// ��������� �� ������ ����, ��� ����������� ������ ���� ��������.
      ///
      ProtoNode* bindOptHigh;
      ///
      /// ������ ��� ������������ ����, ��������� �� ������������������ ���� ���������� ����� � �������� ����� ����.
      ///
      string name;
      ///
      /// ��� ������������ ����, ������ ������������� � ��� ����������. ��������:
      /// "GeneralForm" ��� "TableOfOpenPosition".
      ///
      string shortName;
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
      /// �������� ����������� ������ ������� � �������.
      ///
      long optimalWidth;
      ///
      /// �������� ������ ������������ ���� � �������.
      ///
      long high;
      ///
      /// �������� ����������� ������ ������� � �������.
      ///
      long optimalHigh;
      ///
      /// ���������� �� ����������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ���� ���������.
      ///
      long xDist;
      ///
      /// ���������� �� ��������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ���� ���������.
      ///
      long yDist;
      ///
      /// ���� ���� ������������ ����.
      ///
      color bgColor;
      ///
      /// ���� ������� ��������� �����.
      ///
      color borderColor;
      ///
      /// ��� ����� ��� ������� "������������� �����".
      ///
      ENUM_BORDER_TYPE borderType;
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
      ///
      /// ������������� �������.
      /// \param mytype - ��� ������������ �������, �������� � ������ ������������ ����.
      /// \param myclassName - �����, � �������� ����������� ����������� ����.
      /// \param myname - �������� ������������ ����.
      /// \param parNode - ������������ ����, ������ �������� ������������� ������� ����.
      ///
      void Init(ENUM_OBJECT mytype, ENUM_ELEMENT_TYPE myElementType, string myname, ProtoNode* parNode)
      {
         if(parNode != NULL)
            name = parNode.Name() + "-->" + myname;
         else
            name = myname;
         shortName = myname;
         elementType = myElementType;
         parentNode = parNode;
         typeObject = mytype;
         optimalHigh = 20;
         optimalWidth = 80;
         borderType = BORDER_RAISED;
         switch(myElementType)
         {
            case ELEMENT_TYPE_GCONTAINER:
            case ELEMENT_TYPE_VCONTAINER:
               borderColor = clrBlack;
               bgColor = clrNONE;
               break;
            default:
               bgColor = clrWhite;
               borderColor = clrNONE;      
               break;
         }
      }
};