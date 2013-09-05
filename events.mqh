/*
  Идентификаторы событий и их параметры
*/
enum ENUM_EVENT_DIRECTION
{
   ///
   /// Внешнее событие. Идет от верхнего узла до нижнего.
   ///
   EVENT_EXTERN,
   ///
   /// Внутреннее событие. Идет от нижнего узла к более верхнему высокому.
   ///
   EVENT_INNER
};
///
/// 
///
#define EVENT_INER 1
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
      int GetEventId(){return eventId;}
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
      bool GetVisible(){return isVisible;}
      EventVisible(ENUM_EVENT_DIRECTION myeventDirection, int myEventId, string mynameId, bool visible) :
      Event(myeventDirection, myEventId, mynameId)
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
      long GetNewWidth(){return myWidth;}
      long GetNewHigh(){return myHigh;}
      EventResize(ENUM_EVENT_DIRECTION myeventDirection, int myEventId, string mynameId ,long newWidth, long newHigh) :
      Event(myeventDirection, myEventId, mynameId)
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
      EventNewTick(ENUM_EVENT_DIRECTION myeventDirection, int myEventId, string mynameId , double newTick) :
      Event(myeventDirection, myEventId, mynameId)
      {
         myTick = newTick;
      }
   private:
      double myTick;
};