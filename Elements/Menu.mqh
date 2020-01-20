#include <Files\File.mqh>
#include <Files\FileTxt.mqh>
#include "..\Log.mqh"
#include "..\API\Position.mqh"
#include "..\Settings.mqh"
#include "..\Resources\Resources.mqh"
///
/// Перечисляет тип элемента меню.
///
enum ENUM_MENU_ELEMENT
{
   ///
   /// Меню показывает окно "About".
   ///
   MENU_ABOUT,
   ///
   /// Сохраняет отчет.
   ///
   MENU_SAVE_REPORT,
   ///
   /// Переустанавливает файлы настроек.
   ///
   MENU_INSTALL_FILES,
   ///
   /// Скрывает хеджируемые позиции.
   ///
   MENU_HIDE_HEDGE_POSITIONS
};

///
/// Класс элемента меню.
///
class ElementMenu : public Label
{
   public:
      ElementMenu(ENUM_MENU_ELEMENT mElement, string mName, ProtoNode* node) : Label(mName, node)
      {
         element = mElement;
      }
   private:
      ///
      /// Реагируем на нажатие.
      ///
      virtual void OnPush()
      {
         //По-умолчанию, до обработки нажатия, скрываем меню.
         HideParentMenu();
         switch (element)
         {
            case MENU_ABOUT:
               OnMenuAbout();
               break;
            case MENU_SAVE_REPORT:
               OnMenuSaveReport();
               break;
            case MENU_HIDE_HEDGE_POSITIONS:
               OnMenuHideHedge();
               break;
         }
      }
      ///
      /// Показывает соообщение "О программе..."
      ///
      void OnMenuAbout()
      {
         string message = "HedgeTerminal is designed for hedging net positions in MetaTrader 5 and " + 
                          "simple controls expert advisors." +
                          "                                                                " +
                          "For suggestions and comments, please contact with author at https://login.mql5.com/ru/users/c-4" +
                          "                                                              " +
                          "Copyright 2013-2016, Vasiliy Sokolov, St.-Petersburg, Russia.";
         
         MessageBox(message, VERSION, MB_ICONASTERISK);
      }
      ///
      /// Сохраняет отчет в виде CSV файла.
      ///
      void OnMenuSaveReport()
      {         
         report.SaveToFile(REPORT_CSV);
      }
      ///
      /// Скрывает родительское меню.
      ///
      void HideParentMenu()
      {
         EventVisible* event = new EventVisible(EVENT_FROM_DOWN, GetPointer(this), false);
         EventSend(event);
         delete event;
      }
      
      void OnMenuHideHedge()
      {
         if(api.ActivePosTotal() == 0)
         {
            MessageBox("Active position not find.", VERSION, MB_OK);
            return;
         }
         if(PositionsTotal() != 0)
         {
            int total = PositionsTotal();
            MessageBox("Detect " + (string)total + " active netto-position(s). Close position and try letter", VERSION, MB_OK);
            return;
         }
         int id = MessageBox("Are you sure you want to close a position?", VERSION, MB_OKCANCEL);
         if(id != IDOK)return;
         api.HideHedgePositions();
      }
      
      ENUM_MENU_ELEMENT element;
};

class StartButton;
///
/// Меню панели.
///
class Menu : public Label
{
   public:
      Menu(ProtoNode* startBtn, ProtoNode* node) : Label("Menu", node)
      {
         startButton = startBtn;
         //Высота одного элемента меню.
         highEl = 20;
         //Save Report
         ElementMenu* m = new ElementMenu(MENU_SAVE_REPORT, "Save CSV Report", GetPointer(this));
         m.BorderColor(Settings.ColorTheme.GetSystemColor2());
         childNodes.Add(m);
         //Reinstall files.
         //m = new ElementMenu(MENU_INSTALL_FILES, "Reinstall files", GetPointer(this));
         //m.BorderColor(Settings.ColorTheme.GetSystemColor2());
         //childNodes.Add(m);
         //About Hedge Terminal
         
         m = new ElementMenu(MENU_HIDE_HEDGE_POSITIONS, "Hide Hedge Positions", GetPointer(this));
         m.BorderColor(Settings.ColorTheme.GetSystemColor2());
         childNodes.Add(m);
         
         m = new ElementMenu(MENU_ABOUT, "About HedgeTerminal", GetPointer(this));
         m.BorderColor(Settings.ColorTheme.GetSystemColor2());
         childNodes.Add(m);
         
      }
      ///
      /// Возвращает высоту одного элемента меню.
      ///
      ulong GetHighElement(){return highEl;}
   private:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_MOUSE_MOVE:
               OnMouseMove(event);
               break;
            case EVENT_NODE_VISIBLE:
               OnHideMenu(event);
               break;
            default:
               EventSend(event);
               break;
         }
      }
      void OnMouseMove(EventMouseMove* event)
      {
         for(int i = 0; i < childNodes.Total(); i++)
         {
            ProtoNode* node = childNodes.At(i);
            if(node.IsMouseSelected(event))
               node.BackgroundColor(clrGainsboro);
            else
               node.BackgroundColor(Settings.ColorTheme.GetSystemColor2());
         }
      }
      virtual void OnCommand(EventNodeCommand* event)
      {
         //Текущее положение элемента меню по оси y.
         ulong y = 1;
         for(int i = 0; i < childNodes.Total(); i++)
         {
            ProtoNode* node = childNodes.At(i);
            EventNodeCommand* vis = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 1, y, Width()-2, highEl);
            node.Event(vis);
            delete vis;
            y += highEl;
         }
      }
      ///
      /// Скрывает меню по приказу одного из его элементов
      ///
      void OnHideMenu(EventVisible* event)
      {
         if(event.Direction() != EVENT_FROM_DOWN)
            return;
         startButton.PushOff();
      }
      ulong highEl;
      ///
      /// Ссылка на главную кнопку меню.
      ///
      StartButton* startButton;
};

///
/// Центральная кнопка меню панели.
///
class StartButton : public Button
{
   public:
      StartButton(ProtoNode* node) : Button("Start Button", ELEMENT_TYPE_START_MENU, node)
      {
         menu = new Menu(GetPointer(this), ParentNode());
         childNodes.Add(menu);
      }
      ~StartButton()
      {
         if(CheckPointer(menu) != POINTER_INVALID)
         {
            HideMenu();
            delete menu;
         }
      }
      
      ///
      /// Отжимает кнопку.
      ///
      void PushOff()
      {
         if(State()== BUTTON_STATE_ON)
            State(BUTTON_STATE_OFF);
      }
   private:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_NODE_CLICK:
               OnNodeClick(event);
               break;
            case EVENT_MOUSE_MOVE:
               OnMouseMove(event);
            default:
               menu.Event(event);
               break;
         }
      }
      void OnMouseMove(EventMouseMove* event)
      {
         if(IsMouseSelected(event))
            BackgroundColor(clrLightSteelBlue);
         else if(State() == BUTTON_STATE_OFF)
            BackgroundColor(Settings.ColorTheme.GetSystemColor1());
      }
      void OnNodeClick(EventNodeClick* event)
      {
         if(State() == BUTTON_STATE_ON)
            State(BUTTON_STATE_OFF);
      }
      ///
      /// Показывает/скрывает меню при нажатии.
      ///
      virtual void OnPush()
      {
         if(State() == BUTTON_STATE_ON)
            ShowMenu();
         else
            HideMenu();
      }
      ///
      /// Показывает меню.
      ///
      void ShowMenu()
      {
         ulong x = XAbsDistance();
         ulong y = YAbsDistance()+High()+1;
         ulong elHigh = menu.GetHighElement();
         ulong h = 60;
         if(elHigh > 0)
            h = menu.ChildsTotal()*elHigh+menu.ChildsTotal();
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), true, x, y, 160, h);
         menu.Event(command);
         delete command;
      }
      ///
      /// Скрывает меню.
      ///
      void HideMenu()
      {
         EventVisible* event = new EventVisible(EVENT_FROM_UP, GetPointer(this), false);
         menu.Event(event);
         delete event;
      }
      ///
      /// Меню.
      ///
      Menu* menu;
};

