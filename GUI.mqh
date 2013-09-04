#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Object.mqh>
#include <Arrays\List.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Log.mqh"

///
/// Идентификатор окна графика на котором запущена панель.
///
#define MAIN_WINDOW 0
///
/// Идентификатор подокна графика, на котором запущена панель.
///
#define MAIN_SUBWINDOW 0

///
/// Пользовательское событие: родительский графический узел передвинут.
///
#define EVENT_PARENTNODE_MOVE 1

///
/// Пользовательское событие: родительский графический узел изменил размер.
///
#define EVENT_PARENTNODE_RESIZE 2

///
/// Определяет к какому углу привязан текущий графический элемент.
///
enum ENUM_TYPE_COORDINATE
{
   ///
   /// Текущий графический элемент привязан к окну отрисовки.
   ///
   COORDINATE_WINDOW,
   ///
   /// Текущий графический элемент привязан к углу своего родительского графического элемента.
   ///
   COORDINATE_PARENT
};
///
/// Содержит относительные и абсолютные координаты текущего графического узла.
///
class Coordinate
{
   public:
   ///
   /// Расстояние в пикселях от угла привязки графического узла до края основного окна по горизонтали.
   ///
   long WinX;
   ///
   /// Расстояние в пикселях от угла привязки графического узла до края основного окна по вертикали.
   ///
   long WinY;
   ///
   /// Расстояние в пикселях от угла привязки графического узла до края родительского узла по горизонтали.
   ///
   long ParentX;
   ///
   /// Расстояние в пикселях от угла привязки графического узла до края родительского узла по вертикали.
   ///
   long ParentY;
};

///
/// <b>Универсальный графический узел.</b> Каждый графический элемент, будь то кнопка, текстовая метка или изображение, упаковывается в специальный класс-контейнер GNode.
/// Этот класс-контейнер в свою очередь входит во внутрь такого же класса-родителя. Например кнопка с надписью находящаяся на графической форме образует трехуровневую
/// иерарахию: на самом высоком уровне находится элемент GNode представляющий визуальную форму, внутри него находится такой же элемент представляющий кнопку, а внутри этого
/// элемента будет находится последний графический узел представляющий надпись.
///
class GNode : CObject
{
   public:
      ///
      /// Изменяет размер графического узла node на новый. В случае успеха вызывает функцию OnResize узла, размер
      /// которого был изменен.
      /// \param *node - графический узел, размер которого требуется изменить.
      /// \param newWidth - новая ширина графического узла.
      /// \param newHigh - новая высота графического узла.
      /// \return Истина, если размер был изменен, ложь - в противном случае.
      //bool Resize(GNode *node, long newWidth, long newHigh){return true;}
      ///
      /// Это событие вызывается при изменении размера текущего графического узла.
      /// \param newWidth - Новая ширина текущего графического узла. 
      /// \param newHigh - Новая высота текущего графического узла.
      ///
      virtual void OnResize(long newWidth, long newHigh){;}
      ///
      /// Передвигает графический узел на новое место, задаваемое координатами location. В случае успеха вызывает
      /// функцию OnMove узла, который блы передвинут.
      /// \param *node - Указатель на узел, который требуется передвинуть.
      /// \param *location - Координаты узла, на которые требуется передвинуть узел.
      ///
      bool Move(GNode *node, Coordinate *location);
      ///
      /// Это событие вызывается при изменении координат текущего графического узла.
      /// \param *location - координаты, на которые был передвинут текущий графический узел.
      ///
      virtual void OnMove(Coordinate *location){;}
      ///
      /// Устанавливает видимость узла node. В случае успеха вызывает функцию OnVisible узла, видимость которого была изменена.
      /// \param *node - графический узел, видимость которого надо изменить.
      /// \param isVisible - флаг видимости. Истина, если графический узел требуется отобразить
      /// в окне отрисовки. Ложь, если графический узел требуется удалить с окна отрисовки.
      /// \return Истина, если изменение видимости узла прошло успешно, ложь - в противном случае.
      //bool Visible(GNode *node, bool isVisible);
      ///
      /// Это событие вызвается при изменении видимости текущего графического узла.
      /// \param isVisible - флаг видимости. Истина, если графический узел стал отображаться в окне отрисовки.
      /// Ложь, если графический узел был удален с окна отрисовки.
      ///
      virtual void OnVisible(bool isVisible){;}
      
      
      ///
      /// Передвигает текущий графический узел на новые координаты.
      /// \param newXDist - Новое расстояние в пукнтах по вертикали от угла привязки текущего графического элемента. 
      /// \param newYDist - Новое расстояние в пунтках по горизонтали от угла привязки текущего графического элемента. 
      /// \param context - Тип угла привязки текущго графического элемента.
      /// \return Истина, если передвижение прошло удачно, ложь - в противном случае.
      ///
      bool Move(int newXDist, int newYDist, ENUM_TYPE_COORDINATE context);
      ///
      /// Устанавливает новый размер для текущего графического узла.
      /// \param newWidth - новая ширина графического элемента в пунктах.
      /// \param newHigh - новая высота графического элемента в пунктах.
      /// \return Истина, если новый размер графического элемента был удачно установлен, ложь в противном случае.
      bool Resize(long newWidth, long newHigh);
      ///
      /// Устанавливает флаг видимости элемента и всех его подэлементов.
      /// \param isVisible - флаг видимости элемента. Истина, если элемент и все его подэлементы отображается на форме,
      /// ложь - в противном случае.
      ///
      void SetVisible(bool isVisible);
      ///
      /// Возвращает флаг видимости элемента и всех его подэлементов.
      /// \return Истина, если элемент и все его подэлементы видимы, ложь в противном случае.
      ///
      bool GetVisible(void);
      ///
      /// Возвращает расстояние в пунктах по горизонтали от угла привязки текущего графического элемента.
      /// 
      int GetXDistance();
      ///
      /// Возвращает расстояние в пунктах по вертикали от угла привязки текущего графического элемента.
      ///
      int GetYDistance();
      ///
      /// Возвращает ширину в пунктах текущего графического элемента.
      ///
      long GetWidth(){return width;}
      ///
      /// Возвращает высоту в пунктах текущего графического элемента.
      ///
      long GetHigh(){return high;}
      ///
      /// Устанавливает угол привязки текущего графического элемента. После вызова функции координаты будут автоматически пересчитанны таким образом, что бы их
      /// значения соответствовали выбранному типу привязки.
      /// \param ctype       - Тип угла, к которому требуется привязать элемент.
      /// \return Истина, если перерасчет координат и смена контекста выполнены успешно и ложь в обратном случае.
      bool SetCoordinatesType(ENUM_TYPE_COORDINATE ctype);
      ///
      /// Инициализирует независимый графический элемент с именем myName (имя может быть не уникальным).
      ///
      GNode(string myName);
      ///
      /// Инициализирует элемент с именем myName (может быть не уникальным) с указанием его родительского графического елемента.
      ///
      GNode(string myName, GNode *pNode);
      ///
      /// Возвращает количество дочерних элементов.
      ///
      int GetChildCount();
   protected:
      ///
      /// Указатель на родительский графический элемент.
      ///
      GNode * parentNode;
      /// <b>Дочерние элементы GNode, распологающиеся внутри текущего графического узла.</b>
      /// Внутри текущего графического узла GNode может находится
      /// неограниченное количество таких же, дочерних визуальных элементов
      /// (MQL5 не поддерживает рекурсивное объявление классов, а
      /// CArrayObj не может работать с потомками CObject, поэтому
      /// используем массив элементов CObject)
      CArrayObj childNodes;
      ///
      /// Тип объекта, лежащего в основе узла.
      ///
      ENUM_OBJECT ObjectType;
      ///
      /// Имя графического элемента (может повторятся у других графических элементов).
      ///
      string name;
      ///
      /// Минимальная дистанция в пикселях между родительским и дочерним графическим элементом
      ///
      int minDist;
      ///
      /// Уникальный идентификатор узла, однозначно определяющий его на графике.
      ///
      string nameId;
      ///
      /// Флаг видимости узла. Истина - если узел отображается на графике, ложь в противном случае.
      ///
      bool visible;
      ///
      /// Идентификатор окна, в котором отображается текущий узел.
      ///
      int chartId;
      ///
      /// Ширина графического узла GNode в пунктах.
      ///
      long width;
      ///
      /// Высота графического узла GNode в пунктах.
      ///
      long high;
      ///
      /// Дистанция в пунктах по горизонтали от угла привязки текущего графического элемента.
      ///
      int xDistance;
      ///
      /// Дистанция в пунктах по вертикали от угла привязки текущего графического элемента.
      ///
      int yDistance;
      ///
      /// Определяет к какому углу привязан текущий графический элемент. Дистанция по горизонтали и вертикале автоматически
      /// перерасчитывается в зависимости от типа привязки.
      ///
      ENUM_TYPE_COORDINATE typeCoordinate;
      ///
      /// Инициализирует графический элемент
      ///
      void Init(string myName, GNode* pNode);
      ///
      /// Генерирует уникальное имя элемента, с помощью которого можно однозначно идентифицировать
      /// элемент на графике терминала.
      ///
      void GenNameId(void);
   private:
      
      
};
GNode::GNode(string myName)
{
   Init(myName, NULL);
}

GNode::GNode(string myName, GNode *pNode)
{
   Init(myName, pNode);
}
void GNode::Init(string myName, GNode *pNode)
{     
   name = myName;
   parentNode = pNode;
   visible = false;
   xDistance = 0;
   yDistance = 0;
   typeCoordinate = COORDINATE_PARENT;
   GenNameId();
}

bool GNode::Resize(long newWidth, long newHigh)
{
   TracePush(__FUNCTION__);
   //Новые размеры не должны превышать габариты родительского узла, если он есть.
   if(CheckPointer(parentNode) != POINTER_INVALID)
   {
      long maxWidth = parentNode.GetWidth() - minDist;
      long maxHigh = parentNode.GetHigh() - minDist;
      if(newWidth >= maxWidth)newWidth = maxWidth;
      if(newHigh >= maxHigh)newHigh = maxHigh;
   }
   //Если текущий объект отображается изменяем его визуализацию.
   if(visible)
   {
      bool res = false;
      res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE, newWidth);
      if(!res)
         LogWriter("Failed resize element " + nameId + " by horizontally.", MESSAGE_TYPE_ERROR);
      res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE, newHigh);
      if(!res)
         LogWriter("Failed resize element " + nameId + " by verticaly.", MESSAGE_TYPE_ERROR);
   }
   width = newWidth;
   high = newHigh;
   OnResize(width, high);
   TracePop();
   return true;
}

bool GNode::Move(int newXDist, int newYDist, ENUM_TYPE_COORDINATE context)
{
   
   //Новые координаты не должны выходить за пределы текущего окна.
   /*if(CheckPointer(parentNode)!= INVALID_HANDLE)
   {
      ;
   }*/
   xDistance = newXDist;
   yDistance = newYDist;
   if(visible)
   {
      ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XDISTANCE, xDistance);
      ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YDISTANCE, yDistance);
   }
   return true;
}

void GNode::SetVisible(bool isVisible)
{
   //Отображаем текущий элемент
   if(isVisible && !visible)
   {
      visible = ObjectCreate(MAIN_WINDOW, nameId, ObjectType, MAIN_SUBWINDOW, xDistance, yDistance);
      ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_XSIZE, width);
      ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_YSIZE, high);
      OnVisible(visible);
      //Все подэлементы текущего элемента также автоматически становятся видимы:
      /*GNode *p = NULL;
      for(int i = 0; i < childNodes.Total(); i++)
      {
         p = childNodes.At(i);
         p.SetVisible(true);
      }*/
   }
   else if(!isVisible && visible)
   {
      //Все подэлементы текущего элемента также автоматически становятся невидимы:
      /*GNode *p = NULL;
      bool res = true;
      for(int i = 0; i < childNodes.Total(); i++)
      {
         p = childNodes.At(i);
         p.SetVisible(false);
      }*/
      visible = !ObjectDelete(MAIN_WINDOW, nameId);
      OnVisible(visible);
   }
}

void GNode::GenNameId(void)
{
   //Получаем имя с указанием его порядкового номера
   int index = GetChildCount();
   //Если объект с таким именем уже существует
   //добавляем к имени индекс, до тех пор пока имя не станет уникальным.
   int res = -1;
   while(res > 0)
      res = ObjectFind(0, name + (string)index++);
   nameId = name+(string)index;
}

int GNode::GetChildCount()
{
   if(CheckPointer(parentNode) == POINTER_INVALID)
      return 0;
   else
      return parentNode.GetChildCount();
}
