#include "..\Events.mqh"
#include "Node.mqh"
#include "Label.mqh"
///
/// Тип метки раскрывающегося списка
///
enum ENUM_BOX_TREE_TYPE
{
   BOX_TREE_GENERAL,
   BOX_TREE_SLAVE,
   BOX_TREE_ENDSLAVE
};
///
/// Состояние списка: Развернут/Свернут.
///
enum ENUM_BOX_TREE_STATE
{
   ///
   /// Список свернут.
   ///
   BOX_TREE_COLLAPSE,
   ///
   /// Список развернут.
   ///
   BOX_TREE_RESTORE
};
class TreeViewBox : public Label
{
   public:
      TreeViewBox(string nameCheck, ProtoNode* parNode, ENUM_BOX_TREE_TYPE treeType) : Label(ELEMENT_TYPE_TREE_VIEW, nameCheck, parNode)
      {
         // Я графическое оформление плюсика?
         //if(parNode != NULL && parNode.TypeElement() == ELEMENT_TYPE_TREE_VIEW)
         //   isGrafh = true;
         //else
         //{
            isGrafh = false;
            boxTreeType = treeType;
            //Я область плюсика?
            /*if(treeType == BOX_TREE_GENERAL)
            {
               twb = new TreeViewBox(nameCheck+"+", GetPointer(this), BOX_TREE_GENERAL);
               twb.BorderColor(clrBlack);
               childNodes.Add(twb);
            }*/
         //}
         Edit(true);
         Font("Arial");
         Align(ALIGN_CENTER);
         //По умолчанию список свернут.
         state = BOX_TREE_COLLAPSE;
         if(/*isGrafh && */boxTreeType == BOX_TREE_GENERAL && state == BOX_TREE_COLLAPSE)
            Text("+");
         else if(/*isGrafh && */boxTreeType == BOX_TREE_GENERAL && state == BOX_TREE_RESTORE)
            Text("-");
         else if(boxTreeType != BOX_TREE_GENERAL)
            Text("=");
         else
            Text("");
      }
      ENUM_BOX_TREE_STATE State(){return state;}
   private:
      virtual void OnPush()
      {
         //Реагируем на закрытие и открытие только в том случае, если это плюсик.
         if(boxTreeType == BOX_TREE_GENERAL)
         {
            //Список разворачивается
            if(State() == BOX_TREE_COLLAPSE)
            {
               state = BOX_TREE_RESTORE;
               //if(isGrafh)
                  Text("-");
               //else twb.Text("-");
               //Создаем событие "Список развернут".
               EventCollapseTree* ctree = new EventCollapseTree(EVENT_FROM_DOWN, parentNode, false);
               EventSend(ctree);
               delete ctree;
            }
            else
            {
               state = BOX_TREE_COLLAPSE;
               //if(isGrafh)
                  Text("+");
               //else twb.Text("+");
               //Создаем событие "Список свернут".
               //string name = parentNode.NameID();
               EventCollapseTree* ctree = new EventCollapseTree(EVENT_FROM_DOWN, parentNode, true);
               EventSend(ctree);
               delete ctree;
            }
         }
      }
      
      /*virtual void OnCommand(EventNodeCommand* event)
      {
         if(isGrafh || twb == NULL)return;
         //Позиционируем плюсик.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 5, 5, 13, 13);
         twb.Event(command);
         twb.Align(ALIGN_CENTER);
         delete command;
      }*/
      ENUM_BOX_TREE_TYPE boxTreeType;
      ///
      /// Состояние списка.
      ///
      ENUM_BOX_TREE_STATE state;
      ///
      /// Истина, если текущий элемент является подэлементом раскрывающегося списка
      ///
      bool isGrafh;
      TreeViewBox* twb;
};
