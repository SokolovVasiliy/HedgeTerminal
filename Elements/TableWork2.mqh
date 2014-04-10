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
      void Add(ProtoNode* line, int index)
      {
         childNodes.Insert(line, index);
         if(index <= stepCurrent + StepsVisible())
            StepCurrent(stepCurrent);
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
         if(!notVisible)
            RefreshVisibleLines(true);
      }
      ///
      /// ���������� ���������� ������������ �����.
      ///
      int VisibleCounts(){return 0;}
      ///
      /// ���������� ����� ���������� �����.
      ///
      int StepsTotal()
      {
         return childNodes.Total();
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
      }
      ///
      /// ������������ ������� ��������� ��������� �������.
      ///
      void OnScrollChanged()
      {
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
      /// ���������� ������������ ���������� ���������.
      ///
      int StepsVisible()
      {
         return stepsVisible;
         if(stepHigh <= 0)return 0;
         int visSteps = (int)MathCeil(High()/(double)stepHigh);
         if(visSteps > (StepsTotal()-stepCurrent))
            return (StepsTotal()-stepCurrent);
         return visSteps;
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
         RefreshVisibleLines(false);
         stepCurrent = step;
         RefreshVisibleLines(true);
         return stepCurrent;
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
            default:
               EventSend(event);
               break;
         }
      }
      void OnPressKey(EventKeyDown* event)
      {
         switch(event.Code())
         {
            case KEY_ARROW_UP:
               StepCurrent(stepCurrent-1);
               break;
            case KEY_ARROW_DOWN:
               StepCurrent(stepCurrent+1);
               break;
            case KEY_HOME:
               StepCurrent(0);
               break;
            /*case KEY_END:
               LineVisibleFirst(CalcTotalStepsForScroll());
               if(scroll.CurrentStep() + visibleCount >= childNodes.Total())
                  OnCommand();
               break;
            case KEY_PAGE_UP:
               StepCurrent(stepCurrent-StepsVisible()+1);   
               break;
            case KEY_PAGE_DOWN:
               StepCurrent(stepCurrent+StepsVisible()-1);   
               break;*/
         }  
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
         //color
         for(int i = stepCurrent; y_dist < m_high && i < total; i++, y_dist += stepHigh)
         {
            ProtoNode* node = childNodes.At(i);
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), vis, 0, y_dist, Width(), stepHigh);
            node.Event(command);
            delete command;
            if(vis)
               CheckAndBrushColor(node, count);
            count++;
         }
         if(!vis)
            stepsVisible = 0;
         else
            stepsVisible = count;
      }
      ///
      /// ���������� ����������� ���� ��� �����.
      /// \param count - ������ ������� �����, �� �������� ������� �� ����.
      ///
      void CheckAndBrushColor(ProtoNode* node, int count)
      {
         if(node.TypeElement() == ELEMENT_TYPE_TABLE_SUMMARY)
            return;
         if(CheckPointer(cursor) != POINTER_INVALID && cursor.Index() == node.NLine())
            return;
         color clr = count%2 == 0 ?
               Settings.ColorTheme.GetSystemColor2() :
               Settings.ColorTheme.GetSystemColor1();
         InterlacingColor(node, clr);
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
         }
      }
      ///
      /// ������������ �����������.
      ///
      void OnCommand(EventNodeCommand* command)
      {
         RefreshVisibleLines(command.Visible());
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
};

///
/// ������ � ���������� ������.
///
class Cursor
{
   public:
      Cursor(CWorkArea* area)
      {
         workArea = area;
         currentIndex = -1;
      }
      ///
      /// ���������� ������� ������ �������.
      ///
      int Index(){return currentIndex;}
      ///
      /// ����������� ������ �� ���� ������ �����.
      ///
      bool MoveUp()
      {
         return false;
      }
      ///
      /// ����������� ������ �� ���� ������ ����.
      ///
      bool MoveDn()
      {
         return false;
      }
   private:
      ///
      /// �������� ������� ������ �������.
      ///
      int currentIndex;
      ///
      /// �������� ��������� �� ������� ������� �������.
      ///
      CWorkArea* workArea;
};
