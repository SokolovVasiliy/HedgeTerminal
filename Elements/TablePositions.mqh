#include "..\Settings.mqh"
#include <Arrays\ArrayInt.mqh>
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
         if(event.EventId() == EVENT_DEL_POS)
         {
            //Добавляем в список;
         }
         else
         {
            //Иначе проверяем список. И если он есть;
         }
         switch(event.EventId())
         {
            case EVENT_CREATE_NEWPOS:
               AddPosition(event);
               break;
            case EVENT_REFRESH:
               RefreshPrices();
               break;
            case EVENT_REFRESH_POS:
               OnRefreshPos(event);
            case EVENT_CHECK_BOX_CHANGED:
               OnCheckBoxChanged(event);
               break;
            case EVENT_COLLAPSE_TREE:
               OnCollapse(event);
               break;
            case EVENT_NODE_CLICK:
               OnNodeClick(event);
               break;
            //case EVENT_DEL_POS:
            //   OnDelPos(event);
            //   break;
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
         // Каждая линия - специальный тип, знающий, какие именно элементы нужно в себя добавлять.
         AbstractPos* posLine = lineHeader;
         tDir.TableElement(TABLE_HEADER);
         int index = -1;
         //Заменяем через хук заголовок на другой, поддерживающий методы AbstractPos
         //Находим индекс старого заголовка.
         for(int i = 0; i < ChildsTotal(); i++)
         {
            ProtoNode* node = ChildElementAt(i);
            if(lineHeader == node){
               index = i;
               break;
            }
         }
         //Заменяем его на новый
         if(index != -1)
         {
            childNodes.Delete(index);
            lineHeader = CreateLine(GetPointer(this), GetPointer(tDir), NULL);
            childNodes.Insert(lineHeader, index);
         }
      }
      
      ///
      /// Обработчик события "трал для позиции включен".
      ///
      void OnCheckBoxChanged(EventCheckBoxChanged* event)
      {
         ProtoNode* node = event.Node();
         if(node.TypeElement() != ELEMENT_TYPE_CHECK_BOX)return;
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
         // Определяем имя ячейки отвечающей за трал, если оно еще не определено.
         if(name_tralSl == NULL)
         {
            CArrayObj* columns = Settings.GetSetForActiveTable();
            for(int i = 0; i < columns.Total(); i++)
            {
               DefColumn* dcol = columns.At(i);
               if(dcol.ColumnType() == COLUMN_TRAL)
               {
                  name_tralSl = dcol.Name();
                  break;
               }
            }
         }
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
      /// Обрабатываем комманду на закрытие позиции.
      ///
      void OnClosePos(EventClosePos* event)
      {
         ;
      }
      ///
      /// Обновляет цены открытых позиций.
      ///
      void RefreshPrices()
      {
         if(tDir.TableType() == TABLE_POSHISTORY)return;
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
               
               TextNode* lastPrice = posLine.CellLastPrice();
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
      /// Обновляет все свойства позиции
      ///
      void OnRefreshPos(EventRefreshPos* event)
      {
         //Для начала нужно найти визуальное представление позиции, которую требуется обновить
         Position* npos = event.Position();
         if(!IsItForMe(npos))return;
         int n = npos.NPos();
         //Позиция есть в списке?
         if(n > 0)
         {
            ProtoNode* node = workArea.ChildElementAt(n);
            if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
            PosLine* pline = node;
            //Получаем список колонок, которые надо сгенерировать.
            /*CArrayObj* columns = NULL;
            switch(tDir.TableType())
            {
               case TABLE_POSACTIVE:
                  columns = Settings.GetSetForActiveTable();
                  break;
               case TABLE_POSHISTORY:
                  columns = Settings.GetSetForHistoryTable();
                  break;
               default:
                  //Если тип таблицы неизвестен, то и генерировать нечего.
                  return; 
            }
            int total = pline.ChildsTotal();
            if(total != columns.Total())return;
            for(int i = 0; i < total; i++)
            {
               DefColumn* el = columns.At(i);
               ENUM_COLUMN_TYPE colType = el.ColumnType();
               TextNode* node
               LineBuilder(tDir.TableType(), 
            }*/
         }
      }
      ///
      /// Создает визуальное представление строки, которая отображает: заголовок таблицы позиций, или
      /// саму позицию или сделку, связанную с позицией. После того, как строка представления будет 
      /// создана, она будет возвращена вызывающему методу.
      ///
      Line* CreateLine(ProtoNode* parNode, TableDirective* sDir, Position* pos, Deal* entryDeal=NULL, Deal* exitDeal=NULL)
      {
         AbstractPos* posLine = NULL;
         
         //Получаем указатель на tDir
         TableDirective* pDir = GetPointer(sDir);
         ENUM_TABLE_TYPE elType = pDir.TableType();
         
         //Получаем список колонок, которые надо сгенерировать.
         CArrayObj* columns = NULL;
         switch(pDir.TableType())
         {
            case TABLE_POSACTIVE:
               columns = Settings.GetSetForActiveTable();
               break;
            case TABLE_POSHISTORY:
               columns = Settings.GetSetForHistoryTable();
               break;
            default:
               //Если тип таблицы неизвестен, то и генерировать нечего.
               return posLine; 
         }
         //Определяем какой тип линии будем использовать.
         switch(pDir.TableElement())
         {
            case TABLE_HEADER:
               posLine = new PosLine(GetPointer(parNode), ELEMENT_TYPE_TABLE_HEADER_POS, pos);
               break;
            case TABLE_POSITION:
               posLine = new PosLine(GetPointer(parNode), pos);
               break;
            case TABLE_DEAL:
               posLine = new DealLine(GetPointer(parNode), entryDeal, exitDeal);
               break;
            default:
               //Если тип строки неизвестен, то и сгенерировать ее мы не можем.
               return posLine;
         }
         //Формируем линию.
         int total = columns.Total();
         for(int i = 0; i < total; i++)
         {
            //Элемент, значения которого мы определим
            TextNode* element = NULL;
            DefColumn* el = columns.At(i);
            ENUM_COLUMN_TYPE el_Type = el.ColumnType();
            if(el_Type == COLUMN_COLLAPSE)
               element = posLine.AddCollapseEl(pDir, el);
            else if(el_Type == COLUMN_TRAL)
               element = posLine.AddTralEl(pDir, el);
            else if(el_Type == COLUMN_CURRENT_PRICE)
               element = posLine.AddLastPrice(pDir, el);
            else if(el_Type == COLUMN_PROFIT && pDir.TableElement() == TABLE_POSITION &&
               pDir.TableType() == TABLE_POSACTIVE)
               element = posLine.AddProfitEl(pDir, el);
            else if(el_Type == COLUMN_PROFIT && pDir.TableElement() == TABLE_DEAL &&
               pDir.TableType() == TABLE_POSACTIVE)
               element = posLine.AddProfitDealEl(pDir, el);
            else
               element = posLine.AddDefaultEl(pDir, el);
            //Теперь, когда элемент получен, осталось его заполнить.
            if(element != NULL && pos != NULL)
               LineBuilder(pDir.TableElement(), element, el, pos, entryDeal, exitDeal);
            //Заголовок таблицы окрашиваем в более темный цвет.
            if(element != NULL && pDir.TableElement() == TABLE_HEADER)
               element.BackgroundColor(Settings.ColorTheme.GetSystemColor());
            
         }
         return posLine;
      }
      void LineBuilder(ENUM_TABLE_TYPE_ELEMENT elType, TextNode* element, DefColumn* el, Position* pos, Deal* entryDeal=NULL, Deal* exitDeal=NULL)
      {
         //Информация о позиции должна быть всегда
         if(pos == NULL) return;
         switch(el.ColumnType())
         {
            case COLUMN_MAGIC:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text((string)pos.Magic());
               break;
            case COLUMN_SYMBOL:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.Symbol());
               break;
            case COLUMN_ENTRY_ORDER_ID:
               if(elType == TABLE_POSITION)
                  element.Text((string)pos.EntryOrderID());
               if(elType == TABLE_DEAL && entryDeal != NULL)
                  element.Text((string)entryDeal.Ticket());
               break;
            case COLUMN_EXIT_ORDER_ID:
               if(elType == TABLE_POSITION)
                  element.Text((string)pos.ExitOrderID());
               if(elType == TABLE_DEAL && exitDeal != NULL)
                  element.Text((string)exitDeal.Ticket());
               break;
            case COLUMN_EXIT_MAGIC:
               if(elType == TABLE_POSITION)
                  element.Text((string)pos.ExitMagic());
                  break;
            case COLUMN_ENTRY_DATE:
               if(elType == TABLE_POSITION)
               {
                  CTime* ctime = pos.EntryExecutedDate();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
                  delete ctime;
               }
               if(elType == TABLE_DEAL && entryDeal != NULL)
               {
                  CTime* ctime = entryDeal.Date();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
                  delete ctime;
               }
               break;
            case COLUMN_EXIT_DATE:
               if(elType == TABLE_POSITION)
               {
                  CTime* ctime = pos.ExitExecutedDate();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
                  delete ctime;
               }
               if(elType == TABLE_DEAL && exitDeal != NULL)
               {
                  CTime* ctime = exitDeal.Date();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
                  delete ctime;
               }
               break;
            case COLUMN_TYPE:
               if(elType == TABLE_POSITION)
                  element.Text(pos.PositionTypeAsString());
               //if(elType == TABLE_DEAL && entryDeal != NULL)
               //   element.Text(entryDeal.DealTypeAsString());
               if(elType == TABLE_DEAL)
                  element.Text("-");
               break;
            case COLUMN_VOLUME:
               if(elType == TABLE_POSITION)
                  element.Text(pos.VolumeToString(pos.VolumeExecuted()));
               if(elType == TABLE_DEAL && entryDeal != NULL)
                  element.Text(entryDeal.VolumeToString(entryDeal.VolumeExecuted()));
               break;
            case COLUMN_ENTRY_PRICE:
               if(elType == TABLE_POSITION && pos.PositionStatus() == POSITION_STATUS_PENDING)
                  element.Text(pos.PriceToString(pos.EntryPricePlaced()));
               else if(elType == TABLE_POSITION)
                  element.Text(pos.PriceToString(pos.EntryPriceExecuted()));
               else if(elType == TABLE_DEAL && entryDeal != NULL)
                  element.Text(entryDeal.PriceToString(entryDeal.EntryPriceExecuted()));
               break;
            case COLUMN_SL:
               if(elType == TABLE_POSITION/* || elType == TABLE_DEAL*/)
                  element.Text(pos.PriceToString(pos.StopLossLevel()));
               if(elType == TABLE_DEAL)
                  element.Text("-");   
               break;
            case COLUMN_TP:
               if(elType == TABLE_POSITION/* || elType == TABLE_DEAL*/)
                  element.Text(pos.PriceToString(pos.TakeProfitLevel()));
               if(elType == TABLE_DEAL)
                  element.Text("-");
               break;
            case COLUMN_TRAL:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
               {
                  if(pos.UsingStopLoss())
                     element.Text(CharToString(254));
                  else
                     element.Text(CharToString(168));
               }
               if(elType == TABLE_POSITION)
                  element.FontSize(12);
               if(elType == TABLE_DEAL)
               {
                  element.FontSize(11);
                  element.FontColor(clrSlateGray);
               }
               break;
            case COLUMN_EXIT_PRICE:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.PriceToString(pos.ExitPriceExecuted()));
               break;
            case COLUMN_CURRENT_PRICE:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.PriceToString(pos.CurrentPrice()));
               break;
            case COLUMN_PROFIT:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.ProfitAsString());
               break;
            case COLUMN_ENTRY_COMMENT:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.EntryComment());
               break;
            case COLUMN_EXIT_COMMENT:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.ExitComment());
               break;
         }
      }
      ///
      /// Добавляем новую созданную таблицу, либо раскрывает позицию
      ///
      void AddPosition(EventCreatePos* event)
      {
         
         Position* pos = event.GetPosition();
         if(!IsItForMe(pos))return;
         //Добавляем только активные позиции.
         //if(pos.Status == POSITION_STATUS_CLOSED)return;
         tDir.TableElement(TABLE_POSITION);
         PosLine* nline = CreateLine(workArea, GetPointer(tDir), pos);
         workArea.Add(nline);
         pos.NPos(workArea.ChildsTotal()-1);
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
         if(entryTotal > 0 && entryTotal >= exitTotal)
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
            Line* nline = CreateLine(workArea, GetPointer(tDir), pos, entryDeal, exitDeal);
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
      ///
      /// Возвращает истину, если текущая позиция относится к текущему контексту таблицы.
      ///
      bool IsItForMe(Position* pos)
      {
         bool rs = (pos.PositionStatus() == POSITION_STATUS_OPEN && tDir.TableType() == TABLE_POSACTIVE) ||
                   (pos.PositionStatus() == POSITION_STATUS_CLOSED && tDir.TableType() == TABLE_POSHISTORY);
         return rs;
      }
      string name_tralSl;
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
      ///
      /// Структура, содержащая определенные флаги и доп. информацию, определяющую
      /// последовательность действий при удалении позиции.
      ///
      struct STarget
      {
         public:
            ///
            /// Возвращает истину, если выполнение функции нажатия кнопки "закрытие позиции" завершено.
            ///
            bool ExecutionComplete();
            ///
            /// Возвращает идентификатор ордера, который необходимо закрыть.
            ///
            int OrderId();
         private:
            bool contextBusy;
            int orderId;
      };
};


 