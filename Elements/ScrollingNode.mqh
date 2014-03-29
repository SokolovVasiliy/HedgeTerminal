//+------------------------------------------------------------------+
//|                                                ScrollingNode.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "Node.mqh"
#include "Button.mqh"

class ScrollingNode;
///
/// ���������� ��� �������.
///
enum ENUM_SCROLL_TYPE
{
   ///
   /// ������������ ������.
   ///
   SCROLL_VERTICAL,
   ///
   /// �������������� ������.
   ///
   SCROLL_HORIZONTAL
};

///
/// ������.
///
class NewScroll : public ProtoNode
{
   public:
      NewScroll(string myName, ProtoNode* parNode, ENUM_SCROLL_TYPE sType) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         //��� ������� ������ ���� �������� �� ����� ��� ��������
         scrollType = sType;
      }
      ///
      /// ���������� ������, ��� ��������� ������ ��� ��� ������ ���������.
      ///
      void FrameChanged(){;}
      ///
      /// ��������� ������ � ���������, ������� ���������� ���������.
      ///
      void LinkWithNode(ScrollingNode* node){scrolling = node;}
      ///
      /// ���������� ��� �������.
      ///
      ENUM_SCROLL_TYPE ScrollType(void){return scrollType;}
   private:
      ///
      /// �������, �������� �������� ���������.
      ///
      ScrollingNode* scrolling;
      ///
      /// ��� �������.
      ///
      ENUM_SCROLL_TYPE scrollType;
};

///
/// ��� ������ �������.
///
enum ENUM_SCROLL_BUTTON_TYPE
{
   SCROLL_BUTTON_UP,
   SCROLL_BUTTON_DOWN,
   SCROLL_BUTTON_LEFT,
   SCROLL_BUTTON_RIGHT,
};
///
/// ���� �� ������� ��������� ������ �������. ��������� ������ �� ����� �������.
///
class ButtonScroll : public Button
{
   public:
      ButtonScroll(NewScroll* scroll, ENUM_SCROLL_BUTTON_TYPE type) : Button("ButtonScroll", scroll)
      {
         btnScrollType = type;
         
      }
   private:
      ENUM_SCROLL_BUTTON_TYPE btnScrollType;
};

///
/// ���������� ������� �������������� �������������� � ������������ ������.
///
class ScrollingNode : public ProtoNode
{
   public:
      ///
      /// ����������� ������ �� ��������� ����.
      /// \param scroll - ������, �������� ���������� ����� �� ���������� ������ ����.
      ///
      void AddScroll(NewScroll* scroll)
      {
         if(scroll.ScrollType() == SCROLL_VERTICAL)
            vscroll = scroll;
         else if(scroll.ScrollType() == SCROLL_HORIZONTAL)
            gscroll = scroll;
      }
      ///
      /// �������� ����� ������ ��������.
      ///
      virtual ulong ScrollVertical(){return 0;}
      ///
      /// �������� ����� ������ ��������.
      ///
      virtual ulong ScrollHorizontal(){return 0;}
      ///
      /// �������� ������ ������� ������� ��������.
      ///
      virtual ulong ScrollFrameVertical()
      {
         return High();
      }
      ///
      /// �������� ������ ������� ������� ��������.
      ///
      virtual ulong ScrollFrameHorizontal()
      {
         return Width();
      }
      ///
      /// �������� ��������� �� ��������� �� ������� ������� �������� �� ��� ������� �������.
      ///
      virtual ulong ScrollVerticalToFrame(){return distVertical;}
      ///
      /// �������� ��������� �� ����������� �� ������� ������� �������� �� ��� ����� �������.
      ///
      virtual ulong ScrollHorizontalToFrame(){return distHorizontal;}
      ///
      /// ������������� ��������� �� ��������� �� ������� ������� �������� �� ��� ������� �������.
      ///
      void ScrollVerticalToFrame(ulong y)
      {
         if(ScrollVertical() == 0)return;
         if(y + ScrollFrameVertical() > ScrollVertical())
            y = ScrollVertical() - ScrollFrameVertical();
         distVertical = y;
         OnChangeFrame();
      }
      ///
      /// ������������� ��������� �� ����������� �� ������� ������� �������� �� ��� ����� �������.
      ///
      void ScrollHorizontalToFrame(ulong x)
      {
         if(ScrollHorizontal() == 0)return;
         if(x + ScrollFrameHorizontal() > ScrollHorizontal())
            x = ScrollHorizontal() - ScrollFrameHorizontal();
         distHorizontal = x;
         OnChangeFrame();
      }
   protected:
      ScrollingNode(ENUM_OBJECT mytype, ENUM_ELEMENT_TYPE myElementType, string myname, ProtoNode* parNode) :
      ProtoNode(mytype, myElementType, myname, parNode){;}
      ///
      /// ����������, ����� ������ �������� ��������� �� ������.
      ///
      virtual void OnChangeFrame(){;}
      ///
      /// ���������� ������ �� ��������� ������� ������.
      ///
      void ScrollNoticeByChanged()
      {
         if(vscroll != NULL)
            vscroll.FrameChanged();
         if(gscroll != NULL)
            gscroll.FrameChanged();
      }
   private:
      
      ///
      /// ��������� �� ������������ ������.
      ///
      NewScroll* vscroll;
      ///
      /// ��������� �� �������������� ������.
      ///
      NewScroll* gscroll;
      ///
      /// �������� ��������� � �������� �� ��������� �� ������� ������� �������� �� ��� ����� �������.
      ///
      ulong distVertical;
      ///
      /// �������� ��������� � �������� �� ����������� �� ������� ������� �������� �� ��� ����� �������. 
      ///
      ulong distHorizontal;
};
