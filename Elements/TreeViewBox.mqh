#include "..\Events.mqh"
///
/// Тип метки раскрывающегося списка
///
enum ENUM_BOX_TREE_TYPE
{
   BOX_TREE_GENERAL,
   BOX_TREE_SLAVE,
   BOX_TREE_ENDSLAVE
};

class TreeViewBox : public Button
{
   public:
      TreeViewBox(string nameCheck, ProtoNode* parNode, ENUM_BOX_TREE_TYPE treeType) : Button(nameCheck, parNode)
      {
         boxTreeType = treeType;
         Font("Arial");
         opened = false;
         if(boxTreeType == BOX_TREE_GENERAL)
            Text("+");
         else
            Text("-");
      }
      bool Opened(){return opened;}
   private:
      virtual void OnPush()
      {
         if(boxTreeType == BOX_TREE_GENERAL)
         {
            if(State() == BUTTON_STATE_OFF)
            {
               opened = false;
               Text("+");
               //Создаем событие "Список закрыт".
               EventCollapseTree* ctree = new EventCollapseTree(EVENT_FROM_DOWN, parentNode, true);
               EventSend(ctree);
               delete ctree;
            }
            else
            {
               opened = true;
               Text("-");
               //Создаем событие "Список раскрыт".
               //string name = parentNode.NameID();
               EventCollapseTree* ctree = new EventCollapseTree(EVENT_FROM_DOWN, parentNode, false);
               EventSend(ctree);
               delete ctree;
            }
         }
         
      }
      bool opened;
      ENUM_BOX_TREE_TYPE boxTreeType;
};
