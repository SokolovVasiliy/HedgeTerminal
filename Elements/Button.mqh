///
/// Состояние кнопки
///
enum ENUM_BUTTON_STATE
{
   ///
   /// Кнопка выключена, или отжата.
   ///
   BUTTON_STATE_OFF,
   ///
   /// Кнопка включена, или нажата.
   ///
   BUTTON_STATE_ON
};
///
/// Класс "Кнопка".
///
class Button : public TextNode
{
   public:
      
      Button(string myName, ProtoNode* parNode) : TextNode(OBJ_BUTTON, ELEMENT_TYPE_BOTTON, myName, parNode)
      {
         BorderColor(clrBlack);
      }
      ///
      /// Возвращает состояние кнопки. Если кнопка невидима или отжата возвращает false.
      /// Если кнопка нажата - возвращает true;
      ///
      ENUM_BUTTON_STATE State()
      {
         if(!Visible())return BUTTON_STATE_OFF;
         bool state = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE);
         if(state)return BUTTON_STATE_ON;
         return BUTTON_STATE_OFF;
      }
      ///
      /// Устанавливает кнопку в нажатое или отжатое состояние. Кнопка должна отображаться в окне.
      /// \param state - Состояние, в которое требуется установить кнопку.
      ///
      void State(ENUM_BUTTON_STATE set_state)
      {
         if(!Visible())return;
         ENUM_BUTTON_STATE state = State();
         if(set_state != state)
         {
            bool flag;
            if(set_state == BUTTON_STATE_OFF) flag = false;
            else flag = true;
            bool rez = ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE, flag);
            if(rez)OnPush();
         }
      }
   protected:
      ///
      /// Каждый потомок должен самостоятельно определить свои действия,
      /// при нажатии кнопки.
      ///
      virtual void OnPush(){;}
      //
      virtual void OnEvent(Event* event)
      {
         int id = event.EventId();
         if(id == EVENT_BUTTON_PUSH)
         {
            EventButtonPush* push = event;
            if(push.ButtonName() == NameID())
            {
               OnPush();
               //После каждого нажатия кнопки принудительно обновляем окно
               ChartRedraw(MAIN_WINDOW);
            }
            
         }
         else
            EventSend(event);
      }
      
      ///
      /// Обработчик события статус 'видимости внешнего узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         Visible(vis);
         EventVisible* ev = new EventVisible(EVENT_FROM_UP, NameID(), Visible());
         EventSend(ev);
         delete ev;
      }
};

class ButtonClosePos : public Button
{
   public:
      ButtonClosePos(string myName, ProtoNode* parNode) : Button(myName, parNode){;}
   protected:
      virtual void OnPush()
      {
         //bool state = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE, false);
         //prinf("MSC: " + );
         //if(state)
         //   printf("Кнокпа нажата");
         //else
         //   printf("Кнокпа отжата");
      }
};