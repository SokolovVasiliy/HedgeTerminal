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
   ELEMENT_TYPE_HEAD_COLUMN
};

///
/// �������� ����������� ��������� ��� ������� Move().
///
enum ENUM_COOR_CONTEXT
{
   ///
   /// ������� ���������� �������� ������������ ������ �������� ���� ���� ���������.
   ///
   COOR_GLOBAL,
   ///
   /// ������� ���������� �������� ������������ ������ �������� ���� ������������� ����.
   ///
   COOR_LOCAL
};

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
         width = newWidth;
         high = newHigh;
         // ���� ������ ��� ����� �����������, ���� ����� ���� - �� ������� �� �����.
         if((newHigh <= 0 || newWidth <= 0) && Visible())
            Visible(false);
         // 2) ������������� ����������� ����, ���� �� ������������ � ���� ���������.
         bool res = true;
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
         return res;
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
            // ������� ������ ���� ���������.
            if(width <= 0 || high <= 0)
               return false;
            // 1. ���� �� ����� ������������� ���� ������� ������� ������������� ����.
            if (yDist < YAbsParDistance())
            {
                LogWriter("Y-coordinate of node must be leter Y-coordinate parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 2. ���� �� ����� ������������� ���� ������ ������� ������������� ����.
            if (yDist + High() > YAbsParDistance() + ParHigh())
            {
                long ypar = YAbsParDistance();
                long hpar = ParHigh();
                LogWriter("Node position must be biger down line parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 3. ���� �� ����� ���� ����� ����� ������� ������������� ����.
            if (XAbsDistance() < XAbsParDistance())
            {
                LogWriter("X-coordinate of node must be leter X-coordinate parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 4. ���� �� ����� ���� ������ ������ ������� ������������� ����.
            if (XAbsDistance() + Width() > XAbsParDistance() + ParWidth())
            {
                LogWriter("Node position must be biger left line parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            //���������� ����� ��� ������ ��� ����� ��������� ���������� �������, ���������� ��� ������������.
            GenNameId();
            visible = ObjectCreate(MAIN_WINDOW, nameId, typeObject, MAIN_SUBWINDOW, XAbsDistance(), YAbsDistance());
            //���������� ������� � ������������ � ��� �������������� ������������
            Move(xDist, yDist, COOR_GLOBAL);
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
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE, xCoordinate))
            {
               LogWriter("Failed move element " + nameId, MESSAGE_TYPE_ERROR);
               res = false;
            }
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_YDISTANCE, yCoordinate))
            {
               LogWriter("Failed move element " + nameId, MESSAGE_TYPE_ERROR); 
               res = false;
            }
         }
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
               Event* ev = event.Clone();
               node.Event(ev);
               delete ev;
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
      /// ��� ������������ ����, ������ ������������� � ��� ����������. ��������:
      /// "GeneralForm" ��� "TableOfOpenPosition".
      ///
      string name;
      ///
      /// ��� �������� ������������ ����������, � �������� ����������� ����������� ����. 
      ///
      ENUM_ELEMENT_TYPE elementType;
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
      long xDist;
      ///
      /// ���������� �� ��������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ���� ���������.
      ///
      long yDist;
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
         elementType = myElementType;
         parentNode = parNode;
         typeObject = mytype;
      }
};


