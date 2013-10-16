#include "..\API\Position.mqh"
#include "..\Events.mqh"
#include "Node.mqh"
#include "Button.mqh"
#include "TreeViewBox.mqh"
#include "Line.mqh"
#include "Label.mqh"
#include "Scroll.mqh"
///
/// Класс "Таблица" представляет из себя универсальный контейнер, состоящий из трех элементов:
/// 1. Заголовок таблицы;
/// 2. Вертикальный контейнер строк;
/// 3. Скролл прокрутки вертикального контейнера строк.
/// Каждый из трех элементов имеет свой персональный указатель.
///
class Table : public ProtoNode
{
   public:
      Table(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_UCONTAINER, myName, parNode)
      {
         
         highLine = 20;
         lineHeader = new Line("Header", GetPointer(this));
         workArea = new CWorkArea(GetPointer(this));
         workArea.Edit(true);
         workArea.Text("");
         workArea.BorderColor(BackgroundColor());
         scroll = new Scroll("Scroll", GetPointer(this));
         childNodes.Add(lineHeader);
         childNodes.Add(workArea);
         childNodes.Add(scroll);
      }
   protected:
      class CWorkArea : public Label
      {
         public:
            CWorkArea(ProtoNode* parNode) : Label("WorkArea", parNode)
            {
               highLine = 20;
               Text("");
               Edit(true);
               BorderColor(parNode.BackgroundColor());
            }
            ///
            /// Добавляет новую строку в конец таблицы и автоматически определяет ее размер и положение
            ///
            void Add(ProtoNode* lineNode)
            {
               Add(lineNode, ChildsTotal());
            }
            ///
            /// Добавляет новую строку таблицы по индексу pos
            ///
            void Add(ProtoNode* lineNode, int pos)
            {
               //lineNode.NLine(pos);
               InsertElement(lineNode, pos);
               //после вставки элемента, все последующие элементы изменили свои координаты.
               int total = ChildsTotal();
               for(int i = pos; i < total; i++)
               {
                  RefreshLine(i);
               }
            }
            ///
            /// Обновляет координаты и размер линии по индексу index
            ///
            void RefreshLine(int index)
            {
               int total = ChildsTotal();
               if(index < 0 || index >= total)return;
               //Получаем линию под номером index.
               ProtoNode* node = ChildElementAt(index);
               node.NLine(index);
               if(index == 0)
               {
                  EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, Width(), highLine);
                  node.Event(command);
                  node.NLine(0);
                  delete command;
               }
               else
               {
                  ProtoNode* prevNode = ChildElementAt(index-1);
                  long y_dist = prevNode.YLocalDistance() + prevNode.High();
                  EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, y_dist, Width(), highLine);
                  node.Event(command);
                  delete command;
               }
               InterlacingColor(node);
            }
         private:
            virtual void OnCommand(EventNodeCommand* event)
            {
               //Команды снизу не принимаются.
               if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
               
               //Размещаем строки рабочей области
               int total = ChildsTotal();
               for(int i = 0; i < total; i++)
               {
                  RefreshLine(i);
               }
            }
            ///
            /// Нечетные строки подкрашиваются в более темный оттенок.
            ///
            void InterlacingColor(ProtoNode* nline)
            {
               color clrBack;
               if((nline.NLine()+1) % 2 == 0)
                  clrBack = clrWhiteSmoke;
               else clrBack = clrWhite;
               for(int i = 0; i < nline.ChildsTotal(); i++)
               {
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
            int highLine;
      };
      ///
      /// Заголовок таблицы.
      ///
      Line* lineHeader;
      ///
      /// Рабочая область таблицы
      ///
      CWorkArea* workArea;
      ///
      /// Скролл.
      ///
      Scroll* scroll;
   private:
      
      virtual void OnCommand(EventNodeCommand* event)
      {
         //Команды снизу не принимаются.
         if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
         
         //Размещаем заголовок таблицы.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 2, Width()-24, 20);
         lineHeader.Event(command);
         delete command;
            
         //Размещаем рабочую область.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 22, Width()-24, High()-24);
         workArea.Event(command);
         delete command;
         
         //Размещаем скролл.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(),Width()-22, 2, 20, High()-4);
         scroll.Event(command);
         delete command;
      }
      ///
      /// Ширина линии.
      ///
      int highLine;
      
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
         ow_twb = 20;
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
         //lineHeader = new Line("LineHeader", GetPointer(this));
         Button* hmagic;
         // Раскрытие позиции
         if(true)
         {
            TreeViewBox* hCollapse = new TreeViewBox(name_collapse_pos, GetPointer(lineHeader), BOX_TREE_GENERAL);
            hCollapse.Text("+");
            hCollapse.OptimalWidth(ow_twb);
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
            //printf("Сделка № " + event.NLine() + " закрыта.");
         }
         // Разворачиваем
         else
         {
            //printf("Сделка № " + event.NLine() + " раскрыта.");
            AddDeals(event);
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
         Line* nline = new Line("pos.", GetPointer(workArea));
         
         int total = lineHeader.ChildsTotal();
         Label* cell = NULL;
         CArrayObj* deals = pos.EntryDeals();
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
               CheckBox* btnTralSL = new CheckBox(name_tralSl, GetPointer(nline));
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
               comby.BindingWidth(node);
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
               cell.BindingWidth(node);
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.Edit(isReadOnly);
               nline.Add(cell);
               cell = NULL;
            }
         }
         workArea.Add(nline);
         //Add(nline);
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
      
      ///
      /// Добавляет визуализацию сделок для позиции
      ///
      void AddDeals(EventCollapseTree* event)
      {
         GPosition* gpos = ListPos.At(event.NLine());
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
         //Перебираем сделки
         for(int i = 0; i < total; i++)
         {
            Line* nline = new Line("deal", GetPointer(workArea));
            nline.BorderType(BORDER_FLAT);
            nline.BorderColor(BackgroundColor());
            //Перебираем колонки
            int tColumns = gpos.gpos.ChildsTotal();
            for(int c = 0; c < tColumns; c++)
            {
               ProtoNode* cell = gpos.gpos.ChildElementAt(c);
               //Отображение дерева позиции.
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
                  twb.BindingWidth(cell);
                  //twb.OptimalWidth(ow_twb);
                  //twb.ConstWidth(true);
                  nline.Add(twb);
                  continue;
               }
               //Magic номер сделки
               if(cell.ShortName() == name_magic)
               {
                  Label* magic = new Label("deal magic", nline);
                  Label* lcell = cell;
                  magic.Edit(true);
                  magic.BindingWidth(cell);
                  magic.Text("Magic");
                  //magic.Text(lcell.Text());
                  magic.BackgroundColor(cell.BackgroundColor());
                  magic.BorderColor(cell.BorderColor());
                  //magic.BorderColor(clrBlack);
                  nline.Add(magic);
                  continue;
               }
               //Инструмент, по которому совершена сделка.
               if(cell.ShortName() == name_symbol)
               {
                  Label* symbol = new Label("deal symbol", nline);
                  Label* lcell = cell;
                  symbol.Edit(true);
                  symbol.BindingWidth(cell);
                  symbol.Text("Symbol");
                  //symbol.Text(lcell.Text());
                  symbol.BackgroundColor(cell.BackgroundColor());
                  symbol.BorderColor(cell.BorderColor());
                  //symbol.BorderColor(clrBlack);
                  nline.Add(symbol);
                  continue;
               }
               //Идентификатор сделки.
               if(cell.ShortName() == name_order_id)
               {
                  Label* entry_id = new Label("EntryDealsID", nline);
                  Label* lcell = cell;
                  entry_id.Edit(true);
                  entry_id.BindingWidth(cell);
                  //entry_id.OptimalWidth(ow_order_id);
                  CArrayObj* deals = gpos.pos.EntryDeals();
                  if(deals != NULL && i < deals.Total())
                  {
                     Deal* deal = deals.At(i);
                     entry_id.Text((string)deal.Ticket());
                  }
                  else
                     entry_id.Text("");
                  entry_id.BackgroundColor(cell.BackgroundColor());
                  entry_id.BorderColor(cell.BorderColor());
                  //entry_id.BorderColor(clrBlack);
                  nline.Add(entry_id);
                  continue;
               }
               //Время входа в сделку
               if(cell.ShortName() == name_entry_date)
               {
                  Label* entryDate = new Label("EntryDealsTime", nline);
                  entryDate.Edit(true);
                  entryDate.OptimalWidth(ow_entry_date);
                  CArrayObj* deals = gpos.pos.EntryDeals();
                  if(deals != NULL && i < deals.Total())
                  {
                     Deal* deal = deals.At(i);
                     CTime time = deal.Date();
                     entryDate.Text(time.TimeToString(TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                  }
                  else
                     entryDate.Text("");
                  entryDate.BackgroundColor(cell.BackgroundColor());
                  entryDate.BorderColor(cell.BorderColor());
                  //entryDate.BorderColor(clrBlack);
                  nline.Add(entryDate);
                  continue;
               }
               //Тип сделки
               if(cell.ShortName() == name_type)
               {
                  Label* entryType = new Label("EntryDealsType", nline);
                  entryType.Edit(true);
                  entryType.BindingWidth(cell);
                  CArrayObj* deals = gpos.pos.EntryDeals();
                  if(deals != NULL && i < deals.Total())
                  {
                     Deal* deal = deals.At(i);
                     ENUM_DEAL_TYPE type = deal.DealType();
                     string stype = EnumToString(type);
                     stype = StringSubstr(stype, 10);
                     StringReplace(stype, "_", " ");
                     entryType.Text(stype);
                  }
                  else
                     entryType.Text("");
                  entryType.BackgroundColor(cell.BackgroundColor());
                  entryType.BorderColor(cell.BorderColor());
                  //entryType.BorderColor(clrBlack);
                  nline.Add(entryType);
                  continue;
               }
               //Объем
               if(cell.ShortName() == name_vol)
               {
                  Label* dealVol = new Label("EntryDealsVol", nline);
                  dealVol.Edit(true);
                  dealVol.BindingWidth(cell);
                  //dealVol.OptimalWidth(ow_vol);
                  CArrayObj* deals = gpos.pos.EntryDeals();
                  if(deals != NULL && i < deals.Total())
                  {
                     double step = SymbolInfoDouble(gpos.pos.Symbol(), SYMBOL_VOLUME_STEP);
                     double mylog = MathLog10(step);
                     Deal* deal = deals.At(i);
                     string vol = mylog < 0 ? DoubleToString(deal.Volume(),(int)(mylog*(-1.0))) : DoubleToString(deal.Volume(), 0);
                     dealVol.Text(vol);
                  }
                  else
                     dealVol.Text("");
                  dealVol.BackgroundColor(cell.BackgroundColor());
                  dealVol.BorderColor(cell.BorderColor());
                  //dealVol.BorderColor(clrBlack);
                  nline.Add(dealVol);
                  continue;
               }
               //Цена по которой заключена сделка
               if(cell.ShortName() == name_price)
               {
                  Label* entryPrice = new Label("DealEntryPrice", nline);
                  entryPrice.Edit(true);
                  entryPrice.BindingWidth(cell);
                  //entryPrice.OptimalWidth(ow_price);
                  CArrayObj* deals = gpos.pos.EntryDeals();
                  Deal* deal = deals.At(i);
                  entryPrice.Text((string)deal.Price());
                  entryPrice.BackgroundColor(cell.BackgroundColor());
                  entryPrice.BorderColor(cell.BorderColor());
                  //entryPrice.BorderColor(clrBlack);
                  nline.Add(entryPrice);
                  continue;
               }
               //Стоп-Лосс.
               if(cell.ShortName() == name_sl)
               {
                  Label* sl = new Label("DealStopLoss", nline);
                  Label* lcell = cell;
                  sl.Edit(true);
                  sl.BindingWidth(cell);
                  //sl.OptimalWidth(ow_tp);
                  sl.Text(lcell.Text());
                  sl.BackgroundColor(cell.BackgroundColor());
                  sl.BorderColor(cell.BorderColor());
                  //sl.BorderColor(clrBlack);
                  nline.Add(sl);
                  continue;
               }
               //Тейк-Профит.
               if(cell.ShortName() == name_tp)
               {
                  Label* tp = new Label("DealTakeProfit", nline);
                  Label* lcell = cell;
                  tp.Edit(true);
                  tp.BindingWidth(cell);
                  //tp.OptimalWidth(ow_tp);
                  tp.Text(lcell.Text());
                  tp.BackgroundColor(cell.BackgroundColor());
                  tp.BorderColor(cell.BorderColor());
                  //tp.BorderColor(clrBlack);
                  nline.Add(tp);
                  continue;
               }
               //Трал
               if(cell.ShortName() == name_tralSl)
               {
                  Label* tral = new Label("DealTralSL", nline);
                  tral.Edit(true);
                  tral.BindingWidth(cell);
                  tral.Text("T");
                  tral.BackgroundColor(cell.BackgroundColor());
                  tral.BorderColor(cell.BorderColor());
                  //tral.BorderColor(clrBlack);
                  int count = nline.ChildsTotal();
                  nline.Add(tral);
                  int count1 = nline.ChildsTotal();
                  int kk = 8;
                  continue;
               }
               //Последняя цена
               if(cell.ShortName() == name_currprice)
               {
                  Label* cprice = new Label("DealLastPrice", nline);
                  cprice.BindingWidth(cell);
                  //cprice.OptimalWidth(ow_currprice);
                  int digits = (int)SymbolInfoInteger(gpos.pos.Symbol(), SYMBOL_DIGITS);
                  string price = DoubleToString(gpos.pos.CurrentPrice(), digits);
                  cprice.Text("lprice");
                  //cprice.Text(price);
                  cprice.BackgroundColor(cell.BackgroundColor());
                  cprice.BorderColor(cell.BorderColor());
                  //cprice.BorderColor(clrBlack);
                  nline.Add(cprice);
                  continue;
               }
               //Профит
               if(cell.ShortName() == name_profit)
               {
                  Label* profit = new Label("DealProfit", nline);
                  profit.BindingWidth(cell);
                  
                  //profit.OptimalWidth(ow_profit);
                  profit.Edit(true);
                  profit.Text("Profit");
                  //Данная ячека комбинированная, и содержит другие элементы,
                  //чьи свойства мы и будем использовать.
                  int ch_total = cell.ChildsTotal();
                  bool setManual = true;
                  for(int ch = 0; ch < ch_total; ch++)
                  {
                     ProtoNode* node = cell.ChildElementAt(ch);
                     ENUM_ELEMENT_TYPE type = node.TypeElement();
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
                  //profit.BorderColor(clrBlack);
                  nline.Add(profit);
                  continue;
               }
               //Комментарий
               if(cell.ShortName() == name_comment)
               {
                  Label* comment = new Label("DealComment", nline);
                  comment.BindingWidth(cell);
                  //comment.OptimalWidth(ow_profit);
                  comment.Edit(true);
                  comment.Text("");
                  comment.BackgroundColor(cell.BackgroundColor());
                  comment.BorderColor(cell.BorderColor());
                  //comment.BorderColor(clrBlack);
                  nline.Add(comment);
                  continue;
               }
               
            }
            //int m_total = nline.ChildsTotal();
            //for(int el = 0; el < m_total; el++)
            //{
            //   ;
            //}
            //int n = event.NLine();
            workArea.Add(nline, event.NLine()+1);
         }
      }
      
      CArrayObj* ListPos;
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