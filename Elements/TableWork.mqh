#include "..\Keys.mqh"
#include "Node.mqh"
class CWorkArea : public Label
{
   public:
      CWorkArea(Table* parNode) : Label(ELEMENT_TYPE_WORK_AREA, "WorkArea", parNode)
      {
         //childNodes.Reserve(512);
         table = parNode;   
         highLine = 20;
         Text("");
         ReadOnly(true);
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
         if(pos == childNodes.Total() && pos > 0)
         {
            ProtoNode* node = childNodes.At(pos-1);
            if(node.TypeElement() == ELEMENT_TYPE_TABLE_SUMMARY)
               pos -= 1;
         }
         childNodes.Insert(lineNode, pos);
         lineNode.NLine(pos);
         ChangeScroll();
      }
      ///
      /// ������������ ����� ���������� ����� ��� �������.
      ///
      int CalcTotalStepsForScroll()
      {
         // �������������� �����.
         int lineClearance = 2;
         //����� ���������� �����, ������� ����� ���������� � �����.
         int lines = (int)MathFloor(High()/highLine);
         if(lines >= lineClearance + childNodes.Total())
            return 0;
         int total = childNodes.Total() + lineClearance - lines;
         return total;
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
         ChangeScroll();
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
         if(node.TypeElement() == ELEMENT_TYPE_TABLE_SUMMARY)
         {
            Summary* s = node;
            s.RefreshSummury();
         }
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
         if(node.TypeElement() != ELEMENT_TYPE_TABLE_SUMMARY)
            InterlacingColor(node);
      }
      ///
      /// ���������� ����� ������ ���� ����� � �������.
      ///
      long LinesHighTotal()
      {
         return childNodes.Total()*highLine;
      }
      ///
      /// ���������� ����� ������ ���� ������� ����� � �������.
      ///
      long LinesHighVisible()
      {
         return LinesVisible()*highLine;
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
      /// ���������� ����� ���������� ������� � ��������� ����� � �������.
      ///
      int LinesTotal(){return childNodes.Total();}
      ///
      /// ������������� ������ �����, ������� ��������� ����������.
      ///
      void LineVisibleFirst(int index)
      {               
         if(index == visibleFirst)return;
         // �������� ������ ������ � ���������� �������.
         if(index < visibleFirst)
         {
            //������ ������������ ����� �� ����� �������� �� ������� �������.
            if(index < 0 || index >= childNodes.Total())return;
            visibleFirst = index;
            for(int i = visibleFirst; i < ChildsTotal(); i++)
               RefreshLine(i);
         }
         // �������� ������� ������ � ���������� ������.
         if(index > visibleFirst)
         {
            int total = childNodes.Total();
            if(index < 0 || index > total) return;
            //�������� ��������� ���� - �������� ������� ������.
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
         ChangeScroll();
      }
      ///
      /// ��������� ������ �� ������.
      ///
      void AddScroll(Scroll* nscroll)
      {
         scroll = nscroll;
      }
      ///
      /// ������������ ������� ��������� ��������� �������.
      ///
      void OnScrollChanged()
      {
         if(CheckPointer(scroll) == POINTER_INVALID)
            return;
         if(scroll.CurrentStep() != LineVisibleFirst())
         {
            LineVisibleFirst(scroll.CurrentStep());
         }
      }
   private:
   
      virtual void OnEvent(Event* event)
      {
         //��������� ����� �� ����� ������� ����������?
         if(event.Direction() == EVENT_FROM_DOWN && event.EventId() == EVENT_NODE_VISIBLE)
            ChangeLineVisible(event);

         // ������������ ������, �� ����� �� �����
         else if(event.Direction() == EVENT_FROM_DOWN && event.EventId() == EVENT_NODE_CLICK)
         {
            OnClickNode(event);
            EventSend(event);
         }
         
         // ������������ ������� �������.
         else if(event.EventId() == EVENT_KEYDOWN)
         {
            OnKeyPress(event);
            EventSend(event);
         }
         else if(event.EventId() == EVENT_REFRESH)
         {
            OnRefreshPrices();
         }
         //������������ ������������ ����.
         //else if(event.EventId() == EVENT_MOUSE_MOVE)
         //   return;
         else
            EventSend(event);
      }
      ///
      /// ���������� ������� "��������� ����� �� ����� ������� ����������".
      ///
      void ChangeLineVisible(EventVisible* event)
      {
         EventVisible* vis = event;
         ProtoNode* node = vis.Node();
         if(vis.Visible())
         {
            ++visibleCount;
            highTotal += node.High();
         }
         else
         {
            highTotal -= node.High();
            --visibleCount;  
         }
      }
      ///
      /// ������������� ������ �� ������ �������, �� �������
      /// ��� ���������� ������.
      ///
      void OnClickNode(EventNodeClick* event)
      {
         //���� ������ ��� ���������� �� ������ ���������� ������������� �����,
         //������ ������� ������ ���� ���������� ��������.
         //� ��������� ������, ��������� ������ �������� �������, ������� ���� �������� ������.
         ProtoNode* node = event.Node();
         if(node.TypeElement() == ELEMENT_TYPE_LABEL)
         {
            Label* lab = node;
            //�������� ��������� ������
            ProtoNode* parNode = lab.ParentNode();
            bool isConvert = parNode.TypeElement() == ELEMENT_TYPE_POSITION ||
            parNode.TypeElement() == ELEMENT_TYPE_DEAL;
            if(lab.ReadOnly() && isConvert)
               MoveCursor(parNode);
         }
      }
      ///
      /// ���������� ������ �� ����� ������.
      /// \param newCursLine - ����� �����, �� ������� ����� ����������� ������.
      ///
      void MoveCursor(Line* newCursLine)
      {
         if(CheckPointer(newCursLine) == POINTER_INVALID)return;
         Line* oldCursor = cursorLine;
         cursorLine = newCursLine;
         //�������� ������ ������ �� ����������� ����
         if(CheckPointer(oldCursor) != POINTER_INVALID)
            InterlacingColor(oldCursor);
         ColorationBack(newCursLine, clrLightSteelBlue);
      }
      ///
      /// ���������� ������� ������� �������.
      ///
      void OnKeyPress(EventKeyDown* event)
      {
         switch(event.Code())
         {
            case KEY_ARROW_UP:
            case KEY_ARROW_DOWN:
               OnKeyPressArrow(event.Code());
               break;
            case KEY_HOME:
               LineVisibleFirst(0);
               break;
            case KEY_END:
               LineVisibleFirst(CalcTotalStepsForScroll());
               break;
            case KEY_PAGE_UP:
               OnPressPage(KEY_PAGE_UP);
               break;
            case KEY_PAGE_DOWN:
               OnPressPage(KEY_PAGE_DOWN);
               break;
         }  
      }
      ///
      /// ���������� ������� ������� ������� "������� �����" ��� "������� ����".
      ///
      void OnKeyPressArrow(ENUM_KEY_CODE code)
      {
         //����������� ������ ������ ���� �� ����.
         if(CheckPointer(cursorLine) == POINTER_INVALID)return;
         int n = cursorLine.NLine();
         if(ChildsTotal() > n+1 && code == KEY_ARROW_DOWN)
         {
            //���� ��������� ������� ������� ����� �� ��������.
            if(visibleFirst + visibleCount <= n+1)
               LineVisibleFirst(n+2 - visibleCount);
            Line* nline = ChildElementAt(n+1);
            if(nline.TypeElement() != ELEMENT_TYPE_TABLE_SUMMARY)
               MoveCursor(nline);
         }
         else if(n > 0 && code == KEY_ARROW_UP)
         {
            //���� ��������� ������� ������� ����� �� ��������.
            if(n-1 < visibleFirst)
               LineVisibleFirst(n-1);
            Line* nline = ChildElementAt(n-1);
            if(nline.TypeElement() != ELEMENT_TYPE_TABLE_SUMMARY)
               MoveCursor(nline);
         }
      }
      ///
      /// ������������ ������� ������ "������������� ������ �� ���� ����� �����/����".
      ///
      void OnPressPage(ENUM_KEY_CODE code)
      {
         if(code == KEY_PAGE_UP)
         {
            int fl = visibleFirst - visibleCount-1;
            if(fl < 0)fl = 0;
            LineVisibleFirst(fl);
         }
         else if(code == KEY_PAGE_DOWN)
         {
            int fl = visibleFirst + visibleCount-1;
            int limit = CalcTotalStepsForScroll();
            if(fl > limit)fl = limit;
            LineVisibleFirst(fl);
         }
      }
      
      virtual void OnCommand(EventNodeCommand* event)
      {
         //������� ����� �� �����������.
         if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
         OnCommand();
      }
      
      /*virtual void OnVisible(EventVisible* event)
      {
         if(event.Visible())
            OnCommand();
      }*/
      ///
      /// ��������� ����� �������� ��������� �������.
      ///
      void OnCommand()
      {
         int total = ChildsTotal();
         double lines = MathFloor(High()/(double)highLine);
         if(total <= lines)
         {
            visibleFirst = 0;
            ChangeScroll();
            for(int i = visibleFirst; i < total; i++)
               RefreshLine(i);
            return;
         }
         //��� ������ ����� ������ ������� � �������� ��������. (�� ��������)
         //int lt = (int)MathRound(High()/((double)highLine));
         //int vt = visibleFirst + lt;
         //if(vt >= total && vt < total+3)
         //   return;
         //if(visibleFirst + visibleCount == total)
         //   return;
         //�����, ������� �����, ��� ������� �� �������� �����
         int dn_line = total - (visibleFirst + visibleCount);
         //����� ����� ���������� ����� ������ �����
         if(visibleCount + dn_line < lines)
         {
            int n = (int)(lines - (dn_line + visibleCount));
            visibleFirst -= n;
         }
         for(int i = visibleFirst; i < total; i++)
            RefreshLine(i);
         ChangeScroll();
      }
      ///
      /// ��������� ���� �������� �������.
      ///
      void OnRefreshPrices()
      {
         if(!Visible())return;
         if(table.TableType() != TABLE_POSACTIVE)return;
         int total = ChildsTotal();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = ChildElementAt(i);
            ENUM_ELEMENT_TYPE el_type = node.TypeElement();
            switch(el_type)
            {
               case ELEMENT_TYPE_POSITION:
               case ELEMENT_TYPE_DEAL:
               {
                  AbstractLine* linePos = node;
                  linePos.RefreshValue(COLUMN_CURRENT_PRICE);
                  linePos.RefreshValue(COLUMN_PROFIT);
                  break;
               }
               case ELEMENT_TYPE_TABLE_SUMMARY:
               {
                  Summary* summary = node;
                  summary.RefreshSummury();
                  break;
               }
            }
         }
      }
      
      ///
      /// ��������� ��������� �������.
      ///
      void ChangeScroll(void)
      {
         if(CheckPointer(scroll) != POINTER_INVALID)
         {
            scroll.CurrentStep(visibleFirst);
            scroll.TotalSteps(CalcTotalStepsForScroll());
         }
      }
      ///
      /// �������� ������ �������������� � ����� ������ �������.
      ///
      void InterlacingColor(ProtoNode* nline)
      {
         color clrBack;
         //���������� ������ ��� �������� �� �������������.
         bool checkPoint = CheckPointer(cursorLine) != POINTER_INVALID &&
                           CheckPointer(nline) != POINTER_INVALID;
         if(checkPoint && nline == cursorLine)return;
         if((nline.NLine()+1) % 2 == 0)
            clrBack = clrWhiteSmoke;
         else clrBack = clrWhite;
         ColorationBack(nline, clrBack);
      }
      ///
      /// ������������ ��� �������� ��������� nline � ��������� ����.
      ///
      void ColorationBack(ProtoNode* nline, color clrBack)
      {
         
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
      ///
      /// �������� �� ������, ������� � ������ ������ ��������� ��� ��������.
      ///
      Line* cursorLine;
      ///
      /// ��������� �� ������������ �������.
      ///
      Table* table;
      ///
      /// ��������� �� ������������ ������.
      ///
      Scroll* scroll;
};
