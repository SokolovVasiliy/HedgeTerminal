//#include "..\API\Position.mqh"
#include "..\Events.mqh"
#include "Node.mqh"
#include "Button.mqh"
#include "TreeViewBox.mqh"
#include "Line.mqh"
#include "Label.mqh"
#include "Scroll.mqh"
#include "TableWork.mqh"
//#include "TableDirective.mqh"



#ifndef TABLE_MQH
   #define TABLE_MQH
#endif 

///
/// ���������� ��� ������� �������. ������������ � �������� ����� ���������������� ���� ��������� � ENUM_TABLE_TYPE_ELEMENT.
///
enum ENUM_TABLE_TYPE
{
   ///
   /// ������� ��-���������. ���������� ������ �� ������������.
   ///
   TABLE_DEFAULT = 0,
   ///
   /// ������� �������� �������.
   ///
   TABLE_POSACTIVE = 1,
   ///
   /// ������� ������������ �������.
   ///
   TABLE_POSHISTORY = 2,
};

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
      ///
      /// �������� ���������� ������ ������� �������.
      ///
      void AllocationNewScroll()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-21, 1, 20, High()-2);
         nscroll.Event(command);
         delete command;
      }
      /*TableDirective* SetTable()
      {
         return GetPointer(tDir);
      }*/
      ///
      /// ���������� ��� ������� �������.
      ///
      ENUM_TABLE_TYPE TableType(){return tblType;}
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
      CWorkArea* workArea;
      ///
      /// ������.
      ///
      Scroll* scroll;
      ///
      /// ����� ������.
      ///
      NewScroll* nscroll;
      
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
         workArea = new CWorkArea(GetPointer(this));
         workArea.ReadOnly(true);
         workArea.Text("");
         workArea.BorderColor(BackgroundColor());
         
         scroll = new Scroll("Scroll", GetPointer(this));
         scroll.BorderType(BORDER_FLAT);
         scroll.BorderColor(clrBlack);
         
         nscroll = new NewScroll("NewScroll", GetPointer(this), SCROLL_VERTICAL);
         nscroll.BorderType(BORDER_FLAT);
         nscroll.BorderColor(clrBlack);
         childNodes.Add(nscroll);
         
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
         AllocationScroll();
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



