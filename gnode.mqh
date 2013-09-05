#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include "events.mqh"


class ProtoNode : CObject
{
   public:
      ///
      /// Устанавливает новый размер текущего графического узла. Генерирует восходящее и нисходящее событие EventResize
      ///
      void Resize(int newWidth, int newHigh)
      {
         // 1) Проверяем, являются ли новые желаемые размеры допустимыми,
         // Не будет ли выходить текущий графический узел за пределы
         // границ родительского узла.
         //
         // 2) Переразмечаем графический узел.
         //
         // 3) Теперь, когда размер узла изменен, требуется изменить размер его содержимого.
         // Что будет храниться в этом узле проектирует класс-потомок, поэтому делегируем
         // ему переразметку своего содержимого.
         //Отправляем восходящее и нисходящее событие "Размер изменен".
         EventSend(new EventResize(EVENT_EXTERN, EVENT_NODE_RESIZE, nameId, newWidth, newHigh));
         EventSend(new EventResize(EVENT_INNER, EVENT_NODE_RESIZE, nameId, newWidth, newHigh));
      }      
      ///
      /// Блок обработки событий. Событие будет обработано методами базового класса,
      /// либо, если для его типа нет соответствующего обработчика, передано обработчику событий
      /// производного класса.
      ///
      void Event(Event* newEvent)
      {
         //Делегируем обработку события конкретному экзмепляру.
         OnEvent(newEvent);
         EventSend(newEvent);
      }
   protected:
      ///
      /// Обработчик события, который реализует конкретный экземпляр графического узла. 
      ///
      virtual void OnEvent(Event* newEvent)
      {
         ;
      }
      
      ///
      /// Указатель на родительский графический узел.
      ///
      ProtoNode *parentNode;
      ///
      /// Дочерние графические узлы.
      ///
      CArrayObj childNodes;
   private:
      ///
      /// Истина, если текущее действие над узлом вызванно его родителем.
      ///
      bool isExternCall;
      ///
      /// Уникальное имя-идентификатор графического узла.
      ///
      string nameId;
      ///
      /// Посылает событие в направлении, указанном в его типе.
      ///
      void EventSend(Event* event)
      {
         //Событие идет сверху-вниз.
         if(event.Direction() == EVENT_EXTERN)
         {
            ProtoNode* node;
            for(int i = 0; i < childNodes.Total(); i++)
            {
               node = childNodes.At(i);
               node.Event(event);
            }
         }
         //Событие идет снизу-вверх.
         if(event.Direction() == EVENT_INNER)
         {
            if(parentNode != NULL)
               parentNode.Event(event);
         }
      }
};

class TNode : CObject
{
   public:
      ///
      /// Изменяет размер текущего графического узла на новый.
      ///
      void Resize(int newWidth, int newHigh)
      {
         //Проверяем, позволяют ли рамки родительского графического
         //объекта изменить размер текущего узла на требуемый.
         //if(parentNode != NULL)
         //...
         //Детали переразметки делегируем потомку класса.
         OnResize(newWidth, newHigh);
         // Уведомляем родительский графический объект, о том,
         // что наши размеры были изменены. Но только в том случае,
         // когда изменение размеров инициировано самим объектом.
         if(parentNode != NULL)
         {
            parentNode.OnChildResize(newWidth, newHigh, nameId);
            parentNode.nameId = "sssss";
         }
      }
      
   protected:
      ///
      /// Вызывается, когда узел текущего графического объекта изменил свой размер.
      /// Внутри этой функции переразмечаем все дочерние элементы, входящие в
      /// графический объект-потомок, в соответствии с его логикой.
      ///
      virtual void OnResize(int newWidth, int newHigh){;}
      ///
      /// Принимает уведомление от дочернего графического элемента, о том,
      /// что его размеры были изменены.
      ///
      void OnChildResize(int newWidth, int newHigh, string ChildNameId)
      {
         ;
      }
      ///
      /// Вызывается, когда узел текущего графического объекта стал видим на графике или
      /// исчез с него.
      ///
      virtual void OnVisible(bool isVisible){;}
   private:
      ///
      /// Указатель на родительский графический объект.
      ///
      TNode* parentNode;
      ///
      /// Уникальное имя-идентификатор графического объекта, служащее для нахождения его на графике.
      ///
      string nameId;
      
};
///
/// Класс "прямоугольная форма".
///
class Shape : public ProtoNode
{
   ;
};

void MoveShape()
{
   Shape myShape;
   ProtoNode pNode;
   pNode.Resize(10, 20);
   myShape.Resize(10, 10);
   myShape.Resize(30, 50);
}
