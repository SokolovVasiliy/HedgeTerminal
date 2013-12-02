
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
      AbstractPos(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode) : Line(myName, elType, parNode)
      {
         /*switch(elType)
         {
            case ELEMENT_TYPE_TABLE_HEADER_POS:
               tblElement = TABLE_HEADER;
               break;
            case ELEMENT_TYPE_POSITION:
               tblElement = TABLE_POSITION;
               break;
            case ELEMENT_TYPE_DEAL:
               tblElement = TABLE_DEAL;
               break;
         }*/
      }
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
      /// ��������� �������� ���� ����� ���������� � ������������� ����������� �������.
      /// \param cType - ������������� ������, �������� ������� ���� ��������.
      ///
      bool RefreshAll()
      {
         return false;
      }
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
   protected:
      ///
      /// ��������� ������ � ������������� ����������� �������.
      /// \param el  - ��������� ������, ������� ���� �������.
      ///
      TextNode* AddColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         TextNode* element = NULL;
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               element = AddCollapseEl(pDir, el);
               break;
            case COLUMN_TRAL:
               element = AddTralEl(pDir, el);
               break;
            case COLUMN_CURRENT_PRICE:
               element = AddLastPrice(pDir, el);
               break;
            case COLUMN_PROFIT:
               if(pDir.TableElement() == TABLE_POSITION &&
                  pDir.TableType() == TABLE_POSACTIVE)
               {
                  element = AddProfitEl(pDir, el);
                  break;
               }
               if(pDir.TableElement() == TABLE_DEAL &&
                  pDir.TableType() == TABLE_POSACTIVE)
               {
                  element = AddProfitDealEl(pDir, el);
                  break;
               }
            default:
               element = AddDefaultEl(pDir, el);
               break;
         }
         if(element != NULL)
         {
            ENUM_COLUMN_TYPE cType = el.ColumnType();
            int index = cType;
            if(ArraySize(columns) <= cType)
               ArrayResize(columns, cType+1);
            columns[cType] = element;
         }
         else if(TypeElement() == ELEMENT_TYPE_TABLE_HEADER_POS)
            element.BackgroundColor(Settings.ColorTheme.GetSystemColor());       
         else
            RefreshValue(cType);
         return element;
      }
      ///
      /// ��������� �� �������� ������� �������.
      ///
      TableDirective* pDir;
      ///
      /// ������ �������, ������� ���� ��������� � �����.
      ///
      TextNode* columns[];
      ///
      /// ���� ��������� �� ��������� ������� �������.
      /// ���������� ������, � ������ ������ � ���� � ��������� ������.
      ///
      bool FindPointToSetTable()
      {
         ProtoNode* node = ParentNode();
         while(true)
         {
            if(node == NULL)return false;
            if(node.TypeElement() != ELEMENT_TYPE_TABLE)
            {
               node = node.ParentNode();
               continue;
            }
            Table* table = node;
            pDir = table.SetTable();
            return true;
         }
         return false;
      }
   private:
      
      virtual void RefreshValue(ENUM_COLUMN_TYPE cType)
      {
         ;
      }
      
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
      /// ��������� ������ � ������ �����.
      ///
      void AddCell(TextNode* cell, ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(columns) <= cType)
            ArrayResize(columns, cType+1);
         columns[cType] = cell;
      }
      ///
      /// ��������� �� ������, ������������ ��������� ���� �����������, �� �������� ������� �������/������.
      ///
      TextNode* cellLastPrice;
      ///
      /// ��������� �� ������, ������������ ������ �������/������.
      ///
      Label* cellProfit;
      ///
      /// �������� ������������� ������.
      ///
      //ENUM_COLUMN_TYPE columnType;
      ///
      /// ��� ������: ���������, ������� ��� ������.
      ///
      ENUM_TABLE_TYPE_ELEMENT tblElement;
      
};
///
/// ��������� ������� �������.
///
/*class PosHeader(ProtoNode* parNode, ENUM_TABLE_TYPE tblType)
{
   ;
};*/
///
/// ����������� ������������� �������
///
class PosLine : public AbstractPos
{
   public:
      PosLine(ProtoNode* parNode, ENUM_ELEMENT_TYPE elType, Position* pos) : AbstractPos("Position", elType, parNode)
      {
         /*position = pos;
         //���� ��������� �� ������� �������.
         if(!FindPointToSetTable())return;
         
         //��������� ����������� ������������� ������� � ���������� ��������.
         position = pos;
         if(CheckPointer(Settings) == POINTER_INVALID)return;
         //�������� ������ �������, ������� ���� �������������.
         CArrayObj* scolumns = NULL;
         switch(pDir.TableType())
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
            AddColumn(scolumns.At(i));
         }*/
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
         if(event.EventId() == EVENT_CLOSE_POS)
         {
            EventClosePos* cevent = event;
            if(CheckPointer(position) == POINTER_INVALID)return;
            cevent.PositionId(position.EntryOrderID());
            cevent.NLine(NLine());
            //���������� ������� �������� � API �� ���������.
            EventExchange::PushEvent(cevent);
         }
         else EventSend(event);
      }
      ///
      /// ��������� ����������� ������������� �������
      ///
      void RefreshValue(ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(columns) <= cType || columns[cType] == NULL)return;
         TextNode* element = columns[cType];
         //ENUM_TABLE_TYPE_ELEMENT elType = pDir.TableElement();
         //���������� � ������� ������ ���� ������
         if(position == NULL)return;
         CTime* ctime = NULL;
         switch(cType)
         {
            case COLUMN_MAGIC:
               element.Text((string)position.Magic());
               break;
            case COLUMN_SYMBOL:
               element.Text(position.Symbol());
               break;
            case COLUMN_ENTRY_ORDER_ID:
               element.Text((string)position.EntryOrderID());
               break;
            case COLUMN_EXIT_ORDER_ID:
               element.Text((string)position.ExitOrderID());
               break;
            case COLUMN_EXIT_MAGIC:
               element.Text((string)position.ExitMagic());
               break;
            case COLUMN_ENTRY_DATE:
               ctime = position.EntryExecutedDate();   
               element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
               delete ctime;
               break;
            case COLUMN_EXIT_DATE:
               ctime = position.ExitExecutedDate();   
               element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
               delete ctime;
               break;
            case COLUMN_TYPE:
               element.Text(position.PositionTypeAsString());
               break;
            case COLUMN_VOLUME:
               element.Text(position.VolumeToString(position.VolumeExecuted()));
               break;
            case COLUMN_ENTRY_PRICE:
               if(pDir == NULL)break;
               if(pDir.TableElement() == TABLE_POSITION && position.PositionStatus() == POSITION_STATUS_PENDING)
                  element.Text(position.PriceToString(position.EntryPricePlaced()));
               else if(pDir.TableElement() == TABLE_POSITION)
                  element.Text(position.PriceToString(position.EntryPriceExecuted()));
               break;
            case COLUMN_SL:
               element.Text(position.PriceToString(position.StopLossLevel()));
               break;
            case COLUMN_TP:
               element.Text(position.PriceToString(position.TakeProfitLevel()));
               break;
            case COLUMN_TRAL:
               if(position.UsingStopLoss())
                  element.Text(CharToString(254));
               else
                  element.Text(CharToString(168));
               element.FontSize(12);
               break;
            case COLUMN_EXIT_PRICE:
               element.Text(position.PriceToString(position.ExitPriceExecuted()));
               break;
            case COLUMN_CURRENT_PRICE:
               element.Text(position.PriceToString(position.CurrentPrice()));
               break;
            case COLUMN_PROFIT:
               element.Text(position.ProfitAsString());
               break;
            case COLUMN_ENTRY_COMMENT:
               element.Text(position.EntryComment());
               break;
            case COLUMN_EXIT_COMMENT:
               element.Text(position.ExitComment());
               break;
         }
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
      DealLine(ProtoNode* parNode, Position* mpos, Deal* EntryDeal, Deal* ExitDeal) : AbstractPos("Deal", ELEMENT_TYPE_DEAL, parNode)
      {
         if(CheckPointer(pos) != POINTER_INVALID)pos = mpos;
         //��������� ����������� ������������� ������ � ���������� ��������.
         entryDeal = EntryDeal;
         exitDeal = ExitDeal;
      }
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
      void RefreshValue(ENUM_COLUMN_TYPE cType)
      {
         TextNode* element = columns[cType];
         element.Text("");
         ENUM_TABLE_TYPE_ELEMENT elType = pDir.TableElement();
         //������ ���� ���� �� ���� ������.
         if(entryDeal == NULL && exitDeal == NULL)return;
         Deal* defDeal = entryDeal == NULL ? exitDeal : entryDeal;
         switch(cType)
         {
            case COLUMN_MAGIC:
               element.Text((string)defDeal.Magic());
               break;
            case COLUMN_SYMBOL:
               element.Text(defDeal.Symbol());
               break;
            case COLUMN_ENTRY_ORDER_ID:
               if(entryDeal != NULL)
                  element.Text((string)entryDeal.Ticket());
               break;
            case COLUMN_EXIT_ORDER_ID:
               if(exitDeal != NULL)
                  element.Text((string)exitDeal.Ticket());
               break;
            case COLUMN_ENTRY_DATE:
               if(entryDeal != NULL)
               {
                  CTime* ctime = entryDeal.Date();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
                  delete ctime;
               }
               break;
            case COLUMN_EXIT_DATE:
               if(exitDeal != NULL)
               {
                  CTime* ctime = exitDeal.Date();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
                  delete ctime;
               }
               break;
            case COLUMN_TYPE:
               element.Text("-");
               break;
            case COLUMN_VOLUME:
               if(entryDeal != NULL)
                  element.Text(entryDeal.VolumeToString(entryDeal.VolumeExecuted()));
               break;
            case COLUMN_ENTRY_PRICE:
               if(entryDeal != NULL)
                  element.Text(entryDeal.PriceToString(entryDeal.EntryPriceExecuted()));
               break;
            case COLUMN_SL:
               element.Text("-");   
               break;
            case COLUMN_TP:
               element.Text("-");
               break;
            case COLUMN_TRAL:
               if(pos.UsingStopLoss())
                  element.Text(CharToString(254));
               else
                  element.Text(CharToString(168));
               element.FontSize(11);
               element.FontColor(clrSlateGray);
               break;
            case COLUMN_EXIT_PRICE:
               if(exitDeal != NULL)
                  element.Text(exitDeal.PriceToString(exitDeal.EntryPriceExecuted()));
               break;
            case COLUMN_CURRENT_PRICE:
               if(pos != NULL)
                  element.Text(pos.PriceToString(pos.CurrentPrice()));
               break;
            case COLUMN_PROFIT:
               element.Text("-");
               break;
            case COLUMN_ENTRY_COMMENT:
               if(entryDeal != NULL)
                  element.Text(entryDeal.Comment());
               break;
            case COLUMN_EXIT_COMMENT:
               if(exitDeal != NULL)
                  element.Text(exitDeal.Comment());
               break;
         }
      }
   private:
      ///
      /// ��������� �� �������, � ������� ����������� ������� ������. ��������� ������
      /// ����� ���� ��������� ��� �����-���� �������, � ���� ������ ��������� �����  
      /// ��������� �� NULL.
      ///
      Position* pos;
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

