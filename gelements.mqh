
#include "gnode.mqh"

///
/// �������� ����� ������.
///
class MainForm : public ProtoNode
{
   public:
      ///
      /// ���������� ������� �� ����������� �������.
      ///
      virtual void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_NODE_RESIZE:
                  ResizeExtern(newEvent);
                  break;
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               case EVENT_INIT:
                  Init(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               case EVENT_CHSTATUS:
                  ChStatus(newEvent);
                  break;
               //������� ������� �� ����� ���������� ���������� ������ ����.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      MainForm():ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_FORM, "HedgePanel", NULL)
      {
         //TableOpenPos* table = new TableOpenPos(GetPointer(this));
         childNodes.Add(new TableOpenPos(GetPointer(this)));
      }
   private:
      ///
      /// ���������� ������� '��������� �������� ���� ��������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void ResizeExtern(EventResize* event)
      {
         //������ ����� �� ����� ���� ������ 100 ��������.
         long cwidth = CheckWidth(event.NewWidth());
         //������ ����� �� ����� ���� ������ 50 ��������.
         long chigh = CheckHigh(event.NewHigh());
         Resize(cwidth, chigh);
         EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         EventSend(er);
         delete er;
      }
      void ChStatus(EventNodeStatus* event)
      {
         //������ ����� �� ����� ���� ������ 100 ��������.
         long cwidth = CheckWidth(event.Width());
         //������ ����� �� ����� ���� ������ 50 ��������.
         long chigh = CheckHigh(event.High());
         Resize(cwidth, chigh);
         if(!Visible())
            Visible(true);
         EventNodeStatus* er = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(), XAbsDistance(), YAbsDistance(), Width(), High());
         EventSend(er);
         delete er;
      }
      ///
      /// ��������� �������� �� ���������� ��������� ������. ���� ��������� ������ �������� - ���������� ��,
      /// ���� ���, ���������� ��������� ���������.
      /// \return ������ ����.
      ///
      long CheckWidth(long cwidth)
      {
         if(cwidth < 100)
            return 100;
         return cwidth;
      }
      ///
      /// ��������� �������� �� ���������� ��������� ������. ���� ��������� ������ �������� - ���������� ��,
      /// ���� ���, ���������� ��������� ���������.
      /// \return ������ ����.
      ///
      long CheckHigh(long chigh)
      {
         if(chigh < 70)
            return 70;
         return chigh;
      }
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         Visible(event.Visible());
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
      ///
      /// ������������� � ���������� ������� ������� �����.
      ///
      void Init(EventInit* event)
      {
         long X;     // ������� ������ ���� ����������
         long Y;     // ������� ������ ���� ����������
         X = CheckWidth(ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW));
         Y = CheckHigh(ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW));
         Resize(X, Y);
         Visible(true);
         EventSend(event);
      }
};
///
/// ����� "������".
///
class Button : public ProtoNode
{
   public:
      virtual void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               //case EVENT_INIT:
               //   Init(newEvent);
               //   break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               case EVENT_NODE_COMMAND:
                  RunCommand(newEvent);
               //������� ������� �� ����� ���������� ���������� ������ ����.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      Button(string myName, ProtoNode* parNode):ProtoNode(OBJ_BUTTON, ELEMENT_TYPE_HEAD_COLUMN, myName, parNode)
      {
         ;
      }
   private:
      ///
      /// ��������� ��������.
      ///
      void RunCommand(EventNodeCommand* event)
      {
         Move(event.XDist(), event.YDist());
         Resize(event.Width(), event.High());
         Visible(event.Visible());
         if(Visible())
         {
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, ShortName());
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BORDER_COLOR, clrNONE);
         }
      }
      
      
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         Visible(vis);
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
      ///
      ///
      ///
      void Init(EventInit* event)
      {
         /*Move(0,0);
         Resize(80, 20);
         Visible(true);
         EventSend(event);*/
      }
};

///
/// ��������� �����
///
class Label : ProtoNode
{
   public:
      Label(string myName, ProtoNode* node) : ProtoNode(OBJ_EDIT, ELEMENT_TYPE_LABEL, myName, node){;}
      virtual void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               case EVENT_NODE_COMMAND:
                  RunCommand(newEvent);
               //������� ������� �� ����� ���������� ���������� ������ ����.
               default:
                  EventSend(newEvent);
            }
         }
      }
   private:
      ///
      /// ��������� ��������.
      ///
      void RunCommand(EventNodeCommand* event)
      {
         Move(event.XDist(), event.YDist());
         Resize(event.Width(), event.High());
         Visible(true);
         if(Visible())
         {
            //ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, ShortName());
         }
      }
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         Visible(vis);
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
};
   

///
/// ������ �������.
///
class Cell : public ProtoNode
{
   public:
      virtual void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               case EVENT_NODE_COMMAND:
                  RunCommand(newEvent);
               //������� ������� �� ����� ���������� ���������� ������ ����.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      Cell(string myName, ProtoNode* parNode):ProtoNode(OBJ_LABEL, ELEMENT_TYPE_HEAD_COLUMN, myName, parNode)
      {
         ;
      }
   private:
      ///
      /// ��������� ��������.
      ///
      void RunCommand(EventNodeCommand* event)
      {
         Move(event.XDist(), event.YDist());
         Resize(event.Width(), event.High());
         Visible(true);
         if(Visible())
         {
            //ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, ShortName());
         }
      }
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         Visible(vis);
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
      
};

///
/// ��������� ���������.
///
class Line : ProtoNode
{
   public:
      Line(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_GCONTAINER, myName, parNode){;}
      ///
      /// ��������� ���� � ��������� ���������.
      ///
      void Add(ProtoNode* node)
      {
         
         childNodes.Add(node);
      }
      virtual void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_NODE_COMMAND:
                  CommandExtern(newEvent);
                  break;
               case EVENT_INIT:
                  MyInit(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               default:
                  EventSend(newEvent);
            }
         }
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
         //EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         //EventSend(er);
         //delete er;
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
   private:
      ///
      /// ��������� � ������ ���������� ����������.
      ///
      void CommandExtern(EventNodeStatus* newEvent)
      {
         Move(newEvent.XDist(), newEvent.YDist());
         Resize(newEvent.Width(), newEvent.High());
         Visible(newEvent.Visible());
         // �� ���� ������, ������� ������ �� ������ ���������� ����������.
         //��� �������� ������������ �� ����� �����
         int total = childNodes.Total();
         //��������� ������� �� �����������, ������������ �������� ����.
         long xdist = 0;
         ProtoNode* prevColumn = NULL;
         ProtoNode* node = NULL;
         long kBase = 1250;
         //����������� ����������������.
         double kScale = (double)Width()/(double)kBase;
         for(int i = 0; i < total; i++)
         {
            node = childNodes.At(i);
            //������������ ������� �������� �� �����������.
            xdist = i > 0 ? prevColumn.XLocalDistance() + prevColumn.Width() : 0;
            //��������� ������� �������� ��� ���������� �����
            long cwidth = 0;
            cwidth = i == total-1 ? cwidth = Width() - xdist : (long)MathRound((double)node.OptimalWidth() * kScale);
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist, 0, cwidth, High());
            node.Event(command);
            delete command;
            prevColumn = node;
         }
      }
      virtual void MyInit(EventInit* event)
      {
         //������������� ����������� ��������� ��������
         //Resize(20, 20);
         //Resize(0, 0, 0, 0);
         //Visible(true);
         //EventSend(event);
      }
};
///
/// ��������� ������.
///
class Scroll : ProtoNode
{
   public:
      Scroll(string myName, ProtoNode* parNode) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         //� ������ ���� ��� ������ � ��������.
         up = new Button("UpClick", GetPointer(this));
         childNodes.Add(up);
         
         dn = new Button("DnClick", GetPointer(this));
         childNodes.Add(dn);
         
         toddler = new Button("Todler", GetPointer(this));
         childNodes.Add(toddler);
         
      }
      void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_CHSTATUS:
                  ChStatusExtern(newEvent);
                  break;
               //case EVENT_INIT:
                  //MyInit(newEvent);
                  //break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               default:
                  EventSend(newEvent);
            }
         }
      }
   private:
      void ChStatusExtern(EventNodeStatus* event)
      {
         long w = event.Width();
         long h = event.High(); 
         bool v = event.Visible();
         Move(event.Width() - 20, 0);
         Resize(20, event.High());
         Visible(event.Visible());
         //������������� ������� ������.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 2, 16, 16);
         up.Event(command);
         delete command;
         
         //������������� ������ ������.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, High()-16, 16, 16);
         dn.Event(command);
         delete command;
      }
      
      //� ������ ���� ��� ������ � ��������.
      Button* up;
      Button* dn;
      Button* toddler;
};

///
/// ����� "�������". ������ ������� ����� ��������� ����� ����������� ��������, ��
/// ��������� ���������� ���� ��� ������, ����� � ����������� �����.
/// �� ���������� ���������� ������� ��������� �������� ���������������� ������� MyInit().
///
class Table : public ProtoNode
{
   public:
      Table(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_UCONTAINER, myName, parNode)
      {
         backgroundColor = clrDimGray;
      }
      void Add(ProtoNode* lineNode)
      {
         childNodes.Add(lineNode);
      }
      
      virtual void Event(Event *newEvent)
      {
         // ������������ ������� ���������� ������.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_CHSTATUS:
                  ChStatusExtern(newEvent);
                  break;
               case EVENT_INIT:
                  MyInit(newEvent);
                  break;
               case EVENT_DEINIT:
                  Deinit(newEvent);
                  break;
               default:
                  EventSend(newEvent);
            }
         }
      }
   protected:
      virtual void MyInit(){;}
      //���� �������� �������.
      color backgroundColor;
   private:
      virtual void ChStatusExtern(EventNodeStatus* newEvent)
      {
         Resize(40, 20, 40, 5);
         //�� ����������� ���������� ������� �������.
         if(Visible(true))
         {
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
               LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR);
            ObjectCreate(0, "edittext", OBJ_EDIT, 0, 30, 30);
            ObjectSetInteger(0, "edittext", OBJPROP_XDISTANCE, 40);
            ObjectSetInteger(0, "edittext", OBJPROP_YDISTANCE, 80);
            ObjectSetInteger(0, "edittext", OBJPROP_BGCOLOR, clrNONE);
            ObjectSetInteger(0, "edittext", OBJPROP_BORDER_COLOR, clrNONE);
            //ObjectSetInteger(0, "edittext", OBJPROP_WIDTH, 3);
            ObjectSetString(0, "edittext", OBJPROP_TEXT, "edit text");
         }
         //������, � ����������� �� ��������, ���������� ��� ���������
         long ydist = 0;
         //ProtoNode* prevNode
         for(int i = 0; i < childNodes.Total(); i++)
         {
            
            ProtoNode* node = childNodes.At(i);
            if(node.TypeElement() == ELEMENT_TYPE_GCONTAINER)
            {
             EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, ydist, Width()-20, 20);
             node.Event(command);
             delete command;
             ydist += node.High();
            }
            //
            if(node.TypeElement() == ELEMENT_TYPE_SCROLL)
            {
               bool v = Visible();
               EventNodeStatus* ch = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(), XAbsDistance(), YAbsDistance(), Width(), High());
               node.Event(ch);
               delete ch;
            }
         }
         
      }
      virtual void MyInit(EventInit* event)
      {
         Resize(40, 20, 40, 5);
         Visible(true);
         EventSend(event);
      }
};

///
/// ������� �������� �������.
///
class TableOpenPos : public Table
{
   public:
      TableOpenPos(ProtoNode* parNode):Table("TableOfOpenPos.", parNode)
      {
         // ������ ����� �������� ��������� �������.
         Line* lineHeader = new Line("LineHeader", GetPointer(this));
         
         // ���������� �����
         Button* hmagic = new Button("Magic", GetPointer(lineHeader));
         hmagic.OptimalWidth(50);
         lineHeader.Add(hmagic);
         
         // ������
         Button* hSymbol = new Button("Symbol", GetPointer(lineHeader));
         hmagic.OptimalWidth(70);
         lineHeader.Add(hSymbol);
         
         // Order ID
         Button* hOrderId = new Button("Order ID", GetPointer(lineHeader));
         hOrderId.OptimalWidth(70);
         lineHeader.Add(hOrderId);
         
         // ����� ����� � �������.
         Button* hEntryDate = new Button("Entry Date", GetPointer(lineHeader));
         hEntryDate.OptimalWidth(150);
         lineHeader.Add(hEntryDate);
         
         
         // ����������� �������.
         Button* hTypePos = new Button("Type", GetPointer(lineHeader));
         hTypePos.OptimalWidth(50);
         lineHeader.Add(hTypePos);
         
         // �����
         Button* hVolume = new Button("Vol.", GetPointer(lineHeader));
         hVolume.OptimalWidth(50);
         lineHeader.Add(hVolume);
         
         // ���� �����.
         Button* hEntryPrice = new Button("Price", GetPointer(lineHeader));
         hEntryPrice.OptimalWidth(70);
         lineHeader.Add(hEntryPrice);
         
         // ����-����
         Button* hStopLoss = new Button("S/L", GetPointer(lineHeader));
         hStopLoss.OptimalWidth(70);
         lineHeader.Add(hStopLoss);
         
         // ����-������
         Button* hTakeProfit = new Button("T/P", GetPointer(lineHeader));
         hTakeProfit.OptimalWidth(70);
         lineHeader.Add(hTakeProfit);
         
         // ������� ����
         Button* hCurrentPrice = new Button("Price", GetPointer(lineHeader));
         hCurrentPrice.OptimalWidth(70);
         lineHeader.Add(hCurrentPrice);
         
         // ������
         Button* hProfit = new Button("Profit", GetPointer(lineHeader));
         hProfit.OptimalWidth(70);
         lineHeader.Add(hProfit);
         
         // �����������
         Button* hComment = new Button("Comment", GetPointer(lineHeader));
         hComment.OptimalWidth(150);
         lineHeader.Add(hComment);
         
         //�����
         Scroll* myscroll = new Scroll("Scroll", GetPointer(this));
         Add(myscroll);
         
         Add(lineHeader);
      }
   private:
      virtual void MyInit(EventInit* event)
      {
         Resize(40, 20, 40, 5);
         Visible(true);
         EventSend(event);
      }
};