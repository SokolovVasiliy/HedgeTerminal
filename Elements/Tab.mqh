#include "Node.mqh"
///
/// Класс вкладки.
///
class Tab : public ProtoNode
{
   public:
      Tab(ProtoNode* protoNode) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_TAB, "Tab", protoNode)
      {
         //Конфигурируем вкладки
         BorderType(BORDER_FLAT);
         BackgroundColor(clrWhite);
         clrShadowTab = clrGainsboro;
         //Создаем панель управления влкадками
         comPanel = new Line("TabComPanel", GetPointer(this));
         comPanel.AlignType(LINE_ALIGN_SCALE);
         
         //Конфигурируем кнопки вкладок
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
         
         //Конфигурируем заглушки.
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
         
         //Внедряем таблицу открытых позиций в окно вкладок.
         openPos = new TableOpenPos(GetPointer(this));
         childNodes.Add(openPos);
      }
      
   private:
      virtual void OnEvent(Event* event)
      {
         if(event.Direction() == EVENT_FROM_UP)
         {
            // Ловим событие нажатия одной из кнопок панели
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
                     //Кнопка нажата?
                     if(state == BUTTON_STATE_OFF)
                     {
                        btn.BackgroundColor(BackgroundColor());
                        //Перемещаем заглушку к новой кнопке
                        btnActive = btn;
                        EventNodeCommand* command2 = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), btnActive.XLocalDistance()+1,
                        comPanel.YLocalDistance()-1, btnActive.Width()-2, 5);
                        sstub.Event(command2);
                        delete command2;
                        
                        //Значит все остальные кнопки отжаты
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
                     //Эту кнопку можно отжать только другой кнопкой.
                     else
                     {
                        btn.State(BUTTON_STATE_OFF);
                        btn.BackgroundColor(BackgroundColor());
                        //Значит все остальные кнопки отжаты
                        for(int k = 0; k < btnArray.Total(); k++)
                        {
                           if(k == i)continue;
                           Button* aBtn = btnArray.At(k);
                           aBtn.State(BUTTON_STATE_ON);
                        }
                     }
                  }
               }
               // Если это какая-то другая нажатая кнопка, отправляем событие для нее.
               if(sendEvent)
                  EventSend(event);
               else
                  ChartRedraw(MAIN_WINDOW);
               //Для изменений вида кнопок делаем Refresh();
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
         //Определяем положение заглушки.
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
         
         //Определяем местоположение таблицы
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, Width(), High()-25);
         openPos.Event(command);
         delete command;
         //Конфигурируем заглушку.
         EventNodeCommand* command2 = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), btnActive.XLocalDistance()+1,
         comPanel.YLocalDistance()-3, btnActive.Width()-2, 5);
         sstub.Event(command2);
         delete command2;
      }
      ///
      /// Панель управления табами.
      ///
      Line* comPanel;
      ///
      /// Заглушка для панели кнопок.
      ///
      Label* stub;
      ///
      /// Заглушка для активной кнопки.
      ///
      Label* sstub;
      ///
      /// Активирует влкдку "Активные позиции".
      ///
      Button* btnActivPos;
      ///
      /// Активирует вкладку "Исторические позиции".
      ///
      Button* btnHistoryPos;
      ///
      /// Текущая активная кнопка.
      ///
      Button* btnActive;
      ///
      /// Таблица открытых позиций.
      ///
      TableOpenPos* openPos;
      
      ///
      /// Массив кнопок.
      ///
      CArrayObj btnArray;
      ///
      /// Цвет неактивной вкладки.
      ///
      color clrShadowTab;
};