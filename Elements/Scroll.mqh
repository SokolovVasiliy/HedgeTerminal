#include "Node.mqh"
#include "Table.mqh"

class Toddler;

///
/// 
///
class LabToddle : public Label
{
   public:
      LabToddle(ProtoNode* parNode, Table* tbl) : Label(ELEMENT_TYPE_LABTODDLER, "LabToddler", parNode)
      {
         if(parNode != NULL && parNode.TypeElement() == ELEMENT_TYPE_TODDLER)
            tdl = parNode;
         blockedComm = false;
         table = tbl;
         Text("");
         ReadOnly(true);
         prevY = -1;
      }
   private:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_MOUSE_MOVE:
               OnMouseMove(event);
               break;
            default:
               EventSend(event);
         }
      }
      ///
      /// Перемещает позунок в след за мышью.
      ///
      void OnMouseMove(EventMouseMove* event)
      {
         // Текущий объект должен находится под курсором мыши, а
         // правая кнопка должна быть нажата. В противном случае
         // обнуляем предыдущую y координату мыши.
         if(!IsMouseSelected(event) ||
            !event.PushedLeftButton())
         {
            prevY = -1;
            tdl.BlockedCommand(false);
            return;
         }
         //В первый раз просто запоминаем положение мыши
         if(prevY == -1)
         {
            prevY = event.YCoord();
            tdl.BlockedCommand(true);
            return;
         }
         //Затем двигаем ползунок на изменившееся положение
         long delta = event.YCoord() - prevY;
         long yLocal = YLocalDistance();
         long yLimit = yLocal + High() + delta;
         //Ползунок не может заходит за нижнюю границу направляющей.
         if(delta > 0 && yLimit > parentNode.High())
            delta = parentNode.High() - High() - yLocal;
         //Ползунок не может заходит за верхнюю границу направляющей.
         if(delta < 0 && yLocal < MathAbs(delta))
            delta = yLocal * (-1);
         //Делаем зазоры для красоты.
         if(yLocal + delta == 0)delta += 1;
         if(yLimit >= parentNode.High())
            delta -= 1;
         Move(XLocalDistance(), yLocal + delta, COOR_LOCAL);
         prevY = event.YCoord();
         
         //Теперь, когда ползунок передвинут, рассчитываем
         //первую видимую строку в таблице
         yLocal = YLocalDistance();
         long parHigh = parentNode.High();
         //Зазоры используемые для красоты убираем.
         if(yLocal == 1) yLocal--;
         if(yLocal + High() == parentNode.High()-1)
            yLocal++;
         //Рассчитываем % отступа от первой строки
         double perFirst = yLocal/((double)parHigh);
         int lineFirst = (int)(table.LinesTotal() * perFirst);
         table.LineVisibleFirst(lineFirst);
         ChartRedraw();
         //printf("Scroll FL: " + table.LineVisibleFirst() + " Visible: " + table.LinesVisible());
      }
      ///
      /// Указатель на таблицу, видимость элементов которых надо изменять.
      ///
      Table* table;
      ///
      /// Предыдущая вертикальная координата мыши.
      ///
      long prevY;
      ///
      /// Истина, если треубется заблокировать обработку события EventNodeCommand,
      /// на время перемещения ползунка.
      ///
      bool blockedComm;
      ///
      /// Направляющая ползунка.
      ///
      Toddler* tdl;
};
///
/// Направляющая ползунка скрола. Задает его размер, в зависимости от отношения видимых и невидимых строк. 
///
class Toddler : public Label
{
   public:
      Toddler(ProtoNode* parNode, Table* tbl) : Label(ELEMENT_TYPE_TODDLER, "Toddler", parNode)
      {
         blockedComm = false;
         Text("");
         BorderColor(parNode.BackgroundColor());
         ReadOnly(true);
         labToddle = new LabToddle(GetPointer(this), tbl);
         childNodes.Add(labToddle);
         table = tbl;  
      }
      ///
      /// Блокирует либо восстанавилвает обработку OnCommand на время движения скрола.
      ///
      void BlockedCommand(bool blocked)
      {
         if(blockedComm != blocked)
            blockedComm = blocked;
      }
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(table == NULL || blockedComm)return;
         // 1. Находим отношение всех строк к видимым строкам:
         double p1 = table.LinesHighTotal() == 0 ? 0 : ((double)table.LinesHighVisible())/((double)table.LinesHighTotal());
         // Если отношение больше либо равно еденице - все строки умещаются на одном
         // экране, и ползунок отображать не надо.
         if(NormalizeDouble(p1, 4) >= 1.0)
         {
            if(!labToddle.Visible())return;
            EventVisible* vis = new EventVisible(EVENT_FROM_UP, GetPointer(this), false);
            labToddle.Event(vis);
            delete vis;
            return;
         }
         // Размер ползунка - это размер отношения видимых пользователю
         // строк к общей высоте всех строк.
         else
         {
            // Переводим отношение в размеры ползунка относительно его направляющей
            long size = (long)(High()*p1);
            //Ползунок не может быть меньше 5 пикселей.
            if(size < 5)size = 5;
            //Положение полузнка - это отношение первой видимой строки к общему количеству строк.
            int fl = table.LineVisibleFirst();
            int ltotal = table.LinesTotal();
            double p2 = 0.0; 
            bool vis = true;
            if(ltotal > 0)
               p2 = ((double)table.LineVisibleFirst())/((double)table.LinesTotal());
            else vis = false;
            long yMyDist = (long)(p2*High());
            //long yMyDist = labToddle.YLocalDistance();
            if(yMyDist == 0)yMyDist = 1;
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), vis, 1, yMyDist, Width()-2, size);
            labToddle.Event(command);
            delete command;
         }
      }
      ///
      /// Ползунок, находящийся на области хода ползунка.
      ///
      LabToddle* labToddle;
      ///
      /// Указатель на родительскую таблицу.
      ///
      Table* table;
      ///
      /// Флаг указывающий, надо ли блокировать комманду EventNodeCommand.
      /// Истина, если комманда блокируется и ложь в противном случае.
      ///
      bool blockedComm;
};
///
/// Тип кнопки скрола.
///
enum ENUM_CLICK_SCROLL
{
   CLICK_SCROLL_DOWN,
   CLICK_SCROLL_UP
};

class ClickScroll : public Button
{
   public:
      ClickScroll(ProtoNode* parNode, Table* tbl, ENUM_CLICK_SCROLL tClick) : Button("ScrollClickDn", parNode)
      {
         if(parNode.TypeElement() == ELEMENT_TYPE_SCROLL)
            scroll = parNode;
         typeClick = tClick;
         Text(CharToString(241));
         if(typeClick == CLICK_SCROLL_DOWN)
         {
            itt = 1;
            Text(CharToString(242));
         }
         else itt = -1;
         Font("Wingdings");
         
         BackgroundColor(clrWhiteSmoke);
         BorderColor(clrBlack);
         table = tbl;
      }
   private:
      virtual void OnEvent(Event* event)
      {
         switch(event.EventId())
         {
            case EVENT_MOUSE_MOVE:
               OnMouseMove(event);
               break;
            default:
               EventSend(event);
         }
      }
      ///
      /// Обрабатываем нажатия кнопок мыши.
      ///
      void OnMouseMove(EventMouseMove* event)
      {
         if(!IsMouseSelected(event) || !event.PushedLeftButton())
         {
            //Сбрасываем время нажатия.
            lastCall = 0;
            return;
         }
         //В первый раз просто запоминаем время нажатия
         if(lastCall == 0)
         {
            lastCall = GetTickCount();
            return;
         }
         //Если прошло более 2 секунд с момента нажатия кнопки, начинаем реагировать
         //На комманду.
         if(GetTickCount() - lastCall >= 1500)
            OnPush();
      }
      void OnPush()
      {
         int fline = table.LineVisibleFirst();
         int vline = table.LinesVisible();
         //Весь список отображен?
         if(fline + vline >= table.LinesTotal() && itt == 1)
            return;
         //Достигнуто начало списка.
         if(fline == 0 && itt == -1)   
            return;
         table.LineVisibleFirst(fline+itt);
         //Меняем цвет кнопок, если пределы достигнуты:
         fline = table.LineVisibleFirst();
         vline = table.LinesVisible();
         if(scroll != NULL)
            scroll.ChangedScroll();
      }
      ///
      /// Таблица.
      ///
      Table* table;
      ///
      /// Родительский скролл.
      ///
      Scroll* scroll;
      ///
      /// Тип кнопки скрола.
      ///
      ENUM_CLICK_SCROLL typeClick;
      ///
      /// Количество прибавляемых линий.
      ///
      int itt;
      ///
      /// Время работы терминала в миллисекундах на момент последнего
      /// вызова функции OnMouseMove. 
      ///
      long lastCall;
      ///
      /// Время последнего вызова события EventMouse.
      ///
      long lastEventMouse;
};

///
/// Прокрутка списка.
///
class Scroll : public ProtoNode
{
   public:
      Scroll(string myName, ProtoNode* parNode) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         BackgroundColor(clrWhiteSmoke); 
         //у скрола есть две кнопки и ползунок.
         up = new ClickScroll(GetPointer(this), parNode, CLICK_SCROLL_UP);
         childNodes.Add(up);
         
         dn = new ClickScroll(GetPointer(this), parNode, CLICK_SCROLL_DOWN);
         childNodes.Add(dn);
         
         toddler = new Toddler(GetPointer(this), parentNode);
         childNodes.Add(toddler);
      }
      ///
      /// Изменяет положение ползунка скрола в зависимости
      /// от состояния видимой части таблицы.
      ///
      void ChangedScroll()
      {
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 1, 18, Width()-2, High()-36);
         toddler.Event(command);
         delete command;
      }
      
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         //Позиционируем верхнюю кнопку.
         EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, 2, 16, 16);
         up.Event(command);
         delete command;
         
         //Позиционируем нижнюю кнопку.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 2, High()-18, 16, 16);
         dn.Event(command);
         delete command;
         
         //Позиционируем ползунок.
         //Ползунок должен выбирать свою Y координату самостоятельно.
         command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 1, 18, Width()-2, High()-36);
         toddler.Event(command);
         delete command;
      }
      //у скрола есть две кнопки и ползунок.
      ClickScroll* up;
      ClickScroll* dn;
      Toddler* toddler;
};
