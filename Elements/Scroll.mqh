#include "Node.mqh"
#include "Table.mqh"

///
/// 
///
class LabToddle : public Label
{
   public:
      LabToddle(ProtoNode* parNode, Table* tbl) : Label(ELEMENT_TYPE_LABTODDLER, "LabToddler", parNode)
      {
         table = tbl;
         Text("");
         Edit(true);
         prevY = -1;
      }
   private:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_MOUSE_MOVE:
               OnMouseMove(event);
               break;
            default:
               EventSend(event);
         }
      }
      ///
      /// ���������� ������� � ���� �� �����.
      ///
      void OnMouseMove(EventMouseMove* event)
      {
         // ������� ������ ������ ��������� ��� �������� ����, �
         // ������ ������ ������ ���� ������. � ��������� ������
         // �������� ���������� y ���������� ����.
         if(!IsMouseSelected(event) ||
            !event.PushedRightButton())
         {
            prevY = -1;
            return;
         }
         //� ������ ��� ������ ���������� ��������� ����
         if(prevY == -1)
         {
            prevY = event.YCoord();
            return;
         }
         
         //����� ������� �������� �� ������������ ���������
         long delta = event.YCoord() - prevY;
         long yLocal = YLocalDistance();
         long yLimit = yLocal + High() + delta;
         //�������� �� ����� ������� �� ������ ������� ������������.
         if(delta > 0 && yLimit > parentNode.High())
            delta = parentNode.High() - High() - yLocal;
         //�������� �� ����� ������� �� ������� ������� ������������.
         if(delta < 0 && yLocal < MathAbs(delta))
            delta = yLocal * (-1);
         //������ ������ ��� �������.
         if(yLocal + delta == 0)delta += 1;
         if(yLimit >= parentNode.High())
            delta -= 1;
         Move(XLocalDistance(), yLocal + delta, COOR_LOCAL);
         prevY = event.YCoord();
         
         //������, ����� �������� ����������, ������������
         //������ ������� ������ � �������
         yLocal = YLocalDistance();
         long parHigh = parentNode.High();
         //������ ������������ ��� ������� �������.
         if(yLocal == 1) yLocal--;
         if(yLocal + High() == parentNode.High()-1)
            yLocal++;
         //������������ % ������� �� ������ ������
         double perFirst = yLocal/((double)parHigh);
         int lineFirst = (int)(table.LinesTotal() * perFirst);
         printf("LF: " + lineFirst);
         table.LineVisibleFirst(lineFirst);
         ChartRedraw();
         //printf("Scroll FL: " + table.LineVisibleFirst() + " Visible: " + table.LinesVisible());
      }
      ///
      /// ��������� �� �������, ��������� ��������� ������� ���� ��������.
      ///
      Table* table;
      ///
      /// ���������� ������������ ���������� ����.
      ///
      long prevY;
};
///
/// ������������ �������� ������. ������ ��� ������, � ����������� �� ��������� ������� � ��������� �����. 
///
class Toddler : public Label
{
   public:
      Toddler(ProtoNode* parNode, Table* tbl) : Label(ELEMENT_TYPE_TODDLER, "Toddler", parNode)
      {
         BorderColor(parNode.BackgroundColor());
         Edit(true);
         labToddle = new LabToddle(GetPointer(this), tbl);
         childNodes.Add(labToddle);
         table = tbl;  
      }
      
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(table == NULL)return;
         // 1. ������� ��������� ���� ����� � ������� �������:
         double p1 = ((double)table.LinesHighVisible())/((double)table.LinesHighTotal());
         // ���� ��������� ������ ���� ����� ������� - ��� ������ ��������� �� �����
         // ������, � �������� ���������� �� ����.
         if(NormalizeDouble(p1, 4) >= 1.0)
         {
            if(!labToddle.Visible())return;
            EventVisible* vis = new EventVisible(EVENT_FROM_UP, GetPointer(this), false);
            labToddle.Event(vis);
            delete vis;
            return;
         }
         // ������ �������� - ��� ������ ��������� ������� ������������
         // ����� � ����� ������ ���� �����.
         else
         {
            // ��������� ��������� � ������� �������� ������������ ��� ������������
            long size = (long)(High()*p1);
            //�������� �� ����� ���� ������ 5 ��������.
            if(size < 5)size = 5;
            long yMyDist = labToddle.YLocalDistance();
            if(yMyDist == 0)yMyDist = 1;
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 1, yMyDist, Width()-2, size);
            labToddle.Event(command);
            delete command;
         }
      }
      ///
      /// ��������, ����������� �� ������� ���� ��������.
      ///
      LabToddle* labToddle;
      ///
      /// ��������� �� ������������ �������.
      ///
      Table* table;
};
///
/// ��� ������ ������.
///
enum ENUM_CLICK_SCROLL
{
   CLICK_SCROLL_DOWN,
   CLICK_SCROLL_UP
};

class ClickScroll : public Button
{
   public:
      ClickScroll(ProtoNode* parNode, Table* tbl, ENUM_CLICK_SCROLL tClick) : Button("ScrollClickDn", parNode)
      {
         typeClick = tClick;
         Text(CharToString(241));
         if(typeClick == CLICK_SCROLL_DOWN)
         {
            itt = 1;
            Text(CharToString(242));
         }
         else itt = -1;
         Font("Wingdings");
         
         BackgroundColor(clrWhiteSmoke);
         BorderColor(clrBlack);
         table = tbl;
      }
   private:
      void OnPush()
      {
         int fline = table.LineVisibleFirst();
         int vline = table.LinesVisible();
         if(fline + vline >= table.LinesTotal() && itt == 1)
         {
            printf("���� ������ ���������");
            return;
         }
         if(fline == 0 && itt == -1)
         {
            printf("���������� ������ ������");
            return;
         }
         if(itt == 1)
            table.LineVisibleFirst(fline+itt);
         else
            table.LineVisibleFirst(fline+itt);
         //printf("������ ������ " + table.LineVisibleFirst());
      }
      Table* table;
      ///
      /// ��� ������ ������.
      ///
      ENUM_CLICK_SCROLL typeClick;
      ///
      /// ���������� ������������ �����.
      ///
      int itt;
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
         up = new ClickScroll(GetPointer(this), parNode, CLICK_SCROLL_UP);
         childNodes.Add(up);
         

         dn = new ClickScroll(GetPointer(this), parNode, CLICK_SCROLL_DOWN);
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
      ClickScroll* up;
      ClickScroll* dn;
      Toddler* toddler;
};
