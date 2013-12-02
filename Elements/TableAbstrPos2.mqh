
///
/// ����������� ����� ����� �� ����� ������� �������. ������ ����� ���� ���������� �������, �������� ��� �������.
/// �� ��� ������ ���� ��������� � ������ ��������.
///
class AbstractPos2 : public Line
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
         int total = ArraySize(m_nodes);
         for(int i = 0; i < total; i++)   
            RefreshValue((ENUM_COLUMN_TYPE)i);
      }
      ///
      /// ��������� �������� ������ cType.
      ///
      void RefreshValue(ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(m_nodes) > cType &&
            CheckPointer(m_nodes[cType]) != POINTER_INVALID)
         {
            m_nodes[cType].Text(GetStringValue(cType));
         }
      }
   protected:
      
      AbstractPos2(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode, ENUM_TABLE_TYPE tType) : Line(myName, elType, parNode)
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
      virtual TextNode* GetColumn(DefColumn* el, TextNode* value)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         TextNode* element = NULL;
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               element = GetDefaultEl(el);
               element.Text("+");
               break;
            default:
               element = GetDefaultEl(el);
               break;
         }
         return element;
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
   private:      
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
            ProtoNode* node = GetColumn(el, value);
            if(CheckPointer(node) != POINTER_INVALID)
               Add(node);
            if(CheckPointer(value) != POINTER_INVALID)
            {
               ENUM_COLUMN_TYPE cType = el.ColumnType();
               if(ArraySize(m_nodes) <= cType)
                  ArrayResize(m_nodes, cType+1);
               m_nodes[cType] = value;
            }
         }
      }
      ENUM_TABLE_TYPE tblType;
      ///
      /// ��� �������� ������� � ��������� ������ ����� ������ ������ �� ������.
      ///
      TextNode* m_nodes[];
};

///
/// ����� ��������� ������-��������� ������� �������.
///
class HeaderPos : public AbstractPos2
{
   public:
      HeaderPos(ProtoNode* parNode, ENUM_TABLE_TYPE tType) : AbstractPos2("header", ELEMENT_TYPE_TABLE_HEADER_POS, parNode, tType){;}
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
      virtual TextNode* GetColumn(DefColumn* el, TextNode* value)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         TextNode* element = NULL;
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               element = GetCollapseEl(el);
               break;
            case COLUMN_TRAL:
               element = GetTralEl(el);
               break;
            default:
               element = GetDefaultEl(el);
               break;
         }
         value = element;
         //����� ������������� �������������� ����� �������� ��� ������
         return element;
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
class PosLine2 : AbstractPos2
{
   public:
      PosLine2(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* m_pos) : AbstractPos2("header", ELEMENT_TYPE_POSITION, parNode, tType){;}
   private:
      ///
      /// 
      ///
      virtual TextNode* GetColumn(DefColumn* el, TextNode* value)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         TextNode* element = NULL;
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               element = GetCollapseEl(el);
               value = element;
               break;
            case COLUMN_TRAL:
               element = GetTralEl(el);
               value = element;
               break;
            case COLUMN_PROFIT:
               element = GetProfitEl(el, value);
               break;
            default:
               element = GetDefaultEl(el);
               value = element;
               break;
         }
         if(CheckPointer(element) != POINTER_INVALID)
            element.Text(GetStringValue(cType));
         return element;
      }
      
      TextNode* GetCollapseEl(DefColumn* el)
      {
         Label* tbox = NULL;
         tbox = new TreeViewBoxBorder(el.Name(), GetPointer(this), BOX_TREE_GENERAL);
         tbox.OptimalWidth(el.OptimalWidth());
         tbox.ConstWidth(el.ConstWidth());
         return tbox;
      }
      
      TextNode* GetTralEl(DefColumn* el)
      {
         TextNode* build = NULL;
         build = new CheckBox(el.Name(), GetPointer(this));
         build.Text(CharToString(168));
         build.Font("Wingdings");
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      
      TextNode* GetProfitEl(DefColumn* el, TextNode* value)
      {
         Line* comby = NULL;
         //� ����������� �� ����, �������� �� ������� ������������ ��� ��������,
         //������ ������������ ������ ������� �� ����� ������. 
         if(TableType() == TABLE_POSACTIVE)
         {
            comby = new Line(el.Name(), GetPointer(this));
            comby.AlignType(LINE_ALIGN_CELLBUTTON);
            Label* profit = new Label(el.Name(), comby);
            value = profit;
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
         else
            comby = GetDefaultEl(el);
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
class DealLine2 : public AbstractPos2
{
   public:
      DealLine2(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* mpos, Deal* EntryDeal, Deal* ExitDeal, bool IsLastLine):
      AbstractPos2("Deal", ELEMENT_TYPE_DEAL, parNode, tType)
      {
         ;
      }
   private:
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         TextNode* build = AbstractPos2::GetDefaultEl(el);
         build.FontSize(build.FontSize()-1);
         return build;
      }
      TextNode* AddColumn(DefColumn* el, TextNode* value)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         TextNode* element = NULL;
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               element = GetCollapseEl(el);
               break;
            case COLUMN_TRAL:
               element = GetTralEl(el);
               break;
            default:
               element = GetDefaultEl(el);
               break;
         }
         if(CheckPointer(element) != POINTER_INVALID)
            element.Text(GetStringValue(cType));
         value = element;
         return element;
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


