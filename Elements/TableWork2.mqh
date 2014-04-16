#include "..\Events.mqh"
#include "Node.mqh"
#include "TableAbstrPos2.mqh"
#include "Label.mqh"
#include "Scroll.mqh"

class Cursor;
///
/// ���������� ����� ������� ������� �������.
///
class WorkArea : public Label
{
   public:
      WorkArea(Table* parNode) : Label(ELEMENT_TYPE_WORK_AREA, "WorkArea", parNode) 
      {
         //������ ������ ���� �������� ��������.
         stepHigh = 20;
         cursor = new Cursor(GetPointer(this));
         cursorIndex = -1;
         Text("");
         ReadOnly(true);
         BorderColor(parNode.BackgroundColor());
      }
      ~WorkArea()
      {
         if(CheckPointer(cursor) != POINTER_INVALID)
            delete cursor;
      }
      ///
      /// ��������� ������������ ������ � ����� �������. ������ - ����� ����������� ����, ��� ������ �����
      /// ����� ������ ������� �������.
      ///
      void Add(ProtoNode* line)
      {
         Add(line, childNodes.Total());
      }
      ///
      /// ��������� ������������ ������ � ������� �� ������� index. ������ - ����� ����������� ����, ��� ������ �����
      /// ����� ������ ������� �������.
      ///
      void Add(ProtoNode* lineNode, int pos)
      {
         if(pos == childNodes.Total() && pos > 0)
         {
            ProtoNode* node = childNodes.At(pos-1);
            if(node.TypeElement() == ELEMENT_TYPE_TABLE_SUMMARY)
               pos -= 1;
         }
         childNodes.Insert(lineNode, pos);
         lineNode.NLine(pos);
         ChangeScroll();
      }
      ///
      /// ������� �������� ����� �� �������.
      /// \param index - ������ �����, ������� � ������� ���������� ������� �����.
      /// \param count - ���������� �����, ������� ���������� �������.
      ///
      void DeleteRange(int index, int count)
      {
         if(index < 0 || index >= childNodes.Total())return;
         if(index+count > childNodes.Total())
            count = childNodes.Total()-index;
         int end = index + count;
         bool notVisible = (end < stepCurrent) || (index > stepCurrent + stepsVisible);
         if(!notVisible)
            RefreshVisibleLines(false);
         childNodes.DeleteRange(index, index+count-1);
         if(!notVisible && Visible())
            RefreshVisibleLines(true);
         ChangeScroll();
      }
      ///
      /// ���������� ���������� ������������ �����.
      ///
      //int VisibleCounts(){return 0;}
      ///
      /// ���������� ����� ���������� �����.
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
      /// ���������� ����� ������ ���� ���������.
      ///
      int StepsHighTotal()
      {
         return stepHigh*childNodes.Total();
      }
      ///
      /// ��������� ������ �� ������.
      ///
      void AddScroll(Scroll* nscroll)
      {
         scroll = nscroll;
         ChangeScroll();
      }
      ///
      /// ������������ ������� ��������� ��������� �������.
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
      /// ��������� ������� ���, � �������� ���������� ����������� ����.
      /// \return ������� ������������� ���.
      ///
      int StepCurrent()
      {
         return stepCurrent;
      }
      
      ///
      /// ���������� ������������� ���������� �����, ������� ����� ������������ �� ������.
      ///
      int StepsVisibleTheory()
      {
         int visSteps = (int)MathCeil(High()/(double)stepHigh);
         return visSteps;
      }
      ///
      /// ���������� ������������ ���������� ���������.
      ///
      int StepsVisible()
      {
         return stepsVisible;
      }
      ///
      /// ���������� ����� ������ ���� �����, ����������� � �������.
      ///
      ulong LinesHighTotal()
      {
         return childNodes.Total()*stepHigh;
      }
      
      ///
      /// ������������� ������� ���, � �������� ���������� ����������� ����.
      /// \return ���, ������� ��� ����������.
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
      /// ���������� ����������� ���� ��� �����.
      /// \param count - ������ ������� �����, �� �������� ������� �� ����.
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
            TablePositions* tPos = parentNode;
            if(tPos.TableType() == TABLE_POSHISTORY)
               clr = clrAliceBlue;
            else
            clr = count%2 == 0 ?
                  Settings.ColorTheme.GetSystemColor2() :
                  Settings.ColorTheme.GetSystemColor1();
         }
         InterlacingColor(node, clr);
      }
      ///
      /// ���������� ����� ���������� ����� � �������.
      ///
      int LinesTotal()
      {
         return childNodes.Total();
      }
      /*������� ��� ������������� �� ������ �������*/
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
      /// ������������ ������� ������.
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
      /// ���������� ������� ������ "������� ������" � "������� �����".
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
      /// ������������� ������ �� ������ �������, �� �������
      /// ��� ���������� ������.
      ///
      void OnClickNode(EventNodeClick* event)
      {
         //���� ������ ��� ���������� �� ������ ���������� ������������� �����,
         //������ ������� ������ ���� ���������� ��������.
         //� ��������� ������, ��������� ������ �������� �������, ������� ���� �������� ������.
         ProtoNode* node = event.Node();
         if(node.TypeElement() == ELEMENT_TYPE_LABEL)
         {
            Label* lab = node;
            //�������� ��������� ������
            ProtoNode* parNode = lab.ParentNode();
            ENUM_ELEMENT_TYPE type = parNode.TypeElement();
            bool isConvert = parNode.TypeElement() != ELEMENT_TYPE_TABLE_SUMMARY;
            if(lab.ReadOnly() && isConvert)
               cursor.Move(parNode.NLine(), false);
         }
         EventSend(event);
      }
      
      ///
      /// �������� ���� ���������� ����� � ����������� �� ����� .
      /// \param vis - ������, ���� ���������� ���������� �����, ���� - ���� ������. 
      ///
      void RefreshVisibleLines(bool vis)
      {
         ulong y_dist = 0;
         int count = 0;
         int total = childNodes.Total();
         ulong m_high = High();
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
      /// ������ ��� ���� �������� ��������� ����� �� ��������.
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
      /// ������������ �����������.
      ///
      void OnCommand(EventNodeCommand* command)
      {
         bool vis = command.Visible() && parentNode.Visible();
         TablePositions* table = parentNode;
         //if(!parentNode.Visible() && command.Visible())
            printf("Parent OnCommand " + EnumToString(table.TableType()) +  " vis:" + vis + " event: " + command.Visible());
         RefreshVisibleLines(vis);
         ChangeScroll();
      }
      ///
      /// ������������ �����������.
      ///
      void OnVisible(EventVisible* event)
      {
         ReadOnly(true);
         bool vis = event.Visible() && parentNode.Visible();
         TablePositions* table = parentNode;
         //if(!parentNode.Visible() && command.Visible())
            printf("Parent OnVisible " + EnumToString(table.TableType()) + " vis:" + vis + " event: " + event.Visible());
         RefreshVisibleLines(vis);   
      }
      ///
      /// ��������� ��������� �������.
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
      /// ������� ��� � �������� ���������� ����������� �����.
      ///
      int stepCurrent;
      ///
      /// ������ ������ ����.
      ///
      int stepHigh;
      ///
      /// ��������� �� ������.
      ///
      Scroll* scroll;
      ///
      /// �������� ���������� ������� �����.
      ///
      int stepsVisible;
      ///
      /// ������.
      ///
      Cursor* cursor;
      ///
      /// ������ �������.
      ///
      int cursorIndex;
      ///
      /// ��������� �� �������������� ������, ���� ��� ���������.
      ///
      Line* summaryLine;
};

///
/// ������ � ���������� ������.
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
      /// ���������� ������� ������ �������.
      ///
      int Index(){return index;}
      ///
      /// ���������� ������ �� ��������� ���������� ������� ���� ��� �����.
      /// \param delta - � ����������� �� ����� �������� ������������ �������� �������, ����
      /// ���������� ������.
      /// \param isDelta - ������, ���� delta �������� ��� �������� ������������ �������� ������� �
      /// ����, ���� delta ��������� �� ���������� ������.
      ///
      bool Move(int delta, bool isDelta = true)
      {
         //��������� ���������� �������������� � �������������
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
      /// �������� ������� ������ �������.
      ///
      int index;
      ///
      /// �������� ��������� �� ������� ������� �������.
      ///
      WorkArea* workArea;
};
