#include "Node.mqh"
#include "Table.mqh"

///
/// 
///
class LabToddle : public Label
{
   public:
      LabToddle(ProtoNode* parNode, Table* tbl) : Label(ELEMENT_TYPE_LABTODDLER, "LabToddler", parNode)
      {
         table = tbl;
         Text("");
         Edit(true);
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
            !event.PushedRightButton())
         {
            prevY = -1;
            return;
         }
         //В первый раз просто запоминаем положение мыши
         if(prevY == -1)
         {
            prevY = event.YCoord();
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
      }
      ///
      /// Указатель на таблицу, видимость элементов которых надо изменять.
      ///
      Table* table;
      ///
      /// Предыдущая вертикальная координата мыши.
      ///
      long prevY;
};
///
/// Направляющая ползунка скрола. Задает его размер, в зависимости от отношения видимых и невидимых строк. 
///
class Toddler : public Label
{
   public:
      Toddler(ProtoNode* parNode, Table* tbl) : Label(ELEMENT_TYPE_TODDLER, "Toddler", parNode)
      {
         BorderColor(parNode.BackgroundColor());
         Edit(true);
         labToddle = new LabToddle(GetPointer(this), tbl);
         childNodes.Add(labToddle);
         table = tbl;  
      }
      
   private:
      virtual void OnCommand(EventNodeCommand* event)
      {
         if(table == NULL)return;
         // 1. Находим отношение всех строк к видимым строкам:
         double p1 = ((double)table.LinesHighVisible())/((double)table.LinesHighTotal());
         // Если отношение больше либо равно еденицы - все строки умещаются на одном
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
            long yMyDist = labToddle.YLocalDistance();
            if(yMyDist == 0)yMyDist = 1;
            EventNodeCommand* command = new EventNodeCommand(EVENT_FROM_UP, NameID(), Visible(), 1, yMyDist, Width()-2, size);
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
};
///
/// Прокрутка списка.
///
class Scroll : public ProtoNode
{
   public:
      Scroll(string myName, ProtoNode* parNode) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         //у скрола есть две кнопки и ползунок.
         up = new Button("UpClick", GetPointer(this));
         up.BorderType(BORDER_FLAT);
         up.BorderColor(clrBlack);
         //up.BorderColor(clrNONE);
         up.Font("Wingdings");
         up.Text(CharToString(241));
         up.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(up);
         
         dn = new Button("DnClick", GetPointer(this));
         dn.BorderType(BORDER_FLAT);
         dn.BorderColor(clrBlack);
         //dn.BorderColor(clrNONE);
         dn.Font("Wingdings");
         dn.Text(CharToString(242));
         dn.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(dn);
         
         toddler = new Toddler(GetPointer(this), parentNode);
         //toddler.BorderType(BORDER_FLAT);
         //toddler.BorderColor(clrBlack);
         //toddler.BorderColor(clrNONE);
         toddler.Text("");
         toddler.BackgroundColor(clrWhiteSmoke);
         childNodes.Add(toddler);
         
         BackgroundColor(clrWhiteSmoke); 
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
      Button* up;
      Button* dn;
      Toddler* toddler;
};
