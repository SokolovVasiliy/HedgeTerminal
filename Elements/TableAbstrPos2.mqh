#include "Table.mqh"
#include "..\Math.mqh"
#include "Node.mqh"
#include "TextNode.mqh"

///
/// ����������� ����� ����� �� ����� �������. ������ ����� ���� ����������, �������� ��� �������.
/// �� ��� ������ ���� ��������� � ������ ��������.
///
class AbstractLine : public Line
{
   public:
      ///
      /// ���������� ��� �������, � ������� ����������� ������� ������.
      ///
      ENUM_TABLE_TYPE TableType(){return tblType;}
      ///
      /// ��������� �������� ���� ����� �������� � ������.
      ///
      void RefreshAll()
      {
         int total = ArraySize(textNodes);
         for(int i = 0; i < total; i++)
            RefreshValue((ENUM_COLUMN_TYPE)i);
      }
      ///
      /// ��������� �������� ������ cType.
      ///
      void RefreshValue(ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(textNodes) > cType &&
            CheckPointer(textNodes[cType]) != POINTER_INVALID)
         {
            textNodes[cType].Text(GetStringValue(cType));
            OnRefreshValue(cType);
         }
      }
      ///
      /// ���������� ������ �� ������.
      ///
      TextNode* GetCell(ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(protoNodes) > cType &&
            CheckPointer(protoNodes[cType]) != POINTER_INVALID)
         {
            return protoNodes[cType];
         }
         return NULL;
      }
      ///
      /// ���������� ������ �� ������.
      ///
      TextNode* GetCellText(ENUM_COLUMN_TYPE cType)
      {
         if(ArraySize(textNodes) > cType &&
            CheckPointer(textNodes[cType]) != POINTER_INVALID)
         {
            return textNodes[cType];
         }
         return NULL;
      }
   protected:
      ///
      /// ������ ������-�����. 
      ///
      class tnode
      {
         public:
            ///
            /// ��������� �� ������, ������� ���� �������� � ������.
            ///
            ProtoNode* element;
            ///
            /// ��������� �� ������, ����� ������� ����� ������.
            ///
            TextNode* value;
      };
      
      AbstractLine(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode, ENUM_TABLE_TYPE tType) : Line(myName, elType, parNode)
      {
         tblType = tType;
      }
      virtual string GetStringValue(ENUM_COLUMN_TYPE cType)
      {
         return EnumToString(cType);
      }
      ///
      /// ������� ������� ��-���������.
      ///
      virtual tnode* GetColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         TextNode* element = NULL;
         tnode* comby = new tnode();
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               element = GetDefaultEl(el);
               element.Text("+");
               comby.value = element;
               break;
            default:
               element = GetDefaultEl(el);
               comby.value = element;
               break;
         }
         comby.element = element;
         return comby;
      }
      ///
      /// ������� � ���������� ������� ��-���������.
      ///
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         EditNode* build = NULL;
         build = new Label(el.Name(), GetPointer(this));
         //build.BorderColor(clrRed);
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      ///
      /// ��������� ����� ���������� ��������� ���������������� GetColumn().
      /// ����� ������� ������ ������������� ����� ������������� ������������ �������� ������.
      ///
      void BuilderLine()
      {
         if(CheckPointer(Settings) == POINTER_INVALID)return;
         //�������� ������ �������, ������� ���� �������������.
         CArrayObj* scolumns = NULL;
         switch(tblType)
         {
            case TABLE_POSACTIVE:
               scolumns = Settings.GetSetForActiveTable();
               break;
            case TABLE_POSHISTORY:
               scolumns = Settings.GetSetForHistoryTable();
               break;
            default:
               //���� ��� ������� ����������, �� � ������������ ������.
               return; 
         }
         //��������� �����.
         int total = scolumns.Total();
         for(int i = 0; i < total; i++)
         {
            TextNode* value = NULL;
            DefColumn* el = scolumns.At(i);
            ENUM_COLUMN_TYPE cType = el.ColumnType();
            tnode* node = GetColumn(el);
            if(CheckPointer(node.element) != POINTER_INVALID)
            {
               Add(node.element);
               if(ArraySize(protoNodes) <= cType)
                  ArrayResize(protoNodes, cType+1);
               protoNodes[cType] = node.element;
            }
            if(CheckPointer(node.value) != POINTER_INVALID)
            {
               if(ArraySize(textNodes) <= cType)
                  ArrayResize(textNodes, cType+1);
               textNodes[cType] = node.value;
            }
            delete node;
         }
      }
      ///
      /// ���������� ��� ���������� ������� cType � ���������������� �������� �������.
      ///
      virtual void OnRefreshValue(ENUM_COLUMN_TYPE cType){;}
   private:
      ENUM_TABLE_TYPE tblType;
      ///
      /// ��� �������� ������� � ��������� ������ ����� ������ ������ �� ������.
      ///
      TextNode* textNodes[];
      ///
      /// ��� �������� ������� � ��������� ������ ����� ������ ������ �� ��������.
      ///
      ProtoNode* protoNodes[];
      ///
      /// �������� ������������ ��������� ���� (PriceStep);
      ///
      double ticksize;
};

//class 
///
/// ����� ��������� ������-��������� ������� �������.
///
class HeaderPos : public AbstractLine
{
   public:
      HeaderPos(ProtoNode* parNode, ENUM_TABLE_TYPE tType) : AbstractLine("header", ELEMENT_TYPE_TABLE_HEADER_POS, parNode, tType)
      {
         BuilderLine();
      }
   private:
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         TextNode* build = NULL;
         //� ������� �� ���������� ��-��������� ��������� ������, � �� ��������� �����.
         build = new Button(el.Name(), GetPointer(this));
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      ///
      /// ������� ������� ��-���������.
      ///
      
      virtual tnode* GetColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         tnode* comby = new tnode();
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               comby.element = GetCollapseEl(el);
               break;
            case COLUMN_TRAL:
               comby.element = GetTralEl(el);
               comby.value = comby.element;
               break;
            default:
               comby.element = GetDefaultEl(el);
               comby.value = comby.element;
               break;
         }
         //����� ������������� �������������� ����� �������� ��� ������
         return comby;
      }
      ///
      /// ������� ������� ��� ��������/�������� ����� ������.
      ///
      TextNode* GetCollapseEl(DefColumn* el)
      {
         TextNode* tbox = NULL;
         string sname = el.Name();
         //����� ������������� ������� ��� ��������� �������?
         tbox = new TreeViewBox(sname, GetPointer(this), BOX_TREE_GENERAL);
         tbox.Text("+");
         // ������������� ���������� ��������.
         tbox.OptimalWidth(el.OptimalWidth());
         tbox.ConstWidth(el.ConstWidth());
         return tbox;
      }
      ///
      /// ��������� ���� �����
      ///
      TextNode* GetTralEl(DefColumn* el)
      {
         TextNode* build = NULL;
         build = GetDefaultEl(el);
         build.Text(CharToString(79));
         build.Font("Wingdings");
         return build;
      }
};

///
/// ����� ��������� ������-������� ������� �������.
///
class PosLine : public AbstractLine
{
   public:
      PosLine(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* m_pos) : AbstractLine("PosLine", ELEMENT_TYPE_POSITION, parNode, tType)
      {
         if(CheckPointer(m_pos) != POINTER_INVALID)
            pos = m_pos;
         BuilderLine();
         pos.PositionLine(GetPointer(this));
      }
      ///
      /// ���������� ��������� �� �������, � ������� ������������� ������ ������.
      ///
      Position* Position()
      {
         return pos;
      }
      
      virtual int Compare(const CObject *node, const int mode=0) const
      {
         //const AbstractLine* posLine = node;
         //Position* fpos = posLine.Position();
         //return pos.Compare(fpos, mode);
         return 0;
      }
   private:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_CLOSE_POS:
               if(event.Direction() == EVENT_FROM_DOWN)
                  OnClosePos();
               break;
            case EVENT_END_EDIT_NODE:
               IndefyEndEditNode(event);
               break;
            case EVENT_BLOCK_POS:
               OnBlockPos(event);
               break;
            default:
               EventSend(event);
         }
      }
      ///
      /// �������������� � ����� ������ ���� ��������� ���������,
      /// � � ����������� �� �����, �������� ��������������� �������� ���������.
      ///
      void IndefyEndEditNode(EventEndEditNode* event)
      {
         EditNode* ch_node = event.Node();
         int index = ch_node.NLine();
         
         ENUM_COLUMN_TYPE clType;
         for(int i = 0; i < 10; i++)
         {
            switch(i)
            {
               case 0:
                  clType = COLUMN_VOLUME;
                  break;
               case 1:
                  clType = COLUMN_SL;
                  break;
               default:
                  return;
            }
            ProtoNode* node = GetCell(clType);
            if(ch_node == node)
            {
               switch(clType)
               {
                  case COLUMN_VOLUME:  
                     OnClosePartPos(event.Node());
                     break;
                  case COLUMN_SL:
                     OnStopLossModify(event.Node());
                     break;
               }
            }
         }
      }
      
      ///
      /// ��������� ��������� �������.
      ///
      void OnClosePos()
      {
         if(pos.Status() != POSITION_ACTIVE)return;
         string value = GetStringValue(COLUMN_EXIT_COMMENT);
         //��������� ������� �� �������� �������.
         //Task* closePos = new TaskClosePos(pos);
         //pos.AddTask(closePos);
         //pos.AsynchClose(pos.VolumeExecuted(), value);
         //���������, ����� �� �� ������� �������.
         //...
         TaskClosePos* closePos = new TaskClosePos(pos, value);
         pos.AddTask(closePos);
      }
      
      ///
      /// ������������ ������ �� �������� ����� �������� �������.
      ///
      void OnClosePartPos(EditNode* editNode)
      {
         double setVol = StringToDouble(editNode.Text());
         double curVol = pos.VolumeExecuted();
         if(!pos.IsValidNewVolume(setVol))
         {
            editNode.Text(pos.VolumeToString(curVol));
            return;
         }
         editNode.Text(pos.VolumeToString(setVol)+"...");
         string exitComment = GetStringValue(COLUMN_EXIT_COMMENT);
         double vol = curVol < setVol ? setVol : curVol - setVol;
         pos.AsynchClose(vol, exitComment);
      }
      
      ///
      /// ���������� ������ �� ��������/����������� ������ ����-����.
      ///
      void OnStopLossModify(EditNode* editNode)
      {
         double setPrice = StringToDouble(editNode.Text());
         bool notNull = !Math::DoubleEquals(setPrice, 0.0);
         if(pos.UsingStopLoss() && !notNull)
         {
            pos.AddTask2(new TaskDeleteStopLoss(pos, true));
            return;
         }
         if(!pos.UsingStopLoss() && notNull)
         {
            pos.AddTask2(new TaskSetStopLoss(pos, setPrice, true));
            return;
         }
         //pos.StopLossModify(setPrice, pos.ExitComment(), true);
         TaskModifySL* sl = new TaskModifySL(pos, setPrice, pos.ExitComment());
         pos.AddTask(sl);
      }
      
      ///
      /// ������������ ������� ���������� �������.
      ///
      void OnBlockPos(EventBlockPosition* event)
      {
         if(pos != event.Position())return;
         if(event.Status())
         {
            BlockedCell();
         }
         else
            UnBlockedCell();
         
      }
      ///
      /// ��������� �������������� ������ � �������, ������� ���������
      /// ��� �������������.
      ///
      void BlockedCell()
      {
         tiks = GetTickCount();
         EditNode* cell = GetCell(COLUMN_VOLUME);
         cell.ReadOnly(true);
         cell = GetCell(COLUMN_SL);
         cell.ReadOnly(true);
         SetColorLine(clrRed);
      }
      
      ///
      /// ���������������� �������������� ������ � �������, ������� ���������
      /// ��� �������������.
      ///
      void UnBlockedCell()
      {
         //LogWriter("Task complete for " + (string)(GetTickCount()-tiks) + " msc.", MESSAGE_TYPE_INFO);
         //tiks = 0;
         EditNode* cell = GetCell(COLUMN_VOLUME);
         double vol = pos.VolumeExecuted();
         cell.Text(pos.VolumeToString(vol));
         cell.ReadOnly(false);
         
         cell = GetCell(COLUMN_SL);
         //double sl = pos.StopLossLevel();
         //cell.Text(pos.PriceToString(sl));
         if(pos.Status() == POSITION_ACTIVE)
            cell.ReadOnly(false);
         cell.FontColor(clrRed);
         TextNode* m = childNodes.At(0);
         SetColorLine(Settings.ColorTheme.GetTextColor());
      }
      
      ///
      /// ������������� ���� ��������� ���������.
      ///
      void SetColorLine(color clr)
      {
         for(int i = 0; i < childNodes.Total(); i++)
         {
            TextNode* m = childNodes.At(i);
            //if(m.TypeElement() != ELEMENT_TYPE_LABEL)continue;
            TextNode* cell = m;
            cell.FontColor(clr);
         }
         TextNode* node = GetCell(COLUMN_PROFIT);
         if(node == NULL)return;
         for(int i = 0; i < node.ChildsTotal(); i++)
         {
            TextNode* n = node.ChildElementAt(i);
            n.FontColor(clr);
         }
      }
      ///
      /// 
      ///
      virtual tnode* GetColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         tnode* comby = new tnode();
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               comby.element = GetCollapseEl(el);
               break;
            case COLUMN_TRAL:
               comby.element = GetTralEl(el);
               break;
            case COLUMN_PROFIT:
               delete comby;
               comby = GetProfitEl(el);
               break;
            case COLUMN_VOLUME:
               comby.element = GetDefaultEditEl(el);
               comby.value = comby.element;
               break;
            case COLUMN_SL:
               comby.element = GetSLNode(el);
               comby.value = comby.element;
               break;
            default:
               comby.element = GetDefaultEl(el);
               comby.value = comby.element;
               //if(cType == COLUMN_VOLUME)
               //   comby.element.Edit(true);
               break;
         }
         if(CheckPointer(comby.value) != POINTER_INVALID)   
            comby.value.Text(GetStringValue(cType));
         return comby;
      }
      
      EditNode* GetDefaultEditEl(DefColumn* el)
      {
         EditNode* enode = GetDefaultEl(el);
         if(TableType() == TABLE_POSACTIVE)
            enode.ReadOnly(false);
         return enode;
      }
      
      TextNode* GetCollapseEl(DefColumn* el)
      {
         Label* tbox = NULL;
         tbox = new TreeViewBoxBorder(el.Name(), GetPointer(this), BOX_TREE_GENERAL);
         tbox.BorderColor(clrGreen);
         tbox.OptimalWidth(el.OptimalWidth());
         tbox.ConstWidth(el.ConstWidth());
         return tbox;
      }
      
      TextNode* GetSLNode(DefColumn* el)
      {
         EditNode* enode = GetDefaultEditEl(el);
         if(pos.UsingStopLoss())
         {
            Order* order = pos.StopOrder();
            enode.Tooltip("#" + (string)order.GetId());
         }
         if(pos.Status() != POSITION_HISTORY)
            return enode;
         Order* exitOrder = pos.ExitOrder();
         if(exitOrder.IsStopLoss())
         {
            enode.SetBlockBgColor(clrPink);         
            int dir = pos.Direction() == DIRECTION_LONG ? 1 : -1;
            double slipage = (exitOrder.EntryExecutedPrice() - exitOrder.PriceSetup() * dir);
            enode.Tooltip("slipage: " + pos.PriceToString(slipage));
         }
         return enode;
      }
      
      CheckBox* GetTralEl(DefColumn* el)
      {
         CheckBox* build = NULL;
         build = new CheckBox(el.Name(), GetPointer(this));
         build.Text(CharToString(168));
         build.Font("Wingdings");
         build.FontSize(12);
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      
      tnode* GetProfitEl(DefColumn* el)
      {
         tnode* comby = new tnode();
         Line* element = NULL;
         //� ����������� �� ����, �������� �� ������� ������������ ��� ��������,
         //������ ������������ ������ ������� �� ����� ������. 
         if(TableType() == TABLE_POSACTIVE)
         {
            element = new Line(el.Name(), GetPointer(this));
            element.AlignType(LINE_ALIGN_CELLBUTTON);
            Label* profit = new Label(el.Name(), element);
            comby.value = profit;
            ButtonClosePos* btnClose = new ButtonClosePos("btnClosePos.", element);
            btnClose.Font("Wingdings");
            btnClose.FontSize(12);
            btnClose.Text(CharToString(251));
            element.Add(profit);
            element.Add(btnClose);
            element.OptimalWidth(el.OptimalWidth());
            element.ConstWidth(el.ConstWidth());
            comby.element = element;
         }
         else
         {
            comby.element = GetDefaultEl(el);
            comby.value = comby.element;
         }
         return comby;
      }
      ///
      /// ��������� ����������� ������������� �������
      ///
      virtual string GetStringValue(ENUM_COLUMN_TYPE cType)
      {
         string value = EnumToString(cType);
         //���������� � ������� ������ ���� ������
         if(CheckPointer(pos) == POINTER_INVALID)return value;
         CTime* ctime = NULL;
         switch(cType)
         {
            case COLUMN_MAGIC:
               if(!pos.Unmanagment())
                  value = (string)pos.EntryMagic();
               else
                  value = "UNMANAGMENT";
               break;
            case COLUMN_SYMBOL:
               value = pos.Symbol();
               break;
            case COLUMN_ENTRY_ORDER_ID:
               value = (string)pos.EntryOrderId();
               
               break;
            case COLUMN_EXIT_ORDER_ID:
               value = (string)pos.ExitOrderId();
               break;
            case COLUMN_EXIT_MAGIC:
               value = (string)pos.ExitMagic();
               break;
            case COLUMN_ENTRY_DATE:
               ctime = new CTime(pos.EntryExecutedTime());
               value = ctime.TimeToString(TIME_DATE | TIME_MINUTES);
               delete ctime;
               break;
            case COLUMN_EXIT_DATE:
               ctime = new CTime(pos.ExitExecutedTime());   
               value = ctime.TimeToString(TIME_DATE | TIME_MINUTES);
               delete ctime;
               break;
            case COLUMN_TYPE:
               value = pos.TypeAsString();
               break;
            case COLUMN_VOLUME:
               value = pos.VolumeToString(pos.VolumeExecuted());
               break;
            case COLUMN_ENTRY_PRICE:
               value = pos.PriceToString(pos.EntryExecutedPrice());
               break;
            case COLUMN_SL:
            {
               double sl = pos.StopLossLevel();
               if(Math::DoubleEquals(sl, 0.0))
                  value = "-.";
               else
               {
                  value = pos.PriceToString(sl);
                  /*ProtoNode* node = GetCell(COLUMN_SL);
                  if(node != NULL && node.ToolTip() != )*/
               }
               break;
            }
            case COLUMN_TP:
            {
               double tp = pos.TakeProfitLevel();
               if(Math::DoubleEquals(tp, 0.0))
                  value = "";
               else
                  value = pos.PriceToString(tp);
               break;
            }
            case COLUMN_TRAL:
               if(pos.UsingStopLoss())
                  value = CharToString(254);
               else
                  value = CharToString(168);
               break;
            case COLUMN_EXIT_PRICE:
               value = pos.PriceToString(pos.ExitExecutedPrice());
               break;
            case COLUMN_CURRENT_PRICE:
               value = pos.PriceToString(pos.CurrentPrice());
               break;
            case COLUMN_PROFIT:
               value = pos.ProfitAsString();
               break;
            case COLUMN_ENTRY_COMMENT:
               value = pos.EntryComment();
               break;
            case COLUMN_EXIT_COMMENT:
               value = pos.ExitComment();
               break;
         }
         return value;
      }
      
      ///
      /// ���������� �������������� �������� ��� ���������� ���
      ///
      virtual void OnRefreshValue(ENUM_COLUMN_TYPE cType)
      {
         if(cType != COLUMN_PROFIT)return;
         double sl = pos.StopLossLevel();
         if(Math::DoubleEquals(sl, 0.0))return;
         double delta = MathAbs(pos.CurrentPrice() - sl);
         TextNode* node = GetCell(COLUMN_SL);
         if(node == NULL)return;
         int steps = Settings.GetPriceStepCount();
         if(stepValue < 0.00001)
            stepValue = SymbolInfoDouble(pos.Symbol(), SYMBOL_TRADE_TICK_SIZE);
         if(delta < steps*stepValue)
            node.BackgroundColor(clrPink);
         //�������� ������������ ����
         else if(node.BackgroundColor() == clrPink)
         {
            color restoreClr = clrWhite;
            //����� ������ ���������� ����.
            for(int i = 0; i < childNodes.Total(); i++)
            {
               ProtoNode* anyNode = childNodes.At(i);
               restoreClr = anyNode.BackgroundColor();
               break;
            }
            node.BackgroundColor(restoreClr);
         }
      }
      ///
      /// ��������� �� �������, ������� ������������ ������ ������.
      ///
      Position* pos;
      ///
      /// ���������� ���-�� ����� � ������� ������� ������� � ������
      /// ��� ������� ���������� �������� ��������.
      ///
      long tiks;
      ///
      /// �������� ������ ���������� � ������� �����������.
      ///
      double stepValue;
      int countPS;
};

///
/// ����� ��������� ������-������� ������� �������.
///
class DealLine : public AbstractLine
{
   public:
      DealLine(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* mpos, Deal* EntryDeal, Deal* ExitDeal, bool IsLastLine):
      AbstractLine("Deal", ELEMENT_TYPE_DEAL, parNode, tType)
      {
         if(CheckPointer(mpos) != POINTER_INVALID)
            pos = mpos;
         if(CheckPointer(EntryDeal) != POINTER_INVALID)
            entryDeal = EntryDeal;
         if(CheckPointer(ExitDeal) != POINTER_INVALID)
            exitDeal = ExitDeal;
         isLastLine = IsLastLine;
         BuilderLine();
         
      }
   private:
      virtual TextNode* GetDefaultEl(DefColumn* el)
      {
         TextNode* build = AbstractLine::GetDefaultEl(el);
         build.FontSize(build.FontSize()-1);
         return build;
      }
      virtual tnode* GetColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         tnode* comby = new tnode;
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               comby.element = GetCollapseEl(el);
               break;
            case COLUMN_TRAL:
               comby.element = GetTralEl(el);
               comby.value = comby.element;
               break;
            default:
               comby.element = GetDefaultEl(el);
               comby.value = comby.element;
               break;
         }
         if(CheckPointer(comby.value) != POINTER_INVALID)
            comby.value.Text(GetStringValue(cType));
         return comby;
      }
      
      TextNode* GetCollapseEl(DefColumn* el)
      {
         Label* tbox = NULL;
         ENUM_BOX_TREE_TYPE b_type = isLastLine ? BOX_TREE_ENDSLAVE : BOX_TREE_SLAVE;
         tbox = new TreeViewBox(el.Name(), GetPointer(this), b_type); 
         tbox.OptimalWidth(el.OptimalWidth());
         tbox.ConstWidth(el.ConstWidth());
         return tbox;
      }
      
      TextNode* GetTralEl(DefColumn* el)
      {
         TextNode* build = NULL;
         build = new Label(el.Name(), GetPointer(this));
         build.Font("Wingdings");
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      virtual string GetStringValue(ENUM_COLUMN_TYPE cType)
      {
         string value = "";
         //������ ���� ���� �� ���� ������.
         if(entryDeal == NULL && exitDeal == NULL)return value;
         Deal* defDeal = entryDeal == NULL ? exitDeal : entryDeal;
         switch(cType)
         {
            case COLUMN_MAGIC:
               value = (string)defDeal.Magic();
               break;
            case COLUMN_SYMBOL:
               value = defDeal.Symbol();
               break;
            case COLUMN_ENTRY_ORDER_ID:
               if(entryDeal != NULL)
                  value = (string)entryDeal.GetId();
               break;
            case COLUMN_EXIT_ORDER_ID:
               if(exitDeal != NULL)
                  value = (string)exitDeal.GetId();
               break;
            case COLUMN_ENTRY_DATE:
               if(entryDeal != NULL)
               {
                  CTime* ctime = new CTime(entryDeal.TimeExecuted());   
                  value = ctime.TimeToString(TIME_DATE | TIME_MINUTES);
                  delete ctime;
               }
               break;
            case COLUMN_EXIT_DATE:
               if(exitDeal != NULL)
               {
                  CTime* ctime = new CTime(exitDeal.TimeExecuted());
                  value = ctime.TimeToString(TIME_DATE | TIME_MINUTES);
                  delete ctime;
               }
               break;
            case COLUMN_TYPE:
               value = "deal";
               break;
            case COLUMN_VOLUME:
               if(entryDeal != NULL)
                  value = entryDeal.VolumeToString(entryDeal.VolumeExecuted());
               break;
            case COLUMN_ENTRY_PRICE:
               if(entryDeal != NULL)
                  value = entryDeal.PriceToString(entryDeal.EntryExecutedPrice());
               break;
            case COLUMN_SL:
               if(!Math::DoubleEquals(pos.StopLossLevel(), 0.0))
                  value = pos.PriceToString(pos.StopLossLevel());
               else
                  value = "-";   
               break;
            case COLUMN_TP:
               value = "-";
               break;
            case COLUMN_TRAL:
               if(pos != NULL && pos.UsingStopLoss())
                  value = CharToString(254);
               else
                  value = CharToString(168);
               break;
            case COLUMN_EXIT_PRICE:
               if(exitDeal != NULL)
                  value = exitDeal.PriceToString(exitDeal.EntryExecutedPrice());
               break;
            case COLUMN_CURRENT_PRICE:
               if(pos != NULL)
                  value = pos.PriceToString(pos.CurrentPrice());
               break;
            case COLUMN_PROFIT:
               value = "-";
               break;
            case COLUMN_ENTRY_COMMENT:
               if(entryDeal != NULL)
                  value = entryDeal.Comment();
               break;
            case COLUMN_EXIT_COMMENT:
               if(exitDeal != NULL)
                  value = exitDeal.Comment();
               break;
         }
         return value;
      }
         
      ///
      /// �������, � ������� ����������� ������� ������ (���� ����).
      ///
      Position* pos;
      ///
      /// ������ ����� � ������� (���� ����).
      ///
      Deal* entryDeal;
      ///
      /// ������ ������ �� ������� (���� ����).
      ///
      Deal* exitDeal;
      ///
      /// ������, ���� ������� ������, �������������� ����� ��������� � ������ �������.
      ///
      bool isLastLine;
      
};