#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Object.mqh>
#include <Arrays\List.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Log.mqh"

///
/// ������������� ���� ������� �� ������� �������� ������.
///
#define MAIN_WINDOW 0
///
/// ������������� ������� �������, �� ������� �������� ������.
///
#define MAIN_SUBWINDOW 0

///
/// ���������������� �������: ������������ ����������� ���� ����������.
///
#define EVENT_PARENTNODE_MOVE 1

///
/// ���������������� �������: ������������ ����������� ���� ������� ������.
///
#define EVENT_PARENTNODE_RESIZE 2

///
/// ���������� � ������ ���� �������� ������� ����������� �������.
///
enum ENUM_TYPE_COORDINATE
{
   ///
   /// ������� ����������� ������� �������� � ���� ���������.
   ///
   COORDINATE_WINDOW,
   ///
   /// ������� ����������� ������� �������� � ���� ������ ������������� ������������ ��������.
   ///
   COORDINATE_PARENT
};
///
/// �������� ������������� � ���������� ���������� �������� ������������ ����.
///
class Coordinate
{
   public:
   ///
   /// ���������� � �������� �� ���� �������� ������������ ���� �� ���� ��������� ���� �� �����������.
   ///
   long WinX;
   ///
   /// ���������� � �������� �� ���� �������� ������������ ���� �� ���� ��������� ���� �� ���������.
   ///
   long WinY;
   ///
   /// ���������� � �������� �� ���� �������� ������������ ���� �� ���� ������������� ���� �� �����������.
   ///
   long ParentX;
   ///
   /// ���������� � �������� �� ���� �������� ������������ ���� �� ���� ������������� ���� �� ���������.
   ///
   long ParentY;
};

///
/// <b>������������� ����������� ����.</b> ������ ����������� �������, ���� �� ������, ��������� ����� ��� �����������, ������������� � ����������� �����-��������� GNode.
/// ���� �����-��������� � ���� ������� ������ �� ������ ������ �� ������-��������. �������� ������ � �������� ����������� �� ����������� ����� �������� �������������
/// ���������: �� ����� ������� ������ ��������� ������� GNode �������������� ���������� �����, ������ ���� ��������� ����� �� ������� �������������� ������, � ������ �����
/// �������� ����� ��������� ��������� ����������� ���� �������������� �������.
///
class GNode : CObject
{
   public:
      ///
      /// �������� ������ ������������ ���� node �� �����. � ������ ������ �������� ������� OnResize ����, ������
      /// �������� ��� �������.
      /// \param *node - ����������� ����, ������ �������� ��������� ��������.
      /// \param newWidth - ����� ������ ������������ ����.
      /// \param newHigh - ����� ������ ������������ ����.
      /// \return ������, ���� ������ ��� �������, ���� - � ��������� ������.
      //bool Resize(GNode *node, long newWidth, long newHigh){return true;}
      ///
      /// ��� ������� ���������� ��� ��������� ������� �������� ������������ ����.
      /// \param newWidth - ����� ������ �������� ������������ ����. 
      /// \param newHigh - ����� ������ �������� ������������ ����.
      ///
      virtual void OnResize(long newWidth, long newHigh){;}
      ///
      /// ����������� ����������� ���� �� ����� �����, ���������� ������������ location. � ������ ������ ��������
      /// ������� OnMove ����, ������� ��� ����������.
      /// \param *node - ��������� �� ����, ������� ��������� �����������.
      /// \param *location - ���������� ����, �� ������� ��������� ����������� ����.
      ///
      bool Move(GNode *node, Coordinate *location);
      ///
      /// ��� ������� ���������� ��� ��������� ��������� �������� ������������ ����.
      /// \param *location - ����������, �� ������� ��� ���������� ������� ����������� ����.
      ///
      virtual void OnMove(Coordinate *location){;}
      ///
      /// ������������� ��������� ���� node. � ������ ������ �������� ������� OnVisible ����, ��������� �������� ���� ��������.
      /// \param *node - ����������� ����, ��������� �������� ���� ��������.
      /// \param isVisible - ���� ���������. ������, ���� ����������� ���� ��������� ����������
      /// � ���� ���������. ����, ���� ����������� ���� ��������� ������� � ���� ���������.
      /// \return ������, ���� ��������� ��������� ���� ������ �������, ���� - � ��������� ������.
      //bool Visible(GNode *node, bool isVisible);
      ///
      /// ��� ������� ��������� ��� ��������� ��������� �������� ������������ ����.
      /// \param isVisible - ���� ���������. ������, ���� ����������� ���� ���� ������������ � ���� ���������.
      /// ����, ���� ����������� ���� ��� ������ � ���� ���������.
      ///
      virtual void OnVisible(bool isVisible){;}
      
      
      ///
      /// ����������� ������� ����������� ���� �� ����� ����������.
      /// \param newXDist - ����� ���������� � ������� �� ��������� �� ���� �������� �������� ������������ ��������. 
      /// \param newYDist - ����� ���������� � ������� �� ����������� �� ���� �������� �������� ������������ ��������. 
      /// \param context - ��� ���� �������� ������� ������������ ��������.
      /// \return ������, ���� ������������ ������ ������, ���� - � ��������� ������.
      ///
      bool Move(int newXDist, int newYDist, ENUM_TYPE_COORDINATE context);
      ///
      /// ������������� ����� ������ ��� �������� ������������ ����.
      /// \param newWidth - ����� ������ ������������ �������� � �������.
      /// \param newHigh - ����� ������ ������������ �������� � �������.
      /// \return ������, ���� ����� ������ ������������ �������� ��� ������ ����������, ���� � ��������� ������.
      bool Resize(long newWidth, long newHigh);
      ///
      /// ������������� ���� ��������� �������� � ���� ��� ������������.
      /// \param isVisible - ���� ��������� ��������. ������, ���� ������� � ��� ��� ����������� ������������ �� �����,
      /// ���� - � ��������� ������.
      ///
      void SetVisible(bool isVisible);
      ///
      /// ���������� ���� ��������� �������� � ���� ��� ������������.
      /// \return ������, ���� ������� � ��� ��� ����������� ������, ���� � ��������� ������.
      ///
      bool GetVisible(void);
      ///
      /// ���������� ���������� � ������� �� ����������� �� ���� �������� �������� ������������ ��������.
      /// 
      int GetXDistance();
      ///
      /// ���������� ���������� � ������� �� ��������� �� ���� �������� �������� ������������ ��������.
      ///
      int GetYDistance();
      ///
      /// ���������� ������ � ������� �������� ������������ ��������.
      ///
      long GetWidth(){return width;}
      ///
      /// ���������� ������ � ������� �������� ������������ ��������.
      ///
      long GetHigh(){return high;}
      ///
      /// ������������� ���� �������� �������� ������������ ��������. ����� ������ ������� ���������� ����� ������������� ������������ ����� �������, ��� �� ��
      /// �������� ��������������� ���������� ���� ��������.
      /// \param ctype       - ��� ����, � �������� ��������� ��������� �������.
      /// \return ������, ���� ���������� ��������� � ����� ��������� ��������� ������� � ���� � �������� ������.
      bool SetCoordinatesType(ENUM_TYPE_COORDINATE ctype);
      ///
      /// �������������� ����������� ����������� ������� � ������ myName (��� ����� ���� �� ����������).
      ///
      GNode(string myName);
      ///
      /// �������������� ������� � ������ myName (����� ���� �� ����������) � ��������� ��� ������������� ������������ ��������.
      ///
      GNode(string myName, GNode *pNode);
      ///
      /// ���������� ���������� �������� ���������.
      ///
      int GetChildCount();
   protected:
      ///
      /// ��������� �� ������������ ����������� �������.
      ///
      GNode * parentNode;
      /// <b>�������� �������� GNode, ��������������� ������ �������� ������������ ����.</b>
      /// ������ �������� ������������ ���� GNode ����� ���������
      /// �������������� ���������� ����� ��, �������� ���������� ���������
      /// (MQL5 �� ������������ ����������� ���������� �������, �
      /// CArrayObj �� ����� �������� � ��������� CObject, �������
      /// ���������� ������ ��������� CObject)
      CArrayObj childNodes;
      ///
      /// ��� �������, �������� � ������ ����.
      ///
      ENUM_OBJECT ObjectType;
      ///
      /// ��� ������������ �������� (����� ���������� � ������ ����������� ���������).
      ///
      string name;
      ///
      /// ����������� ��������� � �������� ����� ������������ � �������� ����������� ���������
      ///
      int minDist;
      ///
      /// ���������� ������������� ����, ���������� ������������ ��� �� �������.
      ///
      string nameId;
      ///
      /// ���� ��������� ����. ������ - ���� ���� ������������ �� �������, ���� � ��������� ������.
      ///
      bool visible;
      ///
      /// ������������� ����, � ������� ������������ ������� ����.
      ///
      int chartId;
      ///
      /// ������ ������������ ���� GNode � �������.
      ///
      long width;
      ///
      /// ������ ������������ ���� GNode � �������.
      ///
      long high;
      ///
      /// ��������� � ������� �� ����������� �� ���� �������� �������� ������������ ��������.
      ///
      int xDistance;
      ///
      /// ��������� � ������� �� ��������� �� ���� �������� �������� ������������ ��������.
      ///
      int yDistance;
      ///
      /// ���������� � ������ ���� �������� ������� ����������� �������. ��������� �� ����������� � ��������� �������������
      /// ����������������� � ����������� �� ���� ��������.
      ///
      ENUM_TYPE_COORDINATE typeCoordinate;
      ///
      /// �������������� ����������� �������
      ///
      void Init(string myName, GNode* pNode);
      ///
      /// ���������� ���������� ��� ��������, � ������� �������� ����� ���������� ����������������
      /// ������� �� ������� ���������.
      ///
      void GenNameId(void);
   private:
      
      
};
GNode::GNode(string myName)
{
   Init(myName, NULL);
}

GNode::GNode(string myName, GNode *pNode)
{
   Init(myName, pNode);
}
void GNode::Init(string myName, GNode *pNode)
{     
   name = myName;
   parentNode = pNode;
   visible = false;
   xDistance = 0;
   yDistance = 0;
   typeCoordinate = COORDINATE_PARENT;
   GenNameId();
}

bool GNode::Resize(long newWidth, long newHigh)
{
   TracePush(__FUNCTION__);
   //����� ������� �� ������ ��������� �������� ������������� ����, ���� �� ����.
   if(CheckPointer(parentNode) != POINTER_INVALID)
   {
      long maxWidth = parentNode.GetWidth() - minDist;
      long maxHigh = parentNode.GetHigh() - minDist;
      if(newWidth >= maxWidth)newWidth = maxWidth;
      if(newHigh >= maxHigh)newHigh = maxHigh;
   }
   //���� ������� ������ ������������ �������� ��� ������������.
   if(visible)
   {
      bool res = false;
      res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE, newWidth);
      if(!res)
         LogWriter("Failed resize element " + nameId + " by horizontally.", MESSAGE_TYPE_ERROR);
      res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE, newHigh);
      if(!res)
         LogWriter("Failed resize element " + nameId + " by verticaly.", MESSAGE_TYPE_ERROR);
   }
   width = newWidth;
   high = newHigh;
   OnResize(width, high);
   TracePop();
   return true;
}

bool GNode::Move(int newXDist, int newYDist, ENUM_TYPE_COORDINATE context)
{
   
   //����� ���������� �� ������ �������� �� ������� �������� ����.
   /*if(CheckPointer(parentNode)!= INVALID_HANDLE)
   {
      ;
   }*/
   xDistance = newXDist;
   yDistance = newYDist;
   if(visible)
   {
      ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XDISTANCE, xDistance);
      ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YDISTANCE, yDistance);
   }
   return true;
}

void GNode::SetVisible(bool isVisible)
{
   //���������� ������� �������
   if(isVisible && !visible)
   {
      visible = ObjectCreate(MAIN_WINDOW, nameId, ObjectType, MAIN_SUBWINDOW, xDistance, yDistance);
      ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE, width);
      ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE, high);
      OnVisible(visible);
      //��� ����������� �������� �������� ����� ������������� ���������� ������:
      /*GNode *p = NULL;
      for(int i = 0; i < childNodes.Total(); i++)
      {
         p = childNodes.At(i);
         p.SetVisible(true);
      }*/
   }
   else if(!isVisible && visible)
   {
      //��� ����������� �������� �������� ����� ������������� ���������� ��������:
      /*GNode *p = NULL;
      bool res = true;
      for(int i = 0; i < childNodes.Total(); i++)
      {
         p = childNodes.At(i);
         p.SetVisible(false);
      }*/
      visible = !ObjectDelete(MAIN_WINDOW, nameId);
      OnVisible(visible);
   }
}

void GNode::GenNameId(void)
{
   //�������� ��� � ��������� ��� ����������� ������
   int index = GetChildCount();
   //���� ������ � ����� ������ ��� ����������
   //��������� � ����� ������, �� ��� ��� ���� ��� �� ������ ����������.
   int res = -1;
   while(res > 0)
      res = ObjectFind(0, name + (string)index++);
   nameId = name+(string)index;
}

int GNode::GetChildCount()
{
   if(CheckPointer(parentNode) == POINTER_INVALID)
      return 0;
   else
      return parentNode.GetChildCount();
}
