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
         
         childNodes.Insert(lineNode, pos);
         lineNode.NLine(pos);
         //����� ������� ��������, ��� ����������� �������� �������� ���� ����������.
         //uint tbegin = GetTickCount();
         //OnCommand();
         //printf("Add El: " + (string)(GetTickCount() - tbegin));
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
            if(index < 0 || index >= childNodes.Total()||
               index >= visibleFirst)return;
            visibleFirst = index;
            for(int i = visibleFirst; i < ChildsTotal(); i++)
               RefreshLine(i);
         }
         // �������� ������� ������ � ���������� ������.
         if(index > visibleFirst)
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
         //������������� ������, ������ ��� ����� ���������� �������.
         table.AllocationScroll();
      }
   private:
   
      virtual void OnEvent(Event* event)
      {
         //��������� ����� �� ����� ������� ����������?
         if(event.Direction() == EVENT_FROM_DOWN && event.EventId() == EVENT_NODE_VISIBLE)
            ChangeLineVisible(event);

         // ������������ ������, �� ����� �� �����
         if(event.Direction() == EVENT_FROM_DOWN && event.EventId() == EVENT_NODE_CLICK)
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
         // ������� ����� ���������� ������, ���� �� ����,
         // � ����� ���������� ������� ��� ��������.
         if(CheckPointer(cursorLine) != POINTER_INVALID)
         {
            // ���������� ������ ����.
            if(event.Code() == KEY_DOWN || event.Code() == KEY_UP)
            {
               int n = cursorLine.NLine();
               //����� ������ ��� �����������?
               if(ChildsTotal() > n+1 && event.Code() == KEY_DOWN)
               {
                  //���� ��������� ������� ������� ����� �� ��������.
                  if(visibleFirst + visibleCount <= n+1)
                     LineVisibleFirst(n+2 - visibleCount);
                  Line* nline = ChildElementAt(n+1);
                  MoveCursor(nline);
               }
               else if(n > 0 && event.Code() == KEY_UP)
               {
                  //���� ��������� ������� ������� ����� �� ��������.
                  if(n-1 < visibleFirst)
                     LineVisibleFirst(n-1);
                  Line* nline = ChildElementAt(n-1);
                  MoveCursor(nline);
               }
            }
            
            //���������� �������.
            if(event.Code() == KEY_ENTER)
            {
               ;
            }
         }
      }
      
      virtual void OnCommand(EventNodeCommand* event)
      {
         //������� ����� �� �����������.
         if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
         //printf("������� OnCommand...");
         OnCommand();
         return;
         int total = ChildsTotal();
         //������ ������������� ���������� �����, ������� ����� ������������
         //��� ������� ������� �������.
         long highTable = High();
         double lines = MathFloor(High()/20.0);
         //��������� ����������� ���������� �������������� �����?
         
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
            int n = (int)(lines - (dn_line + visibleCount));
            visibleFirst -= n;
         }
         //else visibleFirst = total - lines;
         for(int i = visibleFirst; i < total; i++)
            RefreshLine(i);
      }
      ///
      /// ��������� ����� �������� ��������� �������.
      ///
      void OnCommand()
      {
         int total = ChildsTotal();
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
            int n = (int)(lines - (dn_line + visibleCount));
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
};
