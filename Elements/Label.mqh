#include "TextNode.mqh"
///
/// ��������� �����
///
class Label : public EditNode
{
   public:
      Label(ENUM_ELEMENT_TYPE elType, string myName, ProtoNode* node) : EditNode(elType, myName, node){;}
      Label(string myName, ProtoNode* node) : EditNode(ELEMENT_TYPE_LABEL, myName, node){;}
   protected:
      ///
      /// ������������� ������� �������� ��������.
      ///
      void RefreshPropertyLabel()
      {
         RefreshPropertyEditNode();
      }
   private:
      virtual void OnVisible(EventVisible* event)
      {
         if(Visible())
            RefreshPropertyLabel();
         EventSend(event);
      }
};