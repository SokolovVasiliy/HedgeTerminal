
///
/// Идентификатор указывающий на алгоритм выравнивания элементов в горизонтальном или вертикальном контейнере.
///
enum ENUM_LINE_ALIGN_TYPE
{
   ///
   /// Масштабирование на основе рекомендованной ширины/высоты элемента.
   ///
   LINE_ALIGN_SCALE,
   ///
   /// Масштабирование обычной ячейки.
   ///
   LINE_ALIGN_CELL,
   ///
   /// Мастшабирование ячейки таблицы содержащую кнопки.
   ///
   LINE_ALIGN_CELLBUTTON,
   ///
   /// Равномерное распределение общей ширины/высоты контейнера между всеми элементами.
   ///
   LINE_ALIGN_EVENNESS
};
///
/// Горизонтальный вектор.
///
class Line : public ProtoNode
{
   public:
      Line(string myName, ProtoNode* parNode):ProtoNode(OBJ_EDIT, ELEMENT_TYPE_GCONTAINER, myName, parNode)
      {
         clearance = 1;
         BorderColor(clrWhite);
         OptimalHigh(20);
         typeAlign = LINE_ALIGN_SCALE;
      }
      Line(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode):ProtoNode(OBJ_EDIT, elType, myName, parNode)
      {
         clearance = 1;
         BorderColor(clrWhite);
         OptimalHigh(20);
         typeAlign = LINE_ALIGN_SCALE;
      }
      ///
      /// Устанавливает алгоритм выравнивания для элементов внутри линии.
      ///
      void AlignType(ENUM_LINE_ALIGN_TYPE align)
      {
         typeAlign = align;
      }
      ///
      /// Возвращает идентификатор алгоритма выравнивания элементов внутри линии.
      ///
      ENUM_LINE_ALIGN_TYPE AlignType()
      {
         return typeAlign;
      }
      ///
      /// Добавляет узел в строковый контейнер.
      ///
      void Add(ProtoNode* node)
      {  
         childNodes.Add(node);
      }
      ///
      /// Устанавливает высоту текущей линии.
      ///
      void HighLine(long curHigh)
      {
         Resize(Width(), curHigh);
         //EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
      }
      ///
      /// Устанавливает ширину текущей линии.
      ///
      void WidthLine(long curWidth)
      {
         Resize(curWidth, High());
      }
      ///
      /// Передвигает линию на новые координаты.
      ///
      void MoveLine(long xdist, long ydist, ENUM_COOR_CONTEXT context = COOR_LOCAL)
      {
         Move(xdist, ydist, context);
      }
      ///
      /// Устанавливает видимость линии.
      ///
      void VisibleLine(bool isVisible)
      {
         Visible(isVisible);
      }
      ///
      /// Устанавливает зазор между элементами строки.
      ///
      void Clearance(int clr)
      {
         clearance = clr;
      }
      ///
      /// Возвращает зазор между элементами.
      ///
      int Clearance(){return clearance;}
      
   private:
      virtual void OnVisible(EventVisible* event)
      {
         if(parentNode != NULL && parentNode.TypeElement() ==
            ELEMENT_TYPE_WORK_AREA)
         {
            //Не забываем удалить/восстановить дочерние элементы
            EventSend(event);
            // Теперь даем сигнал родительскому элементу, что текущая линия поменяла
            // свой статус видимости.
            EventVisible* vis = new EventVisible(EVENT_FROM_DOWN, event.Node(), event.Visible());
            parentNode.Event(vis);
            delete vis;
            //if(event.Visible())
            //   printf(ShortName() + " ON.");
            //else printf(ShortName() + " OFF.");
         }
         else
            EventSend(event);
      }
      ///
      /// Положение и размер контейнера изменились.
      ///
      virtual void OnCommand(EventNodeCommand* newEvent)
      {
         if(!Visible() || newEvent.Direction() == EVENT_FROM_DOWN)return;
         string cname = ShortName();
         switch(typeAlign)
         {
            case LINE_ALIGN_CELL:
            case LINE_ALIGN_CELLBUTTON:
               AlgoCellButton();
               break;
            default:
               AlgoScale();
               break;
         }
      }
      
      ///
      /// Алгоритм масштабирования на основе рекомендованной ширины/высоты элемента.
      ///
      void AlgoScale()
      {
         //Положение подузла по горизонтали, относительно текущего узла.
         //Зазор между соседними элементами в пикселях, 0 - когда зазора нет.
         
         int total = childNodes.Total();
         long xdist = 0;
         ProtoNode* prevColumn = NULL;
         ProtoNode* node = NULL;
         long kBase = 1250;
         //Коэффициент масштабируемости.
         double kScale = (double)Width()/(double)kBase;
         for(int i = 0; i < total; i++)
         {
            node = childNodes.At(i);
            string sname = node.ShortName();
            //рассчитываем текущую привязку по горизонтали.
            xdist = i > 0 ? prevColumn.XLocalDistance() + prevColumn.Width() : 0;
            //Последний элемент занимает все оставшееся место
            long cwidth = 0;
            ProtoNode* bindWidth = node.BindingWidth();
            //Если ширина привязана к другому узлу - берем ее с того узла.
            if(bindWidth != NULL)
               cwidth = bindWidth.Width();
            //Если ширина является константой - не изменяем ее.
            else if(node.ConstWidth())
               cwidth = node.OptimalWidth();
            else
               cwidth = i == total-1 ? cwidth = Width() - xdist - clearance : (long)MathRound((double)node.OptimalWidth() * kScale) - clearance;
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist + clearance, 0, cwidth, High());
            node.Event(command);
            delete command;
            prevColumn = node;
         }
      }
      ///
      /// Алгоритм позиционирования элементов "ячейка с кнопками"
      ///
      void AlgoCellButton()
      {
         //В этом режиме подразумевается, что содержимое состоит из узлов, часть из которых - квадратные кнопки.
         int total = childNodes.Total()-1;
         long xdist = Width();
         long chigh = High();
         //Перебираем элементы в обратном порядке, т.к. кнопки идут самыми последними
         for(int i = total; i >= 0; i--)
         {
            ProtoNode* node = childNodes.At(i);
            ENUM_ELEMENT_TYPE type = node.TypeElement();
            /*bindWidth = node.BindingWidth();
            if(bindWidth != NULL)
            {
               ;
            }*/
            if(node.TypeElement() == ELEMENT_TYPE_BOTTON)
            {
               xdist -= chigh;
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist, 0, chigh, chigh);
               node.Event(command);
               delete command;
            }
            else
            {
               //Средняя ширина элемента
               long avrg = (long)MathRound((double)xdist/(double)(total));
               xdist -= avrg;
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), xdist, 0, avrg, chigh);
               node.Event(command);
               delete command;
            }
         }
      }
      ///
      /// Идентификатор алгоритма выравнивания в линии.
      ///
      ENUM_LINE_ALIGN_TYPE typeAlign;
      ///
      /// Элемент, к чьей ширене необходимо привязать ширину текущего элемента.
      ///
      ProtoNode* bindingWidth;
      ///
      /// Элемент, к чьей высоте необходимо привязать высоту текущего элемента.
      ///
      ProtoNode* bindingHigh;
      ///
      /// Содержит зазор между соседними элементами.
      ///
      int clearance;
};
