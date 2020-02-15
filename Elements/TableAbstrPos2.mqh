#include "Table.mqh"
#include "..\Math\Math.mqh"
#include "Node.mqh"
#include "TextNode.mqh"
#include "..\Settings.mqh"
#include "..\API\Position.mqh"

///
///
class AbstractLine : public Line
{
   public:
      ///
      /// 
      ///
      ENUM_TABLE_TYPE TableType(){return tblType;}
      ///
      ///
      void RefreshAll()
      {
         int total = ArraySize(textNodes);
         for(int i = 0; i < total; i++)
            RefreshValue((ENUM_COLUMN_TYPE)i);
      }
      ///
      ///
      void RefreshValue(ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(textNodes) > cType &&
            CheckPointer(textNodes[cType]) != POINTER_INVALID)
         {
            textNodes[cType].Text(GetStringValue(cType));
            if(cType == COLUMN_ENTRY_COMMENT || cType == COLUMN_EXIT_COMMENT)
               textNodes[cType].Tooltip(GetStringValue(cType));
            OnRefreshValue(cType);
         }
      }
      ///
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
      ///
      /// 鎬誺譇╠殣 嚭膧 縺 灚濋?
      ///
      TextNode* GetCellText(ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(textNodes) > cType &&
            CheckPointer(textNodes[cType]) != POINTER_INVALID)
         {
            return textNodes[cType];
         }
         return NULL;
      }
   protected:
      ///
      /// 栱賙?灚濋?蠈膲? 
      ///
      class tnode
      {
         public:
            ///
            /// 迾馵僗槶?縺 灚濋? 膰襜賾?縺儋 儋摳睯譔 ?厴黓鍧.
            ///
            ProtoNode* element;
            ///
            /// 迾馵僗槶?縺 灚濋? 蠈膲?膰襜豂?斁緱?懤?譔.
            ///
            TextNode* value;
      };
      
      AbstractLine(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode, ENUM_TABLE_TYPE tType) : Line(myName, elType, parNode)
      {
         tblType = tType;
      }
      virtual string GetStringValue(ENUM_COLUMN_TYPE cType)
      {
         return EnumToString(cType);
      }
      ///
      /// 栦諙馲?樦樇?瀁-鶂鎀欑膻?
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
      /// 栦諙馲??碭誺譇╠殣 樦樇?瀁-鶂鎀欑膻?
      ///
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         EditNode* build = NULL;
         build = new Label(el.Name(), GetPointer(this));
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      ///
      /// 侲瀁錍殣 錒膻?樦樇蠉擯 黓瀁錪踠 櫇謥闀謥麧錼臇 GetColumn().
      /// 雞賧?鏵臌灕?儋錛樇 闃齍殥蠋?襙 玴捀?鴈儗魰錒諘灕?膰艚襝鵳襜譇 摳賧碭蜦 膹僔黟.
      ///
      void BuilderLine()
      {
         //if(CheckPointer(Settings) == POINTER_INVALID)return;
         //砐鋹欑樦 厴黓鍧 膰鋋膼? 膰襜蹖?縺儋 鼖樇歑麃鍒僗?
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
               //囑錒 蠂?蠉摠儗?翴鳿瞂嚦樇, 襜 ?蜲翴謶豂瘔譔 翴灚蜦.
               return; 
         }
         //婜謽麃鵴?錒膻?
         int total = scolumns.Total();
         for(int i = 0; i < total; i++)
         {
            TextNode* value = NULL;
            DefColumn* el = scolumns.At(i);
            ENUM_COLUMN_TYPE cType = el.ColumnType();
            int dbg = -1;
            if(cType == COLUMN_PROFIT && TypeElement() == ELEMENT_TYPE_POSITION)
               dbg = COLUMN_PROFIT;
            tnode* node = GetColumn(el);
            
            SetSkinMode(node.element);
            
            if(CheckPointer(node.element) != POINTER_INVALID)
            {
               int s = ArraySize(protoNodes);
               Add(node.element);
               if(ArraySize(protoNodes) <= cType)
                  ArrayResize(protoNodes, cType+1);
               protoNodes[cType] = node.element;
            }
            if(CheckPointer(node.value) != POINTER_INVALID)
            {
               int s = ArraySize(textNodes);
               if(ArraySize(textNodes) <= cType)
                  ArrayResize(textNodes, cType+1);
               textNodes[cType] = node.value;
            }
            delete node;
         }
      }
      ///
      /// 雞踑瘔殣? 瀔?鍕膼碲樇鳷 膰鋋臌?cType ?櫇謥闀謥麧?殣? 儋灚謺鳻 膹僔勷?
      ///
      virtual void OnRefreshValue(ENUM_COLUMN_TYPE cType){;}
      
      
      ///
      /// 魡殣 蜸僳儚殥膰?瀔槼嚦飶錼膻?儇 碫?蠉摠儗?
      ///
      void SetSkinMode(ProtoNode* node)
      {
         if(TypeElement() == ELEMENT_TYPE_TABLE_HEADER_POS)
            node.BorderColor(Settings.ColorTheme.GetBorderColor());
         else
            node.BorderColor(Settings.ColorTheme.GetSystemColor1());
      }
   private:
      ENUM_TABLE_TYPE tblType;
      ///
      /// 犧 朢嚦豂蜦 儋嚦鵿??賝僝樇??嚦豂膱 蠉耩?臝鳧鳻 嚭膱 縺 灚濋?
      ///
      TextNode* textNodes[];
      ///
      /// 犧 朢嚦豂蜦 儋嚦鵿??樦樇蠉?嚦豂膱 蠉耩?臝鳧鳻 嚭膱 縺 樦樇譖.
      ///
      ProtoNode* protoNodes[];
      ///
      /// 僝樇鳺 擯膻憵錪膼蜦 鳿懤翴膻 欈蕻 (PriceStep);
      ///
      double ticksize;
};

//class 
///
/// 抔僔?謥鳪鳿鵴?嚦豂膧-諘蜦鋋碭?蠉摠儗?瀁賥灕?
///
class HeaderPos : public AbstractLine
{
   public:
      HeaderPos(ProtoNode* parNode, ENUM_TABLE_TYPE tType) : AbstractLine("header", ELEMENT_TYPE_TABLE_HEADER_POS, parNode, tType)
      {
         BuilderLine();
      }
   private:
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         TextNode* build = NULL;
         //?闅錒玁?闅 謥鳪鳿僪鳷 瀁-鶂鎀欑膻?勷諙馲襙 膫闀罻, ?翴 蠈膲襜瘔 懤襚?
         build = new Button(el.Name(), GetPointer(this));
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      ///
      /// 栦諙馲?樦樇?瀁-鶂鎀欑膻?
      ///
      void OnEvent(Event* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN &&
            event.EventId() == EVENT_NODE_CLICK)
         {
            Button* btn = event.Node();
            if(btn.State() == BUTTON_STATE_ON)
            {
               btn.State(BUTTON_STATE_OFF);
               LogWriter("Order not support in this version.", MESSAGE_TYPE_INFO);
            }
         }
         EventSend(event);
      }
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
         //殥?鵨蠉縺碲魤馲?儋瀁錍鼏槶 鍕╕?鼀鍣嚦瘔 儇 嚦豂膱
         return comby;
      }
      ///
      /// 栦諙馲?樦樇?儇 闅膴?/諘膴? 碫樍?厴黓罻.
      ///
      TextNode* GetCollapseEl(DefColumn* el)
      {
         TextNode* tbox = NULL;
         string sname = el.Name();
         //勂緱?鼖樇歑麃鍒僗?樦樇?儇 諘蜦鋋瞃?蠉摠儗?
         tbox = new TreeViewBox(sname, GetPointer(this), BOX_TREE_GENERAL);
         tbox.Text("+");
         // 迶蠉縺碲魤馲?闃蠉禘鳺? 鼀鍣嚦瘔.
         tbox.OptimalWidth(el.OptimalWidth());
         tbox.ConstWidth(el.ConstWidth());
         return tbox;
      }
      ///
      /// 癩摳碲殣 鐏飹 襝鳪?
      ///
      TextNode* GetTralEl(DefColumn* el)
      {
         TextNode* build = NULL;
         build = GetDefaultEl(el);
         build.Text(CharToString(79));
         build.Font("Wingdings");
         build.Tooltip("Move the stop order after the price.");
         return build;
      }
};

///
/// 抔僔?謥鳪鳿鵴?嚦豂膧-瀁賥灕?蠉摠儗?瀁賥灕?
///
class PosLine : public AbstractLine
{
   public:
      PosLine(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* m_pos) : AbstractLine("PosLine", ELEMENT_TYPE_POSITION, parNode, tType)
      {
         if(CheckPointer(m_pos) != POINTER_INVALID)
            pos = m_pos;
         BuilderLine();
         pos.PositionLine(GetPointer(this));
      }
      ///
      /// 鎬誺譇╠殣 鵳馵僗槶?縺 瀁賥灕? ?膰襜豂?僔勷灕麃鍒鳧?魡臇? 嚦豂罻.
      ///
      Position* Position()
      {
         return pos;
      }
      
      virtual int Compare(const CObject *node, const int mode=0) const 
      {
         return 0;
      }
      ///
      /// 挓膼碲殣 瀁襜膰禖?欈蕻 ?攦殣??嚦闀/蠈濋 闉麧豂?
      ///
      void RefreshPrices()
      {
         HighlightingSL();
         HighlightingTP();
         TextNode* node = GetCellText(COLUMN_PROFIT);
         if(node != NULL)
            node.Text(GetStringValue(COLUMN_PROFIT));
         node = GetCellText(COLUMN_CURRENT_PRICE);
         if(node != NULL)
            node.Text(GetStringValue(COLUMN_CURRENT_PRICE));
         //挓膼碲樦 鼥槶膱 殥錒 鍙?闅膴?
         RefreshPricesDeals();
      }
      ///
      /// 挓膼碲殣 賝僝樇? ?鼥槶鍧.
      ///
      void RefreshPricesDeals()
      {
         int i = 1;
         while(NLine()+i < parentNode.ChildsTotal())
         {
            ProtoNode* node = parentNode.ChildElementAt(NLine()+i);
            if(node.TypeElement() != ELEMENT_TYPE_DEAL)
               break;
            DealLine* deal = node;
            deal.RefreshPrice();
            i++;
         }
      }
   private:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_CLOSE_POS:
               if(event.Direction() == EVENT_FROM_DOWN)
                  OnClosePos();
               break;
            case EVENT_END_EDIT_NODE:
               IndefyEndEditNode(event);
               break;
            case EVENT_BLOCK_POS:
               OnBlockPos(event);
               break;
            case EVENT_CHECK_BOX_CHANGED:
               OnChangeTral(event);
               break;
            default:
               EventSend(event);
         }
      }
      ///
      /// 
      ///
      void OnChangeTral(EventCheckBoxChanged* event)
      {
         pos.TralStopOrder.TralEnable(event.Checked());
         CheckBox* check = event.Node();
         check.Tooltip("Tral delta: " +  DoubleToString(pos.TralStopOrder.TralDelta(), pos.InstrumentDigits()));
         if(pos.TralStopOrder.TralEnable())   
            check.State(BUTTON_STATE_ON);
         else
            check.State(BUTTON_STATE_OFF);
      }
      ///
      /// 樇蠂鐓灕賾殣 ?罻膰?鳻樇膼 鵰錼 瀔鍞賧齴?鳿懤翴膻?
      /// ??諘睯鼨斁嚦?闅 鍏? 禖踑瘔殣 勷闅瞂襙蠋嚲╕?鳪蜦謶襗 鍕譇搿襚?
      ///
      void IndefyEndEditNode(EventEndEditNode* event)
      {
         EditNode* ch_node = event.Node();
         int index = ch_node.NLine();
         
         ENUM_COLUMN_TYPE clType;
         for(int i = 0; i < 10; i++)
         {
            switch(i)
            {
               case 0:
                  clType = COLUMN_VOLUME;
                  break;
               case 1:
                  clType = COLUMN_SL;
                  break;
               case 2:
                  clType = COLUMN_EXIT_COMMENT;
                  break;
               case 3:
                  clType = COLUMN_TP;
                  break;
               default:
                  return;
            }
            ProtoNode* node = GetCell(clType);
            if(node == NULL)return;
            if(ch_node == node)
            {
               switch(clType)
               {
                  case COLUMN_VOLUME:  
                     OnClosePartPos(event.Node());
                     break;
                  case COLUMN_SL:
                     OnStopLossModify(event.Node());
                     break;
                  case COLUMN_TP:
                     OnTakeProfitModify(event.Node());
                     break;
                  case COLUMN_EXIT_COMMENT:
                     OnCommentModify(event.Node());
                     break;
               }
            }
         }
      }
      
      ///
      /// 砐錍闃譔?諘膴馲?瀁賥灕?
      ///
      void OnClosePos()
      {
         if(pos.Status() != POSITION_ACTIVE)return;
         string value = GetStringValue(COLUMN_EXIT_COMMENT);
         Tiks = GetTickCount();
         //printf("Close pos. :" + (string)GetTickCount());
         //婜謽麃鵴?諘魡膻?縺 諘膴鳺 瀁賥灕?
         //Task* closePos = new TaskClosePos(pos);
         //pos.AddTask(closePos);
         //pos.AsynchClose(pos.VolumeExecuted(), value);
         //砎鍒歑樦, 斁緪?錒 檞 諘膴?瀁賥灕?
         //...
         TaskClosePosition* cPos = new TaskClosePosition(pos, MAGIC_TYPE_MARKET, Settings.GetDeviation(), true);
         pos.AddTask(cPos);
         //TaskClosePos* closePos = new TaskClosePos(pos, value);
         //pos.AddTask(closePos);
      }
      
      ///
      /// 挓譇摳譖瘔殣 瀔鴀馵 縺 諘膴鳺 欑嚦?魛蠂碴鍣 瀁賥灕?
      ///
      void OnClosePartPos(EditNode* editNode)
      {
         double setVol = StringToDouble(editNode.Text());
         double curVol = pos.VolumeExecuted();
         
         if(!pos.IsValidNewVolume(setVol))
         {
            editNode.Text(pos.VolumeToString(curVol));
            return;
         }
         editNode.Text(pos.VolumeToString(setVol)+"...");
         //string exitComment = GetStringValue(COLUMN_EXIT_COMMENT);
         double vol = curVol < setVol ? setVol : curVol - setVol;
         pos.AddTask(new TaskClosePartPosition(pos, vol, Settings.GetDeviation(), true));
         //pos.AsynchClose(vol, exitComment);
      }
      
      ///
      /// 沓儰鐓罻灕 黓羻?╝蜦 膰擤樇蠉 ?黓羻?╝?膰擤樇蠉謶?
      ///
      void OnCommentModify(EditNode* editNode)
      {
         string comment = editNode.Text();
         pos.ExitComment(comment, true);
      }
      ///
      /// 昳豵飶?殣 瀔鴀馵 縺 勷諙鳧鳺/斁儰鐓罻灕?鶇鍒? 嚦闀-鋋嚭.
      ///
      void OnStopLossModify(EditNode* editNode)
      {
         double setPrice = StringToDouble(editNode.Text());
         pos.StopLossLevel(setPrice);
         HighlightingSL();
      }
      ///
      /// 挓譇搿譈鴀 斁儰鐓罻灕?鶇鍒? 蠈濋-瀔隮鼏?
      ///
      void OnTakeProfitModify(EditNode* editNode)
      {
         double setPrice = StringToDouble(editNode.Text());
         pos.TakeProfitLevel(setPrice, true);
         HighlightingTP();
      }
      ///
      /// 挓譇摳譖瘔殣 勷朢蠂?摠鍧麃鍒膱 瀁賥灕?
      ///
      void OnBlockPos(EventBlockPosition* event)
      {
         if(pos != event.Position())return;
         if(event.Status())
            BlockedCell(true);
         else
            BlockedCell(false);
      }
      ///
      /// 鍛鍧麃鵴?謥魡膷麃鍒鳧鳺 蠈膲蠉 ?灚濋僛, 膰襜蹖?瀁誺鎀
      /// 樍?謥魡膷麃鍒僗?
      ///
      void BlockedCell(bool block)
      {
         EditNode* cell = GetCell(COLUMN_VOLUME);
         if(cell != NULL)
            cell.ReadOnly(block);
         cell = GetCell(COLUMN_SL);
         if(cell != NULL)
            cell.ReadOnly(block);
         cell = GetCell(COLUMN_TP);
         if(cell != NULL)   
            cell.ReadOnly(block);
         cell = GetCell(COLUMN_EXIT_COMMENT);
         if(cell != NULL)
            cell.ReadOnly(block);
         if(block)
            SetColorLine(clrRed);
         else
            SetColorLine(Settings.ColorTheme.GetTextColor());
      }
      
      ///
      /// 冓諃鋋膱豂禖瘔殣 謥魡膷麃鍒鳧鳺 蠈膲蠉 ?灚濋僛, 膰襜蹖?瀁誺鎀
      /// 樍?謥魡膷麃鍒僗?
      ///
      void UnBlockedCell()
      {
         //LogWriter("Task complete for " + (string)(GetTickCount()-tiks) + " msc.", MESSAGE_TYPE_INFO);
         //tiks = 0;
         EditNode* cell = GetCell(COLUMN_VOLUME);
         double vol = pos.VolumeExecuted();
         cell.Text(pos.VolumeToString(vol));
         cell.ReadOnly(false);
         
         cell = GetCell(COLUMN_SL);
         //double sl = pos.StopLossLevel();
         //cell.Text(pos.PriceToString(sl));
         if(pos.Status() == POSITION_ACTIVE)
            cell.ReadOnly(false);
         cell.FontColor(clrRed);
         TextNode* m = childNodes.At(0);
         SetColorLine(Settings.ColorTheme.GetTextColor());
      }
      
      ///
      /// 迶蠉縺碲魤馲?攦殣 蠈膲襜禖?勷鍕╝膻?
      ///
      void SetColorLine(color clr)
      {
         for(int i = 0; i < childNodes.Total(); i++)
         {
            TextNode* m = childNodes.At(i);
            //if(m.TypeElement() != ELEMENT_TYPE_LABEL)continue;
            TextNode* cell = m;
            cell.FontColor(clr);
         }
         TextNode* node = GetCell(COLUMN_PROFIT);
         if(node == NULL)return;
         for(int i = 0; i < node.ChildsTotal(); i++)
         {
            TextNode* n = node.ChildElementAt(i);
            n.FontColor(clr);
         }
      }
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
            case COLUMN_TP:
               comby.element = GetTPNode(el);
               comby.value = comby.element;
               break;
            case COLUMN_VOLUME:
            case COLUMN_EXIT_MAGIC:
            case COLUMN_EXIT_COMMENT:
               comby.element = GetDefaultEditEl(el);
               comby.value = comby.element;
               break;
            case COLUMN_SL:
               comby.element = GetSLNode(el);
               comby.value = comby.element;
               break;
            default:
               comby.element = GetDefaultEl(el);
               comby.value = comby.element;
               //if(cType == COLUMN_VOLUME)
               //   comby.element.Edit(true);
               break;
         }
         if(CheckPointer(comby.value) != POINTER_INVALID)   
            comby.value.Text(GetStringValue(cType));
         switch(cType)
         {
            case COLUMN_ENTRY_COMMENT:
            case COLUMN_EXIT_COMMENT:
            case COLUMN_ENTRY_DATE:
            case COLUMN_EXIT_DATE:
               comby.element.Tooltip(GetStringValue(cType));
               break;
         }
         return comby;
      }
      
      EditNode* GetDefaultEditEl(DefColumn* el)
      {
         EditNode* enode = GetDefaultEl(el);
         if(TableType() == TABLE_POSACTIVE)
            enode.ReadOnly(false);
         return enode;
      }
      
      TextNode* GetCollapseEl(DefColumn* el)
      {
         Label* tbox = NULL;
         tbox = new TreeViewBoxBorder(el.Name(), GetPointer(this), BOX_TREE_GENERAL);
         tbox.BorderColor(clrGreen);
         tbox.OptimalWidth(el.OptimalWidth());
         tbox.ConstWidth(el.ConstWidth());
         return tbox;
      }
      
      TextNode* GetSLNode(DefColumn* el)
      {
         EditNode* enode = GetDefaultEditEl(el);
         if(pos.UsingStopLoss())
         {
            Order* order = pos.StopOrder();
            enode.Tooltip("Based on order #" + (string)order.GetId());
         }
         if(pos.Status() != POSITION_HISTORY)
            return enode;
         Order* exitOrder = pos.ExitOrder();
         if(exitOrder.IsStopLoss())
         {
            enode.SetBlockBgColor(clrPink);         
            int dir = pos.Direction() == DIRECTION_LONG ? 1 : -1;
            string tt = "Based on order #" + (string)exitOrder.GetId() + "; Slipage: " + pos.PriceToString(exitOrder.Slippage());
            enode.Tooltip(tt);
         }
         return enode;
      }
      
      TextNode* GetTPNode(DefColumn* el)
      {
         EditNode* enode = GetDefaultEditEl(el);
         if(pos.Status() != POSITION_HISTORY)
            return enode;
         Order* exitOrder = pos.ExitOrder();
         if(exitOrder.IsTakeProfit())
         {
            enode.SetBlockBgColor(clrLightGreen);         
         }
         return enode;
      }
      
      CheckBox* GetTralEl(DefColumn* el)
      {
         CheckBox* build = NULL;
         build = new CheckBox(el.Name(), GetPointer(this));
         uchar ch[] = {168};
         build.Text(CharArrayToString(ch, 0, 1, CP_SYMBOL));
         build.Font("Wingdings");
         build.FontSize(12);
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         build.BackgroundColor(Settings.ColorTheme.GetSystemColor2());
         return build;
      }
      
      tnode* GetProfitEl(DefColumn* el)
      {
         tnode* comby = new tnode();
         Line* element = NULL;
         //?諘睯鼨斁嚦?闅 襜蜦, 碲殣? 錒 瀁賥灕 黓襜謶灚齕鍣 鳹?魛蠂碴鍣,
         //灚濋?瀁罻踑瘔? 瀔隮鼏 勷嚦鍞?鳿 譇賝?欑嚦樥. 
         if(TableType() == TABLE_POSACTIVE)
         {
            element = new Line(el.Name(), GetPointer(this));
            element.AlignType(LINE_ALIGN_CELLBUTTON);
            Label* profit = new Label(el.Name(), element);
            profit.BorderColor(Settings.ColorTheme.GetSystemColor2());
            comby.value = profit;
            ButtonClosePos* btnClose = new ButtonClosePos("btnClosePos.", element);
            btnClose.BorderColor(Settings.ColorTheme.GetSystemColor2());
            btnClose.Font("Wingdings");
            btnClose.FontSize(12);
            uchar ch[1] = {251};
            string cl = CharArrayToString(ch, 0, 1, CP_SYMBOL);
            btnClose.Text(cl);
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
      /// 挓膼碲殣 睯踠鳪鍷 瀔槼嚦飶錼膻?瀁賥灕?
      ///
      virtual string GetStringValue(ENUM_COLUMN_TYPE cType)
      {
         string value = EnumToString(cType);
         //鐕謽僪? ?瀁賥灕?儋錛縺 朢譔 碫樍魡
         if(CheckPointer(pos) == POINTER_INVALID)return value;
         CTime* time = NULL;
         switch(cType)
         {
            case COLUMN_MAGIC:
               if(!pos.Unmanagment())
               {
                  if(pos.EntryMagic() == 0)
                     value = "Manual";
                  else
                     value = Settings.GetNameExpertByMagic(pos.EntryMagic());
               }
               else
               {
                  #ifdef RELEASE
                  value = "";
                  #else
                  value = "UNMANAGMENT";
                  #endif
               }
               break;
            case COLUMN_SYMBOL:
               value = pos.Symbol();
               break;
            case COLUMN_ENTRY_ORDER_ID:
               value = (string)pos.EntryOrderId();
               break;
            case COLUMN_EXIT_ORDER_ID:
               value = (string)pos.ExitOrderId();
               break;
            case COLUMN_EXIT_MAGIC:
               value = (string)pos.ExitMagic();
               break;
            case COLUMN_ENTRY_DATE:
               time = new CTime(pos.EntryExecutedTime());
               value = time.TimeToString(TIME_DATE | TIME_MINUTES | TIME_SECONDS);
               delete time;
               break;
            case COLUMN_EXIT_DATE:
               time = new CTime(pos.ExitExecutedTime());   
               value = time.TimeToString(TIME_DATE | TIME_MINUTES | TIME_SECONDS);
               delete time;
               break;
            case COLUMN_TYPE:
               value = pos.TypeAsString();
               break;
            case COLUMN_VOLUME:
               value = pos.VolumeToString(pos.VolumeExecuted());
               break;
            case COLUMN_ENTRY_PRICE:
               value = pos.PriceToString(pos.EntryExecutedPrice());
               break;
            case COLUMN_SL:
            {
               double sl = pos.StopLossLevel();
               if(Math::DoubleEquals(sl, 0.0))
                  value = "";
               else
                  value = pos.PriceToString(sl);
               break;
            }
            case COLUMN_TP:
            {
               int dbg = 5;
               if(pos.EntryOrderId() == 1009985306)
                  dbg = 6;
               double tp = pos.TakeProfitLevel();
               if(Math::DoubleEquals(tp, 0.0))
                  value = "";
               else
                  value = pos.PriceToString(tp);
               break;
            }
            case COLUMN_TRAL:
               if(pos.UsingStopLoss())
               {
                  uchar ch[] = {254};
                  value = CharArrayToString(ch, 0, 1, CP_SYMBOL);
               }
               else
               {
                  uchar ch[] = {168};
                  value = CharArrayToString(ch, 0, 1, CP_SYMBOL);
               }
               break;
            case COLUMN_EXIT_PRICE:
               value = pos.PriceToString(pos.ExitExecutedPrice());
               break;
            case COLUMN_CURRENT_PRICE:
               value = pos.PriceToString(pos.CurrentPrice());
               break;
            case COLUMN_COMMISSION:
               value = DoubleToString(pos.Commission(), 2);
               break;
            case COLUMN_PROFIT:
               value = DoubleToString(pos.ProfitInCurrency(), 2);
               //value = pos.ProfitAsString();
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
      /// 昜謥麧?樦 儋瀁錍鼏槶 麧濄蠋? 瀔?鍕膼碲樇鳷 欈?
      ///
      /*virtual void OnRefreshValue(ENUM_COLUMN_TYPE cType)
      {
         if(cType != COLUMN_PROFIT)return;
         HighlightingSL();
         HighlightingTP();
      }*/
      
      ///
      /// 砐儊瞂玁瘔膻?灚濋?嚦闀-鋋嚭?
      ///
      void HighlightingSL()
      {
         double sl = pos.StopLossLevel();
         if(Math::DoubleEquals(sl, 0.0))return;
         double delta = MathAbs(pos.CurrentPrice() - sl);
         TextNode* node = GetCell(COLUMN_SL);
         if(node == NULL)return;
         int steps = Settings.GetPriceStepCount();
         if(stepValue < 0.00001)
            stepValue = SymbolInfoDouble(pos.Symbol(), SYMBOL_TRADE_TICK_SIZE);
         if(delta <= steps*stepValue)
            node.BackgroundColor(clrPink);
         //秏蠉樦? 碭嚭蠉膼睯譔 攦殣
         else if(node.BackgroundColor() == clrPink)
         {
            color restoreClr = clrWhite;
            //鍊謥?櫇謼 瀁櫡禘鴇? 攦殣.
            for(int i = 0; i < childNodes.Total(); i++)
            {
               ProtoNode* anyNode = childNodes.At(i);
               restoreClr = anyNode.BackgroundColor();
               break;
            }
            node.BackgroundColor(restoreClr);
         }
      }
      ///
      /// 砐儊瞂玁瘔膻?灚濋?蠈濋-瀔隮鼏?
      ///
      void HighlightingTP()
      {
         TextNode* node = GetCell(COLUMN_TP);
         if(node == NULL)return;
         double tp = pos.TakeProfitLevel();
         if(Math::DoubleEquals(tp, 0.0))
         {
            RestoreColor(node);
            return;
         }
         double delta = MathAbs(pos.CurrentPrice() - tp);
         int steps = Settings.GetPriceStepCount();
         if(stepValue < 0.00001)
            stepValue = SymbolInfoDouble(pos.Symbol(), SYMBOL_TRADE_TICK_SIZE);
         if(delta <= steps*stepValue)
            node.BackgroundColor(clrLightGreen);
         //秏蠉樦? 碭嚭蠉膼睯譔 攦殣
         else if(node.BackgroundColor() == clrLightGreen)
            RestoreColor(node);
      }
      
      void RestoreColor(TextNode* node)
      {
         color restoreClr = clrWhite;
         //鍊謥?櫇謼 瀁櫡禘鴇? 攦殣.
         for(int i = 0; i < childNodes.Total(); i++)
         {
            ProtoNode* anyNode = childNodes.At(i);
            restoreClr = anyNode.BackgroundColor();
            break;
         }
         node.BackgroundColor(restoreClr);
      }
      ///
      /// 迾馵僗槶?縺 瀁賥灕? 膰襜賾?瀔槼嚦飶?殣 魡臇? 嚦豂罻.
      ///
      Position* pos;
      ///
      /// 瀁擯縺殣 膰?碭 蠂膰??斁懤艜?櫇謼鍏?諘瀀齕??儴鵵鼏
      /// 儇 譇壝殣?禖瀁錍樇? 齕闉闃蠂 闀歑僪鳷.
      ///
      long tiks;
      ///
      /// 醫錒玁縺 鍱膼蜦 瀔骫嚭蠈櫡 ?瀀臌蠉?鴈嚦賾懤艜?
      ///
      double stepValue;
      int countPS;
      
};

///
/// 抔僔?謥鳪鳿鵴?嚦豂膧-瀁賥灕?蠉摠儗?瀁賥灕?
///
class DealLine : public AbstractLine
{
   public:
      DealLine(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* mpos, Deal* EntryDeal, Deal* ExitDeal, bool IsLastLine):
      AbstractLine("Deal", ELEMENT_TYPE_DEAL, parNode, tType)
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
      ///
      /// 挓膼碲殣 欈蕻
      ///
      void RefreshPrice()
      {
         TextNode* mnode = GetCellText(COLUMN_CURRENT_PRICE);
         if(mnode != NULL)
            mnode.Text(GetStringValue(COLUMN_CURRENT_PRICE));
         mnode = GetCellText(COLUMN_PROFIT);
         if(mnode != NULL)
            mnode.Text(GetStringValue(COLUMN_PROFIT));
      }
   private:
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         TextNode* build = AbstractLine::GetDefaultEl(el);
         build.FontSize(build.FontSize()-2);
         build.FontColor(C'70,70,70');
         //build.FontColor(clrDimGray);
         /*build.Font("Arial Rounded MT Bold");
         build.Font("Consolas");
         build.Font("Georgia");
         build.Font("Arial Italic");
         build.Font("Courier New");*/
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
            /*case COLUMN_TRAL:
               comby.element = GetTralEl(el);
               comby.value = comby.element;
               break;*/
            default:
               comby.element = GetDefaultEl(el);
               comby.value = comby.element;
               break;
         }
         if(CheckPointer(comby.value) != POINTER_INVALID)
            comby.value.Text(GetStringValue(cType));
         if(cType == COLUMN_VOLUME)
            comby.value.Tooltip(GetStringValue(cType));
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
                  value = (string)entryDeal.GetId();
               break;
            case COLUMN_EXIT_ORDER_ID:
               if(exitDeal != NULL)
                  value = (string)exitDeal.GetId();
               break;
            case COLUMN_ENTRY_DATE:
               if(entryDeal != NULL)
               {
                  CTime* time = new CTime(entryDeal.TimeExecuted());   
                  value = time.TimeToString(TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                  delete time;
               }
               break;
            case COLUMN_EXIT_DATE:
               if(exitDeal != NULL)
               {
                  CTime* time = new CTime(exitDeal.TimeExecuted());
                  value = time.TimeToString(TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                  delete time;
               }
               break;
            case COLUMN_TYPE:
               value = "deal";
               break;
            case COLUMN_VOLUME:
               if(entryDeal != NULL)
                  value = entryDeal.VolumeToString(entryDeal.VolumeExecuted());
               if(exitDeal != NULL)
                  value += "/" + exitDeal.VolumeToString(exitDeal.VolumeExecuted());
               break;
            case COLUMN_ENTRY_PRICE:
               if(entryDeal != NULL)
                  value = entryDeal.PriceToString(entryDeal.EntryExecutedPrice());
               break;
            case COLUMN_SL:
               /*if(!Math::DoubleEquals(pos.StopLossLevel(), 0.0))
                  value = pos.PriceToString(pos.StopLossLevel());
               else
                  value = "-";*/
               value = "";   
               break;
            case COLUMN_TP:
               value = "";
               break;
            case COLUMN_TRAL:
               
               /*if(pos != NULL && pos.TralStopOrder.TralEnable())
                  value = CharToString(254);
               else
                  value = CharToString(168);*/
               value = "";
               break;
            case COLUMN_EXIT_PRICE:
               if(exitDeal != NULL)
                  value = exitDeal.PriceToString(exitDeal.EntryExecutedPrice());
               break;
            case COLUMN_CURRENT_PRICE:
               if(pos != NULL)
                  value = pos.PriceToString(pos.CurrentPrice());
               break;
            case COLUMN_COMMISSION:
            {
               double comm = 0.0;
               if(exitDeal != NULL)
                  comm += exitDeal.Commission();
               if(entryDeal != NULL)
                  comm += entryDeal.Commission();
               value = DoubleToString(comm, 2);
               break;
            }
            case COLUMN_PROFIT:
               value = "";
               //value = DoubleToString(defDeal.ProfitInCurrency(), 2);
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
      /// 砐賥灕, ?膰襜豂?瀔鴈馯錼糈?蠈膧╕?襝樥噊 (殥錒 殥譔).
      ///
      Position* pos;
      ///
      /// 栵槶罻 碬鍱??瀁賥灕?(殥錒 殥譔).
      ///
      Deal* entryDeal;
      ///
      /// 栵槶罻 禖羻魡 鳿 瀁賥灕?(殥錒 殥譔).
      ///
      Deal* exitDeal;
      ///
      /// 蠂縺, 殥錒 蠈膧╠ 嚦豂罻, 瀔槼嚦飶?? 襝樥?瀁儴槼? ?厴黓耪 襝樥儋?
      ///
      bool isLastLine;
      
};

///
/// 鍏鍒? 嚦豂罻 蠉摠儗?
///
class Summary : public AbstractLine
{
   public:
      Summary(ProtoNode* parNode, ENUM_TABLE_TYPE tType) : AbstractLine("Summary", ELEMENT_TYPE_TABLE_SUMMARY, parNode, tType)
      {
         countHistory = -1;
         typeTable = tType;
         textNode = new Label("summary", GetPointer(this));
         textNode.Font("\\Resources\\Fonts\\Arial Rounded MT Bold Bold.ttf");
         textNode.Font("Arial Rounded MT Bold");
         textNode.Text("Summary Active Positions");
         textNode.FontSize(9);
         //textNode.Font("Arial Black");
         textNode.BackgroundColor(clrGainsboro);
         textNode.BorderColor(Settings.ColorTheme.GetSystemColor2());
         Add(textNode);
         if(typeTable == TABLE_POSHISTORY)
            RefreshHistory();
      }
      ///
      /// 挓膼碲殣 蠈膲?鼏鍏鍒鍣 嚦豂膱 儇 魛蠂碴鍣 蠉摠儗?
      ///
      /*void RefreshSummury(void)
      {
         if(TableType() == TABLE_POSACTIVE)
            RefreshActive();
         if(TableType() == TABLE_POSHISTORY)
            RefreshHistory();
      }*/
      
      virtual void OnEvent(Event* event)
      {
         ;
         switch(event.EventId())
         {
            case EVENT_REFRESH:
            {
               if(typeTable == TABLE_POSACTIVE)
                  RefreshActive();
               int t = callBack.HistoryPosTotal();
               bool needRefresh = countHistory != t || countHistory == -1;
               if(needRefresh && typeTable == TABLE_POSHISTORY)
               {
                  RefreshHistory();
                  countHistory = t;
               }
               break;
            }
            default:
               EventSend(event);
               break;
         }   
      }
   private:
      ///
      /// 挓膼碲殣 鼏鍏鍒嚲 嚦豂膧 儇 瞃錟儆?魛蠂碴 瀁賥灕?
      ///
      void RefreshActive()
      {
         RefreshSummary();
         double margin = AccountInfoDouble(ACCOUNT_MARGIN);
         double m_balance = AccountInfoDouble(ACCOUNT_BALANCE);
         double m_equity = AccountInfoDouble(ACCOUNT_EQUITY);
         string strPerMargin = "0.0";
         if(!Math::DoubleEquals(0.0, m_balance))
            strPerMargin = DoubleToString((margin/m_equity)*100.0, 2);
         
         string strBalance = DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2);
         
         string strComm = DoubleToString(commission, 2);
         double pl = GetFloatPL();
         string strPerPl = "0.0";
         if(!Math::DoubleEquals(0.0, m_balance))
            strPerPl = DoubleToString(pl/m_balance*100.0, 2);
         string strPL = DoubleToString(GetFloatPL(), 2);
         //double leverage = AccountInfoDouble(ACCOUNT_CREDIT)
         //" Comm.: " + strComm + 
         string str = "Balance: " + strBalance + "  Floating P/L: " + strPL + " (" + strPerPl + "%)  Margin: " + strPerMargin + "%";
         //string str = "Current time: " + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
         textNode.Text(str);
      }
      ///
      /// 挓膼碲殣 鼏鍏鍒嚲 嚦豂膧 儇 瞃錟儆?黓襜謶灚齕儓 瀁賥灕?
      ///
      void RefreshHistory()
      {
         RefreshSummary();
         string strBalance = DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2);
         string strPL = DoubleToString(balance+commission+swap, 2);
         string strComm = DoubleToString(commission, 2);
         string strSwap = DoubleToString(swap, 2);
         string strPerComm = "";
         if(balance != 0.0)
            strPerComm = DoubleToString(commission/MathAbs(balance)*100.0, 2);
         //string str = "Balance: " + strBalance + "  P/L: " + strPL + " (Comm.: " + strComm + ", " + strPerComm + "%)";
         string pF = "";
         if(AccountInfoString(ACCOUNT_CURRENCY) == "USD")
            pF = "$";
         if(AccountInfoString(ACCOUNT_CURRENCY) == "RUB")
            pF = " RUB";
         string str = "Balance: " + strBalance + "  Total P/L: " + strPL + pF +
         /*"(P/L: " + strBalance + ", Comm: " + strComm + ", Swap: " + strSwap +*/ " Pos.: " + (string)posTotal;
         Tooltip("Including ");
         textNode.Text(str);
      }
      ///
      /// 砐鋹欑殣 摳錟艚 諘瞂蹢樇 鼥槶鍧.
      ///
      void RefreshSummary()
      {
         if(api == NULL)
            return;
            
         int total = callBack.HistoryPosTotal();
         for(; histTrans < total; histTrans++)
         {
            Transaction* trans = callBack.HistoryPosAt(histTrans);
            if(trans == NULL)
               continue;
            balance += trans.ProfitInCurrency();
            commission += trans.Commission();
            if(trans.TransactionType() == TRANS_POSITION)
            {
               posTotal++;
               Position* pos = trans;
               swap += pos.Swap();
            }
         }
      }
      
      ///
      /// 鎬誺譇╠殣 瀇飶嚲╫?瀔魨?鶋鍧.
      ///
      double GetFloatPL(void)
      {
         double pl = 0.0;
         //HedgeManager* api = EventExchange::GetAPI();
         int total = api.ActivePosTotal();
         for(int i = 0; i < total; i++)
         {
            Transaction* trans = api.ActivePosAt(i);
            pl += trans.ProfitInCurrency();
         }
         return pl;
      }
      ///
      /// 饜鴈嚦瞂臇 樦樇?嚦豂膱.
      ///
      Label* textNode;
      ///
      /// 醜錟艚 諘瞂蹢樇蕻?鼥槶鍧.
      ///
      double balance;
      ///
      /// 栦碭膧瀍? 膰擯嚭? 碫氁 勷瞂蹢樇蕻?襝鳧諘艖鴇.
      ///
      double commission;
      ///
      /// 侲膰瀇樇蕻?鼀闀.
      ///
      double swap;
      ///
      /// 膰錒灚嚦碭 黓襜謶灚齕儓 襝鳧諘艖鴇.
      ///
      int histTrans;
      ///
      /// 鎚樍?瀁賥灕?
      ///
      int posTotal;
      ///
      /// 栦麧謷鼏 瀁儴槼翴?鳿瞂嚦膼?膰錒灚嚦碭 黓襜謶灚齕儓 襝鳧諘艖鴇. 囑錒 蠈膧╝?膰錒灚嚦碭
      /// 黓襜謶灚齕儓 襝鳧諘艖鴇 翴 譇碴?樦? 襜 翴鍕羻儰斁 鍕膼睯譔 鼏鍏鍒嚲 嚦豂膧 summury.
      ///
      int countHistory;
      ///
      /// 祏?蠉摠儗? ?膰襜豂?瀔鴈馯錼緡?蠈膧╠ 鼏鍏鍒? 嚦豂罻.
      ///
      ENUM_TABLE_TYPE typeTable;
};