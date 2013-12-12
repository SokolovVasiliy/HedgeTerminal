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
            case EVENT_REFRESH_POS:
               OnRefreshPos(event);
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
            case EVENT_DEL_POS:
               OnDelPosition(event);
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
            printf("Col/Res: " + delta);
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
      /// ������������ �������� �� �������� �������.
      ///
      void OnClosePos(EventClosePos* event)
      {
         ;
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
      /// ��������� ��� �������� �������. ���� ������� ��� � �������,
      /// ������ ��� ������ ��������� � ���, �� ������� ����� �������.
      ///
      void OnRefreshPos(EventRefreshPos* event)
      {
         Position* pos = event.Position();
         if(!IsItForMe(pos))return;
         PosLine* posLine = pos.PositionLine();
         if(CheckPointer(posLine) == POINTER_INVALID)
         {
            PosLine* nline = new PosLine(workArea, TableType(), pos);
            workArea.Add(nline);
         }
         else
         {
            //��������� ��� �������������� �������.
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
         EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
         EventSend(er);
         delete er;
      }
      ///
      /// ������� ������� �� ������ �������.
      ///
      void OnDelPosition(EventDelPos* event)
      {
         Position* delPos = event.Position();
         if(!IsItForMe(delPos))return;
         PosLine* posLine = delPos.PositionLine();
         if(CheckPointer(posLine) == POINTER_INVALID)return;
         ProtoNode* node = posLine.GetCell(COLUMN_COLLAPSE);
         if(node != NULL && node.TypeElement() == ELEMENT_TYPE_TREE_BORDER)
         {
            TreeViewBoxBorder* tbox = node;
            if(tbox.State() == BOX_TREE_RESTORE)
            {
               tbox.OnPush();
            }
         }
         workArea.Delete(posLine.NLine());
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
         if(entryTotal > 0 && entryTotal >= exitTotal)
            total = entryTotal;
         else if(exitTotal > 0 && exitTotal > exitTotal)
            total = exitTotal;
         else return;
         color clrSlave = clrSlateGray;
         //���������� ������
         for(int i = 0; i < total; i++)
         {
            //������� ������
            Deal* entryDeal = NULL;
            if(entryDeals != NULL && i < entryDeals.Total())
               entryDeal = entryDeals.At(i);
            Deal* exitDeal = NULL;
            if(exitDeals != NULL && i < exitDeals.Total())
               exitDeal = exitDeals.At(i);
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
         ENUM_POSITION_STATUS pType = pos.PositionStatus();
         ENUM_TABLE_TYPE tType = TableType();
         bool rs = (pos.PositionStatus() == POSITION_STATUS_OPEN && TableType() == TABLE_POSACTIVE) ||
                   (pos.PositionStatus() == POSITION_STATUS_CLOSED && TableType() == TABLE_POSHISTORY);
         return rs;
      }
};


 