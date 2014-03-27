#include <Arrays\ArrayObj.mqh>
#include "\API\MqlTransactions.mqh"
#ifndef EVENTS_MQH
   #define EVENTS_MQH
#endif
#ifndef HEDGE_PANEL
   class ProtoNode;
#endif 

class Event;
class HedgeManager;
class Position;
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
         #ifdef HEDGE_PANEL
         if(panel != NULL)
            panel.Event(myEvent);
         #endif
      }
      
      static Event* PopEvent()
      {
         return event;
      }
      static void DeleteEvent()
      {
         event = NULL;
      }
      static void Add(HedgeManager* myHedge)
      {
         api = myHedge;
      }
      #ifdef HEDGE_PANEL
      static void Add(ProtoNode* node)
      {
         panel = node;
      }
      #endif
      static HedgeManager* GetAPI(void)
      {
         return api;
      }
      static HedgeManager* api;
      #ifdef HEDGE_PANEL
      static ProtoNode* panel;
      #endif
   private:
      void ExecuteEvent()
      {
         ;
      }
      static Event* event;
      
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
   EVENT_OBJ_CLICK,
   ///
   /// Это событие посылает графический объект, после того, как был нажат.
   ///
   EVENT_NODE_CLICK,
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
   EVENT_CHECK_BOX_CHANGED,
   ///
   /// Идентификатор события цвет узла сменен.
   ///
   EVENT_CHANGE_COLOR,
   ///
   /// Клавиша нажатия
   ///
   EVENT_KEYDOWN,
   ///
   /// Завершение редактирования текста.
   ///
   EVENT_END_EDIT,
   ///
   /// После завершения редактирования текста, класс EditNode генерирует
   /// это событие.
   ///
   EVENT_END_EDIT_NODE,
   ///
   /// Идентификатор события "Совершена новая сделка".
   ///
   EVENT_ADD_DEAL,
   ///
   /// Идентификатор события-приказа "Обновить представление позиции".
   ///
   EVENT_REFRESH_POS,
   ///
   /// Идентификатор события "Ответ торгового сервера".
   ///
   EVENT_REQUEST_NOTICE,
   ///
   /// Идентификатор события "Статус блокировки позиции изменен".
   ///
   EVENT_BLOCK_POS,
   ///
   /// Идентификатор события поступления отложенного ордера.
   ///
   EVENT_ORDER_CANCEL,
   ///
   /// Идентификатор события поступления сработавшего ордера.
   ///
   EVENT_ORDER_EXE,
   ///
   /// Идентификатор события поступления нового отложенного ордера.
   ///
   EVENT_ORDER_PENDING,
   ///
   /// Идентификатор события данные xml активной позиции изменились. (31-ое событие)
   ///
   EVENT_XML_ACTPOS_REFRESH,
   ///
   /// Идентификатор приказа удаления xml позиции и лежащего в его основе xml узла.
   ///
   EVENT_DELETE_XML_POS,
   ///
   /// Идентификатор приказа изменения xml аттрибута.
   ///
   EVENT_CHANGE_XML_ATTR,
   ///
   /// Идентификатор события обновления графической панели.
   ///
   EVENT_REFRESH_PANEL
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
      ENUM_EVENT EventId(){return eventId;}
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
      #ifdef HEDGE_PANEL
      ProtoNode* Node(){return node;}
      #endif 
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
      #ifdef HEDGE_PANEL
      Event(ENUM_EVENT_DIRECTION myDirection, ENUM_EVENT myEventId, ProtoNode* myNode)
      {
         eventDirection = myDirection;
         eventId = myEventId;
         #ifdef HEDGE_PANEL
         nameNodeId = myNode.NameID();
         #endif
         node = myNode;
         tickCount = GetTickCount();
      }
      #endif
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
      #ifdef HEDGE_PANEL
      ProtoNode* node;
      #endif
};

/* TERMINAL EVENTS*/
///
/// Событие "получено торговое событие".
///
class EventRequestNotice : public Event
{
   public:
      EventRequestNotice(const MqlTradeTransaction& mqlTrans, const MqlTradeRequest& mqlRequest, const MqlTradeResult& mqlResult) :
      Event(EVENT_FROM_UP, EVENT_REQUEST_NOTICE, "WINDOW TERMINAL")
      {
         trans = new TradeTransaction(mqlTrans);
         request = new TradeRequest(mqlRequest);
         result = new TradeResult(mqlResult);
      }
      ~EventRequestNotice()
      {
         delete trans;
         delete request;
         delete result;
      }
      TradeTransaction* GetTransaction(){return trans;}
      TradeRequest* GetRequest(){return request;}
      TradeResult* GetResult(){return result;}
   private:
      TradeTransaction* trans;
      TradeRequest* request;
      TradeResult* result;
};

///
/// Событие "Статус блокировки позиции изменен".
///
class EventBlockPosition : public Event
{
   public:
      EventBlockPosition(Position* blockPos, bool status) : Event(EVENT_FROM_UP, EVENT_BLOCK_POS, "Position blocked")
      {
         pos = blockPos;
         statusBlock = status;
      }
      ///
      /// Возвращает указатель на позицию, которая была блокирована/разблокирована.
      ///
      Position* Position(){return pos;}
      ///
      /// Возвращает статус блокировки позиции.
      ///
      bool Status(){return statusBlock;}
      virtual Event* Clone()
      {
         EventBlockPosition* ev = new EventBlockPosition(pos, statusBlock);
         return ev;
      }
   private:
      Position* pos;
      bool statusBlock;
};
///
/// Событие EVENT_NODE_VISIBLE
///
#ifdef HEDGE_PANEL
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
#endif
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

///
/// Это событие генерируется терминалом 
///
class EventObjectClick : public Event
{
   public:
      EventObjectClick(string pushName): Event(EVENT_FROM_UP, EVENT_OBJ_CLICK, "TERMINAL WINDOW")
      {
         pushObjName = pushName;
      }
      ///
      /// Возвращает название объекта, по которому было произведено нажатие.
      ///
      string PushObjName(){return pushObjName;}
      virtual Event* Clone()
      {
         return new EventObjectClick(pushObjName);
      }
   private:
      ///
      /// Хранит название узла, по которому было произведено нажатие.
      ///
      string pushObjName;
};

///
/// Это событие генерируется терминалом в случаи окончания редактирования текстовой метки.
///
class EventEndEdit : public Event
{
   public:
      EventEndEdit(string editNameNode): Event(EVENT_FROM_UP, EVENT_END_EDIT, "TERMINAL WINDOW")
      {
         nameNode = editNameNode;
      }
      
      ///
      /// Возвращает название объекта, по которому было произведено нажатие.
      ///
      string EditNode(){return nameNode;}
      virtual Event* Clone()
      {
         return new EventObjectClick(nameNode);
      }
   private:
      ///
      /// Хранит название узла, по которому было произведено нажатие.
      ///
      string nameNode;
      ///
      /// Хранит новое значение надписи узла.
      ///
      string value;
};
#ifdef HEDGE_PANEL
class EditNode;
class EventEndEditNode : public Event
{
   public:
      EventEndEditNode(EditNode* editNode, string curValue) : Event(EVENT_FROM_DOWN, EVENT_END_EDIT_NODE, editNode)
      {
         this.value = curValue;
      }
      ///
      /// Возвращает значение EditNode после редактирования.
      ///
      string Value(){return value;}
   private:
      string value;
};
#endif

///
/// Определяет тип изменения позиции
///
enum ENUM_POSITION_CHANGED_TYPE
{
   ///
   ///Указывает, что текущую позицию необходимо скрыть.
   ///
   POSITION_HIDE,
   ///
   /// Указывает что переданную позицию необходимо отобразить.
   ///
   POSITION_SHOW,
   ///
   /// Указывает, что необходимо обновить отображение переданной позиции.
   ///
   POSITION_REFRESH
};

///
/// Это событие дает команду о том, что нужно делать с изменившейся позицией.
///
class EventPositionChanged : public Event
{
   public:
      EventPositionChanged(Position* pos, ENUM_POSITION_CHANGED_TYPE type) :
      Event(EVENT_FROM_UP, EVENT_CHANGE_POS, "Hedge API")
      {
         myPos = pos;
         chType = type;
      }
      ENUM_POSITION_CHANGED_TYPE ChangedType(){return chType;}
      Position* Position(){return myPos;}
   private:
      ENUM_POSITION_CHANGED_TYPE chType;
      Position* myPos;
};

///
/// Это событие посылает команду закрыть позицию (Генерируется кнопкой close).
///
class EventClosePos : public Event
{
   public:
      EventClosePos(string nodeId) : Event(EVENT_FROM_DOWN, EVENT_CLOSE_POS, nodeId){;}
      ///
      /// Устанавливает идентификатор позиции, которую требуется закрыть.
      ///
      void PositionId(ulong pos){positionId = pos;}
      ///
      /// Возвращает идентификатор позиции, которую требуется закрыть.
      ///
      ulong PositionId(){return positionId;}
      ///
      /// Устанавливает номер строки, являющимся визуальным представлением позиции.
      ///
      void NLine(int n)
      {
         n_line = n;
      }
      ///
      /// Возвращает номер строки, являющимся визуальным представлением позиции.
      ///
      int NLine(){return n_line;}
      ///
      /// Возвращает закрывающий комментарий.
      ///
      string CloseComment(){return comment;}
      ///
      /// Возвращает закрывающий комментарий.
      ///
      void CloseComment(string comm){comment = comm;}
      
      virtual Event* Clone()
      {
         return new EventClosePos(NameNodeId());
      }
      
   private:
      ///
      /// Идентификатор позиции, которую требуется закрыть.
      ///
      ulong positionId;
      ///
      /// номер позиции в списке визуальных позиций.
      ///
      int n_line;
      ///
      /// Закрывающий комментарий.
      ///
      string comment;
};

class Order;
///
/// Это событие посылает HedgeManager, когда в историю ордеров попадает
/// новый отмененный ордер.
///
class EventOrderCancel : public Event
{
   public:
      EventOrderCancel(Order* myOrder) : Event(EVENT_FROM_UP, EVENT_ORDER_CANCEL, "Terminal API")
      {
         order = myOrder;
      }
      ///
      /// Возвращает отмененный ордер.
      ///
      Order* Order(){return order;}
   private:
      Order* order;
};

///
/// Это событие посылает HedgeManager, когда формируется новый
/// сработавший ордер.
///
class EventOrderExe : public Event
{
   public:
      EventOrderExe(Order* myOrder) : Event(EVENT_FROM_UP, EVENT_ORDER_EXE, "Terminal API")
      {
         order = myOrder;
      }
      ///
      /// Возвращает отмененный ордер.
      ///
      Order* Order(){return order;}
   private:
      Order* order;
};

///
/// Это событие посылает HedgeManager, когда поступает новый
/// отложенный (активный) ордер в список активных ордеров.
///
class EventOrderPending : public Event
{
   public:
      EventOrderPending(Order* myOrder) : Event(EVENT_FROM_UP, EVENT_ORDER_PENDING, "Terminal API")
      {
         order = myOrder;
      }
      ///
      /// Возвращает отмененный ордер.
      ///
      Order* Order(){return order;}
   private:
      Order* order;
};

#ifdef HEDGE_PANEL
class EventCollapseTree : public Event
{
   public:
      EventCollapseTree(ENUM_EVENT_DIRECTION myDir, ProtoNode* myNode, bool isCollapse) : Event(EVENT_FROM_DOWN, EVENT_COLLAPSE_TREE, myNode)
      {
         #ifdef HEDGE_PANEL
         n_line = myNode.NLine();
         #endif
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
#endif
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

#ifdef HEDGE_PANEL
//class CheckBox;
class EventCheckBoxChanged : public Event
{
   public:
      EventCheckBoxChanged(ENUM_EVENT_DIRECTION dirEvent, CheckBox* m_checkBox, bool check) : Event(dirEvent, EVENT_CHECK_BOX_CHANGED, m_checkBox)
      {
         checkBox = m_checkBox;
         isChecked = check;
      }
      ///
      /// Возвращает статус нажатия кнопки.
      ///
      bool Checked(){return isChecked;}
      ///
      /// Возвращает состояние CheckBox.
      ///
      ENUM_BUTTON_STATE State(){return state;}
      virtual Event* Clone()
      {
         EventCheckBoxChanged* checked = new EventCheckBoxChanged(Direction(), checkBox, isChecked);
         return checked;
      }
   private:
      CheckBox* checkBox;
      bool isChecked;
      ENUM_BUTTON_STATE state;
};
#endif

///
/// Это событие посылает графический объект после того, как был нажат
/// (реализация по-умолчанию в ProtoNode.OnPush())
///
#ifdef HEDGE_PANEL
class EventNodeClick : public Event
{
   public:
      EventNodeClick(ENUM_EVENT_DIRECTION dirEvent, ProtoNode* myNode) : Event(dirEvent, EVENT_NODE_CLICK, myNode){;}
      Event* Clone(){return new EventNodeClick(Direction(), Node());}
};
#endif
///
/// Событие, сигнализирующее о смене цвета.
///
class EventChangeColor : public Event
{
   public:
      EventChangeColor(ENUM_EVENT_DIRECTION dirEvent, string nodeName, color clr) : Event(dirEvent, EVENT_CHANGE_COLOR, nodeName)
      {
         m_clr = clr;
      }
      ///
      /// Возвращает цвет, на который необходимо сменить цвет узла.
      ///
      color Color(){return m_clr;}
   private:
      color m_clr;
};

///
/// Событие нажатия клавишы клавиатуры.
///
class EventKeyDown : public Event
{
   public:
      ///
      /// Созадет событие "нажатие клавиши".
      /// \param keyCode - Код нажатой клавиши.
      /// \param keysMask - Маска, описывающая комбинацию нажатых клавиш на клавиатуре.
      ///
      EventKeyDown(int keyCode, int keysMask) : Event(EVENT_FROM_UP, EVENT_KEYDOWN, "TERMINAL WINDOW")
      {
         code = keyCode;
         mask = keysMask;
      }
      ///
      /// Возвращает код нажатой клавишы.
      ///
      int Code(){return code;}
      ///
      /// Возвращает маску, описывающую комбинацию нажатых клавишь на компьютере.
      ///
      int Mask(){return mask;}
      Event* Clone(){return new EventKeyDown(code, mask);}
   private:
      ///
      /// Маска, описывающая комбинацию нажатых клавиш на клавиатуре.
      ///
      int mask;
      ///
      /// Код нажатой клавиши.
      ///
      int code;
};

///
/// Это событие возникает при совершении новой сделки.
///
class EventAddDeal : public Event
{
   public:
      EventAddDeal(ulong deal_id) : Event(EVENT_FROM_UP, EVENT_ADD_DEAL, "API")
      {
         dealId = deal_id;
      }
      EventAddDeal(ulong deal_id, ulong order_id) : Event(EVENT_FROM_UP, EVENT_ADD_DEAL, "API")
      {
         dealId = deal_id;
         orderId = order_id;
      }
      ///
      /// Возвращает уникальный идентификатор сделки.
      ///
      ulong DealID(){return dealId;}
      ///
      /// Возвращает ордер, на основании которого возвращен трейд.
      ///
      ulong OrderId(){return orderId;}
   private:
      ///
      /// Уникальный идентификатор сделки.
      ///
      ulong dealId;
      ///
      /// Ордер, на основании которого совершен трейд.
      ///
      ulong orderId;
};

class XmlPos;
///
/// Событие xml данные активной позиции изменились.
///
class EventXmlActPosRefresh : public Event
{
   public:
      XmlPos* GetXmlPosition(void){return xPos;}
      virtual Event* Clone()
      {
         return new EventXmlActPosRefresh(xPos);
      }
      EventXmlActPosRefresh(XmlPos* xmlPos):
      Event(EVENT_FROM_UP, EVENT_XML_ACTPOS_REFRESH, "TERMINAL_WINDOW")
      {
         xPos = xmlPos;
      }
   private:
      XmlPos* xPos;
};

#ifdef HEDGE_PANEL
///
/// Событие графическое обновление панели.
///
class EventRefreshPanel : public Event
{
   public:
      EventRefreshPanel() : Event(EVENT_FROM_UP, EVENT_REFRESH_PANEL, "HEDGE API"){;}
};
#endif