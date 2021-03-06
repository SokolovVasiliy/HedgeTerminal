#include "..\Events.mqh"
#include "Node.mqh"
#include "TableAbstrPos2.mqh"
#include "Label.mqh"
#include "Scroll.mqh"

class Cursor;
///
/// 迵齀鷿臇 膹僔?譇搿灚?鍕錟嚦?蠉摠儗?
///
class WorkArea : public Label
{
   public:
      
      WorkArea(Table* parNode) : Label(ELEMENT_TYPE_WORK_AREA, "WorkArea", parNode) 
      {
         //嵙謶縺 鍱膼蜦 鸆蜬 鳱馯攡譔 歞膲槶樥.
         stepHigh = 20;
         cursor = new Cursor(GetPointer(this));
         cursorIndex = -1;
         Text("");
         ReadOnly(true);
         BorderColor(parNode.BackgroundColor());
         prevHigh = High();
      }
      ~WorkArea()
      {
         if(CheckPointer(cursor) != POINTER_INVALID)
            delete cursor;
      }
      ///
      /// 癩摳碲殣 瀔鍞誺鎀嚲 嚦豂膧 ?膰翴?蠉摠儗? 栺豂罻 - 錌搿?蜸僳儚殥膱?鵰槶, 襴 麠謶縺 摷麧?
      /// 譇碴?麠謶翴 譇搿灚?鍕錟嚦?
      ///
      void Add(ProtoNode* line)
      {
         Add(line, childNodes.Total());
      }
      ///
      /// 癩摳碲殣 瀔鍞誺鎀嚲 嚦豂膧 ?蠉摠儗?瀁 鴈麧膲?index. 栺豂罻 - 錌搿?蜸僳儚殥膱?鵰槶, 襴 麠謶縺 摷麧?
      /// 譇碴?麠謶翴 譇搿灚?鍕錟嚦?
      ///
      void Add(ProtoNode* lineNode, int pos)
      {
         if(pos == childNodes.Total()/* && pos > 0*/)
         {
            if(summaryLine == NULL && 
               lineNode.TypeElement() == ELEMENT_TYPE_TABLE_SUMMARY)
               summaryLine = lineNode;
            else if(summaryLine != NULL)
               pos -= 1;
         }
         childNodes.Insert(lineNode, pos);
         lineNode.NLine(pos);
         ChangeScroll();
      }
      
      ///
      /// 赸鳪殣 儰黽馵鍙 錒膻?鳿 蠉摠儗?
      /// \param index - 麧膲 錒膻? 縺玁縺 ?膰襜豂?翴鍕羻儰斁 鵫鳪譔 錒膻?
      /// \param count - 扻錒灚嚦碭 錒膻? 膰襜豂?翴鍕羻儰斁 鵫鳪鼏?
      ///
      void DeleteRange(int index, int count)
      {
         if(index < 0 || index >= childNodes.Total())return;
         if(index+count > childNodes.Total())
            count = childNodes.Total()-index;
         int end = index + count;
         bool notVisible = (end < stepCurrent) || (index > stepCurrent + stepsVisible);
         if(!notVisible && Visible())
            RefreshVisibleLines(false);
         childNodes.DeleteRange(index, index+count-1);
         if(!notVisible && Visible())
            RefreshVisibleLines(true);
         ChangeScroll();
      }
      ///
      /// 鎬誺譇╠殣 膰錒灚嚦碭 闅鍕譇緪臇 錒膻?
      ///
      //int VisibleCounts(){return 0;}
      ///
      /// 鎬誺譇╠殣 鍕╝?膰錒灚嚦碭 鸆蜦?
      ///
      int StepsTotal()
      {
         int chTotal = childNodes.Total();
         int total = chTotal - StepsVisibleTheory() + 3;
         if(total < 0)total = 0;
         if(total > chTotal)total = chTotal;
         return total;
      }
      ///
      /// 鎬誺譇╠殣 鍕╫?禖勷覷 碫氁 樦樇襜?
      ///
      int StepsHighTotal()
      {
         return stepHigh*childNodes.Total();
      }
      ///
      /// 癩摳碲殣 嚭膧 縺 齕豂錭.
      ///
      void AddScroll(Scroll* nscroll)
      {
         scroll = nscroll;
         ChangeScroll();
      }
      ///
      /// 挓譇摳譖瘔殣 勷朢蠂?鳿懤翴膻 勷嚦?膻 齕豂錭?
      ///
      void OnScrollChanged(EventScrollChanged* event)
      {
         if(!Visible())return;
         if(CheckPointer(scroll) == POINTER_INVALID)
            return;
         if(scroll.CurrentStep() != stepCurrent)
            StepCurrent(scroll.CurrentStep());
      }
      ///
      /// 鎬趜僓馲?蠈膧╕?鸆? ?膰襜豂蜦 縺玁縺殣? 闅鍕譇緪膻?鵰錟.
      /// \return 砱膧╕?鵨蠉膼碲樇蕻?鸆?
      ///
      int StepCurrent()
      {
         return stepCurrent;
      }
      
      ///
      /// 鎬誺譇╠殣 蠈闉殣儚殥膰?膰錒灚嚦碭 錒膻? 膰襜豂?斁緪?譇賚殥蠂譔? 縺 譇翴.
      ///
      int StepsVisibleTheory()
      {
         int visSteps = (int)MathCeil(High()/(double)stepHigh);
         return visSteps;
      }
      ///
      /// 鎬誺譇╠殣 闅鍕譇緪臇鍷 膰錒灚嚦碭 樦樇襜?
      ///
      int StepsVisible()
      {
         return stepsVisible;
      }
      ///
      /// 鎬誺譇╠殣 鍕╫?禖勷覷 碫氁 嚦豂? 縺羻?╕蘘 ?蠉摠儗?
      ///
      ulong LinesHighTotal()
      {
         return childNodes.Total()*stepHigh;
      }
      
      ///
      /// 迶蠉縺碲魤馲?蠈膧╕?鸆? ?膰襜豂蜦 縺玁縺殣? 闅鍕譇緪膻?鵰錟.
      /// \return 嵑? 膰襜蹖?朢?鵨蠉膼碲樇.
      ///
      int StepCurrent(int step)
      {
         if(step < 0)step = 0;
         if(step > StepsTotal())step = StepsTotal();
         if(step == stepCurrent)return stepCurrent;
         RefreshVisibleLines(false);
         stepCurrent = step;
         RefreshVisibleLines(true);
         ChangeScroll();
         return stepCurrent;
      }
      ///
      /// 昜謥麧?殣 翴鍕羻儰檞?攦殣 儇 錒膻?
      /// \param count - 麧膲 蠈膧╝?錒膻? 闅 膰襜豂蜦 諘睯鼨?槫 攦殣.
      ///
      void CheckAndBrushColor(int count)
      {
         if(count >= childNodes.Total() || count < 0)return;
         ProtoNode* node = childNodes.At(count);
         if(node.TypeElement() == ELEMENT_TYPE_TABLE_SUMMARY)
            return;
         color clr;
         if(CheckPointer(cursor) != POINTER_INVALID && cursor.Index() == node.NLine())
            clr = Settings.ColorTheme.GetCursorColor();
         else
         {
            clr = count%2 == 0 ?
                  Settings.ColorTheme.GetSystemColor2() :
                  Settings.ColorTheme.GetSystemColor1();
         }
         InterlacingColor(node, clr);
      }
      ///
      /// 鎬誺譇╠殣 鍕╝?膰錒灚嚦碭 錒膻??蠉摠儗?
      ///
      int LinesTotal()
      {
         return childNodes.Total();
      }
      /*屙臌灕?儇 勷碪殥蠂斁嚦?勷 嚦僦鍣 瞂貘鳺?*/
      int LinesVisible()
      {
         return StepsVisible();
      }
      
      int LineVisibleFirst()
      {
         return stepCurrent;
      }
      void LineVisibleFirst(int index)
      {
         StepCurrent(index);
      }
      ulong LinesHighVisible()
      {
         return (ulong)StepsHighTotal();
      }
      
   private:
      void OnEvent(Event* event)
      {
         Table* tbl = parentNode;
         int dbg = 5;
         if(tbl.TableType() == TABLE_POSHISTORY &&
            (event.EventId() == EVENT_REFRESH || event.EventId() == EVENT_MOUSE_MOVE))
         {
            if(CheckPointer(summaryLine) != POINTER_INVALID)
               summaryLine.OnEvent(event);
            return;
         }
         switch(event.EventId())
         {
            case EVENT_KEYDOWN:
               OnPressKey(event);
               EventSend(event);
               break;
            case EVENT_NODE_CLICK:
               OnClickNode(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
      
      ///
      /// 挓譇摳譖瘔殣 縺糈蠂?膹飶儑.
      ///
      void OnPressKey(EventKeyDown* event)
      {
         if(!Visible())return;
         switch(event.Code())
         {
            case KEY_ARROW_UP:
               cursor.Move(-1);
               break;
            case KEY_ARROW_DOWN:
               cursor.Move(1);
               break;
            case KEY_ARROW_RIGHT:
            case KEY_ARROW_LEFT:
               OnKeyRightOrLeft(event);
               break;
            case KEY_HOME:
               cursor.Move(0, false);
               break;
            case KEY_END:
               cursor.Move(LinesTotal()-1, false);
               StepCurrent(StepsTotal());
               break;
            case KEY_PAGE_UP:
               cursor.Move((-1)*(StepsVisibleTheory()-1));  
               break;
            case KEY_PAGE_DOWN:
               cursor.Move(StepsVisibleTheory()-1);
               break;
         }  
      }
      ///
      /// 挓譇搿譈鴀 縺糈蠂 膫闀鍧 "嚦謥鍆?碨譇碭" ?"嚦謥鍆?碲槻?.
      ///
      void OnKeyRightOrLeft(EventKeyDown* event)
      {
         if(event.Code() != KEY_ARROW_LEFT &&
            event.Code() != KEY_ARROW_RIGHT)
            return;
         ProtoNode* node = childNodes.At(cursor.Index());
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)
            return;
         PosLine* posLine = node;
         TreeViewBoxBorder* twb = posLine.GetCell(COLUMN_COLLAPSE);
         if(twb == NULL)return;
         if(event.Code() == KEY_ARROW_RIGHT &&
            twb.State() == BOX_TREE_RESTORE)return;
         if(event.Code() == KEY_ARROW_LEFT &&
            twb.State() == BOX_TREE_COLLAPSE)return;
         //bool res = i == workArea.ChildsTotal()-1;
         //twb.NeedRefresh();
         twb.OnPush();
         //twb.NeedRefresh(true);
      }
      ///
      /// 迶蠉縺碲魤馲?膧貘闉 縺 嚦豂膧 蠉摠儗? 瀁 膰襜豂?
      /// 朢?瀔鍞誺槼樇 ╝錤鍧.
      ///
      void OnClickNode(EventNodeClick* event)
      {
         //囑錒 ╝錤鍧 朢?瀔鍞誺槼樇 瀁 嚦豂耪 勷麧謷僓鴇 鐓膲麃鍒鳧蕻?蠈膲?
         //賝僝鼏 蠈膧╫?嚦豂膧 縺儋 瀁儆譇鼨譔 膧貘闉鍎.
         //?瀔闅魤膼?儴齀馲, 瀔鍞賧齴?僽鵽鍷 賝僝鳻鍷 勷朢蠂? 膰襜豂?縺儋 櫇謥魡譔 縺瞂贂.
         ProtoNode* node = event.Node();
         if(node.TypeElement() == ELEMENT_TYPE_LABEL)
         {
            Label* lab = node;
            //鎖錌欑樦 瀁儊瞂襚?嚦豂膱
            ProtoNode* parNode = lab.ParentNode();
            //赸闃襜瞂?樦? 蘹?豂儰蠈錪齕鴇 鵰槶 鳻樇膼 嚦豂罻 ?勷嚦飶?TableWork,
            //?翴 搿錼?蜱鶋鍧鴇 樦樇??鳺譇贂鳷 樦樇襜?
            ProtoNode* ppNode = parNode.ParentNode();
            if(GetPointer(ppNode) != GetPointer(this))return;
            ENUM_ELEMENT_TYPE type = parNode.TypeElement();
            bool isConvert = parNode.TypeElement() != ELEMENT_TYPE_TABLE_SUMMARY;
            if(lab.ReadOnly() && isConvert)
               cursor.Move(parNode.NLine(), false);
         }
         EventSend(event);
      }
      
      ///
      /// 栴蹖瘔殣 錒搿 闅鍕譇糈殣 錒膻??諘睯鼨斁嚦?闅 鐏飹?.
      /// \param vis - 蠂縺, 殥錒 翴鍕羻儰斁 闅鍕譇賥譔 錒膻? 鋋聧 - 殥錒 齕蹖譔. 
      ///
      void RefreshVisibleLines(bool vis)
      {
         ulong y_dist = 0;
         int count = 0;
         int total = childNodes.Total();
         ulong m_high = vis ? High() : prevHigh;
         for(int i = stepCurrent; y_dist <= m_high && i < total; i++, y_dist += stepHigh)
         {
            ProtoNode* node = childNodes.At(i);
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), vis, 0, y_dist, Width(), stepHigh);
            node.Event(command);
            delete command;
            if(vis)
               CheckAndBrushColor(i);
            count++;
         }
         if(!vis)
            stepsVisible = 0;
         else
            stepsVisible = count;
      }
      
      ///
      /// 极?殣 鐕?碫氁 儋灚謺儓 樦樇襜?錒膻?縺 諘魡臇.
      ///
      void InterlacingColor(ProtoNode* nline, color clr)
      {
         for(int i = 0; i < nline.ChildsTotal(); i++)
         {
            ProtoNode* node = nline.ChildElementAt(i);
            node.BackgroundColor(clr);
            node.BorderColor(clr);
            if(node.TypeElement() == ELEMENT_TYPE_GCONTAINER)
            {
               for(int j = 0; j < node.ChildsTotal(); j++)
               {
                  ProtoNode* c_node = node.ChildElementAt(j);
                  c_node.BackgroundColor(clr);
                  c_node.BorderColor(clr);
               }
            }
         }
      }
      ///
      /// 挓譇摳譖瘔殣 闅鍕譇緪膻?
      ///
      void OnCommand(EventNodeCommand* command)
      {
         bool vis = command.Visible() && parentNode.Visible();
         TablePositions* table = parentNode;
         if(vis)
            RefreshVisibleLines(false);
         RefreshVisibleLines(vis);
         ChangeScroll();
         prevHigh = High();
      }
      ///
      /// 挓譇摳譖瘔殣 闅鍕譇緪膻?
      ///
      void OnVisible(EventVisible* event)
      {
         ReadOnly(true);
         bool vis = event.Visible() && parentNode.Visible();
         TablePositions* table = parentNode;
         RefreshVisibleLines(vis);   
      }
      ///
      /// 挓膼碲殣 櫡譇懤襝?齕豂錭?
      ///
      void ChangeScroll(void)
      {
         if(CheckPointer(scroll) != POINTER_INVALID)
         {
            scroll.CurrentStep(stepCurrent);
            scroll.TotalSteps(StepsTotal());
         }
      }
      ///
      /// 砱膧╕?鸆??膰襜豂蜦 縺玁縺殣? 闅鍕譇緪膻?錒膻?
      ///
      int stepCurrent;
      ///
      /// 雞勷蠉 鍱膼蜦 鸆蜬.
      ///
      int stepHigh;
      ///
      /// 迾馵僗槶?縺 齕豂錭.
      ///
      Scroll* scroll;
      ///
      /// 栦麧謷鼏 膰錒灚嚦碭 睯儰檞?錒膻?
      ///
      int stepsVisible;
      ///
      /// 扷貘闉.
      ///
      Cursor* cursor;
      ///
      /// 麧膲 膧貘闉?
      ///
      int cursorIndex;
      ///
      /// 迾馵僗槶?縺 鼏鍏鍒嚲 錒膻?
      ///
      Summary* summaryLine;
      ///
      /// 砎槼齍? 儇鴈?蠉摠儗?(黓瀁錪踠殣? 儇 RefreshVisibleLines(false). 
      ///
      ulong prevHigh;
      
};

///
/// 涾鳧鼏 ?櫇謥懤╠殣 膧貘闉.
///
class Cursor
{
   public:
      Cursor(WorkArea* area)
      {
         workArea = area;
         index = -1;
      }
      ///
      /// 鎬誺譇╠殣 蠈膧╕?鴈麧膲 膧貘闉?
      ///
      int Index(){return index;}
      ///
      /// 盷謥懤╠殣 膧貘闉 縺 鵳馵鳧膼?膰錒灚嚦碭 瀁賥灕?碴鳿 鳹?瞁歑?
      /// \param delta - ?諘睯鼨斁嚦?闅 鐏飹?儵潁樇鳺 闅膼鼨蠈錪膼 蠈膧╝蜦 膧貘闉? 錒搿
      /// 颬勷錌襡 鴈麧膲.
      /// \param isDelta - 蠂縺, 殥錒 delta 諘魡殣? 罻?儵氂樇鳺 闅膼鼨蠈錪膼 蠈膧╝蜦 膧貘闉??
      /// 鋋聧, 殥錒 delta 鵳馵馲?縺 颬勷錌襡 鴈麧膲.
      ///
      bool Move(int delta, bool isDelta = true)
      {
         //盷謥碭儰?颬勷錌襡鍷 懤嚦闀鎀鍻樇鳺 ?闅膼鼨蠈錪膼?
         if(!isDelta)
            delta = delta-index;
         if(delta == 0)return false;
         else if(index + delta < 0)
            index = 0;
         else if(index + delta >= workArea.LinesTotal()-1)
            index = workArea.LinesTotal()-2;
         else
            index += delta;
         if(delta < 0)
            workArea.CheckAndBrushColor(index + MathAbs(delta));
         if(delta > 0)
            workArea.CheckAndBrushColor(index - delta);
         workArea.CheckAndBrushColor(index);
         if(workArea.StepCurrent() + workArea.StepsVisible() < index+2)
            workArea.StepCurrent(index - workArea.StepsVisible()+2);
         if(workArea.StepCurrent() > index)
            workArea.StepCurrent(index);
         return true;
      }
      
   private:
      ///
      /// 栦麧謷鼏 蠈膧╕?鴈麧膲 膧貘闉?
      ///
      int index;
      ///
      /// 栦麧謷鼏 鵳馵僗槶?縺 譇搿蘼?鍕錟嚦?蠉摠儗?
      ///
      WorkArea* workArea;

};
