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

///
/// Определяет тип скролла.
///
enum ENUM_SCROLL_TYPE
{
   ///
   /// Вертикальный скролл.
   ///
   SCROLL_VERTICAL,
   ///
   /// Горизонтальный скролл.
   ///
   SCROLL_HORIZONTAL
};

///
/// Тип кнопки скролла.
///
enum ENUM_SCROLL_BUTTON_TYPE
{
   SCROLL_BUTTON_UP,
   SCROLL_BUTTON_DOWN,
   SCROLL_BUTTON_LEFT,
   SCROLL_BUTTON_RIGHT,
};


class NewScroll2;
///
/// Одна из четырех возможных кнопок скролла. Реализует кнопки по краям скролла.
///
class ButtonScroll : public Button
{
   public:
      ButtonScroll(NewScroll2* nscroll, ENUM_SCROLL_BUTTON_TYPE type) : Button("ButtonScroll", nscroll)
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
      /// Ссылка на скролл.
      ///
      NewScroll2* scroll;
};

class NewScroll2;
///
/// Направляющая ползунка скролла.
///
class ScrollArea : public Label
{
   public:
      ScrollArea(NewScroll2* nscroll) : Label(ELEMENT_TYPE_TODDLER, "Scroll area", nscroll)
      {
         scroll = nscroll;
         toddler = new Label("toddler", GetPointer(this));
         toddler.Text("");
         childNodes.Add(toddler);
      }
      ///
      /// Позиционирует ползунок.
      ///
      void RefreshToddler()
      {
         if(scroll.VisibleSteps() >= scroll.TotalSteps())
         {
            if(toddler.Visible())
            {
               EventVisible* event = new EventVisible(EVENT_FROM_UP, GetPointer(this), false);
               toddler.Event(event);
               delete event;
            }
            return;
         }
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), ParVisible(), GetX(), GetY(), Width()-2, Width()-2);
         toddler.Event(command);
         delete command;
      }
   private:
      ///
      /// Позиционирует расположение направляющей ползунка и сам ползунок.
      ///
      virtual void OnRedraw(EventRedraw* event)
      {
         BorderColor(clrRed);
         Text("");
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
      /// Получает координату по оси X для позиционирования ползунка.
      ///
      long GetX()
      {
         if(scroll.ScrollType() == SCROLL_VERTICAL)
            return 1;
         return 1;
      }
      ///
      /// Получает координату по оси Y для позиционирования ползунка.
      ///
      long GetY()
      {
         if(scroll.ScrollType() == SCROLL_HORIZONTAL ||
            scroll.TotalSteps() <= scroll.VisibleSteps())
            return 1;
         long thigh = High()-toddler.High();
         double piksInStep = (double)thigh/scroll.TotalSteps(); //Пикселей в одном шаге.
         long piksNow = (long)(piksInStep*scroll.CurrentStep());
         return piksNow+1;
      }
      ///
      /// Скролл, которому принадлежит направляющая.
      ///
      NewScroll2* scroll;
      ///
      /// Ползунок скролла.
      ///
      Label* toddler;
};

class Scrolling;
///
/// Скролл.
///
class NewScroll2 : public ProtoNode
{
   public:
      NewScroll2(string myName, ProtoNode* parNode, ENUM_SCROLL_TYPE sType) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         //Тип скролла должен быть известен на этапе его создания
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
      /// Отправляет уведомление об изменении состояния скролла.
      ///
      void SendChangeScrollEvent()
      {
         EventScrollChanged* event = new EventScrollChanged(EVENT_FROM_DOWN, GetPointer(this));
         EventSend(event);
         delete event;
      }
      ///
      /// Привязывает текущий скроллинг к настройки.
      ///
      //void LinkToScrolling(Scrolling* scr){scrolling = scr;}
      ///
      /// Обновляет позиционирования ползунка.
      ///
      void RefreshToddler(void)
      {
         scrollArea.RefreshToddler();
      }
      ///
      /// Возвращает тип скролла.
      ///
      ENUM_SCROLL_TYPE ScrollType(){return scrollType;}
      ///
      /// Возвращает текущий шаг.
      ///
      int CurrentStep(void)
      {
         return currStep;
      }
      ///
      /// Устанавливает текущий шаг из вне.
      ///
      void CurrentStep(int step)
      {
         if(step < 0 || step >= totalSteps)
            return;
         currStep = step;
         RefreshToddler();
      }
      ///
      /// Возвращает количество видимых шагов.
      ///
      int VisibleSteps(void)
      {
         return visibleSteps;
      }
      ///
      /// Устанавливает количество видимых шагов из вне.
      ///
      void VisibleSteps(int vstep)
      {
         visibleSteps = vstep;
         RefreshToddler();
      }
      ///
      /// Возвращает общее количество шагов.
      ///
      int TotalSteps(void)
      {
         return totalSteps;
      }
      ///
      /// Устанавливает общее количество шагов.
      ///
      void TotalSteps(int steps)
      {
         if(steps < 0)return;
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
      /// Надстройка элемента, через которую задается скроллинг.
      ///
      //Scrolling* scrolling;
      ///
      /// Тип скролла.
      ///
      ENUM_SCROLL_TYPE scrollType;
      ///
      /// Текущий шаг скролла.
      ///
      int currStep;
      ///
      /// Количество отображаемых шагов.
      ///
      int visibleSteps;
      ///
      /// Общее количество шагов.
      ///
      int totalSteps;
      ///
      /// Направляющая ползунка.
      ///
      ScrollArea* scrollArea;
};
///
/// Поддержка горизонтального и вертикального скролла.
///
class Scrolling : public CObject
{
   public:
      Scrolling(NewScroll2* nscroll)
      {
         scroll = nscroll;
      }
      ///
      /// Возвращает общее количество шагов.
      ///
      int TotalSteps(void){return totalSteps;}
      ///
      /// Возвращает индекс текущего шага.
      ///
      int CurrentStep(void){return currStep;}
      ///
      /// Устанавливает индекс текущего шага.
      ///
      void CurrentStep(int step)
      {
         if(step >= totalSteps || step < 0 || step == currStep)return;
         currStep = step;
      }
      ///
      /// Устанавливает общее количество шагов.
      ///
      void TotalSteps(int steps){totalSteps = steps;}
   private:
      ///
      /// Текущий шаг.
      ///
      int currStep;
      ///
      /// Общее количество шагов.
      ///
      int totalSteps;
      ///
      /// Скролл, на который ссылается надстройка.
      ///
      NewScroll2* scroll;
};
