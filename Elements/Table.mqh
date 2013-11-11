#include "..\API\Position.mqh"
#include "..\Events.mqh"
#include "Node.mqh"
#include "Button.mqh"
#include "TreeViewBox.mqh"
#include "Line.mqh"
#include "Label.mqh"
#include "Scroll.mqh"
#include "TableWork.mqh"
#include "TableAbstrPos.mqh"
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
      Table(string myName, ProtoNode* parNode, bool isTablePos=false):Label(ELEMENT_TYPE_TABLE, myName, parNode)
      {
         if(isTablePos)
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

///
/// ��� ������� �������.
///
enum ENUM_TABLE_POSTYPE
{
   ///
   /// ������� �������� �������.
   ///
   TABLE_POSOPEN,
   ///
   /// ������� ������������ �������.
   ///
   TABLE_POSHISTORY
};

///
/// ������� �������� �������.
///
class TablePositions : public Table
{
   public:
      TablePositions(ProtoNode* parNode, ENUM_TABLE_POSTYPE posType):Table("TableOfPosition.", parNode, true)
      {
         tableType = posType;
         if(tableType == TABLE_POSHISTORY)
            defTableType = THISTORY;
         else
            defTableType = TACTIVE;
         this.Init();
      }
      
      TablePositions(ProtoNode* parNode):Table("TableOfPosition.", parNode, true)
      {
         tableType = TABLE_POSOPEN;
         this.Init();
      }
      
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_CREATE_NEWPOS:
               AddPosition(event);
               break;
            case EVENT_REFRESH:
               RefreshPrices();
               break;
            case EVENT_CHECK_BOX_CHANGED:
               OnCheckBoxChanged(event);
               break;
            case EVENT_COLLAPSE_TREE:
               OnCollapse(event);
               break;
            case EVENT_NODE_CLICK:
               OnNodeClick(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
      
   private:
      ///
      /// ������������� �������
      ///
      void Init()
      {
         int type;
         if(tableType == TABLE_POSOPEN)
            type = TACTIVE;
         else
            type = THISTORY;
         nProfit = -1;
         nLastPrice = -1;
         ow_twb = 20;
         ow_magic = 100;
         ow_symbol = 70;
         ow_order_id = 80;
         ow_entry_date = 150;
         ow_type = 50;
         ow_vol = 50;
         ow_price = 70;
         ow_sl = 70;
         ow_tp = 70;
         ow_currprice = 70;
         //if(tableType == TABLE_POSHISTORY)
         //   ow_profit = 50;
         //else
            ow_profit = 70;
         if(tableType == TABLE_POSHISTORY)
            ow_comment = 150;
         else
            ow_comment = 350;
         
         name_collapse_pos = "CollapsePos.";
         name_magic = "Magic";
         name_symbol = "Symbol";
         name_entryOrderId = "Order ID";
         name_exitOrderId = "Exit Order ID";
         name_entry_date = "Entry Date";
         name_exit_date = "Exit Date";
         name_type = "Type";
         name_vol = "Vol.";
         name_entryPrice = "Price";
         name_exitPrice = "Exit Price";
         name_sl = "S/L";
         name_tp = "T/P";
         name_currprice = "Last Price";
         name_profit = "Profit";
         name_entryComment = "Comment";
         name_exitComment = "Exit Comment";
         
         //ListPos = new CArrayObj();
         int count = 0;
         
         // ������ ����� �������� ��������� ������� (��� ���� ������).
         //lineHeader = new Line("LineHeader", GetPointer(this));
         Button* hmagic;
         // ��������� �������
         AbstractPos* posLine = lineHeader;
         if(true)
         {
            Label* label = posLine.GetCollapseEl(defTableType | THEADER);
            //TreeViewBox* hCollapse = new TreeViewBox(name_collapse_pos, GetPointer(lineHeader), BOX_TREE_GENERAL);
            //hCollapse.Text("+");
            //hCollapse.OptimalWidth(ow_twb);
            //hCollapse.ConstWidth(true);
            //lineHeader.Add(label);
            count++;
         }
         // ���������� �����
         if(true)
         {
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
         // Entry Order ID
         if(true)
         {
            string n;
            if(tableType == TABLE_POSHISTORY)
               n = "Entry " + name_entryOrderId;
            else
               n = name_entryOrderId;
            Button* hOrderId = new Button(name_entryOrderId, GetPointer(lineHeader));
            hOrderId.Text(n);
            hOrderId.OptimalWidth(ow_order_id);
            lineHeader.Add(hOrderId);
            count++;
         }
         // Exit Order ID
         if(true && tableType == TABLE_POSHISTORY)
         {
            Button* hOrderId = new Button(name_exitOrderId, GetPointer(lineHeader));
            hOrderId.OptimalWidth(ow_order_id);
            lineHeader.Add(hOrderId);
            count++;
         }
         // ����� ����� � �������.
         if(true)
         {
            Button* hEntryDate = new Button(name_entry_date, GetPointer(lineHeader));
            hEntryDate.OptimalWidth(ow_entry_date);
            lineHeader.Add(hEntryDate);
            count++;
         }
         // ����� ������ �� �������.
         if(true && tableType == TABLE_POSHISTORY)
         {
            Button* hExitDate = new Button(name_exit_date, GetPointer(lineHeader));
            hExitDate.OptimalWidth(ow_entry_date);
            lineHeader.Add(hExitDate);
            count++;
         }
         // ����������� �������.
         if(true)
         {
            Button* hTypePos = new Button(name_type, GetPointer(lineHeader));
            hTypePos.OptimalWidth(ow_type);
            lineHeader.Add(hTypePos);
            count++;
         }
         // �����
         if(true)
         {
            Button* hVolume = new Button(name_vol, GetPointer(lineHeader));
            hVolume.OptimalWidth(ow_vol);
            lineHeader.Add(hVolume);
            count++;
         }
         // ���� �����.
         if(true)
         {
            string n;
            if(tableType == TABLE_POSHISTORY)
               n = "Entry " + name_entryPrice;
            else n = name_entryPrice;
            Button* hEntryPrice = new Button(name_entryPrice, GetPointer(lineHeader));
            hEntryPrice.Text(n);
            hEntryPrice.OptimalWidth(ow_price);
            lineHeader.Add(hEntryPrice);
            count++;
         }
         //���� ������.
         if(true && tableType == TABLE_POSHISTORY)
         {
            Button* hEntryPrice = new Button(name_exitPrice, GetPointer(lineHeader));
            hEntryPrice.OptimalWidth(ow_price);
            lineHeader.Add(hEntryPrice);
            count++;
         }
         // ����-����
         if(true)
         {
            Button* hStopLoss = new Button(name_sl, GetPointer(lineHeader));
            hStopLoss.OptimalWidth(ow_sl);
            lineHeader.Add(hStopLoss);
            count++;
         }
         // ����-������
         if(true)
         {
            Button* hTakeProfit = new Button(name_tp, GetPointer(lineHeader));
            hTakeProfit.OptimalWidth(ow_tp);
            lineHeader.Add(hTakeProfit);
            count++;
         }
         //���� ���������� ������
         if(true && tableType == TABLE_POSOPEN)
         {
            Button* hTralSL = new Button(name_tralSl, GetPointer(lineHeader));
            hTralSL.Font("Wingdings");
            //hTralSL.FontColor(clrRed);
            hTralSL.Text(CharToString(79));
            hTralSL.OptimalWidth(lineHeader.OptimalHigh());
            hTralSL.ConstWidth(true);
            lineHeader.Add(hTralSL);
            count++;
         }
         if(true && tableType == TABLE_POSOPEN)
         {
            // ������� ����
            Button* hCurrentPrice = new Button(name_currprice, GetPointer(lineHeader));
            hCurrentPrice.OptimalWidth(ow_currprice);
            lineHeader.Add(hCurrentPrice);
            nLastPrice = count;
            count++;
         }
         // ������
         if(true)
         {
            Button* hProfit = new Button(name_profit, GetPointer(lineHeader));
            hProfit.OptimalWidth(ow_profit);
            lineHeader.Add(hProfit);
            nProfit = count;
            count++;
         }
         // �����������
         if(true)
         {
            string n;
            if(tableType == TABLE_POSHISTORY)
               n = "Entry " + name_entryComment;
            else
               n = name_entryComment;
            Button* hComment = new Button(name_entryComment, GetPointer(lineHeader));
            hComment.Text(n);
            hComment.OptimalWidth(ow_comment);
            lineHeader.Add(hComment);
            count++;
         }
         // ����������� ��� ������.
         if(true && tableType == TABLE_POSHISTORY)
         {
            Button* hComment = new Button(name_exitComment, GetPointer(lineHeader));
            hComment.OptimalWidth(ow_comment);
            lineHeader.Add(hComment);
            count++;
         }
         //�������� ��� ����� ��� ������� �� ���������
         for(int i = 0; i < lineHeader.ChildsTotal();i++)
         {
            ProtoNode* node = lineHeader.ChildElementAt(i);
            node.BorderColor(clrBlack);
            node.BackgroundColor(clrWhiteSmoke);
         }
      }
      ///
      /// ���������� ������� "���� ��� ������� �������".
      ///
      void OnCheckBoxChanged(EventCheckBoxChanged* event)
      {
         ProtoNode* node = event.Node();
         if(node.TypeElement() != ELEMENT_TYPE_BOTTON)return;
         Button* btn = node;
         ENUM_BUTTON_STATE state = btn.State();
         ProtoNode* parNode = node.ParentNode();
         if(parNode == NULL || parNode.TypeElement() != ELEMENT_TYPE_POSITION)return;
         PosLine* pos = parNode;
         int total = workArea.ChildsTotal();
         for(int i = parNode.NLine()+1; i < total; i++)
         {
            ProtoNode* mnode = workArea.ChildElementAt(i);
            if(mnode.TypeElement() != ELEMENT_TYPE_DEAL)break;
            DealLine* deal = mnode;
            Label* tral = deal.CellTral();
            if(tral == NULL)return;
            if(tral.Font() != "Wingdings")
               tral.Font("Wingdings");
            if(event.Checked() == true)
               tral.Text(CharToString(254));
            else
               tral.Text(CharToString(168));
         }
      }
      ///
      /// ������������ ������� ������� ������ ����.
      ///
      void OnNodeClick(EventNodeClick* event)
      {
         ProtoNode* node = event.Node();
         ProtoNode* parNode = node.ParentNode();
         if(parNode == NULL || parNode != lineHeader)
            return;
         //������������ ��������� ����� ��� ���� �������.
         if(node.ShortName() == name_tralSl)
         {
            if(node.TypeElement() != ELEMENT_TYPE_BOTTON)return;
            Button* btn = node;
            //��������� ���� ��� ���� �������.
            ENUM_BUTTON_STATE state = btn.State();
            int total = workArea.ChildsTotal();
            for(int i = 0; i < total; i++)
            {
               ProtoNode* mnode = workArea.ChildElementAt(i);
               if(mnode.TypeElement() == ELEMENT_TYPE_POSITION)
               {
                  PosLine* pos = mnode;
                  CheckBox* checkBox = pos.CellTral();
                  if(checkBox.State() != state)
                     checkBox.State(state);
               }
            }
         }
         //������� ���������������� ������, �� ������� ���� ������������� �������
         //if(parentNode.TypeElement() == ELEMENT)
      }
      void OnCollapse(EventCollapseTree* event)
      {
         ProtoNode* node = event.Node();
         ENUM_ELEMENT_TYPE type = node.TypeElement();
         if(type == ELEMENT_TYPE_POSITION)
         {
            // �����������
            if(event.IsCollapse())
               DeleteDeals(event);
            // �������������
            else AddDeals(event);
         }
         //��������� ����������/�������� ��� �������?
         if(type == ELEMENT_TYPE_TABLE_HEADER_POS)
         {
            // ����������� ���� ������.
            if(event.IsCollapse())
               CollapseAll();
            // ������������� ���� ������.
            else RestoreAll();
            //AllocationShow();
         }
         //��������� ������� ������� ��� ���������������� ����������������
         //�����.
         AllocationWorkTable();
         
         //������ ��������� �� �������������� ������
         AllocationScroll();      
      }
      
      
      ///
      /// ������������� ���� ������ �������.
      ///
      void RestoreAll()
      {
         for(int i = 0; i < workArea.ChildsTotal(); i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            if(node.TypeElement() != ELEMENT_TYPE_POSITION)
               continue;
            PosLine* posLine = node;
            TreeViewBoxBorder* twb = posLine.CellCollapsePos();
            if(twb != NULL && twb.State() != BOX_TREE_COLLAPSE)continue;
            twb.OnPush();
         }
      }
      ///
      /// ����������� ���� ������ �������
      ///
      void CollapseAll()
      {
         for(int i = 0; i < workArea.ChildsTotal(); i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            if(node.TypeElement() != ELEMENT_TYPE_POSITION)continue;
            PosLine* posLine = node;
            TreeViewBoxBorder* twb = posLine.CellCollapsePos();
            if(twb != NULL && twb.State() != BOX_TREE_RESTORE)continue;
            twb.OnPush();
         }
      }
      ///
      /// ������ ������ �������������� ������� � ����������� ��
      /// flaga isCollapse
      ///
      void ChangeCollapse(PosLine* pos, bool isCollapse)
      {
         TreeViewBoxBorder* twb = pos.CellCollapsePos();
         if(isCollapse)
            twb.Text("-");
         else twb.Text("+");
      }
      ///
      /// ��������� ���� �������� �������.
      ///
      void RefreshPrices()
      {
         int total = workArea.ChildsTotal();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            ENUM_ELEMENT_TYPE el_type = node.TypeElement();
            if(node.TypeElement() != ELEMENT_TYPE_POSITION &&
               node.TypeElement() != ELEMENT_TYPE_DEAL)
               continue;
            //��������� ������� � ������ ��-�������.
            if(node.TypeElement() == ELEMENT_TYPE_POSITION)
            {
               //��������� ��������� ����
               PosLine* posLine = node;
               Position* pos = posLine.Position();
               Label* lastPrice = posLine.CellLastPrice();
               double price = pos.CurrentPrice();
               if(lastPrice != NULL)
               {
                  int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
                  lastPrice.Text(DoubleToString(price, digits));
               }
               //��������� ���������� � ������� �������
               Label* profit = posLine.CellProfit();
               if(profit != NULL)
                  profit.Text(pos.ProfitAsString());
            }
            else if(node.TypeElement() == ELEMENT_TYPE_DEAL)
            {
               DealLine* dealLine = node;
               Deal* deal = dealLine.EntryDeal();
               double price = deal.CurrentPrice();
               int digits = (int)SymbolInfoInteger(deal.Symbol(), SYMBOL_DIGITS);
               Label* lastPrice = dealLine.CellLastPrice();
               lastPrice.Text(DoubleToString(price, digits));
               //��������� ���������� � ������� ������.
               Label* profit = dealLine.CellProfit();
               if(profit != NULL)
                  profit.Text(deal.ProfitAsString());
            }
         }
      }

      ///
      /// ��������� ����� ��������� �������, ���� ���������� �������
      ///
      void AddPosition(EventCreatePos* event)
      {
         Position* pos = event.GetPosition();
         //��������� ������ �������� �������.
         //if(pos.Status == POSITION_STATUS_CLOSED)return;
         PosLine* nline = new PosLine(GetPointer(workArea),pos);
         
         int total = lineHeader.ChildsTotal();
         Label* cell = NULL;
         CArrayObj* deals = pos.EntryDeals();
         
         for(int i = 0; i < total; i++)
         {
            bool isReadOnly = true;
            ProtoNode* node = lineHeader.ChildElementAt(i);
            
            if(node.ShortName() == name_collapse_pos)
            {
               nline.GetCollapseEl(TPOSITION);
               //TreeViewBox* twb = new TreeViewBox(name_collapse_pos, GetPointer(nline), BOX_TREE_GENERAL);
               /*TreeViewBoxBorder* twb = new TreeViewBoxBorder(name_collapse_pos, GetPointer(nline), BOX_TREE_GENERAL);
               twb.OptimalWidth(20);
               twb.ConstWidth(true);
               twb.BackgroundColor(clrWhite);
               twb.BorderColor(clrWhiteSmoke);
               nline.Add(twb);
               nline.CellCollapsePos(twb);*/
               continue;
            }
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
            else if(node.ShortName() == name_entryOrderId)
            {
               cell = new Label(name_entryOrderId, GetPointer(nline));
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
               StringReplace(stype, "_", " ");
               int len = StringLen(stype);
               int optW = len*10;
               if(node.OptimalWidth() < optW)
                  node.OptimalWidth(optW);
               cell.Text(stype);
            }
            else if(node.ShortName() == name_vol)
            {
               cell = new Label(name_vol, GetPointer(nline));
               double step = SymbolInfoDouble(pos.Symbol(), SYMBOL_VOLUME_STEP);
               double mylog = MathLog10(step);
               string vol = mylog < 0 ? DoubleToString(pos.Volume(),(int)(mylog*(-1.0))) : DoubleToString(pos.Volume(), 0);
               cell.Text(vol);
               isReadOnly = false;
            }
            else if(node.ShortName() == name_entryPrice)
            {
               cell = new Label(name_entryPrice, GetPointer(nline));
               int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(pos.EntryPrice(), digits);
               cell.Text(price);
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
            else if(node.ShortName() == name_tralSl)
            {
               CheckBox* btnTralSL = new CheckBox(name_tralSl, GetPointer(nline));
               btnTralSL.BorderColor(clrWhite);
               btnTralSL.FontSize(14);
               //btnTralSL.Text(CharToString(168));
               btnTralSL.OptimalWidth(nline.OptimalHigh());
               btnTralSL.ConstWidth(true);
               nline.Add(btnTralSL);
               nline.CellTral(btnTralSL);
               continue;
            }
            else if(node.ShortName() == name_currprice)
            {
               cell = new Label(name_currprice, GetPointer(nline));
               nline.CellLastPrice(cell);
               int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(pos.CurrentPrice(), digits);
               cell.Text(price);
               nline.CellLastPrice(cell);
            }
            
            else if(node.ShortName() == name_profit)
            {
               Line* comby = new Line(name_profit, GetPointer(nline));
               comby.BindingWidth(node);
               comby.AlignType(LINE_ALIGN_CELLBUTTON);
               cell = new Label(name_profit, comby);
               //nline.CellProfit(cell);
               cell.Text(pos.ProfitAsString());
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.ReadOnly(true);
               nline.CellProfit(cell);
               ButtonClosePos* btnClose = new ButtonClosePos("btnClosePos.", comby);
               btnClose.Font("Wingdings");
               btnClose.FontSize(12);
               btnClose.Text(CharToString(251));
               btnClose.BorderColor(clrWhite);
               double profit = pos.Profit();
               if(profit > 0)
                  btnClose.BackgroundColor(clrMintCream);
               else
                  btnClose.BackgroundColor(clrLavenderBlush);
               comby.Add(cell);
               comby.Add(btnClose);
               nline.Add(comby);
               continue;
            }
            else if(node.ShortName() == name_entryComment)
            {
               cell = new Label(name_entryComment, GetPointer(nline));
               cell.Text((string)pos.EntryComment());
            }
            else
               cell = new Label("edit", GetPointer(nline));
            if(cell != NULL)
            {
               cell.BindingWidth(node);
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.ReadOnly(isReadOnly);
               nline.Add(cell);
               cell = NULL;
            }
         }
         
         workArea.Add(nline);
         //��� �� ����� ������� ��� �� ������������ � ������� �������� �������
         //���������� ������������ �������, ��� ���������� ������� refresh
         EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
         EventSend(er);
         delete er;
      }
      
      ///
      /// ��������� ������������ ������ ��� �������
      ///
      void AddDeals(EventCollapseTree* event)
      {
         ProtoNode* node = event.Node();
         //������� ����� ������������ ������ �������, � � ������� ���������� �������� �� �����.
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
         PosLine* posLine = node;
         //�������� ������������� ��� ����������� ������� �� ����.
         if(posLine.IsRestore())return;
         Position* pos = posLine.Position();
         ulong order_id = pos.EntryOrderID();
         //������� �������� ������, ������� ���������� ��������.
         CArrayObj* entryDeals = pos.EntryDeals();
         CArrayObj* exitDeals = pos.ExitDeals();
         // ���������� �������������� ����� ����� ����� ������������
         // ���������� ������ ����� �� ������
         int entryTotal = entryDeals != NULL ? entryDeals.Total() : 0;
         int exitTotal = exitDeals != NULL ? exitDeals.Total() : 0;
         int total;
         int fontSize = 8;
         if(entryTotal > 0 && entryTotal > exitTotal)
            total = entryTotal;
         else if(exitTotal > 0 && exitTotal > exitTotal)
            total = exitTotal;
         else return;
         color clrSlave = clrSlateGray;
         //���������� ������
         for(int i = 0; i < total; i++)
         {
            //������� ������
            Deal* entryDeal = NULL;
            if(entryDeals != NULL && i < entryDeals.Total())
               entryDeal = entryDeals.At(i);
            Deal* exitDeal = NULL;
            if(exitDeals != NULL && i < exitDeals.Total())
               exitDeal = exitDeals.At(i);
            DealLine* nline = new DealLine(GetPointer(workArea), entryDeal, exitDeal);
            nline.BorderType(BORDER_FLAT);
            nline.BorderColor(BackgroundColor());
            //���������� �������
            int tColumns = posLine.ChildsTotal();
            for(int c = 0; c < tColumns; c++)
            {
               ProtoNode* cell = posLine.ChildElementAt(c);
               string n_el = cell.ShortName();
               //����������� ������ �������.
               if(cell.ShortName() == name_collapse_pos)
               {
                  TreeViewBox* twb; 
                  //��������� ������� ����������� ������� ENDSLAVE
                  if(i == total -1)
                     twb = new TreeViewBox("TreeEndSlave", nline, BOX_TREE_ENDSLAVE);
                  else
                     twb = new TreeViewBox("TreeEndSlave", nline, BOX_TREE_SLAVE);
                  twb.BackgroundColor(cell.BackgroundColor());
                  twb.BackgroundColor(clrRed);
                  twb.BorderColor(cell.BorderColor());
                  twb.BindingWidth(cell);
                  nline.Add(twb);
                  continue;
               }
               //Magic ����� ������
               if(cell.ShortName() == name_magic)
               {
                  Label* magic = new Label("deal magic", nline);
                  magic.FontSize(fontSize);
                  Label* lcell = cell;
                  magic.ReadOnly(true);
                  magic.BindingWidth(cell);
                  //magic.Font("Wingdings");
                  //magic.Text(CharToString(225));
                  //magic.FontColor(clrSlave);
                  magic.Text(lcell.Text());
                  magic.BackgroundColor(cell.BackgroundColor());
                  magic.BorderColor(cell.BorderColor());
                  nline.Add(magic);
                  continue;
               }
               //����������, �� �������� ��������� ������.
               if(cell.ShortName() == name_symbol)
               {
                  Label* symbol = new Label("deal symbol", nline);
                  symbol.FontSize(fontSize);
                  Label* lcell = cell;
                  symbol.ReadOnly(true);
                  symbol.BindingWidth(cell);
                  //symbol.Font("Wingdings");
                  //symbol.Text(CharToString(225));
                  symbol.Text(lcell.Text());
                  //symbol.FontColor(clrSlave);
                  symbol.BackgroundColor(cell.BackgroundColor());
                  symbol.BorderColor(cell.BorderColor());
                  nline.Add(symbol);
                  continue;
               }
               //������������� ������.
               if(cell.ShortName() == name_entryOrderId)
               {
                  Label* entry_id = new Label("EntryDealsID", nline);
                  entry_id.FontSize(fontSize);
                  Label* lcell = cell;
                  entry_id.ReadOnly(true);
                  entry_id.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     entry_id.Text((string)entryDeal.Ticket());
                  }
                  else
                     entry_id.Text("");
                  entry_id.BackgroundColor(cell.BackgroundColor());
                  entry_id.BorderColor(cell.BorderColor());
                  nline.Add(entry_id);
                  continue;
               }
               //����� ����� � ������
               if(cell.ShortName() == name_entry_date)
               {
                  Label* entryDate = new Label("EntryDealsTime", nline);
                  entryDate.FontSize(fontSize);
                  entryDate.ReadOnly(true);
                  entryDate.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     CTime time = entryDeal.Date();
                     entryDate.Text(time.TimeToString(TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                  }
                  else
                     entryDate.Text("");
                  entryDate.BackgroundColor(cell.BackgroundColor());
                  entryDate.BorderColor(cell.BorderColor());
                  nline.Add(entryDate);
                  continue;
               }
               //��� ������
               if(cell.ShortName() == name_type)
               {
                  Label* entryType = new Label("EntryDealsType", nline);
                  entryType.FontSize(fontSize);
                  entryType.ReadOnly(true);
                  entryType.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     ENUM_DEAL_TYPE type = entryDeal.DealType();
                     string stype = EnumToString(type);
                     stype = StringSubstr(stype, 10);
                     StringReplace(stype, "_", " ");
                     entryType.Text(stype);
                  }
                  else
                     entryType.Text("");
                  entryType.BackgroundColor(cell.BackgroundColor());
                  entryType.BorderColor(cell.BorderColor());
                  nline.Add(entryType);
                  continue;
               }
               //�����
               if(cell.ShortName() == name_vol)
               {
                  Label* dealVol = new Label("EntryDealsVol", nline);
                  dealVol.FontSize(fontSize);
                  dealVol.ReadOnly(true);
                  dealVol.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     double step = SymbolInfoDouble(entryDeal.Symbol(), SYMBOL_VOLUME_STEP);
                     double mylog = MathLog10(step);
                     string vol = mylog < 0 ? DoubleToString(entryDeal.Volume(),(int)(mylog*(-1.0))) : DoubleToString(entryDeal.Volume(), 0);
                     dealVol.Text(vol);
                  }
                  else
                     dealVol.Text("");
                  dealVol.BackgroundColor(cell.BackgroundColor());
                  dealVol.BorderColor(cell.BorderColor());
                  nline.Add(dealVol);
                  continue;
               }
               //���� �� ������� ��������� ������
               if(cell.ShortName() == name_entryPrice)
               {
                  Label* entryPrice = new Label("DealEntryPrice", nline);
                  entryPrice.FontSize(fontSize);
                  entryPrice.ReadOnly(true);
                  entryPrice.BindingWidth(cell);
                  if(entryDeal != NULL)
                  {
                     entryPrice.Text((string)entryDeal.Price());
                  }
                  else
                     entryPrice.Text("");
                  entryPrice.BackgroundColor(cell.BackgroundColor());
                  entryPrice.BorderColor(cell.BorderColor());
                  nline.Add(entryPrice);
                  continue;
               }
               //����-����.
               if(cell.ShortName() == name_sl)
               {
                  Label* sl = new Label("DealStopLoss", nline);
                  sl.FontSize(fontSize);
                  Label* lcell = cell;
                  sl.ReadOnly(true);
                  sl.BindingWidth(cell);
                  //sl.FontColor(clrSlave);
                  //sl.Font("Wingdings");
                  //sl.Text(CharToString(225));
                  sl.Text(lcell.Text());
                  sl.BackgroundColor(cell.BackgroundColor());
                  sl.BorderColor(cell.BorderColor());
                  nline.Add(sl);
                  continue;
               }
               //����-������.
               if(cell.ShortName() == name_tp)
               {
                  Label* tp = new Label("DealTakeProfit", nline);
                  tp.FontSize(fontSize);
                  Label* lcell = cell;
                  tp.ReadOnly(true);
                  tp.BindingWidth(cell);
                  //tp.FontColor(clrSlave);
                  tp.Text(lcell.Text());
                  //tp.Font("Wingdings");
                  //tp.Text(CharToString(225));
                  tp.BackgroundColor(cell.BackgroundColor());
                  tp.BorderColor(cell.BorderColor());
                  nline.Add(tp);
                  continue;
               }
               //����
               if(cell.ShortName() == name_tralSl)
               {
                  
                  Label* tral = new Label("DealTralSL", nline);
                  tral.FontSize(fontSize);
                  tral.ReadOnly(true);
                  tral.BindingWidth(cell);
                  tral.Font("Wingdings");
                  CheckBox* checkTral = cell;
                  if(checkTral.Checked())
                     tral.Text(CharToString(254));
                  else
                     tral.Text(CharToString(168));
                  tral.FontSize(12);
                  tral.FontColor(clrSlave);
                  tral.Align(ALIGN_CENTER);
                  tral.BackgroundColor(cell.BackgroundColor());
                  tral.BorderColor(cell.BorderColor());
                  nline.Add(tral);
                  nline.CellTral(tral);
                  continue;
               }
               //��������� ����
               if((cell.ShortName() == name_currprice && tableType == TABLE_POSOPEN) ||
                  ((cell.ShortName() == name_exitPrice || cell.ShortName() == "edit") && tableType == TABLE_POSHISTORY))
               {
                  Label* cprice = new Label("DealLastPrice", nline);
                  cprice.FontSize(fontSize);
                  cprice.BindingWidth(cell);
                  Label* lprice = cell;
                  int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
                  string price = DoubleToString(pos.CurrentPrice(), digits);
                  cprice.Text(lprice.Text());
                  cprice.BackgroundColor(cell.BackgroundColor());
                  cprice.BorderColor(cell.BorderColor());
                  //cprice.FontColor(clrSlave);
                  nline.Add(cprice);
                  nline.CellLastPrice(cprice);
                  continue;
               }
               //������
               if(cell.ShortName() == name_profit)
               {
                  Label* profit = new Label("DealProfit", nline);
                  profit.FontSize(fontSize);
                  profit.BindingWidth(cell);
                  profit.ReadOnly(true);   
                  if(entryDeal != NULL)
                     profit.Text((string)entryDeal.ProfitAsString());
                  else
                     profit.Text("");
                  //������ ����� ���������������, � �������� ������ ��������,
                  //��� �������� �� � ����� ������������.
                  int ch_total = cell.ChildsTotal();
                  bool setManual = true;
                  for(int ch = 0; ch < ch_total; ch++)
                  {
                     ProtoNode* pnode = cell.ChildElementAt(ch);
                     ENUM_ELEMENT_TYPE type = pnode.TypeElement();
                     if(type == ELEMENT_TYPE_LABEL)
                     {
                        profit.BackgroundColor(node.BackgroundColor());
                        profit.BorderColor(node.BorderColor());
                        setManual = false;
                        break;
                     }   
                  }
                  if(setManual)
                  {
                     profit.BackgroundColor(clrWhite);
                     profit.BorderColor(clrWhite);
                  }
                  nline.Add(profit);
                  nline.CellProfit(profit);
                  continue;
               }
               //�����������
               if(cell.ShortName() == name_entryComment)
               {
                  Label* comment = new Label("DealComment", nline);
                  comment.FontSize(fontSize);
                  comment.BindingWidth(cell);
                  comment.ReadOnly(true);
                  comment.Text("");
                  comment.BackgroundColor(cell.BackgroundColor());
                  comment.BorderColor(cell.BorderColor());
                  nline.Add(comment);
                  continue;
               }
               else
               {
                  Label* entryPrice = new Label("DealEntryPrice", nline);
                  entryPrice.FontSize(fontSize);
                  entryPrice.ReadOnly(true);
                  entryPrice.BindingWidth(cell);
                  entryPrice.BackgroundColor(cell.BackgroundColor());
                  entryPrice.BorderColor(cell.BorderColor());
                  nline.Add(entryPrice);
                  continue;
               }
            }
            int m_total = nline.ChildsTotal();
            /*for(int el = 0; el < m_total; el++)
            {
               Label* label = nline.ChildElementAt(el);
               label.FontColor(clrDimGray);
            }*/
            int n = event.NLine();
            workArea.Add(nline, event.NLine()+1);
         }
         posLine.IsRestore(true);
      }
      ///
      /// ������� ������������ ������� �������
      ///
      void DeleteDeals(EventCollapseTree* event)
      {
         //����� ���� � ����������������� ��������?
         ProtoNode* node = event.Node();
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
         int sn_line = node.NLine();
         // ������������ ������� ���� ����� �� ����� ��������.
         int count = 0;
         for(int i = sn_line+1; i < workArea.ChildsTotal(); i++)
         {
            ProtoNode* cnode = workArea.ChildElementAt(i);
            if(cnode.TypeElement() != ELEMENT_TYPE_DEAL)break;
            count++;
         }
         workArea.DeleteRange(sn_line+1, count);
         PosLine* posLine = node;
         posLine.IsRestore(false);
      }
      /*virtual void OnVisible(EventVisible* event)
      {
         ProtoNode* node = event.Node();
         string el = "������� #" + node.NLine();
         string stype = "";
         if(event.Visible())
            stype = " �������� � ������.";
         else
            stype = " ������ �� ������.";
         el += stype;
         printf(el); 
         EventSend(event);
      }*/
      
      ///
      /// ��-���������, ���������� ������� ���������� ������� ���������/�������� ������ ��� ��������� �������.
      /// \param parTable - ������������ �������.
      /// \param isLastDeal - ������, ���� ������, ������� ��������� ���������� �������� ��������� ������ � ������������ ������.
      ///
      virtual Label* GetCollapseEl(int mode, bool isLastDeal = false)
      {
         Label* tbox = NULL;
         Settings* set = Settings::GetSettings();
         //��������� "��������/������ ��� ������". ������������ ������.
         if(mode & THEADER == THEADER)
         {
            TreeViewBox* hCollapse = new TreeViewBox(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_GENERAL);
            hCollapse.Text("+");
            hCollapse.OptimalWidth(20);
            hCollapse.ConstWidth(true);
            tbox = hCollapse;
         }
         else if(mode & TPOSITION == TPOSITION)
         {
            TreeViewBoxBorder* twb = new TreeViewBoxBorder(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_GENERAL);
            twb.OptimalWidth(20);
            twb.ConstWidth(true);
            twb.BackgroundColor(clrWhite);
            twb.BorderColor(clrWhiteSmoke);
            tbox = twb;
         }
         else if(mode & TDEAL == TDEAL)
         {
            TreeViewBox* twb; 
            //��������� ������� ����������� ������� ENDSLAVE
            if(isLastDeal)
               twb = new TreeViewBox(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_ENDSLAVE);
            else
               twb = new TreeViewBox(set.ColumnsName.Collapse(), GetPointer(this), BOX_TREE_SLAVE);
            tbox = twb;
         }
         return tbox;
      }
      
      //CArrayObj* ListPos;
      /*��������������� �������*/
      long ow_twb;
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
      string name_collapse_pos;
      string name_magic;
      string name_symbol;
      string name_entryOrderId;
      string name_exitOrderId;
      string name_entry_date;
      string name_exit_date;
      string name_type;
      string name_vol;
      string name_entryPrice;
      string name_exitPrice;
      string name_sl;
      string name_tp;
      string name_tralSl;
      string name_currprice;
      string name_profit;
      string name_entryComment;
      string name_exitComment;
      ///
      /// ����� ������ � �����, ������������ ������ �������.
      ///
      int nProfit;
      ///
      /// ����� ������ � �����, ������������ ��������� ���� �����������,
      /// �� �������� ������� �������.
      ///
      int nLastPrice;
      ///
      /// ���������� ����� � �������.
      ///
      int lines;
      ///
      /// ��� ������� �������.
      ///
      ENUM_TABLE_POSTYPE tableType;
      ///
      /// ��� ������� ������� ���������� � ������������� ���������. 
      ///
      int defTableType;
};

///
/// �������� ������ ������������ ���������� ��������.
///
class GenElements
{
   public:
      void AddPosition(EventCreatePos* event)
      {
         /*Position* pos = event.GetPosition();
         PosLine* nline = new PosLine(GetPointer(workArea),pos);
         
         int total = lineHeader.ChildsTotal();
         Label* cell = NULL;
         CArrayObj* deals = pos.EntryDeals();
         for(int i = 0; i < total; i++)
         {
            bool isReadOnly = true;
            ProtoNode* node = lineHeader.ChildElementAt(i);
            
            //if(node.ShortName() == name_collapse_pos)
         }*/
      }
      ///
      /// ���������� ������� ���������� ������� ���������/�������� ������.
      /// \param parNode - ������������ �������.
      /// \param state - ��� ������������� ������.
      ///
      /*TreeViewBoxBorder* GetCollapseEl(ProtoNode* parNode, ENUM_BOX_TREE_STATE state)
      {
         //TreeViewBox* twb = new TreeViewBox(name_collapse_pos, GetPointer(nline), BOX_TREE_GENERAL);
         TreeViewBoxBorder* twb = new TreeViewBoxBorder(name_collapse_pos, GetPointer(parNode), state);
         twb.OptimalWidth(20);
         twb.ConstWidth(true);
         twb.BackgroundColor(clrWhite);
         twb.BorderColor(clrWhiteSmoke);
         return twb;
      }*/
};

