#include "Node.mqh"
#include "Label.mqh"
#include "Line.mqh"
#include <Arrays\ArrayObj.mqh>
///
/// ����� �������
///
class TabFlat : public Label
{
   public:
      TabFlat(ProtoNode* protoNode) : Label(ELEMENT_TYPE_TAB, "TabFlat", protoNode)
      {
         //������ �������� ������ ����
         ReadOnly(true);
         BorderColor(clrWhiteSmoke);
         colorBorder = clrBlack;
         iActive = 0;
         
         //������������� �������� ����
         activeStub = new Label(ELEMENT_TYPE_LABEL, "activeStub", GetPointer(this));
         activeStub.Text("");
         activeStub.ReadOnly(true);
         activeStub.BorderColor(clrWhite);
         childNodes.Add(activeStub);
         
         //�������������� ������� � ������ ������ � ������ ������� ����
         btnHigh = 25;
         btnWidth = 70;
         
         //�������������� ������� ������� ����.
         workArea = new Label(ELEMENT_TYPE_LABEL, "tabWorkArea", GetPointer(this));
         workArea.Text("");
         workArea.BorderColor(colorBorder);
         workArea.ReadOnly(true);
         childNodes.Add(workArea);
      }
      ///
      /// ��������� ������ ���������, � ������ text.
      /// \param text - �������� ������ ���������. 
      /// \param node - ����������� ����, ������� ����� �����������
      /// �� ������� ������� ����������.
      void AddTab(string btnText, ProtoNode* node)
      {
         // ������ �������� �������.
         if(CheckPointer(node) == POINTER_INVALID)return;
         // ������� ����� ��� � �������� ��� � ������ ������ � �����, ������� ��
         // ����� ����������, � ����� ���������.
         
         //������� ������ � ������ �� ��������.
         Label* btn = new Label(ELEMENT_TYPE_LABEL, btnText, GetPointer(this));
         btn.BorderColor(colorBorder);
         btn.Align(ALIGN_CENTER);
         btn.ReadOnly(true);
         childNodes.Add(btn);
         ArrayButtons.Add(btn);
         
         //�������� ���� ������� ����� ���������� ���� ��� � ����������� � ����� ������.
         ArrayNodes.Add(node);
         childNodes.Add(node);
      }
      ///
      /// ������� ������ ���������, � ������ text
      ///
      void DeleteTab(string btnText){;}
   private:
      ///
      /// ������������� ������������ ����
      ///
      virtual void OnCommand(EventNodeCommand* event)
      {
         AlocationTab();
      }
      ///
      /// ������������� ���������
      ///
      void AlocationTab()
      {
         if(!Visible()) return;
         //������������� ������� �������
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, Width(), High()-btnHigh);
         workArea.Event(command);
         delete command;
         int total = ArrayButtons.Total();
         //��������� ���� ������ �� ������
         for(int i = 0; i < total; i++)
         {
            Label* btn = ArrayButtons.At(i);
            int s = i > 0 ? -1 : 0;
            EventNodeCommand* mcommand = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 5+s+i*btnWidth, High()-btnHigh-1, btnWidth, btnHigh);
            btn.Event(mcommand);
            delete mcommand;
            if(i != iActive)
            {
               //�������� ����������� ���� �������������� �� ���� �������, ���� �� �� �����.
               ProtoNode* mnode = ArrayNodes.At(i);
               VisibleNode(mnode, false);
               btn.BackgroundColor(clrWhiteSmoke);
               btn.FontColor(clrGray);
            }
         }
         //�������� ��������� � ������������ � ����� �����, ����� ���� ������ ���� ������.
         if(iActive < total)
         {
            Label* btn = ArrayButtons.At(iActive);
            //������������� ����������� ���� �� ���� �������, ���������� ��� �� ���� ��������� �������.
            ProtoNode* mnode = ArrayNodes.At(iActive);
            command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), XLocalDistance()+1, YLocalDistance()+1, Width()-2, High()-btnHigh-2);
            mnode.Event(command);
            delete command;
            VisibleNode(mnode, true);
            btn.BackgroundColor(clrWhite);
            btn.FontColor(clrBlack);
            command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), btn.XLocalDistance(), btn.YLocalDistance(), btnWidth, 1);
            activeStub.Event(command);
            delete command;
         }
      }
      ///
      /// �������� ���� ���������� ���� mnode.
      ///
      void VisibleNode(ProtoNode* mnode, bool status)
      {
         if(mnode.Visible() != status)
         {
            EventVisible* mvisible = new EventVisible(EVENT_FROM_UP, GetPointer(this), status);
            mnode.Event(mvisible);
            delete mvisible;
            ChartRedraw();
         }
      }
      virtual void OnEvent(Event* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN &&
            event.EventId() == EVENT_NODE_CLICK)
         {
            //���� ������ ������? - ���� ��, �� �����?
            for(int i = 0; i < ArrayButtons.Total(); i++)
            {
               Label* btn = ArrayButtons.At(i);
               ProtoNode* mnode = event.Node();
               if(GetPointer(btn) == GetPointer(mnode))
               {
                  iActive = i;
                  AlocationTab();
                  break;
               }
            }
         }
         else
            EventSend(event);
      }
      ///
      /// �������� ������ ������ ������.
      ///
      int btnWidth;
      ///
      /// �������� ������ ������ ������.
      ///
      int btnHigh;
      ///
      /// ������ �����.
      ///
      Line* comPanel;
      ///
      /// ������� ������� ����������.
      ///
      Label* workArea;
      ///
      /// ������ ����������� �����, ������ ������� ������������� �������
      /// ������ ������������/���������� ����������� �������� ���� ��
      /// ������� ������� ����������.
      ///
      CArrayObj ArrayNodes;
      ///
      /// ������ ������ ����������, ������������/���������� �����������
      /// ����� �� ������� ������� ����������, ��������� � ����� ��������.
      ///
      CArrayObj ArrayButtons;
      ///
      /// ������ �������� ��� ������ �� ������ ����������.
      ///
      CArrayObj* ArrayStubs;
      ///
      /// ���� ����� ���������� � ������.
      ///
      color colorBorder;
      ///
      /// �������� ������ ����������� � ������ ������ ����.
      ///
      int iActive;
      ///
      /// ��������, ���������� ������� ������� �������� ������.
      ///
      Label* activeStub;
};