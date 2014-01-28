#include "TextNode.mqh"

///
/// Класс "Кнопка".
///
class Button : public Label
{
   public:
      Button(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode) : Label(elType, myName, parNode)
      {
         SetColorsFromSettings();
      }
      Button(string myName, ProtoNode* parNode) : Label(ELEMENT_TYPE_BOTTON, myName, parNode)
      {
         SetColorsFromSettings();
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
      virtual void SetColorsFromSettings(void)
      {
         color m_borderColor;
         color m_bgColor;
         if(CheckPointer(Settings) != POINTER_INVALID)
         {
            m_borderColor = Settings.ColorTheme.GetBorderColor();
            m_bgColor = Settings.ColorTheme.GetSystemColor1();
         }
         else
         {
            m_borderColor = clrBlack;
            m_bgColor = clrWhiteSmoke;
         }
         BorderColor(m_borderColor);
         BackgroundColor(m_bgColor);
      }
      ///
      /// Обработчик события статус 'видимости внешнего узла изменен'.
      /// \param event - Событие типа 'видимость внешнего узла изменена'.
      ///
      void VisibleExtern(EventVisible* event)
      {
         bool vis = event.Visible();
         Visible(vis);
         EventVisible* ev = new EventVisible(EVENT_FROM_UP, GetPointer(this), Visible());
         EventSend(ev);
         delete ev;
      }
};

class ButtonClosePos : public Button
{
   public:
      ButtonClosePos(string myName, ProtoNode* parNode) : Button(myName, parNode)
      {
         FontColor(clrDimGray);
      }
   protected:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_MOUSE_MOVE:
               OnMouseMove(event);
            default:
               EventSend(event);
               break;
         }
      }
      void OnMouseMove(EventMouseMove* event)
      {
         bool res = true;
         long x = event.XCoord();
         long xAbs = XAbsDistance();
         if(x > xAbs + Width() || x < xAbs)res = false;
         long y = event.YCoord();
         long yAbs = YAbsDistance();
         if(y > yAbs + High() || y < yAbs)res = false;
         if(res)
            FontColor(clrCrimson);
         else
            FontColor(clrDimGray);
         
      }
      virtual void OnPush()
      {
         //bool state = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE, false);
         //Генерируем событие "Поступила команда закрыть позицию"
         EventClosePos* event = new EventClosePos(NameID());
         EventSend(event);
         delete event;
      }
};