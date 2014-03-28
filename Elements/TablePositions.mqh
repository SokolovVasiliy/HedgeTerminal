#include "..\Settings.mqh"
#include <Arrays\ArrayInt.mqh>
#include "..\API\Transaction.mqh"
#include "Table.mqh"
#include "TableAbstrPos2.mqh"



#define TABLEPOSITIONS_MQH
///
/// ������� �������� �������.
///
class TablePositions : public Table
{
   public:
      TablePositions(ProtoNode* parNode, ENUM_TABLE_TYPE posType = TABLE_POSACTIVE):Table("TableOfPosition.", parNode, posType)
      {
         lineHeader = new HeaderPos(GetPointer(this), posType);
         childNodes.Add(lineHeader);
      }
      
      /*TablePositions(ProtoNode* parNode):Table("TableOfPosition.", parNode, )
      {
         this.Init();
      }*/
      
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_REFRESH:
               if(TableType() == TABLE_POSACTIVE)
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
            case EVENT_CHANGE_POS:
               OnChangedPos(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
      
   private:     
      ///
      /// ���������� ������� "���� ��� ������� �������".
      ///
      void OnCheckBoxChanged(EventCheckBoxChanged* event)
      {
         ProtoNode* node = event.Node();
         if(node.TypeElement() != ELEMENT_TYPE_CHECK_BOX)return;
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
            Label* tral = deal.GetCell(COLUMN_TRAL);
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
      /// ��������/��������� ���� ��� ���� �������� �������.
      ///
      void OnNodeClick(EventNodeClick* event)
      {
         //��� ������� �������� ������ ��� �������� �������.
         if(TableType() != TABLE_POSACTIVE)return;
         ProtoNode* node = event.Node();
         ProtoNode* tralNode = lineHeader.GetCell(COLUMN_TRAL);
         if(tralNode == NULL || node.Name() != tralNode.Name())return;
         if(node.TypeElement() != ELEMENT_TYPE_BOTTON)return;
         Button* btn = node;
         ENUM_BUTTON_STATE state = btn.State();
         int total = workArea.ChildsTotal();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* mnode = workArea.ChildElementAt(i);
            if(mnode.TypeElement() == ELEMENT_TYPE_POSITION)
            {
               PosLine* pos = mnode;
               CheckBox* checkBox = pos.GetCell(COLUMN_TRAL);
               if(checkBox.State() != state)
                  checkBox.State(state);
            }
         }
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
            uint tbegin = GetTickCount();
            // ����������� ���� ������.
            if(event.IsCollapse())
               CollapseAll();
            // ������������� ���� ������.
            else RestoreAll();
            //AllocationShow();
            uint tend = GetTickCount();
            uint delta = tend - tbegin;
            printf("Col/Res: " + (string)delta);
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
            TreeViewBoxBorder* twb = posLine.GetCell(COLUMN_COLLAPSE);
            if(twb != NULL && twb.State() != BOX_TREE_COLLAPSE)continue;
            ENUM_ELEMENT_TYPE elType = twb.TypeElement();
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
            TreeViewBoxBorder* twb = posLine.GetCell(COLUMN_COLLAPSE);
            if(twb != NULL && twb.State() != BOX_TREE_RESTORE)continue;
            twb.OnPush();
         }
         
      }
      
      
      ///
      /// ��������� ���� �������� �������.
      ///
      void RefreshPrices()
      {
         if(TableType() != TABLE_POSACTIVE)return;
         if(!Visible())return;
         int total = workArea.ChildsTotal();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            ENUM_ELEMENT_TYPE el_type = node.TypeElement();
            if(node.TypeElement() != ELEMENT_TYPE_POSITION &&
               node.TypeElement() != ELEMENT_TYPE_DEAL)
               continue;
            AbstractLine* linePos = node;
            linePos.RefreshValue(COLUMN_CURRENT_PRICE);
            linePos.RefreshValue(COLUMN_PROFIT);
         }
      }

      ///
      /// ������� ������� � ������� �������.
      ///
      void CreatePosition(Position* pos)
      {
         if(!IsItForMe(pos))return;
         PosLine* nline = new PosLine(workArea, TableType(), pos);
         workArea.Add(nline);
      }
      
      ///
      /// ��������� �������� �������.
      ///
      void RefreshPosition(Position* pos)
      {
         if(!IsItForMe(pos))return;
         PosLine* posLine = pos.PositionLine();
         if(CheckPointer(posLine) == POINTER_INVALID)
            return;
         posLine.RefreshAll();
         //��������� ������ ���� ������, ���� �� �������.
         ProtoNode* node = posLine.GetCell(COLUMN_COLLAPSE);
         if(node != NULL && node.TypeElement() == ELEMENT_TYPE_TREE_BORDER)
         {
            TreeViewBoxBorder* tbox = node;
            if(tbox.State() == BOX_TREE_RESTORE)
            {
               tbox.OnPush();
               tbox.OnPush();
            }
         }
      }
      
      ///
      /// ������� ���������� ������������� ������� �� �������.
      ///
      void DelPosition(Position* pos)
      {
         if(!IsItForMe(pos))return;
         ENUM_TABLE_TYPE type = TableType();
         PosLine* posLine = pos.PositionLine();
         if(CheckPointer(posLine) == POINTER_INVALID)
            return;
         ProtoNode* node = posLine.GetCell(COLUMN_COLLAPSE);
         if(node != NULL && node.TypeElement() == ELEMENT_TYPE_TREE_BORDER)
         {
            TreeViewBoxBorder* tbox = node;
            if(tbox.State() == BOX_TREE_RESTORE)
               tbox.OnPush();
         }
         workArea.Delete(posLine.NLine());
      }
      ///
      /// ��������� ��� �������� �������. ���� ������� ��� � �������,
      /// ������ ��� ������ ��������� � ���, �� ������� ����� �������.
      ///
      void OnChangedPos(EventPositionChanged* event)
      {
         switch(event.ChangedType())
         {
            case POSITION_SHOW:
               CreatePosition(event.Position());
               break;
            case POSITION_REFRESH:
               RefreshPosition(event.Position());
               break;
            case POSITION_HIDE:
               DelPosition(event.Position());
               break;
         }
         //EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
         //EventSend(er);
         //delete er;
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
         //if(posLine.IsRestory())return;
         Position* pos = posLine.Position();
         ulong order_id = pos.EntryOrderId();
         
         Order* entryOrder = pos.EntryOrder();
         CArrayObj* entryDeals = NULL;
         
         Order* exitOrder = pos.ExitOrder();
         CArrayObj exitDeals;
            
         // ���������� �������������� ����� ����� ����� ������������
         // ���������� ������ ����� �� ������
         int entryTotal = CheckPointer(entryOrder) != POINTER_INVALID ?
                          entryOrder.DealsTotal() : 0;
         int exitTotal = CheckPointer(exitOrder) != POINTER_INVALID ?
                          exitOrder.DealsTotal() : 0;
         int total = 0;
         if(entryTotal > 0 && entryTotal >= exitTotal)
            total = entryTotal;
         else if(exitTotal > 0 && exitTotal > exitTotal)
            total = exitTotal;
         else return;
         //color clrSlave = clrSlateGray;
         //int fontSize = 8;
         //���������� ������
         for(int i = 0; i < total; i++)
         {
            //������� ������
            Deal* entryDeal = NULL;
            if(entryOrder != NULL && i < entryOrder.DealsTotal())
               entryDeal = entryOrder.DealAt(i);
            Deal* exitDeal = NULL;
            if(exitOrder != NULL && i < exitOrder.DealsTotal())
               exitDeal = exitOrder.DealAt(i);
            bool isLast = i == total-1 ? true : false;
            DealLine* nline = new DealLine(workArea, TableType(), pos, entryDeal, exitDeal, isLast);
            workArea.Add(nline, event.NLine()+1);
         }
         //posLine.IsRestory(true);
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
         //PosLine* posLine = node;
         //posLine.IsRestory(false);
      }
      ///
      /// ���������� ������, ���� ������� ������� ��������� � �������� ��������� �������.
      ///
      bool IsItForMe(Position* pos)
      {
         if(CheckPointer(pos) == POINTER_INVALID)return false;
         POSITION_STATUS pType = pos.Status();
         ENUM_TABLE_TYPE tType = TableType();
         bool rs = ((pos.Status() == POSITION_NULL || pos.Status() == POSITION_ACTIVE) && TableType() == TABLE_POSACTIVE) ||
                   (pos.Status() == POSITION_HISTORY && TableType() == TABLE_POSHISTORY);
         return rs;
      }
};


 