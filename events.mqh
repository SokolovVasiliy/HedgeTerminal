/*
  Идентификаторы событий и их параметры
*/

//#define TERMINAL_IDNAME "dddd"
enum ENUM_EVENT_DIRECTION
{
   ///
   /// Внешнее событие. Идет от верхнего узла к нижнему.
   ///
   EVENT_FROM_UP,
   ///
   /// Внутреннее событие. Идет от нижнего узла к верхнему.
   ///
   EVENT_FROM_DOWN
};
///
/// Идентификатор события "Размер графического узла изменен".
///
#define EVENT_NODE_RESIZE 0
///
/// Идентификатор события "Графический узел передвинут".
///
#define EVENT_NODE_MOVE 1
///
/// Идентификатор события "Видимость графического узла изменена".
///
#define EVENT_NODE_VISIBLE 2
///
/// Идентификатор события "новый тик".
///
#define EVENT_NEW_TICK 3

///
/// <b>Абстрактный базовый класс события.</b> Любое генерируемое событие должно иметь свой уникальный идентификатор,
/// а также уникальное имя графического узла, который это событие произвел.
///
class Event
{
   public:
      ///
      /// Возвращает направление текущего события.
      ///
      ENUM_EVENT_DIRECTION Direction()
      {
         return eventDirection;
      }
      int EventId(){return eventId;}
      ///
      /// Набор параметров любого из события, обязательно содержит имя
      /// графического узла, который это событие инициализировал.
      ///
      string GetNameNodeId(){return nameNodeId;}
   // Непосредствено создать класс может только его потомок, т.е. класс является абстрактным и
   // его конструктор защищен от внешнего вызова.
   protected:
      ///
      /// Для создания параметров любого из событий, необходимо как минимум,
      /// указать уникальный идентификатор события и имя графического узла
      /// который его инициализировал.
      ///
      Event(ENUM_EVENT_DIRECTION myeventDirection ,int myeventId, string nameNode)
      {
         eventDirection = myeventDirection;
         eventId = myeventId;
         nameNodeId = nameNode;
      }
   private:
      ENUM_EVENT_DIRECTION eventDirection;
      int eventId;
      string nameNodeId;
};
///
/// Параметры события EVENT_NODE_VISIBLE
///
class EventVisible : Event
{
   public:
      bool Visible(){return isVisible;}
      EventVisible(ENUM_EVENT_DIRECTION myeventDirection, string mynameId, bool visible) :
      Event(myeventDirection, EVENT_NODE_VISIBLE, mynameId)
      {
         isVisible = visible;
      }
   private:
      bool isVisible;
};
///
/// Параметры события EVENT_NODE_RESIZE
///
class EventResize : Event
{
   public:
      long NewWidth(){return myWidth;}
      long NewHigh(){return myHigh;}
      EventResize(ENUM_EVENT_DIRECTION myeventDirection, string mynameId ,long newWidth, long newHigh) :
      Event(myeventDirection, EVENT_NODE_RESIZE, mynameId)
      {
         myWidth = newWidth;
         myHigh = newHigh;
      }
   private:
      long myWidth;
      long myHigh;
};
///
/// Параметры события EVENT_NEW_TICK
///
class EventNewTick : Event
{
   public:
      double GetNewTick(){return myTick;}
      EventNewTick(ENUM_EVENT_DIRECTION myeventDirection, string mynameId , double newTick) :
      Event(myeventDirection, EVENT_NEW_TICK, mynameId)
      {
         myTick = newTick;
      }
   private:
      double myTick;
};