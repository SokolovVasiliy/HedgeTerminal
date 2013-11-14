#include "..\Settings.mqh"
#ifndef TABLE_MQH
   #include "Table.mqh"
#endif

#ifndef TABLE_ABSTRPOS_MQH
   #include "TableAbstrPos.mqh"
#endif


#define TABLEPOSITIONS_MQH
///
/// Таблица открытых позиций.
///
class TablePositions : public Table
{
   public:
      TablePositions(ProtoNode* parNode, ENUM_TABLE_TYPE posType = TABLE_POSACTIVE):Table("TableOfPosition.", parNode, posType)
      {
         this.Init();
      }
      
      /*TablePositions(ProtoNode* parNode):Table("TableOfPosition.", parNode, )
      {
         this.Init();
      }*/
      
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_CREATE_NEWPOS:
               AddPosition(event);
               break;
            case EVENT_REFRESH:
               RefreshPrices();
               break;
            case EVENT_CHECK_BOX_CHANGED:
               OnCheckBoxChanged(event);
               break;
            case EVENT_COLLAPSE_TREE:
               OnCollapse(event);
               break;
            case EVENT_NODE_CLICK:
               OnNodeClick(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
      
   private:
      ///
      /// Инициализация таблицы
      ///
      void Init()
      {
         nProfit = -1;
         nLastPrice = -1;
         ow_twb = 20;
         ow_magic = 100;
         ow_symbol = 70;
         ow_order_id = 80;
         ow_entry_date = 150;
         ow_type = 50;
         ow_vol = 50;
         ow_price = 70;
         ow_sl = 70;
         ow_tp = 70;
         ow_currprice = 70;
         //if(tableType == TABLE_POSHISTORY)
         //   ow_profit = 50;
         //else
            ow_profit = 70;
         //if(tableType == TABLE_POSHISTORY)
            ow_comment = 150;
         //else
         //   ow_comment = 350;
         
         
         name_symbol = "Symbol";
         name_entryOrderId = "Order ID";
         name_exitOrderId = "Exit Order ID";
         name_entry_date = "Entry Date";
         name_exit_date = "Exit Date";
         name_type = "Type";
         name_vol = "Vol.";
         name_entryPrice = "Price";
         name_exitPrice = "Exit Price";
         name_sl = "S/L";
         name_tp = "T/P";
         name_currprice = "Last Price";
         name_profit = "Profit";
         name_entryComment = "Comment";
         name_exitComment = "Exit Comment";
         
         int count = 0;
         Button* hmagic;
         // Каждая линия - специальный тип, знающий, какие именно элементы нужно в себя добавлять.
         AbstractPos* posLine = lineHeader;
         tDir.TableElement(TABLE_HEADER);
         CArrayObj* Columns = Settings.GetSetForActiveTable();
         if(Columns == NULL)return;
         for(int i = 0; i < Columns.Total(); i++)
         {
            DefColumn* el = Columns.At(i);
            switch(el.ColumnType())
            {
               case COLUMN_COLLAPSE:
                  posLine.AddCollapseEl(GetPointer(tDir), el);
                  continue;
               case COLUMN_TRAL:
                  posLine.AddTralEl(GetPointer(tDir), el);
                  continue;
               default:
                  posLine.AddDefaultEl(GetPointer(tDir), el);
            }
            /*if(el.ColumnType() == COLUMN_COLLAPSE)
               posLine.AddCollapseEl(GetPointer(tDir), el);
            else
               posLine.AddDefaultEl(GetPointer(tDir), el);*/
         }
         /*for(int i = 0; i < Columns.Total(); i++)
         {
         DefColumn* el = Columns.At(i);
         if(el.ColumnType() == COLUMN_COLLAPSE)
         {
            posLine.AddCollapseEl(GetPointer(tDir), el);
         }
         // Магический номер
         if(el.ColumnType() == COLUMN_MAGIC)
         {
            posLine.AddDefaultEl(GetPointer(tDir), el);
         }
         if(el.ColumnType() == COLUMN_SYMBOL)
         {
            // Символ
            Button* hSymbol = new Button(name_symbol, GetPointer(lineHeader));
            hSymbol.OptimalWidth(ow_symbol);
            lineHeader.Add(hSymbol);
            //count++;
         }
         // Entry Order ID
         if(el.ColumnType() == COLUMN_ENTRY_ORDER_ID)
         {
            string n;
            if(tDir.TableType() == TABLE_POSHISTORY)
               n = "Entry " + name_entryOrderId;
            else
               n = name_entryOrderId;
            Button* hOrderId = new Button(name_entryOrderId, GetPointer(lineHeader));
            hOrderId.Text(n);
            hOrderId.OptimalWidth(ow_order_id);
            lineHeader.Add(hOrderId);
            //count++;
         }
         // Exit Order ID
         if(el.ColumnType() == COLUMN_EXIT_ORDER_ID)
         {
            Button* hOrderId = new Button(name_exitOrderId, GetPointer(lineHeader));
            hOrderId.OptimalWidth(ow_order_id);
            lineHeader.Add(hOrderId);
            //count++;
         }
         // Время входа в позицию.
         if(el.ColumnType() == COLUMN_ENTRY_DATE)
         {
            Button* hEntryDate = new Button(name_entry_date, GetPointer(lineHeader));
            hEntryDate.OptimalWidth(ow_entry_date);
            lineHeader.Add(hEntryDate);
            //count++;
         }
         // Время выхода из позиции.
         if(el.ColumnType() == COLUMN_EXIT_DATE)
         {
            Button* hExitDate = new Button(name_exit_date, GetPointer(lineHeader));
            hExitDate.OptimalWidth(ow_entry_date);
            lineHeader.Add(hExitDate);
            //count++;
         }
         // Направление позиции.
         if(el.ColumnType() == COLUMN_TYPE)
         {
            Button* hTypePos = new Button(name_type, GetPointer(lineHeader));
            hTypePos.OptimalWidth(ow_type);
            lineHeader.Add(hTypePos);
            //count++;
         }
         // Объем
         if(el.ColumnType() == COLUMN_VOLUME)
         {
            Button* hVolume = new Button(name_vol, GetPointer(lineHeader));
            hVolume.OptimalWidth(ow_vol);
            lineHeader.Add(hVolume);
            //count++;
         }
         // Цена входа.
         if(el.ColumnType() == COLUMN_ENTRY_PRICE)
         {
            string n;
            if(tDir.TableType() == TABLE_POSHISTORY)
               n = "Entry " + name_entryPrice;
            else
            n = name_entryPrice;
            Button* hEntryPrice = new Button(name_entryPrice, GetPointer(lineHeader));
            hEntryPrice.Text(n);
            hEntryPrice.OptimalWidth(ow_price);
            lineHeader.Add(hEntryPrice);
            //count++;
         }
         //Цена выхода.
         if(el.ColumnType() == COLUMN_EXIT_PRICE)
         {
            Button* hEntryPrice = new Button(name_exitPrice, GetPointer(lineHeader));
            hEntryPrice.OptimalWidth(ow_price);
            lineHeader.Add(hEntryPrice);
            //count++;
         }
         // Стоп-лосс
         if(el.ColumnType() == COLUMN_SL)
         {
            Button* hStopLoss = new Button(name_sl, GetPointer(lineHeader));
            hStopLoss.OptimalWidth(ow_sl);
            lineHeader.Add(hStopLoss);
            //count++;
         }
         // Тейк-профит
         if(el.ColumnType() == COLUMN_TP)
         {
            Button* hTakeProfit = new Button(name_tp, GetPointer(lineHeader));
            hTakeProfit.OptimalWidth(ow_tp);
            lineHeader.Add(hTakeProfit);
            //count++;
         }
         //Флаг управления тралом
         if(el.ColumnType() == COLUMN_TRAL)
         {
            Button* hTralSL = new Button(name_tralSl, GetPointer(lineHeader));
            hTralSL.Font("Wingdings");
            //hTralSL.FontColor(clrRed);
            hTralSL.Text(CharToString(79));
            hTralSL.OptimalWidth(lineHeader.OptimalHigh());
            hTralSL.ConstWidth(true);
            lineHeader.Add(hTralSL);
            //count++;
         }
         if(el.ColumnType() == COLUMN_CURRENT_PRICE)
         {
            // Текущая цена
            Button* hCurrentPrice = new Button(name_currprice, GetPointer(lineHeader));
            hCurrentPrice.OptimalWidth(ow_currprice);
            lineHeader.Add(hCurrentPrice);
            nLastPrice = count;
            //count++;
         }
         // Профит
         if(el.ColumnType() == COLUMN_PROFIT)
         {
            Button* hProfit = new Button(name_profit, GetPointer(lineHeader));
            hProfit.OptimalWidth(ow_profit);
            lineHeader.Add(hProfit);
            nProfit = count;
            //count++;
         }
         // Комментарий
         if(el.ColumnType() == COLUMN_ENTRY_COMMENT)
         {
            string n;
            if(tDir.TableType() == TABLE_POSHISTORY)
               n = "Entry " + name_entryComment;
            else
               n = name_entryComment;
            Button* hComment = new Button(name_entryComment, GetPointer(lineHeader));
            hComment.Text(n);
            hComment.OptimalWidth(ow_comment);
            lineHeader.Add(hComment);
            //count++;
         }
         // Комментарий для выхода.
         if(el.ColumnType() == COLUMN_EXIT_COMMENT)
         {
            Button* hComment = new Button(name_exitComment, GetPointer(lineHeader));
            hComment.OptimalWidth(ow_comment);
            lineHeader.Add(hComment);
            //count++;
         }
         }
         //Изменяем тип рамки для каждого из элементов
         for(int i = 0; i < lineHeader.ChildsTotal();i++)
         {
            ProtoNode* node = lineHeader.ChildElementAt(i);
            node.BorderColor(clrBlack);
            node.BackgroundColor(clrWhiteSmoke);
         }
         */
      }
      ///
      /// Обработчик события "трал для позиции включен".
      ///
      void OnCheckBoxChanged(EventCheckBoxChanged* event)
      {
         ProtoNode* node = event.Node();
         if(node.TypeElement() != ELEMENT_TYPE_BOTTON)return;
         Button* btn = node;
         ENUM_BUTTON_STATE state = btn.State();
         ProtoNode* parNode = node.ParentNode();
         if(parNode == NULL || parNode.TypeElement() != ELEMENT_TYPE_POSITION)return;
         PosLine* pos = parNode;
         int total = workArea.ChildsTotal();
         for(int i = parNode.NLine()+1; i < total; i++)
         {
            ProtoNode* mnode = workArea.ChildElementAt(i);
            if(mnode.TypeElement() != ELEMENT_TYPE_DEAL)break;
            DealLine* deal = mnode;
            Label* tral = deal.CellTral();
            if(tral == NULL)return;
            if(tral.Font() != "Wingdings")
               tral.Font("Wingdings");
            if(event.Checked() == true)
               tral.Text(CharToString(254));
            else
               tral.Text(CharToString(168));
         }
      }
      ///
      /// Обрабатываем событие нажатие кнопки мыши.
      ///
      void OnNodeClick(EventNodeClick* event)
      {
         ProtoNode* node = event.Node();
         ProtoNode* parNode = node.ParentNode();
         if(parNode == NULL || parNode != lineHeader)
            return;
         //Обрабатываем включение трала для всех позиций.
         if(node.ShortName() == name_tralSl)
         {
            if(node.TypeElement() != ELEMENT_TYPE_BOTTON)return;
            Button* btn = node;
            //Выключаем трал для всех позиций.
            ENUM_BUTTON_STATE state = btn.State();
            int total = workArea.ChildsTotal();
            for(int i = 0; i < total; i++)
            {
               ProtoNode* mnode = workArea.ChildElementAt(i);
               if(mnode.TypeElement() == ELEMENT_TYPE_POSITION)
               {
                  PosLine* pos = mnode;
                  CheckBox* checkBox = pos.CellTral();
                  if(checkBox.State() != state)
                     checkBox.State(state);
               }
            }
         }
         //Пробуем идентифицировать строку, по которой было осуществленно нажатие
         //if(parentNode.TypeElement() == ELEMENT)
      }
      void OnCollapse(EventCollapseTree* event)
      {
         ProtoNode* node = event.Node();
         ENUM_ELEMENT_TYPE type = node.TypeElement();
         if(type == ELEMENT_TYPE_POSITION)
         {
            // Сворачиваем
            if(event.IsCollapse())
               DeleteDeals(event);
            // Разворачиваем
            else AddDeals(event);
         }
         //Требуется развернуть/свернуть все позиции?
         if(type == ELEMENT_TYPE_TABLE_HEADER_POS)
         {
            // Сворачиваем весь список.
            if(event.IsCollapse())
               CollapseAll();
            // Разворачиваем весь список.
            else RestoreAll();
            //AllocationShow();
         }
         //Обновляем рабочую область для гарантированного позиционирования
         //строк.
         AllocationWorkTable();
         
         //Скролл реагирует на разворачивания списка
         AllocationScroll();      
      }
      
      
      ///
      /// Разворачивает весь список позиций.
      ///
      void RestoreAll()
      {
         for(int i = 0; i < workArea.ChildsTotal(); i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            if(node.TypeElement() != ELEMENT_TYPE_POSITION)
               continue;
            PosLine* posLine = node;
            TreeViewBoxBorder* twb = posLine.CellCollapsePos();
            if(twb == NULL || twb.State() != BOX_TREE_COLLAPSE)continue;
            twb.OnPush();
         }
      }
      ///
      /// Сворачивает весь список позиций
      ///
      void CollapseAll()
      {
         for(int i = 0; i < workArea.ChildsTotal(); i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            if(node.TypeElement() != ELEMENT_TYPE_POSITION)continue;
            PosLine* posLine = node;
            TreeViewBoxBorder* twb = posLine.CellCollapsePos();
            if(twb != NULL && twb.State() != BOX_TREE_RESTORE)continue;
            twb.OnPush();
         }
      }
      ///
      /// Меняет значок раскрывающейся позиции в зависимости от
      /// flaga isCollapse
      ///
      void ChangeCollapse(PosLine* pos, bool isCollapse)
      {
         TreeViewBoxBorder* twb = pos.CellCollapsePos();
         if(isCollapse)
            twb.Text("-");
         else twb.Text("+");
      }
      ///
      /// Обновляет цены открытых позиций.
      ///
      void RefreshPrices()
      {
         int total = workArea.ChildsTotal();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            ENUM_ELEMENT_TYPE el_type = node.TypeElement();
            if(node.TypeElement() != ELEMENT_TYPE_POSITION &&
               node.TypeElement() != ELEMENT_TYPE_DEAL)
               continue;
            //Обновляем позиции и трейды по-разному.
            if(node.TypeElement() == ELEMENT_TYPE_POSITION)
            {
               //Обновляем последнюю цену
               PosLine* posLine = node;
               Position* pos = posLine.Position();
               Label* lastPrice = posLine.CellLastPrice();
               double price = pos.CurrentPrice();
               if(lastPrice != NULL)
               {
                  int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
                  lastPrice.Text(DoubleToString(price, digits));
               }
               //Обновляем информацию о профите позиции
               Label* profit = posLine.CellProfit();
               if(profit != NULL)
                  profit.Text(pos.ProfitAsString());
            }
            else if(node.TypeElement() == ELEMENT_TYPE_DEAL)
            {
               DealLine* dealLine = node;
               Deal* deal = dealLine.EntryDeal();
               double price = deal.CurrentPrice();
               int digits = (int)SymbolInfoInteger(deal.Symbol(), SYMBOL_DIGITS);
               Label* lastPrice = dealLine.CellLastPrice();
               lastPrice.Text(DoubleToString(price, digits));
               //Обновляем информацию о профите сделки.
               Label* profit = dealLine.CellProfit();
               if(profit != NULL)
                  profit.Text(deal.ProfitAsString());
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
         PosLine* nline = new PosLine(GetPointer(workArea),pos);
         
         int total = lineHeader.ChildsTotal();
         
         Label* cell = NULL;
         //CArrayObj* deals = pos.EntryDeals();
         tDir.TableElement(TABLE_POSITION);
         CArrayObj* Columns = Settings.GetSetForActiveTable();
         total = Columns.Total();
         for(int i = 0; i < total; i++)
         {
            bool isReadOnly = true;
            ProtoNode* node = lineHeader.ChildElementAt(i);
            DefColumn* el = Columns.At(i);
            //if(node.ShortName() == name_tralSl)...
            if(el.ColumnType() == COLUMN_COLLAPSE)
            {
               nline.AddCollapseEl(GetPointer(tDir), el);
               continue;
            }
            if(el.ColumnType() == COLUMN_MAGIC)
            {
               TextNode* node = nline.AddDefaultEl(GetPointer(tDir), el);
               node.Text(pos.Magic());
            }
            else if(el.ColumnType() == COLUMN_SYMBOL)
            {
               cell = new Label(name_symbol, GetPointer(nline));
               cell.Text((string)pos.Symbol());
            }
            else if(el.ColumnType() == COLUMN_ENTRY_ORDER_ID)
            {
               cell = new Label(name_entryOrderId, GetPointer(nline));
               cell.Text((string)pos.EntryOrderID());
            }
            else if(el.ColumnType() == COLUMN_ENTRY_DATE)
            {
               cell = new Label(name_entry_date, GetPointer(nline));
               CTime* date = pos.EntryDate();
               string sdate = date.TimeToString(TIME_DATE | TIME_MINUTES | TIME_SECONDS);
               cell.Text(sdate);
            }
            else if(el.ColumnType() == COLUMN_TYPE)
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
            else if(el.ColumnType() == COLUMN_VOLUME)
            {
               cell = new Label(name_vol, GetPointer(nline));
               double step = SymbolInfoDouble(pos.Symbol(), SYMBOL_VOLUME_STEP);
               double mylog = MathLog10(step);
               string vol = mylog < 0 ? DoubleToString(pos.Volume(),(int)(mylog*(-1.0))) : DoubleToString(pos.Volume(), 0);
               cell.Text(vol);
               isReadOnly = false;
            }
            else if(el.ColumnType() == COLUMN_ENTRY_PRICE)
            {
               cell = new Label(name_entryPrice, GetPointer(nline));
               int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(pos.EntryPrice(), digits);
               cell.Text(price);
            }
            else if(el.ColumnType() == COLUMN_SL)
            {
               cell = new Label(name_sl, GetPointer(nline));
               cell.Text((string)pos.StopLoss());
               isReadOnly = false;
            }
            else if(el.ColumnType() == COLUMN_TP)
            {
               cell = new Label(name_tp, GetPointer(nline));
               cell.Text((string)pos.TakeProfit());
               isReadOnly = false; 
            }
            else if(el.ColumnType() == COLUMN_TRAL)
            {
               CheckBox* btnTralSL = new CheckBox(name_tralSl, GetPointer(nline));
               btnTralSL.BorderColor(clrWhite);
               btnTralSL.FontSize(14);
               //btnTralSL.Text(CharToString(168));
               btnTralSL.OptimalWidth(nline.OptimalHigh());
               btnTralSL.ConstWidth(true);
               nline.Add(btnTralSL);
               nline.CellTral(btnTralSL);
               continue;
            }
            else if(el.ColumnType() == COLUMN_CURRENT_PRICE)
            {
               cell = new Label(name_currprice, GetPointer(nline));
               nline.CellLastPrice(cell);
               int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(pos.CurrentPrice(), digits);
               cell.Text(price);
               nline.CellLastPrice(cell);
            }
            
            else if(el.ColumnType() == COLUMN_PROFIT)
            {
               Line* comby = new Line(name_profit, GetPointer(nline));
               comby.BindingWidth(node);
               comby.AlignType(LINE_ALIGN_CELLBUTTON);
               cell = new Label(name_profit, comby);
               //nline.CellProfit(cell);
               cell.Text(pos.ProfitAsString());
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.ReadOnly(true);
               nline.CellProfit(cell);
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
            else if(el.ColumnType() == COLUMN_ENTRY_COMMENT)
            {
               cell = new Label(name_entryComment, GetPointer(nline));
               cell.Text((string)pos.EntryComment());
            }
            else
               cell = new Label("edit", GetPointer(nline));
            if(cell != NULL)
            {
               cell.BindingWidth(node);
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.ReadOnly(isReadOnly);
               nline.Add(cell);
               cell = NULL;
            }
         }
         
         workArea.Add(nline);
         //Что бы новая позиция тут же отобразилась в таблице активных позиций
         //уведомляем родительский элемент, что необходимо сделать refresh
         EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
         EventSend(er);
         delete er;
      }
      
      ///
      /// Добавляет визуализацию сделок для позиции
      ///
      void AddDeals(EventCollapseTree* event)
      {
         /*ProtoNode* node = event.Node();
         //Функция умеет развертывать только позиции, и с другими элеменатми работать не может.
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
         PosLine* posLine = node;
         //Повторно разворачивать уже развернутую позицию не надо.
         if(posLine.IsRestore())return;
         Position* pos = posLine.Position();
         ulong order_id = pos.EntryOrderID();
         //Позиция содержит сделки, которые необходимо раскрыть.
         CArrayObj* entryDeals = pos.EntryDeals();
         CArrayObj* exitDeals = pos.ExitDeals();
         // Количество дополнительных строк будет равно максимальном
         // количеству сделок одной из сторон
         int entryTotal = entryDeals != NULL ? entryDeals.Total() : 0;
         int exitTotal = exitDeals != NULL ? exitDeals.Total() : 0;
         int total;
         int fontSize = 8;
         if(entryTotal > 0 && entryTotal > exitTotal)
            total = entryTotal;
         else if(exitTotal > 0 && exitTotal > exitTotal)
            total = exitTotal;
         else return;
         color clrSlave = clrSlateGray;
         //Перебираем сделки
         tDir.TableElement(TABLE_DEAL);
         for(int i = 0; i < total; i++)
         {
            //Текущая сделка
            Deal* entryDeal = NULL;
            if(entryDeals != NULL && i < entryDeals.Total())
               entryDeal = entryDeals.At(i);
            Deal* exitDeal = NULL;
            if(exitDeals != NULL && i < exitDeals.Total())
               exitDeal = exitDeals.At(i);
            DealLine* nline = new DealLine(GetPointer(workArea), entryDeal, exitDeal);
            nline.BorderType(BORDER_FLAT);
            nline.BorderColor(BackgroundColor());
            //Перебираем колонки
            int tColumns = posLine.ChildsTotal();
            for(int c = 0; c < tColumns; c++)
            {
               ProtoNode* cell = posLine.ChildElementAt(c);
               string n_el = cell.ShortName();
               //Отображение дерева позиции.
               if(el.ColumnType() == COLUMN_COLLAPSE)
               {
                  if(i == total - 1)tDir.IsLastDeal(true);
                  else tDir.IsLastDeal(false);
                  nline.AddCollapseEl(GetPointer(tDir));
                  continue;
               }
               //Magic номер сделки
               if(el.ColumnType() == COLUMN_MAGIC)
               {
                  TextNode* node = nline.AddMagicEl(GetPointer(tDir));
                  node.Text(pos.Magic());
                  continue;
               }
               //Инструмент, по которому совершена сделка.
               if(el.ColumnType() == COLUMN_SYMBOL)
               {
                  Label* symbol = new Label("deal symbol", nline);
                  symbol.FontSize(fontSize);
                  Label* lcell = cell;
                  symbol.ReadOnly(true);
                  symbol.BindingWidth(cell);
                  //symbol.Font("Wingdings");
                  //symbol.Text(CharToString(225));
                  symbol.Text(lcell.Text());
                  //symbol.FontColor(clrSlave);
                  symbol.BackgroundColor(cell.BackgroundColor());
                  symbol.BorderColor(cell.BorderColor());
                  nline.Add(symbol);
                  continue;
               }
               //Идентификатор сделки.
               if(el.ColumnType() == COLUMN_ENTRY_ORDER_ID)
               {
                  Label* entry_id = new Label("EntryDealsID", nline);
                  entry_id.FontSize(fontSize);
                  Label* lcell = cell;
                  entry_id.ReadOnly(true);
                  entry_id.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     entry_id.Text((string)entryDeal.Ticket());
                  }
                  else
                     entry_id.Text("");
                  entry_id.BackgroundColor(cell.BackgroundColor());
                  entry_id.BorderColor(cell.BorderColor());
                  nline.Add(entry_id);
                  continue;
               }
               //Время входа в сделку
               if(el.ColumnType() == COLUMN_ENTRY_DATE)
               {
                  Label* entryDate = new Label("EntryDealsTime", nline);
                  entryDate.FontSize(fontSize);
                  entryDate.ReadOnly(true);
                  entryDate.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     CTime time = entryDeal.Date();
                     entryDate.Text(time.TimeToString(TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                  }
                  else
                     entryDate.Text("");
                  entryDate.BackgroundColor(cell.BackgroundColor());
                  entryDate.BorderColor(cell.BorderColor());
                  nline.Add(entryDate);
                  continue;
               }
               //Тип сделки
               if(el.ColumnType() == COLUMN_TYPE)
               {
                  Label* entryType = new Label("EntryDealsType", nline);
                  entryType.FontSize(fontSize);
                  entryType.ReadOnly(true);
                  entryType.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     ENUM_DEAL_TYPE type = entryDeal.DealType();
                     string stype = EnumToString(type);
                     stype = StringSubstr(stype, 10);
                     StringReplace(stype, "_", " ");
                     entryType.Text(stype);
                  }
                  else
                     entryType.Text("");
                  entryType.BackgroundColor(cell.BackgroundColor());
                  entryType.BorderColor(cell.BorderColor());
                  nline.Add(entryType);
                  continue;
               }
               //Объем
               if(el.ColumnType() == COLUMN_VOLUME)
               {
                  Label* dealVol = new Label("EntryDealsVol", nline);
                  dealVol.FontSize(fontSize);
                  dealVol.ReadOnly(true);
                  dealVol.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     double step = SymbolInfoDouble(entryDeal.Symbol(), SYMBOL_VOLUME_STEP);
                     double mylog = MathLog10(step);
                     string vol = mylog < 0 ? DoubleToString(entryDeal.Volume(),(int)(mylog*(-1.0))) : DoubleToString(entryDeal.Volume(), 0);
                     dealVol.Text(vol);
                  }
                  else
                     dealVol.Text("");
                  dealVol.BackgroundColor(cell.BackgroundColor());
                  dealVol.BorderColor(cell.BorderColor());
                  nline.Add(dealVol);
                  continue;
               }
               //Цена по которой заключена сделка
               if(el.ColumnType() == COLUMN_ENTRY_PRICE)
               {
                  Label* entryPrice = new Label("DealEntryPrice", nline);
                  entryPrice.FontSize(fontSize);
                  entryPrice.ReadOnly(true);
                  entryPrice.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     entryPrice.Text((string)entryDeal.Price());
                  }
                  else
                     entryPrice.Text("");
                  entryPrice.BackgroundColor(cell.BackgroundColor());
                  entryPrice.BorderColor(cell.BorderColor());
                  nline.Add(entryPrice);
                  continue;
               }
               //Стоп-Лосс.
               if(el.ColumnType() == COLUMN_SL)
               {
                  Label* sl = new Label("DealStopLoss", nline);
                  sl.FontSize(fontSize);
                  Label* lcell = cell;
                  sl.ReadOnly(true);
                  sl.BindingWidth(cell);
                  //sl.FontColor(clrSlave);
                  //sl.Font("Wingdings");
                  //sl.Text(CharToString(225));
                  sl.Text(lcell.Text());
                  sl.BackgroundColor(cell.BackgroundColor());
                  sl.BorderColor(cell.BorderColor());
                  nline.Add(sl);
                  continue;
               }
               //Тейк-Профит.
               if(el.ColumnType() == COLUMN_TP)
               {
                  Label* tp = new Label("DealTakeProfit", nline);
                  tp.FontSize(fontSize);
                  Label* lcell = cell;
                  tp.ReadOnly(true);
                  tp.BindingWidth(cell);
                  //tp.FontColor(clrSlave);
                  tp.Text(lcell.Text());
                  //tp.Font("Wingdings");
                  //tp.Text(CharToString(225));
                  tp.BackgroundColor(cell.BackgroundColor());
                  tp.BorderColor(cell.BorderColor());
                  nline.Add(tp);
                  continue;
               }
               //Трал
               if(el.ColumnType() == COLUMN_TRAL)
               {
                  
                  Label* tral = new Label("DealTralSL", nline);
                  tral.FontSize(fontSize);
                  tral.ReadOnly(true);
                  tral.BindingWidth(cell);
                  tral.Font("Wingdings");
                  CheckBox* checkTral = cell;
                  if(checkTral.Checked())
                     tral.Text(CharToString(254));
                  else
                     tral.Text(CharToString(168));
                  tral.FontSize(12);
                  tral.FontColor(clrSlave);
                  tral.Align(ALIGN_CENTER);
                  tral.BackgroundColor(cell.BackgroundColor());
                  tral.BorderColor(cell.BorderColor());
                  nline.Add(tral);
                  nline.CellTral(tral);
                  continue;
               }
               //Последняя цена
               if((cell.ShortName() == name_currprice && tDir.TableType() == TABLE_POSACTIVE) ||
                  ((cell.ShortName() == name_exitPrice || cell.ShortName() == "edit") && tDir.TableType() == TABLE_POSHISTORY))
               {
                  Label* cprice = new Label("DealLastPrice", nline);
                  cprice.FontSize(fontSize);
                  cprice.BindingWidth(cell);
                  Label* lprice = cell;
                  int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
                  string price = DoubleToString(pos.CurrentPrice(), digits);
                  cprice.Text(lprice.Text());
                  cprice.BackgroundColor(cell.BackgroundColor());
                  cprice.BorderColor(cell.BorderColor());
                  //cprice.FontColor(clrSlave);
                  nline.Add(cprice);
                  nline.CellLastPrice(cprice);
                  continue;
               }
               //Профит
               if(cell.ShortName() == name_profit)
               {
                  Label* profit = new Label("DealProfit", nline);
                  profit.FontSize(fontSize);
                  profit.BindingWidth(cell);
                  profit.ReadOnly(true);   
                  if(entryDeal != NULL)
                     profit.Text((string)entryDeal.ProfitAsString());
                  else
                     profit.Text("");
                  //Данная ячека комбинированная, и содержит другие элементы,
                  //чьи свойства мы и будем использовать.
                  int ch_total = cell.ChildsTotal();
                  bool setManual = true;
                  for(int ch = 0; ch < ch_total; ch++)
                  {
                     ProtoNode* pnode = cell.ChildElementAt(ch);
                     ENUM_ELEMENT_TYPE type = pnode.TypeElement();
                     if(type == ELEMENT_TYPE_LABEL)
                     {
                        profit.BackgroundColor(node.BackgroundColor());
                        profit.BorderColor(node.BorderColor());
                        setManual = false;
                        break;
                     }   
                  }
                  if(setManual)
                  {
                     profit.BackgroundColor(clrWhite);
                     profit.BorderColor(clrWhite);
                  }
                  nline.Add(profit);
                  nline.CellProfit(profit);
                  continue;
               }
               //Комментарий
               if(cell.ShortName() == name_entryComment)
               {
                  Label* comment = new Label("DealComment", nline);
                  comment.FontSize(fontSize);
                  comment.BindingWidth(cell);
                  comment.ReadOnly(true);
                  comment.Text("");
                  comment.BackgroundColor(cell.BackgroundColor());
                  comment.BorderColor(cell.BorderColor());
                  nline.Add(comment);
                  continue;
               }
               else
               {
                  Label* entryPrice = new Label("DealEntryPrice", nline);
                  entryPrice.FontSize(fontSize);
                  entryPrice.ReadOnly(true);
                  entryPrice.BindingWidth(cell);
                  entryPrice.BackgroundColor(cell.BackgroundColor());
                  entryPrice.BorderColor(cell.BorderColor());
                  nline.Add(entryPrice);
                  continue;
               }
            }
            int m_total = nline.ChildsTotal();
            for(int el = 0; el < m_total; el++)
            {
               Label* label = nline.ChildElementAt(el);
               label.FontColor(clrDimGray);
            }
            int n = event.NLine();
            workArea.Add(nline, event.NLine()+1);
         }
         posLine.IsRestore(true);*/
      }
      ///
      /// Удаляет визуализацию трейдов позиции
      ///
      void DeleteDeals(EventCollapseTree* event)
      {
         //Имеем дело с визуализированной позицией?
         ProtoNode* node = event.Node();
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
         int sn_line = node.NLine();
         // Визуализация трейдов идет вслед за самой позицией.
         int count = 0;
         for(int i = sn_line+1; i < workArea.ChildsTotal(); i++)
         {
            ProtoNode* cnode = workArea.ChildElementAt(i);
            if(cnode.TypeElement() != ELEMENT_TYPE_DEAL)break;
            count++;
         }
         workArea.DeleteRange(sn_line+1, count);
         PosLine* posLine = node;
         posLine.IsRestore(false);
      }
      /*virtual void OnVisible(EventVisible* event)
      {
         ProtoNode* node = event.Node();
         string el = "Элемент #" + node.NLine();
         string stype = "";
         if(event.Visible())
            stype = " вставлен в список.";
         else
            stype = " удален из списка.";
         el += stype;
         printf(el); 
         EventSend(event);
      }*/
      
      
      
      //CArrayObj* ListPos;
      /*Рекомендованные размеры*/
      long ow_twb;
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
      string name_symbol;
      string name_entryOrderId;
      string name_exitOrderId;
      string name_entry_date;
      string name_exit_date;
      string name_type;
      string name_vol;
      string name_entryPrice;
      string name_exitPrice;
      string name_sl;
      string name_tp;
      string name_tralSl;
      string name_currprice;
      string name_profit;
      string name_entryComment;
      string name_exitComment;
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


 