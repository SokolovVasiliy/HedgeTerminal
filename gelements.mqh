
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
         //�������� ��������� �������.
         NodeContainer* nc = new NodeContainer("Container", GetPointer(this));
         childNodes.Add(nc);
         FieldsTables* ft = new FieldsTables("FieldTables", GetPointer(this));
         childNodes.Add(ft);
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
/// ������������ �������� ������� ���������� �������
///
enum ENUM_COLUMNS_OPEN_POS
{
   COLUMN_MAGIC,
   COLUMN_ORDER_ID,
   COLUMN_SYMBOL
};

///
/// �����-���������, ������������ ��������� ����� � ���� ��������.
///
class NodeContainer : public ProtoNode
{
   public:
      NodeContainer(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_CONTAINER, myName, parNode)
      {
         strMagic = "Magic";
         PosMagic = new HeadColumn(strMagic, GetPointer(this));
         
         strOrderId = "Order ID";
         PosOrderId = new HeadColumn(strOrderId, GetPointer(this));
         
         strSymbol = "Symbol";
         PosSymbol = new HeadColumn(strSymbol, GetPointer(this));
         
         strDir = "Dir";
         PosDir = new HeadColumn(strDir, GetPointer(this));
         
         strEntryPrice = "Entry Price";
         PosEntryPrice = new HeadColumn(strEntryPrice, GetPointer(this));
         
         strTakeProfit = "TakeProfit";
         PosTakeProfit = new HeadColumn(strTakeProfit, GetPointer(this));
         
         strStopLoss = "Stop Loss";
         PosStopLoss = new HeadColumn(strStopLoss, GetPointer(this));
         
         strSwap = "Swap";
         PosSwap = new HeadColumn(strSwap, GetPointer(this));
         
         strEntryTime = "Entry Date";
         PosEntryTime = new HeadColumn(strEntryTime, GetPointer(this));
         
         strQuant = "Vol.";
         PosQuantity = new HeadColumn(strQuant, GetPointer(this));
         
         strProfit = "Profit";
         PosProfit = new HeadColumn(strProfit, GetPointer(this));
         
         strComment = "Comment";
         PosComment = new HeadColumn(strComment, GetPointer(this));
         
         strCurrPrice = "Price";
         PosCurrPrice = new HeadColumn(strCurrPrice, GetPointer(this));
         
         childNodes.Add(PosMagic);
         childNodes.Add(PosSymbol);
         childNodes.Add(PosOrderId);
         childNodes.Add(PosEntryTime);
         childNodes.Add(PosDir);
         childNodes.Add(PosQuantity);
         childNodes.Add(PosEntryPrice);
         childNodes.Add(PosStopLoss);
         childNodes.Add(PosTakeProfit);
         childNodes.Add(PosSwap);
         childNodes.Add(PosCurrPrice);
         childNodes.Add(PosProfit);
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
               case EVENT_DEINIT:
                  Deinit(newEvent);
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
      virtual void ChStatusExtern(EventNodeStatus* event)
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
         SetNodePosition();
      }
      
   protected:
      void SetNodePosition()
      {
         long useWidth = 0;
         long kBase = 1250;
         //����������� ����������������.
         double kScale = (double)ParWidth()/(double)kBase;
         for(int i=0; i < childNodes.Total();i++)
         {
            HeadColumn* currColumn = childNodes.At(i);
            long cwidth = 20;
            //�� ����� �������� ���������� ��� ������
            string cname = currColumn.ShortName();
            if(cname == strMagic || cname == strOrderId)
               cwidth = 100;
            if(cname == strSymbol || cname == strEntryPrice ||
               cname == strTakeProfit || cname == strStopLoss ||
               cname == strSwap || cname == strProfit || cname == strCurrPrice)
               cwidth = 70;
            if(cname == strDir || cname == strQuant)
               cwidth = 50;
            if(cname == strSymbol)
               cwidth = 100;
            if(cname == strEntryTime)
               cwidth = 150;
            if(cname == strComment)
               cwidth = 150;
            
            cwidth = (long)MathRound(cwidth * kScale);
            useWidth += cwidth;
            //��������� ������� �������� ��� ���������� ��������� �����, �� ������� 20 ��������,
            //����������� �� ������.
            if(i == childNodes.Total()-1)
               cwidth += parentNode.Width()-useWidth - 20;
               
            //������, ����� ������ ������� ��������, ��������� ��� � ����
            EventNodeCommand* enc;
            if(i == 0)
               enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, cwidth, parentNode.High());
            else
            {
               HeadColumn* prevColumn = childNodes.At(i-1);
               enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), prevColumn.XLocalDistance() + prevColumn.Width(), 0, cwidth, parentNode.High());
            }
            currColumn.Event(enc);
            delete enc;
         }
      }
   private:
      /// Magic ������.
      HeadColumn* PosMagic;
      /// �������� ������� ����������� ������.
      string strMagic;
      
      /// ������������� ������
      HeadColumn* PosOrderId;
      ///
      string strOrderId;
      
      /// ����������� �������.
      HeadColumn* PosDir;
      ///
      string strDir;
      
      /// �������� �����������, �� �������� ������� �������.
      HeadColumn* PosSymbol;
      ///
      string strSymbol;
      
      /// ����� �������.
      HeadColumn* PosQuantity;
      ///
      string strQuant;
      
      /// ����� �����.
      HeadColumn* PosEntryTime;
      ///
      string strEntryTime;
      
      /// ���� �����.
      HeadColumn* PosEntryPrice;
      ///
      string strEntryPrice;
      
      ///
      /// ���� ������.
      ///
      HeadColumn* PosTakeProfit;
      ///
      string strTakeProfit;
      
      /// ������� ���� �������.
      HeadColumn* PosCurrPrice;
      ///
      string strCurrPrice;
      
      ///
      /// ���� ����.
      ///
      HeadColumn* PosStopLoss;
      ///
      string strStopLoss;
      
      ///
      /// ����
      ///
      HeadColumn* PosSwap;
      string strSwap;
      
      ///
      /// ������� ������/���� �������.
      ///
      HeadColumn* PosProfit;
      string strProfit;
      
      ///
      /// ����������� � �������� �������.
      ///
      HeadColumn* PosComment;
      string strComment;
};

class FieldsTables : public NodeContainer
{
   public:
      FieldsTables(string myName, ProtoNode* parNode):NodeContainer(myName, parNode){;}
      virtual void ChStatusExtern(EventNodeStatus* event)
      {
         Move(1, 21);
         Resize(event.Width()-2, (long)(ParHigh()-21)/2);
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
         //SetNodePosition();
      }
};
///
/// �����, ������������ ��������� ����������� ����� � �����.
///
class NodeLine: ProtoNode
{
   public:
      NodeLine(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_CONTAINER, myName, parNode)
      {
         strComment = "Comment";
         strCurrPrice = "Price";
         strMagic = "Magic";
         strOrderId = "Order ID";
         strDir = "Dir";
         strEntryPrice = "Entry Price";
         strEntryTime = "Entry Date";
         strProfit = "Profit";
         strSymbol = "Symbol";
         strQuant = "Vol.";
         strStopLoss = "StopLoss";
         strTakeProfit = "TakeProfit";
         strSwap = "Swap";
      }
   protected:
      ///
      /// ������������� �������������� �������� ��������� ������ �����
      ///
      void SetPosition(string nameNode)
      {
         long useWidth = 0;
         long kBase = 1250;
         //����������� ����������������.
         double kScale = (double)ParWidth()/(double)kBase;
         for(int i=0; i < childNodes.Total();i++)
         {
            HeadColumn* currColumn = childNodes.At(i);
            long cwidth = 20;
            //�� ����� �������� ���������� ��� ������
            string cname = currColumn.ShortName();
            if(cname == strMagic || cname == strOrderId)
               cwidth = 100;
            if(cname == strSymbol || cname == strEntryPrice ||
               cname == strTakeProfit || cname == strStopLoss ||
               cname == strSwap || cname == strProfit || cname == strCurrPrice)
               cwidth = 70;
            if(cname == strDir || cname == strQuant)
               cwidth = 50;
            if(cname == strSymbol)
               cwidth = 100;
            if(cname == strEntryTime)
               cwidth = 150;
            if(cname == strComment)
               cwidth = 150;
            
            cwidth = (long)MathRound(cwidth * kScale);
            useWidth += cwidth;
            //��������� ������� �������� ��� ���������� ��������� �����, �� ������� 20 ��������,
            //����������� �� ������.
            if(i == childNodes.Total()-1)
               cwidth += parentNode.Width()-useWidth;
               
            //������, ����� ������ ������� ��������, ��������� ��� � ����
            EventNodeCommand* enc;
            if(i == 0)
               enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, cwidth, parentNode.High());
            else
            {
               HeadColumn* prevColumn = childNodes.At(i-1);
               enc = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), prevColumn.XLocalDistance() + prevColumn.Width(), 0, cwidth, parentNode.High());
            }
            currColumn.Event(enc);
            delete enc;
         }
      }
      ///
      /// ��������� ���� � ���������.
      ///
      void AddNode(ProtoNode* node)
      {
         childNodes.Add(node);
      }
   private:
      /*
       * ����� ���� ��������� ��������� ���������� �������� ������� �������.
       * ������ ������� ����������� ���� ����������� ������, ������� �����
       * ���� ���������, ���� �� ��������.
      */
      ///
      /// Magic ������.
      ///
      string strMagic;
      
      ///
      /// ������������� ������.
      ///
      string strOrderId;
      
      ///
      /// ����������� �������.
      ///
      string strDir;
      
      ///
      /// �������� �����������, �� �������� ������� �������.
      ///
      string strSymbol;
      
      ///
      /// ����� �������.
      ///
      string strQuant;
      
      ///
      /// ����� �����.
      ///
      string strEntryTime;
      
      ///
      /// ���� �����.
      ///
      string strEntryPrice;
      
      ///
      /// ���� ������.
      ///
      string strTakeProfit;
      
      ///
      /// ������� ���� �������.
      ///
      string strCurrPrice;
      
      ///
      /// ���� ����.
      ///
      string strStopLoss;
      
      ///
      /// ����
      ///
      string strSwap;
      
      ///
      /// ������� ������/���� �������.
      ///
      string strProfit;
      
      ///
      /// ����������� � �������� �������.
      ///
      string strComment;
};


