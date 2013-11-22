//#include "..\API\Position.mqh"
#include "..\Events.mqh"
#include "Node.mqh"
#include "Button.mqh"
#include "TreeViewBox.mqh"
#include "Line.mqh"
#include "Label.mqh"
#include "Scroll.mqh"
#include "TableWork.mqh"
#include "TableDirective.mqh"

#ifndef TABLE_MQH
   #define TABLE_MQH
#endif 

///
/// Класс "Таблица" представляет из себя универсальный контейнер, состоящий из трех элементов:
/// 1. Заголовок таблицы;
/// 2. Вертикальный контейнер строк;
/// 3. Скролл прокрутки вертикального контейнера строк.
/// Каждый из трех элементов имеет свой персональный указатель.
///
class Table : public Label
{
   public:
      Table(string myName, ProtoNode* parNode, ENUM_TABLE_TYPE tableType = TABLE_POSACTIVE):Label(ELEMENT_TYPE_TABLE, myName, parNode)
      {
         tDir.TableType(tableType);
         //Для таблиц, представляющих позиции, формируем специальный заголовок.
         if(tDir.IsPositionTable())
            lineHeader = new AbstractPos("header", ELEMENT_TYPE_TABLE_HEADER_POS, GetPointer(this));
         
         Init(myName, parNode);
      }
      
      ///
      /// Возвращает общую высоту всех линий в таблице.
      ///
      long LinesHighTotal()
      {
         return workArea.LinesHighTotal();
      }
      ///
      /// Возвращает общую высоту всех видимых линий в таблице.
      ///
      long LinesHighVisible()
      {
         return workArea.LinesHighVisible();
      }
      ///
      /// Возвращает общее количество всех строк в таблице, в т.ч. за
      /// находящимися за пределами окна.
      ///
      int LinesTotal()
      {
         return workArea.ChildsTotal();
      }
      
      ///
      /// Возвращает количество строк, отображаемых в текущий момент в
      /// окне таблице.
      ///
      int LinesVisible()
      {
         if(workArea != NULL)
            return workArea.LinesVisible();
         return 0;
      }
      ///
      /// Возвращает индекс первой видимой строки.
      ///
      int LineVisibleFirst()
      {
         if(workArea != NULL)
            return workArea.LineVisibleFirst();
         return -1;
      }
      ///
      /// Задает индекс первой видимой строки.
      ///
      void LineVisibleFirst(int index)
      {
         workArea.LineVisibleFirst(index);
      }
      ///
      /// Задает индекс первой видимой строки.
      ///
      void LineVisibleFirst1(int index)
      {
         workArea.LineVisibleFirst(index);
      }
      ///
      /// Алгоритм размещения заголовка таблицы.
      ///
      void AllocationHeader()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 1, Width()-22, 20);
         bool vis = Visible();
         lineHeader.Event(command);
         delete command;
      }
      ///
      /// Алгоритм размещения рабочей области таблицы.
      ///
      void AllocationWorkTable()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 21, Width()-22, High()-24);
         workArea.Event(command);
         delete command;
      }
      ///
      /// Алгоритм размещения скролла таблицы.
      ///
      void AllocationScroll()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-21, 1, 20, High()-2);
         scroll.Event(command);
         delete command;
      }
   protected:
      ///
      /// Заголовок таблицы.
      ///
      Line* lineHeader;
      //Line* lineHeader;
      ///
      /// Рабочая область таблицы
      ///
      CWorkArea* workArea;
      ///
      /// Скролл.
      ///
      Scroll* scroll;
      virtual Line* InitHeader()
      {
         return new Line("Header", ELEMENT_TYPE_TABLE_HEADER, GetPointer(this));
      }
      ///
      /// Содержит набор параметров, характеризущих настройки таблицы.
      ///
      TableDirective tDir;
   private:
      void Init(string myName, ProtoNode* parNode)
      {
         ReadOnly(true);
         BorderType(BORDER_FLAT);
         BorderColor(clrWhite);
         highLine = 20;
         if(lineHeader == NULL)
            lineHeader = new Line("header", GetPointer(this));
         lineHeader.BackgroundColor(clrWhite);
         lineHeader.Align(ALIGN_CENTER);
         workArea = new CWorkArea(GetPointer(this));
         workArea.ReadOnly(true);
         workArea.Text("");
         workArea.BorderColor(BackgroundColor());
         
         scroll = new Scroll("Scroll", GetPointer(this));
         scroll.BorderType(BORDER_FLAT);
         scroll.BorderColor(clrBlack);
         
         childNodes.Add(lineHeader);
         childNodes.Add(workArea);
         childNodes.Add(scroll);
      }
      virtual void OnCommand(EventVisible* event)
      {
         if(!event.Visible())return;
         //Размещаем заголовок таблицы.
         AllocationHeader();
         //Размещаем рабочую область.
         AllocationWorkTable();
         //Размещаем скролл.
         AllocationScroll();
      }
      virtual void OnCommand(EventNodeCommand* event)
      {
         //Команды снизу не принимаются.
         if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
         
         //Размещаем заголовок таблицы.
         AllocationHeader();
         //Размещаем рабочую область.
         AllocationWorkTable();
         //Размещаем скролл.
         AllocationScroll();
      }
      
      ///
      /// Ширина линии.
      ///
      int highLine;
      
};

#ifndef TABLEPOSITION_MQH
   #include "TablePositions.mqh"
#endif



