#include "..\Events.mqh"
#include "Node.mqh"
#include "Label.mqh"
///
/// ��� ����� ��������������� ������
///
enum ENUM_BOX_TREE_TYPE
{
   BOX_TREE_GENERAL,
   BOX_TREE_SLAVE,
   BOX_TREE_ENDSLAVE
};
///
/// ��������� ������: ���������/�������.
///
enum ENUM_BOX_TREE_STATE
{
   ///
   /// ������ �������.
   ///
   BOX_TREE_COLLAPSE,
   ///
   /// ������ ���������.
   ///
   BOX_TREE_RESTORE
};

class TreeViewBox : public Label
{
   public:
      TreeViewBox(string nameCheck, ProtoNode* parNode, ENUM_BOX_TREE_TYPE treeType) : Label(ELEMENT_TYPE_TREE_VIEW, nameCheck, parNode)
      {
         // � ����������� ���������� �������?
         //if(parNode != NULL && parNode.TypeElement() == ELEMENT_TYPE_TREE_VIEW)
         //   isGrafh = true;
         //else
         //{
            isGrafh = false;
            boxTreeType = treeType;
            //� ������� �������?
            /*if(treeType == BOX_TREE_GENERAL)
            {
               twb = new TreeViewBox(nameCheck+"+", GetPointer(this), BOX_TREE_GENERAL);
               twb.BorderColor(clrBlack);
               childNodes.Add(twb);
            }*/
         //}
         SetColorsFromSettings();
         ReadOnly(true);
         Font("Arial");
         Align(ALIGN_CENTER);
         //�� ��������� ������ �������.
         state = BOX_TREE_COLLAPSE;
         if(/*isGrafh && */boxTreeType == BOX_TREE_GENERAL && state == BOX_TREE_COLLAPSE)
            Text("+");
         else if(/*isGrafh && */boxTreeType == BOX_TREE_GENERAL && state == BOX_TREE_RESTORE)
            Text("-");
         else if(boxTreeType != BOX_TREE_GENERAL)
            Text(CharToString(3));
         else
            Text("");
      }
      ENUM_BOX_TREE_STATE State(){return state;}
      ///
      /// ������������� ���� ����������� ������.
      ///
      virtual void OnPush()
      {
         //��������� �� �������� � �������� ������ � ��� ������, ���� ��� ������.
         if(boxTreeType == BOX_TREE_GENERAL)
         {
            //������ ���������������
            if(State() == BOX_TREE_COLLAPSE)
            {
               state = BOX_TREE_RESTORE;
               //if(isGrafh)
                  Text("-");
               //else twb.Text("-");
               //������� ������� "������ ���������".
               
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
               //������� ������� "������ �������".
               //string name = parentNode.NameID();
               EventCollapseTree* ctree = new EventCollapseTree(EVENT_FROM_DOWN, parentNode, true);
               //ctree.NeedRefresh();
               EventSend(ctree);
               delete ctree;
            }
         }
      }
   private:
      /*virtual void OnCommand(EventNodeCommand* event)
      {
         if(isGrafh || twb == NULL)return;
         //������������� ������.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 5, 5, 13, 13);
         twb.Event(command);
         twb.Align(ALIGN_CENTER);
         delete command;
      }*/
      ENUM_BOX_TREE_TYPE boxTreeType;
      ///
      /// ��������� ������.
      ///
      ENUM_BOX_TREE_STATE state;
      ///
      /// ������, ���� ������� ������� �������� ������������ ��������������� ������
      ///
      bool isGrafh;
      TreeViewBox* twb;
};

class TreeViewBoxBorder : public Label
{
   public:
      TreeViewBoxBorder(string nameCheck, ProtoNode* parNode, ENUM_BOX_TREE_TYPE TreeType) : Label(ELEMENT_TYPE_TREE_BORDER, nameCheck, parNode)
      {
         needRefresh = true;
         ReadOnly(true);
         treeType = TreeType;
         if(treeType == BOX_TREE_GENERAL)
         {
            //printf("Create bew TWB, Name: " + nameCheck);
            brdGeneral = new BorderGeneral(GetPointer(this));
            childNodes.Add(brdGeneral);
            //Text(CharToString(5));
         }
         else if(treeType == BOX_TREE_SLAVE)
            Text(CharToString(5));
         else
            Text(CharToString(3));
      }
      void OnEvent(Event* event)
      {
         //if(event.Direction() == EVENT_FROM_DOWN)
         //{
            if(event.EventId() == EVENT_OBJ_CLICK)
               OnPush();
         //}
      }
      ProtoNode* ParentNode(){return parentNode;}      
      
      ///
      /// ���������� ������ ������� ������.
      ///
      ENUM_BOX_TREE_STATE State()
      {
         return state;
      }
      ///
      /// �������� ������. ������������� � ����������� ������.
      ///
      virtual void OnPush()
      {
         //��������� �� �������, ������ ���� ������� ������� ������ ������������ ������
         if(treeType == BOX_TREE_GENERAL)
         {
            //������ ��� �������? - ������ ������ ���������������.
            if(state == BOX_TREE_COLLAPSE)
            {
               state = BOX_TREE_RESTORE;
               if(brdGeneral != NULL)
                  brdGeneral.Text("-");
               if(parentNode.TypeElement() != ELEMENT_TYPE_POSITION)return;
               ENUM_ELEMENT_TYPE el_type = parentNode.TypeElement();
               EventCollapseTree* collapse = new EventCollapseTree(EVENT_FROM_DOWN, parentNode, false);
               collapse.NeedRefresh(needRefresh);
               EventSend(collapse);
               delete collapse;
            }
            //������ ��� ���������? - ������ ������ �������������.
            else if(state == BOX_TREE_RESTORE)
            {
               state = BOX_TREE_COLLAPSE;
               if(brdGeneral != NULL)
                  brdGeneral.Text("+");
               EventCollapseTree* collapse = new EventCollapseTree(EVENT_FROM_DOWN, parentNode, true);
               collapse.NeedRefresh(needRefresh);
               EventSend(collapse);
               delete collapse;
            }
         }
      }
      virtual void FontColor(color clrFont)
      {
         brdGeneral.FontColor(clrFont);  
      }
      void NeedRefresh(bool refresh){needRefresh = refresh;}
   private:      
      
      virtual void OnCommand(EventNodeCommand* event)
      {
         // ������������� ������ � �����
         if(brdGeneral != NULL)
         {
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 3, 14, 14);
            brdGeneral.Event(command);
            delete command;
         }
      }
      virtual void OnVisible(EventVisible* event)
      {
         
         // �������� ��� ���������� ������.
         if(CheckPointer(brdGeneral) != POINTER_INVALID)
         {
            ReadOnly(true);
            EventVisible* vis = new EventVisible(EVENT_FROM_UP, GetPointer(this), Visible());
            brdGeneral.Event(vis);
            delete vis;
         }
      }
      
      class BorderGeneral : public Label
      {
         public:
            BorderGeneral(ProtoNode* twb) : Label(ELEMENT_TYPE_TREE_BORDER, "TreeBorder", twb)
            {
               if(twb == NULL || twb.TypeElement() != ELEMENT_TYPE_TREE_BORDER)return;
               treeViewBox = twb;
               ReadOnly(true);
               BorderColor(clrBlack);
               BackgroundColor(parentNode.BackgroundColor());
               Align(ALIGN_LEFT);
               FontSize(8);
               Text("+");
            }
            
            virtual void FontColor(color clrFont)
            {
               TextNode::FontColor(clrFont);
               TextNode::BorderColor(clrFont);
            }
         private:
            //�������� ������� ������ ������������ ��������
            virtual void OnPush()
            {
               if(parentNode != NULL)
               {
                  treeViewBox.OnPush();
               }
            }
            TreeViewBoxBorder* treeViewBox;
      };
      ///
      /// ������������ ������� 
      ///
      BorderGeneral* brdGeneral;
      ///
      /// ��������� ������.
      ///
      ENUM_BOX_TREE_STATE state;
      ///
      /// ��� ��������.
      ///
      ENUM_BOX_TREE_TYPE treeType;
      bool needRefresh;
};