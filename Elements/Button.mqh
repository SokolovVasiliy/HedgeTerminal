#include "TextNode.mqh"
#include "..\Events.mqh"

///
/// ����� "������".
///
class Button : public TextNode
{
   public:
      Button(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode) : TextNode(OBJ_BUTTON, elType, myName, parNode)
      {
         SetColorsFromSettings();
      }
      Button(string myName, ProtoNode* parNode) : TextNode(OBJ_BUTTON, ELEMENT_TYPE_BOTTON, myName, parNode)
      {
         SetColorsFromSettings();
      }
      ///
      /// ���������� ��������� ������. ���� ������ �������� ��� ������ ���������� false.
      /// ���� ������ ������ - ���������� true;
      ///
      ENUM_BUTTON_STATE State()
      {
         if(!Visible())return BUTTON_STATE_OFF;
         bool state = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE);
         if(state)return BUTTON_STATE_ON;
         return BUTTON_STATE_OFF;
      }
      ///
      /// ������������� ������ � ������� ��� ������� ���������. ������ ������ ������������ � ����.
      /// \param state - ���������, � ������� ��������� ���������� ������.
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
         //if(CheckPointer(Settings) != POINTER_INVALID)
         //{
            m_borderColor = Settings.ColorTheme.GetBorderColor();
            m_bgColor = Settings.ColorTheme.GetSystemColor1();
         //}
         //else
         //{
            //m_borderColor = clrBlack;
            //m_bgColor = clrWhiteSmoke;
         //}
         BorderColor(m_borderColor);
         BackgroundColor(m_bgColor);
      }
      ///
      /// ���������� ������� ������ '��������� �������� ���� �������'.
      /// \param event - ������� ���� '��������� �������� ���� ��������'.
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
      virtual void FontColor(color clr)
      {
         if(clr == Settings.ColorTheme.GetTextColor())
            Button::FontColor(clrDimGray);
         else
            Button::FontColor(clr);
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
         if(IsMouseSelected(event))
            FontColor(clrCrimson);
         else
            FontColor(clrDimGray);
         
      }
      virtual void OnPush()
      {
         //bool state = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE, false);
         //���������� ������� "��������� ������� ������� �������"
         EventClosePos* event = new EventClosePos(NameID());
         EventSend(event);
         delete event;
      }
};
