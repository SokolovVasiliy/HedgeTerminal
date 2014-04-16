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
         if(!notVisible && Visible())
            RefreshVisibleLines(true);
         ChangeScroll();
      }
      ///
      /// Возвращает количество отображенных линий.
      ///
      //int VisibleCounts(){return 0;}
      ///
      /// Возвращает общее количество шагов.
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
         ChangeScroll();
      }
      ///
      /// Обрабатывает событие изменения состояния скролла.
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
      /// Возращает текущий шаг, с которого начинается отображение узла.
      /// \return Текущий установленный шаг.
      ///
      int StepCurrent()
      {
         return stepCurrent;
      }
      
      ///
      /// Возвращает теоретическое количество линий, которое может разместиться на экране.
      ///
      int StepsVisibleTheory()
      {
         int visSteps = (int)MathCeil(High()/(double)stepHigh);
         return visSteps;
      }
      ///
      /// Возвращает отображенное количество элементов.
      ///
      int StepsVisible()
      {
         return stepsVisible;
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
         if(step == stepCurrent)return stepCurrent;
         RefreshVisibleLines(false);
         stepCurrent = step;
         RefreshVisibleLines(true);
         ChangeScroll();
         return stepCurrent;
      }
      ///
      /// Определяет необходимый цвет для линии.
      /// \param count - Индекс текущей линии, от которого зависит ее цвет.
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
      /// Возвращает общее количество линий в таблице.
      ///
      int LinesTotal()
      {
         return childNodes.Total();
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
            case EVENT_NODE_CLICK:
               OnClickNode(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
      
      ///
      /// Обрабатывает нажатие клавиш.
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
      /// Обработчик нажатия кнопок "стрелка вправо" и "стрелка влево".
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
      /// Устанавливает курсор на строку таблицы, по которой
      /// был произведен щелчок.
      ///
      void OnClickNode(EventNodeClick* event)
      {
         //Если щелчок был произведен по строке содержащий фиксированный текст,
         //значит текущую строку надо подкрасить курсором.
         //В противном случае, произошло другое значимое событие, которое надо передать наверх.
         ProtoNode* node = event.Node();
         if(node.TypeElement() == ELEMENT_TYPE_LABEL)
         {
            Label* lab = node;
            //Включаем подсветку строки
            ProtoNode* parNode = lab.ParentNode();
            ENUM_ELEMENT_TYPE type = parNode.TypeElement();
            bool isConvert = parNode.TypeElement() != ELEMENT_TYPE_TABLE_SUMMARY;
            if(lab.ReadOnly() && isConvert)
               cursor.Move(parNode.NLine(), false);
         }
         EventSend(event);
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
      /// Меняет фон всех дочерних элементов линии на заданный.
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
      /// Обрабатывает отображение.
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
      /// Обрабатывает отображение.
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
      /// Обновляет параметры скролла.
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
      ///
      /// Индекс курсора.
      ///
      int cursorIndex;
      ///
      /// Указатель на результирующую строку, если она добавлена.
      ///
      Line* summaryLine;
};

///
/// Хранит и перемещает курсор.
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
      /// Возвращает текущий индекс курсора.
      ///
      int Index(){return index;}
      ///
      /// Перемещает курсор на указанное количество позиций вниз или вверх.
      /// \param delta - В зависимости от флага смещение относительно текущего курсора, либо
      /// абсолютный индекс.
      /// \param isDelta - Истина, если delta задается как смешение относительно текущего курсора и
      /// ложь, если delta указывает на абсолютный индекс.
      ///
      bool Move(int delta, bool isDelta = true)
      {
         //Переводим абсолютное местоположение в относительное
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
      /// Содержит текущий индекс курсора.
      ///
      int index;
      ///
      /// Содержит указатель на рабочую область таблицы.
      ///
      WorkArea* workArea;
};
