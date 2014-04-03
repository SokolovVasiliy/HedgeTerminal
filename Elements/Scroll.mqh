//+------------------------------------------------------------------+
//|                                                       Scroll.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "..\Events.mqh"
#include "Node.mqh"
#include "Button.mqh"

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
/// ��� ������ �������.
///
enum ENUM_SCROLL_BUTTON_TYPE
{
   SCROLL_BUTTON_UP,
   SCROLL_BUTTON_DOWN,
   SCROLL_BUTTON_LEFT,
   SCROLL_BUTTON_RIGHT,
};


class Scroll;
///
/// ���� �� ������� ��������� ������ �������. ��������� ������ �� ����� �������.
///
class ButtonScroll : public Button
{
   public:
      ButtonScroll(Scroll* nscroll, ENUM_SCROLL_BUTTON_TYPE type) : Button("ButtonScroll", nscroll)
      {
         btnScrollType = type;
         scroll = nscroll;
      }
   private:
      
      virtual void OnRedraw(EventRedraw* event)
      {
         switch(btnScrollType)
         {
            case SCROLL_BUTTON_UP:
               UpMove();
               break;
            case SCROLL_BUTTON_DOWN:
               DnMove();
               break;
            case SCROLL_BUTTON_LEFT:
               LeftMove();
               break;
            case SCROLL_BUTTON_RIGHT:
               RightMove();
               break;
         }
         if(!Visible())
            Visible(true);
      }
      void UpMove()
      {
         Move(2,2, COOR_LOCAL);
         long w = scroll.Width()-4;
         Resize(w, w);
         Font("Wingdings");
         Text(CharToString(241));
      }
      void DnMove()
      {
         long y = ParHigh() - ParWidth() + 2;
         Move(2,y, COOR_LOCAL);
         long w = scroll.Width()-4;
         Resize(w, w);
         Font("Wingdings");
         Text(CharToString(242));
      }
      void LeftMove()
      {
         Move(2,2, COOR_LOCAL);
         long h = scroll.High()-4;
         Resize(h, h);
         Font("Wingdings");
         Text(CharToString(239));
      }
      void RightMove()
      {
         long w = ParWidth() - ParHigh() + 2;
         Move(w,2, COOR_LOCAL);
         long h = scroll.High()-4;
         Resize(h, h);
         Font("Wingdings");
         Text(CharToString(240));
      }
      virtual void OnPush()
      {
         int step = scroll.CurrentStep();
         switch(btnScrollType)
         {
            case SCROLL_BUTTON_UP:
            case SCROLL_BUTTON_LEFT:
               scroll.CurrentStep(--step);
               break;
            case SCROLL_BUTTON_DOWN:
            case SCROLL_BUTTON_RIGHT:
               scroll.CurrentStep(++step);
               break;
         }
         scroll.SendChangeScrollEvent();
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE, false);
      }
      
      ENUM_SCROLL_BUTTON_TYPE btnScrollType;
      ///
      /// ������ �� ������.
      ///
      Scroll* scroll;
};

class ScrollArea;
///
/// �������� �������.
///
class Todler : public Label
{
   public:
      Todler(ScrollArea* area) : Label("toddler", area)
      {
         BorderColor(Settings.ColorTheme.GetBorderColor());
         BackgroundColor(Settings.ColorTheme.GetSystemColor1());
         Text("");
         Scroll* scroll = area.GetScroll();
         scrollType = scroll.ScrollType();
         scrollArea = area;
      }
      ///
      /// ���������� ���������� ��������.
      ///
      long Coordinates()
      {
         long c = 0;
         if(scrollType == SCROLL_VERTICAL)
            c = YLocalDistance();
         if(scrollType == SCROLL_HORIZONTAL)
            c = XLocalDistance();
         if(c <= 0)
            return 1;
         return c;
      }
      ///
      /// ������, ���� �������� �������� ��� �����������.
      ///
      bool IsMove(){return isMove;}
   private:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_MOUSE_MOVE:
               OnMoveMouse(event);
               break;
         }
      }
      ///
      /// ���������� ����������� ����.
      ///
      void OnMoveMouse(EventMouseMove* event)
      {
         if(ResetTodler(event))return;
         if(SetTodler(event))return;
         MoveTodler(event);
      }
      ///
      /// ���������� ����� ����������� ��������
      ///
      bool ResetTodler(EventMouseMove* event)
      {
         if(!event.PushedLeftButton() && isMove)
         {
            isMove = false;
            coord = 0;
            return true;
         }
         return false;
      }
      ///
      /// ������������� ����� ����������� ��������.
      ///
      bool SetTodler(EventMouseMove* event)
      {
         if(!isMove && event.PushedLeftButton() &&
            IsMouseSelected(event))
         {
            isMove = true;
            if(scrollType == SCROLL_VERTICAL)
               coord = event.YCoord();
            if(scrollType == SCROLL_HORIZONTAL)
               coord = event.XCoord();
            return true;
         }
         return false;
      }
      ///
      /// ������� �������� ����� ������������ ����� �� �����.
      ///
      void MoveTodler(EventMouseMove* event)
      {
         if(!isMove)return;
         long delta = GetDelta(event);
         if(scrollType == SCROLL_VERTICAL)
         {
            coord = event.YCoord();
            Move(1, YLocalDistance()+delta);
         }
         if(scrollType == SCROLL_HORIZONTAL)
         {
            coord = event.XCoord();
            Move(XLocalDistance()+delta, 1);
         }
         scrollArea.SetCurrentStepByTodler();
      }
      ///
      /// ���������� ������� ����� ������ � ����� �����������.
      /// ������� ����� ��� ������������� ��� � ������������� ������.
      ///
      long GetDelta(EventMouseMove* event)
      {
         long delta = 0;
         if(scrollType == SCROLL_VERTICAL)
         {
            delta = event.YCoord() - coord;
            //������� ������.
            if(YLocalDistance()+delta < 1)
               delta = (-1) * (YLocalDistance()-1);
            //������ ������.
            else
            {
               long t = scrollArea.High() - YLocalDistance() - scrollArea.GetHigh() - 1;
               if(delta > t)delta = t;
            }
         }
         if(scrollType == SCROLL_HORIZONTAL)
         {
            delta = event.XCoord() - coord;
         }
         return delta;
      }
      ///
      /// ������, ���� �������� ���������� � ��������� �����������.
      ///
      bool isMove;
      ///
      /// ��������� ��������� ����������.
      ///
      long coord;
      ///
      /// ������������ ��������.
      ///
      ScrollArea* scrollArea;
      ///
      /// ��� �������.
      ///
      ENUM_SCROLL_TYPE scrollType;
};

class Scroll;
///
/// ������������ �������� �������.
///
class ScrollArea : public Label
{
   public:
      ScrollArea(Scroll* nscroll) : Label(ELEMENT_TYPE_TODDLER, "Scroll area", nscroll)
      {
         BorderColor(Settings.ColorTheme.GetSystemColor2());
         Text("");
         scroll = nscroll;
         toddler = new Todler(GetPointer(this));
         
         childNodes.Add(toddler);
      }
      ///
      /// ������������� ��������.
      ///
      void RefreshToddler()
      {
         if(scroll.TotalSteps() == 0)
         {
            if(toddler.Visible())
            {
               EventVisible* event = new EventVisible(EVENT_FROM_UP, GetPointer(this), false);
               toddler.Event(event);
               delete event;
            }
            return;
         }
         //������������� �������� � ������ �������������.
         if(!toddler.IsMove())
         {
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), ParVisible(), GetX(), GetY(), GetWidth(), GetHigh());
            toddler.Event(command);
            delete command;
         }
      }
      ///
      /// �������� ������ ��������.
      ///
      long GetHigh()
      {
         if(scroll.ScrollType() == SCROLL_VERTICAL)
            return ParWidth()-4;
         return ParHigh()-4;
      }
      ///
      /// �������� ������ ��������.
      ///
      long GetWidth()
      {
         if(scroll.ScrollType() == SCROLL_VERTICAL)
            return ParWidth()-4;
         return ParHigh()-4;
      }
      ///
      /// ���������� ��������� �� ������, �������� ����������� ������������.
      ///
      Scroll* GetScroll(){return scroll;}
      
      ///
      /// ������������ ������� ��� � ����������� �� ��������� ��������.
      ///
      int CalcCurrentStepByTodler()
      {
         int step = scroll.CurrentStep();
         //� ������� ������� ��������� �������� ���������� ����� ������� ������.
         if(toddler.Coordinates() <= 1 || scroll.TotalSteps() == 0)
            step = 0;
         //� ������� ������ ��������� �������� ������� ������� �� �����.
         else if(toddler.Coordinates() + GetHigh() == High()-1)
            step = scroll.TotalSteps();
         else
         {
            long thigh = High()-GetHigh();
            double piksInStep = (double)thigh/scroll.TotalSteps(); //�������� � ����� ����.
            step = (int)(toddler.Coordinates()/piksInStep);
         }
         return step;
      }
      ///
      /// ������������� ������� ��� � ����������� �� ��������� ��������.
      ///
      void SetCurrentStepByTodler()
      {
         int step = CalcCurrentStepByTodler();
         if(scroll.CurrentStep() != step)
            scroll.CurrentStepIntro(step);
         
      }
   private:
      ///
      /// ������������� ������������ ������������ �������� � ��� ��������.
      ///
      virtual void OnRedraw(EventRedraw* event)
      {
         //BorderColor(clrRed);
         //Text("");
         if(scroll.ScrollType() == SCROLL_VERTICAL)
         {
            Move(1, ParWidth()-2);
            Resize(ParWidth()-2, ParHigh() - 2*ParWidth()+4);
         }
         if(scroll.ScrollType() == SCROLL_HORIZONTAL)
         {
            Move(ParHigh()-2, 1);
            Resize(ParWidth() - 2*ParHigh()+4, ParHigh()-2);
         }
         if(!Visible())
            Visible(true);
         RefreshToddler();
      }
      ///
      /// �������� ���������� �� ��� X ��� ���������������� ��������.
      ///
      long GetX()
      {
         if(scroll.ScrollType() == SCROLL_VERTICAL)
            return 1;
         //��� ��������������� �������� �������� �� ���������. ��. �������� �� GetY()
         return 1;
      }
      ///
      /// �������� ���������� �� ��� Y ��� ���������������� ��������.
      ///
      long GetY()
      {
         if(scroll.ScrollType() == SCROLL_HORIZONTAL ||
            scroll.TotalSteps() == 0)
            return 1;
         //�������� ����� (�� ��������).
         //int step = CalcCurrentStepByTodler();
         //if(step == scroll.CurrentStep())
         //   return toddler.Coordinates();
         long tod_high = toddler.High();
         long thigh = High()-toddler.High();
         double piksInStep = (double)thigh/scroll.TotalSteps(); //�������� � ����� ����.
         long piksNow = (long)(piksInStep*scroll.CurrentStep());
         //������������� ������.
         if(piksNow + GetHigh() >= High())
            piksNow = High() - GetHigh() - 1;
         if(piksNow <= 0)piksNow = 1;
         return piksNow;
      }
      
      ///
      /// ������, �������� ����������� ������������.
      ///
      Scroll* scroll;
      ///
      /// �������� �������.
      ///
      Todler* toddler;
};

class Scrolling;
///
/// ������.
///
class Scroll : public ProtoNode
{
   public:
      Scroll(string myName, ProtoNode* parNode, ENUM_SCROLL_TYPE sType) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         //��� ������� ������ ���� �������� �� ����� ��� ��������
         scrollType = sType;
         ProtoNode * el = new ScrollArea(GetPointer(this));
         scrollArea = el;
         childNodes.Add(el);
         if(sType == SCROLL_VERTICAL)
         {
            el = new ButtonScroll(GetPointer(this),SCROLL_BUTTON_UP);
            childNodes.Add(el);
            el = new ButtonScroll(GetPointer(this), SCROLL_BUTTON_DOWN);
            childNodes.Add(el); 
         }
         if(sType == SCROLL_HORIZONTAL)
         {
            el = new ButtonScroll(GetPointer(this),SCROLL_BUTTON_LEFT);
            childNodes.Add(el);
            el = new ButtonScroll(GetPointer(this), SCROLL_BUTTON_RIGHT);
            childNodes.Add(el);
         }
      }
      ///
      /// ���������� ����������� �� ��������� ��������� �������.
      ///
      void SendChangeScrollEvent()
      {
         EventScrollChanged* event = new EventScrollChanged(EVENT_FROM_DOWN, GetPointer(this));
         EventSend(event);
         delete event;
      }
      ///
      /// ����������� ������� ��������� � ���������.
      ///
      //void LinkToScrolling(Scrolling* scr){scrolling = scr;}
      ///
      /// ��������� ���������������� ��������.
      ///
      void RefreshToddler(void)
      {
         scrollArea.RefreshToddler();
      }
      ///
      /// ���������� ��� �������.
      ///
      ENUM_SCROLL_TYPE ScrollType(){return scrollType;}
      ///
      /// ���������� ������� ���.
      ///
      int CurrentStep(void)
      {
         return currStep;
      }
      ///
      /// ������������� ������� ��� �� ���.
      ///
      void CurrentStep(int step)
      {
         if(step < 0 || step > totalSteps || step == currStep)
            return;
         currStep = step;
         RefreshToddler();
      }
      ///
      /// ������������� ������� ��� �� �����.
      ///
      void CurrentStepIntro(int step)
      {
         if(step < 0 || step > totalSteps || step == currStep)
         {
            printf("set current set failed");
            return;
         }
         currStep = step;
         SendChangeScrollEvent();
      }
      ///
      /// ���������� ����� ���������� �����.
      ///
      int TotalSteps(void)
      {
         return totalSteps;
      }
      ///
      /// ������������� ����� ���������� �����.
      ///
      void TotalSteps(int steps)
      {
         if(steps < 0 || steps == totalSteps)return;
         totalSteps = steps;
         RefreshToddler();
      }
      
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         EventRedraw* redraw = new EventRedraw(EVENT_FROM_UP, NameID());
         EventSend(redraw);
         delete redraw;
      }
      ///
      /// ���������� ��������, ����� ������� �������� ���������.
      ///
      //Scrolling* scrolling;
      ///
      /// ��� �������.
      ///
      ENUM_SCROLL_TYPE scrollType;
      ///
      /// ������� ��� �������.
      ///
      int currStep;
      ///
      /// ���������� ������������ �����.
      ///
      int visibleSteps;
      ///
      /// ����� ���������� �����.
      ///
      int totalSteps;
      ///
      /// ������������ ��������.
      ///
      ScrollArea* scrollArea;
};