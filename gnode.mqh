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
      long AbsXDistance(){return xAbsDist;}
      ///
      /// Возвращает расстояние по вертикали от левого верхнего угла графического узла
      /// до левого верхнего угла окна терминала.
      /// \return Расстояние в пунктах по оси Y.
      ///
      long AbsYDistance(){return yAbsDist;}
      ///
      /// Возвращает расстояние по горизонтали от левого верхнего угла графического узла
      /// до левого верхнего угла родительского графического узла.
      /// \return Расстояние в пунктах по оси X.
      ///
      long ParXDistance(){return xParDist;}
      ///
      /// Возвращает расстояние по вертикали от левого верхнего угла графического узла
      /// до левого верхнего угла родительского графического узла.
      /// \return Расстояние в пунктах по оси Y.
      ///
      long ParYDistance(){return yParDist;}
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
            // Больше лимитов.
            if(newWidth > parentNode.Width())
               newWidth = parentNode.Width();
            if(newHigh > parentNode.High())
               newHigh = parentNode.High();
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
            visible = ObjectCreate(MAIN_WINDOW, nameId, ObjectType, MAIN_SUBWINDOW, xAbsDist, yAbsDist);
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
      /// Посылает событие в направлении, указанном в его типе.
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
               node.Event(event);
            }
         }
         //Событие идет снизу-вверх.
         if(event.Direction() == EVENT_FROM_DOWN)
         {
            if(parentNode != NULL)
               parentNode.Event(event);
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
      ENUM_OBJECT ObjectType;
      ///
      /// Имя графического узла, дающее представление о его назначении. Например:
      /// "GeneralForm" или "TableOfOpenPosition".
      ///
      string name;
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
      long xAbsDist;
      ///
      /// Расстояние по вертикали от левого верхнего угла графического узла
      /// до левого верхнего угла окна терминала.
      ///
      long yAbsDist;
      ///
      /// Расстояние по горизонтали от левого верхнего угла графического узла
      /// до левого верхнего угла родительского графического узла.
      ///
      long xParDist;
      ///
      /// Расстояние по вертикали от левого верхнего угла графического узла
      /// до левого верхнего угла родительского графического узла.
      ///
      long yParDist;
      
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
};
///
/// Основная форма панели.
///
class MainForm : public ProtoNode
{
   public:
      ///
      /// Определяем реакцию на поступающие события.
      ///
      virtual void Event(Event *newEvent)
      {
         // Обрабатываем события приходящие сверху.
         if(newEvent.Direction() == EVENT_FROM_UP)
         {
            switch(newEvent.EventId())
            {
               case EVENT_NODE_RESIZE:
                  ResizeExtern(newEvent);
                  break;
               case EVENT_NODE_VISIBLE:
                  VisibleExtern(newEvent);
                  break;
               //События которые не можем обработать отправляем дальше вниз.
               default:
                  EventSend(newEvent);
            }
         }
      }
      MainForm()
      {
         //В основе главной формы панели лежит "Прямоугольная метка";
         ObjectType = OBJ_RECTANGLE_LABEL;
         name = "HedgePanel";
      }
   private:
      ///
      /// Обработчик события 'видимость внешнего узла изменена'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void ResizeExtern(EventResize* event)
      {
         //Ширина формы не может быть меньше 100 пикселей.
         long cwidth = event.NewWidth() < 100 ? 100 : event.NewWidth();
         //Высота формы не может быть меньше 50 пикселей.
         long chigh = event.NewHigh() < 50 ? 50 : event.NewWidth();
         Resize(event.NewWidth(), event.NewHigh());
         // Теперь, когда текущий узел переразмечен, старое событие утилизируем,
         // а вместо него создаем новое событие "Размер этого графического узла изменен",
         // и посылаем его всем дочерним элементам.
         delete event;
         EventSend(new EventResize(EVENT_FROM_UP, NameID(), Width(), High()));
      }
      ///
      /// Обработчик события статус 'видимости внешнего узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         Visible(event.Visible());
         delete event;
         EventSend(new EventVisible(EVENT_FROM_UP, NameID(), Visible()));
      }
};

