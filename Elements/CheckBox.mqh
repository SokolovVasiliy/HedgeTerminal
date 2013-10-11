
class CheckBox : public Button
{
   public:
      CheckBox(string nameCheck, ProtoNode* parNode) : Button(nameCheck, parNode)
      {
         Font("Wingdings");
         checked = false;
         Text(CharToString(168));
      }
      bool Checked(){return checked;}
   private:
      virtual void OnPush()
      {
         if(State() == BUTTON_STATE_OFF)
         {
            checked = false;
            Text(CharToString(168));
         }
         else
         {
            checked = true;
            Text(CharToString(254));
         }
      }
      bool checked;
};
