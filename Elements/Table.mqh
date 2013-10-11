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
      /// Добавляем новую созданную таблицу, либо раскрывает позицию
      ///
      void AddPosition(EventCreatePos* event)
      {
         Position* pos = event.GetPosition();
         //Добавляем только активные позиции.
         //if(pos.Status == POSITION_STATUS_CLOSED)return;
         Line* nline = new Line("pos.", GetPointer(this));
         
         int total = lineHeader.ChildsTotal();
         Label* cell = NULL;
         CArrayObj* deals = pos.EntryDeals();
         
         nline.NLine(lines);
         lines++;
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
      
      ///
      /// Добавляет визуализацию сделок для позиции
      ///
      void AddDeals(GPosition* gpos)
      {
         CArrayObj* entryDeals = gpos.pos.EntryDeals();
         CArrayObj* exitDeals = gpos.pos.ExitDeals();
         // Количество дополнительных строк будет равно максимальном
         // количеству сделок одной из сторон
         int entryTotal = entryDeals != NULL ? entryDeals.Total() : 0;
         int exitTotal = exitDeals != NULL ? exitDeals.Total() : 0;
         int total;
         if(entryTotal > 0 && entryTotal > exitTotal)
            total = entryTotal;
         else if(exitTotal > 0 && exitTotal > exitTotal)
            total = exitTotal;
         else return;
         //Общая высота внедренных строк
         int total_y;
         CArrayObj* alines = new CArrayObj();
         //Перебираем сделки
         for(int i = 0; i < total; i++)
         {
            Line* nline = new Line("deal", GetPointer(this));
            //Перебираем колонки
            int tColumns = gpos.gpos.ChildsTotal();
            for(int c = 0; c < tColumns; c++)
            {
               ProtoNode* cell = gpos.gpos.ChildElementAt(c);
               if(cell.ShortName() == name_collapse_pos)
               {
                  TreeViewBox* twb; 
                  //последний элемент завершается значком ENDSLAVE
                  if(i == total -1)
                     twb = new TreeViewBox("TreeEndSlave", nline, BOX_TREE_ENDSLAVE);
                  else
                     twb = new TreeViewBox("TreeEndSlave", nline, BOX_TREE_SLAVE);
                  twb.BackgroundColor(cell.BackgroundColor());
                  twb.BorderColor(cell.BorderColor());
                  nline.Add(twb);
                  continue;
               }
            }
            nline.NLine(gpos.gpos.NLine() + i);
            alines.Add(nline);
         }
         //Меняем индексацию узлов следующих за строкой позиции.
         int nsum = alines.Total();
         for(int i = gpos.gpos.NLine()+1; i < childNodes.Total(); i++)
         {
            ProtoNode* node = childNodes.At(i);
            node.NLine(node.NLine()+nsum);
         }
         //Вставляем сделки
         childNodes.InsertArray(alines, gpos.gpos.NLine()+1);
         //Теперь пытаемся визуализировать строки сделок
         for(int i = 0; i < alines.Total(); i++)
         {
            Label* deal = alines.At(i);
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, 0, 0);
            deal.Event(command);
            delete command;
         }
      }
      
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