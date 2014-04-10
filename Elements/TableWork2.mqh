#include "..\Events.mqh"
#include "Node.mqh"
#include "TableAbstrPos2.mqh"
#include "Label.mqh"
#include "Scroll.mqh"

class Cursor;
///
/// Улучшенный класс рабочей области таблицы.
///
class WorkArea : public Label
{
   public:
      WorkArea(Table* parNode) : Label(ELEMENT_TYPE_WORK_AREA, "WorkArea", parNode) 
      {
         //Ширина одного шага двадцать пикселей.
         stepHigh = 20;
      }
      ///
      /// Добавляет произвольную строку в конец таблицы. Строка - любой графический узел, чья ширина будет
      /// равна ширине рабочей области.
      ///
      void Add(ProtoNode* line)
      {
         Add(line, childNodes.Total());
      }
      ///
      /// Добавляет произвольную строку в таблицу по индексу index. Строка - любой графический узел, чья ширина будет
      /// равна ширине рабочей области.
      ///
      void Add(ProtoNode* line, int index)
      {
         childNodes.Insert(line, index);
         if(index <= stepCurrent + StepsVisible())
            StepCurrent(stepCurrent);
      }
      ///
      /// Удаляет диапазон линий из таблицы.
      /// \param index - Индекс линии, начиная с которой необходимо удалять линии.
      /// \param count - Количество линий, которое необходимо удалить.
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
      /// Возвращает количество отображенных линий.
      ///
      int VisibleCounts(){return 0;}
      ///
      /// Возвращает общее количество шагов.
      ///
      int StepsTotal()
      {
         return childNodes.Total();
      }
      ///
      /// Возвращает общую высоту всех элементов.
      ///
      int StepsHighTotal()
      {
         return stepHigh*childNodes.Total();
      }
      ///
      /// Добавляет ссылку на скролл.
      ///
      void AddScroll(Scroll* nscroll)
      {
         scroll = nscroll;
      }
      ///
      /// Обрабатывает событие изменения состояния скролла.
      ///
      void OnScrollChanged()
      {
         if(CheckPointer(scroll) == POINTER_INVALID)
            return;
         if(scroll.CurrentStep() != stepCurrent)
            StepCurrent(scroll.CurrentStep());
      }
      ///
      /// Возращает текущий шаг, с которого начинается отображение узла.
      /// \return Текущий установленный шаг.
      ///
      int StepCurrent()
      {
         return stepCurrent;
      }
      ///
      /// Возвращает отображенное количество элементов.
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
      /// Возвращает общую высоту всех строк, находящихся в таблице.
      ///
      ulong LinesHighTotal()
      {
         return childNodes.Total()*stepHigh;
      }
      
      ///
      /// Устанавливает текущий шаг, с которого начинается отображение узла.
      /// \return Шаг, который был установлен.
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
      
      /*Функции для совместимости со старой версией*/
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
      /// Скрывает либо отображает линии в зависимости от флага .
      /// \param vis - Истина, если необходимо отобразить линии, ложь - если скрыть. 
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
      /// Определяет необходимый цвет для линии.
      /// \param count - Индекс текущей линии, от которого зависит ее цвет.
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
      /// Меняет фон всех дочерних элементов линии на заданный.
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
      /// Обрабатывает отображение.
      ///
      void OnCommand(EventNodeCommand* command)
      {
         RefreshVisibleLines(command.Visible());
      }
      ///
      /// Текущий шаг с которого начинается отображение линий.
      ///
      int stepCurrent;
      ///
      /// Высота одного шага.
      ///
      int stepHigh;
      ///
      /// Указатель на скролл.
      ///
      Scroll* scroll;
      ///
      /// Содержит количество видимых линий.
      ///
      int stepsVisible;
      ///
      /// Курсор.
      ///
      Cursor* cursor;
};

///
/// Хранит и перемещает курсор.
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
      /// Возвращает текущий индекс курсора.
      ///
      int Index(){return currentIndex;}
      ///
      /// Передвигает курсор на одну строку вверх.
      ///
      bool MoveUp()
      {
         return false;
      }
      ///
      /// Передвигает курсор на одну строку вниз.
      ///
      bool MoveDn()
      {
         return false;
      }
   private:
      ///
      /// Содержит текущий индекс курсора.
      ///
      int currentIndex;
      ///
      /// Содержит указатель на рабочую область таблицы.
      ///
      CWorkArea* workArea;
};
