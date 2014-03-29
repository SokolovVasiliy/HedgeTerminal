//+------------------------------------------------------------------+
//|                                                ScrollingNode.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "Node.mqh"
#include "Button.mqh"

class ScrollingNode;
///
/// Определяет тип скролла.
///
enum ENUM_SCROLL_TYPE
{
   ///
   /// Вертикальный скролл.
   ///
   SCROLL_VERTICAL,
   ///
   /// Горизонтальный скролл.
   ///
   SCROLL_HORIZONTAL
};

///
/// Скролл.
///
class NewScroll : public ProtoNode
{
   public:
      NewScroll(string myName, ProtoNode* parNode, ENUM_SCROLL_TYPE sType) : ProtoNode(OBJ_RECTANGLE_LABEL, ELEMENT_TYPE_SCROLL, myName, parNode)
      {
         //Тип скролла должен быть известен на этапе его создания
         scrollType = sType;
      }
      ///
      /// Уведомляет скролл, что положение фрейма или его размер изменился.
      ///
      void FrameChanged(){;}
      ///
      /// Связывает скролл с элементом, который необходимо скроллить.
      ///
      void LinkWithNode(ScrollingNode* node){scrolling = node;}
      ///
      /// Возвращает тип скролла.
      ///
      ENUM_SCROLL_TYPE ScrollType(void){return scrollType;}
   private:
      ///
      /// Элемент, которому задается скроллинг.
      ///
      ScrollingNode* scrolling;
      ///
      /// Тип скролла.
      ///
      ENUM_SCROLL_TYPE scrollType;
};

///
/// Тип кнопки скролла.
///
enum ENUM_SCROLL_BUTTON_TYPE
{
   SCROLL_BUTTON_UP,
   SCROLL_BUTTON_DOWN,
   SCROLL_BUTTON_LEFT,
   SCROLL_BUTTON_RIGHT,
};
///
/// Одна из четырех возможных кнопок скролла. Реализует кнопки по краям скролла.
///
class ButtonScroll : public Button
{
   public:
      ButtonScroll(NewScroll* scroll, ENUM_SCROLL_BUTTON_TYPE type) : Button("ButtonScroll", scroll)
      {
         btnScrollType = type;
         
      }
   private:
      ENUM_SCROLL_BUTTON_TYPE btnScrollType;
};

///
/// Визуальный элемент поддерживающий горизонтальный и вертикальный скролл.
///
class ScrollingNode : public ProtoNode
{
   public:
      ///
      /// Подписывает скролл на изменения узла.
      /// \param scroll - Скролл, которому необходимо знать об изменениях фрейма узла.
      ///
      void AddScroll(NewScroll* scroll)
      {
         if(scroll.ScrollType() == SCROLL_VERTICAL)
            vscroll = scroll;
         else if(scroll.ScrollType() == SCROLL_HORIZONTAL)
            gscroll = scroll;
      }
      ///
      /// Получает общую высоту элемента.
      ///
      virtual ulong ScrollVertical(){return 0;}
      ///
      /// Получает общую ширину элемента.
      ///
      virtual ulong ScrollHorizontal(){return 0;}
      ///
      /// Получает высоту видимой области элемента.
      ///
      virtual ulong ScrollFrameVertical()
      {
         return High();
      }
      ///
      /// Получает ширину видимой области элемента.
      ///
      virtual ulong ScrollFrameHorizontal()
      {
         return Width();
      }
      ///
      /// Получает дистанцию по вертикали до видимой области элемента от его верхней границы.
      ///
      virtual ulong ScrollVerticalToFrame(){return distVertical;}
      ///
      /// Получает дистанцию по горизонтали до видимой области элемента от его левой границы.
      ///
      virtual ulong ScrollHorizontalToFrame(){return distHorizontal;}
      ///
      /// Устанавливает дистанцию по вертикали до видимой области элемента от его верхней границы.
      ///
      void ScrollVerticalToFrame(ulong y)
      {
         if(ScrollVertical() == 0)return;
         if(y + ScrollFrameVertical() > ScrollVertical())
            y = ScrollVertical() - ScrollFrameVertical();
         distVertical = y;
         OnChangeFrame();
      }
      ///
      /// Устанавливает дистанцию по горизонтали до видимой области элемента от его левой границы.
      ///
      void ScrollHorizontalToFrame(ulong x)
      {
         if(ScrollHorizontal() == 0)return;
         if(x + ScrollFrameHorizontal() > ScrollHorizontal())
            x = ScrollHorizontal() - ScrollFrameHorizontal();
         distHorizontal = x;
         OnChangeFrame();
      }
   protected:
      ScrollingNode(ENUM_OBJECT mytype, ENUM_ELEMENT_TYPE myElementType, string myname, ProtoNode* parNode) :
      ProtoNode(mytype, myElementType, myname, parNode){;}
      ///
      /// Вызывается, когда скролл изменяет дистанцию до фрейма.
      ///
      virtual void OnChangeFrame(){;}
      ///
      /// Уведомляет скролл об изменении размера фрейма.
      ///
      void ScrollNoticeByChanged()
      {
         if(vscroll != NULL)
            vscroll.FrameChanged();
         if(gscroll != NULL)
            gscroll.FrameChanged();
      }
   private:
      
      ///
      /// Указатель на вертикальный скролл.
      ///
      NewScroll* vscroll;
      ///
      /// Указатель на горизонтальный скролл.
      ///
      NewScroll* gscroll;
      ///
      /// Содержит дистанцию в пикселях по вертикали до видимой области элемента от его левой границы.
      ///
      ulong distVertical;
      ///
      /// Содержит дистанцию в пикселях по горизонтали до видимой области элемента от его левой границы. 
      ///
      ulong distHorizontal;
};
