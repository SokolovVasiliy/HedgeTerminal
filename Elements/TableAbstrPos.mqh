
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
      void CellLastPrice(TextNode* label){cellLastPrice = label;}
      ///
      /// ���������� ������, ������������ ��������� ���� �������.
      ///
      TextNode* CellLastPrice(){return cellLastPrice;}
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
      virtual Label* AddCollapseEl(TableDirective* tDir, DefColumn* el)
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
      /// ���������� ������� ���������� ������� ���� ����-�����. ���������� ��� ��������, ������������
      /// �� ��������� ������ ������� ���������� � ������ tDir.
      /// \param tDir - ��������� �������� ������� � ����������� ��������, ������� ���������� �������.
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
         if(tDir.TableType() == TABLE_POSACTIVE && tDir.TableElement() == TABLE_POSITION)
         {
            comby = new Line(el.Name(), GetPointer(this));
            comby.AlignType(LINE_ALIGN_CELLBUTTON);
            Label* profit = new Label(el.Name(), comby);
            cellProfit = profit;
            ButtonClosePos* btnClose = new ButtonClosePos("btnClosePos.", comby);
            btnClose.Font("Wingdings");
            btnClose.FontSize(12);
            btnClose.Text(CharToString(251));
            comby.Add(profit);
            comby.Add(btnClose);
            comby.OptimalWidth(el.OptimalWidth());
            comby.ConstWidth(el.ConstWidth());
            Add(comby);
         }
         return comby;
      }
      virtual TextNode* AddLastPrice(TableDirective* tDir, DefColumn* el)
      {
         TextNode* build = AddDefaultEl(tDir, el);
         cellLastPrice = build;
         return build;
      }
      virtual TextNode* AddProfitDealEl(TableDirective* tDir, DefColumn* el)
      {
         TextNode* build = AddDefaultEl(tDir, el);
         cellProfit = build;
         return build;
      }
      ///
      /// ��������� ������� ��-��������� � ������, � ���������� ������ �� ����.
      ///
      TextNode* AddDefaultEl(TableDirective* tDir, DefColumn* el)
      {
         TextNode* build = DefaultBuilder(tDir, el);
         Add(build);
         return build;
      }
      
   private:
      ///
      /// ������� ������� �������, �� ��������� ���������� � ������� � ���������� �������� ��������.
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
         //��� ������ ���������� �������������� ��������� ������������.
         if(tDir.TableElement() == TABLE_DEAL)
            SetForDeal(build);
         return build;
      }
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
      TextNode* cellLastPrice;
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
      PosLine(ProtoNode* parNode, ENUM_ELEMENT_TYPE elType, Position* pos) : AbstractPos("Position", elType, parNode)
      {
         //��������� ����������� ������������� ������� � ���������� ��������.
         position = pos;
      }
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
      virtual void OnEvent(Event* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN && event.EventId() == EVENT_CLOSE_POS)
         {
            EventClosePos* cevent = event;
            if(CheckPointer(position) == POINTER_INVALID)return;
            cevent.PositionId(position.EntryOrderID());
            EventSend(cevent);
         }
         else EventSend(event);
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
      void CellTral(TextNode* tral){cellTral = tral;}
      ///
      /// ���������� ��������� �� ������, ����������� �� ������ �����.
      ///
      TextNode* CellTral(){return cellTral;}
      ///
      /// ��������� ������ �����
      ///
      virtual TextNode* AddTralEl(TableDirective* tDir, DefColumn* el)
      {
         TextNode* build = AddDefaultEl(tDir, el);
         build.Font("Wingdings");
         CellTral(build);
         return build;
      }
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
      TextNode* cellTral;
};

