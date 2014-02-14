
///
/// ���������, ��������������� ������ ������ � �������, ��������������� ������ ������������ ����.
///
class TextNode : public ProtoNode
{
   public:
      ///
      /// ���������� ������� ��������.
      ///
      string Text(){return text;}
      ///
      /// ������������� ������� ��������.
      ///
      void Text(string newText)
      {
         text = newText;
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_TEXT, text);
      }
      ///
      /// ���������� ��� ������������� ������.
      ///
      string Font(){return font;}
      ///
      /// ������������� ��� ������������� ������.
      ///
      void Font(string myFont)
      {
         font = myFont;
         if(Visible())
            ObjectSetString(MAIN_WINDOW, NameID(), OBJPROP_FONT, font);
      }
      ///
      /// ���������� ������ ������������� ������.
      ///
      int FontSize(){return fontsize;}
      ///
      /// ������������� ������ ������������� ������.
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
      /// ������������� ������������ ������ � �����.
      ///
      void Align(ENUM_ALIGN_MODE mode)
      {
         alignMode = mode;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_ALIGN, alignMode);
      }
      ///
      /// ���������� ��� ������������ ������ � �����.
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
      /// ��������� ������� �������� ���������� ����.
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
      ///  ������� ������.
      ///
      string text;
      ///
      /// ��� ������.
      ///
      string font;
      ///
      /// ������ ������.
      ///
      int fontsize;
      ///
      /// ���� ������.
      ///
      color fontColor;
      ///
      /// ���������� ��� ������������ ������ ������ ������������ ��������.
      ///
      ENUM_ALIGN_MODE alignMode;
};

///
/// ���������, ���������������/����������� ����������� �������������� ������ � OBJ_EDIT.
/// ��� �������� ������������ ���������� ������� � ������ OBG_EDIT ������ ������������� �� ������� ������.
///
class EditNode : public TextNode
{
   public:
      EditNode(ENUM_ELEMENT_TYPE elType, string myName, ProtoNode* parNode) :
      TextNode(OBJ_EDIT, elType, myName, parNode)
      {
         //��-��������� �������������� ������ ���������.
         readOnly = true;
      }
      ///
      /// �������������, ���� ��������� ����������� �������������� ������ � ������� OBJ_EDIT
      /// \param isReadOnly - ������, ���� �������������� ������ ���������, ���� � ��������� ������.
      ///
      void ReadOnly(bool isReadOnly)
      {
         readOnly = isReadOnly;
         if(Visible())
            ObjectSetInteger(MAIN_WINDOW, NameID(), OBJPROP_READONLY, readOnly);
      }
      ///
      /// ���������� ����� �������������� ��������� �����.
      /// \return ������, ���� �������������� ������ ���������, ���� � ��������� ������.
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
      /// ��������� �������� ���� EditNode
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