
#include "gnode.mqh"

///
/// Основная форма панели.
///
class MainForm : public ProtoNode
{
   public:
      ///
      /// Определяем реакцию на поступающие события.
      ///
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
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
               case EVENT_INIT:
                  Init(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               case EVENT_CHBORDER:
                  ChBorder(newEvent);
                  break;
               //События которые не можем обработать отправляем дальше вниз.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      MainForm():ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_FORM, "HedgePanel", NULL)
      {
         ;
      }
   private:
      ///
      /// Обработчик события 'видимость внешнего узла изменена'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void ResizeExtern(EventResize* event)
      {
         //Ширина формы не может быть меньше 100 пикселей.
         long cwidth = CheckWidth(event.NewWidth());
         //Высота формы не может быть меньше 50 пикселей.
         long chigh = CheckHigh(event.NewHigh());
         Resize(cwidth, chigh);
         EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         EventSend(er);
         delete er;
      }
      void ChBorder(EventChangeBorder* event)
      {
         //Ширина формы не может быть меньше 100 пикселей.
         long cwidth = CheckWidth(event.Width());
         //Высота формы не может быть меньше 50 пикселей.
         long chigh = CheckHigh(event.High());
         Resize(0, 0, 0, 0);
         EventChangeBorder* er = new EventChangeBorder(EVENT_FROM_UP, NameID(), XAbsDistance(), YAbsDistance(), Width(), High());
         EventSend(er);
         delete er;
      }
      ///
      /// Проверяет возможно ли установить требуемую ширину. Если требуемая ширина возможна - возвращает ее,
      /// если нет, возвращает ближайшую возможную.
      /// \return Ширина узла.
      ///
      long CheckWidth(long cwidth)
      {
         if(cwidth < 100)
            return 100;
         return cwidth;
      }
      ///
      /// Проверяет возможно ли установить требуемую высоту. Если требуемая высота возможна - возвращает ее,
      /// если нет, возвращает ближайшую возможную.
      /// \return Высота узла.
      ///
      long CheckHigh(long chigh)
      {
         if(chigh < 70)
            return 70;
         return chigh;
      }
      ///
      /// Обработчик события статус 'видимости внешнего узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         Visible(event.Visible());
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
      ///
      /// Позиционирует и отображает элемент главной формы.
      ///
      void Init(EventInit* event)
      {
         long X;     // Текущая ширина окна индикатора
         long Y;     // Текущая высота окна индикатора
         X = CheckWidth(ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW));
         Y = CheckHigh(ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW));
         Resize(X, Y);
         Visible(true);
         //Создаем таблицу открытых позиций
         TableOfOpenPos* tOpenPos = new TableOfOpenPos("TableOfOpenPos", GetPointer(this));
         childNodes.Add(tOpenPos);
         EventSend(event);
      }
};

///
/// Таблица открытых позиций.
///
class TableOfOpenPos : ProtoNode
{
   public:
      ///
      /// Определяем реакцию на поступающие события.
      ///
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
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
               case EVENT_INIT:
                  Init(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               case EVENT_CHBORDER:
                  ChBorder(newEvent);
                  break;
               //События которые не можем обработать отправляем дальше вниз.
               default:
                  EventSend(newEvent);
            }
         }
      }
      TableOfOpenPos(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_TABLE, myName, parNode)
      {
         ;
      }
   private:
      ///
      /// Обработчик события 'размер родительского узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void ResizeExtern(EventResize* event)
      {
         Resize(40, 20, 40, 5);
         //По возможности отображаем текущий элемент.
         if(ParVisible() && !Visible())
         {
            Visible(true);
            if(Visible(true))
               if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
                  LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR);
         }
         EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         EventSend(er);
         delete er;
      }
      void ChBorder(EventChangeBorder* event)
      {
         Resize(40, 20, 40, 5);
         EventChangeBorder* cb = new EventChangeBorder(EVENT_FROM_UP, NameID(),
                                    XAbsDistance(), YAbsDistance(), Width(), High());
         EventSend(cb);
         delete cb;
      }
      ///
      /// Обработчик события статус 'видимости внешнего узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         if(Visible(vis) && vis)
         {
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
               LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR); 
         }
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
      ///
      /// Цвет подложки таблицы открытых позиций. 
      ///
      color backgroundColor;
      void Init(EventInit* event)
      {
         backgroundColor = clrDimGray;
         Resize(40, 0, 40, 0);
         if(Visible(true))
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
               LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR);
         HeadColumn* HeadMagic = new HeadColumn("HeadMagic", GetPointer(this));
         childNodes.Add(HeadMagic);
         EventSend(event);
      }
};

class HeadColumn : ProtoNode
{
   public:
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
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
               case EVENT_INIT:
                  Init(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               //События которые не можем обработать отправляем дальше вниз.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      HeadColumn(string myName, ProtoNode* parNode):ProtoNode(OBJ_BUTTON, ELEMENT_TYPE_HEAD_COLUMN, myName, parNode)
      {
         ;
      }
   private:
      ///
      /// Обработчик события 'размер родительского узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void ResizeExtern(EventResize* event)
      {
         Move(5, 20);
         Resize(100, 20);
         //По возможности отображаем текущий элемент.
         if(ParVisible())
            Visible(true);
         EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         EventSend(er);
         delete er;
      }
      
      void ChBorder(EventChangeBorder* event)
      {
         Move(5, 20);
         Resize(100, 20);
         EventChangeBorder* cb = new EventChangeBorder(EVENT_FROM_UP, NameID(),
                                    XAbsDistance(), YAbsDistance(), Width(), High());
         EventSend(cb);
         delete cb;
      }
      ///
      /// Обработчик события статус 'видимости внешнего узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         Visible(vis);
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
      ///
      ///
      ///
      void Init(EventInit* event)
      {
         Move(5,5);
         Resize(100, 20);
         Visible(true);
         EventSend(event);
      }
};