
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
         ;
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
         //������� ������� �������� �������
         TableOfOpenPos* tOpenPos = new TableOfOpenPos("TableOfOpenPos", GetPointer(this));
         childNodes.Add(tOpenPos);
         EventSend(event);
      }
};

///
/// ������� �������� �������.
///
class TableOfOpenPos : ProtoNode
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
            }
         }
      }
      TableOfOpenPos(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_TABLE, myName, parNode)
      {
         ;
      }
   private:
      ///
      /// ���������� ������� '������ ������������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void ResizeExtern(EventResize* event)
      {
         Resize(40, 20, 40, 5);
         //�� ����������� ���������� ������� �������.
         if(ParVisible() && !Visible())
         {
            Visible(true);
            if(Visible(true))
               if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
                  LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR);
         }
         EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         EventSend(er);
         delete er;
      }
      void ChStatus(EventNodeStatus* event)
      {
         Resize(40, 20, 40, 5);
         //�� ����������� ���������� ������� �������.
         if(ParVisible() && !Visible())
         {
            Visible(true);
            if(Visible(true))
               if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
                  LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR);
         }
         EventNodeStatus* cb = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(),
                                    XAbsDistance(), YAbsDistance(), Width(), High());
         EventSend(cb);
         delete cb;
      }
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         if(Visible(vis) && vis)
         {
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
               LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR); 
         }
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
      ///
      /// ���� �������� ������� �������� �������. 
      ///
      color backgroundColor;
      void Init(EventInit* event)
      {
         backgroundColor = clrDimGray;
         Resize(40, 0, 40, 0);
         if(Visible(true))
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor))
               LogWriter("Failed change color of " + NameID(), MESSAGE_TYPE_ERROR);
         //HeadColumn* HeadMagic = new HeadColumn("HeadMagic", GetPointer(this));
         //childNodes.Add(HeadMagic);
         NodeContainer* nc = new NodeContainer("Container", GetPointer(this));
         childNodes.Add(nc);
         EventSend(event);
      }
};

class HeadColumn : public ProtoNode
{
   public:
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
               case EVENT_NODE_COMMAND:
                  RunCommand(newEvent);
               //������� ������� �� ����� ���������� ���������� ������ ����.
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      HeadColumn(string myName, ProtoNode* parNode):ProtoNode(OBJ_BUTTON, ELEMENT_TYPE_HEAD_COLUMN, myName, parNode)
      {
         ;
      }
   private:
      ///
      /// ��������� ��������.
      ///
      void RunCommand(EventNodeCommand* event)
      {
         /*if(!event.Visible())
         {
            Visible(false);
            return;
         }*/
         Move(event.XDist(), event.YDist());
         Resize(event.Width(), event.High());
         Visible(true);
         if(Visible())
         {
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, ShortName());
         }
      }
      ///
      /// ���������� ������� '������ ������������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void ResizeExtern(EventResize* event)
      {
         Move(5, 20);
         Resize(100, 20);
         //�� ����������� ���������� ������� �������.
         if(ParVisible())
            Visible(true);
         EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         EventSend(er);
         delete er;
      }
      
      void ChStatus(EventNodeStatus* event)
      {
         Move(5, 20);
         Resize(100, 20);
         //�� ����������� ���������� ������� �������.
         if(ParVisible())
            Visible(true);
         EventNodeStatus* cb = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(),
                                    XAbsDistance(), YAbsDistance(), Width(), High());
         EventSend(cb);
         delete cb;
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
         Move(5,5);
         Resize(100, 20);
         Visible(true);
         EventSend(event);
      }
};

///
/// �����-���������, ������������ ��������� ����� � ���� ��������.
///
class NodeContainer : public ProtoNode
{
   public:
      NodeContainer(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_CONTAINER, myName, parNode)
      {
         PosMagic = new HeadColumn("Magic", GetPointer(this));
         PosOrderId = new HeadColumn("Order ID", GetPointer(this));
         PosSymbol = new HeadColumn("Symbol", GetPointer(this));
         PosDir = new HeadColumn("Dir", GetPointer(this));
         PosEntryPrice = new HeadColumn("Entry Price", GetPointer(this));
         PosTakeProfit = new HeadColumn("Take Profit", GetPointer(this));
         PosStopLoss = new HeadColumn("Stop Loss", GetPointer(this));
         PosSwap = new HeadColumn("Swap", GetPointer(this));
         PosEntryTime = new HeadColumn("Entry Date", GetPointer(this));
         PosQuantity = new HeadColumn("Vol.", GetPointer(this));
         PosComment = new HeadColumn("Entry Comment", GetPointer(this));
         childNodes.Add(PosMagic);
         childNodes.Add(PosOrderId);
         childNodes.Add(PosSymbol);
         childNodes.Add(PosDir);
         childNodes.Add(PosEntryPrice);
         childNodes.Add(PosEntryTime);
         childNodes.Add(PosQuantity);
         childNodes.Add(PosComment);
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
               default:
                  EventSend(newEvent);
                  //delete newEvent;
            }
         }
      }
      ///
      /// ���������� ������� '������ ������������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void ChStatusExtern(EventNodeStatus* event)
      {
         Move(1, 1);
         Resize(event.Width()-2, 20);
         if(ParVisible())
         {
            Visible(true);
         }
         if(Visible())
         {
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BORDER_TYPE, BORDER_FLAT);
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_WIDTH, 1);
         }
         HeadColumn* currNode = PosMagic;
         EventNodeCommand* enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, 100, 20);
         currNode.Event(enc);
         delete enc;
         
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), currNode.XLocalDistance()+currNode.Width(), 0, 100, 20);
         currNode = PosOrderId;
         currNode.Event(enc);
         delete enc;
         
         //�������� �������� �������� ������ ��������-���������
         //������������ ��������� � ������ ������� PosMagic
         /*EventNodeCommand* enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, 100, 20);
         PosMagic.Event(enc);
         delete enc;
         
         //������������ ��������� � ������ ������� OrderID
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 100, 0, 100, 20);
         PosOrderId.Event(enc);
         delete enc;*/
         
         //������������ ��������� � ������ ������� Symbol
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 200, 0, 70, 20);
         PosSymbol.Event(enc);
         delete enc;
         
         //������������ ��������� ������� Direction
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 270, 0, 50, 20);
         PosDir.Event(enc);
         delete enc;
         
         //������������ ��������� ������� EntryPrice
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 320, 0, 70, 20);
         PosEntryPrice.Event(enc);
         delete enc;
         
         //������������ ��������� ������� EntryPrice
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 390, 0, 70, 20);
         PosTakeProfit.Event(enc);
         delete enc;
         
         //������������ ��������� ������� EntryPrice
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 460, 0, 70, 20);
         PosStopLoss.Event(enc);
         delete enc;
         
         //������������ ��������� ������� EntryPrice
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 530, 0, 70, 20);
         PosSwap.Event(enc);
         delete enc;
         
         //������������ ��������� ������� Date
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 600, 0, 150, 20);
         PosEntryTime.Event(enc);
         delete enc;
         
         //������������ ��������� ������� Comment
         enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 750, 0, 250, 20);
         PosComment.Event(enc);
         delete enc;
      }
   private:
      ///
      /// Magic ������.
      ///
      HeadColumn* PosMagic;
      ///
      /// ������������� ������
      ///
      HeadColumn* PosOrderId;
      ///
      /// ����������� �������.
      ///
      HeadColumn* PosDir;
      ///
      /// �������� �����������, �� �������� ������� �������.
      ///
      HeadColumn* PosSymbol;
      ///
      /// ����� �������.
      ///
      HeadColumn* PosQuantity;
      ///
      /// ����� �����.
      ///
      HeadColumn* PosEntryTime;
      ///
      /// ���� �����.
      ///
      HeadColumn* PosEntryPrice;
      ///
      /// ���� ������.
      ///
      HeadColumn* PosTakeProfit;
      ///
      /// ���� ����.
      ///
      HeadColumn* PosStopLoss;
      ///
      /// ����
      ///
      HeadColumn* PosSwap;
      ///
      /// ����������� � �������� �������.
      ///
      HeadColumn* PosComment;
};