///
/// Прокрутка списка.
///
class Scroll : ProtoNode
{
   public:
      Scroll(string myName, ProtoNode* parNode) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         //у скрола есть две кнопки и ползунок.
         up = new Button("UpClick", GetPointer(this));
         up.BorderColor(clrNONE);
         up.Font("Wingdings");
         up.Text(CharToString(241));
         up.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(up);
         
         dn = new Button("DnClick", GetPointer(this));
         dn.BorderColor(clrNONE);
         dn.Font("Wingdings");
         dn.Text(CharToString(242));
         dn.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(dn);
         
         toddler = new Button("Todler", GetPointer(this));
         toddler.BorderType(BORDER_FLAT);
         toddler.BackgroundColor(clrWhiteSmoke);
         //toddler.BorderColor(toddler.BackgroundColor());
         childNodes.Add(toddler);
         BackgroundColor(clrWhiteSmoke); 
      }
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         //Позиционируем верхнюю кнопку.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 2, 16, 16);
         up.Event(command);
         delete command;
         
         //Позиционируем нижнюю кнопку.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, High()-16, 16, 16);
         dn.Event(command);
         delete command;
      }
      //у скрола есть две кнопки и ползунок.
      Button* up;
      Button* dn;
      Button* toddler;
};