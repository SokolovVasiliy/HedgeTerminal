
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
/// �������� ����� �������� � ������ ������� � ������ ��� ������������ �������������.
///
class AbstractPos : public Line
{
   public:
      AbstractPos(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode) : Line(myName, elType, parNode){;}
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
      
      ///
      /// ���������� ������� ���������� ������� ���������/�������� ������. ���������� ��� ��������, ������������
      /// �� ��������� ������ ������� ���������� � ������ tDir.
      /// \param tDir - ��������� �������� ������� � ����������� ��������, ������� ���������� �������.
      ///
      virtual Label* AddCollapseEl(TableDirective* tDir, CElement* el)
      {
         Label* tbox = NULL;
         string sname = el.Name();
         // ���� ������� ������������ ��� ������� �� ������������ �������, �� �� �� �����, ����� ���������� ������� �����,
         // ������� ���������� �������� � ������� +.
         if(!tDir.IsPositionTable())
         {
            tbox = new Label(sname, GetPointer(this));
            tbox.Text("+");
         }
         //����� ������������� ������� ��� ��������� �������?
         else if(tDir.TableElement() == TABLE_HEADER)
         {
            tbox = new TreeViewBox(sname, GetPointer(this), BOX_TREE_GENERAL);
            tbox.Text("+");
         }
         //����� ������������� ������� ��� ���������?
         else if(tDir.TableElement() == TABLE_POSITION)
            tbox = new TreeViewBoxBorder(sname, GetPointer(this), BOX_TREE_GENERAL);
         //����� ������������� ������� ��� ������?
         else if(tDir.TableElement() == TABLE_DEAL)
         {
            //��������� ������� ����������� ������� ENDSLAVE?
            ENUM_BOX_TREE_TYPE b_type = tDir.IsLastDeal() ? BOX_TREE_ENDSLAVE : BOX_TREE_SLAVE;
            tbox = new TreeViewBox(sname, GetPointer(this), b_type); 
         }
         // ������������� ���������� ��������.
         if(tbox != NULL)
         {
            tbox.OptimalWidth(el.OptimalWidth());
            tbox.ConstWidth(el.ConstWidth());
            Add(tbox);
         }
         return tbox;
      }
      ///
      /// ���������� ������� ����������� ������������� ����������� ������. ���������� ��� ��������, ������������
      /// �� ��������� ������ ������� ���������� � ������ tDir.
      /// \param tDir - ��������� �������� ������� � ����������� ��������, ������� ���������� �������.
      ///
      virtual TextNode* AddMagicEl(TableDirective* tDir, CElement* el)
      {
         TextNode* textMagic = NULL;
         if(tDir.TableElement() == TABLE_HEADER)
            textMagic = new Button(el.Name(), GetPointer(this));
         else
            textMagic = new Label(el.Name(), GetPointer(this));
         textMagic.OptimalWidth(el.OptimalWidth());
         //��� ������ ���������� �������������� ��������� ������������.
         if(tDir.TableElement() == TABLE_DEAL)
            SetForDeal(textMagic);
         Add(textMagic);
         return textMagic;
      }
      ///
      /// ���������� ������� ����������� ������������� �������� �����������. ���������� ��� ��������, ������������
      /// �� ��������� ������ ������� ���������� � ������ tDir.
      /// \param tDir - ��������� �������� ������� � ����������� ��������, ������� ���������� �������.
      ///
      virtual TextNode* AddSymbolEl(TableDirective* tDir, CElement* el)
      {
         TextNode* textMagic = NULL;
         if(tDir.TableElement() == TABLE_HEADER)
            textMagic = new Button(el.Name(), GetPointer(this));
         else
            textMagic = new Label(el.Name(), GetPointer(this));
         textMagic.OptimalWidth(el.OptimalWidth());
         //��� ������ ���������� �������������� ��������� ������������.
         if(tDir.TableElement() == TABLE_DEAL)
            SetForDeal(textMagic);
         Add(textMagic);
         return textMagic;
      }
   private:
      ///
      /// ������������� �������������� ��������� ��� ���������, ������������ ������.
      ///
      void SetForDeal(TextNode* node)
      {
         node.FontSize(9);
      }
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
      ///
      /// 
      ///
      /*virtual TextNode* AddMagicEl(TableDirective* tDir)
      {
         TextNode* node = AbstractPos::AddMagicEl(tDir);
         //�����
         node.FontSize(9);
      }*/
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

