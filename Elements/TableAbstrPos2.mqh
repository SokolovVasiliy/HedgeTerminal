
///
/// ����������� ����� ����� �� ����� ������� �������. ������ ����� ���� ���������� �������, �������� ��� �������.
/// �� ��� ������ ���� ��������� � ������ ��������.
///
class AbstractPos : public Line
{
   public:
      ///
      /// ���������� ��� �������, � ������� ����������� ������� ������.
      ///
      ENUM_TABLE_TYPE TableType(){return tblType;}
      ///
      /// ��������� �������� ���� ����� �������� � ������.
      ///
      void RefreshAll()
      {
         int total = ArraySize(textNodes);
         for(int i = 0; i < total; i++)   
            RefreshValue((ENUM_COLUMN_TYPE)i);
      }
      ///
      /// ��������� �������� ������ cType.
      ///
      void RefreshValue(ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(textNodes) > cType &&
            CheckPointer(textNodes[cType]) != POINTER_INVALID)
         {
            textNodes[cType].Text(GetStringValue(cType));
         }
      }
      ///
      /// ���������� ������ �� ������.
      ///
      TextNode* GetCell(ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(protoNodes) > cType &&
            CheckPointer(protoNodes[cType]) != POINTER_INVALID)
         {
            return protoNodes[cType];
         }
         return NULL;
      }
   protected:
      ///
      /// ������ ������-�����. 
      ///
      class tnode
      {
         public:
            ///
            /// ��������� �� ������, ������� ���� �������� � ������.
            ///
            ProtoNode* element;
            ///
            /// ��������� �� ������, ����� ������� ����� ������.
            ///
            TextNode* value;
      };
      
      AbstractPos(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode, ENUM_TABLE_TYPE tType) : Line(myName, elType, parNode)
      {
         tblType = tType;
      }
      virtual string GetStringValue(ENUM_COLUMN_TYPE cType)
      {
         return EnumToString(cType);
      }
      ///
      /// ������� ������� ��-���������.
      ///
      virtual tnode* GetColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         TextNode* element = NULL;
         tnode* comby = new tnode();
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               element = GetDefaultEl(el);
               element.Text("+");
               comby.value = element;
               break;
            default:
               element = GetDefaultEl(el);
               comby.value = element;
               break;
         }
         comby.element = element;
         return comby;
      }
      ///
      /// ������� � ���������� ������� ��-���������.
      ///
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         TextNode* build = NULL;
         build = new Label(el.Name(), GetPointer(this));
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      ///
      /// ��������� ����� ���������� ��������� ���������������� GetColumn().
      /// ����� ������� ������ ������������� ����� ������������� ������������ �������� ������.
      ///
      void BuilderLine()
      {
         if(CheckPointer(Settings) == POINTER_INVALID)return;
         //�������� ������ �������, ������� ���� �������������.
         CArrayObj* scolumns = NULL;
         switch(tblType)
         {
            case TABLE_POSACTIVE:
               scolumns = Settings.GetSetForActiveTable();
               break;
            case TABLE_POSHISTORY:
               scolumns = Settings.GetSetForHistoryTable();
               break;
            default:
               //���� ��� ������� ����������, �� � ������������ ������.
               return; 
         }
         //��������� �����.
         int total = scolumns.Total();
         for(int i = 0; i < total; i++)
         {
            TextNode* value = NULL;
            DefColumn* el = scolumns.At(i);
            ENUM_COLUMN_TYPE cType = el.ColumnType();
            tnode* node = GetColumn(el);
            if(CheckPointer(node.element) != POINTER_INVALID)
            {
               Add(node.element);
               if(ArraySize(protoNodes) <= cType)
                  ArrayResize(protoNodes, cType+1);
               protoNodes[cType] = node.element;
            }
            if(CheckPointer(node.value) != POINTER_INVALID)
            {
               if(ArraySize(textNodes) <= cType)
                  ArrayResize(textNodes, cType+1);
               textNodes[cType] = node.value;
            }
            delete node;
         }
      }
      
   private:
      ENUM_TABLE_TYPE tblType;
      ///
      /// ��� �������� ������� � ��������� ������ ����� ������ ������ �� ������.
      ///
      TextNode* textNodes[];
      ///
      /// ��� �������� ������� � ��������� ������ ����� ������ ������ �� ��������.
      ///
      ProtoNode* protoNodes[];
};

///
/// ����� ��������� ������-��������� ������� �������.
///
class HeaderPos : public AbstractPos
{
   public:
      HeaderPos(ProtoNode* parNode, ENUM_TABLE_TYPE tType) : AbstractPos("header", ELEMENT_TYPE_TABLE_HEADER_POS, parNode, tType)
      {
         BuilderLine();
      }
   private:
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         TextNode* build = NULL;
         //� ������� �� ���������� ��-��������� ��������� ������, � �� ��������� �����.
         build = new Button(el.Name(), GetPointer(this));
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      ///
      /// ������� ������� ��-���������.
      ///
      
      virtual tnode* GetColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         tnode* comby = new tnode();
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               comby.element = GetCollapseEl(el);
               break;
            case COLUMN_TRAL:
               comby.element = GetTralEl(el);
               comby.value = comby.element;
               break;
            default:
               comby.element = GetDefaultEl(el);
               comby.value = comby.element;
               break;
         }
         //����� ������������� �������������� ����� �������� ��� ������
         return comby;
      }
      ///
      /// ������� ������� ��� ��������/�������� ����� ������.
      ///
      TextNode* GetCollapseEl(DefColumn* el)
      {
         TextNode* tbox = NULL;
         string sname = el.Name();
         //����� ������������� ������� ��� ��������� �������?
         tbox = new TreeViewBox(sname, GetPointer(this), BOX_TREE_GENERAL);
         tbox.Text("+");
         // ������������� ���������� ��������.
         tbox.OptimalWidth(el.OptimalWidth());
         tbox.ConstWidth(el.ConstWidth());
         return tbox;
      }
      ///
      /// ��������� ���� �����
      ///
      TextNode* GetTralEl(DefColumn* el)
      {
         TextNode* build = NULL;
         build = GetDefaultEl(el);
         build.Text(CharToString(168));
         build.Font("Wingdings");
         return build;
      }
};

///
/// ����� ��������� ������-������� ������� �������.
///
class PosLine : public AbstractPos
{
   public:
      PosLine(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* m_pos) : AbstractPos("header", ELEMENT_TYPE_POSITION, parNode, tType)
      {
         if(CheckPointer(m_pos) != POINTER_INVALID)
            pos = m_pos;
         BuilderLine();
         pos.PositionLine(GetPointer(this));
      }
      ///
      /// ���������� ��������� �� �������, � ������� ������������� ������ ������.
      ///
      Position* Position()
      {
         return pos;
      }
   private:
      ///
      /// 
      ///
      virtual tnode* GetColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         tnode* comby = new tnode();
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               comby.element = GetCollapseEl(el);
               break;
            case COLUMN_TRAL:
               comby.element = GetTralEl(el);
               break;
            case COLUMN_PROFIT:
               delete comby;
               comby = GetProfitEl(el);
               break;
            default:
               comby.element = GetDefaultEl(el);
               comby.value = comby.element;
               break;
         }
         if(CheckPointer(comby.value) != POINTER_INVALID)   
            comby.value.Text(GetStringValue(cType));
         return comby;
      }
      
      TextNode* GetCollapseEl(DefColumn* el)
      {
         Label* tbox = NULL;
         tbox = new TreeViewBoxBorder(el.Name(), GetPointer(this), BOX_TREE_GENERAL);
         tbox.OptimalWidth(el.OptimalWidth());
         tbox.ConstWidth(el.ConstWidth());
         return tbox;
      }
      
      CheckBox* GetTralEl(DefColumn* el)
      {
         CheckBox* build = NULL;
         build = new CheckBox(el.Name(), GetPointer(this));
         build.Text(CharToString(168));
         build.Font("Wingdings");
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      
      tnode* GetProfitEl(DefColumn* el)
      {
         tnode* comby = new tnode();
         Line* element = NULL;
         //� ����������� �� ����, �������� �� ������� ������������ ��� ��������,
         //������ ������������ ������ ������� �� ����� ������. 
         if(TableType() == TABLE_POSACTIVE)
         {
            element = new Line(el.Name(), GetPointer(this));
            element.AlignType(LINE_ALIGN_CELLBUTTON);
            Label* profit = new Label(el.Name(), element);
            comby.value = profit;
            ButtonClosePos* btnClose = new ButtonClosePos("btnClosePos.", element);
            btnClose.Font("Wingdings");
            btnClose.FontSize(12);
            btnClose.Text(CharToString(251));
            element.Add(profit);
            element.Add(btnClose);
            element.OptimalWidth(el.OptimalWidth());
            element.ConstWidth(el.ConstWidth());
            comby.element = element;
         }
         else
         {
            comby.element = GetDefaultEl(el);
            comby.value = comby.element;
         }
         return comby;
      }
      ///
      /// ��������� ����������� ������������� �������
      ///
      virtual string GetStringValue(ENUM_COLUMN_TYPE cType)
      {
         string value = EnumToString(cType);
         //���������� � ������� ������ ���� ������
         if(CheckPointer(pos) == POINTER_INVALID)return value;
         CTime* ctime = NULL;
         switch(cType)
         {
            case COLUMN_MAGIC:
               value = (string)pos.Magic();
               break;
            case COLUMN_SYMBOL:
               value = pos.Symbol();
               break;
            case COLUMN_ENTRY_ORDER_ID:
               value = (string)pos.EntryOrderID();
               break;
            case COLUMN_EXIT_ORDER_ID:
               value = (string)pos.ExitOrderID();
               break;
            case COLUMN_EXIT_MAGIC:
               value = (string)pos.ExitMagic();
               break;
            case COLUMN_ENTRY_DATE:
               ctime = pos.EntryExecutedDate();   
               value = ctime.TimeToString(TIME_DATE | TIME_MINUTES);
               delete ctime;
               break;
            case COLUMN_EXIT_DATE:
               ctime = pos.ExitExecutedDate();   
               value = ctime.TimeToString(TIME_DATE | TIME_MINUTES);
               delete ctime;
               break;
            case COLUMN_TYPE:
               value = pos.PositionTypeAsString();
               break;
            case COLUMN_VOLUME:
               value = pos.VolumeToString(pos.VolumeExecuted());
               break;
            case COLUMN_ENTRY_PRICE:
               if(pos.PositionStatus() == POSITION_STATUS_PENDING)
                  value = pos.PriceToString(pos.EntryPricePlaced());
               else
                  value = pos.PriceToString(pos.EntryPriceExecuted());
               break;
            case COLUMN_SL:
               value = pos.PriceToString(pos.StopLossLevel());
               break;
            case COLUMN_TP:
               value = pos.PriceToString(pos.TakeProfitLevel());
               break;
            case COLUMN_TRAL:
               if(pos.UsingStopLoss())
                  value = CharToString(254);
               else
                  value = CharToString(168);
               break;
            case COLUMN_EXIT_PRICE:
               value = pos.PriceToString(pos.ExitPriceExecuted());
               break;
            case COLUMN_CURRENT_PRICE:
               value = pos.PriceToString(pos.CurrentPrice());
               break;
            case COLUMN_PROFIT:
               value = pos.ProfitAsString();
               break;
            case COLUMN_ENTRY_COMMENT:
               value = pos.EntryComment();
               break;
            case COLUMN_EXIT_COMMENT:
               value = pos.ExitComment();
               break;
         }
         return value;
      }
      ///
      /// ��������� �� �������, ������� ������������ ������ ������.
      ///
      Position* pos;
};

///
/// ����� ��������� ������-������� ������� �������.
///
class DealLine : public AbstractPos
{
   public:
      DealLine(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* mpos, Deal* EntryDeal, Deal* ExitDeal, bool IsLastLine):
      AbstractPos("Deal", ELEMENT_TYPE_DEAL, parNode, tType)
      {
         if(CheckPointer(mpos) != POINTER_INVALID)
            pos = mpos;
         if(CheckPointer(EntryDeal) != POINTER_INVALID)
            entryDeal = EntryDeal;
         if(CheckPointer(ExitDeal) != POINTER_INVALID)
            exitDeal = ExitDeal;
         isLastLine = IsLastLine;
         BuilderLine();
         
      }
   private:
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         TextNode* build = AbstractPos::GetDefaultEl(el);
         build.FontSize(build.FontSize()-1);
         return build;
      }
      virtual tnode* GetColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         tnode* comby = new tnode;
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               comby.element = GetCollapseEl(el);
               break;
            case COLUMN_TRAL:
               comby.element = GetTralEl(el);
               comby.value = comby.element;
               break;
            default:
               comby.element = GetDefaultEl(el);
               comby.value = comby.element;
               break;
         }
         if(CheckPointer(comby.value) != POINTER_INVALID)
            comby.value.Text(GetStringValue(cType));
         return comby;
      }
      
      TextNode* GetCollapseEl(DefColumn* el)
      {
         Label* tbox = NULL;
         ENUM_BOX_TREE_TYPE b_type = isLastLine ? BOX_TREE_ENDSLAVE : BOX_TREE_SLAVE;
         tbox = new TreeViewBox(el.Name(), GetPointer(this), b_type); 
         tbox.OptimalWidth(el.OptimalWidth());
         tbox.ConstWidth(el.ConstWidth());
         return tbox;
      }
      
      TextNode* GetTralEl(DefColumn* el)
      {
         TextNode* build = NULL;
         build = new Label(el.Name(), GetPointer(this));
         build.Font("Wingdings");
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      virtual string GetStringValue(ENUM_COLUMN_TYPE cType)
      {
         string value = "";
         //������ ���� ���� �� ���� ������.
         if(entryDeal == NULL && exitDeal == NULL)return value;
         Deal* defDeal = entryDeal == NULL ? exitDeal : entryDeal;
         switch(cType)
         {
            case COLUMN_MAGIC:
               value = (string)defDeal.Magic();
               break;
            case COLUMN_SYMBOL:
               value = defDeal.Symbol();
               break;
            case COLUMN_ENTRY_ORDER_ID:
               if(entryDeal != NULL)
                  value = (string)entryDeal.Ticket();
               break;
            case COLUMN_EXIT_ORDER_ID:
               if(exitDeal != NULL)
                  value = (string)exitDeal.Ticket();
               break;
            case COLUMN_ENTRY_DATE:
               if(entryDeal != NULL)
               {
                  CTime* ctime = entryDeal.Date();   
                  value = ctime.TimeToString(TIME_DATE | TIME_MINUTES);
                  delete ctime;
               }
               break;
            case COLUMN_EXIT_DATE:
               if(exitDeal != NULL)
               {
                  CTime* ctime = exitDeal.Date();   
                  value = ctime.TimeToString(TIME_DATE | TIME_MINUTES);
                  delete ctime;
               }
               break;
            case COLUMN_TYPE:
               value = "-";
               break;
            case COLUMN_VOLUME:
               if(entryDeal != NULL)
                  value = entryDeal.VolumeToString(entryDeal.VolumeExecuted());
               break;
            case COLUMN_ENTRY_PRICE:
               if(entryDeal != NULL)
                  value = entryDeal.PriceToString(entryDeal.EntryPriceExecuted());
               break;
            case COLUMN_SL:
               value = "-";
               break;
            case COLUMN_TP:
               value = "-";
               break;
            case COLUMN_TRAL:
               if(pos != NULL && pos.UsingStopLoss())
                  value = CharToString(254);
               else
                  value = CharToString(168);
               break;
            case COLUMN_EXIT_PRICE:
               if(exitDeal != NULL)
                  value = exitDeal.PriceToString(exitDeal.EntryPriceExecuted());
               break;
            case COLUMN_CURRENT_PRICE:
               if(pos != NULL)
                  value = pos.PriceToString(pos.CurrentPrice());
               break;
            case COLUMN_PROFIT:
               value = "-";
               break;
            case COLUMN_ENTRY_COMMENT:
               if(entryDeal != NULL)
                  value = entryDeal.Comment();
               break;
            case COLUMN_EXIT_COMMENT:
               if(exitDeal != NULL)
                  value = exitDeal.Comment();
               break;
         }
         return value;
      }
         
      ///
      /// �������, � ������� ����������� ������� ������ (���� ����).
      ///
      Position* pos;
      ///
      /// ������ ����� � ������� (���� ����).
      ///
      Deal* entryDeal;
      ///
      /// ������ ������ �� ������� (���� ����).
      ///
      Deal* exitDeal;
      ///
      /// ������, ���� ������� ������, �������������� ����� ��������� � ������ �������.
      ///
      bool isLastLine;
};