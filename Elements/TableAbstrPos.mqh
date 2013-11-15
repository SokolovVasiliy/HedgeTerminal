
#ifndef NODE_MQH
   #include "Node.mqh"
#endif
#ifndef SETTINGS_MQH
   #include "..\Settings.mqh"
#endif 

#ifndef TABLE_ABSTRPOS_MQH
   #define TABLE_ABSTRPOS_MQH
#endif

#ifndef TABLE_POSITIONS_MQH
   class TablePositions;
#endif

#ifndef TABLE_DIRECTIVE_MQH
   #include "TableDirective.mqh"
#endif
//class TablePositions;

///
/// Содержит общие свойства и методы позиций и сделок для графического представления.
///
class AbstractPos : public Line
{
   public:
      AbstractPos(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode) : Line(myName, elType, parNode){;}
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
      
      ///
      /// Возвращает элемент визуальной позиции раскрытие/закрытие списка. Конкретный тип элемента, определяется
      /// на основании свойст таблицы переданных в классе tDir.
      /// \param tDir - Описывает свойства таблицы и конкретного элемента, который необходимо создать.
      ///
      virtual Label* AddCollapseEl(TableDirective* tDir, DefColumn* el)
      {
         Label* tbox = NULL;
         string sname = el.Name();
         // Если элемент генерируется для таблицы не отображающей позиции, то мы не знаем, какой конкретный элемент нужен,
         // поэтому генерируем заглушку с текстом +.
         if(!tDir.IsPositionTable())
         {
            tbox = new Label(sname, GetPointer(this));
            tbox.Text("+");
         }
         //Нужно сгенерировать элемент для заголовка таблицы?
         else if(tDir.TableElement() == TABLE_HEADER)
         {
            tbox = new TreeViewBox(sname, GetPointer(this), BOX_TREE_GENERAL);
            tbox.Text("+");
         }
         //Нужно сгенерировать элемент для позициции?
         else if(tDir.TableElement() == TABLE_POSITION)
            tbox = new TreeViewBoxBorder(sname, GetPointer(this), BOX_TREE_GENERAL);
         //Нужно сгенерировать элемент для сделки?
         else if(tDir.TableElement() == TABLE_DEAL)
         {
            //последний элемент завершается значком ENDSLAVE?
            ENUM_BOX_TREE_TYPE b_type = tDir.IsLastDeal() ? BOX_TREE_ENDSLAVE : BOX_TREE_SLAVE;
            tbox = new TreeViewBox(sname, GetPointer(this), b_type); 
         }
         // Устанавливаем оставшиеся свойства.
         if(tbox != NULL)
         {
            tbox.OptimalWidth(el.OptimalWidth());
            tbox.ConstWidth(el.ConstWidth());
            Add(tbox);
         }
         return tbox;
      }
      ///
      /// Возвращает элемент визуальной позиции трал стоп-лосса. Конкретный тип элемента, определяется
      /// на основании свойст таблицы переданных в классе tDir.
      /// \param tDir - Описывает свойства таблицы и конкретного элемента, который необходимо создать.
      ///
      virtual TextNode* AddTralEl(TableDirective* tDir, DefColumn* el)
      {
         TextNode* build = NULL;
         if(tDir.TableElement() == TABLE_HEADER)
         {
            build = new Button(el.Name(), GetPointer(this));
            build.Text(CharToString(79));
         }
         else if(tDir.TableElement() == TABLE_POSITION)
            build = new CheckBox(el.Name(), GetPointer(this));
         else/* if(tDir.TableElement() == TABLE_DEAL)*/
            build = new Label(el.Name(), GetPointer(this));
         if(tDir.TableElement() != TABLE_HEADER)
            build.Text(CharToString(168));   
         build.Font("Wingdings");
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         Add(build);
         return build;
      }
      virtual TextNode* AddProfitEl(TableDirective* tDir, DefColumn* el)
      {
         Line* comby = NULL;
         if(tDir.TableType() == TABLE_POSACTIVE)
         {
            Line* comby = new Line(el.Name(), GetPointer(this));
            comby.AlignType(LINE_ALIGN_CELLBUTTON);
            Label* profit = new Label(el.Name(), GetPointer(this));
            ButtonClosePos* btnClose = new ButtonClosePos("btnClosePos.", comby);
            btnClose.Font("Wingdings");
            btnClose.FontSize(12);
            btnClose.Text(CharToString(251));
            comby.Add(profit);
            comby.Add(btnClose);
            comby.OptimalWidth(el.OptimalWidth());
            comby.ConstWidth(el.ConstWidth());
         }
         return comby;
         /*Line* comby = new Line(name_profit, GetPointer(nline));
         //      comby.BindingWidth(node);
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
           */
      }
      ///
      /// Добавляет елемент по-умолчанию в список, и возвращает ссылку на него.
      ///
      TextNode* AddDefaultEl(TableDirective* tDir, DefColumn* el)
      {
         TextNode* build = DefaultBuilder(tDir, el);
         Add(build);
         return build;
      }
      
   private:
      ///
      /// Создает элемент таблицы, на основании информации о таблице и настройках текущего элемента.
      ///
      TextNode* DefaultBuilder(TableDirective* tDir, DefColumn* el)
      {
         TextNode* build = NULL;
         if(tDir.TableElement() == TABLE_HEADER)
            build = new Button(el.Name(), GetPointer(this));
         else
            build = new Label(el.Name(), GetPointer(this));
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         //Для сделок используем дополнительные настройки визуализации.
         if(tDir.TableElement() == TABLE_DEAL)
            SetForDeal(build);
         return build;
      }
      ///
      /// Устанавливает дополнительные настройки для элементов, отображающие сделки.
      ///
      void SetForDeal(TextNode* node)
      {
         node.FontSize(9);
      }
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
      
      virtual Label* AddCollapseEl(TableDirective* tDir, DefColumn* el)
      {
         Label* lbl = AbstractPos::AddCollapseEl(tDir, el);
         if(lbl == NULL || lbl.TypeElement() != ELEMENT_TYPE_TREE_BORDER)return lbl;
         TreeViewBoxBorder* twb = lbl;
         CellCollapsePos(twb);
         return twb;
      }
      virtual TextNode* AddTralEl(TableDirective* tDir, DefColumn* el)
      {
         TextNode* build = AbstractPos::AddTralEl(tDir, el);
         if(build != NULL && build.TypeElement() != ELEMENT_TYPE_CHECK_BOX)
            return build;
         CheckBox* cbox = build;
         CellTral(cbox);
         return build;
      }
      
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
      ///
      /// 
      ///
      /*virtual TextNode* AddMagicEl(TableDirective* tDir)
      {
         TextNode* node = AbstractPos::AddMagicEl(tDir);
         //Линия
         node.FontSize(9);
      }*/
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

