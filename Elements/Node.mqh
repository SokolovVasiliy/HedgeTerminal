
#include <Arrays\ArrayObj.mqh>
///
/// Тип элемента графического интерфейса.
///
enum ENUM_ELEMENT_TYPE
{
   ///
   /// Элемент графического интерфейса "Форма".
   ///
   ELEMENT_TYPE_FORM,
   ///
   /// Элемент графического интерфейса "Таблица".
   ///
   ELEMENT_TYPE_TABLE,
   ///
   /// Элемент графического интерфейса "Заголовок формы".
   ///
   ELEMENT_TYPE_FORM_HEADER,
   ///
   /// Элемент графического интерфейса "Кнопка".
   ///
   ELEMENT_TYPE_BOTTON,
   ///
   /// Элемент графического интерфейса "Вкладка".
   ///
   ELEMENT_TYPE_TAB,
   ///
   /// Элемент графического интерфейса "Заголовок колонки таблицы".
   ///
   ELEMENT_TYPE_HEAD_COLUMN,
   ///
   /// Элемент графического интерфейса "Горизонтальный контейнер".
   ///
   ELEMENT_TYPE_GCONTAINER,
   ///
   /// Элемент графического интерфейса "Вертикальный контейнер".
   ///
   ELEMENT_TYPE_VCONTAINER,
   ///
   /// Элемент графического интерфейса "Универсальный контейнер".
   ///
   ELEMENT_TYPE_UCONTAINER,
   ///
   /// Элемент графического интерфейса "Позунок".
   ///
   ELEMENT_TYPE_SCROLL,
   ///
   /// Элемент графического интерфейса "Текстовая метка".
   ///
   ELEMENT_TYPE_LABEL,
   ///
   /// Элемент графического интерфейса "Ячейка таблицы".
   ///
   ELEMENT_TYPE_CELL,
   ///
   /// Элемент графического интерфейса "Раскрывающаяся таблица".
   ///
   ELEMENT_TYPE_TREE_VIEW,
   ///
   /// Оформление раскрывающегося списка.
   ///
   ELEMENT_TYPE_TREE_BORDER,
   ///
   /// Строковое представление позиции.
   ///
   ELEMENT_TYPE_POSITION,
   ///
   /// Строковое представление сделки.
   ///
   ELEMENT_TYPE_DEAL,
   ///
   /// Элемент графического интерфейса направляющая ползунка скрола.
   ///
   ELEMENT_TYPE_TODDLER,
   ///
   /// Элемент графического интерфейса ползунок скрола.
   ///
   ELEMENT_TYPE_LABTODDLER,
   ///
   /// Элемент графического интерфейса тело таблицы.
   ///
   ELEMENT_TYPE_WORK_AREA
};


class ProtoNode : public CObject
{
   public:
      ENUM_ELEMENT_TYPE TypeElement(){return elementType;}   
      ///
      /// Принимаем событие и обрабатываем его в соответсвтии с правилами
      /// определенными в классе-потомке. 
      ///
      void Event(Event* event)
      {
         if(event.Direction() == EVENT_FROM_UP)
         {
            switch(event.EventId())
            {
               case EVENT_NODE_MOVE:
                  Move(event);
                  break;
               case EVENT_NODE_RESIZE:
                  Resize(event);
                  break;
               case EVENT_NODE_VISIBLE:
                  Visible(event);
                  break;
               case EVENT_NODE_COMMAND:
                  ExecuteCommand(event);
                  break;
               //Нажатие на объект
               case EVENT_PUSH:
                  Push(event);
                  break;
               case EVENT_REDRAW:
                  Redraw(event);
                  break;
               case EVENT_DEINIT:
                  OnDeinit(event);
                  Deinit(event);
                  break;
               //Все события о которых мы не знаем - делегируем потомкам.
               default:
                  OnEvent(event);
            }
         }
         else
            OnEvent(event);
      }
      virtual void OnDeinit(EventDeinit* event){;}
      ///
      /// Возвращает ширину графического узла в пунктах.
      /// \return Высота графического узла в пунктах.
      ///
      long Width(){return width;}
      ///
      /// Возвращает высоту графического узла в пунктах.
      /// \return Ширина графического узла в пунктах.
      ///
      long High(){return high;}
      ///
      /// Возвращает оптимальную ширину графического элемента.
      ///
      long OptimalWidth()
      {
         if(CheckPointer(bindingWidth) != POINTER_INVALID)
            return bindingWidth.OptimalWidth();
         return optimalWidth;
      }
      ///
      /// Возвращает оптимальную высоту графического элемента.
      ///
      long OptimalHigh()
      {
         if(CheckPointer(bindingHigh) != POINTER_INVALID)
            return bindingHigh.OptimalHigh();
         return optimalHigh;
      }
       
      void OptimalWidth(long optWidth)
      {
         //if(bindingWidth != NULL)
         //   bindingWidth.OptimalWidth(optWidth);
         if(bindingWidth == NULL)
            optimalWidth = optWidth;
      }
      
      void OptimalHigh(long optHigh)
      {
         //if(bindOptHigh != NULL)
         //   bindOptHigh.OptimalHigh(optHigh);
         if(bindingHigh == NULL)
            optimalHigh = optHigh;
      }
      void ConstWidth(bool status)
      {
         constWidth = status;
      }
      bool ConstWidth()
      {
         return constWidth;
      }
      void ConstHigh(bool status)
      {
         constHigh = status;
      }
      bool ConstHigh(){return constHigh;}
      ///
      /// Привязать ширину элемента к ширене другого элемента.
      ///
      void BindingWidth(ProtoNode* node)
      {
         if(CheckPointer(node) != POINTER_INVALID)
            bindingWidth = node;
      }
      ///
      /// Возвращает узел, к чьей ширине привязан текущий узел. Возвращает NULL,
      /// если ширина текущего узла не привяна к ширине другого узла.
      ///
      ProtoNode* BindingWidth()
      {
         return bindingWidth;
      }
      ///
      /// Привязать высоту элемента к высоте другого элемента.
      ///
      void BindingHigh(ProtoNode* node)
      {
         if(CheckPointer(node) != POINTER_INVALID)
            bindingHigh = node;
      }
      ///
      /// Возвращает узел, к чьей высоте привязан текущий узел. Возвращает NULL,
      /// если высота текущего узла не привяна к высоте другого узла.
      ///
      ProtoNode* BindingHigh()
      {
         return bindingHigh;
      }
      ///
      /// Отвязывает ширину текущего элемента от ширины другого элемента 
      ///
      void UnbindingWidth()
      {  
         bindingWidth = NULL;
      }
      ///
      /// Отвязывает высоту текущего элемента от высоты другого элемента
      ///
      void UnbindingHigh()
      {
         bindingHigh = NULL;
      }
      ///
      /// Возвращает количество подузлов, входящее в графический элемент.
      ///
      int ChildsTotal()
      {
         return childNodes.Total();
      }
      ///
      /// Возвращает ссылку на дочерний элемент под номером n
      ///
      ProtoNode* ChildElementAt(int n)
      {
         ProtoNode* node = childNodes.At(n);
         return node;
      }
      ///
      /// Вставляет графический узел на позицию pos в списке графических элементов
      ///
      /*void InsertElement(ProtoNode* node, int pos)
      {         
         //node
         childNodes.Insert(node, pos);
      }*/
      ///
      /// Удаляет графический элемент из списка элементов, находящийся 
      /// на позиции index.
      ///
      /*void DeleteElement(int index)
      {
         childNodes.Delete(index);
      }*/
      ///
      /// Возвращает статус видимости графического узла.
      /// \return Истина, если графический узел отображается в окне терминала,
      /// ложь - в противном случае.
      ///
      bool Visible(){return visible;}
      ///
      /// Возвращает статус видимости родительского элемента.
      /// Если родительского элемента нет - возвращает истину.
      /// \return Истина, если родительский элемент виден, ложь в противном случае.
      ///
      bool ParVisible()
      {
         if(parentNode != NULL)
            return parentNode.Visible();
         //Окно терминала по определению всегда видимо.
         else return true;
      }
      ///
      /// Возвращает уникальный строковой идентификатор графического узла.
      /// \return Уникальный строковой идентификатор графического узла.
      ///
      string NameID(){return nameId;}
      ///
      /// Возвращает расстояние по горизонтали между левой стороной текущего узла и
      /// левой стороной родительского узла. Если родительского узла нет,
      /// возвращает абсолютное растояние до левой стороны окна терминала.
      /// \return Расстояние в пунктах по оси X.
      ///
      long XLocalDistance()
      {
         return xDist - XAbsParDistance();
      }
      ///
      /// Возвращает расстояние по вертикали между верхней стороной текущего узла и
      /// верхней стороной родительского узла. Если родительского узла нет,
      /// возвращает абсолютное растояние до верхней стороны окна терминала.
      /// \return Расстояние в пунктах по оси Y.
      ///
      long YLocalDistance()
      {
         return yDist - YAbsParDistance();
      }
      ///
      /// Возвращает абсолютное расстояние по горизонтали между левой стороной текущего узла и
      /// левой стороной окна терминала.
      /// \return Расстояние в пунктах по оси X.
      ///
      long XAbsDistance()
      {
         return xDist;
      }
      ///
      /// Возвращает абсолютное расстояние по вертикали между верхней стороной текущего узла и
      /// верхней стороной окна терминала.
      /// \return Расстояние в пунктах по оси Y.
      ///
      long YAbsDistance()
      {
         return yDist;
      }
      ///
      /// Возвращает абсолютное расстояние по горизонтали в пунктах от левой стороны
      /// родительского графического узла до левой стороны окна терминала.
      /// Если родительского узла нет - возвращает 0.
      /// \return Расстояние в пунктах по оси X.
      ///
      long XAbsParDistance()
      {
         if(parentNode != NULL)
            return parentNode.XAbsDistance();
         return 0;
      }
      ///
      /// Возвращает абсолютное расстояние по вертикали в пунктах от верхней стороны
      /// родительского графического узла до верхней стороны окна терминала.
      /// Если родительского узла нет - возвращает 0.
      /// \return Расстояние в пунктах по оси X.
      ///
      long YAbsParDistance()
      {
         if(parentNode != NULL)
            return parentNode.YAbsDistance();
         return 0;
      }
      ///
      /// Возвращает ширину родительского графического узла. Если родительский
      /// графический узел не задан - возвращает 0.
      ///
      long ParWidth()
      {
         if(parentNode != NULL)
            return parentNode.Width();
         //Подразумевается что окно терминала имеет ширину 32667 пикселей.
         else return SHORT_MAX;
      }
      ///
      /// Возвращает высоту родительского графического узла. Если родительский
      /// графический узел не задан - возвращает 0.
      ///
      long ParHigh()
      {
         if(parentNode != NULL)
            return parentNode.High();
         //Подразумевается что окно терминала имеет высоту 32667 пикселей.
         else return SHORT_MAX;
      }
      ///
      /// Возварщает короктое имя узла.
      ///
      string ShortName(){return shortName;}
      ///
      /// Возвращает имя графического узла.
      /// \retrurn name - Имя графического узла.
      ///
      string Name(){return name;}
      ///
      /// Конструктор объекта.
      /// \param mytype - Тип графического объекта, лежащего в основе графического узла.
      /// \param myclassName - Класс, к которому принадлежит графический узел.
      /// \param myname - Название графического узла.
      /// \param parNode - Родительский узел, внутри которого располагается текущий узел.
      ///

      ProtoNode(ENUM_OBJECT mytype, ENUM_ELEMENT_TYPE myElementType, string myname, ProtoNode* parNode)
      {
         Init(mytype, myElementType, myname, parNode);
      }
      
      ProtoNode(ENUM_OBJECT mytype, ENUM_ELEMENT_TYPE myElementType, string myname, ProtoNode* parNode, long optWidth, long optHigh)
      {
         Init(mytype, myElementType, myname, parNode);
         optimalWidth = optWidth;
         optimalHigh = optHigh;
         Resize(optHigh, optHigh);
      }
      ///
      /// Устанавливает цвет заднего фона.
      ///
      void BackgroundColor(color clr)
      {
         bgColor = clr;
         if(visible)
            ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_BGCOLOR, bgColor);
      }
      ///
      /// Возвращает цвет заднего фона.
      ///
      color BackgroundColor()
      {
         return bgColor;
      }
      ///
      /// Устанавливает цвет рамки текстовой метки.
      ///
      void BorderColor(color clr)
      {
         borderColor = clr;
         if(visible)
            ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_BORDER_COLOR, borderColor);
      }
      ///
      /// Возвращает цвет рамки текстовой метки.
      ///
      color BorderColor()
      {
         return borderColor;
      }
      ///
      /// Тип рамки для объекта "Прямоугольная рамка".
      ///
      void BorderType(ENUM_BORDER_TYPE bType)
      {
         borderType = bType;
         //Это свойство поддерживает только прямоугольная рамка.
         if(visible && typeObject == OBJ_RECTANGLE_LABEL)
            ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_BORDER_TYPE, borderType);
      }
      ///
      /// Возвращает номер строки в списке дочерних элементов.
      ///
      int NLine()
      {
         //Если n-line не заполнен узнаем номер строки через перебор
         if(n_line == -1)
         {
            if(parentNode == NULL)
            {
               n_line = 0;
               return n_line;
            }
            else
            {
               int total = parentNode.ChildsTotal();
               for(int i = 0; i < total; i++)
               {
                  ProtoNode* node = parentNode.ChildElementAt(i);
                  // Идентификация узла по уникальному имени.
                  if(this.NameID() == node.NameID())
                  {
                     n_line = i;
                     return n_line;
                  }
               }
            }
         }
         return n_line;
      }
      ///
      /// Устанавливает номер строки в списке дочерних элементов.
      ///
      void NLine(int n)
      {
         
         if(n < 0)
         {
            n_line = -1;
         }
         else
         {
            if(parentNode.ChildElementAt(n) != GetPointer(this))
               printf("Устанавливаемый номер не равен фактическому!!!!");
            n_line = n;
         }
      }
   protected:
      ///
      /// Вовращает истину, если обект находится под курсором мыши,
      /// и ложь в противном случе.
      ///
      bool IsMouseSelected(EventMouseMove* event)
      {
         long x = event.XCoord();
         long xAbs = XAbsDistance();
         if(x > xAbs + Width() || x < xAbs)return false;
         long y = event.YCoord();
         long yAbs = YAbsDistance();
         if(y > yAbs + High() || y < yAbs)return false;
         return true;   
      }
      ///
      /// Переопределяемый прием событий.
      ///
      virtual void OnEvent(Event* event){EventSend(event);}
      virtual void OnVisible(EventVisible* event){EventSend(event);}
      virtual void OnResize(EventResize* event)
      {
         int total = childNodes.Total();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = childNodes.At(i);
            EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), node.Width(), node.High());
            node.Event(er);
            delete er;
         }
      }
      virtual void OnMove(EventMove* event)
      {
         int total = childNodes.Total();
         for(int i = 0; i < total; i++)
         {
            ProtoNode* node = childNodes.At(i);
            EventMove* em = new EventMove(EVENT_FROM_UP, NameID(), node.XAbsDistance(), node.YAbsDistance(), COOR_GLOBAL);
            node.Event(em);
            delete em;
         }   
      }
      virtual void OnCommand(EventNodeCommand* event){;}
      ///
      /// Каждый потомок должен самостоятельно определить свои действия,
      /// при нажатии на свой объект.
      ///
      virtual void OnPush(){;}
      ///
      /// По умолчанию обновляем все элементы рекурсивно.
      ///
      virtual void OnRedraw(EventRedraw* event){EventSend(event);}
      
      void Resize(EventResize* event)
      {
         Resize(event.NewWidth(), event.NewHigh());
      }
      ///
      /// Устанавливает новый размер текущего графического узла.
      /// \return Истина, если размер графического узла был установлен на новый, ложь
      /// в противном случае.
      ///
      bool Resize(long newWidth, long newHigh)
      {
         // 1) Проверяем, являются ли новые желаемые размеры допустимыми,
         // Не будет ли выходить текущий графический узел за пределы
         // границ родительского узла.
         //Высота не может превышать нижней границы родительского окна.
         if(YAbsParDistance() + ParHigh() < YAbsDistance() + newHigh)
         {
            //Иначе корректируем высоту на предельно допустимую
            newHigh = (YAbsParDistance() + ParHigh()) - YAbsDistance();
         }
         //Ширина не может превышать правой границы родительского окна.
         if(XAbsParDistance() + ParWidth() < XAbsDistance() + newWidth)
         {
            //Иначе корректируем высоту на предельно допустимую
            newWidth = (XAbsParDistance() + ParWidth()) - XAbsDistance();
         }
         // Если размер все равно отрицателен, либо равен нулю - то элемент не видим.
         if((newHigh <= 0 || newWidth <= 0) && Visible())
            Visible(false);

         // 2) Переразмечаем графический узел, если он отображается в окне терминала.
         if(visible)
         {
            if(!ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE, newWidth))
            {
               LogWriter("Failed resize element " + nameId + " by horizontally.", MESSAGE_TYPE_ERROR);
               newWidth = ObjectGetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE);
            }
            if(!ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE, newHigh))
            {
               LogWriter("Failed resize element " + nameId + " by verticaly.", MESSAGE_TYPE_ERROR);
               newHigh = ObjectGetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE);
            }
         }
         int k = 5;
         if(width != newWidth)
            k = 6;
         width = newWidth;
         high = newHigh;
         if(nameId == NULL || nameId == "")
            GenNameId();
         EventResize* er = new EventResize(EVENT_FROM_UP, NameID(), Width(), High());
         OnResize(er);
         delete er;
         
         return true;
      }
      ///
      /// Переразмечает графический узел.
      /// \param UpBorder - Расстояние между верхней границей графического узла и верхней границей родительского графического узла.
      /// \param LeftBorder - Расстояние между левой границей графического узла и левой границей родительского графического узла.
      /// \param RightBorder - Расстояние между правой границей графического узла и правой границей родительского графического узла.
      /// \param DnBorder - Расстояние между нижней границей графического узла и нижней границей родительского графического узла.
      ///
      bool Resize(long UpBorder, long LeftBorder, long DnBorder, long RightBorder)
      {
         Move(LeftBorder, UpBorder);
         //Зная границы графического объекта, можно рассчитать его размер аналитически.
         long newWidth = ParWidth() - LeftBorder - RightBorder;
         long newHigh = ParHigh() - UpBorder - DnBorder;
         return Resize(newWidth, newHigh);
      }
      void Visible(EventVisible* event)
      {
         Visible(event.Visible());
      }
      ///
      /// Устанавливает видимость графического узла.
      /// \param status - Истина, если требуется отобразить графический узел в окне терминала,
      /// ложь - в противном случае.
      /// \return Истина, если смена видимости графического узла прошла успешно, ложь -
      /// в противном случае.
      bool Visible(bool status)
      {
         // Включаем визуализацию.
         if(!visible && status)
         {
            // Размеры должны быть значимыми.
            if(width <= 0 || high <= 0)
               return false;
            // 1. Узел не может располагаться выше верхней границы родительского узла.
            if (yDist < YAbsParDistance())
            {
                //LogWriter("Y-coordinate of node must be leter Y-coordinate parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 2. Узел не может располагаться ниже нижней границы родительского узла.
            if (yDist + High() > YAbsParDistance() + ParHigh())
            {
                long ypar = YAbsParDistance();
                long hpar = ParHigh();
                //LogWriter("Node position must be biger down line parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 3. Узел не может быть левей левой границы родительского узла.
            if (XAbsDistance() < XAbsParDistance())
            {
                //LogWriter("X-coordinate of node must be leter X-coordinate parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 4. Узел не может быть правей правой границы родительского узла.
            if (XAbsDistance() + Width() > XAbsParDistance() + ParWidth())
            {
                //LogWriter("Node position must be biger left line parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            //Генерируем новое имя всякий раз когда требуется отобразить элемент, гарантируя его уникальность.
            GenNameId();
            visible = ObjectCreate(MAIN_WINDOW, nameId, typeObject, MAIN_SUBWINDOW, XAbsDistance(), YAbsDistance());
            if(!visible)
               LogWriter("Failed visualize element " + nameId, MESSAGE_TYPE_ERROR);
            else
            {
               //Устанавливаем оформление по-умолчанию.
               BackgroundColor(bgColor);
               BorderColor(borderColor);
               BorderType(borderType);
               Move(xDist, yDist, COOR_GLOBAL);
               Resize(width, high);
               //
               EventVisible* ev = new EventVisible(EVENT_FROM_UP, GetPointer(this), visible);
               //printf(ShortName() + " ON.");
               OnVisible(ev);
               delete ev;
            }
         }
         // Выключаем визуализацию.
         if(Visible() && !status)
         {
            //printf(ShortName() + " OFF.");
            visible = !ObjectDelete(MAIN_WINDOW, nameId);
            //Уведомляем дочерние элементы.
            EventVisible* ev = new EventVisible(EVENT_FROM_UP, GetPointer(this), visible);
            OnVisible(ev);
            delete ev;
         }
         return visible;
      }
      void Move(EventMove* event)
      {
         Move(event.XDist(), event.YDist(), event.Context());
      }
      ///
      /// Передвигает графический узел на новое место, задаваемое координатами по осям X и Y.
      /// После перемещения на новые графические координаты, графический узел не должен выходить
      /// за пределы родительского графического узла.
      /// \param xCoordinate - Количество пикселей от левого верхнего угла графического узла, до
      /// верхнего левого угла окна терминала по горизонтальной оси.
      /// \param yCoordinate - Количество пикселей от левого верхнего угла графического узла, до
      /// верхнего левого угла окна терминала по горизонтальной оси.
      /// \param contex - Контекст переданных координат. 
      /// \return Истина, если передвижение прошло успешно, ложь в противном случае.
      ///
      bool Move(long xCoordinate, long yCoordinate, ENUM_COOR_CONTEXT context = COOR_LOCAL)
      {
         //Переводим относительные координаты в абсолютные.
         if(context == COOR_LOCAL)
         {
            long xAbsPar = XAbsParDistance();
            long yAbsPar = YAbsParDistance();
            long xLocal = XLocalDistance();
            long yLocal = YLocalDistance();
            xCoordinate = xCoordinate + xAbsPar/* + (XLocalDistance() - xAbsPar)*/;
            yCoordinate = yCoordinate + yAbsPar/* + (YLocalDistance() - yAbsPar)*/;
         }
         // 1. Узел не может располагаться выше верхней границы родительского узла.
         if (yCoordinate < YAbsParDistance())
         {
             // Иначе корректируем его Y координату
             yCoordinate = YAbsParDistance();
         }
         // 2. Узел не может располагаться ниже нижней границы родительского узла.
         if (yCoordinate + High() > YAbsParDistance() + ParHigh())
         {
             //Иначе корректируем высоту текущего узла
             //Рассчитаем предельно допустимую высоту объекта при заданной Y координате
             long newHigh = (YAbsParDistance() + ParHigh()) - yCoordinate;
             //Если Y координата слишком большая, что бы объект мог хотя бы частично поместиться
             //на родительской форме, то удаляем объект с графика.
             if (newHigh <= 0)
                 Visible(false);
             Resize(Width(), newHigh);
         }
         // 3. Узел не может быть левей левой границы родительского узла.
         if (xCoordinate < XAbsParDistance())
         {
             // Иначе корректируем его X координату
             xCoordinate = XAbsParDistance();
         }
         // 4. Узел не может быть правей правой границы родительского узла.
         if (xCoordinate + Width() > XAbsParDistance() + ParWidth())
         {
             //Иначе корректируем ширину текущего узла
             //Рассчитаем предельно допустимую ширину объекта при заданной X координате
             long newWidth = (XAbsParDistance() + ParWidth()) - xCoordinate;
             //Если Y координата слишком большая, что бы объект мог хотя бы частично поместиться
             //на родительской форме, то удаляем объект с графика.
             if (newWidth <= 0)
                 Visible(false);
             Resize(newWidth, High());
         }
         
         xDist = xCoordinate;
         yDist = yCoordinate;
         // Фактически перемещаем узел только в том случае, если он отображается.
         bool res = true;
         if(Visible())
         {
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE, xDist))
            {
               LogWriter("Failed move element " + nameId, MESSAGE_TYPE_ERROR);
               res = false;
               xDist = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE);
            }
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_YDISTANCE, yDist))
            {
               LogWriter("Failed move element " + nameId, MESSAGE_TYPE_ERROR); 
               res = false;
               yDist = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_YDISTANCE);
            }
         }
         if(nameId == NULL || nameId == "")
            GenNameId();
         EventMove* em = new EventMove(EVENT_FROM_UP, nameId, XAbsDistance(), YAbsDistance(), COOR_GLOBAL);
         OnMove(em);
         delete em;
         return res;
      }
      ///
      /// Посылает копии переданного события в направлении, указанном в его типе. 
      /// \param event - Событие, которое требуется отослать.
      ///
      void EventSend(Event* event)
      {
         //Событие идет сверху-вниз.
         if(event.Direction() == EVENT_FROM_UP)
         {
            ProtoNode* node;
            for(int i = 0; i < childNodes.Total(); i++)
            {
               node = childNodes.At(i);
               //Клонируем событие для каждого подузла
               //Event* ev = event.Clone();
               node.Event(event);
               //delete ev;
            }
            // ? Оригинальное событие утилизируем.
            //delete event;
         }
         //Событие идет снизу-вверх.
          if(event.Direction() == EVENT_FROM_DOWN)
         {
            if(parentNode != NULL)
               parentNode.Event(event);
         }
      }
      ///
      /// Вызывается при деинициализации объекта
      ///
      virtual void Deinit(EventDeinit* event)
      {
         for(int i = 0; i < childNodes.Total(); i++)
         {
            ProtoNode* node = childNodes.At(i);
            node.Event(event);
            delete node;
         }
         childNodes.Shutdown();
         Visible(false);
      }
      ///
      /// Перемещает текущий элемент на новые координаты и изменяет его размеры
      /// в соответствии с командой-событием.
      ///
      void ExecuteCommand(EventNodeCommand* newEvent)
      {
         Move(newEvent.XDist(), newEvent.YDist());
         Resize(newEvent.Width(), newEvent.High());
         Visible(newEvent.Visible());
         OnCommand(newEvent);
      }
      void Push(EventPush* push)
      {
         if(push.PushObjName() == NameID())
         {
            OnPush();
            ChartRedraw();
         }
         else
            EventSend(push);
      }
      void Redraw(EventRedraw* event)
      {
         //Команда актуальна только для видимых элементов
         if(Visible())
         {
            ChartRedraw(MAIN_WINDOW);
            OnRedraw(event);
         }
      }
      ///
      /// Указатель на родительский графический узел.
      ///
      ProtoNode *parentNode;
      ///
      /// Дочерние графические узлы.
      ///
      CArrayObj childNodes;
      ///
      /// Тип объекта, лежащего в основе узла.
      ///
      ENUM_OBJECT typeObject;
      
      ///
      /// Тип элемента графического интерфейса, к которому принадлежит графический узел. 
      ///
      ENUM_ELEMENT_TYPE elementType;
   private:
      ///
      /// Указатель на другой узел, чью оптимальную ширину надо получить.
      ///
      ProtoNode* bindingWidth;
      ///
      /// Указатель на другой узел, чью оптимальную высоту надо получить.
      ///
      ProtoNode* bindingHigh;
      ///
      /// Полное имя графического узла, состоящее из последовательности имен предыдущих узлов и текущего имени узла.
      ///
      string name;
      ///
      /// Имя графического узла, дающее представление о его назначении. Например:
      /// "GeneralForm" или "TableOfOpenPosition".
      ///
      string shortName;
      ///
      /// Уникальное имя-идентификатор графического узла.
      ///
      string nameId;
      ///
      /// Содержит статус видимости графического узла. Истина, если
      /// графический узел отображается в окне терминала и ложь в 
      /// противном случае.
      ///
      bool visible;
      ///
      /// Содержит ширину графического узла в пунктах.
      ///
      long width;
      ///
      /// Содержит оптимальную ширину объекта в пунктах.
      ///
      long optimalWidth;
      ///
      /// Истина, если оптимальная ширина объекта является константой и не может быть перемасштабирована.
      ///
      bool constWidth;
      ///
      /// Содержит высоту графического узла в пунктах.
      ///
      long high;
      ///
      /// Содержит оптимальную высоту объекта в пунктах.
      ///
      long optimalHigh;
      ///
      /// Истина, если оптимальная высота объекта является константой и не может быть перемастштабирована.
      ///
      bool constHigh;
      ///
      /// Расстояние по горизонтали от левого верхнего угла графического узла
      /// до левого верхнего угла окна терминала.
      ///
      long xDist;
      ///
      /// Расстояние по вертикали от левого верхнего угла графического узла
      /// до левого верхнего угла окна терминала.
      ///
      long yDist;
      ///
      /// Цвет фона графического узла.
      ///
      color bgColor;
      ///
      /// Цвет границы текстовой рамки.
      ///
      color borderColor;
      ///
      /// Номер строки в списке дочерних элементов.
      ///
      int n_line;
      ///
      /// Тип рамки для объекта "Прямоугольная рамка".
      ///
      ENUM_BORDER_TYPE borderType;
      ///
      /// Генерирует уникальное имя объекта
      ///
      void GenNameId(void)
      {
         //Получаем имя с указанием его порядкового номера
         if(name == NULL || name == "")
            name = "VisualForm";
         //nameId = name;
         nameId = ShortName();
         //Если объект с таким именем уже существует
         //добавляем к имени индекс, до тех пор пока имя не станет уникальным.
         int index = 0;
         //MathSrand(TimeLocal());
         int rnd = MathRand();
         while(ObjectFind(MAIN_WINDOW, nameId + (string)index + rnd) >= 0)
         {
            index++;
         }
         nameId += (string)index + rnd;
      }
      ///
      /// Инициализатор объекта.
      /// \param mytype - Тип графического объекта, лежащего в основе графического узла.
      /// \param myclassName - Класс, к которому принадлежит графический узел.
      /// \param myname - Название графического узла.
      /// \param parNode - Родительский узел, внутри которого располагается текущий узел.
      ///
      void Init(ENUM_OBJECT mytype, ENUM_ELEMENT_TYPE myElementType, string myname, ProtoNode* parNode)
      {
         if(parNode != NULL)
            name = parNode.Name() + "-->" + myname;
         else
            name = myname;
         constHigh = false;
         constWidth = false;
         shortName = myname;
         elementType = myElementType;
         parentNode = parNode;
         typeObject = mytype;
         optimalHigh = 20;
         optimalWidth = 80;
         borderType = BORDER_RAISED;
         switch(myElementType)
         {
            case ELEMENT_TYPE_GCONTAINER:
            case ELEMENT_TYPE_VCONTAINER:
               borderColor = clrBlack;
               bgColor = clrNONE;
               break;
            default:
               bgColor = clrWhite;
               borderColor = clrNONE;      
               break;
         }
      }
};