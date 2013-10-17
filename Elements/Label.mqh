#include "TextNode.mqh"
///
/// ��������� �����
///
class Label : public TextNode
{
   public:
      Label(ENUM_ELEMENT_TYPE elType, string myName, ProtoNode* node) : TextNode(OBJ_EDIT, elType, myName, node)
      {
         alignMode = ALIGN_LEFT;
      }
      Label(string myName, ProtoNode* node) : TextNode(OBJ_EDIT, ELEMENT_TYPE_LABEL, myName, node)
      {
         alignMode = ALIGN_LEFT;
      }
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
      ///
      /// ���������� ����� �����.
      ///
      //string Text(){return text;}
   private:
      virtual void OnVisible(EventVisible* event)
      {
         Text(Text());
         Font(Font());
         FontSize(FontSize());
         FontColor(FontColor());
         Edit(Edit());
         Align(alignMode);
      }
      ///
      /// ������, ���� ��������� ����� ����� ��������������� �������������, ����, � ��������� ������.
      ///
      bool isEdit;
      ///
      /// ������� �����, ������� ������������ � ��������� �����.
      ///
      string text;
      ///
      /// �������� ��� ������������ ������.
      ///
      ENUM_ALIGN_MODE alignMode;
      
};