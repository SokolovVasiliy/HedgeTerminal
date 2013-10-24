#include "..\API\Position.mqh"
#include "..\Events.mqh"
#include "Node.mqh"
#include "Button.mqh"
#include "TreeViewBox.mqh"
#include "Line.mqh"
#include "Label.mqh"
#include "Scroll.mqh"
///
/// ����� "�������" ������������ �� ���� ������������� ���������, ��������� �� ���� ���������:
/// 1. ��������� �������;
/// 2. ������������ ��������� �����;
/// 3. ������ ��������� ������������� ���������� �����.
/// ������ �� ���� ��������� ����� ���� ������������ ���������.
///
class Table : public ProtoNode
{
   public:
      Table(string myName, ProtoNode* parNode):ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_TABLE, myName, parNode)
      {
         
         highLine = 20;
         lineHeader = new Line("Header", GetPointer(this));
         workArea = new CWorkArea(GetPointer(this));
         workArea.Edit(true);
         workArea.Text("");
         workArea.BorderColor(BackgroundColor());
         
         scroll = new Scroll("Scroll", GetPointer(this));
         scroll.BorderType(BORDER_FLAT);
         scroll.BorderColor(clrBlack);
         
         childNodes.Add(lineHeader);
         childNodes.Add(workArea);
         childNodes.Add(scroll);
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
   protected:
      class CWorkArea : public Label
      {
         public:
            CWorkArea(ProtoNode* parNode) : Label(ELEMENT_TYPE_WORK_AREA, "WorkArea", parNode)
            {
               highLine = 20;
               Text("");
               Edit(true);
               BorderColor(parNode.BackgroundColor());
               //visibleCount = -1;
            }
            ///
            /// ��������� ����� ������ � ����� ������� � ������������� ���������� �� ������ � ���������
            ///
            void Add(ProtoNode* lineNode)
            {
               Add(lineNode, ChildsTotal());
            }
            ///
            /// ��������� ����� ������ ������� �� ������� pos
            ///
            void Add(ProtoNode* lineNode, int pos)
            {
               childNodes.Insert(lineNode, pos);
               lineNode.NLine(pos);
               //����� ������� ��������, ��� ����������� �������� �������� ���� ����������.
               OnCommand();
               /*int total = ChildsTotal();
               for(int i = pos; i < total; i++)
                  RefreshLine(i);*/
            }
            ///
            /// ������� ������ �� ������� index �� ������� �����.
            ///
            void Delete(int index)
            {
               ProtoNode* line = ChildElementAt(index);
               EventVisible* vis = new EventVisible(EVENT_FROM_UP, GetPointer(this), false);
               line.Event(vis);
               delete vis;
               childNodes.Delete(index);
               //��� ����������� �������� �������� ���� ���������
               for(int i = index; i < ChildsTotal(); i++)
                  RefreshLine(i);
            }
            ///
            /// ������� �������� ����� �� ������� �����.
            /// \param index - ������ ������ ��������� ������.
            /// \param count - ���������� �����, ������� ���� �������.
            ///
            void DeleteRange(int index, int count)
            {
               int total = index + count > ChildsTotal() ? ChildsTotal() : index + count;
               for(int i = index; i < total; i++)
               {
                  ProtoNode* line = ChildElementAt(index);
                  EventVisible* vis = new EventVisible(EVENT_FROM_UP, GetPointer(this), false);
                  line.Event(vis);
                  delete vis;
                  childNodes.Delete(index);
               }
               //��� ����������� �������� �������� ���� ���������
               for(int i = index; i < ChildsTotal(); i++)
                  RefreshLine(i);
            }
            ///
            /// ��������� ���������� � ������ ����� �� ������� index
            ///
            void RefreshLine(int index)
            {
               //����� ������� ���������.
               int total = ChildsTotal();
               if(index < 0 || index >= total)return;
               //�������� ����� ��� ������� index.
               ProtoNode* node = ChildElementAt(index);
               int nline = node.NLine();
               node.NLine(index);
               //���������� ��������� ��������
               bool vis = node.Visible();
               if(index == visibleFirst || index == 0)
               {
                  EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, Width(), highLine);
                  node.Event(command);
                  delete command;
               }
               else
               {
                  ProtoNode* prevNode = ChildElementAt(index-1);
                  long y_dist = prevNode.YLocalDistance() + prevNode.High();
                  EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, y_dist, Width(), highLine);
                  node.Event(command);
                  delete command;
               }
               InterlacingColor(node);
            }
            ///
            /// ���������� ����� ������ ���� ����� � �������.
            ///
            long LinesHighTotal()
            {
               return childNodes.Total()*20;
            }
            ///
            /// ���������� ����� ������ ���� ������� ����� � �������.
            ///
            long LinesHighVisible()
            {
               return LinesVisible()*20;
            }
            ///
            /// ���������� ������ ������ ������� ������.
            ///
            int LineVisibleFirst(){return visibleFirst;}
            ///
            /// ���������� ���������� ������� ����� � �������.
            ///
            int LinesVisible(){return visibleCount;}
            
            ///
            /// ������������� ������ �����, ������� ��������� ����������.
            ///
            void LineVisibleFirst(int index)
            {
               //�������� �������� ��� ��������, �� ������� ���������
               //������ ������
               //DEBUG TEMP
               /*ProtoNode* ref = NULL;
               if(index == 1)
               {
                  ProtoNode* node = ChildElementAt(1);
                  if(node.TypeElement() == ELEMENT_TYPE_POSITION){
                     PosLine* pline = node;
                     Position* pos = pline.Position();
                     long id = pos.EntryOrderID();
                     long tid = 1005439241;
                     //if(id != tid){
                     TreeViewBoxBorder* twb = node.ChildElementAt(0);
                     ref = twb.ParentNode();
                     int n = ref.NLine();
                     printf("Pos#" + tid + " ref on " + ref.NameID() + " n:" + ref.NLine());
                  }
               }*/
               
               if(index < visibleFirst)
                  MoveUp(index);
               if(index > visibleFirst)
                  MoveDown(index);
               
               //DEBUG TEMP
               /*if(index == 1)
               {
                  ProtoNode* node = ChildElementAt(1);
                  if(node.TypeElement() == ELEMENT_TYPE_POSITION){
                     PosLine* pline = node;
                     Position* pos = pline.Position();
                     long id = pos.EntryOrderID();
                     long tid = 1005439241;
                     //if(id != tid){
                     TreeViewBoxBorder* twb = node.ChildElementAt(0);
                     ref = twb.ParentNode();
                     int n = ref.NLine();
                     printf("Pos#" + tid + " ref on " + ref.NameID() + " n:" + ref.NLine());
                  }
               }*/
            }
         private:
            ///
            /// �������� ������� ������ � ���������� ������.
            ///
            void MoveDown(int index)
            {
               if(index < 0 || LineVisibleFirst() == index ||
                  index <= visibleFirst) return;
               //�������� ��������� ���� - �������� ������� ������.
               int total = childNodes.Total();
               //int i = 0;
               int i = visibleFirst;
               for(; i < index; i++)
               {
                  ProtoNode* node = childNodes.At(i);
                  EventVisible* vis = new EventVisible(EVENT_FROM_UP, GetPointer(this), false);
                  node.Event(vis);
                  delete vis;
               }
               //����������� ������.
               visibleFirst = index;
               for(; i < total; i++)
                  RefreshLine(i);
            }
            ///
            /// �������� ������ ������ � ���������� �������.
            ///
            void MoveUp(int index)
            {
               //������ ������������ ����� �� ����� �������� �� ������� �������.
               if(index < 0 || index >= childNodes.Total()||
                  index >= visibleFirst)return;
               visibleFirst = index;
               for(int i = visibleFirst; i < ChildsTotal(); i++)
                  RefreshLine(i);
            }
            virtual void OnEvent(Event* event)
            {
               //��������� ����� �� ����� ������� ����������?
               if(event.Direction() == EVENT_FROM_DOWN && event.EventId() == EVENT_NODE_VISIBLE)
               {
                  EventVisible* vis = event;
                  ProtoNode* node = vis.Node();
                  if(vis.Visible())
                  {
                     ++visibleCount;
                     highTotal += node.High();
                     //printf("�������� ������: " + string(node.NLine()+1) + " �� " + visibleCount + " ����� ������: " + highTotal);
                     
                  }
                  else
                  {
                     //���� ��������� ������ ������� �������, ��� ����� �������� ��������
                     /*if(node.NLine() == visibleFirst)
                     {
                        visibleFirst = -1;
                        for(int i = node.NLine(); i < ChildsTotal(); i++)
                        {
                           ProtoNode* mnode = ChildElementAt(i);
                           if(mnode.Visible())
                           {
                              visibleFirst = mnode.NLine();
                              break;
                           }
                        }
                     }*/
                     highTotal -= node.High();
                     --visibleCount;
                     //printf("������ ������: " + string(node.NLine()+1) + " �� " + visibleCount + " ����� ������: " + highTotal);
                     
                  }
                  //printf("FL: " + visibleFirst + " Count: " + visibleCount);
                  //printf("VisibleCount: " + visibleCount);
                  //firstVisible = node
               }
               else
                  EventSend(event);
            }
            
            virtual void OnCommand(EventNodeCommand* event)
            {
               //������� ����� �� �����������.
               if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
               OnCommand();
               return;
               int total = ChildsTotal();
               //������ ������������� ���������� �����, ������� ����� ������������
               //��� ������� ������� �������.
               int highTable = High();
               //1000
               double lines = MathFloor(High()/20.0);
               //��������� ����������� ���������� �������������� �����?
               //if(lines > visibleCount && total >= lines)
               //{
                  //���� ������ ��� ����� ��������� � ������� - 
                  //���������� �� ���.
                  if(total <= lines)
                  {
                     visibleFirst = 0;
                     for(int i = visibleFirst; i < total; i++)
                        RefreshLine(i);
                     return;
                  }
                  //�����, ������� �����, ��� ������� �� �������� �����
                  int dn_line = total - (visibleFirst + visibleCount);
                  //����� ����� ���������� ����� ������ �����
                  if(visibleCount + dn_line < lines)
                  {
                     int n = lines - (dn_line + visibleCount);
                     visibleFirst -= n;
                  }
                  //else visibleFirst = total - lines;
                  for(int i = visibleFirst; i < total; i++)
                     RefreshLine(i);
               //}
               //��������� ������ �� �����, ��� ����� ������.
               /*else
               {
                  int limit = visibleFirst + visibleCount
                  for(int i = visibleFirst; i < limit; i++)
                     RefreshLine(i);
               }*/
            }
            ///
            /// ��������� ����� �������� ��������� �������.
            ///
            void OnCommand()
            {
               int total = ChildsTotal();
               //�������� �������� ��� ��������, �� ������� ���������
               //������ ������
               /*for(int i = 0; i < total; i++)
               {
                  ProtoNode* node = ChildElementAt(i);
                  if(node.TypeElement() != ELEMENT_TYPE_POSITION)continue;
                  PosLine* pline = node;
                  Position* pos = pline.Position();
                  long id = pos.EntryOrderID();
                  long tid = 1005439241;
                  if(id != tid)continue;
                  TreeViewBoxBorder* twb = node.ChildElementAt(0);
                  ProtoNode* ref = twb.ParentNode();
                  int n = ref.NLine();
                  printf("Pos#" + tid + " ref on " + ref.NameID() + " n:" + ref.NLine());
               }*/
               double lines = MathFloor(High()/20.0);
               if(total <= lines)
               {
                  visibleFirst = 0;
                  for(int i = visibleFirst; i < total; i++)
                     RefreshLine(i);
                  return;
               }
               //�����, ������� �����, ��� ������� �� �������� �����
               int dn_line = total - (visibleFirst + visibleCount);
               //����� ����� ���������� ����� ������ �����
               if(visibleCount + dn_line < lines)
               {
                  int n = lines - (dn_line + visibleCount);
                  visibleFirst -= n;
               }
               for(int i = visibleFirst; i < total; i++)
                  RefreshLine(i);
            }
            ///
            /// �������� ������ �������������� � ����� ������ �������.
            ///
            void InterlacingColor(ProtoNode* nline)
            {
               color clrBack;
               if((nline.NLine()+1) % 2 == 0)
                  clrBack = clrWhiteSmoke;
               else clrBack = clrWhite;
               for(int i = 0; i < nline.ChildsTotal(); i++)
               {
                  ProtoNode* node = nline.ChildElementAt(i);
                  //��������� �������� ������������ ����������
                  if(node.TypeElement() == ELEMENT_TYPE_GCONTAINER)
                  {
                     Line* line = node;
                     for(int k = 0; k < line.ChildsTotal(); k++)
                     {
                        ProtoNode* rnode = line.ChildElementAt(k);
                        //if(rnode.TypeElement() != ELEMENT_TYPE_BOTTON)
                           rnode.BackgroundColor(clrBack);
                        rnode.BorderColor(clrBack);
                     }
                  }
                  else
                  {
                     node.BackgroundColor(clrBack);
                     node.BorderColor(clrBack);
                  }
               }
            }
            int highLine;
            ///
            /// ���������� ������� �����, ������� � ������ ������ ������������
            /// � �������.
            ///
            int visibleCount;
            ///
            /// ������ ������� �������� ��������.
            ///
            int visibleFirst;
            ///
            /// ����� ������ ���� ������� ���������.
            ///
            long highTotal;
      };
      ///
      /// ��������� �������.
      ///
      Line* lineHeader;
      ///
      /// ������� ������� �������
      ///
      CWorkArea* workArea;
      ///
      /// ������.
      ///
      Scroll* scroll;
   private:
      
      virtual void OnCommand(EventNodeCommand* event)
      {
         //������� ����� �� �����������.
         if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
         
         //��������� ��������� �������.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 2, Width()-24, 20);
         lineHeader.Event(command);
         delete command;
            
         //��������� ������� �������.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 22, Width()-24, High()-24);
         workArea.Event(command);
         delete command;
         
         //��������� ������.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(),Width()-22, 2, 20, High()-4);
         scroll.Event(command);
         delete command;
      }
      ///
      /// ������ �����.
      ///
      int highLine;
      
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
         ow_twb = 20;
         ow_magic = 100;
         ow_symbol = 70;
         ow_order_id = 100;
         ow_entry_date = 150;
         ow_type = 50;
         ow_vol = 50;
         ow_price = 70;
         ow_sl = 70;
         ow_tp = 70;
         ow_currprice = 70;
         ow_profit = 90;
         ow_comment = 150;
         
         name_collapse_pos = "CollapsePos.";
         name_magic = "Magic";
         name_symbol = "Symbol";
         name_entryOrderId = "Order ID";
         name_entry_date = "EntryDate";
         name_type = "Type";
         name_vol = "Vol.";
         name_price = "Price";
         name_sl = "S/L";
         name_tp = "T/P";
         name_currprice = "Last Price";
         name_profit = "Profit";
         name_comment = "Comment";
         
         //ListPos = new CArrayObj();
         int count = 0;
         
         // ������ ����� �������� ��������� ������� (��� ���� ������).
         //lineHeader = new Line("LineHeader", GetPointer(this));
         Button* hmagic;
         // ��������� �������
         if(true)
         {
            TreeViewBox* hCollapse = new TreeViewBox(name_collapse_pos, GetPointer(lineHeader), BOX_TREE_GENERAL);
            hCollapse.Text("+");
            hCollapse.OptimalWidth(ow_twb);
            hCollapse.ConstWidth(true);
            lineHeader.Add(hCollapse);
            count++;
         }
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
            Button* hOrderId = new Button(name_entryOrderId, GetPointer(lineHeader));
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
         //���� ���������� ������
         if(true)
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
         //�������� ��� ����� ��� ������� �� ���������
         for(int i = 0; i < lineHeader.ChildsTotal();i++)
         {
            ProtoNode* node = lineHeader.ChildElementAt(i);
            node.BorderColor(clrBlack);
            node.BackgroundColor(clrWhiteSmoke);
         }
      }
      
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_CREATE_NEWPOS:
               AddPosition(event);
               break;
            //case EVENT_REFRESH:
            //   RefreshPos();
            //   break;
            case EVENT_COLLAPSE_TREE:
               OnCollapse(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
   private:
      void OnCollapse(EventCollapseTree* event)
      {
         // �����������
         if(event.IsCollapse())
         {
            DeleteDeals(event);
         }
         // �������������
         else
         {
            //printf("������ � " + event.NLine() + " ��������.");
            AddDeals(event);
         }
      }
      ///
      /// ���������������� �������������� ������������ �������
      ///
      /*void OnDeinit(EventDeinit* event)
      {
         ListPos.Clear();
         delete ListPos;
      }*/
      ///
      /// ��������� ���� �������� �������.
      ///
      void RefreshPrices()
      {
         int total = workArea.ChildsTotal();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = workArea.ChildElementAt(i);
            if(node.TypeElement() != ELEMENT_TYPE_POSITION ||
               node.TypeElement() != ELEMENT_TYPE_DEAL)
               continue;
            //��������� ������� � ������ ��-�������.
            if(node.TypeElement() == ELEMENT_TYPE_POSITION)
            {
               PosLine* posLine = node;
               Position* pos = posLine.Position();
               //posLine.
            }
         }
      }
      ///
      /// ��������� ��������� �������
      ///
      /*void RefreshPos()
      {
         int total = ListPos.Total();
         color lossZone = clrLavenderBlush;
         color profitZone = clrMintCream;
         for(int i = 0; i < total; i++)
         {
            GPosition* gposition = ListPos.At(i);
            //��������� ������ �������.
            if(nProfit != -1)
            {
               Line* lline = gposition.gpos.ChildElementAt(nProfit);
               if(lline.ChildsTotal() < 1)continue;
               Label* lprofit = lline.ChildElementAt(0);
               double profit = gposition.pos.Profit();
               string sprofit = gposition.pos.ProfitAsString();
               Button* btnClose = lline.ChildElementAt(1);
               if(profit > 0 && btnClose.BackgroundColor() != profitZone)
                  btnClose.BackgroundColor(profitZone);
               else if(profit <= 0 && btnClose.BackgroundColor() != lossZone)
                  btnClose.BackgroundColor(lossZone);
               lprofit.Text(sprofit);
            }
            //��������� ��������� ���� �������
            if(nLastPrice)
            {
               Label* lastprice = gposition.gpos.ChildElementAt(nLastPrice);
               int digits = (int)SymbolInfoInteger(gposition.pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(gposition.pos.CurrentPrice(), digits);
               //lastprice.Text((string)gposition.pos.CurrentPrice());
               lastprice.Text(price);
            }
         }
      }*/
      
      
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
               //TreeViewBox* twb = new TreeViewBox(name_collapse_pos, GetPointer(nline), BOX_TREE_GENERAL);
               TreeViewBoxBorder* twb = new TreeViewBoxBorder(name_collapse_pos, GetPointer(nline), BOX_TREE_GENERAL);
               twb.OptimalWidth(20);
               twb.ConstWidth(true);
               twb.BackgroundColor(clrWhite);
               twb.BorderColor(clrWhiteSmoke);
               nline.Add(twb);
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
            else if(node.ShortName() == name_price)
            {
               cell = new Label(name_price, GetPointer(nline));
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
               continue;
            }
            else if(node.ShortName() == name_currprice)
            {
               cell = new Label(name_currprice, GetPointer(nline));
               int digits = (int)SymbolInfoInteger(pos.Symbol(), SYMBOL_DIGITS);
               string price = DoubleToString(pos.CurrentPrice(), digits);
               cell.Text(price);
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
               cell.Edit(true);
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
            else if(node.ShortName() == name_comment)
            {
               cell = new Label(name_comment, GetPointer(nline));
               cell.Text((string)pos.EntryComment());
            }
            else
               cell = new Label("edit", GetPointer(nline));
            if(cell != NULL)
            {
               cell.BindingWidth(node);
               cell.BackgroundColor(clrWhite);
               cell.BorderColor(clrWhiteSmoke);
               cell.Edit(isReadOnly);
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
      /// ����������� ������������� �������
      ///
      class PosLine : public Line
      {
         public:
            PosLine(ProtoNode* parNode, Position* pos) : Line("Position", ELEMENT_TYPE_POSITION, parNode)
            {
               //��������� ����������� ������������� ������� � ���������� ��������.
               position = pos;
            }
            ///
            /// ���������� �������, ��� ����������� ������������� ��������� ������� ���������.
            ///
            Position* Position(){return position;}
            ///
            /// ���������� ������, ������������ ��������� ���� �������.
            ///
            Label* CellLastPrice(){return cellLastPrice;}
            ///
            /// ��������� ��������� ���� ������� � �������, � ������� ��� ������������.
            ///
            void CellLastPrice(Label* label){cellLastPrice = label;}
         private:
            ///
            /// ��������� �� �������, ��� ����������� ������������� ��������� ������� ���������.
            ///
            Position* position;
            ///
            /// ��������� ���� �����������, �� �������� ������� �������.
            ///
            Label* cellLastPrice;
            ///
            /// ������ �������.
            ///
            Label* cellProfit;
      };
      ///
      /// ����������� ������������� ������
      ///
      class DealLine : public Line
      {
         public:
            DealLine(ProtoNode* parNode, Deal* EntryDeal, Deal* ExitDeal) : Line("Deal", ELEMENT_TYPE_DEAL, parNode)
            {
               //��������� ����������� ������������� ������ � ���������� ��������.
               entryDeal = EntryDeal;
               exitDeal = ExitDeal;
            }
            ///
            /// ���������� ��������� �� ����� ���������������� �������.
            ///
            Deal* EntryDeal(){return entryDeal;}
            ///
            /// ���������� ��������� �� ����� ����������� �������.
            ///
            Deal* ExitDeal(){return exitDeal;}
         private:
            ///
            /// ��������� �� ����� ���������������� �������, ��� ����������� ������������� ��������� ������� ���������.
            ///
            Deal* entryDeal;
            ///
            /// ��������� �� ����� ����������� �������, ��� ����������� ������������� ��������� ������� ���������.
            ///
            Deal* exitDeal;
      };
      ///
      /// ��������� ������������ ������ ��� �������
      ///
      void AddDeals(EventCollapseTree* event)
      {
         ProtoNode* node = event.Node();
         int n_line = node.NLine();
         //������� ����� ������������ ������ �������, � � ������� ���������� �������� �� �����.
         if(node.TypeElement() != ELEMENT_TYPE_POSITION)return;
         PosLine* posLine = node;
         Position* pos = posLine.Position();
         long order_id = pos.EntryOrderID();
         //������� �������� ������, ������� ���������� ��������.
         CArrayObj* entryDeals = pos.EntryDeals();
         CArrayObj* exitDeals = pos.ExitDeals();
         // ���������� �������������� ����� ����� ����� ������������
         // ���������� ������ ����� �� ������
         int entryTotal = entryDeals != NULL ? entryDeals.Total() : 0;
         int exitTotal = exitDeals != NULL ? exitDeals.Total() : 0;
         int total;
         int fontSize = 9;
         if(entryTotal > 0 && entryTotal > exitTotal)
            total = entryTotal;
         else if(exitTotal > 0 && exitTotal > exitTotal)
            total = exitTotal;
         else return;
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
                  magic.Edit(true);
                  magic.BindingWidth(cell);
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
                  symbol.Edit(true);
                  symbol.BindingWidth(cell);
                  symbol.Text(lcell.Text());
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
                  entry_id.Edit(true);
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
                  entryDate.Edit(true);
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
                  entryType.Edit(true);
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
                  dealVol.Edit(true);
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
               if(cell.ShortName() == name_price)
               {
                  Label* entryPrice = new Label("DealEntryPrice", nline);
                  entryPrice.FontSize(fontSize);
                  entryPrice.Edit(true);
                  entryPrice.BindingWidth(cell);
                  if(entryDeal != NULL)
                     entryPrice.Text((string)entryDeal.Price());
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
                  sl.Edit(true);
                  sl.BindingWidth(cell);
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
                  tp.Edit(true);
                  tp.BindingWidth(cell);
                  tp.Text(lcell.Text());
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
                  tral.Edit(true);
                  tral.BindingWidth(cell);
                  tral.Text("T");
                  tral.Align(ALIGN_RIGHT);
                  tral.BackgroundColor(cell.BackgroundColor());
                  tral.BorderColor(cell.BorderColor());
                  nline.Add(tral);
                  continue;
               }
               //��������� ����
               if(cell.ShortName() == name_currprice)
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
                  nline.Add(cprice);
                  continue;
               }
               //������
               if(cell.ShortName() == name_profit)
               {
                  Label* profit = new Label("DealProfit", nline);
                  profit.FontSize(fontSize);
                  profit.BindingWidth(cell);
                  profit.Edit(true);   
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
                  continue;
               }
               //�����������
               if(cell.ShortName() == name_comment)
               {
                  Label* comment = new Label("DealComment", nline);
                  comment.FontSize(fontSize);
                  comment.BindingWidth(cell);
                  comment.Edit(true);
                  comment.Text("");
                  comment.BackgroundColor(cell.BackgroundColor());
                  comment.BorderColor(cell.BorderColor());
                  nline.Add(comment);
                  continue;
               }
               
            }
            int m_total = nline.ChildsTotal();
            for(int el = 0; el < m_total; el++)
            {
               Label* label = nline.ChildElementAt(el);
               label.Font("Courier New");
            }
            int n = event.NLine();
            workArea.Add(nline, event.NLine()+1);
         }
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
      string name_entry_date;
      string name_type;
      string name_vol;
      string name_price;
      string name_sl;
      string name_tp;
      string name_tralSl;
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
      ///
      /// ���������� ����� � �������.
      ///
      int lines;
};