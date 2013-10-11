class TextNode : public ProtoNode
{
   public:
      ///
      /// Возвращает надпись элемента.
      ///
      string Text(){return text;}
      ///
      /// Устанавливает надпись элемента.
      ///
      void Text(string newText)
      {
         text = newText;
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, text);
      }
      ///
      /// Возвращает имя используемого шрифта.
      ///
      string Font(){return font;}
      ///
      /// Устанавливает имя используемого шрифта.
      ///
      void Font(string myFont)
      {
         font = myFont;
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_FONT, font);
      }
      ///
      /// Возвращает размер используемого шрифта.
      ///
      int FontSize(){return fontsize;}
      ///
      /// Устанавливает размер используемого шрифта.
      ///
      void FontSize(int size)
      {
         fontsize = size;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_FONTSIZE, fontsize);
      }
      color FontColor(){return fontColor;}
      void FontColor(color clrFont)
      {
         fontColor = clrFont;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_COLOR, fontColor);
      }
   protected:
      TextNode(ENUM_OBJECT objType, ENUM_ELEMENT_TYPE elType, string myName, ProtoNode* parNode):
      ProtoNode(objType, elType, myName, parNode)
      {
         text = myName;
         font = "Arial";
         fontsize = 10;
      }
   private:
      virtual void OnVisible(EventVisible* event)
      {
         if(!Visible())return;
         Text(Text());
         Font(Font());
         FontSize(FontSize());
         FontColor(FontColor());
      }
      ///
      ///  Надпись кнопки.
      ///
      string text;
      ///
      /// Имя шрифта.
      ///
      string font;
      ///
      /// Размер шрифта.
      ///
      int fontsize;
      ///
      /// Цвет шрифта.
      ///
      color fontColor;
};