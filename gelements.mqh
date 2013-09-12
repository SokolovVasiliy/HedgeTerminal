
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
               case EVENT_CHSTATUS:
                  ChStatus(newEvent);
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
      void ChStatus(EventNodeStatus* event)
      {
         //Ширина формы не может быть меньше 100 пикселей.
         long cwidth = CheckWidth(event.Width());
         //Высота формы не может быть меньше 50 пикселей.
         long chigh = CheckHigh(event.High());
         Resize(cwidth, chigh);
         if(!Visible())
            Visible(true);
         EventNodeStatus* er = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(), XAbsDistance(), YAbsDistance(), Width(), High());
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
               case EVENT_CHSTATUS:
                  ChStatus(newEvent);
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
      void ChStatus(EventNodeStatus* event)
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
         EventNodeStatus* cb = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(),
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
         //HeadColumn* HeadMagic = new HeadColumn("HeadMagic", GetPointer(this));
         //childNodes.Add(HeadMagic);
         NodeContainer* nc = new NodeContainer("Container", GetPointer(this));
         childNodes.Add(nc);
         EventSend(event);
      }
};

class HeadColumn : public ProtoNode
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
               case EVENT_CHSTATUS:
                  ChStatus(newEvent);
                  break;
               case EVENT_NODE_COMMAND:
                  RunCommand(newEvent);
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
      /// Выполняет комманду.
      ///
      void RunCommand(EventNodeCommand* event)
      {
         /*if(!event.Visible())
         {
            Visible(false);
            return;
         }*/
         Move(event.XDist(), event.YDist());
         Resize(event.Width(), event.High());
         Visible(true);
         if(Visible())
         {
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, ShortName());
         }
      }
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
      
      void ChStatus(EventNodeStatus* event)
      {
         Move(5, 20);
         Resize(100, 20);
         //По возможности отображаем текущий элемент.
         if(ParVisible())
            Visible(true);
         EventNodeStatus* cb = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(),
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

///
/// Класс-контейнер, объединяющий несколько узлов в одну общность.
///
class NodeContainer : public ProtoNode
{
   public:
      NodeContainer(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_CONTAINER, myName, parNode)
      {
         PosMagic = new HeadColumn("Magic", GetPointer(this));
         PosOrderId = new HeadColumn("Order ID", GetPointer(this));
         PosSymbol = new HeadColumn("Symbol", GetPointer(this));
         PosDir = new HeadColumn("Dir", GetPointer(this));
         PosEntryPrice = new HeadColumn("Entry Price", GetPointer(this));
         PosTakeProfit = new HeadColumn("Take Profit", GetPointer(this));
         PosStopLoss = new HeadColumn("Stop Loss", GetPointer(this));
         PosSwap = new HeadColumn("Swap", GetPointer(this));
         PosEntryTime = new HeadColumn("Entry Date", GetPointer(this));
         PosQuantity = new HeadColumn("Vol.", GetPointer(this));
         PosComment = new HeadColumn("Entry Comment", GetPointer(this));
         childNodes.Add(PosMagic);
         childNodes.Add(PosOrderId);
         childNodes.Add(PosSymbol);
         childNodes.Add(PosDir);
         childNodes.Add(PosEntryPrice);
         childNodes.Add(PosEntryTime);
         childNodes.Add(PosQuantity);
         childNodes.Add(PosComment);
      }
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_CHSTATUS:
                  ChStatusExtern(newEvent);
                  break;
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      ///
      /// Обработчик события 'размер родительского узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void ChStatusExtern(EventNodeStatus* event)
      {
         Move(1, 1);
         Resize(event.Width()-2, 20);
         if(ParVisible())
         {
            Visible(true);
         }
         if(Visible())
         {
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BORDER_TYPE, BORDER_FLAT);
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_WIDTH, 1);
         }
         HeadColumn* currNode = PosMagic;
         EventNodeCommand* enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, 100, 20);
         currNode.Event(enc);
         delete enc;
         
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), currNode.XLocalDistance()+currNode.Width(), 0, 100, 20);
         currNode = PosOrderId;
         currNode.Event(enc);
         delete enc;
         
         //Дочерним элментам посылаем особую комманду-дерективу
         //Рассчитываем положение и размер колонки PosMagic
         /*EventNodeCommand* enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, 100, 20);
         PosMagic.Event(enc);
         delete enc;
         
         //Рассчитываем положение и размер колонки OrderID
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 100, 0, 100, 20);
         PosOrderId.Event(enc);
         delete enc;*/
         
         //Рассчитываем положение и размер колонки Symbol
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 200, 0, 70, 20);
         PosSymbol.Event(enc);
         delete enc;
         
         //Рассчитываем положение колонки Direction
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 270, 0, 50, 20);
         PosDir.Event(enc);
         delete enc;
         
         //Рассчитываем положение колонки EntryPrice
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 320, 0, 70, 20);
         PosEntryPrice.Event(enc);
         delete enc;
         
         //Рассчитываем положение колонки EntryPrice
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 390, 0, 70, 20);
         PosTakeProfit.Event(enc);
         delete enc;
         
         //Рассчитываем положение колонки EntryPrice
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 460, 0, 70, 20);
         PosStopLoss.Event(enc);
         delete enc;
         
         //Рассчитываем положение колонки EntryPrice
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 530, 0, 70, 20);
         PosSwap.Event(enc);
         delete enc;
         
         //Рассчитываем положение колонки Date
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 600, 0, 150, 20);
         PosEntryTime.Event(enc);
         delete enc;
         
         //Рассчитываем положение колонки Comment
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 750, 0, 250, 20);
         PosComment.Event(enc);
         delete enc;
      }
   private:
      ///
      /// Magic позици.
      ///
      HeadColumn* PosMagic;
      ///
      /// Идентификатор ордера
      ///
      HeadColumn* PosOrderId;
      ///
      /// Направление позиции.
      ///
      HeadColumn* PosDir;
      ///
      /// Название инструмента, по которому открыта позиция.
      ///
      HeadColumn* PosSymbol;
      ///
      /// Объем позиции.
      ///
      HeadColumn* PosQuantity;
      ///
      /// Время входа.
      ///
      HeadColumn* PosEntryTime;
      ///
      /// Цена входа.
      ///
      HeadColumn* PosEntryPrice;
      ///
      /// Тейк профит.
      ///
      HeadColumn* PosTakeProfit;
      ///
      /// Стоп лосс.
      ///
      HeadColumn* PosStopLoss;
      ///
      /// Своп
      ///
      HeadColumn* PosSwap;
      ///
      /// Комментарий к открытой позиции.
      ///
      HeadColumn* PosComment;
};