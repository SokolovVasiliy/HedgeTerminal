#include <Arrays\ArrayObj.mqh>
/*
  Идентификаторы событий и их параметры
*/
///
/// Класс-адаптер позволяющий обмениваться событиями двум независимым классам.
///
class EventExchange
{
   public:
      static void PushEvent(Event* myEvent)
      {
         if(api != NULL)
            api.Event(myEvent);
         if(panel != NULL)
            panel.Event(myEvent);
      }
      static Event* PopEvent()
      {
         return event;
      }
      static void DeleteEvent()
      {
         event = NULL;
      }
      static void Add(CHedge* myHedge)
      {
         api = myHedge;
      }
      static void Add(ProtoNode* node)
      {
         panel = node;
      }
   private:
      void ExecuteEvent()
      {
         ;
      }
      static Event* event;
      static CHedge* api;
      static ProtoNode* panel;
};

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
enum ENUM_EVENT
{
   ///
   /// Идентификатор события "Размер графического узла изменен".
   ///
   EVENT_NODE_RESIZE,
   ///
   /// Идентификатор события "Графический узел передвинут".
   ///   
   EVENT_NODE_MOVE,
   ///
   /// Идентификатор события "Видимость графического узла изменена".
   ///
   EVENT_NODE_VISIBLE,
   ///
   /// Идентификатор события "новый тик".
   ///  
   EVENT_NEW_TICK,
   ///
   /// Идентификатор события "Инициализация эксперта".
   ///   
   EVENT_INIT,
   ///
   /// Идентификатор события "Деинициализация эксперта".
   ///
   EVENT_DEINIT,
   ///
   /// Идентификатор события "Приказ".
   ///
   EVENT_NODE_COMMAND,
   ///
   /// Идентификатор события "Создана новая позиция".
   ///
   EVENT_CREATE_NEWPOS,
   ///
   /// Идентификатор события Свойство позиции изменено.
   ///
   EVENT_CHANGE_POS,
   ///
   /// Команда на удаление позиции.
   ///
   EVENT_DEL_POS,
   ///
   /// Идентификатор события "Позиция закрылась".
   ///
   EVENT_CLOSE_POS,
   ///
   /// Идентификатор события таймер.
   ///
   EVENT_TIMER,
   ///
   /// Идентификатор события обновление экрана.
   ///
   EVENT_REFRESH,
   ///
   /// Идентификатор события "кнопка нажата".
   ///
   EVENT_PUSH,
   ///
   /// Идентификатор события "дерево Раскрыто/Закрыто".
   ///
   EVENT_COLLAPSE_TREE,
   ///
   /// Идентификатор команды обновить графический узел.
   ///
   EVENT_REDRAW,
   ///
   /// Идентификатор события "положение мыши изменено".
   ///
   EVENT_MOUSE_MOVE,
   ///
   /// Идентификатор события "статус графического элемента CheckBox изменене".
   ///
   EVENT_CHECK_BOX_CHANGED
};


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
      string NameNodeId(){return nameNodeId;}
      ///
      /// Возвращает указатель на узел, сгенерировавший событие. Событие может не иметь
      /// сгенерировавшего его узла (например все системыне события OnChartEvent), или
      /// узел может не дать ссылку на себя. В этом случае, метод вернет значение NULL.
      ///
      ProtoNode* Node(){return node;}
      ///
      /// Создает точную копию события и возвращает ссылку для него.
      ///
      virtual Event* Clone()
      {
         return new Event(eventDirection, eventId, nameNodeId);
      }
      ///
      /// Возвращает количество милисекунд прошедщих с момента запуска терминала до момента создания события.
      ///
      uint TickCount(){return tickCount;}
   // Непосредствено создать класс может только его потомок, т.е. класс является абстрактным и
   // его конструктор защищен от внешнего вызова.
   protected:
      ///
      /// Для создания параметров любого из событий, необходимо как минимум,
      /// указать уникальный идентификатор события и имя графического узла
      /// который его инициализировал.
      ///
      Event(ENUM_EVENT_DIRECTION myeventDirection ,ENUM_EVENT myeventId, string nameNode)
      {
         eventDirection = myeventDirection;
         eventId = myeventId;
         nameNodeId = nameNode;
         tickCount = GetTickCount();
      }
      ///
      /// Создает новое событие, с указателем на узел, который его сгенерировал.
      /// \param myDirection - направление, по которому распространяется событие.
      /// \param myEventId - идентификатор события.
      /// \param myNode - значимый указатель на узел, сгенерировавший событие.
      ///
      Event(ENUM_EVENT_DIRECTION myDirection, ENUM_EVENT myEventId, ProtoNode* myNode)
      {
         eventDirection = myDirection;
         eventId = myEventId;
         nameNodeId = myNode.NameID();
         node = myNode;
         tickCount = GetTickCount();
      }
   private:
      ///
      /// Направление события.
      ///
      ENUM_EVENT_DIRECTION eventDirection;
      ///
      /// Идентификатор события.
      ///
      ENUM_EVENT eventId;
      ///
      /// Имя узла, сгенерировавшее событие.
      ///
      string nameNodeId;
      ///
      /// Количество милисекунд, прошедщих с момента запуска терминала до создания события.
      ///
      uint tickCount;
      ///
      /// Указатель на экземпляр узла, сгенерировавший событие.
      ///
      ProtoNode* node;
};



///
/// Событие EVENT_NODE_VISIBLE
///
class EventVisible : public Event
{
   public:
      bool Visible(){return isVisible;}
      /*EventVisible(ENUM_EVENT_DIRECTION myeventDirection, string mynameId, bool visible) :
      Event(myeventDirection, EVENT_NODE_VISIBLE, mynameId)
      {
         isVisible = visible;
      }*/
      EventVisible(ENUM_EVENT_DIRECTION myeventDirection, ProtoNode* myNode, bool visible) :
      Event(myeventDirection, EVENT_NODE_VISIBLE, myNode)
      {
         isVisible = visible;
      }
      virtual Event* Clone()
      {
         return new EventVisible(Direction(), Node(), isVisible);
      }
   private:
      bool isVisible;
};
///
/// Событие EVENT_NODE_RESIZE
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
      virtual Event* Clone()
      {
         return new EventResize(Direction(), NameNodeId(), myWidth, myHigh);
      }
   private:
      long myWidth;
      long myHigh;
};
///
/// Событие EVENT_NODE_MOVE
///
class EventMove : Event
{
   public:
      long XDist(){return xDist;}
      long YDist(){return yDist;}
      ENUM_COOR_CONTEXT Context(){return context;}
      EventMove(ENUM_EVENT_DIRECTION eventDir, string mynameId ,long myXDist, long myYDist, ENUM_COOR_CONTEXT myContext):
      Event(eventDir, EVENT_NODE_MOVE, mynameId)
      {
         xDist = myXDist;
         yDist = myYDist;
         context = myContext;
      }
      virtual Event* Clone()
      {
         return new EventMove(Direction(), NameNodeId(), xDist, yDist, context);
      }
   private:
      long xDist;
      long yDist;
      ENUM_COOR_CONTEXT context;
};
///
/// События EVENT_NEW_TICK
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
      virtual Event* Clone()
      {
         return new EventNewTick(Direction(), NameNodeId(), myTick);
      }
   private:
      double myTick;
};

class EventInit : Event
{
   public:
      virtual Event* Clone()
      {
         return new EventInit();
      }
      EventInit():
      Event(EVENT_FROM_UP, EVENT_INIT, "TERMINAL_WINDOW"){;}
};
///
/// Событие "Деинициализация программы".
///
class EventDeinit : Event
{
   public:
      virtual Event* Clone()
      {
         return new EventDeinit();
      }
      EventDeinit():
      Event(EVENT_FROM_UP, EVENT_DEINIT, "TERMINAL_WINDOW"){;}
};

///
/// Событие содержит приказ на установку текущего узла в соответствующее положение.
///
class EventNodeCommand : public Event
{
   public:
      virtual Event* Clone()
      {
         return new EventNodeCommand(Direction(), NameNodeId(), visible, xDist, yDist, width, high);
      }
      long XDist(){return xDist;}
      long YDist(){return yDist;}
      long Width(){return width;}
      long High(){return high;}
      bool Visible(){return visible;}
      EventNodeCommand(ENUM_EVENT_DIRECTION myDir, string nodeId, bool isVisible, long newXDist, long newYDist, long newWidth, long newHigh):
      Event(myDir, EVENT_NODE_COMMAND, nodeId)
      {
         visible = isVisible;
         width = newWidth;
         high = newHigh;
         xDist = newXDist;
         yDist = newYDist;
      }
   private:
      ///
      /// Статус видимости объекта.
      ///
      bool visible;
      ///
      /// Ширина узла в пунктах.
      ///
      long width;
      ///
      /// Высота узла в пунктах.
      ///
      long high;
      ///
      /// Абсолютная вертикальная координата.
      ///
      long xDist;
      ///
      /// Абсолютная горизонтальная координата.
      ///
      long yDist;
};

///
/// Событие "Состояние позиций изменилось".
///
/*class EventChangeStatePos : public Event
{
   public:
      EventChangeStatePos(ENUM_EVENT_DIRECTION myDir, string nodeId, CArrayObj* myPos):
      Event(myDir, EVENT_CHANGE_POS, nodeId)
      {
         pos = myPos;
      }
      virtual Event* Clone()
      {
         return new EventChangeStatePos(Direction(), NameNodeId(), pos);
      }
      CArrayObj* GetPositions(){return pos;}
   private:
      ///
      /// Список изменившихся позиций
      ///
      CArrayObj* pos;
};*/

///
/// Событие "Новая позиция создана".
///
class EventCreatePos : public Event
{
   public:
      EventCreatePos(ENUM_EVENT_DIRECTION myDir, string nodeId, Position* myPos):
      Event(myDir, EVENT_CREATE_NEWPOS, nodeId)
      {
         pos = myPos;
      }
      virtual Event* Clone()
      {
         return new EventCreatePos(Direction(), NameNodeId(), pos);
      }
      Position* GetPosition(){return pos;}
   private:
      ///
      /// Список изменившихся позиций
      ///
      Position* pos;
};
///
/// Событие, генерируемое с заданой периодичностью. Создается в функции OnTimer()
///
class EventTimer : public Event
{
   public:
      EventTimer(int myRefreshRate):Event(EVENT_FROM_UP, EVENT_TIMER, "TERMINAL")
      {
         refreshRate = myRefreshRate;
      }
      virtual Event* Clone()
      {
         EventTimer* timer = new EventTimer(refreshRate);
         return timer;
      }
   private:
      int refreshRate;
};

class EventRefresh : public Event
{
   public:
      EventRefresh(ENUM_EVENT_DIRECTION Dir, string nodeId):
      Event(Dir, EVENT_REFRESH, nodeId){;}
};

class EventPush : public Event
{
   public:
      EventPush(string pushName): Event(EVENT_FROM_UP, EVENT_PUSH, "TERMINAL WINDOW")
      {
         pushObjName = pushName;
      }
      ///
      /// Возвращает название объекта, по которому было произведено нажатие.
      ///
      string PushObjName(){return pushObjName;}
      virtual Event* Clone()
      {
         return new EventPush(pushObjName);
      }
   private:
      ///
      /// Хранит название узла, по которому было произведено нажатие.
      ///
      string pushObjName;
};

///
/// Команда на закрытие позиции.
///
class EventDelPos : public Event
{
   public:
      EventDelPos(ulong posId, string nodeId) : Event(EVENT_FROM_DOWN, EVENT_DEL_POS, nodeId)
      {
         positionId = posId;
      }
      virtual Event* Clone()
      {
         return new EventDelPos(positionId, NameNodeId());
      }
   private:
      ulong positionId;
};

class EventCollapseTree : public Event
{
   public:
      EventCollapseTree(ENUM_EVENT_DIRECTION myDir, ProtoNode* myNode, bool isCollapse) : Event(EVENT_FROM_DOWN, EVENT_COLLAPSE_TREE, myNode)
      {
         n_line = myNode.NLine();
         status = isCollapse;
      }
      ///
      /// Возвращает состояние списка.
      /// \return Истина, если список закрыт и ложь в противном случае.
      ///
      bool IsCollapse()
      {
         return status;
      }
      int NLine(){return n_line;}
      virtual Event* Clone()
      {
         return new EventCollapseTree(Direction(), Node(), status);
      } 
   private:
      ///
      /// Содержит состояние списка. Истина, если список закрыт и ложь в противном случае.
      ///
      bool status;
      ///
      /// Номер строки в списке дочерних элементов, которая была свернута/развернута
      ///
      int n_line;
};
///
/// Команда на обновление графического узла функцией ChartRedraw();
///
class EventRedraw : public Event
{
   public:
      EventRedraw(ENUM_EVENT_DIRECTION myDir, string nameNode) : Event(myDir, EVENT_REDRAW, nameNode){;}
      virtual Event* Clone(){return new EventRedraw(Direction(), NameNodeId());}
};

///
/// Событие "положение мыши изменено".
///
class EventMouseMove : public Event
{
   public:
      ///
      /// Создание события "положение мыши изменено".
      /// \param xCoord - X координата положения мыши.
      /// \param yCoord - Y координата положения мыши.
      /// \param mask - Маска, указывающая комбинацию нажатых кнопок.
      ///
      EventMouseMove(long XCoord, long YCoord, int Mask) : Event(EVENT_FROM_UP, EVENT_MOUSE_MOVE, "TERMINAL WINDOW")
      {
         xCoord = XCoord;
         yCoord = YCoord;
         mask = Mask;
      }
      virtual Event* Clone(){return new EventMouseMove(xCoord, yCoord, mask);}
      ///
      /// Истина, если нажата правая кнопка мыши.
      ///
      bool PushedRightButton()
      {
         bool res = (MOUSE_RIGHT_BUTTON_PUSH & mask) ==
              MOUSE_RIGHT_BUTTON_PUSH;
         return res;
      }
      ///
      /// Истина, если нажата левая кнопка мыши.
      ///
      bool PushedLeftButton()
      {
         bool res = (MOUSE_LEFT_BUTTON_PUSH & mask) ==
              MOUSE_LEFT_BUTTON_PUSH;
         return res;
      }
      ///
      /// Истина, если нажата центральная кнопка мыши.
      ///
      bool PushedCentralButton()
      {
         bool res = (MOUSE_CENTER_BUTTON_PUSH & mask) ==
              MOUSE_CENTER_BUTTON_PUSH;
         return res;
      }
      ///
      /// Истина, если не нажата ни одна из кнопок мыши.
      ///
      bool PushedNothing()
      {
         if(mask == 0)return true;
         return false;
      }
      ///
      /// Возвращает комбинацию нажатых клавиш мыши в виде маски.
      ///
      int Mask(){return mask;}
      ///
      /// Возвращает X координату положения мыши.
      ///
      long XCoord(){return xCoord;}
      ///
      /// Возвращает Y координату положения мыши.
      ///
      long YCoord(){return yCoord;}
   private:
      ///
      /// X координата положение мыши.
      ///
      long xCoord;
      ///
      /// Y координата положение мыши.
      ///
      long yCoord;
      ///
      /// Маска, содержащая комбинацию нажатых кнопок мыши.
      ///
      int mask;
};

class EventCheckBoxChanged : public Event
{
   public:
      EventCheckBoxChanged(ENUM_EVENT_DIRECTION dirEvent, CheckBox* m_checkBox, ENUM_BUTTON_STATE myState) : Event(dirEvent, EVENT_CHECK_BOX_CHANGED, m_checkBox)
      {
         checkBox = m_checkBox;
      }
      ///
      /// Возвращает состояние CheckBox.
      ///
      ENUM_BUTTON_STATE State(){return state;}
      virtual Event* Clone()
      {
         EventCheckBoxChanged* checked = new EventCheckBoxChanged(Direction(), checkBox, state);
         return checked;
      }
   private:
      CheckBox* checkBox;
      
      ENUM_BUTTON_STATE state;
};

