#include "Node.mqh"
#include "Table.mqh"

///
/// �������� ������, ��� ��������� � ����������� ������������� ������� ���� ��������. 
///
class Toddler : public Label
{
   public:
      Toddler(ProtoNode* parNode, Table* tbl) : Label(ELEMENT_TYPE_TODDLER, "Toddler", parNode)
      {
         BorderColor(parNode.BackgroundColor());
         Edit(true);
         labToddle = new Label("btnToddle", GetPointer(this));
         labToddle.Text("");
         table = tbl;  
      }
      
   private:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_MOUSE_MOVE:
               OnMouseMove(event);
            default:
               EventSend(event);
               break;
         }
      }
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(table == NULL)return;
         //���������� ������ ��������.
         long highArea = parentNode.High();
         long totalHigh = table.HighLines();
         long high = High();
         //�������� ��������, ���� ������ ������� ������� ������ ���������
         //������ ���� ����� �������.
         if(totalHigh < highArea)
         {
            EventVisible* vis = new EventVisible(EVENT_FROM_UP, NameID(), false);
            labToddle.Event(vis);
         }
         //� ��������� ������ ���������� ��������� �������� � ������������� ���
         //������, � ����������� �� �������� �������� ������������.
         else if(totalHigh - high < high)
         {
            //������������ ������ ��������
            long highToddle = high - (totalHigh - high);
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 1, 1, Width()-2, highToddle);
            labToddle.Event(command);
            delete command;
         }
      }
      ///
      /// ���������� ������� � ���� �� �����.
      ///
      void OnMouseMove(EventMouseMove* event)
      {
         // ��� ��������� ��������� �������� ������ ������ ������
         // ���� ������ ���� ������.
         /*
         if(!event.PushedRightButton())return;
         long x = event.XCoord();
         long xAbs = XAbsDistance();
         if(x > xAbs + Width() || x < xAbs)return;
         long y = event.YCoord();
         long yAbs = YAbsDistance();
         if(y > yAbs + High() || y < yAbs)return;
         */
      }
      ///
      /// ���������� �������������� ���������� ����.
      ///
      long prevX;
      ///
      /// ���������� ������������ ���������� ����.
      ///
      long prevY;
      ///
      /// ��������, ����������� �� ������� ���� ��������.
      ///
      Label* labToddle;
      ///
      /// ��������� �� ������������ �������.
      ///
      Table* table;
};
///
/// ��������� ������.
///
class Scroll : public ProtoNode
{
   public:
      Scroll(string myName, ProtoNode* parNode) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         //� ������ ���� ��� ������ � ��������.
         up = new Button("UpClick", GetPointer(this));
         up.BorderType(BORDER_FLAT);
         up.BorderColor(clrBlack);
         //up.BorderColor(clrNONE);
         up.Font("Wingdings");
         up.Text(CharToString(241));
         up.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(up);
         
         dn = new Button("DnClick", GetPointer(this));
         dn.BorderType(BORDER_FLAT);
         dn.BorderColor(clrBlack);
         //dn.BorderColor(clrNONE);
         dn.Font("Wingdings");
         dn.Text(CharToString(242));
         dn.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(dn);
         
         toddler = new Toddler(GetPointer(this), parentNode);
         //toddler.BorderType(BORDER_FLAT);
         //toddler.BorderColor(clrBlack);
         //toddler.BorderColor(clrNONE);
         toddler.Text("");
         toddler.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(toddler);
         
         BackgroundColor(clrWhiteSmoke); 
      }
      
      
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         //������������� ������� ������.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 2, 16, 16);
         up.Event(command);
         delete command;
         
         //������������� ������ ������.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, High()-18, 16, 16);
         dn.Event(command);
         delete command;
         
         //������������� ��������.
         //�������� ������ �������� ���� Y ���������� ��������������.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 1, 18, Width()-2, High()-36);
         toddler.Event(command);
         delete command;
      }
      //� ������ ���� ��� ������ � ��������.
      Button* up;
      Button* dn;
      Toddler* toddler;
};
