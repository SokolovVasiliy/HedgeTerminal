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
      /// ���������� ���������� ��������� ������������� ������������ ����.
      /// \return ���������� ��������� ������������� ������������ ����.
      ///
      string NameID(){return nameId;}
      ///
      /// ���������� ���������� �� ����������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ���� ���������.
      /// \return ���������� � ������� �� ��� �.
      ///
      long XDistance(){return xDist;}
      ///
      /// ���������� ���������� �� ��������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ���� ���������.
      /// \return ���������� � ������� �� ��� Y.
      ///
      long YDistance(){return yDist;}
      ///
      /// ���������� ���������� �� ����������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ������������� ������������ ����.
      /// \return ���������� � ������� �� ��� X.
      ///
      long XParDistance()
      {
         if(parentNode != NULL)
            return parentNode.XDistance();
         else return 0;
      }
      ///
      /// ���������� ���������� �� ��������� �� ������ �������� ���� ������������ ����
      /// �� ������ �������� ���� ������������� ������������ ����.
      /// \return ���������� � ������� �� ��� Y.
      ///
      long YParDistance()
      {
         if(parentNode != NULL)
            return parentNode.YDistance();
         else return 0;
      }
      ///
      /// ���������� ������ ������������� ������������ ����. ���� ������������
      /// ����������� ���� �� ����� - ���������� 0.
      ///
      long ParWidth()
      {
         if(parentNode != NULL)
            return parentNode.Width();
         else return 0;
      }
      ///
      /// ���������� ������ ������������� ������������ ����. ���� ������������
      /// ����������� ���� �� ����� - ���������� 0.
      ///
      long ParHigh()
      {
         if(parentNode != NULL)
            return parentNode.High();
         else return 0;
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
         if(parentNode != NULL)
         {
            // 1. ���� �� ����� ������������� ���� ������� ������� ������������� ����.
            //XDistance()
            //XAbs
            // 2. ���� �� ����� ������������� ���� ������ ������� ������������� ����.
            // 3. ���� �� ����� ���� ����� ����� ������� ������������� ����.
            // 4. ���� �� ����� ���� ������ ������ ������� ������������� ����.
            if(XParDistance() + newWidth > parentNode.Width())
               newWidth = parentNode.Width() - XParDistance();
            if(YParDistance() + newHigh > parentNode.High())
            {
               long h = parentNode.High();
               long y = YParDistance();
               newHigh = h - y;
               //newHigh = parentNode.High() - YParDistance();
            }
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
         long newWidth, newHigh;
         long X = parentNode == NULL ? ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW):
                                       parentNode.Width();
         long Y = parentNode == NULL ? ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW):
                                       parentNode.High();
         newWidth = X - XDistance() - RightBorder;
         newHigh = Y - YDistance() - DnBorder;
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
            //���������� ����� ��� ������ ��� ����� ��������� ���������� �������, ���������� ��� ������������.
            GenNameId();
            visible = ObjectCreate(MAIN_WINDOW, nameId, typeObject, MAIN_SUBWINDOW, XDistance(), YDistance());
            //���������� ������� � ������������ � ��� �������������� ������������
            Move(xDist, yDist);
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
         if(context == COOR_LOCAL && parentNode != NULL)
         {
            xCoordinate = xCoordinate + XParDistance();
            yCoordinate = yCoordinate + YParDistance();
         }
         // ���������, �� ������ �� �� ������� ������������� ���� �����
         // ����������� ����������.
         if(parentNode != NULL)
         {
            long xParDist = XParDistance();
            long yParDist = YParDistance();
            if(xCoordinate < xParDist)
               xCoordinate = xParDist;
            if(yCoordinate < yParDist)
               yCoordinate = xParDist;
            if(xCoordinate + width > xParDist + parentNode.Width())
               xCoordinate = xParDist + (parentNode.Width() - width);
            if(yCoordinate + high > yParDist + parentNode.High())
               yCoordinate = yParDist + (parentNode.High() - high);
         }
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
         //� ������ ���������� ����������� ��������, ���������� �� ������������ ��������������.
         if(!res)
         {
            xDist = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE);
            yDist = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE);
         }
         else
         {
            xDist = xCoordinate - XParDistance();
            yDist = yCoordinate - YParDistance();
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


