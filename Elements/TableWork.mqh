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
      /// Добавляет новую строку в конец таблицы и автоматически определяет ее размер и положение
      ///
      void Add(ProtoNode* lineNode)
      {
         Add(lineNode, ChildsTotal());
      }
      ///
      /// Добавляет новую строку таблицы по индексу pos
      ///
      void Add(ProtoNode* lineNode, int pos)
      {
         
         childNodes.Insert(lineNode, pos);
         lineNode.NLine(pos);
         //после вставки элемента, все последующие элементы изменили свои координаты.
         //uint tbegin = GetTickCount();
         //OnCommand();
         //printf("Add El: " + (string)(GetTickCount() - tbegin));
         /*int total = ChildsTotal();
         for(int i = pos; i < total; i++)
            RefreshLine(i);*/
      }
      ///
      /// Удаляет строку по индексу index из таблицы строк.
      ///
      void Delete(int index)
      {
         ProtoNode* line = ChildElementAt(index);
         EventVisible* vis = new EventVisible(EVENT_FROM_UP, GetPointer(this), false);
         line.Event(vis);
         delete vis;
         childNodes.Delete(index);
         //Все последующие элементы изменили свое положение
         for(int i = index; i < ChildsTotal(); i++)
            RefreshLine(i);
      }
      ///
      /// Удаляет диапазон строк из таблицы строк.
      /// \param index - индекс первой удаляемой строки.
      /// \param count - количество строк, которое надо удалить.
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
         //Все последующие элементы изменили свое положение
         for(int i = index; i < ChildsTotal(); i++)
            RefreshLine(i);
      }
      ///
      /// Обновляет координаты и размер линии по индексу index
      ///
      void RefreshLine(int index)
      {
         //Всего видимых элементов.
         int total = ChildsTotal();
         if(index < 0 || index >= total)return;
         //Получаем линию под номером index.
         ProtoNode* node = ChildElementAt(index);
         int nline = node.NLine();
         node.NLine(index);
         //Запоминаем видимость элемента
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
      /// Возвращает общую высоту всех линий в таблице.
      ///
      long LinesHighTotal()
      {
         return childNodes.Total()*20;
      }
      ///
      /// Возвращает общую высоту всех видимых линий в таблице.
      ///
      long LinesHighVisible()
      {
         return LinesVisible()*20;
      }
      ///
      /// Возвращает индекс первой видимой строки.
      ///
      int LineVisibleFirst(){return visibleFirst;}
      ///
      /// Возвращает количество видимых строк в таблице.
      ///
      int LinesVisible(){return visibleCount;}
      ///
      /// Возвращает общее количество видимых и невидимых строк в таблице.
      ///
      int LinesTotal(){return childNodes.Total();}
      ///
      /// Устанавливает первую линию, которую требуется отобразить.
      ///
      void LineVisibleFirst(int index)
      {               
         
         if(index == visibleFirst)return;
         // Скрывает нижние строки и отображает верхние.
         if(index < visibleFirst)
         {
            //Первая отображаемая линия не может выходить за пределы таблицы.
            if(index < 0 || index >= childNodes.Total()||
               index >= visibleFirst)return;
            visibleFirst = index;
            for(int i = visibleFirst; i < ChildsTotal(); i++)
               RefreshLine(i);
         }
         // Скрывает верхние строки и отображает нижние.
         if(index > visibleFirst)
         {
            if(index < 0 || LineVisibleFirst() == index ||
            index <= visibleFirst) return;
            //Ползунок перемещен вниз - скрываем верхние строки.
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
            //Передвигаем нижние.
            visibleFirst = index;
            for(; i < total; i++)
               RefreshLine(i);
         }
         //Позиционируем скролл, всякий раз после прокрутики таблицы.
         table.AllocationScroll();
      }
   private:
   
      virtual void OnEvent(Event* event)
      {
         //Видимость одной из строк таблицы изменилась?
         if(event.Direction() == EVENT_FROM_DOWN && event.EventId() == EVENT_NODE_VISIBLE)
            ChangeLineVisible(event);

         // Обрабатываем щелчок, по одной из строк
         if(event.Direction() == EVENT_FROM_DOWN && event.EventId() == EVENT_NODE_CLICK)
         {
            OnClickNode(event);
            EventSend(event);
         }
         
         // Обрабатываем нажатие клавиши.
         else if(event.EventId() == EVENT_KEYDOWN)
         {
            OnKeyPress(event);
            EventSend(event);
         }
         else
            EventSend(event);
      }
      ///
      /// Обработчик события "видимость одной из строк таблицы изменилась".
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
      /// Устанавливает курсор на строку таблицы, по которой
      /// был произведен щелчок.
      ///
      void OnClickNode(EventNodeClick* event)
      {
         //Если щелчок был произведен по строке содержащий фиксированный текст,
         //значит текущую строку надо подкрасить курсором.
         //В противном случае, произошло другое значимое событие, которое надо передать наверх.
         ProtoNode* node = event.Node();
         if(node.TypeElement() == ELEMENT_TYPE_LABEL)
         {
            Label* lab = node;
            //Включаем подсветку строки
            ProtoNode* parNode = lab.ParentNode();
            bool isConvert = parNode.TypeElement() == ELEMENT_TYPE_POSITION ||
            parNode.TypeElement() == ELEMENT_TYPE_DEAL;
            if(lab.ReadOnly() && isConvert)
               MoveCursor(parNode);
         }
      }
      ///
      /// Перемещает курсор на новую строку.
      /// \param newCursLine - новая линия, на которую нужно переместить курсор.
      ///
      void MoveCursor(Line* newCursLine)
      {
         if(CheckPointer(newCursLine) == POINTER_INVALID)return;
         Line* oldCursor = cursorLine;
         cursorLine = newCursLine;
         //Заменяем старый курсор на стандартный цвет
         if(CheckPointer(oldCursor) != POINTER_INVALID)
            InterlacingColor(oldCursor);
         ColorationBack(newCursLine, clrLightSteelBlue);
      }
      ///
      /// Обработчик события нажатия клавиши.
      ///
      void OnKeyPress(EventKeyDown* event)
      {
         // Клавиши могут перемещать курсор, если он есть,
         // а также раскрывать позицию под курсором.
         if(CheckPointer(cursorLine) != POINTER_INVALID)
         {
            // Перемещаем курсор вниз.
            if(event.Code() == KEY_DOWN || event.Code() == KEY_UP)
            {
               int n = cursorLine.NLine();
               //Конец списка еще недостигнут?
               if(ChildsTotal() > n+1 && event.Code() == KEY_DOWN)
               {
                  //Если требуется двигаем таблицу вслед за курсором.
                  if(visibleFirst + visibleCount <= n+1)
                     LineVisibleFirst(n+2 - visibleCount);
                  Line* nline = ChildElementAt(n+1);
                  MoveCursor(nline);
               }
               else if(n > 0 && event.Code() == KEY_UP)
               {
                  //Если требуется двигаем таблицу вслед за курсором.
                  if(n-1 < visibleFirst)
                     LineVisibleFirst(n-1);
                  Line* nline = ChildElementAt(n-1);
                  MoveCursor(nline);
               }
            }
            
            //Раскрываем позицию.
            if(event.Code() == KEY_ENTER)
            {
               ;
            }
         }
      }
      
      virtual void OnCommand(EventNodeCommand* event)
      {
         //Команды снизу не принимаются.
         if(!Visible() || event.Direction() == EVENT_FROM_DOWN)return;
         //printf("Вызываю OnCommand...");
         OnCommand();
         return;
         int total = ChildsTotal();
         //Узнаем потенциальное количество строк, которое может разместиться
         //при текущем размере таблице.
         long highTable = High();
         double lines = MathFloor(High()/20.0);
         //Появилась возможность отобразить дополнительные линии?
         
         //Если теперь все линии вмещаются в таблицу - 
         //отображаем их все.
         if(total <= lines)
         {
            visibleFirst = 0;
            for(int i = visibleFirst; i < total; i++)
               RefreshLine(i);
            return;
         }
         //Иначе, считаем линии, для которых не осталось места
         int dn_line = total - (visibleFirst + visibleCount);
         //Можно также отобразить часть нижних линий
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
      /// Размещает линии согласно алгоритму таблицы.
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
         //Иначе, считаем линии, для которых не осталось места
         int dn_line = total - (visibleFirst + visibleCount);
         //Можно также отобразить часть нижних линий
         if(visibleCount + dn_line < lines)
         {
            int n = (int)(lines - (dn_line + visibleCount));
            visibleFirst -= n;
         }
         for(int i = visibleFirst; i < total; i++)
            RefreshLine(i);
      }
      ///
      /// Нечетные строки подкрашиваются в более темный оттенок.
      ///
      void InterlacingColor(ProtoNode* nline)
      {
         color clrBack;
         //Выделенную строку под курсором не перекрашиваем.
         bool checkPoint = CheckPointer(cursorLine) != POINTER_INVALID &&
                           CheckPointer(nline) != POINTER_INVALID;
         if(checkPoint && nline == cursorLine)return;
         if((nline.NLine()+1) % 2 == 0)
            clrBack = clrWhiteSmoke;
         else clrBack = clrWhite;
         ColorationBack(nline, clrBack);
      }
      ///
      /// Раскрашивает фон дочерних элементов nline в указанный цвет.
      ///
      void ColorationBack(ProtoNode* nline, color clrBack)
      {
         
         for(int i = 0; i < nline.ChildsTotal(); i++)
         {
            ProtoNode* node = nline.ChildElementAt(i);
            //Вложенные элементы обрабатываем рекурсивно
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
      /// Количество видимых строк, которые в данный момент отображаются
      /// в таблице.
      ///
      int visibleCount;
      ///
      /// Индекс первого видимого элемента.
      ///
      int visibleFirst;
      ///
      /// Общая высота всех видимых элементов.
      ///
      long highTotal;
      ///
      /// Содержит на строку, которая в данный момент находится под курсором.
      ///
      Line* cursorLine;
      ///
      /// Указатель на родительскую таблицу.
      ///
      Table* table;
};
