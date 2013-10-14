#include "TextNode.mqh"
///
/// “екстова€ метка
///
class Label : public TextNode
{
   public:
      Label(string myName, ProtoNode* node) : TextNode(OBJ_EDIT, ELEMENT_TYPE_LABEL, myName, node){;}
      void Edit(bool edit)
      {
         isEdit = edit;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_READONLY, isEdit);
      }
      ///
      /// ¬озвращает режим редактировани€ текстовой метки.
      ///
      bool Edit(){return isEdit;}
      ///
      /// ¬озвращает текст метки.
      ///
      //string Text(){return text;}
   private:
      virtual void OnVisible(EventVisible* event)
      {
         int d = 5;
         if(Text() == CharToString(74))
            d = 8;
         Text(Text());
         Font(Font());
         FontSize(FontSize());
         FontColor(FontColor());
         Edit(Edit());
         //ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_COLOR, clrBlack);
      }
      ///
      /// »стина, если текстова€ метка может редактироватьс€ пользователем, ложь, в противном случае.
      ///
      bool isEdit;
      ///
      /// “екущий текст, который отображаетс€ в текстовой метке.
      ///
      string text;
      
};