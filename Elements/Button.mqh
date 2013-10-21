#include "TextNode.mqh"
///
/// ��������� ������
///
enum ENUM_BUTTON_STATE
{
   ///
   /// ������ ���������, ��� ������.
   ///
   BUTTON_STATE_OFF,
   ///
   /// ������ ��������, ��� ������.
   ///
   BUTTON_STATE_ON
};
///
/// ����� "������".
///
class Button : public TextNode
{
   public:
      
      Button(string myName, ProtoNode* parNode) : TextNode(OBJ_BUTTON, ELEMENT_TYPE_BOTTON, myName, parNode)
      {
         BorderColor(clrBlack);
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
            FontColor(clrBlack);
         else
            FontColor(clrDimGray);
         
      }
      virtual void OnPush()
      {
         //bool state = ObjectGetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE);
         ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_STATE, false);
         //prinf("MSC: " + );
         //if(state)
         //   printf("������ ������");
         //else
         //   printf("������ ������");
      }
};