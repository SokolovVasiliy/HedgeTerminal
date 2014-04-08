//#include "..\API\Position.mqh"
#include "..\Events.mqh"
#include "Node.mqh"
#include "Button.mqh"
#include "TreeViewBox.mqh"
#include "Line.mqh"
#include "Label.mqh"
#include "TableWork.mqh"
#include "TableWork2.mqh"

#ifndef TABLE_MQH
   #define TABLE_MQH
#endif 



#include "TableAbstrPos2.mqh"
///
/// ����� "�������" ������������ �� ���� ������������� ���������, ��������� �� ���� ���������:
/// 1. ��������� �������;
/// 2. ������������ ��������� �����;
/// 3. ������ ��������� ������������� ���������� �����.
/// ������ �� ���� ��������� ����� ���� ������������ ���������.
///
class Table : public Label
{
   public:      
      ///
      /// ���������� ����� ������ ���� ����� � �������.
      ///
      long LinesHighTotal()
      {
         return (long)workArea.LinesHighTotal();
      }
      ///
      /// ���������� ����� ������ ���� ������� ����� � �������.
      ///
      long LinesHighVisible()
      {
         return (long)workArea.LinesHighVisible();
      }
      ///
      /// ���������� ����� ���������� ���� ����� � �������, � �.�. ��
      /// ������������ �� ��������� ����.
      ///
      int LinesTotal()
      {
         return workArea.ChildsTotal();
      }
      
      ///
      /// ���������� ���������� �����, ������������ � ������� ������ �
      /// ���� �������.
      ///
      int LinesVisible()
      {
         if(workArea != NULL)
            return workArea.LinesVisible();
         return 0;
      }
      ///
      /// ���������� ������ ������ ������� ������.
      ///
      int LineVisibleFirst()
      {
         if(workArea != NULL)
            return workArea.LineVisibleFirst();
         return -1;
      }
      ///
      /// ������ ������ ������ ������� ������.
      ///
      void LineVisibleFirst(int index)
      {
         workArea.LineVisibleFirst(index);
      }

      ///
      /// �������� ���������� ��������� �������.
      ///
      void AllocationHeader()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 1, Width()-22, 20);
         bool vis = Visible();
         lineHeader.Event(command);
         delete command;
      }
      ///
      /// �������� ���������� ������� ������� �������.
      ///
      void AllocationWorkTable()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 21, Width()-22, High()-24);
         workArea.Event(command);
         delete command;
      }
      ///
      /// �������� ���������� ������� �������.
      ///
      /*void AllocationScroll()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-21, 1, 20, High()-2);
         scroll.Event(command);
         delete command;
      }*/
      ///
      /// �������� ���������� ������ ������� �������.
      ///
      void AllocationNewScroll()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-21, 1, 20, High()-2);
         nscroll.Event(command);
         delete command;
         /*command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 2, Width()-4, 20);
         gscroll.Event(command);
         delete command;*/
      }
      /*TableDirective* SetTable()
      {
         return GetPointer(tDir);
      }*/
      ///
      /// ���������� ��� ������� �������.
      ///
      ENUM_TABLE_TYPE TableType(){return tblType;}
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_SCROLL_CHANGED:
               if(nscroll != NULL)
                  workArea.OnScrollChanged();
               break;
         }
      }
   protected:
      Table(string myName, ProtoNode* parNode, ENUM_TABLE_TYPE tableType = TABLE_POSACTIVE):Label(ELEMENT_TYPE_TABLE, myName, parNode)
      {
         //tDir.TableType(tableType);
         //��� ������, �������������� �������, ��������� ����������� ���������.
         //if(tDir.IsPositionTable())
         //   lineHeader = new AbstractLine("header", ELEMENT_TYPE_TABLE_HEADER_POS, GetPointer(this));
         tblType = tableType;
         Init(myName, parNode);
      }
      ///
      /// ��������� �������.
      ///
      AbstractLine* lineHeader;
      //Line* lineHeader;
      ///
      /// ������� ������� �������
      ///
      #ifndef NEW_TABLE
      CWorkArea* workArea;
      #endif
      #ifdef NEW_TABLE
      WorkArea* workArea;
      #endif
      ///
      /// ����� ������.
      ///
      Scroll* nscroll;
      ///
      /// �������������� ������.
      ///
      Scroll* gscroll;
      
      virtual Line* InitHeader()
      {
         return new Line("Header", ELEMENT_TYPE_TABLE_HEADER, GetPointer(this));
      }
      ///
      /// �������� ����� ����������, �������������� ��������� �������.
      ///
      //TableDirective tDir;

   private:
      void Init(string myName, ProtoNode* parNode)
      {
         ReadOnly(true);
         BorderType(BORDER_FLAT);
         BorderColor(clrWhite);
         highLine = 20;
         // ��������� ������� ������ ������������������� � �������� � ������ �������.
         //...
         #ifndef NEW_TABLE
         workArea = new CWorkArea(GetPointer(this));
         #endif
         #ifdef NEW_TABLE
         workArea = new WorkArea(GetPointer(this));
         #endif
         workArea.ReadOnly(true);
         workArea.Text("");
         workArea.BorderColor(BackgroundColor());
         
         nscroll = new Scroll("", GetPointer(this), SCROLL_VERTICAL);
         nscroll.BorderType(BORDER_FLAT);
         nscroll.BorderColor(clrBlack);
         workArea.AddScroll(nscroll);
         childNodes.Add(nscroll);
         
         //�������� �������������� ������.
         gscroll = new Scroll("NewScroll", GetPointer(this), SCROLL_HORIZONTAL);
         gscroll.BorderType(BORDER_FLAT);
         gscroll.BorderColor(clrBlack);
         childNodes.Add(gscroll);
         
         childNodes.Add(workArea);
         //childNodes.Add(scroll);
      }
      
      
      virtual void OnCommand(EventVisible* event)
      {
         if(!event.Visible())return;
         //��������� ��������� �������.
         AllocationHeader();
         //��������� ������� �������.
         AllocationWorkTable();
         //��������� ������.
         //AllocationScroll();
         //
         AllocationNewScroll();
      }
      virtual void OnCommand(EventNodeCommand* event)
      {
         //������� ����� �� �����������.
         if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
         
         //��������� ��������� �������.
         AllocationHeader();
         //��������� ������� �������.
         AllocationWorkTable();
         //��������� ������.
         //AllocationScroll();
         //
         AllocationNewScroll();
      }
      ///
      /// ������ �����.
      ///
      int highLine;
      ///
      /// ��� �������.
      ///
      ENUM_TABLE_TYPE tblType;
};

#ifndef TABLEPOSITION_MQH
   #include "TablePositions.mqh"
#endif



