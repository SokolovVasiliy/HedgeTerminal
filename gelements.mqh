
#include "gnode.mqh"


///
/// Горизонтальный вектор.
///
class Line : public ProtoNode
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
      virtual void OnCommand(EventNodeCommand* newEvent)
      {
         if(!Visible() || newEvent.Direction() == EVENT_FROM_DOWN)return;
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
/// Текстовая метка
///
class Label : public ProtoNode
{
   public:
      Label(string myName, ProtoNode* node) : ProtoNode(OBJ_EDIT, ELEMENT_TYPE_LABEL, myName, node){;}
      void Edit(bool edit)
      {
         isEdit = edit;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_READONLY, isEdit);
      }
      ///
      /// Возвращает режим редактирования текстовой метки.
      ///
      bool Edit(){return isEdit;}
      ///
      /// Устанавливает текст, который будет отображаться в текстовой метке.
      ///
      void Text(string myText)
      {
         text = myText;
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, text);
      }
      ///
      /// Возвращает текст метки.
      ///
      string Text(){return text;}
   private:
      virtual void OnVisible(EventVisible* event)
      {
         if(!event.Visible())return;
         BackgroundColor(BackgroundColor());
         BorderColor(BorderColor());
         Text(Text());
         Edit(Edit());
      }
      ///
      /// Истина, если текстовая метка может редактироваться пользователем, ложь, в противном случае.
      ///
      bool isEdit;
      ///
      /// Текущий текст, который отображается в текстовой метке.
      ///
      string text;
      
};


///
/// Идентификатор указывающий на алгоритм выравнивания элементов в горизонтальном или вертикальном контейнере.
///
/*enum ENUM_LINE_ALIGN_TYPE
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
};*/

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
   protected:
      virtual void MyInit(){;}
      //Цвет подложки таблицы.
      color backgroundColor;
   private:
      virtual void OnVisible(EventVisible* event)
      {
         // Устанавливаем дополнительные свойства
         if(event.Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor);
      }
      virtual void OnCommand(EventNodeCommand* event)
      {
         //Команды снизу не принимаются.
         if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
         //Теперь, в зависимости от элемента, определяем его положение
         long ydist = 2;
         //ProtoNode* prevNode
         int total = childNodes.Total();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = childNodes.At(i);
            if(node.TypeElement() == ELEMENT_TYPE_GCONTAINER)
            {
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, ydist, Width()-20, 20);
               node.Event(command);
               delete command;
               ydist += node.High();
            }
            //
            if(node.TypeElement() == ELEMENT_TYPE_SCROLL)
            {
               bool v = Visible();
               //EventNodeStatus* ch = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(), XAbsDistance(), YAbsDistance(), Width(), High());
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(),Width()-20,0,20, High());
               node.Event(command);
               delete command;
            }
         } 
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
         ow_magic = 100;
         ow_symbol = 70;
         ow_order_id = 70;
         ow_entry_date = 150;
         ow_type = 50;
         ow_vol = 50;
         ow_price = 70;
         ow_sl = 70;
         ow_tp = 70;
         ow_currprice = 70;
         ow_profit = 70;
         ow_comment = 150;
         
         // Первая линия содержит заголовок таблицы.
         lineHeader = new Line("LineHeader", GetPointer(this));
         
         // Магический номер
         Button* hmagic = new Button("Magic", GetPointer(lineHeader));
         hmagic.OptimalWidth(ow_magic);
         lineHeader.Add(hmagic);
         
         // Символ
         Button* hSymbol = new Button("Symbol", GetPointer(lineHeader));
         hmagic.OptimalWidth(ow_symbol);
         lineHeader.Add(hSymbol);
         
         // Order ID
         Button* hOrderId = new Button("Order ID", GetPointer(lineHeader));
         hOrderId.OptimalWidth(ow_order_id);
         lineHeader.Add(hOrderId);
         
         // Время входа в позицию.
         Button* hEntryDate = new Button("Entry Date", GetPointer(lineHeader));
         hEntryDate.OptimalWidth(ow_entry_date);
         lineHeader.Add(hEntryDate);
         
         
         // Направление позиции.
         Button* hTypePos = new Button("Type", GetPointer(lineHeader));
         hTypePos.OptimalWidth(ow_type);
         lineHeader.Add(hTypePos);
         
         // Объем
         Button* hVolume = new Button("Vol.", GetPointer(lineHeader));
         hVolume.OptimalWidth(ow_vol);
         lineHeader.Add(hVolume);
         
         // Цена входа.
         Button* hEntryPrice = new Button("Price", GetPointer(lineHeader));
         hEntryPrice.OptimalWidth(ow_price);
         lineHeader.Add(hEntryPrice);
         
         // Стоп-лосс
         Button* hStopLoss = new Button("S/L", GetPointer(lineHeader));
         hStopLoss.OptimalWidth(ow_sl);
         lineHeader.Add(hStopLoss);
         
         // Тейк-профит
         Button* hTakeProfit = new Button("T/P", GetPointer(lineHeader));
         hTakeProfit.OptimalWidth(ow_tp);
         lineHeader.Add(hTakeProfit);
         
         // Текущая цена
         Button* hCurrentPrice = new Button("Price", GetPointer(lineHeader));
         hCurrentPrice.OptimalWidth(ow_currprice);
         lineHeader.Add(hCurrentPrice);
         
         // Профит
         Button* hProfit = new Button("Profit", GetPointer(lineHeader));
         hProfit.OptimalWidth(ow_profit);
         lineHeader.Add(hProfit);
         
         // Комментарий
         Button* hComment = new Button("Comment", GetPointer(lineHeader));
         hComment.OptimalWidth(ow_comment);
         lineHeader.Add(hComment);
         
         //Скрол
         Scroll* myscroll = new Scroll("Scroll", GetPointer(this));
         Add(myscroll);
         
         Add(lineHeader);
      }
      
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_CREATE_NEWPOS:
               AddPosition(event);
               break;
         }
      }
      ///
      /// Добавляет новую позицию в таблицу.
      ///
      void AddPosition(EventCreateNewPos* event)
      {
         Position* pos = event.GetPosition();
         Line* nline = new Line("pos.", GetPointer(this));
         //Магик
         Label* magic = new Label("magic", GetPointer(nline));
         magic.OptimalWidth(ow_magic);
         magic.BackgroundColor(clrWhite);
         magic.BorderColor(clrWhiteSmoke);
         magic.Text((string)pos.Magic());
         nline.Add(magic);
         
         //Символ
         Label* symbol = new Label("symbol", GetPointer(nline));
         symbol.OptimalWidth(ow_magic);
         symbol.BackgroundColor(clrWhite);
         symbol.BorderColor(clrWhiteSmoke);
         symbol.Text((string)pos.Symbol());
         nline.Add(symbol);
         
         //OrderID
         Label* orderId = new Label("OrderID", GetPointer(nline));
         orderId.OptimalWidth(ow_magic);
         orderId.BackgroundColor(clrWhite);
         orderId.BorderColor(clrWhiteSmoke);
         orderId.Text((string)pos.OrderID());
         nline.Add(orderId);
         
         //EntryDate
         Label* entryDate = new Label("EntryDate", GetPointer(nline));
         entryDate.OptimalWidth(ow_entry_date);
         entryDate.BackgroundColor(clrWhite);
         entryDate.BorderColor(clrWhiteSmoke);
         entryDate.Text((string)pos.EntryDate());
         nline.Add(entryDate);
         
         //EntryDate
         Label* type = new Label("Type", GetPointer(nline));
         type.OptimalWidth(ow_type);
         type.BackgroundColor(clrWhite);
         type.BorderColor(clrWhiteSmoke);
         if(pos.Type() == POSITION_TYPE_BUY)
            type.Text("BUY");
         else
            type.Text("SELL");
         nline.Add(type);
         
         //Comment
         Label* comment = new Label("comment", GetPointer(nline));
         comment.OptimalWidth(ow_comment);
         comment.BackgroundColor(clrWhite);
         comment.BorderColor(clrWhiteSmoke);
         comment.Text(pos.EntryComment());
         nline.Add(comment);
         
         //Добавляем строку
         Add(nline);
         
      }
   private:
      Line* lineHeader;
      long ow_magic;
      long ow_symbol;
      long ow_order_id;
      long ow_entry_date;
      long ow_type;
      long ow_vol;
      long ow_price;
      long ow_sl;
      long ow_tp;
      long ow_currprice;
      long ow_profit;
      long ow_comment;
};
///
/// Основная форма панели.
///
class MainForm : public ProtoNode
{
   public:
      MainForm():ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_FORM, "HedgePanel", NULL)
      {
         openPos = new TableOpenPos(GetPointer(this));
         childNodes.Add(openPos);
      }
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         event.High();
         if(event.Direction() == EVENT_FROM_DOWN)return;
         //Конфигурируем местоположение таблицы
         long cwidth = Width()-25;
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 20, 40, Width()-25, High()-50);
         openPos.Event(command);
         delete command;
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
      /// Таблица открытых позиций.
      ///
      TableOpenPos* openPos;
};
///
/// Класс "Кнопка".
///
class Button : public ProtoNode
{
   public:
      
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
      virtual void OnVisible(EventVisible* event)
      {
         if(!Visible())return;
         ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, label);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BORDER_COLOR, clrNONE);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BORDER_COLOR, borderColor);
         ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_FONT, font);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_FONTSIZE, fontsize);
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
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
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

