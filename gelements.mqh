
#include "gnode.mqh"
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
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_COLOR, clrBlack);
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
            default:
               EventSend(event);
               break;
         }
      }
   private:
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
         int total = lineHeader.ChildsTotal();
         Label* cell = NULL;
         //Комбинированный элемент
         Line* comby = NULL;
         for(int i = 0; i < total; i++)
         {
            bool isReadOnly = true;
            ProtoNode* node = lineHeader.ChildElementAt(i);
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
            else if(node.ShortName() == name_currprice)
            {
               cell = new Label(name_currprice, GetPointer(nline));
               int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(pos.CurrentPrice(), digits);
               cell.Text(price);
            }
            
            else if(node.ShortName() == name_profit)
            {
               comby = new Line(name_profit, GetPointer(nline));
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
               btnClose.Label(CharToString(251));
               btnClose.BorderColor(clrWhite);
               double profit = pos.Profit();
               if(profit > 0)
                  btnClose.BackgroundColor(clrMintCream);
               else
                  btnClose.BackgroundColor(clrLavenderBlush);
               comby.Add(cell);
               comby.Add(btnClose);
            }
            else if(node.ShortName() == name_comment)
            {
               cell = new Label(name_comment, GetPointer(nline));
               cell.Text((string)pos.EntryComment());
            }
            else
               cell = new Label("edit", GetPointer(nline));
            if(comby != NULL)
            {
               nline.Add(comby);
               comby = NULL;
            }
            else if(cell != NULL)
            {
               cell.BindOptWidth(node);
               //cell.OptimalWidth(node.OptimalWidth());
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.Edit(isReadOnly);
               nline.Add(cell);
            }
            
         }
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
      string name_magic;
      string name_symbol;
      string name_order_id;
      string name_entry_date;
      string name_type;
      string name_vol;
      string name_price;
      string name_sl;
      string name_tp;
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
};

///
/// Класс "Кнопка".
///
class Button : public ProtoNode
{
   public:
      
      Button(string myName, ProtoNode* parNode):ProtoNode(OBJ_BUTTON, ELEMENT_TYPE_BOTTON, myName, parNode)
      {
         borderColor = clrBlack;
         label = myName;
         font = "Arial";
         fontsize = 10;
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
            }
         }
         else
            EventSend(event);
      }
      virtual void OnVisible(EventVisible* event)
      {
         if(!Visible())return;
         ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, label);
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

class TabButton : public Button
{
   public:
      TabButton(string myName, ProtoNode* protoNode) : Button(myName, protoNode){;}
   private:
      /*virtual void OnPush()
      {
         static int count;
         if(State() == BUTTON_STATE_ON)
         {
            printf(count + ". " + ShortName() + " Нажата");
         }
         else
            printf(ShortName() + " Отжата");
      }*/
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
         BackgroundColor(clrDarkGray);
         BorderColor(clrAqua);
         //Создаем панель управления влкадками
         comPanel = new Line("TabComPanel", GetPointer(this));
         comPanel.AlignType(LINE_ALIGN_SCALE);
         
         //Конфигурируем кнопки вкладок
         btnActivPos = new TabButton("Active", GetPointer(comPanel));
         btnActivPos.OptimalWidth(100);
         btnActivPos.BorderColor(clrBlack);
         btnArray.Add(btnActivPos);
         comPanel.Add(btnActivPos);
         
         btnHistoryPos = new TabButton("History", GetPointer(comPanel));
         btnHistoryPos.OptimalWidth(100);
         btnHistoryPos.BorderColor(clrBlack);
         btnArray.Add(btnHistoryPos);
         comPanel.Add(btnHistoryPos);
         
         //Конфигурируем заглушку.
         stub = new Label("stub", GetPointer(comPanel));
         if(parentNode != NULL)
         {
            stub.BorderColor(parentNode.BackgroundColor());
            stub.BackgroundColor(parentNode.BackgroundColor());
         }
         stub.Edit(false);
         comPanel.Add(stub);
         childNodes.Add(comPanel);
      }
      
   private:
      virtual void OnEvent(Event* event)
      {
         if(event.Direction() == EVENT_FROM_UP)
         {
            // Ловим событие нажатия одной из кнопок панели
            if(event.EventId() == EVENT_BUTTON_PUSH)
            {
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
                     if(state == BUTTON_STATE_ON)
                     {
                        printf("tab: " + btn.ShortName() + " Нажата");
                        btn.BackgroundColor(clrWhite);
                        //Значит все остальные кнопки отжаты
                        for(int k = 0; k < btnArray.Total(); k++)
                        {
                           if(k == i)continue;
                           Button* aBtn = btnArray.At(k);
                           aBtn.State(BUTTON_STATE_OFF);
                           //aBtn.BackgroundColor(clrDarkGray);
                           ENUM_BUTTON_STATE currState = aBtn.State();
                           if(currState == BUTTON_STATE_OFF)
                           {
                              aBtn.BackgroundColor(clrDarkGray);
                           }
                        }
                     }
                     //Эту кнопку можно отжать только другой кнопкой.
                     else
                     {
                        btn.State(BUTTON_STATE_ON);
                        btn.BackgroundColor(clrWhite);
                     }
                  }
               }
               // Если это какая-то другая нажатая кнопка, отправляем событие для нее.
               if(sendEvent)
                  EventSend(event);
               //Для изменений вида кнопок делаем Refresh();
               if(true)
               {
                  EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
                  parentNode.Event(er);
                  delete er;
               }
            }
         }
      }
      
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN)return;
         //Определяем положение заглушки.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, High()-25, Width(), 25);
         comPanel.Event(command);
         delete command;
         //
      }
      
      ///
      /// Панель управления табами.
      ///
      Line* comPanel;
      ///
      /// Заглушка для линии.
      ///
      Label* stub;
      ///
      /// Активирует влкдку "Активные позиции".
      ///
      TabButton* btnActivPos;
      ///
      /// Активирует вкладку "Исторические позиции".
      ///
      TabButton* btnHistoryPos;
      ///
      /// Массив кнопок.
      ///
      CArrayObj btnArray;
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
         //openPos = new TableOpenPos(GetPointer(this));
         //childNodes.Add(openPos);
         tabs = new Tab(GetPointer(this));
         childNodes.Add(tabs);
      }
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN)return;
         //Конфигурируем местоположение таблицы
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 20, 40, Width()-25, High()-50);
         //openPos.Event(command);
         tabs.Event(command);
         delete command;
         
      }
      
      virtual void OnEvent(Event* event)
      {
         //Принимаем команды снизу на обновление терминала
         if(event.Direction() == EVENT_FROM_DOWN)
         {
            if(event.EventId() == EVENT_REFRESH)
            {
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 20, 40, Width()-25, High()-50);
               EventSend(command);
               //tabs.Event(command);
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
      /// Таблица открытых позиций.
      ///
      TableOpenPos* openPos;
      ///
      /// Вкладки
      ///
      Tab* tabs;
      
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



