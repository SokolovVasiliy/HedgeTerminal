
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
/// Класс "Кнопка".
///
class Button : public ProtoNode
{
   public:
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               //case EVENT_INIT:
               //   Init(newEvent);
               //   break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               case EVENT_NODE_COMMAND:
                  RunCommand(newEvent);
                  break;
               //События которые не можем обработать отправляем дальше вниз.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      Button(string myName, ProtoNode* parNode):ProtoNode(OBJ_BUTTON, ELEMENT_TYPE_HEAD_COLUMN, myName, parNode)
      {
         borderColor = clrBlack;
         label = myName;
         font = "Arial";
         fontsize = 10;
      }
      void BorderColor(color clr)
      {
         borderColor = clr;
      }
      color BorderColor()
      {
         return borderColor;
      }
      ///
      /// Возвращает надпись кнопки.
      ///
      string Label(){return label;}
      ///
      /// Устанавливает надпись кнопки.
      ///
      void Label(string text){label = text;}
      ///
      /// Возвращает имя используемого шрифта.
      ///
      string Font(){return font;}
      ///
      /// Устанавливает имя используемого шрифта.
      ///
      void Font(string myFont){font = myFont;}
      ///
      /// Возвращает размер используемого шрифта.
      ///
      int FontSize(){return fontsize;}
      ///
      /// Устанавливает размер используемого шрифта.
      ///
      void FontSize(int size){fontsize = size;}
   private:
      ///
      /// Выполняет комманду.
      ///
      void RunCommand(EventNodeCommand* event)
      {
         ExecuteCommand(event);
         if(Visible())
         {
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, label);
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BORDER_COLOR, clrNONE);
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BORDER_COLOR, borderColor);
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_FONT, font);
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_FONTSIZE, fontsize);
         }
      }
      
      
      ///
      /// Обработчик события статус 'видимости внешнего узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         Visible(vis);
         EventVisible* ev = new EventVisible(EVENT_FROM_UP, NameID(), Visible());
         EventSend(ev);
         delete ev;
      }
      ///
      /// Цвет рамки кнопки
      ///
      color borderColor;
      ///
      ///  Надпись кнопки.
      ///
      string label;
      ///
      /// Имя шрифта.
      ///
      string font;
      ///
      /// Размер шрифта.
      ///
      int fontsize;
};

///
/// Текстовая метка
///
class Label : ProtoNode
{
   public:
      Label(string myName, ProtoNode* node) : ProtoNode(OBJ_EDIT, ELEMENT_TYPE_LABEL, myName, node){;}
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               case EVENT_NODE_COMMAND:
                  RunCommand(newEvent);
               //События которые не можем обработать отправляем дальше вниз.
               default:
                  EventSend(newEvent);
            }
         }
      }
   private:
      ///
      /// Выполняет комманду.
      ///
      void RunCommand(EventNodeCommand* event)
      {
         ExecuteCommand(event);
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
};
   

///
/// Ячейка таблицы.
///
class Cell : public ProtoNode
{
   public:
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
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
      Cell(string myName, ProtoNode* parNode):ProtoNode(OBJ_LABEL, ELEMENT_TYPE_HEAD_COLUMN, myName, parNode)
      {
         ;
      }
   private:
      ///
      /// Выполняет комманду.
      ///
      void RunCommand(EventNodeCommand* event)
      {
         Move(event.XDist(), event.YDist());
         Resize(event.Width(), event.High());
         Visible(true);
         if(Visible())
         {
            //ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, ShortName());
         }
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
      
};
///
/// Идентификатор указывающий на алгоритм выравнивания элементов в горизонтальном или вертикальном контейнере.
///
enum ENUM_LINE_ALIGN_TYPE
{
   ///
   /// Масштабирование на основе рекомендованной ширины/высоты элемента.
   ///
   LINE_ALIGN_SCALE,
   ///
   /// Масштабирование обычной ячейки.
   ///
   LINE_ALIGN_CELL,
   ///
   /// Мастшабирование ячейки таблицы содержащую кнопки.
   ///
   LINE_ALIGN_CELLBUTTON,
   ///
   /// Равномерное распределение общей ширины/высоты контейнера между всеми элементами.
   ///
   LINE_ALIGN_EVENNESS
};
///
/// Строковый контейнер.
///
class Line : ProtoNode
{
   public:
      Line(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_GCONTAINER, myName, parNode)
      {
         typeAlign = LINE_ALIGN_SCALE;
      }
      ///
      /// Устанавливает алгоритм выравнивания для элементов внутри линии.
      ///
      void AlignType(ENUM_LINE_ALIGN_TYPE align)
      {
         typeAlign = align;
      }
      ///
      /// Возвращает идентификатор алгоритма выравнивания элементов внутри линии.
      ///
      ENUM_LINE_ALIGN_TYPE AlignType()
      {
         return typeAlign;
      }
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
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               default:
                  EventSend(newEvent);
            }
         }
      }
      ///
      /// Устанавливает высоту текущей линии.
      ///
      void HighLine(long curHigh)
      {
         Resize(Width(), curHigh);
         //EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
      }
      ///
      /// Устанавливает ширину текущей линии.
      ///
      void WidthLine(long curWidth)
      {
         Resize(curWidth, High());
         //EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         //EventSend(er);
         //delete er;
      }
      ///
      /// Передвигает линию на новые координаты.
      ///
      void MoveLine(long xdist, long ydist, ENUM_COOR_CONTEXT context = COOR_LOCAL)
      {
         Move(xdist, ydist, context);
         
      }
      ///
      /// Устанавливает видимость линии.
      ///
      void VisibleLine(bool isVisible)
      {
         Visible(isVisible);
      }
   private:
      ///
      /// Положение и размер контейнера изменились.
      ///
      void CommandExtern(EventNodeCommand* newEvent)
      {
         ExecuteCommand(newEvent);
         switch(typeAlign)
         {
            case LINE_ALIGN_CELL:
            case LINE_ALIGN_CELLBUTTON:
               AlgoCellButton();
            default:
               AlgoScale();
               break;
         }
      }
      ///
      /// Алгоритм масштабирования на основе рекомендованной ширины/высоты элемента.
      ///
      void AlgoScale()
      {
         //Положение подузла по горизонтали, относительно текущего узла.
         int total = childNodes.Total();
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
      ///
      /// Алгоритм позиционирования элементов "ячейка с кнопками"
      ///
      void AlgoCellButton()
      {
         //В этом режиме подразумевается, что содержимое состоит из узлов, часть из которых - квадратные кнопки.
         int total = childNodes.Total()-1;
         long xdist = Width();
         long chigh = High();
         //Перебираем элементы в обратном порядке, т.к. кнопки идут самыми последними
         for(int i = total; i <= 0; i--)
         {
            ProtoNode* node = childNodes.At(i);
            if(node.TypeElement() == ELEMENT_TYPE_BOTTON)
            {
               xdist -= chigh;
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist+2, 2, chigh-2, chigh-2);
               node.Event(command);
               delete command;
            }
            else
            {
               //Средняя ширина элемента
               long avrg = (long)MathRound((double)xdist/(double)(total+1));
               xdist -= avrg;
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist, 0, avrg, chigh);
               node.Event(command);
               delete command;
            }
         }
      }
      ///
      /// Идентификатор алгоритма выравнивания в линии.
      ///
      ENUM_LINE_ALIGN_TYPE typeAlign;
};
///
/// Прокрутка списка.
///
class Scroll : ProtoNode
{
   public:
      Scroll(string myName, ProtoNode* parNode) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         //у скрола есть две кнопки и ползунок.
         up = new Button("UpClick", GetPointer(this));
         up.BorderColor(clrNONE);
         up.Font("Wingdings");
         up.Label(CharToString(241));
         childNodes.Add(up);
         
         dn = new Button("DnClick", GetPointer(this));
         dn.BorderColor(clrNONE);
         dn.Font("Wingdings");
         dn.Label(CharToString(242));
         childNodes.Add(dn);
         
         toddler = new Button("Todler", GetPointer(this));
         childNodes.Add(toddler);
         
      }
      void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_CHSTATUS:
                  ChStatusExtern(newEvent);
                  break;
               //case EVENT_INIT:
                  //MyInit(newEvent);
                  //break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               default:
                  EventSend(newEvent);
            }
         }
      }
   private:
      void ChStatusExtern(EventNodeStatus* event)
      {
         int dbg = 4;
         if(!event.Visible())
            dbg = 3;
         long w = event.Width();
         long h = event.High(); 
         bool v = event.Visible();
         Move(event.Width() - 20, 0);
         Resize(20, event.High());
         Visible(event.Visible());
         //Позиционируем верхнюю кнопку.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 2, 16, 16);
         up.Event(command);
         delete command;
         
         //Позиционируем нижнюю кнопку.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, High()-16, 16, 16);
         dn.Event(command);
         delete command;
      }
      
      //у скрола есть две кнопки и ползунок.
      Button* up;
      Button* dn;
      Button* toddler;
};

///
/// Класс "Таблица". Внутри таблицы могут находится любые графические элементы, но
/// поведение определено лишь для скрола, линий и контейнеров линий.
/// За конкретное наполнение таблицы колонками отвечает переопределяемая функция MyInit().
///
class Table : public ProtoNode
{
   public:
      Table(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_UCONTAINER, myName, parNode)
      {
         backgroundColor = clrDimGray;
      }
      void Add(ProtoNode* lineNode)
      {
         childNodes.Add(lineNode);
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
         if(Visible(true))
         {
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
               LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR);
            ObjectCreate(0, "edittext", OBJ_EDIT, 0, 30, 30);
            ObjectSetInteger(0, "edittext", OBJPROP_XDISTANCE, 40);
            ObjectSetInteger(0, "edittext", OBJPROP_YDISTANCE, 80);
            ObjectSetInteger(0, "edittext", OBJPROP_BGCOLOR, clrNONE);
            ObjectSetInteger(0, "edittext", OBJPROP_BORDER_COLOR, clrNONE);
            //ObjectSetInteger(0, "edittext", OBJPROP_WIDTH, 3);
            ObjectSetString(0, "edittext", OBJPROP_TEXT, "edit text");
         }
         //Теперь, в зависимости от элемента, определяем его положение
         long ydist = 0;
         //ProtoNode* prevNode
         for(int i = 0; i < childNodes.Total(); i++)
         {
            
            ProtoNode* node = childNodes.At(i);
            if(node.TypeElement() == ELEMENT_TYPE_GCONTAINER)
            {
             EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, ydist, Width()-20, 20);
             node.Event(command);
             delete command;
             ydist += node.High();
            }
            //
            if(node.TypeElement() == ELEMENT_TYPE_SCROLL)
            {
               bool v = Visible();
               EventNodeStatus* ch = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(), XAbsDistance(), YAbsDistance(), Width(), High());
               node.Event(ch);
               delete ch;
            }
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
         // Первая линия содержит заголовок таблицы.
         Line* lineHeader = new Line("LineHeader", GetPointer(this));
         
         // Магический номер
         Button* hmagic = new Button("Magic", GetPointer(lineHeader));
         hmagic.OptimalWidth(50);
         lineHeader.Add(hmagic);
         
         // Символ
         Button* hSymbol = new Button("Symbol", GetPointer(lineHeader));
         hmagic.OptimalWidth(70);
         lineHeader.Add(hSymbol);
         
         // Order ID
         Button* hOrderId = new Button("Order ID", GetPointer(lineHeader));
         hOrderId.OptimalWidth(70);
         lineHeader.Add(hOrderId);
         
         // Время входа в позицию.
         Button* hEntryDate = new Button("Entry Date", GetPointer(lineHeader));
         hEntryDate.OptimalWidth(150);
         lineHeader.Add(hEntryDate);
         
         
         // Направление позиции.
         Button* hTypePos = new Button("Type", GetPointer(lineHeader));
         hTypePos.OptimalWidth(50);
         lineHeader.Add(hTypePos);
         
         // Объем
         Button* hVolume = new Button("Vol.", GetPointer(lineHeader));
         hVolume.OptimalWidth(50);
         lineHeader.Add(hVolume);
         
         // Цена входа.
         Button* hEntryPrice = new Button("Price", GetPointer(lineHeader));
         hEntryPrice.OptimalWidth(70);
         lineHeader.Add(hEntryPrice);
         
         // Стоп-лосс
         Button* hStopLoss = new Button("S/L", GetPointer(lineHeader));
         hStopLoss.OptimalWidth(70);
         lineHeader.Add(hStopLoss);
         
         // Тейк-профит
         Button* hTakeProfit = new Button("T/P", GetPointer(lineHeader));
         hTakeProfit.OptimalWidth(70);
         lineHeader.Add(hTakeProfit);
         
         // Текущая цена
         Button* hCurrentPrice = new Button("Price", GetPointer(lineHeader));
         hCurrentPrice.OptimalWidth(70);
         lineHeader.Add(hCurrentPrice);
         
         // Профит
         Button* hProfit = new Button("Profit", GetPointer(lineHeader));
         hProfit.OptimalWidth(70);
         lineHeader.Add(hProfit);
         
         // Комментарий
         Button* hComment = new Button("Comment", GetPointer(lineHeader));
         hComment.OptimalWidth(150);
         lineHeader.Add(hComment);
         
         //Скрол
         Scroll* myscroll = new Scroll("Scroll", GetPointer(this));
         Add(myscroll);
         
         Add(lineHeader);
      }
   private:
      virtual void MyInit(EventInit* event)
      {
         Resize(40, 20, 40, 5);
         Visible(true);
         EventSend(event);
      }
};