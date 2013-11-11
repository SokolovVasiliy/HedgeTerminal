#define TABLEABSTRPOS_MQH
#ifndef NODE_MQH
   #include "Node.mqh"
#endif
#ifndef SETTINGS_MQH
   #include "..\Settings.mqh"
#endif 

#define THEADER 1
#define TPOSITION 2
#define TDEAL 4
#define TACTIVE 8
#define THISTORY 16

//#include "Table.mqh"
class Table;
class TablePositions;

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
      ///
      /// По-умолчанию, возвращает элемент визуальной позиции раскрытие/закрытие списка для заголовка таблицы.
      /// \param parTable - Родительская таблица.
      /// \param isLastDeal - Истина, если сделка, которую требуется отобразить занимает последнюю строку в раскрывающем списке.
      ///
      virtual Label* GetCollapseEl(int mode, bool isLastDeal = false)
      {
         Label* tbox = NULL;
         Settings* set = Settings::GetSettings();
         //Заголовок "Раскрыть/скрыть все сделки". Присутствует всегда.
         if((mode & THEADER) == THEADER)
         {
            tbox = new TreeViewBox(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_GENERAL);
            tbox.Text("+");
         }
         else if((mode & TPOSITION) == TPOSITION)
            tbox = new TreeViewBoxBorder(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_GENERAL);
         
         else if((mode & TDEAL) == TDEAL)
         {
            //последний элемент завершается значком ENDSLAVE
            if(isLastDeal)
               tbox = new TreeViewBox(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_ENDSLAVE);
            else
               tbox = new TreeViewBox(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_SLAVE); 
         }
         if(tbox != NULL)
         {
            tbox.OptimalWidth(20);
            tbox.ConstWidth(true);
            tbox.BackgroundColor(clrWhite);
            tbox.BorderColor(clrWhiteSmoke);
            Add(tbox);
         }
         return tbox;
      }
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
      
      virtual void GetCollapseEl(TablePositions* table, ENUM_BOX_TREE_TYPE state)
      {
         //AbstractPos::GetCollapseEl(table, state);
      }
      
      virtual Label* GetCollapseEl(int mode, bool isLastDeal = false)
      {
         Label* lbl = AbstractPos::GetCollapseEl(mode);
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

