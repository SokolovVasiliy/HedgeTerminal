
#include "gnode.mqh"


///
/// �������������� ������.
///
class Line : public ProtoNode
{
   public:
      Line(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_GCONTAINER, myName, parNode)
      {
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
   private:
      ///
      /// ��������� � ������ ���������� ����������.
      ///
      virtual void OnCommand(EventNodeCommand* newEvent)
      {
         if(!Visible() || newEvent.Direction() == EVENT_FROM_DOWN)return;
         switch(typeAlign)
         {
            case LINE_ALIGN_CELL:
            case LINE_ALIGN_CELLBUTTON:
               AlgoCellButton();
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
         for(int i = total; i <= 0; i--)
         {
            ProtoNode* node = childNodes.At(i);
            if(node.TypeElement() == ELEMENT_TYPE_BOTTON)
            {
               xdist -= chigh;
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist+2, 2, chigh-2, chigh-2);
               node.Event(command);
               delete command;
            }
            else
            {
               //������� ������ ��������
               long avrg = (long)MathRound((double)xdist/(double)(total+1));
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
};
///
/// ��������� �����
///
class Label : public ProtoNode
{
   public:
      Label(string myName, ProtoNode* node) : ProtoNode(OBJ_EDIT, ELEMENT_TYPE_LABEL, myName, node){;}
      void Edit(bool edit)
      {
         isEdit = edit;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_READONLY, isEdit);
      }
      ///
      /// ���������� ����� �������������� ��������� �����.
      ///
      bool Edit(){return isEdit;}
      ///
      /// ������������� �����, ������� ����� ������������ � ��������� �����.
      ///
      void Text(string myText)
      {
         text = myText;
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, text);
      }
      ///
      /// ���������� ����� �����.
      ///
      string Text(){return text;}
   private:
      virtual void OnVisible(EventVisible* event)
      {
         if(!event.Visible())return;
         BackgroundColor(BackgroundColor());
         BorderColor(BorderColor());
         Text(Text());
         Edit(Edit());
      }
      ///
      /// ������, ���� ��������� ����� ����� ��������������� �������������, ����, � ��������� ������.
      ///
      bool isEdit;
      ///
      /// ������� �����, ������� ������������ � ��������� �����.
      ///
      string text;
      
};


///
/// ������������� ����������� �� �������� ������������ ��������� � �������������� ��� ������������ ����������.
///
/*enum ENUM_LINE_ALIGN_TYPE
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
};*/

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
   protected:
      virtual void MyInit(){;}
      //���� �������� �������.
      color backgroundColor;
   private:
      virtual void OnVisible(EventVisible* event)
      {
         // ������������� �������������� ��������
         if(event.Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BGCOLOR, backgroundColor);
      }
      virtual void OnCommand(EventNodeCommand* event)
      {
         //������� ����� �� �����������.
         if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
         //������, � ����������� �� ��������, ���������� ��� ���������
         long ydist = 2;
         //ProtoNode* prevNode
         int total = childNodes.Total();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = childNodes.At(i);
            if(node.TypeElement() == ELEMENT_TYPE_GCONTAINER)
            {
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, ydist, Width()-20, 20);
               node.Event(command);
               delete command;
               ydist += node.High();
            }
            //
            if(node.TypeElement() == ELEMENT_TYPE_SCROLL)
            {
               bool v = Visible();
               //EventNodeStatus* ch = new EventNodeStatus(EVENT_FROM_UP, NameID(), Visible(), XAbsDistance(), YAbsDistance(), Width(), High());
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(),Width()-20,0,20, High());
               node.Event(command);
               delete command;
            }
         } 
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
         nProfit = -1;
         nLastPrice = -1;
         
         ow_magic = 100;
         ow_symbol = 70;
         ow_order_id = 130;
         ow_entry_date = 150;
         ow_type = 50;
         ow_vol = 50;
         ow_price = 70;
         ow_sl = 70;
         ow_tp = 70;
         ow_currprice = 70;
         ow_profit = 70;
         ow_comment = 150;
         
         name_magic = "Magic";
         name_symbol = "Symbol";
         name_order_id = "Order ID";
         name_entry_date = "EntryDate";
         name_type = "Type";
         name_vol = "Vol.";
         name_price = "Price";
         name_sl = "S/L";
         name_tp = "T/P";
         name_currprice = "Last Price";
         name_profit = "Profit";
         name_comment = "Comment";
         
         ListPos = new CArrayObj();
         int count = 0;
         
         // ������ ����� �������� ��������� ������� (��� ���� ������).
         lineHeader = new Line("LineHeader", GetPointer(this));
         Button* hmagic;
         if(true)
         {
            // ���������� �����
            hmagic = new Button(name_magic, GetPointer(lineHeader));
            hmagic.OptimalWidth(ow_magic);
            lineHeader.Add(hmagic);
            count++;
         }
         if(true)
         {
            // ������
            Button* hSymbol = new Button(name_symbol, GetPointer(lineHeader));
            hmagic.OptimalWidth(ow_symbol);
            lineHeader.Add(hSymbol);
            count++;
         }
         if(true)
         {
            // Order ID
            Button* hOrderId = new Button(name_order_id, GetPointer(lineHeader));
            hOrderId.OptimalWidth(ow_order_id);
            lineHeader.Add(hOrderId);
            count++;
         }
         
         if(true)
         {
            // ����� ����� � �������.
            Button* hEntryDate = new Button(name_entry_date, GetPointer(lineHeader));
            hEntryDate.OptimalWidth(ow_entry_date);
            lineHeader.Add(hEntryDate);
            count++;
         }
         
         if(true)
         {
            // ����������� �������.
            Button* hTypePos = new Button(name_type, GetPointer(lineHeader));
            hTypePos.OptimalWidth(ow_type);
            lineHeader.Add(hTypePos);
            count++;
         }
         
         if(true)
         {
            // �����
            Button* hVolume = new Button(name_vol, GetPointer(lineHeader));
            hVolume.OptimalWidth(ow_vol);
            lineHeader.Add(hVolume);
            count++;
         }
         
         if(true)
         {
            // ���� �����.
            Button* hEntryPrice = new Button(name_price, GetPointer(lineHeader));
            hEntryPrice.OptimalWidth(ow_price);
            lineHeader.Add(hEntryPrice);
            count++;
         }
         
         if(true)
         {
            // ����-����
            Button* hStopLoss = new Button(name_sl, GetPointer(lineHeader));
            hStopLoss.OptimalWidth(ow_sl);
            lineHeader.Add(hStopLoss);
            count++;
         }
         
         if(true)
         {
            // ����-������
            Button* hTakeProfit = new Button(name_tp, GetPointer(lineHeader));
            hTakeProfit.OptimalWidth(ow_tp);
            lineHeader.Add(hTakeProfit);
            count++;
         }
         
         if(true)
         {
            // ������� ����
            Button* hCurrentPrice = new Button(name_currprice, GetPointer(lineHeader));
            hCurrentPrice.OptimalWidth(ow_currprice);
            lineHeader.Add(hCurrentPrice);
            nLastPrice = count;
            count++;
         }
         
         if(true)
         {
            // ������
            Button* hProfit = new Button(name_profit, GetPointer(lineHeader));
            hProfit.OptimalWidth(ow_profit);
            lineHeader.Add(hProfit);
            nProfit = count;
            count++;
         }
         if(true)
         {
            // �����������
            Button* hComment = new Button(name_comment, GetPointer(lineHeader));
            hComment.OptimalWidth(ow_comment);
            lineHeader.Add(hComment);
            count++;
         }
         //�����
         Scroll* myscroll = new Scroll("Scroll", GetPointer(this));
         Add(myscroll);
         
         Add(lineHeader);
      }
      
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_CREATE_NEWPOS:
               AddPosition(event);
               break;
            case EVENT_REFRESH:
               RefreshPos();
               break;
         }
      }
   private:
      ///
      /// ��������� ��������� �������
      ///
      void RefreshPos()
      {
         int total = ListPos.Total();
         for(int i = 0; i < total; i++)
         {
            GPosition* gposition = ListPos.At(i);
            //��������� ������ �������.
            if(nProfit != -1)
            {
               Label* profit = gposition.gpos.ChildElementAt(nProfit);
               profit.Text((string)gposition.pos.Profit());
            }
            //��������� ��������� ���� �������
            if(nLastPrice)
            {
               Label* lastprice = gposition.gpos.ChildElementAt(nLastPrice);
               lastprice.Text((string)gposition.pos.CurrentPrice());
            }
         }
      }
      
      
      ///
      /// ��������� ����� ��������� �������.
      ///
      void AddPosition(EventCreatePos* event)
      {
         Position* pos = event.GetPosition();
         //��������� ������ �������� �������.
         //if(pos.Status == POSITION_STATUS_CLOSED)return;
         Line* nline = new Line("pos.", GetPointer(this));
         int total = lineHeader.ChildsTotal();
         Label* cell;
         for(int i = 0; i < total; i++)
         {
            bool isReadOnly = true;
            ProtoNode* node = lineHeader.ChildElementAt(i);
            if(node.ShortName() == name_magic)
            {
               cell = new Label(name_magic, GetPointer(nline));
               cell.Text((string)pos.Magic());
            }
            else if(node.ShortName() == name_symbol)
            {
               cell = new Label(name_symbol, GetPointer(nline));
               cell.Text((string)pos.Symbol());
            }
            else if(node.ShortName() == name_order_id)
            {
               cell = new Label(name_order_id, GetPointer(nline));
               cell.Text((string)pos.EntryOrderID());
            }
            else if(node.ShortName() == name_entry_date)
            {
               cell = new Label(name_entry_date, GetPointer(nline));
               CTime* date = pos.EntryDate();
               string sdate = date.TimeToString(TIME_DATE | TIME_MINUTES | TIME_SECONDS);
               cell.Text(sdate);
            }
            else if(node.ShortName() == name_type)
            {
               cell = new Label(name_type, GetPointer(nline));
               string stype = EnumToString(pos.PositionType());
               stype = StringSubstr(stype, 11);
               cell.Text(stype);
            }
            else if(node.ShortName() == name_vol)
            {
               cell = new Label(name_vol, GetPointer(nline));
               cell.Text((string)pos.Volume());
               isReadOnly = false;
            }
            else if(node.ShortName() == name_price)
            {
               cell = new Label(name_price, GetPointer(nline));
               cell.Text((string)pos.EntryPrice());
            }
            else if(node.ShortName() == name_sl)
            {
               cell = new Label(name_sl, GetPointer(nline));
               cell.Text((string)pos.StopLoss());
               isReadOnly = false;
            }
            else if(node.ShortName() == name_tp)
            {
               cell = new Label(name_tp, GetPointer(nline));
               cell.Text((string)pos.TakeProfit());
               isReadOnly = false; 
            }
            else if(node.ShortName() == name_currprice)
            {
               cell = new Label(name_currprice, GetPointer(nline));
               cell.Text((string)pos.CurrentPrice());
            }
            
            else if(node.ShortName() == name_profit)
            {
               cell = new Label(name_profit, GetPointer(nline));
               cell.Text((string)pos.Profit());
            }
            else if(node.ShortName() == name_comment)
            {
               cell = new Label(name_comment, GetPointer(nline));
               cell.Text((string)pos.EntryComment());
            }
            else
               cell = new Label("edit", GetPointer(nline));
            cell.OptimalWidth(node.OptimalWidth());
            cell.BackgroundColor(clrWhite);
            cell.BorderColor(clrWhiteSmoke);
            cell.Edit(isReadOnly);
            nline.Add(cell);
         }
         Add(nline);

         GPosition* gposition = new GPosition();
         gposition.pos = pos;
         gposition.gpos = nline;
         ListPos.Add(gposition);
         //��� �� ����� ������� ��� �� ������������ � ������� �������� �������
         //���������� ������������ �������, ��� ���������� ������� refresh
         EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
         EventSend(er);
         delete er;
      }
      ///
      /// ����������� ������������� �������.
      ///
      class GPosition : CObject
      {
         public:
            ///
            /// ����������� ������������� �������.
            ///
            Line* gpos;
            ///
            /// ��������� �� ������� �������.
            ///
            Position* pos;
      };
      CArrayObj* ListPos;
      Line* lineHeader;
      /*��������������� �������*/
      long ow_magic;
      long ow_symbol;
      long ow_order_id;
      long ow_entry_date;
      long ow_type;
      long ow_vol;
      long ow_price;
      long ow_sl;
      long ow_tp;
      long ow_currprice;
      long ow_profit;
      long ow_comment;
      /*�������� �������*/
      string name_magic;
      string name_symbol;
      string name_order_id;
      string name_entry_date;
      string name_type;
      string name_vol;
      string name_price;
      string name_sl;
      string name_tp;
      string name_currprice;
      string name_profit;
      string name_comment;
      ///
      /// ����� ������ � �����, ������������ ������ �������.
      ///
      int nProfit;
      ///
      /// ����� ������ � �����, ������������ ��������� ���� �����������,
      /// �� �������� ������� �������.
      ///
      int nLastPrice;
};
///
/// �������� ����� ������.
///
class MainForm : public ProtoNode
{
   public:
      MainForm():ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_FORM, "HedgePanel", NULL)
      {
         openPos = new TableOpenPos(GetPointer(this));
         childNodes.Add(openPos);
      }
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN)return;
         //������������� �������������� �������
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 20, 40, Width()-25, High()-50);
         openPos.Event(command);
         delete command;
      }
      
      virtual void OnEvent(Event* event)
      {
         //��������� ������� ����� �� ���������� ���������
         if(event.Direction() == EVENT_FROM_DOWN)
         {
            if(event.EventId() == EVENT_REFRESH)
            {
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 20, 40, Width()-25, High()-50);
               openPos.Event(command);
               delete command;
               return;
            }
         }
         EventSend(event);
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
      /// ������� �������� �������.
      ///
      TableOpenPos* openPos;
};
///
/// ����� "������".
///
class Button : public ProtoNode
{
   public:
      
      Button(string myName, ProtoNode* parNode):ProtoNode(OBJ_BUTTON, ELEMENT_TYPE_HEAD_COLUMN, myName, parNode)
      {
         borderColor = clrBlack;
         label = myName;
         font = "Arial";
         fontsize = 10;
      }
      void BorderColor(color clr)
      {
         borderColor = clr;
      }
      color BorderColor()
      {
         return borderColor;
      }
      ///
      /// ���������� ������� ������.
      ///
      string Label(){return label;}
      ///
      /// ������������� ������� ������.
      ///
      void Label(string text){label = text;}
      ///
      /// ���������� ��� ������������� ������.
      ///
      string Font(){return font;}
      ///
      /// ������������� ��� ������������� ������.
      ///
      void Font(string myFont){font = myFont;}
      ///
      /// ���������� ������ ������������� ������.
      ///
      int FontSize(){return fontsize;}
      ///
      /// ������������� ������ ������������� ������.
      ///
      void FontSize(int size){fontsize = size;}
   private:
      virtual void OnVisible(EventVisible* event)
      {
         if(!Visible())return;
         ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, label);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BORDER_COLOR, clrNONE);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_BORDER_COLOR, borderColor);
         ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_FONT, font);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_FONTSIZE, fontsize);
      }
      
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         Visible(vis);
         EventVisible* ev = new EventVisible(EVENT_FROM_UP, NameID(), Visible());
         EventSend(ev);
         delete ev;
      }
      ///
      /// ���� ����� ������
      ///
      color borderColor;
      ///
      ///  ������� ������.
      ///
      string label;
      ///
      /// ��� ������.
      ///
      string font;
      ///
      /// ������ ������.
      ///
      int fontsize;
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
         up.BorderColor(clrNONE);
         up.Font("Wingdings");
         up.Label(CharToString(241));
         childNodes.Add(up);
         
         dn = new Button("DnClick", GetPointer(this));
         dn.BorderColor(clrNONE);
         dn.Font("Wingdings");
         dn.Label(CharToString(242));
         childNodes.Add(dn);
         
         toddler = new Button("Todler", GetPointer(this));
         childNodes.Add(toddler);  
      }
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
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

