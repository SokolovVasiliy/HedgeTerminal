#include "..\Settings.mqh"
#ifndef TABLE_MQH
   #include "Table.mqh"
#endif

#ifndef TABLE_ABSTRPOS_MQH
   #include "TableAbstrPos.mqh"
#endif


#define TABLEPOSITIONS_MQH
///
/// ������� �������� �������.
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
         switch(event.EventId())
         {
            case EVENT_CREATE_NEWPOS:
               AddPosition(event);
               break;
            case EVENT_REFRESH:
               RefreshPrices();
               break;
            case EVENT_CHECK_BOX_CHANGED:
               OnCheckBoxChanged(event);
               break;
            case EVENT_COLLAPSE_TREE:
               OnCollapse(event);
               break;
            case EVENT_NODE_CLICK:
               OnNodeClick(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
      
   private:
      ///
      /// ������������� �������
      ///
      void Init()
      {
         // ������ ����� - ����������� ���, �������, ����� ������ �������� ����� � ���� ���������.
         AbstractPos* posLine = lineHeader;
         tDir.TableElement(TABLE_HEADER);
         int index = -1;
         //�������� ����� ��� ��������� �� ������, �������������� ������ AbstractPos
         //������� ������ ������� ���������.
         for(int i = 0; i < ChildsTotal(); i++)
         {
            ProtoNode* node = ChildElementAt(i);
            if(lineHeader == node){
               index = i;
               break;
            }
         }
         //�������� ��� �� �����
         if(index != -1)
         {
            childNodes.Delete(index);
            lineHeader = CreateLine(GetPointer(this), GetPointer(tDir), NULL);
            childNodes.Insert(lineHeader, index);
         }
      }
      ///
      /// ���������� ������� "���� ��� ������� �������".
      ///
      void OnCheckBoxChanged(EventCheckBoxChanged* event)
      {
         ProtoNode* node = event.Node();
         if(node.TypeElement() != ELEMENT_TYPE_BOTTON)return;
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
      /// ������������ ������� ������� ������ ����.
      ///
      void OnNodeClick(EventNodeClick* event)
      {
         ProtoNode* node = event.Node();
         ProtoNode* parNode = node.ParentNode();
         if(parNode == NULL || parNode != lineHeader)
            return;
         //������������ ��������� ����� ��� ���� �������.
         if(node.ShortName() == name_tralSl)
         {
            if(node.TypeElement() != ELEMENT_TYPE_BOTTON)return;
            Button* btn = node;
            //��������� ���� ��� ���� �������.
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
         //������� ���������������� ������, �� ������� ���� ������������� �������
         //if(parentNode.TypeElement() == ELEMENT)
      }
      void OnCollapse(EventCollapseTree* event)
      {
         ProtoNode* node = event.Node();
         ENUM_ELEMENT_TYPE type = node.TypeElement();
         if(type == ELEMENT_TYPE_POSITION)
         {
            // �����������
            if(event.IsCollapse())
               DeleteDeals(event);
            // �������������
            else AddDeals(event);
         }
         //��������� ����������/�������� ��� �������?
         if(type == ELEMENT_TYPE_TABLE_HEADER_POS)
         {
            // ����������� ���� ������.
            if(event.IsCollapse())
               CollapseAll();
            // ������������� ���� ������.
            else RestoreAll();
            //AllocationShow();
         }
         //��������� ������� ������� ��� ���������������� ����������������
         //�����.
         AllocationWorkTable();
         
         //������ ��������� �� �������������� ������
         AllocationScroll();      
      }
      
      
      ///
      /// ������������� ���� ������ �������.
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
      /// ����������� ���� ������ �������
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
      /// ������ ������ �������������� ������� � ����������� ��
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
      /// ��������� ���� �������� �������.
      ///
      void RefreshPrices()
      {
         int total = workArea.ChildsTotal();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            ENUM_ELEMENT_TYPE el_type = node.TypeElement();
            if(node.TypeElement() != ELEMENT_TYPE_POSITION &&
               node.TypeElement() != ELEMENT_TYPE_DEAL)
               continue;
            //��������� ������� � ������ ��-�������.
            if(node.TypeElement() == ELEMENT_TYPE_POSITION)
            {
               //��������� ��������� ����
               PosLine* posLine = node;
               Position* pos = posLine.Position();
               TextNode* lastPrice = posLine.CellLastPrice();
               double price = pos.CurrentPrice();
               if(lastPrice != NULL)
               {
                  int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
                  lastPrice.Text(DoubleToString(price, digits));
               }
               //��������� ���������� � ������� �������
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
               //��������� ���������� � ������� ������.
               Label* profit = dealLine.CellProfit();
               if(profit != NULL)
                  profit.Text(deal.ProfitAsString());
            }
         }
      }
      
      ///
      /// ������� ���������� ������������� ������, ������� ����������: ��������� ������� �������, ���
      /// ���� ������� ��� ������, ��������� � ��������. ����� ����, ��� ������ ������������� ����� 
      /// �������, ��� ����� ���������� ����������� ������.
      ///
      Line* CreateLine(ProtoNode* parNode, TableDirective* tDir, Position* pos, Deal* entryDeal=NULL, Deal* exitDeal=NULL)
      {
         AbstractPos* posLine = NULL;
         
         //�������� ��������� �� tDir
         TableDirective* pDir = GetPointer(tDir);
         ENUM_TABLE_TYPE elType = pDir.TableType();
         
         //�������� ������ �������, ������� ���� �������������.
         CArrayObj* columns = NULL;
         switch(pDir.TableType())
         {
            case TABLE_POSACTIVE:
               columns = Settings.GetSetForActiveTable();
               break;
            case TABLE_POSHISTORY:
               columns = Settings.GetSetForActiveTable();
               break;
            default:
               //���� ��� ������� ����������, �� � ������������ ������.
               return posLine; 
         }
         //���������� ����� ��� ����� ����� ������������.
         switch(pDir.TableElement())
         {
            case TABLE_HEADER:
            case TABLE_POSITION:
               posLine = new PosLine(GetPointer(parNode), pos);
               break;
            case TABLE_DEAL:
               posLine = new DealLine(GetPointer(parNode), entryDeal, exitDeal);
               break;
            default:
               //���� ��� ������ ����������, �� � ������������� �� �� �� �����.
               return posLine;
         }
         //��������� �����.
         int total = columns.Total();
         for(int i = 0; i < total; i++)
         {
            //�������, �������� �������� �� ���������
            TextNode* element = NULL;
            DefColumn* el = columns.At(i);
            ENUM_COLUMN_TYPE elType = el.ColumnType();
            if(elType == COLUMN_COLLAPSE)
               posLine.AddCollapseEl(pDir, el);
            else if(elType == COLUMN_TRAL)
               element = posLine.AddTralEl(pDir, el);
            else if(elType == COLUMN_CURRENT_PRICE)
               element = posLine.AddLastPrice(pDir, el);
            else if(elType == COLUMN_PROFIT && pDir.TableElement() == TABLE_POSITION &&
               pDir.TableType() == TABLE_POSACTIVE)
               posLine.AddProfitEl(pDir, el);
            else if(elType == COLUMN_PROFIT && pDir.TableElement() == TABLE_DEAL &&
               pDir.TableType() == TABLE_POSACTIVE)
               posLine.AddProfitDealEl(pDir, el);
            else
               element = posLine.AddDefaultEl(pDir, el);
            //������, ����� ������� �������, �������� ��� ���������.
            if(element != NULL && pos != NULL)
               LineBuilder(pDir.TableElement(), element, el, pos, entryDeal, exitDeal);
            
         }
         return posLine;
      }
      void LineBuilder(ENUM_TABLE_TYPE_ELEMENT elType, TextNode* element, DefColumn* el, Position* pos, Deal* entryDeal=NULL, Deal* exitDeal=NULL)
      {
         //���������� � ������� ������ ���� ������
         if(pos == NULL) return;
         switch(el.ColumnType())
         {
            case COLUMN_MAGIC:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.Magic());
               break;
            case COLUMN_SYMBOL:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.Symbol());
               break;
            case COLUMN_ENTRY_ORDER_ID:
               if(elType == TABLE_POSITION)
                  element.Text(pos.EntryOrderID());
               if(elType == TABLE_DEAL && entryDeal != NULL)
                  element.Text(entryDeal.Ticket());
               break;
            case COLUMN_EXIT_ORDER_ID:
               if(elType == TABLE_POSITION)
                  element.Text(pos.ExitOrderID());
               if(elType == TABLE_DEAL && exitDeal != NULL)
                  element.Text(exitDeal.Ticket());
               break;
            case COLUMN_ENTRY_DATE:
               if(elType == TABLE_POSITION)
               {
                  CTime ctime = pos.EntryDate();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
               }
               if(elType == TABLE_DEAL && entryDeal != NULL)
               {
                  CTime ctime = entryDeal.Date();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
               }
               break;
            case COLUMN_EXIT_DATE:
               if(elType == TABLE_POSITION)
               {
                  CTime ctime = pos.ExitDate();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
               }
               if(elType == TABLE_DEAL && exitDeal != NULL)
               {
                  CTime ctime = exitDeal.Date();   
                  element.Text(ctime.TimeToString(TIME_DATE | TIME_MINUTES));
               }
               break;
            case COLUMN_TYPE:
               if(elType == TABLE_POSITION)
                  element.Text(pos.StrPositionType());
               if(elType == TABLE_DEAL && entryDeal != NULL)
                  element.Text(entryDeal.StrDealType());
               break;
            case COLUMN_VOLUME:
               if(elType == TABLE_POSITION)
                  element.Text(pos.VolumeAsString());
               if(elType == TABLE_DEAL && entryDeal != NULL)
                  element.Text(entryDeal.StrDealType());
               break;
            case COLUMN_ENTRY_PRICE:
               if(elType == TABLE_POSITION)
                  element.Text(pos.PriceToString(pos.EntryPrice()));
               if(elType == TABLE_DEAL && entryDeal != NULL)
                  element.Text(entryDeal.PriceToString(entryDeal.Price()));
               break;
            case COLUMN_SL:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.PriceToString((string)pos.StopLoss()));
               break;
            case COLUMN_TP:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
                  element.Text(pos.PriceToString((string)pos.TakeProfit()));
               break;
            case COLUMN_TRAL:
               if(elType == TABLE_POSITION || elType == TABLE_DEAL)
               {
                  if(pos.UsingStopLoss())
                     element.Text(CharToString(254));
                  else
                     element.Text(CharToString(168));
               }
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
      /// ��������� ����� ��������� �������, ���� ���������� �������
      ///
      void AddPosition(EventCreatePos* event)
      {
         Position* pos = event.GetPosition();
         //��������� ������ �������� �������.
         //if(pos.Status == POSITION_STATUS_CLOSED)return;
         tDir.TableElement(TABLE_POSITION);
         PosLine* nline = CreateLine(workArea, GetPointer(tDir), pos);
         workArea.Add(nline);
         //��� �� ����� ������� ��� �� ������������ � ������� �������� �������
         //���������� ������������ �������, ��� ���������� ������� refresh
         EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
         EventSend(er);
         delete er;
      }
      
      ///
      /// ��������� ������������ ������ ��� �������
      ///
      void AddDeals(EventCollapseTree* event)
      {
         ProtoNode* node = event.Node();
         //������� ����� ������������ ������ �������, � � ������� ���������� �������� �� �����.
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
         PosLine* posLine = node;
         //�������� ������������� ��� ����������� ������� �� ����.
         if(posLine.IsRestore())return;
         Position* pos = posLine.Position();
         ulong order_id = pos.EntryOrderID();
         //������� �������� ������, ������� ���������� ��������.
         CArrayObj* entryDeals = pos.EntryDeals();
         CArrayObj* exitDeals = pos.ExitDeals();
         // ���������� �������������� ����� ����� ����� ������������
         // ���������� ������ ����� �� ������
         int entryTotal = entryDeals != NULL ? entryDeals.Total() : 0;
         int exitTotal = exitDeals != NULL ? exitDeals.Total() : 0;
         int total;
         int fontSize = 8;
         if(entryTotal > 0 && entryTotal > exitTotal)
            total = entryTotal;
         else if(exitTotal > 0 && exitTotal > exitTotal)
            total = exitTotal;
         else return;
         color clrSlave = clrSlateGray;
         //���������� ������
         tDir.TableElement(TABLE_DEAL);
         for(int i = 0; i < total; i++)
         {
            //������� ������
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
      /// ������� ������������ ������� �������
      ///
      void DeleteDeals(EventCollapseTree* event)
      {
         //����� ���� � ����������������� ��������?
         ProtoNode* node = event.Node();
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
         int sn_line = node.NLine();
         // ������������ ������� ���� ����� �� ����� ��������.
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
      /*��������������� �������*/
      long ow_twb;
      long ow_magic;
      long ow_symbol;
      long ow_order_id;
      long ow_entry_date;
      long ow_type;
      long ow_vol;
      long ow_price;
      long ow_sl;
      long ow_tp;
      long ow_currprice;
      long ow_profit;
      long ow_comment;
      /*�������� �������*/
      string name_symbol;
      string name_entryOrderId;
      string name_exitOrderId;
      string name_entry_date;
      string name_exit_date;
      string name_type;
      string name_vol;
      string name_entryPrice;
      string name_exitPrice;
      string name_sl;
      string name_tp;
      string name_tralSl;
      string name_currprice;
      string name_profit;
      string name_entryComment;
      string name_exitComment;
      ///
      /// ����� ������ � �����, ������������ ������ �������.
      ///
      int nProfit;
      ///
      /// ����� ������ � �����, ������������ ��������� ���� �����������,
      /// �� �������� ������� �������.
      ///
      int nLastPrice;
      ///
      /// ���������� ����� � �������.
      ///
      int lines;
      
};


 