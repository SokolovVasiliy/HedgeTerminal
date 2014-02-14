
///
/// Интерфейс, предоставляющий методы работы с текстом, распологающимся внутри графического узла.
///
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
      virtual void FontColor(color clrFont)
      {
         fontColor = clrFont;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_COLOR, fontColor);
      }
      ///
      /// Устанавливает выравнивание текста в метке.
      ///
      void Align(ENUM_ALIGN_MODE mode)
      {
         alignMode = mode;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_ALIGN, alignMode);
      }
      ///
      /// Возвращает тип выравнивания текста в метке.
      ///
      ENUM_ALIGN_MODE Align()
      {
         return alignMode;
      }
   protected:
      TextNode(ENUM_OBJECT objType, ENUM_ELEMENT_TYPE elType, string myName, ProtoNode* parNode):
      ProtoNode(objType, elType, myName, parNode)
      {
         text = myName;
         font = "Arial";
         fontsize = 10;
         alignMode = ALIGN_LEFT;
      }
      ///
      /// Обновляет базовые свойства текстового узла.
      ///
      void RefreshPropertyTextNode()
      {
         if(!Visible())return;
         Text(Text());
         Font(Font());
         FontSize(FontSize());
         FontColor(FontColor());
         Align(alignMode);
      }
   private:
      virtual void OnVisible(EventVisible* event)
      {
         RefreshPropertyTextNode();
         EventSend(event);
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
      ///
      /// Определяет вид выравнивания текста внутри графического элемента.
      ///
      ENUM_ALIGN_MODE alignMode;
};

///
/// Интерфейс, предоставляющий/блокирующий возможность редактирования текста в OBJ_EDIT.
/// Все элементы графического интерфейса имеющие в основе OBG_EDIT должны наследоваться от данного класса.
///
class EditNode : public TextNode
{
   public:
      EditNode(ENUM_ELEMENT_TYPE elType, string myName, ProtoNode* parNode) :
      TextNode(OBJ_EDIT, elType, myName, parNode)
      {
         //По-умолчанию редактирование текста запрещено.
         readOnly = true;
      }
      ///
      /// Устанавливает, либо блокирует возможность редактирования текста в базовом OBJ_EDIT
      /// \param isReadOnly - истина, если редактирование текста запрещено, ложь в противном случае.
      ///
      void ReadOnly(bool isReadOnly)
      {
         readOnly = isReadOnly;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_READONLY, readOnly);
      }
      ///
      /// Возвращает режим редактирования текстовой метки.
      /// \return Истина, если редактирование текста запрещено, ложь в противном случае.
      ///
      bool ReadOnly(){return readOnly;}
      
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_END_EDIT:
               OnEndEdit(event);
               break;
            default:
               EventSend(event);
         }
      }
   protected:
      ///
      /// Обновляет свойства узла EditNode
      ///
      void RefreshPropertyEditNode()
      {
         RefreshPropertyTextNode();
         ReadOnly(readOnly);
      }
   private:
      void OnEndEdit(EventEndEdit* event)
      {
         if(event.EditNode() != NameID())return;
         string ntext = ObjectGetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT);
         Text(ntext);
         EventEndEditNode* endEdit = new EventEndEditNode(GetPointer(this), Text());
         EventSend(endEdit);
         delete endEdit;
      }
      virtual void OnVisible(EventVisible* event)
      {
         if(Visible())
            RefreshPropertyEditNode();
         EventSend(event);
      }
      bool readOnly;
};