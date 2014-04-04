#include "Node.mqh"
#resource "\\Images\\euro.bmp"
class Image : public ProtoNode
{
   public:
      Image(string myName, ProtoNode* parNode, string resfile) : ProtoNode(OBJ_BITMAP_LABEL, ELEMENT_TYPE_IMAGE, myName, parNode)
      {
         imgName = resfile;
         //imgName = "\\Images\\euro.bmp";
      }
   protected:
      string imgName;
   private:
      virtual void OnVisible(EventVisible* event)
      {
         BorderColor(clrRed);
         ResetLastError();
         bool res = ObjectSetString(MAIN_WINDOW,NameID(),OBJPROP_BMPFILE, "::Images\\euro.bmp");
         /*bool res;
         if(event.Visible())
            res = ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_BMPFILE, imgName);*/
         //if(!res)
            printf((string)GetLastError());
         EventSend(event);
      }
      /*virtual void OnCommand(EventNodeCommand* event)
      {
         if(event.Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_BMPFILE, 0, imgName);
         EventSend(event);
      }*/
};

class MenuButton : public Image
{
   public:
      MenuButton(ProtoNode* parNode) : Image("HP Menu", parNode, IMG_MENU)
      {
         imgName = IMG_MENU;
      }
};