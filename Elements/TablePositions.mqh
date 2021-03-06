#include "..\Settings.mqh"
#include <Arrays\ArrayInt.mqh>
#include "..\API\Transaction.mqh"
#include "Table.mqh"
#include "TableAbstrPos2.mqh"



#define TABLEPOSITIONS_MQH
///
/// 砫摠儗?闅膴 瀁賥灕?
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
         Table::OnEvent(event);
         switch(event.EventId())
         {
            case EVENT_CHECK_BOX_CHANGED:
               OnCheckBoxChanged(event);
               break;
            case EVENT_COLLAPSE_TREE:
               OnCollapse(event);
               break;
            case EVENT_NODE_CLICK:
               OnNodeClick(event);
               EventSend(event);
               break;
            case EVENT_CHANGE_POS:
               OnChangedPos(event);
               break;
            case EVENT_CREATE_SUMMARY:
               OnCreateSummary(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
      
   private:     
      ///
      /// 挓譇搿譈鴀 勷朢蠂 "襝鳪 儇 瀁賥灕?瞃錌灚?.
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
            uchar ch[1];
            if(event.Checked() == true)
               ch[0] = 254;
            else
               ch[0] = 168;
            tral.Text(CharArrayToString(ch, 0, 1, CP_SYMBOL));
         }
      }
      ///
      /// 鎖錌欑殣/禖膹馲?襝鳪 儇 碫氁 魛蠂碴 瀁賥灕?
      ///
      void OnNodeClick(EventNodeClick* event)
      {
         //椯?鏵臌灕 譇搿蠉殣 襜錪膰 儇 魛蠂碴 瀁賥灕?
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
            // 栱闉僝魤馲?
            if(event.IsCollapse())
               DeleteDeals(event);
            // 冓誺闉僝魤馲?
            else AddDeals(event);
         }
         //秮槦鵴襙 譇誺歑薃譔/鼀歑薃譔 碫?瀁賥灕?
         if(type == ELEMENT_TYPE_TABLE_HEADER_POS)
         {
            int step = workArea.StepCurrent();
            workArea.StepCurrent(0);
            uint tbegin = GetTickCount();
            // 栱闉僝魤馲?瞂嬿 厴黓鍧.
            if(event.IsCollapse())
               CollapseAll();
            // 冓誺闉僝魤馲?瞂嬿 厴黓鍧.
            else RestoreAll();
            workArea.StepCurrent(step);
            //workArea.RefreshVisible();
            //AllocationShow();
            uint tend = GetTickCount();
            uint delta = tend - tbegin;
            //printf("Col/Res: " + (string)delta);
         }
         //挓膼碲樦 譇搿蘼?鍕錟嚦?儇 蜬譇艜麃鍒鳧膼蜦 瀁賥灕鍙麃鍒鳧?
         //嚦豂?
         if(event.NeedRefresh())
            AllocationWorkTable();
         //栴豂錭 謥飹麃鵴?縺 譇誺闉僝魤鳧? 厴黓罻
         //AllocationScroll();
      }
      /*virtual void OnVisible(EventVisible event)
      {
      
      }*/
      ///
      /// 冓誺闉僝魤馲?瞂嬿 厴黓鍧 瀁賥灕?
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
            bool res = i == workArea.ChildsTotal()-1;
            twb.NeedRefresh(res);
            twb.OnPush();
            twb.NeedRefresh(true);
         }
      }
      ///
      /// 栱闉僝魤馲?瞂嬿 厴黓鍧 瀁賥灕?
      ///
      void CollapseAll()
      {
         //for(int i = workArea.ChildsTotal()-1; i >= 0; i--)
         for(int i = 0; i < workArea.ChildsTotal(); i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            if(node.TypeElement() != ELEMENT_TYPE_POSITION)continue;
            PosLine* posLine = node;
            TreeViewBoxBorder* twb = posLine.GetCell(COLUMN_COLLAPSE);
            if(twb != NULL && twb.State() != BOX_TREE_RESTORE)continue;
            bool res = i == workArea.ChildsTotal()-1;
            twb.NeedRefresh(res);
            twb.OnPush();
            twb.NeedRefresh(true);
         }
         
      }

      ///
      /// 栦諙馲?瀁賥灕??蠉摠儗?瀁賥灕?
      ///
      void CreatePosition(Position* pos)
      {
         ulong id = pos.GetId();
         if(!IsItForMe(pos))return;
         PosLine* nline = new PosLine(workArea, TableType(), pos);
         workArea.Add(nline);
      }
      
      ///
      /// 挓膼碲殣 賝僝樇? 瀁賥灕?
      ///
      void RefreshPosition(Position* pos)
      {
         if(!IsItForMe(pos))return;
         PosLine* posLine = pos.PositionLine();
         if(CheckPointer(posLine) == POINTER_INVALID)
            return;
         posLine.RefreshAll();
         //挓膼碲樦 厴黓鍧 碫氁 鼥槶鍧, 殥錒 鍙 譇齕蹖?
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
      /// 赸鳪殣 睯踠鳪鍷 瀔槼嚦飶錼膻?瀁賥灕?鳿 蠉摠儗?
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
         workArea.DeleteRange(posLine.NLine(), 1);
      }
      ///
      /// 挓膼碲殣 碫?鼀鍣嚦瘔 瀁賥灕? 囑錒 瀁賥灕?翴??蠉摠儗?
      /// 鍱縺膰 鍙?儋錛縺 縺羻儰襙 ?翴? 襜 瀁賥灕 摷麧?勷諙鳧?
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
      }
      
      ///
      /// 栦諙馲?鼏鍏鍒嚲 嚦豂膧.
      ///
      void OnCreateSummary(EventCreateSummary* event)
      {
         if(event.TableType() != TableType())return;
         Summary* summary = new Summary(GetPointer(workArea), TableType());
         workArea.Add(summary);
      }
      
      ///
      /// 癩摳碲殣 睯踠鳪鳿僪噮 鼥槶鍧 儇 瀁賥灕?
      ///
      void AddDeals(EventCollapseTree* event)
      {
         ProtoNode* node = event.Node();
         //屙臌灕 鶂槫?譇誺歑譖瘔譔 襜錪膰 瀁賥灕? ??僽鵽鳻?樦樇僗擯 譇搿蠉譔 翴 斁緪?
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
         PosLine* posLine = node;
         //posLine.
         //砐碞闉膼 譇誺闉僝魤僗?鵵?譇誺歑薃覷?瀁賥灕?翴 縺儋.
         //if(posLine.IsRestory())return;
         Position* pos = posLine.Position();
         ulong order_id = pos.EntryOrderId();
         
         Order* entryOrder = pos.EntryOrder();
         CArrayObj* entryDeals = NULL;
         
         Order* exitOrder = pos.ExitOrder();
         CArrayObj exitDeals;
            
         // 扻錒灚嚦碭 儋瀁錍鼏槶 嚦豂?摷麧?譇碴?憵膲鳻鳪鍎
         // 膰錒灚嚦碥 鼥槶鍧 鍱膼?鳿 嚦闉鍙
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
         //盷謥摜譇樦 鼥槶膱
         for(int i = 0; i < total; i++)
         {
            //砱膧╠ 鼥槶罻
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
      /// 赸鳪殣 睯踠鳪鳿僪噮 襝樥儋?瀁賥灕?
      ///
      void DeleteDeals(EventCollapseTree* event)
      {
         //槫?麧鋋 ?睯踠鳪鳿麃鍒鳧膼?瀁賥灕樥?
         ProtoNode* node = event.Node();
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
         int sn_line = node.NLine();
         // 鎔踠鳪鳿僪? 襝樥儋?鳼殣 碫錼?諘 黟斁?瀁賥灕樥.
         int count = 0;
         for(int i = sn_line+1; i < workArea.ChildsTotal(); i++)
         {
            ProtoNode* cnode = workArea.ChildElementAt(i);
            if(cnode.TypeElement() != ELEMENT_TYPE_DEAL)break;
            count++;
         }
         workArea.DeleteRange(sn_line+1, count);
      }
      ///
      /// 鎬誺譇╠殣 黓蠂薃, 殥錒 蠈膧╠ 瀁賥灕 闅膼鼨襙 ?蠈膧╝檍 膰艜樏嚦?蠉摠儗?
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


 