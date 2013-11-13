#include "Node.mqh"
#include "Label.mqh"
#include "Line.mqh"
#include <Arrays\ArrayObj.mqh>
///
/// Класс Вкладки
///
class TabFlat : public Label
{
   public:
      TabFlat(ProtoNode* protoNode) : Label(ELEMENT_TYPE_TAB, "TabFlat", protoNode)
      {
         //Задаем свойства самого таба
         ReadOnly(true);
         BorderColor(clrWhiteSmoke);
         colorBorder = clrBlack;
         iActive = 0;
         
         //Конфигурируем заглушку таба
         activeStub = new Label(ELEMENT_TYPE_LABEL, "activeStub", GetPointer(this));
         activeStub.Text("");
         activeStub.ReadOnly(true);
         activeStub.BorderColor(clrWhite);
         childNodes.Add(activeStub);
         
         //Инициализируем массивы и задаем ширину и высоту каждого таба
         btnHigh = 25;
         btnWidth = 70;
         
         //Инициализируем рабочую область таба.
         workArea = new Label(ELEMENT_TYPE_LABEL, "tabWorkArea", GetPointer(this));
         workArea.Text("");
         workArea.BorderColor(colorBorder);
         workArea.ReadOnly(true);
         childNodes.Add(workArea);
      }
      ///
      /// Добавляет кнопку табуляции, с именем text.
      /// \param text - Название кнопки табуляции. 
      /// \param node - Графический узел, который будет размещаться
      /// на рабочей области табулятора.
      void AddTab(string btnText, ProtoNode* node)
      {
         // Только значимые объекты.
         if(CheckPointer(node) == POINTER_INVALID)return;
         // Создаем новый таб и помещаем его в списки вместе с узлом, который он
         // будет отображать, а также заглушкой.
         
         //Создаем кнопку и задаем ее свойства.
         Label* btn = new Label(ELEMENT_TYPE_LABEL, btnText, GetPointer(this));
         btn.BorderColor(colorBorder);
         btn.Align(ALIGN_CENTER);
         btn.ReadOnly(true);
         childNodes.Add(btn);
         ArrayButtons.Add(btn);
         
         //Помещаем узел который будет отображать этот таб в специальный и общий списки.
         ArrayNodes.Add(node);
         childNodes.Add(node);
      }
      ///
      /// Удаляет кнопку табуляции, с именем text
      ///
      void DeleteTab(string btnText){;}
   private:
      ///
      /// Позиционируем внутренности таба
      ///
      virtual void OnCommand(EventNodeCommand* event)
      {
         AlocationTab();
      }
      ///
      /// Позиционирует табулятор
      ///
      void AlocationTab()
      {
         if(!Visible()) return;
         //Позиционируем рабочую область
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 0, 0, Width(), High()-btnHigh);
         workArea.Event(command);
         delete command;
         int total = ArrayButtons.Total();
         //Размещаем одну кнопку за другой
         for(int i = 0; i < total; i++)
         {
            Label* btn = ArrayButtons.At(i);
            int s = i > 0 ? -1 : 0;
            EventNodeCommand* mcommand = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 5+s+i*btnWidth, High()-btnHigh-1, btnWidth, btnHigh);
            btn.Event(mcommand);
            delete mcommand;
            if(i != iActive)
            {
               //Скрываем графический узел отображающийся на этой вкладке, если он не скрыт.
               ProtoNode* mnode = ArrayNodes.At(i);
               VisibleNode(mnode, false);
               btn.BackgroundColor(clrWhiteSmoke);
               btn.FontColor(clrGray);
            }
         }
         //Заглушка создается и перемещается в самом конце, чтобы быть поверх всех кнопок.
         if(iActive < total)
         {
            Label* btn = ArrayButtons.At(iActive);
            //Позиционируем графический узел на этой вкладке, растягивая его по всей доступной площади.
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
      /// Скрывает либо отображает узел mnode.
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
            //Была нажата кнопка? - если да, то какая?
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
      /// Содержит ширину каждой кнопки.
      ///
      int btnWidth;
      ///
      /// Содержит высоту каждой кнопки.
      ///
      int btnHigh;
      ///
      /// Панель табов.
      ///
      Line* comPanel;
      ///
      /// Рабочая область табулятора.
      ///
      Label* workArea;
      ///
      /// Список графических узлов, индекс которых соответствует индексу
      /// кнопки отображающей/скрывающей изображение рабочего узла на
      /// рабочей области табулятора.
      ///
      CArrayObj ArrayNodes;
      ///
      /// Список кнопок табулятора, отображающих/скрывающих изображение
      /// узлов на рабочей области табулятора, связанных с этими кнопками.
      ///
      CArrayObj ArrayButtons;
      ///
      /// Список заглушек для каждой из кнопок табулятора.
      ///
      CArrayObj* ArrayStubs;
      ///
      /// Цвет рамки табулятора и кнопок.
      ///
      color colorBorder;
      ///
      /// Содержит индекс включенного в данный момент таба.
      ///
      int iActive;
      ///
      /// Заглушка, скрывающая верхнюю границу активной кнопки.
      ///
      Label* activeStub;
};