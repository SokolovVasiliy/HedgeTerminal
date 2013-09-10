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
      /// Возвращает уникальный строковой идентификатор графического узла.
      /// \return Уникальный строковой идентификатор графического узла.
      ///
      string NameID(){return nameId;}
      ///
      /// Возвращает расстояние по горизонтали от левого верхнего угла графического узла
      /// до левого верхнего угла окна терминала.
      /// \return Расстояние в пунктах по оси Х.
      ///
      long XDistance(){return xDist;}
      ///
      /// Возвращает расстояние по вертикали от левого верхнего угла графического узла
      /// до левого верхнего угла окна терминала.
      /// \return Расстояние в пунктах по оси Y.
      ///
      long YDistance(){return yDist;}
      ///
      /// Возвращает расстояние по горизонтали от левого верхнего угла графического узла
      /// до левого верхнего угла родительского графического узла.
      /// \return Расстояние в пунктах по оси X.
      ///
      long XParDistance()
      {
         if(parentNode != NULL)
            return parentNode.XDistance();
         else return 0;
      }
      ///
      /// Возвращает расстояние по вертикали от левого верхнего угла графического узла
      /// до левого верхнего угла родительского графического узла.
      /// \return Расстояние в пунктах по оси Y.
      ///
      long YParDistance()
      {
         if(parentNode != NULL)
            return parentNode.YDistance();
         else return 0;
      }
      ///
      /// Возвращает ширину родительского графического узла. Если родительский
      /// графический узел не задан - возвращает 0.
      ///
      long ParWidth()
      {
         if(parentNode != NULL)
            return parentNode.Width();
         else return 0;
      }
      ///
      /// Возвращает высоту родительского графического узла. Если родительский
      /// графический узел не задан - возвращает 0.
      ///
      long ParHigh()
      {
         if(parentNode != NULL)
            return parentNode.High();
         else return 0;
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
         if(parentNode != NULL)
         {
            // 1. Узел не может располагаться выше верхней границы родительского узла.
            //XDistance()
            //XAbs
            // 2. Узел не может располагаться ниже нижней границы родительского узла.
            // 3. Узел не может быть левей левой границы родительского узла.
            // 4. Узел не может быть правей правой границы родительского узла.
            if(XParDistance() + newWidth > parentNode.Width())
               newWidth = parentNode.Width() - XParDistance();
            if(YParDistance() + newHigh > parentNode.High())
            {
               long h = parentNode.High();
               long y = YParDistance();
               newHigh = h - y;
               //newHigh = parentNode.High() - YParDistance();
            }
         }
         // Размер не может быть отрицательным.
         if(newWidth < 0)newWidth = 0;
         if(newHigh < 0)newHigh = 0;
         // 2) Переразмечаем графический узел, если он отображается в окне терминала.
         bool res = width != newWidth || high != newHigh;
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
         if(res)
         {
            width = newWidth;
            high = newHigh;
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
         long newWidth, newHigh;
         long X = parentNode == NULL ? ChartGetInteger(MAIN_WINDOW, CHART_WIDTH_IN_PIXELS, MAIN_SUBWINDOW):
                                       parentNode.Width();
         long Y = parentNode == NULL ? ChartGetInteger(MAIN_WINDOW, CHART_HEIGHT_IN_PIXELS, MAIN_SUBWINDOW):
                                       parentNode.High();
         newWidth = X - XDistance() - RightBorder;
         newHigh = Y - YDistance() - DnBorder;
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
            //Генерируем новое имя всякий раз когда требуется отобразить элемент, гарантируя его уникальность.
            GenNameId();
            visible = ObjectCreate(MAIN_WINDOW, nameId, typeObject, MAIN_SUBWINDOW, XDistance(), YDistance());
            //Перемещаем элемент в соответствии с его установленными координатами
            Move(xDist, yDist);
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
         if(context == COOR_LOCAL && parentNode != NULL)
         {
            xCoordinate = xCoordinate + XParDistance();
            yCoordinate = yCoordinate + YParDistance();
         }
         // Проверяем, не выйдут ли за пределы родительского узла новые
         // графические координаты.
         if(parentNode != NULL)
         {
            long xParDist = XParDistance();
            long yParDist = YParDistance();
            if(xCoordinate < xParDist)
               xCoordinate = xParDist;
            if(yCoordinate < yParDist)
               yCoordinate = xParDist;
            if(xCoordinate + width > xParDist + parentNode.Width())
               xCoordinate = xParDist + (parentNode.Width() - width);
            if(yCoordinate + high > yParDist + parentNode.High())
               yCoordinate = yParDist + (parentNode.High() - high);
         }
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
         //В случае неудачного перемещения объектов, запоминаем их фактоическое местоположение.
         if(!res)
         {
            xDist = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE);
            yDist = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_XDISTANCE);
         }
         else
         {
            xDist = xCoordinate - XParDistance();
            yDist = yCoordinate - YParDistance();
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


