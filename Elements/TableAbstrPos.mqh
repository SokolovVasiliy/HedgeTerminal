
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
      virtual Label* AddCollapseEl(TableDirective* tDir, CElement* el)
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
      /// Возвращает элемент визуального представления магического номера. Конкретный тип элемента, определяется
      /// на основании свойст таблицы переданных в классе tDir.
      /// \param tDir - Описывает свойства таблицы и конкретного элемента, который необходимо создать.
      ///
      virtual TextNode* AddMagicEl(TableDirective* tDir, CElement* el)
      {
         TextNode* textMagic = NULL;
         if(tDir.TableElement() == TABLE_HEADER)
            textMagic = new Button(el.Name(), GetPointer(this));
         else
            textMagic = new Label(el.Name(), GetPointer(this));
         textMagic.OptimalWidth(el.OptimalWidth());
         //Для сделок используем дополнительные настройки визуализации.
         if(tDir.TableElement() == TABLE_DEAL)
            SetForDeal(textMagic);
         Add(textMagic);
         return textMagic;
      }
      ///
      /// Возвращает элемент визуального представления названия инструмента. Конкретный тип элемента, определяется
      /// на основании свойст таблицы переданных в классе tDir.
      /// \param tDir - Описывает свойства таблицы и конкретного элемента, который необходимо создать.
      ///
      virtual TextNode* AddSymbolEl(TableDirective* tDir, CElement* el)
      {
         TextNode* textMagic = NULL;
         if(tDir.TableElement() == TABLE_HEADER)
            textMagic = new Button(el.Name(), GetPointer(this));
         else
            textMagic = new Label(el.Name(), GetPointer(this));
         textMagic.OptimalWidth(el.OptimalWidth());
         //Для сделок используем дополнительные настройки визуализации.
         if(tDir.TableElement() == TABLE_DEAL)
            SetForDeal(textMagic);
         Add(textMagic);
         return textMagic;
      }
   private:
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
      
      virtual Label* AddCollapseEl(TableDirective* tDir, CElement* el)
      {
         Label* lbl = AbstractPos::AddCollapseEl(tDir, el);
         if(lbl == NULL || lbl.TypeElement() != ELEMENT_TYPE_TREE_BORDER)return lbl;
         TreeViewBoxBorder* twb = lbl;
         CellCollapsePos(twb);
         return twb;
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

