
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
         //TableOpenPos* table = new TableOpenPos(GetPointer(this));
         childNodes.Add(new TableOpenPos(GetPointer(this)));
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
         //Включаем заголовок таблицы.
         NodeContainer* nc = new NodeContainer("Container", GetPointer(this));
         childNodes.Add(nc);
         FieldsTables* ft = new FieldsTables("FieldTables", GetPointer(this));
         childNodes.Add(ft);
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
         Move(0,0);
         Resize(80, 20);
         Visible(true);
         EventSend(event);
      }
};

///
/// Перечисление задающее порядок следования колонок
///
enum ENUM_COLUMNS_OPEN_POS
{
   COLUMN_MAGIC,
   COLUMN_ORDER_ID,
   COLUMN_SYMBOL
};

///
/// Класс-контейнер, объединяющий несколько узлов в одну общность.
///
class NodeContainer : public ProtoNode
{
   public:
      NodeContainer(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_CONTAINER, myName, parNode)
      {
         strMagic = "Magic";
         PosMagic = new HeadColumn(strMagic, GetPointer(this));
         
         strOrderId = "Order ID";
         PosOrderId = new HeadColumn(strOrderId, GetPointer(this));
         
         strSymbol = "Symbol";
         PosSymbol = new HeadColumn(strSymbol, GetPointer(this));
         
         strDir = "Dir";
         PosDir = new HeadColumn(strDir, GetPointer(this));
         
         strEntryPrice = "Entry Price";
         PosEntryPrice = new HeadColumn(strEntryPrice, GetPointer(this));
         
         strTakeProfit = "TakeProfit";
         PosTakeProfit = new HeadColumn(strTakeProfit, GetPointer(this));
         
         strStopLoss = "Stop Loss";
         PosStopLoss = new HeadColumn(strStopLoss, GetPointer(this));
         
         strSwap = "Swap";
         PosSwap = new HeadColumn(strSwap, GetPointer(this));
         
         strEntryTime = "Entry Date";
         PosEntryTime = new HeadColumn(strEntryTime, GetPointer(this));
         
         strQuant = "Vol.";
         PosQuantity = new HeadColumn(strQuant, GetPointer(this));
         
         strProfit = "Profit";
         PosProfit = new HeadColumn(strProfit, GetPointer(this));
         
         strComment = "Comment";
         PosComment = new HeadColumn(strComment, GetPointer(this));
         
         strCurrPrice = "Price";
         PosCurrPrice = new HeadColumn(strCurrPrice, GetPointer(this));
         
         childNodes.Add(PosMagic);
         childNodes.Add(PosSymbol);
         childNodes.Add(PosOrderId);
         childNodes.Add(PosEntryTime);
         childNodes.Add(PosDir);
         childNodes.Add(PosQuantity);
         childNodes.Add(PosEntryPrice);
         childNodes.Add(PosStopLoss);
         childNodes.Add(PosTakeProfit);
         childNodes.Add(PosSwap);
         childNodes.Add(PosCurrPrice);
         childNodes.Add(PosProfit);
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
               case EVENT_DEINIT:
                  Deinit(newEvent);
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
      virtual void ChStatusExtern(EventNodeStatus* event)
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
         SetNodePosition();
      }
      
   protected:
      void SetNodePosition()
      {
         long useWidth = 0;
         long kBase = 1250;
         //Коэффициент масштабируемости.
         double kScale = (double)ParWidth()/(double)kBase;
         for(int i=0; i < childNodes.Total();i++)
         {
            HeadColumn* currColumn = childNodes.At(i);
            long cwidth = 20;
            //По имени элемента определяем его размер
            string cname = currColumn.ShortName();
            if(cname == strMagic || cname == strOrderId)
               cwidth = 100;
            if(cname == strSymbol || cname == strEntryPrice ||
               cname == strTakeProfit || cname == strStopLoss ||
               cname == strSwap || cname == strProfit || cname == strCurrPrice)
               cwidth = 70;
            if(cname == strDir || cname == strQuant)
               cwidth = 50;
            if(cname == strSymbol)
               cwidth = 100;
            if(cname == strEntryTime)
               cwidth = 150;
            if(cname == strComment)
               cwidth = 150;
            
            cwidth = (long)MathRound(cwidth * kScale);
            useWidth += cwidth;
            //Последний элемент занимает все оставшееся свободное место, за вычетом 20 пикселей,
            //оставленных на скролл.
            if(i == childNodes.Total()-1)
               cwidth += parentNode.Width()-useWidth - 20;
               
            //Теперь, когда ширина объекта известна, размещаем его в узле
            EventNodeCommand* enc;
            if(i == 0)
               enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, cwidth, parentNode.High());
            else
            {
               HeadColumn* prevColumn = childNodes.At(i-1);
               enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), prevColumn.XLocalDistance() + prevColumn.Width(), 0, cwidth, parentNode.High());
            }
            currColumn.Event(enc);
            delete enc;
         }
      }
   private:
      /// Magic позици.
      HeadColumn* PosMagic;
      /// Название колонки магического номера.
      string strMagic;
      
      /// Идентификатор ордера
      HeadColumn* PosOrderId;
      ///
      string strOrderId;
      
      /// Направление позиции.
      HeadColumn* PosDir;
      ///
      string strDir;
      
      /// Название инструмента, по которому открыта позиция.
      HeadColumn* PosSymbol;
      ///
      string strSymbol;
      
      /// Объем позиции.
      HeadColumn* PosQuantity;
      ///
      string strQuant;
      
      /// Время входа.
      HeadColumn* PosEntryTime;
      ///
      string strEntryTime;
      
      /// Цена входа.
      HeadColumn* PosEntryPrice;
      ///
      string strEntryPrice;
      
      ///
      /// Тейк профит.
      ///
      HeadColumn* PosTakeProfit;
      ///
      string strTakeProfit;
      
      /// Текущая цена позиции.
      HeadColumn* PosCurrPrice;
      ///
      string strCurrPrice;
      
      ///
      /// Стоп лосс.
      ///
      HeadColumn* PosStopLoss;
      ///
      string strStopLoss;
      
      ///
      /// Своп
      ///
      HeadColumn* PosSwap;
      string strSwap;
      
      ///
      /// Текущий профит/лосс позиции.
      ///
      HeadColumn* PosProfit;
      string strProfit;
      
      ///
      /// Комментарий к открытой позиции.
      ///
      HeadColumn* PosComment;
      string strComment;
};

class FieldsTables : public NodeContainer
{
   public:
      FieldsTables(string myName, ProtoNode* parNode):NodeContainer(myName, parNode){;}
      virtual void ChStatusExtern(EventNodeStatus* event)
      {
         Move(1, 21);
         Resize(event.Width()-2, (long)(ParHigh()-21)/2);
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
         //SetNodePosition();
      }
};



///
/// Класс, объединяющий несколько графический узлов в линию.
///
class NodeLine : ProtoNode
{
   public:
      NodeLine(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_CONTAINER, myName, parNode)
      {
         strComment = "Comment";
         strCurrPrice = "Price";
         strMagic = "Magic";
         strOrderId = "Order ID";
         strDir = "Dir";
         strEntryPrice = "Entry Price";
         strEntryTime = "Entry Date";
         strProfit = "Profit";
         strSymbol = "Symbol";
         strQuant = "Vol.";
         strStopLoss = "StopLoss";
         strTakeProfit = "TakeProfit";
         strSwap = "Swap";
      }
   protected:
      ///
      /// Устанавливает местоположение дочерних элементов внутри линии
      ///
      void SetPosition(string nameNode)
      {
         long useWidth = 0;
         long kBase = 1250;
         //Коэффициент масштабируемости.
         double kScale = (double)ParWidth()/(double)kBase;
         for(int i=0; i < childNodes.Total();i++)
         {
            HeadColumn* currColumn = childNodes.At(i);
            long cwidth = 20;
            //По имени элемента определяем его размер
            string cname = currColumn.ShortName();
            if(cname == strMagic || cname == strOrderId)
               cwidth = 100;
            if(cname == strSymbol || cname == strEntryPrice ||
               cname == strTakeProfit || cname == strStopLoss ||
               cname == strSwap || cname == strProfit || cname == strCurrPrice)
               cwidth = 70;
            if(cname == strDir || cname == strQuant)
               cwidth = 50;
            if(cname == strSymbol)
               cwidth = 100;
            if(cname == strEntryTime)
               cwidth = 150;
            if(cname == strComment)
               cwidth = 150;
            
            cwidth = (long)MathRound(cwidth * kScale);
            useWidth += cwidth;
            //Последний элемент занимает все оставшееся свободное место, за вычетом 20 пикселей,
            //оставленных на скролл.
            if(i == childNodes.Total()-1)
               cwidth += parentNode.Width()-useWidth;
               
            //Теперь, когда ширина объекта известна, размещаем его в узле
            EventNodeCommand* enc;
            if(i == 0)
               enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, cwidth, parentNode.High());
            else
            {
               HeadColumn* prevColumn = childNodes.At(i-1);
               enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), prevColumn.XLocalDistance() + prevColumn.Width(), 0, cwidth, parentNode.High());
            }
            currColumn.Event(enc);
            delete enc;
         }
      }
      ///
      /// Добавляет узел в коллекцию.
      ///
      void AddNode(ProtoNode* node)
      {
         childNodes.Add(node);
      }
   private:
      /*
       * Далее идут строковые константы означающие название колонок таблицы.
       * Каждой колонке свойственен свой характерный размер, который может
       * быть рассчитан, зная ее название.
      */
      ///
      /// Magic позици.
      ///
      string strMagic;
      
      ///
      /// Идентификатор ордера.
      ///
      string strOrderId;
      
      ///
      /// Направление позиции.
      ///
      string strDir;
      
      ///
      /// Название инструмента, по которому открыта позиция.
      ///
      string strSymbol;
      
      ///
      /// Объем позиции.
      ///
      string strQuant;
      
      ///
      /// Время входа.
      ///
      string strEntryTime;
      
      ///
      /// Цена входа.
      ///
      string strEntryPrice;
      
      ///
      /// Тейк профит.
      ///
      string strTakeProfit;
      
      ///
      /// Текущая цена позиции.
      ///
      string strCurrPrice;
      
      ///
      /// Стоп лосс.
      ///
      string strStopLoss;
      
      ///
      /// Своп
      ///
      string strSwap;
      
      ///
      /// Текущий профит/лосс позиции.
      ///
      string strProfit;
      
      ///
      /// Комментарий к открытой позиции.
      ///
      string strComment;
};

///
/// Строковый контейнер.
///
class Line : ProtoNode
{
   public:
      Line(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_CONTAINER, myName, parNode){;}
      ///
      /// Добавляет узел в строковый контейнер.
      ///
      void Add(ProtoNode* node)
      {
         
         childNodes.Add(node);
      }
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_NODE_COMMAND:
                  CommandExtern(newEvent);
                  break;
               case EVENT_INIT:
                  MyInit(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               default:
                  EventSend(newEvent);
            }
         }
      }
   private:
      ///
      /// Положение и размер контейнера изменились.
      ///
      void CommandExtern(EventNodeStatus* newEvent)
      {
         Move(newEvent.XDist(), newEvent.YDist());
         Resize(newEvent.Width(), newEvent.High());
         Visible(newEvent.Visible());
         // На этом уровне, события меняем на прямое управление элементами.
         //Все элементы перемещаются на новое место
         int total = childNodes.Total();
         //Положение подузла по горизонтали, относительно текущего узла.
         long xdist = 0;
         ProtoNode* prevColumn = NULL;
         ProtoNode* node = NULL;
         long kBase = 1250;
         //Коэффициент масштабируемости.
         double kScale = (double)Width()/(double)kBase;
         for(int i = 0; i < total; i++)
         {
            node = childNodes.At(i);
            //рассчитываем текущую привязку по горизонтали.
            xdist = i > 0 ? prevColumn.XLocalDistance() + prevColumn.Width() : 0;
            //Последний элемент занимает все оставшееся место
            long cwidth = 0;
            cwidth = i == total-1 ? cwidth = Width() - xdist : (long)MathRound((double)node.OptimalWidth() * kScale);
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist, 0, cwidth, High());
            node.Event(command);
            delete command;
            prevColumn = node;
         }
      }
      virtual void MyInit(EventInit* event)
      {
         //Устанавливаем максимально возможные габариты
         Resize(0, 0, 0, 0);
         Visible(true);
         EventSend(event);
      }
};

///
/// Контейнер, объединяющий несколько строк
///
class LineConteiner : ProtoNode
{
   public:
      LineConteiner(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_CONTAINER, myName, parNode){;}
      
      ///
      /// Добавляет строку графический узлов в контейнер.
      ///
      void Add(Line* lineNode)
      {
         //Рассчитываем текущую дистанцию.
         //long cDist = childNodes
         childNodes.Add(lineNode);
         /*EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, cDist, Width(), highLine);
         lineNode.Event(command);
         delete command;*/
      }
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               // Положение блока линий определяется динамически, на уровне вышестоящего узла,
               // поэтому единвстенное поддерживаемое событие на изменение блока - это комманда сверху.
               case EVENT_NODE_COMMAND:
                  CommandExtern(newEvent);
                  break;
               case EVENT_INIT:
                  MyInit(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               default:
                  EventSend(newEvent);
            }
         }
      }
   private:
      
      void CommandExtern(EventNodeCommand* newEvent)
      {
         long x = newEvent.XDist();
         long y = newEvent.YDist();
         bool vis = newEvent.Visible();
         Move(newEvent.XDist(), newEvent.YDist());
         
         //Высота контейнера строго равна суммарной высоте всех входящих в него линий.
         long chigh = 0;
         long mhigh = 0;
         int total = childNodes.Total();
         //Считаем максимально возможную высоту контейнера
         for(int i = 0; i < total;i++)
         {
            ProtoNode* line = childNodes.At(i);
            mhigh += line.High();
         }
         //Пытаемся установить предельную высоту контейнера
         Resize(newEvent.Width(), mhigh);
         Visible(newEvent.Visible());
         for(int i = 0; i < total;i++)
         {
            ProtoNode* line = childNodes.At(i);
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, chigh, Width(), line.High());
            line.Event(command);
            delete command;
            if(line.Visible())
               chigh += line.High();
         }
         Resize(newEvent.Width(), chigh);
      }
      
      virtual void MyInit(EventInit* event)
      {
         //Устанавливаем максимально возможные габариты
         Resize(0, 0, 0, 0);
         Visible(true);
         EventSend(event);
      }
};

///
/// Класс "Таблица". Внутри таблицы могут находится любые графические элементы, но
/// поведение определено лишь для скрола, линий и контейнеров линий.
/// За конкретное наполнение таблицы колонками отвечает переопределяемая функция MyInit().
///
class Table : public ProtoNode
{
   public:
      Table(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_CONTAINER, myName, parNode)
      {
         backgroundColor = clrDimGray;
      }
      void Add(Line* lineNode)
      {
         childNodes.Add(lineNode);
      }
      void Add(LineConteiner* contNode)
      {
         childNodes.Add(contNode);
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
               case EVENT_INIT:
                  MyInit(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               default:
                  EventSend(newEvent);
            }
         }
      }
   protected:
      virtual void MyInit(){;}
      //Цвет подложки таблицы.
      color backgroundColor;
   private:
      virtual void ChStatusExtern(EventNodeStatus* newEvent)
      {
         Resize(40, 20, 40, 5);
         //По возможности отображаем текущий элемент.
         if(Visible() || Visible(true))
         {
            Visible(true);
            if(Visible(true))
               if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
                  LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR);
         }
         //Теперь, в зависимости от элемента, определяем его положение
         long ydist = 0;
         //ProtoNode* prevNode
         for(int i = 0; i < childNodes.Total(); i++)
         {
            ProtoNode* node = childNodes.At(i);
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, ydist, Width()-20, 20);
            node.Event(command);
            delete command;
            ydist += node.High();
         }
      }
      virtual void MyInit(EventInit* event)
      {
         Resize(40, 20, 40, 5);
         Visible(true);
         EventSend(event);
      }
};

///
/// Таблица открытых позиций.
///
class TableOpenPos : public Table
{
   public:
      TableOpenPos(ProtoNode* parNode):Table("TableOfOpenPos.", parNode)
      {
         // 1. Создадим контейнер, включающий заголовок и фильтр.
         //LineConteiner* contHeader = new LineConteiner("ConteinerHeader", GetPointer(this));
         // 1.1 Линия содержит заголовок таблицы.
         Line* lineHeader = new Line("LineHeader", GetPointer(this));
         
         // 1.1.1 Заполняем заголовок элементами.
         HeadColumn* hmagic = new HeadColumn("Magic", GetPointer(lineHeader));
         hmagic.OptimalWidth(50);
         lineHeader.Add(hmagic);
         Add(lineHeader);
         //contHeader.Add(lineHeader);
         //Add(contHeader);
         // 1.2 Создаем новую линию, включающую строку поиска.
         
         //
         
         //string colNames[] = {"Magic", "Order ID", "Time Enter", "Type", "Vol.", "Price Enter"};
         
      }
   private:
      virtual void MyInit(EventInit* event)
      {
         Resize(40, 20, 40, 5);
         Visible(true);
         EventSend(event);
      }
};