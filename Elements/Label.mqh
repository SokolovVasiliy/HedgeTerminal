#include "TextNode.mqh"
///
/// ��������� �����
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
      /// ���������� ����� �������������� ��������� �����.
      ///
      bool Edit(){return isEdit;}
      ///
      /// ���������� ����� �����.
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
      /// ������, ���� ��������� ����� ����� ��������������� �������������, ����, � ��������� ������.
      ///
      bool isEdit;
      ///
      /// ������� �����, ������� ������������ � ��������� �����.
      ///
      string text;
      
};