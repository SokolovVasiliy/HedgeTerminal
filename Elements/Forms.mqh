#include "Button.mqh"
///
/// Основная форма панели.
///
class MainForm : public ProtoNode
{
   public:
      MainForm():ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_FORM, "HedgePanel", NULL)
      {
         BorderType(BORDER_FLAT);
         BackgroundColor(clrWhiteSmoke);
         
         //Создаем табулятор
         tabs = new TabFlat(GetPointer(this));
         childNodes.Add(tabs);
         
         //Внедряем таблицу открытых позиций в окно вкладок.
         TablePositions* openPos = new TablePositions(GetPointer(this), TABLE_POSACTIVE);
         tabs.AddTab("Active", openPos);
         
         //Добавляем вкладку завершенных (исторических) позиций.
         openPos = new TablePositions(GetPointer(this), TABLE_POSHISTORY);
         tabs.AddTab("History", openPos);
         
         allowed = false;
         
         start = new Button("Menu", GetPointer(this));
         childNodes.Add(start);
         
         //btnMenu = new MenuButton(GetPointer(this));
         //btnMenu = new Image("HP Menu", GetPointer(this), IMG_MENU);
         //childNodes.Add(btnMenu);
         
         status = new Label("TradeStatus", GetPointer(this));
         status.ReadOnly(true);
         status.BackgroundColor(BackgroundColor());
         status.BorderColor(BackgroundColor());
         status.Font("Wingdings");
         status.Text(CharToString(76));
         status.FontSize(14);
         status.FontColor(clrRed);
         childNodes.Add(status);
         
         mailStatus = new Label("MailStatus", GetPointer(this));
         mailStatus.ReadOnly(true);
         mailStatus.BackgroundColor(BackgroundColor());
         mailStatus.BorderColor(BackgroundColor());
         mailStatus.Font("Wingdings");
         mailStatus.Text(CharToString(42));
         mailStatus.FontSize(12);
         mailStatus.FontColor(clrRed);
         childNodes.Add(mailStatus);
         
         connected = new Label("ConnectedStatus", GetPointer(this));
         connected.ReadOnly(true);
         connected.BackgroundColor(BackgroundColor());
         connected.BorderColor(BackgroundColor());
         connected.Font("Wingdings");
         connected.Text(CharToString(40));
         connected.FontSize(12);
         connected.FontColor(clrRed);
         childNodes.Add(connected);
         
      }
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(event.Direction() == EVENT_FROM_DOWN)return;
         
         //Конфигурируем местоположение таблицы
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 5, 40, Width()-10, High()-45);
         tabs.Event(command);
         delete command;
         
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-22, 2, 20, 18);
         status.Event(command);
         delete command;
         
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-55, 1, 25, 18);
         mailStatus.Event(command);
         delete command;
         
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), Width()-88, 1, 25, 18);
         connected.Event(command);
         delete command;
         
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 15, 0, 100, 30);
         start.Event(command);
         delete command;
         
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 15, 0, 100, 30);
         btnMenu.Event(command);
         delete command;
      }
      
      virtual void OnEvent(Event* event)
      {
         if(event.Direction() == EVENT_FROM_UP)
         {
            if(event.EventId() == EVENT_REFRESH)
            {
               //Проверяем возможность торговли
               bool is_allowed = TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
               bool is_expert = MQLInfoInteger(MQL_TRADE_ALLOWED);
               is_allowed = is_allowed && is_expert;
               if(is_allowed != allowed)
               {
                  allowed = is_allowed;
                  if(!is_allowed)
                  {
                     status.FontColor(clrRed);
                     status.Text(CharToString(76));
                  }
                  else
                  {
                     status.FontColor(clrGreen);
                     status.Text(CharToString(74));
                  }
               }
               bool isMail = TerminalInfoInteger(TERMINAL_EMAIL_ENABLED);
               if(isMail != mail_allowed)
               {
                  mail_allowed = isMail;
                  if(isMail)mailStatus.FontColor(clrGreen);
                  else mailStatus.FontColor(clrRed);
               }
               bool isConn = TerminalInfoInteger(TERMINAL_CONNECTED);
               if(isConnected != isConn)
               {
                  isConnected = isConn;
                  if(isConn)connected.FontColor(clrGreen);
                  else connected.FontColor(clrRed);
               }
            }
         }
         //Принимаем команды снизу на обновление терминала
         /*if(event.Direction() == EVENT_FROM_DOWN)
         {
            if(event.EventId() == EVENT_REFRESH)
            {
               EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 5, 40, Width()-10, High()-45);
               tabs.Event(command);
               //openPos.Event(command);
               delete command;
               return;
            }
         }*/
         if(event.EventId() == EVENT_REFRESH_PANEL)
         {
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 5, 40, Width()-10, High()-45);
            tabs.Event(command);
            delete command;
            return;
         }
         EventSend(event);
      }
      ///
      /// Проверяет возможно ли установить требуемую ширину. Если требуемая ширина возможна - возвращает ее,
      /// если нет, возвращает ближайшую возможную.
      /// \return Ширина узла.
      ///
      long CheckWidth(long cwidth)
      {
         if(cwidth < 100)
            return 100;
         return cwidth;
      }
      ///
      /// Проверяет возможно ли установить требуемую высоту. Если требуемая высота возможна - возвращает ее,
      /// если нет, возвращает ближайшую возможную.
      /// \return Высота узла.
      ///
      long CheckHigh(long chigh)
      {
         if(chigh < 70)
            return 70;
         return chigh;
      }
      ///
      /// Вкладки
      ///
      TabFlat* tabs;
      ///
      /// Статус торговли
      ///
      Label* status;
      ///
      /// Флаг разрешения торговли советником.
      ///
      bool allowed;
      ///
      /// Разрешение на отправку писем
      ///
      bool mail_allowed;
      ///
      /// Показывает разрешение на отправку писем.
      ///
      Label* mailStatus;
      ///
      /// Флаг подключения к серверу.
      ///
      bool isConnected;
      ///
      /// Статус подключения к серверу.
      ///
      Label* connected;
      ///
      /// Кнопка старта.
      ///
      Button* start;
      ///
      /// Графическая кнопка меню.
      ///
      Image* btnMenu;
};