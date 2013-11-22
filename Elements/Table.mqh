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
/// ����� "�������" ������������ �� ���� ������������� ���������, ��������� �� ���� ���������:
/// 1. ��������� �������;
/// 2. ������������ ��������� �����;
/// 3. ������ ��������� ������������� ���������� �����.
/// ������ �� ���� ��������� ����� ���� ������������ ���������.
///
class Table : public Label
{
   public:
      Table(string myName, ProtoNode* parNode, ENUM_TABLE_TYPE tableType = TABLE_POSACTIVE):Label(ELEMENT_TYPE_TABLE, myName, parNode)
      {
         tDir.TableType(tableType);
         //��� ������, �������������� �������, ��������� ����������� ���������.
         if(tDir.IsPositionTable())
            lineHeader = new AbstractPos("header", ELEMENT_TYPE_TABLE_HEADER_POS, GetPointer(this));
         
         Init(myName, parNode);
      }
      
      ///
      /// ���������� ����� ������ ���� ����� � �������.
      ///
      long LinesHighTotal()
      {
         return workArea.LinesHighTotal();
      }
      ///
      /// ���������� ����� ������ ���� ������� ����� � �������.
      ///
      long LinesHighVisible()
      {
         return workArea.LinesHighVisible();
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
      /// ������ ������ ������ ������� ������.
      ///
      void LineVisibleFirst1(int index)
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
      void AllocationScroll()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-21, 1, 20, High()-2);
         scroll.Event(command);
         delete command;
      }
   protected:
      ///
      /// ��������� �������.
      ///
      Line* lineHeader;
      //Line* lineHeader;
      ///
      /// ������� ������� �������
      ///
      CWorkArea* workArea;
      ///
      /// ������.
      ///
      Scroll* scroll;
      virtual Line* InitHeader()
      {
         return new Line("Header", ELEMENT_TYPE_TABLE_HEADER, GetPointer(this));
      }
      ///
      /// �������� ����� ����������, �������������� ��������� �������.
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
         //��������� ��������� �������.
         AllocationHeader();
         //��������� ������� �������.
         AllocationWorkTable();
         //��������� ������.
         AllocationScroll();
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
         AllocationScroll();
      }
      
      ///
      /// ������ �����.
      ///
      int highLine;
      
};

#ifndef TABLEPOSITION_MQH
   #include "TablePositions.mqh"
#endif



