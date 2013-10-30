#include "..\API\Position.mqh"
#include "..\Events.mqh"
#include "Node.mqh"
#include "Button.mqh"
#include "TreeViewBox.mqh"
#include "Line.mqh"
#include "Label.mqh"
#include "Scroll.mqh"
#include "TableWork.mqh"
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
      Table(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_TABLE, myName, parNode)
      {
         highLine = 20;
         lineHeader = new Line("Header", ELEMENT_TYPE_TABLE_HEADER, GetPointer(this));
         workArea = new CWorkArea(GetPointer(this));
         workArea.Edit(true);
         workArea.Text("");
         workArea.BorderColor(BackgroundColor());
         
         scroll = new Scroll("Scroll", GetPointer(this));
         scroll.BorderType(BORDER_FLAT);
         scroll.BorderColor(clrBlack);
         
         childNodes.Add(lineHeader);
         childNodes.Add(workArea);
         childNodes.Add(scroll);
      }
      ///
      /// Возвращает общую высоту всех линий в таблице.
      ///
      long LinesHighTotal()
      {
         return workArea.LinesHighTotal();
      }
      ///
      /// Возвращает общую высоту всех видимых линий в таблице.
      ///
      long LinesHighVisible()
      {
         return workArea.LinesHighVisible();
      }
      ///
      /// Возвращает общее количество всех строк в таблице, в т.ч. за
      /// находящимися за пределами окна.
      ///
      int LinesTotal()
      {
         return workArea.ChildsTotal();
      }
      
      ///
      /// Возвращает количество строк, отображаемых в текущий момент в
      /// окне таблице.
      ///
      int LinesVisible()
      {
         if(workArea != NULL)
            return workArea.LinesVisible();
         return 0;
      }
      ///
      /// Возвращает индекс первой видимой строки.
      ///
      int LineVisibleFirst()
      {
         if(workArea != NULL)
            return workArea.LineVisibleFirst();
         return -1;
      }
      ///
      /// Задает индекс первой видимой строки.
      ///
      void LineVisibleFirst(int index)
      {
         workArea.LineVisibleFirst(index);
      }
      ///
      /// Задает индекс первой видимой строки.
      ///
      void LineVisibleFirst1(int index)
      {
         workArea.LineVisibleFirst(index);
      }
      ///
      /// Алгоритм размещения заголовка таблицы.
      ///
      void AllocationHeader()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 1, 2, Width()-24, 20);
         lineHeader.Event(command);
         delete command;
      }
      ///
      /// Алгоритм размещения рабочей области таблицы.
      ///
      void AllocationWorkTable()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 1, 22, Width()-24, High()-24);
         workArea.Event(command);
         delete command;
      }
      ///
      /// Алгоритм размещения скролла таблицы.
      ///
      void AllocationScroll()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(),Width()-22, 2, 20, High()-4);
         scroll.Event(command);
         delete command;
      }
   protected:
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
         AllocationHeader();
         //Размещаем рабочую область.
         AllocationWorkTable();
         //Размещаем скролл.
         AllocationScroll();
      }
      
      ///
      /// Ширина линии.
      ///
      int highLine;
      
};
class PosLine;
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
         name_entryOrderId = "Order ID";
         name_entry_date = "EntryDate";
         name_type = "Type";
         name_vol = "Vol.";
         name_price = "Price";
         name_sl = "S/L";
         name_tp = "T/P";
         name_currprice = "Last Price";
         name_profit = "Profit";
         name_comment = "Comment";
         
         //ListPos = new CArrayObj();
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
            Button* hOrderId = new Button(name_entryOrderId, GetPointer(lineHeader));
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
            ProtoNode* node = workArea.ChildElementAt(i);
            if(node.TypeElement() != ELEMENT_TYPE_DEAL)break;
            DealLine* deal = node;
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
               ProtoNode* node = workArea.ChildElementAt(i);
               if(node.TypeElement() == ELEMENT_TYPE_POSITION)
               {
                  PosLine* pos = node;
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
            //Скролл реагирует на разворачивания списка
            AllocationScroll();
         }
         //Требуется развернуть/свернуть все позиции?
         if(type == ELEMENT_TYPE_TABLE_HEADER)
         {
            // Сворачиваем весь список.
            if(event.IsCollapse())
               CollapseAll();
            // Разворачиваем весь список.
            else RestoreAll();
            //Скролл реагирует на разворачивания списка
            AllocationScroll();
         }      
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
            if(twb != NULL && twb.State() != BOX_TREE_COLLAPSE)continue;
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
         CArrayObj* deals = pos.EntryDeals();
         for(int i = 0; i < total; i++)
         {
            bool isReadOnly = true;
            ProtoNode* node = lineHeader.ChildElementAt(i);
            
            if(node.ShortName() == name_collapse_pos)
            {
               //TreeViewBox* twb = new TreeViewBox(name_collapse_pos, GetPointer(nline), BOX_TREE_GENERAL);
               TreeViewBoxBorder* twb = new TreeViewBoxBorder(name_collapse_pos, GetPointer(nline), BOX_TREE_GENERAL);
               twb.OptimalWidth(20);
               twb.ConstWidth(true);
               twb.BackgroundColor(clrWhite);
               twb.BorderColor(clrWhiteSmoke);
               nline.Add(twb);
               nline.CellCollapsePos(twb);
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
            else if(node.ShortName() == name_entryOrderId)
            {
               cell = new Label(name_entryOrderId, GetPointer(nline));
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
               nline.CellTral(btnTralSL);
               continue;
            }
            else if(node.ShortName() == name_currprice)
            {
               cell = new Label(name_currprice, GetPointer(nline));
               nline.CellLastPrice(cell);
               int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(pos.CurrentPrice(), digits);
               cell.Text(price);
               nline.CellLastPrice(cell);
            }
            
            else if(node.ShortName() == name_profit)
            {
               Line* comby = new Line(name_profit, GetPointer(nline));
               comby.BindingWidth(node);
               comby.AlignType(LINE_ALIGN_CELLBUTTON);
               cell = new Label(name_profit, comby);
               //nline.CellProfit(cell);
               cell.Text(pos.ProfitAsString());
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.Edit(true);
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
         //Что бы новая позиция тут же отобразилась в таблице активных позиций
         //уведомляем родительский элемент, что необходимо сделать refresh
         EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
         EventSend(er);
         delete er;
      }
      ///
      /// Содержит общие свойства и методы позиций и сделок для графического представления.
      ///
      class AbstractPos : public Line
      {
         public:
            ///
            /// Устанавливает ссылку на ячейку строки, отображающую последнюю цену инструмента,
            /// по которому открыта позиция / совершена сделка.
            ///
            void CellLastPrice(Label* label){cellLastPrice = label;}
            ///
            /// Возвращает ячейку, отображающую последнюю цену позиции.
            ///
            Label* CellLastPrice(){return cellLastPrice;}
            ///
            /// Устанавливает ссылку на ячейку строки, отображающую профит.
            ///
            void CellProfit(Label* profit)
            {
               cellProfit = profit;
            }
            ///
            /// Возвращает ссылку на ячейку, отображающую профит.
            ///
            Label* CellProfit(){return cellProfit;}
            
            AbstractPos(string nameEl, ENUM_ELEMENT_TYPE el_type, ProtoNode* parNode) : Line(nameEl, el_type, parNode){;}           
         private:
            ///
            /// Указатель на ячейку, отображающую последнюю цену инструмента, по которому открыта позиция/сделка.
            ///
            Label* cellLastPrice;
            ///
            /// Указатель на ячейку, отображающую профит позиции/сделки.
            ///
            Label* cellProfit;
            
      };
      ///
      /// Графическое представление позиции
      ///
      class PosLine : public AbstractPos
      {
         public:
            PosLine(ProtoNode* parNode, Position* pos) : AbstractPos("Position", ELEMENT_TYPE_POSITION, parNode)
            {
               //Связываем графическое представление позиции с конкретной позицией.
               position = pos;
            }
            ///
            /// Возвращает позицию, чье графическое представление реализует текущий экземпляр.
            ///
            Position* Position(){return position;}
            ///
            /// Возвращает флаг указываютщий, является ли текущая позиция развернутой (true)
            /// или свернутой.
            ///
            bool IsRestore(){return isRestore;}
            ///
            /// Устанавливает флаг указывающий, является ли текущая позиция развернутой (true)
            /// или свернутой.
            ///
            void IsRestore(bool status){isRestore = status;}
            ///
            /// Возвращает ссылку на кнопку раскрытия позиции.
            ///
            TreeViewBoxBorder* CellCollapsePos(){return collapsePos;}
            ///
            /// Устанавливает ссылку на ячейку расскрытия позиции
            ///
            void CellCollapsePos(TreeViewBoxBorder* collapse){collapsePos = collapse;}
            ///
            /// Устанавливает указатель на ячейку отображающую кнопку влкючения/выключения трала.
            ///
            void CellTral(CheckBox* tral){cellTral = tral;}
            ///
            /// Возвращает указатель на ячейку отображающую кнопку включения/выключения трала.
            ///
            CheckBox* CellTral(){return cellTral;}
         private:
            ///
            /// Указатель на раскрывающую кнопку позиции.
            ///
            TreeViewBoxBorder* collapsePos;
            ///
            /// Указатель на позицию, чье графическое представление реализует текущий экземпляр.
            ///
            Position* position;
            ///
            /// Истина, если позиция имеет развернутое графическое представление
            /// (показываются также сделки), ложь - в противном случе.
            ///
            bool isRestore;
            ///
            /// Указатель на ячейку, отображающую трал для позиции/сделки.
            ///
            CheckBox* cellTral;
      };
      ///
      /// Графическое представление трейда
      ///
      class DealLine : public AbstractPos
      {
         public:
            DealLine(ProtoNode* parNode, Deal* EntryDeal, Deal* ExitDeal) : AbstractPos("Deal", ELEMENT_TYPE_DEAL, parNode)
            {
               //Связываем графическое представление трейда с конкретной позицией.
               entryDeal = EntryDeal;
               exitDeal = ExitDeal;
            }
            ///
            /// Возвращает Указатель на трейд инициализирующий позицию.
            ///
            Deal* EntryDeal(){return entryDeal;}
            ///
            /// Возвращает указатель на трейд закрывающий позицию.
            ///
            Deal* ExitDeal(){return exitDeal;}
            ///
            /// Устанавливает указатель на ячейку, показывающую статус трала.
            ///
            void CellTral(Label* tral){cellTral = tral;}
            ///
            /// Возвращает указатель на ячейку, указывающую на статус трала.
            ///
            Label* CellTral(){return cellTral;}
            
         private:
            ///
            /// Указатель на трейд инициализирующий позицию, чье графическое представление реализует текущий экземпляр.
            ///
            Deal* entryDeal;
            ///
            /// Указатель на трейд закрывающий позицию, чье графическое представление реализует текущий экземпляр.
            ///
            Deal* exitDeal;
            ///
            /// Указатель на метку, указывающиую, используется ли трал для сделки.
            ///
            Label* cellTral;
      };
      ///
      /// Добавляет визуализацию сделок для позиции
      ///
      void AddDeals(EventCollapseTree* event)
      {
         ProtoNode* node = event.Node();
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
                  nline.Add(twb);
                  continue;
               }
               //Magic номер сделки
               if(cell.ShortName() == name_magic)
               {
                  Label* magic = new Label("deal magic", nline);
                  magic.FontSize(fontSize);
                  Label* lcell = cell;
                  magic.Edit(true);
                  magic.BindingWidth(cell);
                  //magic.Font("Wingdings");
                  //magic.Text(CharToString(225));
                  //magic.FontColor(clrSlave);
                  magic.Text(lcell.Text());
                  magic.BackgroundColor(cell.BackgroundColor());
                  magic.BorderColor(cell.BorderColor());
                  nline.Add(magic);
                  continue;
               }
               //Инструмент, по которому совершена сделка.
               if(cell.ShortName() == name_symbol)
               {
                  Label* symbol = new Label("deal symbol", nline);
                  symbol.FontSize(fontSize);
                  Label* lcell = cell;
                  symbol.Edit(true);
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
               if(cell.ShortName() == name_entryOrderId)
               {
                  Label* entry_id = new Label("EntryDealsID", nline);
                  entry_id.FontSize(fontSize);
                  Label* lcell = cell;
                  entry_id.Edit(true);
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
               if(cell.ShortName() == name_entry_date)
               {
                  Label* entryDate = new Label("EntryDealsTime", nline);
                  entryDate.FontSize(fontSize);
                  entryDate.Edit(true);
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
               if(cell.ShortName() == name_type)
               {
                  Label* entryType = new Label("EntryDealsType", nline);
                  entryType.FontSize(fontSize);
                  entryType.Edit(true);
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
               if(cell.ShortName() == name_vol)
               {
                  Label* dealVol = new Label("EntryDealsVol", nline);
                  dealVol.FontSize(fontSize);
                  dealVol.Edit(true);
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
               if(cell.ShortName() == name_price)
               {
                  Label* entryPrice = new Label("DealEntryPrice", nline);
                  entryPrice.FontSize(fontSize);
                  entryPrice.Edit(true);
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
               if(cell.ShortName() == name_sl)
               {
                  Label* sl = new Label("DealStopLoss", nline);
                  sl.FontSize(fontSize);
                  Label* lcell = cell;
                  sl.Edit(true);
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
               if(cell.ShortName() == name_tp)
               {
                  Label* tp = new Label("DealTakeProfit", nline);
                  tp.FontSize(fontSize);
                  Label* lcell = cell;
                  tp.Edit(true);
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
               if(cell.ShortName() == name_tralSl)
               {
                  
                  Label* tral = new Label("DealTralSL", nline);
                  tral.FontSize(fontSize);
                  tral.Edit(true);
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
               if(cell.ShortName() == name_currprice)
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
                  profit.Edit(true);   
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
               if(cell.ShortName() == name_comment)
               {
                  Label* comment = new Label("DealComment", nline);
                  comment.FontSize(fontSize);
                  comment.BindingWidth(cell);
                  comment.Edit(true);
                  comment.Text("");
                  comment.BackgroundColor(cell.BackgroundColor());
                  comment.BorderColor(cell.BorderColor());
                  nline.Add(comment);
                  continue;
               }
               
            }
            int m_total = nline.ChildsTotal();
            /*for(int el = 0; el < m_total; el++)
            {
               Label* label = nline.ChildElementAt(el);
               label.FontColor(clrDimGray);
            }*/
            int n = event.NLine();
            workArea.Add(nline, event.NLine()+1);
         }
         posLine.IsRestore(true);
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
      string name_collapse_pos;
      string name_magic;
      string name_symbol;
      string name_entryOrderId;
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