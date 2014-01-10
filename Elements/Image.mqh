#include "Node.mqh"

class Image : public ProtoNode
{
   public:
      Image(string myName, ProtoNode* parNode, string resfile) : ProtoNode(OBJ_BITMAP_LABEL, ELEMENT_TYPE_IMAGE, myName, parNode)
      {
         imgName = resfile;
      }
   protected:
      string imgName;
   private:
      virtual void OnVisible(EventVisible* event)
      {
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_BMPFILE, imgName);
         EventSend(event);
      }
};

class MenuButton : public Image
{
   public:
      MenuButton(ProtoNode* parNode) : Image("HP Menu", parNode, IMG_MENU)
      {
         imgName = IMG_MENU;
      }
};