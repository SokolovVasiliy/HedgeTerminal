#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include "events.mqh"
#include "log.mqh"

///
/// Идентификатор окна графика на котором запущена панель.
///
#define MAIN_WINDOW 0
///
/// Идентификатор подокна графика, на котором запущена панель.
///
#define MAIN_SUBWINDOW 0

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
   ELEMENT_TYPE_HEAD_COLUMN
};

///
/// Контекст передваемых координат для функции Move().
///
enum ENUM_COOR_CONTEXT
{
   ///
   /// Текущие координаты задаются относительно левого верхнего угла окна терминала.
   ///
   COOR_GLOBAL,
   ///
   /// Текущие координаты задаются относительно левого верхнего угла родительского узла.
   ///
   COOR_LOCAL
};

class ProtoNode : CObject
{
   public:
            
      ///
      /// Принимаем событие и обрабатываем его в соответсвтии с правилами
      /// определенными в классе-потомке. 
      ///
      virtual void Event(Event* newEvent){;}
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
   protected:
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
         width = newWidth;
         high = newHigh;
         // Если размер все равно отрицателен, либо равен нулю - то элемент не видим.
         if((newHigh <= 0 || newWidth <= 0) && Visible())
            Visible(false);
         // 2) Переразмечаем графический узел, если он отображается в окне терминала.
         bool res = true;
         if(visible)
         {
            res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE, newWidth);
            if(!res)
               LogWriter("Failed resize element " + nameId + " by horizontally.", MESSAGE_TYPE_ERROR);
            else
               res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE, newHigh);
            if(!res)
               LogWriter("Failed resize element " + nameId + " by verticaly.", MESSAGE_TYPE_ERROR);
         }
         return res;
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
      ///
      /// Устанавливает видимость графического узла.
      /// \param status - Истина, если требуется отобразить графический узел в окне терминала,
      /// ложь - в противном случае.
      /// \return Истина, если смена видимости графического узла прошла успешно, ложь -
      /// в противном случае.
      bool Visible(bool status)
      {
         // Включаем визуализацию.
         if(!Visible() && status)
         {
            // Размеры должны быть значимыми.
            if(width <= 0 || high <= 0)
               return false;
            // 1. Узел не может располагаться выше верхней границы родительского узла.
            if (yDist < YAbsParDistance())
            {
                LogWriter("Y-coordinate of node must be leter Y-coordinate parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 2. Узел не может располагаться ниже нижней границы родительского узла.
            if (yDist + High() > YAbsParDistance() + ParHigh())
            {
                long ypar = YAbsParDistance();
                long hpar = ParHigh();
                LogWriter("Node position must be biger down line parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 3. Узел не может быть левей левой границы родительского узла.
            if (XAbsDistance() < XAbsParDistance())
            {
                LogWriter("X-coordinate of node must be leter X-coordinate parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            // 4. Узел не может быть правей правой границы родительского узла.
            if (XAbsDistance() + Width() > XAbsParDistance() + ParWidth())
            {
                LogWriter("Node position must be biger left line parent node", MESSAGE_TYPE_WARNING);
                return false;
            }
            //Генерируем новое имя всякий раз когда требуется отобразить элемент, гарантируя его уникальность.
            GenNameId();
            visible = ObjectCreate(MAIN_WINDOW, nameId, typeObject, MAIN_SUBWINDOW, XAbsDistance(), YAbsDistance());
            //Перемещаем элемент в соответствии с его установленными координатами
            Move(xDist, yDist, COOR_GLOBAL);
            if(!visible)
               LogWriter("Failed visualize element " + nameId, MESSAGE_TYPE_ERROR);
            else
               Resize(width, high);
         }
         // Выключаем визуализацию.
         if(Visible() && !status)
         {
            visible = !ObjectDelete(MAIN_WINDOW, nameId);
         }
         if(status == visible)return true;
         else return false;
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
            xCoordinate = xCoordinate + XAbsParDistance();
            yCoordinate = yCoordinate + YAbsParDistance();
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
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE, xCoordinate))
            {
               LogWriter("Failed move element " + nameId, MESSAGE_TYPE_ERROR);
               res = false;
            }
            if(!ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_YDISTANCE, yCoordinate))
            {
               LogWriter("Failed move element " + nameId, MESSAGE_TYPE_ERROR); 
               res = false;
            }
         }
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
               Event* ev = event.Clone();
               node.Event(ev);
               delete ev;
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
      /// Имя графического узла, дающее представление о его назначении. Например:
      /// "GeneralForm" или "TableOfOpenPosition".
      ///
      string name;
      ///
      /// Тип элемента графического интерфейса, к которому принадлежит графический узел. 
      ///
      ENUM_ELEMENT_TYPE elementType;
   private:
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
      /// Содержит высоту графического узла в пунктах.
      ///
      long high;
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
      /// Генерирует уникальное имя объекта
      ///
      void GenNameId(void)
      {
         //Получаем имя с указанием его порядкового номера
         if(name == NULL || name == "")
            name = "VisualForm";
         nameId = name;
         //Если объект с таким именем уже существует
         //добавляем к имени индекс, до тех пор пока имя не станет уникальным.
         int index = 0;
         while(ObjectFind(MAIN_WINDOW, nameId + (string)index) >= 0)
         {
            index++;
         }
         nameId += (string)index;
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
         elementType = myElementType;
         parentNode = parNode;
         typeObject = mytype;
      }
};


