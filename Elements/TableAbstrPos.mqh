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
/// �������� ����� �������� � ������ ������� � ������ ��� ������������ �������������.
///
class AbstractPos : public Line
{
   public:
      ///
      /// ������������� ������ �� ������ ������, ������������ ��������� ���� �����������,
      /// �� �������� ������� ������� / ��������� ������.
      ///
      void CellLastPrice(Label* label){cellLastPrice = label;}
      ///
      /// ���������� ������, ������������ ��������� ���� �������.
      ///
      Label* CellLastPrice(){return cellLastPrice;}
      ///
      /// ������������� ������ �� ������ ������, ������������ ������.
      ///
      void CellProfit(Label* profit)
      {
         cellProfit = profit;
      }
      ///
      /// ���������� ������ �� ������, ������������ ������.
      ///
      Label* CellProfit(){return cellProfit;}
      
      AbstractPos(string nameEl, ENUM_ELEMENT_TYPE el_type, ProtoNode* parNode) : Line(nameEl, el_type, parNode){;}
      ///
      /// ��-���������, ���������� ������� ���������� ������� ���������/�������� ������ ��� ��������� �������.
      /// \param parTable - ������������ �������.
      /// \param isLastDeal - ������, ���� ������, ������� ��������� ���������� �������� ��������� ������ � ������������ ������.
      ///
      virtual Label* GetCollapseEl(int mode, bool isLastDeal = false)
      {
         Label* tbox = NULL;
         Settings* set = Settings::GetSettings();
         //��������� "��������/������ ��� ������". ������������ ������.
         if((mode & THEADER) == THEADER)
         {
            tbox = new TreeViewBox(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_GENERAL);
            tbox.Text("+");
         }
         else if((mode & TPOSITION) == TPOSITION)
            tbox = new TreeViewBoxBorder(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_GENERAL);
         
         else if((mode & TDEAL) == TDEAL)
         {
            //��������� ������� ����������� ������� ENDSLAVE
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
      /// ��������� �� ������, ������������ ��������� ���� �����������, �� �������� ������� �������/������.
      ///
      Label* cellLastPrice;
      ///
      /// ��������� �� ������, ������������ ������ �������/������.
      ///
      Label* cellProfit;
      
};
///
/// ����������� ������������� �������
///
class PosLine : public AbstractPos
{
   public:
      PosLine(ProtoNode* parNode, Position* pos) : AbstractPos("Position", ELEMENT_TYPE_POSITION, parNode)
      {
         //��������� ����������� ������������� ������� � ���������� ��������.
         position = pos;
      }
      ///
      /// ���������� �������, ��� ����������� ������������� ��������� ������� ���������.
      ///
      Position* Position(){return position;}
      ///
      /// ���������� ���� ������������, �������� �� ������� ������� ����������� (true)
      /// ��� ���������.
      ///
      bool IsRestore(){return isRestore;}
      ///
      /// ������������� ���� �����������, �������� �� ������� ������� ����������� (true)
      /// ��� ���������.
      ///
      void IsRestore(bool status){isRestore = status;}
      ///
      /// ���������� ������ �� ������ ��������� �������.
      ///
      TreeViewBoxBorder* CellCollapsePos(){return collapsePos;}
      ///
      /// ������������� ������ �� ������ ���������� �������
      ///
      void CellCollapsePos(TreeViewBoxBorder* collapse){collapsePos = collapse;}
      ///
      /// ������������� ��������� �� ������ ������������ ������ ���������/���������� �����.
      ///
      void CellTral(CheckBox* tral){cellTral = tral;}
      ///
      /// ���������� ��������� �� ������ ������������ ������ ���������/���������� �����.
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
      /// ��������� �� ������������ ������ �������.
      ///
      TreeViewBoxBorder* collapsePos;
      ///
      /// ��������� �� �������, ��� ����������� ������������� ��������� ������� ���������.
      ///
      Position* position;
      ///
      /// ������, ���� ������� ����� ����������� ����������� �������������
      /// (������������ ����� ������), ���� - � ��������� �����.
      ///
      bool isRestore;
      ///
      /// ��������� �� ������, ������������ ���� ��� �������/������.
      ///
      CheckBox* cellTral;
};
///
/// ����������� ������������� ������
///
class DealLine : public AbstractPos
{
   public:
      DealLine(ProtoNode* parNode, Deal* EntryDeal, Deal* ExitDeal) : AbstractPos("Deal", ELEMENT_TYPE_DEAL, parNode)
      {
         //��������� ����������� ������������� ������ � ���������� ��������.
         entryDeal = EntryDeal;
         exitDeal = ExitDeal;
      }
      ///
      /// ���������� ��������� �� ����� ���������������� �������.
      ///
      Deal* EntryDeal(){return entryDeal;}
      ///
      /// ���������� ��������� �� ����� ����������� �������.
      ///
      Deal* ExitDeal(){return exitDeal;}
      ///
      /// ������������� ��������� �� ������, ������������ ������ �����.
      ///
      void CellTral(Label* tral){cellTral = tral;}
      ///
      /// ���������� ��������� �� ������, ����������� �� ������ �����.
      ///
      Label* CellTral(){return cellTral;}
      
   private:
      ///
      /// ��������� �� ����� ���������������� �������, ��� ����������� ������������� ��������� ������� ���������.
      ///
      Deal* entryDeal;
      ///
      /// ��������� �� ����� ����������� �������, ��� ����������� ������������� ��������� ������� ���������.
      ///
      Deal* exitDeal;
      ///
      /// ��������� �� �����, ������������, ������������ �� ���� ��� ������.
      ///
      Label* cellTral;
};

