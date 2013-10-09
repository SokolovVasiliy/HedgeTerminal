
#include "gnode.mqh"
#include "events.mqh"
///
/// Состояние кнопки
///
enum ENUM_BUTTON_STATE
{
   ///
   /// Кнопка выключена, или отжата.
   ///
   BUTTON_STATE_OFF,
   ///
   /// Кнопка включена, или нажата.
   ///
   BUTTON_STATE_ON
};

///
/// Горизонтальный вектор.
///
class Line : public ProtoNode
{
   public:
      Line(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_GCONTAINER, myName, parNode)
      {
         OptimalHigh(20);
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
         string cname = ShortName();
         switch(typeAlign)
         {
            case LINE_ALIGN_CELL:
            case LINE_ALIGN_CELLBUTTON:
               AlgoCellButton();
               break;
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
            //Кнопки всегда квадратные, независимо от ширины окна.
            if(node.ConstWidth()){
               cwidth = node.OptimalWidth();
               string n = node.NameID();
               int ff = 5;
            }
            else
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
         for(int i = total; i >= 0; i--)
         {
            ProtoNode* node = childNodes.At(i);
            ENUM_ELEMENT_TYPE type = node.TypeElement();
            if(node.TypeElement() == ELEMENT_TYPE_BOTTON)
            {
               xdist -= chigh;
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist, 0, chigh, chigh);
               node.Event(command);
               delete command;
            }
            else
            {
               //Средняя ширина элемента
               long avrg = (long)MathRound((double)xdist/(double)(total));
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

class TextNode : public ProtoNode
{
   public:
      ///
      /// Возвращает надпись элемента.
      ///
      string Text(){return text;}
      ///
      /// Устанавливает надпись элемента.
      ///
      void Text(string newText)
      {
         text = newText;
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, text);
      }
      ///
      /// Возвращает имя используемого шрифта.
      ///
      string Font(){return font;}
      ///
      /// Устанавливает имя используемого шрифта.
      ///
      void Font(string myFont)
      {
         font = myFont;
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_FONT, font);
      }
      ///
      /// Возвращает размер используемого шрифта.
      ///
      int FontSize(){return fontsize;}
      ///
      /// Устанавливает размер используемого шрифта.
      ///
      void FontSize(int size)
      {
         fontsize = size;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_FONTSIZE, fontsize);
      }
      color FontColor(){return fontColor;}
      void FontColor(color clrFont)
      {
         fontColor = clrFont;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_COLOR, fontColor);
      }
   protected:
      TextNode(ENUM_OBJECT objType, ENUM_ELEMENT_TYPE elType, string myName, ProtoNode* parNode):
      ProtoNode(objType, elType, myName, parNode)
      {
         text = myName;
         font = "Arial";
         fontsize = 10;
      }
   private:
      virtual void OnVisible(EventVisible* event)
      {
         if(!Visible())return;
         Text(Text());
         Font(Font());
         FontSize(FontSize());
         FontColor(FontColor());
      }
      ///
      ///  Надпись кнопки.
      ///
      string text;
      ///
      /// Имя шрифта.
      ///
      string font;
      ///
      /// Размер шрифта.
      ///
      int fontsize;
      ///
      /// Цвет шрифта.
      ///
      color fontColor;
};

///
/// Текстовая метка
///
class Label : public TextNode
{
   public:
      Label(string myName, ProtoNode* node) : TextNode(OBJ_EDIT, ELEMENT_TYPE_LABEL, myName, node){;}
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
      /*void Text(string myText)
      {
         text = myText;
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, text);
      }*/
      ///
      /// Возвращает текст метки.
      ///
      //string Text(){return text;}
   private:
      virtual void OnVisible(EventVisible* event)
      {
         int d = 5;
         if(Text() == CharToString(74))
            d = 8;
         Text(Text());
         Font(Font());
         FontSize(FontSize());
         FontColor(FontColor());
         Edit(Edit());
         //ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_COLOR, clrBlack);
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
         //BorderType(BORDER_FLAT);
         if(parentNode != NULL)
            backgroundColor = parentNode.BackgroundColor();
         else
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
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, ydist, Width()-24, 20);
               node.Event(command);
               delete command;
               ydist += node.High();
            }
            //
            if(node.TypeElement() == ELEMENT_TYPE_SCROLL)
            {
               bool v = Visible();
               //EventNodeStatus* ch = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(), XAbsDistance(), YAbsDistance(), Width(), High());
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(),Width()-22, 2, 20, High()-4);
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
         nProfit = -1;
         nLastPrice = -1;
         
         ow_magic = 100;
         ow_symbol = 70;
         ow_order_id = 100;
         ow_entry_date = 150;
         ow_type = 50;
         ow_vol = 50;
         ow_price = 70;
         ow_sl = 70;
         ow_tp = 70;
         ow_currprice = 70;
         ow_profit = 90;
         ow_comment = 150;
         
         name_collapse_pos = "CollapsePos.";
         name_magic = "Magic";
         name_symbol = "Symbol";
         name_order_id = "Order ID";
         name_entry_date = "EntryDate";
         name_type = "Type";
         name_vol = "Vol.";
         name_price = "Price";
         name_sl = "S/L";
         name_tp = "T/P";
         name_currprice = "Last Price";
         name_profit = "Profit";
         name_comment = "Comment";
         
         ListPos = new CArrayObj();
         int count = 0;
         
         // Первая линия содержит заголовок таблицы (Она есть всегда).
         lineHeader = new Line("LineHeader", GetPointer(this));
         Button* hmagic;
         // Раскрытие позиции
         if(true)
         {
            TreeViewBox* hCollapse = new TreeViewBox(name_collapse_pos, GetPointer(lineHeader), BOX_TREE_GENERAL);
            hCollapse.Text("+");
            hCollapse.OptimalWidth(20);
            hCollapse.ConstWidth(true);
            lineHeader.Add(hCollapse);
            count++;
         }
         if(true)
         {
            // Магический номер
            hmagic = new Button(name_magic, GetPointer(lineHeader));
            hmagic.OptimalWidth(ow_magic);
            lineHeader.Add(hmagic);
            count++;
         }
         if(true)
         {
            // Символ
            Button* hSymbol = new Button(name_symbol, GetPointer(lineHeader));
            hmagic.OptimalWidth(ow_symbol);
            lineHeader.Add(hSymbol);
            count++;
         }
         if(true)
         {
            // Order ID
            Button* hOrderId = new Button(name_order_id, GetPointer(lineHeader));
            hOrderId.OptimalWidth(ow_order_id);
            lineHeader.Add(hOrderId);
            count++;
         }
         
         if(true)
         {
            // Время входа в позицию.
            Button* hEntryDate = new Button(name_entry_date, GetPointer(lineHeader));
            hEntryDate.OptimalWidth(ow_entry_date);
            lineHeader.Add(hEntryDate);
            count++;
         }
         
         if(true)
         {
            // Направление позиции.
            Button* hTypePos = new Button(name_type, GetPointer(lineHeader));
            hTypePos.OptimalWidth(ow_type);
            lineHeader.Add(hTypePos);
            count++;
         }
         
         if(true)
         {
            // Объем
            Button* hVolume = new Button(name_vol, GetPointer(lineHeader));
            hVolume.OptimalWidth(ow_vol);
            lineHeader.Add(hVolume);
            count++;
         }
         
         if(true)
         {
            // Цена входа.
            Button* hEntryPrice = new Button(name_price, GetPointer(lineHeader));
            hEntryPrice.OptimalWidth(ow_price);
            lineHeader.Add(hEntryPrice);
            count++;
         }
         
         if(true)
         {
            // Стоп-лосс
            Button* hStopLoss = new Button(name_sl, GetPointer(lineHeader));
            hStopLoss.OptimalWidth(ow_sl);
            lineHeader.Add(hStopLoss);
            count++;
         }
         
         if(true)
         {
            // Тейк-профит
            Button* hTakeProfit = new Button(name_tp, GetPointer(lineHeader));
            hTakeProfit.OptimalWidth(ow_tp);
            lineHeader.Add(hTakeProfit);
            count++;
         }
         //Флаг управления тралом
         if(true)
         {
            Button* hTralSL = new Button(name_tralSl, GetPointer(lineHeader));
            hTralSL.Font("Wingdings");
            //hTralSL.FontColor(clrRed);
            hTralSL.Text(CharToString(79));
            hTralSL.OptimalWidth(lineHeader.OptimalHigh());
            hTralSL.ConstWidth(true);
            lineHeader.Add(hTralSL);
            count++;
         }
         if(true)
         {
            // Текущая цена
            Button* hCurrentPrice = new Button(name_currprice, GetPointer(lineHeader));
            hCurrentPrice.OptimalWidth(ow_currprice);
            lineHeader.Add(hCurrentPrice);
            nLastPrice = count;
            count++;
         }
         
         if(true)
         {
            // Профит
            Button* hProfit = new Button(name_profit, GetPointer(lineHeader));
            hProfit.OptimalWidth(ow_profit);
            lineHeader.Add(hProfit);
            nProfit = count;
            count++;
         }
         if(true)
         {
            // Комментарий
            Button* hComment = new Button(name_comment, GetPointer(lineHeader));
            hComment.OptimalWidth(ow_comment);
            lineHeader.Add(hComment);
            count++;
         }
         //Изменяем тип рамки для каждого из элементов
         for(int i = 0; i < lineHeader.ChildsTotal();i++)
         {
            ProtoNode* node = lineHeader.ChildElementAt(i);
            node.BorderColor(clrBlack);
            node.BackgroundColor(clrWhiteSmoke);
         }
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
            case EVENT_REFRESH:
               RefreshPos();
               break;
            case EVENT_COLLAPSE_TREE:
               OnCollapse(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
   private:
      void OnCollapse(EventCollapseTree* event)
      {
         // Сворачиваем
         if(event.IsCollapse())
         {
            printf("Список закрыт");
         }
         // Разворачиваем
         else
         {
            printf("Список раскрыт");
            
         }
      }
      ///
      /// Деинициализируем дополнительные динамические объекты
      ///
      void OnDeinit(EventDeinit* event)
      {
         ListPos.Clear();
         delete ListPos;
      }
      ///
      /// Обновляем состояние позиций
      ///
      void RefreshPos()
      {
         int total = ListPos.Total();
         color lossZone = clrLavenderBlush;
         color profitZone = clrMintCream;
         for(int i = 0; i < total; i++)
         {
            GPosition* gposition = ListPos.At(i);
            //Обновляем профит позиции.
            if(nProfit != -1)
            {
               Line* lline = gposition.gpos.ChildElementAt(nProfit);
               if(lline.ChildsTotal() < 1)continue;
               Label* lprofit = lline.ChildElementAt(0);
               double profit = gposition.pos.Profit();
               string sprofit = gposition.pos.ProfitAsString();
               Button* btnClose = lline.ChildElementAt(1);
               if(profit > 0 && btnClose.BackgroundColor() != profitZone)
                  btnClose.BackgroundColor(profitZone);
               else if(profit <= 0 && btnClose.BackgroundColor() != lossZone)
                  btnClose.BackgroundColor(lossZone);
               lprofit.Text(sprofit);
            }
            //Обновляем последнюю цену позиции
            if(nLastPrice)
            {
               Label* lastprice = gposition.gpos.ChildElementAt(nLastPrice);
               int digits = (int)SymbolInfoInteger(gposition.pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(gposition.pos.CurrentPrice(), digits);
               //lastprice.Text((string)gposition.pos.CurrentPrice());
               lastprice.Text(price);
            }
         }
      }
      
      
      ///
      /// Добавляем новую созданную таблицу.
      ///
      void AddPosition(EventCreatePos* event)
      {
         Position* pos = event.GetPosition();
         //Добавляем только активные позиции.
         //if(pos.Status == POSITION_STATUS_CLOSED)return;
         Line* nline = new Line("pos.", GetPointer(this));
         nline.NLine(lines);
         lines++;
         int total = lineHeader.ChildsTotal();
         Label* cell = NULL;
         for(int i = 0; i < total; i++)
         {
            bool isReadOnly = true;
            ProtoNode* node = lineHeader.ChildElementAt(i);
            if(node.ShortName() == name_collapse_pos)
            {
               TreeViewBox* twb = new TreeViewBox(name_collapse_pos, GetPointer(nline), BOX_TREE_GENERAL);
               twb.OptimalWidth(20);
               twb.ConstWidth(true);
               twb.BackgroundColor(clrWhite);
               twb.BorderColor(clrWhiteSmoke);
               nline.Add(twb);
               continue;
            }
            if(node.ShortName() == name_magic)
            {
               cell = new Label(name_magic, GetPointer(nline));
               cell.Text((string)pos.Magic());
            }
            else if(node.ShortName() == name_symbol)
            {
               cell = new Label(name_symbol, GetPointer(nline));
               cell.Text((string)pos.Symbol());
            }
            else if(node.ShortName() == name_order_id)
            {
               cell = new Label(name_order_id, GetPointer(nline));
               cell.Text((string)pos.EntryOrderID());
            }
            else if(node.ShortName() == name_entry_date)
            {
               cell = new Label(name_entry_date, GetPointer(nline));
               CTime* date = pos.EntryDate();
               string sdate = date.TimeToString(TIME_DATE | TIME_MINUTES | TIME_SECONDS);
               cell.Text(sdate);
            }
            else if(node.ShortName() == name_type)
            {
               cell = new Label(name_type, GetPointer(nline));
               string stype = EnumToString(pos.PositionType());
               stype = StringSubstr(stype, 11);
               StringReplace(stype, "_", " ");
               int len = StringLen(stype);
               int optW = len*10;
               if(node.OptimalWidth() < optW)
                  node.OptimalWidth(optW);
               cell.Text(stype);
            }
            else if(node.ShortName() == name_vol)
            {
               cell = new Label(name_vol, GetPointer(nline));
               double step = SymbolInfoDouble(pos.Symbol(), SYMBOL_VOLUME_STEP);
               double mylog = MathLog10(step);
               string vol = mylog < 0 ? DoubleToString(pos.Volume(),(int)(mylog*(-1.0))) : DoubleToString(pos.Volume(), 0);
               cell.Text(vol);
               isReadOnly = false;
            }
            else if(node.ShortName() == name_price)
            {
               cell = new Label(name_price, GetPointer(nline));
               int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(pos.EntryPrice(), digits);
               cell.Text(price);
            }
            else if(node.ShortName() == name_sl)
            {
               cell = new Label(name_sl, GetPointer(nline));
               cell.Text((string)pos.StopLoss());
               isReadOnly = false;
            }
            else if(node.ShortName() == name_tp)
            {
               cell = new Label(name_tp, GetPointer(nline));
               cell.Text((string)pos.TakeProfit());
               isReadOnly = false; 
            }
            else if(node.ShortName() == name_tralSl)
            {
               CheckBox* btnTralSL = new CheckBox("Check SL", GetPointer(nline));
               btnTralSL.BorderColor(clrWhite);
               btnTralSL.FontSize(14);
               //btnTralSL.Text(CharToString(168));
               btnTralSL.OptimalWidth(nline.OptimalHigh());
               btnTralSL.ConstWidth(true);
               nline.Add(btnTralSL);
               continue;
            }
            else if(node.ShortName() == name_currprice)
            {
               cell = new Label(name_currprice, GetPointer(nline));
               int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(pos.CurrentPrice(), digits);
               cell.Text(price);
            }
            
            else if(node.ShortName() == name_profit)
            {
               Line* comby = new Line(name_profit, GetPointer(nline));
               comby.BindOptWidth(node);
               comby.AlignType(LINE_ALIGN_CELLBUTTON);
               cell = new Label(name_profit, comby);
               cell.Text(pos.ProfitAsString());
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.Edit(true);
               ButtonClosePos* btnClose = new ButtonClosePos("btnClosePos.", comby);
               btnClose.Font("Wingdings");
               btnClose.FontSize(12);
               btnClose.Text(CharToString(251));
               btnClose.BorderColor(clrWhite);
               double profit = pos.Profit();
               if(profit > 0)
                  btnClose.BackgroundColor(clrMintCream);
               else
                  btnClose.BackgroundColor(clrLavenderBlush);
               comby.Add(cell);
               comby.Add(btnClose);
               nline.Add(comby);
               continue;
            }
            else if(node.ShortName() == name_comment)
            {
               cell = new Label(name_comment, GetPointer(nline));
               cell.Text((string)pos.EntryComment());
            }
            else
               cell = new Label("edit", GetPointer(nline));
            if(cell != NULL)
            {
               cell.BindOptWidth(node);
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.Edit(isReadOnly);
               nline.Add(cell);
               cell = NULL;
            }
         }
         // Подкрашиваем каждую вторую строку
         InterlacingColor(nline);
         
         Add(nline);

         GPosition* gposition = new GPosition();
         gposition.pos = pos;
         gposition.gpos = nline;
         ListPos.Add(gposition);
         //Что бы новая позиция тут же отобразилась в таблице активных позиций
         //уведомляем родительский элемент, что необходимо сделать refresh
         EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
         EventSend(er);
         delete er;
      }
      ///
      /// Установка общих настроек для ячейки таблицы
      ///
      /*void CellSettings(const Label* cell)
      {
         cell.BindOptWidth(node);
         cell.BackgroundColor(clrWhite);
         cell.BorderColor(clrWhiteSmoke);
         
      }*/
      ///
      /// Нечетные строки подкрашиваются в более темный оттенок.
      ///
      void InterlacingColor(ProtoNode* nline)
      {
         if(lines % 2 == 0)
         {
            for(int i = 0; i < nline.ChildsTotal(); i++)
            {
               color clrBack = clrWhiteSmoke;
               ProtoNode* node = nline.ChildElementAt(i);
               //Вложенные элементы обрабатываем рекурсивно
               if(node.TypeElement() == ELEMENT_TYPE_GCONTAINER)
               {
                  Line* line = node;
                  for(int k = 0; k < line.ChildsTotal(); k++)
                  {
                     ProtoNode* rnode = line.ChildElementAt(k);
                     //if(rnode.TypeElement() != ELEMENT_TYPE_BOTTON)
                        rnode.BackgroundColor(clrBack);
                     rnode.BorderColor(clrBack);
                  }
               }
               else
               {
                  node.BackgroundColor(clrBack);
                  node.BorderColor(clrBack);
               }
            }
         }
      }
      ///
      /// Графическое представление позиции.
      ///
      class GPosition : CObject
      {
         public:
            ///
            /// Графическое представление позиции.
            ///
            Line* gpos;
            ///
            /// Указатель на текущую позицию.
            ///
            Position* pos;
      };
      CArrayObj* ListPos;
      Line* lineHeader;
      /*Рекомендованные размеры*/
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
      /*Названия колонок*/
      string name_collapse_pos;
      string name_magic;
      string name_symbol;
      string name_order_id;
      string name_entry_date;
      string name_type;
      string name_vol;
      string name_price;
      string name_sl;
      string name_tp;
      string name_tralSl;
      string name_currprice;
      string name_profit;
      string name_comment;
      ///
      /// Номер ячейки в линии, отображающий профит позиции.
      ///
      int nProfit;
      ///
      /// Номер ячейки в линии, отображающий последнюю цену инструмента,
      /// по которому открыта позиция.
      ///
      int nLastPrice;
      ///
      /// Количество строк в таблице.
      ///
      int lines;
};

///
/// Класс "Кнопка".
///
class Button : public TextNode
{
   public:
      
      Button(string myName, ProtoNode* parNode) : TextNode(OBJ_BUTTON, ELEMENT_TYPE_BOTTON, myName, parNode)
      {
         BorderColor(clrBlack);
      }
      ///
      /// Возвращает состояние кнопки. Если кнопка невидима или отжата возвращает false.
      /// Если кнопка нажата - возвращает true;
      ///
      ENUM_BUTTON_STATE State()
      {
         if(!Visible())return BUTTON_STATE_OFF;
         bool state = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE);
         if(state)return BUTTON_STATE_ON;
         return BUTTON_STATE_OFF;
      }
      ///
      /// Устанавливает кнопку в нажатое или отжатое состояние. Кнопка должна отображаться в окне.
      /// \param state - Состояние, в которое требуется установить кнопку.
      ///
      void State(ENUM_BUTTON_STATE set_state)
      {
         if(!Visible())return;
         ENUM_BUTTON_STATE state = State();
         if(set_state != state)
         {
            bool flag;
            if(set_state == BUTTON_STATE_OFF) flag = false;
            else flag = true;
            bool rez = ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE, flag);
            if(rez)OnPush();
         }
      }
   protected:
      ///
      /// Каждый потомок должен самостоятельно определить свои действия,
      /// при нажатии кнопки.
      ///
      virtual void OnPush(){;}
      //
      virtual void OnEvent(Event* event)
      {
         int id = event.EventId();
         if(id == EVENT_BUTTON_PUSH)
         {
            EventButtonPush* push = event;
            if(push.ButtonName() == NameID())
            {
               OnPush();
               //После каждого нажатия кнопки принудительно обновляем окно
               ChartRedraw(MAIN_WINDOW);
            }
            
         }
         else
            EventSend(event);
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
};

class CheckBox : public Button
{
   public:
      CheckBox(string nameCheck, ProtoNode* parNode) : Button(nameCheck, parNode)
      {
         Font("Wingdings");
         checked = false;
         Text(CharToString(168));
      }
      bool Checked(){return checked;}
   private:
      virtual void OnPush()
      {
         if(State() == BUTTON_STATE_OFF)
         {
            checked = false;
            Text(CharToString(168));
         }
         else
         {
            checked = true;
            Text(CharToString(254));
         }
      }
      bool checked;
};

///
/// Тип метки раскрывающегося списка
///
enum ENUM_BOX_TREE_TYPE
{
   BOX_TREE_GENERAL,
   BOX_TREE_SLAVE,
   BOX_TREE_ENDSLAVE
};

class TreeViewBox : public Button
{
   public:
      TreeViewBox(string nameCheck, ProtoNode* parNode, ENUM_BOX_TREE_TYPE treeType) : Button(nameCheck, parNode)
      {
         boxTreeType = treeType;
         Font("Arial");
         opened = false;
         if(boxTreeType == BOX_TREE_GENERAL)
            Text("+");
         else
            Text("-");
      }
      bool Opened(){return opened;}
   private:
      virtual void OnPush()
      {
         if(boxTreeType == BOX_TREE_GENERAL)
         {
            if(State() == BUTTON_STATE_OFF)
            {
               opened = false;
               Text("+");
               //Создаем событие "Список закрыт".
               EventCollapseTree* ctree = new EventCollapseTree(EVENT_FROM_DOWN, parentNode, true);
               EventSend(ctree);
               delete ctree;
            }
            else
            {
               opened = true;
               Text("-");
               //Создаем событие "Список раскрыт".
               string name = parentNode.NameID();
               EventCollapseTree* ctree = new EventCollapseTree(EVENT_FROM_DOWN, parentNode, false);
               EventSend(ctree);
               delete ctree;
            }
         }
         
      }
      bool opened;
      ENUM_BOX_TREE_TYPE boxTreeType;
};

///
/// Класс вкладки.
///
class Tab : public ProtoNode
{
   public:
      Tab(ProtoNode* protoNode) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_TAB, "Tab", protoNode)
      {
         //Конфигурируем вкладки
         BorderType(BORDER_FLAT);
         BackgroundColor(clrWhite);
         clrShadowTab = clrGainsboro;
         //Создаем панель управления влкадками
         comPanel = new Line("TabComPanel", GetPointer(this));
         comPanel.AlignType(LINE_ALIGN_SCALE);
         
         //Конфигурируем кнопки вкладок
         btnActivPos = new Button("Active", GetPointer(comPanel));
         btnActivPos.OptimalWidth(100);
         btnActivPos.BorderColor(clrBlack);
         btnArray.Add(btnActivPos);
         btnActive = btnActivPos;
         comPanel.Add(btnActivPos);
         
         btnHistoryPos = new Button("History", GetPointer(comPanel));
         btnHistoryPos.OptimalWidth(100);
         btnHistoryPos.BorderColor(clrBlack);
         btnArray.Add(btnHistoryPos);
         comPanel.Add(btnHistoryPos);
         
         //Конфигурируем заглушки.
         stub = new Label("stub", GetPointer(comPanel));
         stub.Text("");
         if(parentNode != NULL)
         {
            stub.BorderColor(parentNode.BackgroundColor());
            stub.BackgroundColor(parentNode.BackgroundColor());
         }
         stub.Edit(false);
         comPanel.Add(stub);
         childNodes.Add(comPanel);
         
         sstub = new Label("stub2", GetPointer(this));
         sstub.Text("");
         sstub.BorderColor(BackgroundColor());
         sstub.BackgroundColor(BackgroundColor());
         sstub.Edit(false);
         childNodes.Add(sstub);
         
         //Внедряем таблицу открытых позиций в окно вкладок.
         openPos = new TableOpenPos(GetPointer(this));
         openPos.BorderType(BORDER_FLAT);
         childNodes.Add(openPos);
      }
      
   private:
      virtual void OnEvent(Event* event)
      {
         if(event.Direction() == EVENT_FROM_UP)
         {
            // Ловим событие нажатия одной из кнопок панели
            if(event.EventId() == EVENT_BUTTON_PUSH)
            {
               ENUM_BUTTON_STATE myState = btnHistoryPos.State();
               EventButtonPush* push = event;
               string btnName = push.ButtonName();
               bool sendEvent = true;
               for(int i = 0; i < btnArray.Total(); i++)
               {
                  Button* btn = btnArray.At(i);
                  if(btn.NameID() == btnName)
                  {
                     sendEvent = false;
                     ENUM_BUTTON_STATE state = btn.State();
                     //Кнопка нажата?
                     if(state == BUTTON_STATE_OFF)
                     {
                        btn.BackgroundColor(BackgroundColor());
                        //Перемещаем заглушку к новой кнопке
                        btnActive = btn;
                        EventNodeCommand* command2 = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), btnActive.XLocalDistance()+1,
                        comPanel.YLocalDistance()-1, btnActive.Width()-2, 5);
                        sstub.Event(command2);
                        delete command2;
                        
                        //Значит все остальные кнопки отжаты
                        for(int k = 0; k < btnArray.Total(); k++)
                        {
                           if(k == i)continue;
                           Button* aBtn = btnArray.At(k);
                           aBtn.State(BUTTON_STATE_ON);
                           //aBtn.BackgroundColor(clrDarkGray);
                           ENUM_BUTTON_STATE currState = aBtn.State();
                           if(currState == BUTTON_STATE_ON)
                           {
                              aBtn.BackgroundColor(clrShadowTab);
                           }
                        }
                     }
                     //Эту кнопку можно отжать только другой кнопкой.
                     else
                     {
                        btn.State(BUTTON_STATE_OFF);
                        btn.BackgroundColor(BackgroundColor());
                        //Значит все остальные кнопки отжаты
                        for(int k = 0; k < btnArray.Total(); k++)
                        {
                           if(k == i)continue;
                           Button* aBtn = btnArray.At(k);
                           aBtn.State(BUTTON_STATE_ON);
                        }
                     }
                  }
               }
               // Если это какая-то другая нажатая кнопка, отправляем событие для нее.
               if(sendEvent)
                  EventSend(event);
               else
                  ChartRedraw(MAIN_WINDOW);
               //Для изменений вида кнопок делаем Refresh();
               if(true)
               {
                  EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
                  parentNode.Event(er);
                  delete er;
               }
            }
            else
               EventSend(event);
         }
         else
            EventSend(event);
      }
      
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN)return;
         //Определяем положение заглушки.
         bool vis = comPanel.Visible();
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, High()-25, Width(), 25);
         comPanel.Event(command);
         delete command;
         if(!vis && vis != comPanel.Visible())
         {
            btnActivPos.BackgroundColor(BackgroundColor());
            btnHistoryPos.BackgroundColor(clrShadowTab);
            btnHistoryPos.State(BUTTON_STATE_ON);
            ENUM_BUTTON_STATE state = btnHistoryPos.State();
            ChartRedraw(MAIN_WINDOW);
         }
         
         //Определяем местоположение таблицы
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, Width(), High()-25);
         openPos.Event(command);
         delete command;
         //Конфигурируем заглушку.
         EventNodeCommand* command2 = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), btnActive.XLocalDistance()+1,
         comPanel.YLocalDistance()-3, btnActive.Width()-2, 5);
         sstub.Event(command2);
         delete command2;
      }
      ///
      /// Панель управления табами.
      ///
      Line* comPanel;
      ///
      /// Заглушка для панели кнопок.
      ///
      Label* stub;
      ///
      /// Заглушка для активной кнопки.
      ///
      Label* sstub;
      ///
      /// Активирует влкдку "Активные позиции".
      ///
      Button* btnActivPos;
      ///
      /// Активирует вкладку "Исторические позиции".
      ///
      Button* btnHistoryPos;
      ///
      /// Текущая активная кнопка.
      ///
      Button* btnActive;
      ///
      /// Таблица открытых позиций.
      ///
      TableOpenPos* openPos;
      
      ///
      /// Массив кнопок.
      ///
      CArrayObj btnArray;
      ///
      /// Цвет не активной вкладки.
      ///
      color clrShadowTab;
};

///
/// Основная форма панели.
///
class MainForm : public ProtoNode
{
   public:
      MainForm():ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_FORM, "HedgePanel", NULL)
      {
         BorderType(BORDER_FLAT);
         BackgroundColor(clrWhiteSmoke);
         tabs = new Tab(GetPointer(this));
         childNodes.Add(tabs);
         allowed = false;
         
         status = new Label("TradeStatus", GetPointer(this));
         status.Edit(true);
         status.BackgroundColor(BackgroundColor());
         status.BorderColor(BackgroundColor());
         status.Font("Wingdings");
         status.Text(CharToString(76));
         status.FontSize(14);
         status.FontColor(clrRed);
         childNodes.Add(status);
         
         mailStatus = new Label("MailStatus", GetPointer(this));
         mailStatus.Edit(true);
         mailStatus.BackgroundColor(BackgroundColor());
         mailStatus.BorderColor(BackgroundColor());
         mailStatus.Font("Wingdings");
         mailStatus.Text(CharToString(42));
         mailStatus.FontSize(12);
         mailStatus.FontColor(clrRed);
         childNodes.Add(mailStatus);
         
         connected = new Label("ConnectedStatus", GetPointer(this));
         connected.Edit(true);
         connected.BackgroundColor(BackgroundColor());
         connected.BorderColor(BackgroundColor());
         connected.Font("Wingdings");
         connected.Text(CharToString(40));
         connected.FontSize(12);
         connected.FontColor(clrRed);
         childNodes.Add(connected);
         
      }
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN)return;
         //Конфигурируем местоположение таблицы
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 5, 40, Width()-10, High()-45);
         tabs.Event(command);
         delete command;
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-22, 2, 20, 18);
         status.Event(command);
         delete command;
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-55, 1, 25, 18);
         mailStatus.Event(command);
         delete command;
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-88, 1, 25, 18);
         connected.Event(command);
         delete command;
      }
      
      virtual void OnEvent(Event* event)
      {
         if(event.Direction() == EVENT_FROM_UP)
         {
            if(event.EventId() == EVENT_REFRESH)
            {
               //Проверяем возможность торговли
               bool is_allowed = TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
               if(is_allowed != allowed)
               {
                  allowed = is_allowed;
                  if(!is_allowed)
                  {
                     status.FontColor(clrRed);
                     status.Text(CharToString(76));
                  }
                  else
                  {
                     status.FontColor(clrGreen);
                     status.Text(CharToString(74));
                  }
               }
               bool isMail = TerminalInfoInteger(TERMINAL_EMAIL_ENABLED);
               if(isMail != mail_allowed)
               {
                  mail_allowed = isMail;
                  if(isMail)mailStatus.FontColor(clrGreen);
                  else mailStatus.FontColor(clrRed);
               }
               bool isConn = TerminalInfoInteger(TERMINAL_CONNECTED);
               if(isConnected != isConn)
               {
                  isConnected = isConn;
                  if(isConn)connected.FontColor(clrGreen);
                  else connected.FontColor(clrRed);
               }
            }
         }
         //Принимаем команды снизу на обновление терминала
         if(event.Direction() == EVENT_FROM_DOWN)
         {
            if(event.EventId() == EVENT_REFRESH)
            {
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 5, 40, Width()-10, High()-45);
               tabs.Event(command);
               //openPos.Event(command);
               delete command;
               return;
            }
         }
         EventSend(event);
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
      /// Вкладки
      ///
      Tab* tabs;
      ///
      /// Статус торговли
      ///
      Label* status;
      ///
      /// Флаг разрешения торговли советником.
      ///
      bool allowed;
      ///
      /// Разрешение на отправку писем
      ///
      bool mail_allowed;
      ///
      /// Показывает разрешение на отправку писем.
      ///
      Label* mailStatus;
      ///
      /// Флаг подключения к серверу.
      ///
      bool isConnected;
      ///
      /// Статус подключения к серверу.
      ///
      Label* connected;
};

class ButtonClosePos : public Button
{
   public:
      ButtonClosePos(string myName, ProtoNode* parNode) : Button(myName, parNode){;}
   protected:
      virtual void OnPush()
      {
         //bool state = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE, false);
         //prinf("MSC: " + );
         //if(state)
         //   printf("Кнокпа нажата");
         //else
         //   printf("Кнокпа отжата");
      }
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
         up.Text(CharToString(241));
         up.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(up);
         
         dn = new Button("DnClick", GetPointer(this));
         dn.BorderColor(clrNONE);
         dn.Font("Wingdings");
         dn.Text(CharToString(242));
         dn.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(dn);
         
         toddler = new Button("Todler", GetPointer(this));
         toddler.BorderType(BORDER_FLAT);
         toddler.BackgroundColor(clrWhiteSmoke);
         //toddler.BorderColor(toddler.BackgroundColor());
         childNodes.Add(toddler);
         BackgroundColor(clrWhiteSmoke); 
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



