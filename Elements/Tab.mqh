#include "Node.mqh"
///
/// ����� �������.
///
class Tab : public ProtoNode
{
   public:
      Tab(ProtoNode* protoNode) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_TAB, "Tab", protoNode)
      {
         //������������� �������
         BorderType(BORDER_FLAT);
         BackgroundColor(clrWhite);
         clrShadowTab = clrGainsboro;
         //������� ������ ���������� ���������
         comPanel = new Line("TabComPanel", GetPointer(this));
         comPanel.AlignType(LINE_ALIGN_SCALE);
         
         //������������� ������ �������
         btnActivPos = new Button("Active", GetPointer(comPanel));
         btnActivPos.OptimalWidth(100);
         btnActivPos.BorderColor(clrBlack);
         btnArray.Add(btnActivPos);
         btnActive = btnActivPos;
         comPanel.Add(btnActivPos);
         
         btnHistoryPos = new Button("History", GetPointer(comPanel));
         btnHistoryPos.OptimalWidth(100);
         btnHistoryPos.BorderColor(clrBlack);
         btnArray.Add(btnHistoryPos);
         comPanel.Add(btnHistoryPos);
         
         //������������� ��������.
         /*stub = new Label("stub", GetPointer(comPanel));
         stub.Text("");
         if(parentNode != NULL)
         {
            stub.BorderColor(parentNode.BackgroundColor());
            stub.BackgroundColor(parentNode.BackgroundColor());
         }
         stub.ReadOnly(false);
         comPanel.Add(stub);*/
         childNodes.Add(comPanel);
         
         sstub = new Label("stub2", GetPointer(this));
         sstub.Text("");
         sstub.BorderColor(BackgroundColor());
         sstub.BackgroundColor(BackgroundColor());
         sstub.ReadOnly(false);
         childNodes.Add(sstub);
         
         //�������� ������� �������� ������� � ���� �������.
         openPos = new TableOpenPos(GetPointer(this));
         childNodes.Add(openPos);
      }
      
   private:
      virtual void OnEvent(Event* event)
      {
         if(event.Direction() == EVENT_FROM_UP)
         {
            // ����� ������� ������� ����� �� ������ ������
            if(event.EventId() == EVENT_OBJ_CLICK)
            {
               ENUM_BUTTON_STATE myState = btnHistoryPos.State();
               EventObjectClick* push = event;
               string btnName = push.PushObjName();
               bool sendEvent = true;
               for(int i = 0; i < btnArray.Total(); i++)
               {
                  Button* btn = btnArray.At(i);
                  if(btn.NameID() == btnName)
                  {
                     sendEvent = false;
                     ENUM_BUTTON_STATE state = btn.State();
                     //������ ������?
                     if(state == BUTTON_STATE_OFF)
                     {
                        btn.BackgroundColor(BackgroundColor());
                        //���������� �������� � ����� ������
                        btnActive = btn;
                        EventNodeCommand* command2 = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), btnActive.XLocalDistance()+1,
                        comPanel.YLocalDistance()-1, btnActive.Width()-2, 5);
                        sstub.Event(command2);
                        delete command2;
                        
                        //������ ��� ��������� ������ ������
                        for(int k = 0; k < btnArray.Total(); k++)
                        {
                           if(k == i)continue;
                           Button* aBtn = btnArray.At(k);
                           aBtn.State(BUTTON_STATE_ON);
                           //aBtn.BackgroundColor(clrDarkGray);
                           ENUM_BUTTON_STATE currState = aBtn.State();
                           if(currState == BUTTON_STATE_ON)
                           {
                              aBtn.BackgroundColor(clrShadowTab);
                           }
                        }
                     }
                     //��� ������ ����� ������ ������ ������ �������.
                     else
                     {
                        btn.State(BUTTON_STATE_OFF);
                        btn.BackgroundColor(BackgroundColor());
                        //������ ��� ��������� ������ ������
                        for(int k = 0; k < btnArray.Total(); k++)
                        {
                           if(k == i)continue;
                           Button* aBtn = btnArray.At(k);
                           aBtn.State(BUTTON_STATE_ON);
                        }
                     }
                  }
               }
               // ���� ��� �����-�� ������ ������� ������, ���������� ������� ��� ���.
               if(sendEvent)
                  EventSend(event);
               else
                  ChartRedraw(MAIN_WINDOW);
               //��� ��������� ���� ������ ������ Refresh();
               if(true)
               {
                  EventRefresh* er = new EventRefresh(EVENT_FROM_DOWN, NameID());
                  parentNode.Event(er);
                  delete er;
               }
            }
            else
               EventSend(event);
         }
         else
            EventSend(event);
      }
      
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN)return;
         //���������� ��������� ��������.
         bool vis = comPanel.Visible();
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, High()-25, Width(), 25);
         comPanel.Event(command);
         delete command;
         if(!vis && vis != comPanel.Visible())
         {
            btnActivPos.BackgroundColor(BackgroundColor());
            btnHistoryPos.BackgroundColor(clrShadowTab);
            btnHistoryPos.State(BUTTON_STATE_ON);
            ENUM_BUTTON_STATE state = btnHistoryPos.State();
            //ChartRedraw(MAIN_WINDOW);
         }
         
         //���������� �������������� �������
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, Width(), High()-25);
         openPos.Event(command);
         delete command;
         //������������� ��������.
         EventNodeCommand* command2 = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), btnActive.XLocalDistance()+1,
         comPanel.YLocalDistance()-3, btnActive.Width()-2, 5);
         sstub.Event(command2);
         delete command2;
      }
      ///
      /// ������ ���������� ������.
      ///
      Line* comPanel;
      ///
      /// �������� ��� ������ ������.
      ///
      Label* stub;
      ///
      /// �������� ��� �������� ������.
      ///
      Label* sstub;
      ///
      /// ���������� ������ "�������� �������".
      ///
      Button* btnActivPos;
      ///
      /// ���������� ������� "������������ �������".
      ///
      Button* btnHistoryPos;
      ///
      /// ������� �������� ������.
      ///
      Button* btnActive;
      ///
      /// ������� �������� �������.
      ///
      TableOpenPos* openPos;
      
      ///
      /// ������ ������.
      ///
      CArrayObj btnArray;
      ///
      /// ���� ���������� �������.
      ///
      color clrShadowTab;
};