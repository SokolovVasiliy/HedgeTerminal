#include "Node.mqh"

class CheckBox : public Button
{
   public:
      CheckBox(string nameCheck, ProtoNode* parNode) : Button(nameCheck, ELEMENT_TYPE_CHECK_BOX, parNode)
      {
         
         Font("Wingdings");
         checked = false;
         uchar ch[] = {168};
         Text(CharArrayToString(ch, 0, 1, CP_SYMBOL));
      }
      bool Checked(){return checked;}
   private:
      virtual void OnPush()
      {
         if(State() == BUTTON_STATE_OFF)
         {
            checked = false;
            uchar ch[] = {168};
            Text(CharArrayToString(ch, 0, 1, CP_SYMBOL));
         }
         else
         {
            checked = true;
            uchar ch[] = {254};
            Text(CharArrayToString(ch, 0, 1, CP_SYMBOL));
            //BackgroundColor(Settings.ColorTheme.GetSystemColor2());
         }
         if(ChildsTotal() > 0)
         {
            EventCheckBoxChanged* checkBox = new EventCheckBoxChanged(EVENT_FROM_UP, GetPointer(this), checked);
            EventSend(checkBox);
            delete checkBox;;
         }
         if(parentNode != NULL)
         {
            EventCheckBoxChanged* checkBox = new EventCheckBoxChanged(EVENT_FROM_DOWN, GetPointer(this), State());
            EventSend(checkBox);
            delete checkBox;
         }
      }
      bool checked;
};
