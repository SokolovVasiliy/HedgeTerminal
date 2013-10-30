
///
/// ������������� ����������� �� �������� ������������ ��������� � �������������� ��� ������������ ����������.
///
enum ENUM_LINE_ALIGN_TYPE
{
   ///
   /// ��������������� �� ������ ��������������� ������/������ ��������.
   ///
   LINE_ALIGN_SCALE,
   ///
   /// ��������������� ������� ������.
   ///
   LINE_ALIGN_CELL,
   ///
   /// ��������������� ������ ������� ���������� ������.
   ///
   LINE_ALIGN_CELLBUTTON,
   ///
   /// ����������� ������������� ����� ������/������ ���������� ����� ����� ����������.
   ///
   LINE_ALIGN_EVENNESS
};
///
/// �������������� ������.
///
class Line : public ProtoNode
{
   public:
      Line(string myName, ProtoNode* parNode):ProtoNode(OBJ_EDIT, ELEMENT_TYPE_GCONTAINER, myName, parNode)
      {
         clearance = 1;
         BorderColor(clrWhite);
         OptimalHigh(20);
         typeAlign = LINE_ALIGN_SCALE;
      }
      Line(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode):ProtoNode(OBJ_EDIT, elType, myName, parNode)
      {
         clearance = 1;
         BorderColor(clrWhite);
         OptimalHigh(20);
         typeAlign = LINE_ALIGN_SCALE;
      }
      ///
      /// ������������� �������� ������������ ��� ��������� ������ �����.
      ///
      void AlignType(ENUM_LINE_ALIGN_TYPE align)
      {
         typeAlign = align;
      }
      ///
      /// ���������� ������������� ��������� ������������ ��������� ������ �����.
      ///
      ENUM_LINE_ALIGN_TYPE AlignType()
      {
         return typeAlign;
      }
      ///
      /// ��������� ���� � ��������� ���������.
      ///
      void Add(ProtoNode* node)
      {  
         childNodes.Add(node);
      }
      ///
      /// ������������� ������ ������� �����.
      ///
      void HighLine(long curHigh)
      {
         Resize(Width(), curHigh);
         //EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
      }
      ///
      /// ������������� ������ ������� �����.
      ///
      void WidthLine(long curWidth)
      {
         Resize(curWidth, High());
      }
      ///
      /// ����������� ����� �� ����� ����������.
      ///
      void MoveLine(long xdist, long ydist, ENUM_COOR_CONTEXT context = COOR_LOCAL)
      {
         Move(xdist, ydist, context);
      }
      ///
      /// ������������� ��������� �����.
      ///
      void VisibleLine(bool isVisible)
      {
         Visible(isVisible);
      }
      ///
      /// ������������� ����� ����� ���������� ������.
      ///
      void Clearance(int clr)
      {
         clearance = clr;
      }
      ///
      /// ���������� ����� ����� ����������.
      ///
      int Clearance(){return clearance;}
      
   private:
      virtual void OnVisible(EventVisible* event)
      {
         if(parentNode != NULL && parentNode.TypeElement() ==
            ELEMENT_TYPE_WORK_AREA)
         {
            //�� �������� �������/������������ �������� ��������
            EventSend(event);
            // ������ ���� ������ ������������� ��������, ��� ������� ����� ��������
            // ���� ������ ���������.
            EventVisible* vis = new EventVisible(EVENT_FROM_DOWN, event.Node(), event.Visible());
            parentNode.Event(vis);
            delete vis;
            //if(event.Visible())
            //   printf(ShortName() + " ON.");
            //else printf(ShortName() + " OFF.");
         }
         else
            EventSend(event);
      }
      ///
      /// ��������� � ������ ���������� ����������.
      ///
      virtual void OnCommand(EventNodeCommand* newEvent)
      {
         if(!Visible() || newEvent.Direction() == EVENT_FROM_DOWN)return;
         string cname = ShortName();
         switch(typeAlign)
         {
            case LINE_ALIGN_CELL:
            case LINE_ALIGN_CELLBUTTON:
               AlgoCellButton();
               break;
            default:
               AlgoScale();
               break;
         }
      }
      
      ///
      /// �������� ��������������� �� ������ ��������������� ������/������ ��������.
      ///
      void AlgoScale()
      {
         //��������� ������� �� �����������, ������������ �������� ����.
         //����� ����� ��������� ���������� � ��������, 0 - ����� ������ ���.
         
         int total = childNodes.Total();
         long xdist = 0;
         ProtoNode* prevColumn = NULL;
         ProtoNode* node = NULL;
         long kBase = 1250;
         //����������� ����������������.
         double kScale = (double)Width()/(double)kBase;
         for(int i = 0; i < total; i++)
         {
            node = childNodes.At(i);
            string sname = node.ShortName();
            //������������ ������� �������� �� �����������.
            xdist = i > 0 ? prevColumn.XLocalDistance() + prevColumn.Width() : 0;
            //��������� ������� �������� ��� ���������� �����
            long cwidth = 0;
            ProtoNode* bindWidth = node.BindingWidth();
            //���� ������ ��������� � ������� ���� - ����� �� � ���� ����.
            if(bindWidth != NULL)
               cwidth = bindWidth.Width();
            //���� ������ �������� ���������� - �� �������� ��.
            else if(node.ConstWidth())
               cwidth = node.OptimalWidth();
            else
               cwidth = i == total-1 ? cwidth = Width() - xdist - clearance : (long)MathRound((double)node.OptimalWidth() * kScale) - clearance;
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist + clearance, 0, cwidth, High());
            node.Event(command);
            delete command;
            prevColumn = node;
         }
      }
      ///
      /// �������� ���������������� ��������� "������ � ��������"
      ///
      void AlgoCellButton()
      {
         //� ���� ������ ���������������, ��� ���������� ������� �� �����, ����� �� ������� - ���������� ������.
         int total = childNodes.Total()-1;
         long xdist = Width();
         long chigh = High();
         //���������� �������� � �������� �������, �.�. ������ ���� ������ ����������
         for(int i = total; i >= 0; i--)
         {
            ProtoNode* node = childNodes.At(i);
            ENUM_ELEMENT_TYPE type = node.TypeElement();
            /*bindWidth = node.BindingWidth();
            if(bindWidth != NULL)
            {
               ;
            }*/
            if(node.TypeElement() == ELEMENT_TYPE_BOTTON)
            {
               xdist -= chigh;
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist, 0, chigh, chigh);
               node.Event(command);
               delete command;
            }
            else
            {
               //������� ������ ��������
               long avrg = (long)MathRound((double)xdist/(double)(total));
               xdist -= avrg;
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist, 0, avrg, chigh);
               node.Event(command);
               delete command;
            }
         }
      }
      ///
      /// ������������� ��������� ������������ � �����.
      ///
      ENUM_LINE_ALIGN_TYPE typeAlign;
      ///
      /// �������, � ���� ������ ���������� ��������� ������ �������� ��������.
      ///
      ProtoNode* bindingWidth;
      ///
      /// �������, � ���� ������ ���������� ��������� ������ �������� ��������.
      ///
      ProtoNode* bindingHigh;
      ///
      /// �������� ����� ����� ��������� ����������.
      ///
      int clearance;
};
