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


class Scroll;
///
/// Одна из четырех возможных кнопок скролла. Реализует кнопки по краям скролла.
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
      /// Ссылка на скролл.
      ///
      Scroll* scroll;
};

class ScrollArea;
///
/// Ползунок скролла.
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
      /// Возвращает координату ползунка.
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
      /// Истина, если ползунок захвачен для перемещения.
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
      /// Обработчик перемещения мыши.
      ///
      void OnMoveMouse(EventMouseMove* event)
      {
         if(ResetTodler(event))return;
         if(SetTodler(event))return;
         MoveTodler(event);
      }
      ///
      /// Сбрасывает режим перемещения ползунка
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
      /// Устанавливает режим перемещения ползунка.
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
      /// Двигает ползунок вдоль направляющей вслед за мышью.
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
      /// Возвращает разницу между старой и новой координатой.
      /// Разница может как положительным так и отрицательным числом.
      ///
      long GetDelta(EventMouseMove* event)
      {
         long delta = 0;
         if(scrollType == SCROLL_VERTICAL)
         {
            delta = event.YCoord() - coord;
            //Верхний предел.
            if(YLocalDistance()+delta < 1)
               delta = (-1) * (YLocalDistance()-1);
            //Нижний предел.
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
      /// Истина, если ползунок находиться в состоянии перемещения.
      ///
      bool isMove;
      ///
      /// последняя известная координата.
      ///
      long coord;
      ///
      /// Направляющая ползунка.
      ///
      ScrollArea* scrollArea;
      ///
      /// Тип скролла.
      ///
      ENUM_SCROLL_TYPE scrollType;
};

class Scroll;
///
/// Направляющая ползунка скролла.
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
      /// Позиционирует ползунок.
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
         //Позиционируем ползунок в случае необходимости.
         if(!toddler.IsMove())
         {
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), ParVisible(), GetX(), GetY(), GetWidth(), GetHigh());
            toddler.Event(command);
            delete command;
         }
      }
      ///
      /// Получает высоту ползунка.
      ///
      long GetHigh()
      {
         if(scroll.ScrollType() == SCROLL_VERTICAL)
            return ParWidth()-4;
         return ParHigh()-4;
      }
      ///
      /// Получает ширину ползунка.
      ///
      long GetWidth()
      {
         if(scroll.ScrollType() == SCROLL_VERTICAL)
            return ParWidth()-4;
         return ParHigh()-4;
      }
      ///
      /// Возвращает указатель на скролл, которому принадлежит направляющая.
      ///
      Scroll* GetScroll(){return scroll;}
      
      ///
      /// Рассчитывает текущий шаг в зависимости от положения ползунка.
      ///
      int CalcCurrentStepByTodler()
      {
         int step = scroll.CurrentStep();
         //В крайнем верхнем положении ползунка отображаем самую верхнюю строку.
         if(toddler.Coordinates() <= 1 || scroll.TotalSteps() == 0)
            step = 0;
         //В крайнем нижнем положении ползунка доводим таблицу до упора.
         else if(toddler.Coordinates() + GetHigh() == High()-1)
            step = scroll.TotalSteps();
         else
         {
            long thigh = High()-GetHigh();
            double piksInStep = (double)thigh/scroll.TotalSteps(); //Пикселей в одном шаге.
            step = (int)(toddler.Coordinates()/piksInStep);
         }
         return step;
      }
      ///
      /// Устанавливает текущий шаг в зависимости от положения ползунка.
      ///
      void SetCurrentStepByTodler()
      {
         int step = CalcCurrentStepByTodler();
         if(scroll.CurrentStep() != step)
            scroll.CurrentStepIntro(step);
         
      }
   private:
      ///
      /// Позиционирует расположение направляющей ползунка и сам ползунок.
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
      /// Получает координату по оси X для позиционирования ползунка.
      ///
      long GetX()
      {
         if(scroll.ScrollType() == SCROLL_VERTICAL)
            return 1;
         //Для горизонтального ползунка алгоритм не реализван. См. аналогию по GetY()
         return 1;
      }
      ///
      /// Получает координату по оси Y для позиционирования ползунка.
      ///
      long GetY()
      {
         if(scroll.ScrollType() == SCROLL_HORIZONTAL ||
            scroll.TotalSteps() == 0)
            return 1;
         //Обратная связь (не работает).
         //int step = CalcCurrentStepByTodler();
         //if(step == scroll.CurrentStep())
         //   return toddler.Coordinates();
         long tod_high = toddler.High();
         long thigh = High()-toddler.High();
         double piksInStep = (double)thigh/scroll.TotalSteps(); //Пикселей в одном шаге.
         long piksNow = (long)(piksInStep*scroll.CurrentStep());
         //Корректировка границ.
         if(piksNow + GetHigh() >= High())
            piksNow = High() - GetHigh() - 1;
         if(piksNow <= 0)piksNow = 1;
         return piksNow;
      }
      
      ///
      /// Скролл, которому принадлежит направляющая.
      ///
      Scroll* scroll;
      ///
      /// Ползунок скролла.
      ///
      Todler* toddler;
};

class Scrolling;
///
/// Скролл.
///
class Scroll : public ProtoNode
{
   public:
      Scroll(string myName, ProtoNode* parNode, ENUM_SCROLL_TYPE sType) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
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
         if(step < 0 || step > totalSteps || step == currStep)
            return;
         currStep = step;
         RefreshToddler();
      }
      ///
      /// Устанавливает текущий шаг из нутри.
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