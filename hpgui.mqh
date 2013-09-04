//+------------------------------------------------------------------+
//|                                                      HedgePanel© |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+

/*
 * Файл содержит конкретные реализации графических объектов, основанных на классе GNode
 */

#property copyright   "2013, , Vasiliy Sokolov, St.Petersburg, Russia."
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.001"

#include "Log.mqh"
#include "gui.mqh"

///
/// Ячейка таблицы.
///
class GraphCell : public GNode
{
   public:
   ///
   /// Инициализирует независимую ячейку, не имющую родительского графического элемента.
   ///
   GraphCell(void) : GNode("cell"){};
   ///
   /// Инициализирует дочернюю ячейку, имеющую родительских графический элемент.
   ///
   GraphCell(GNode *pNode) : GNode("cell", pNode){};
};

class hpTable : public GNode
{
   public:
      ///
      /// Инициализирует независимую таблицу, не имющую родительского элемента.
      ///
      hpTable() : GNode("hpTable"){this.Init();};
      ///
      /// Инициализирует независимую таблицу с именем myName, не имеющую родительскую форму.
      ///
      hpTable(string myName) : GNode(myName){this.Init();};
      ///
      /// Инициализирует дочернюю таблицу, имеющую родительский элемент.
      ///
      hpTable(GNode *pNode) : GNode("hpTable", pNode){this.Init();};
      ///
      /// Инициализирует дочернюю таблицу с именем myName, и родительским элементом pNode.
      ///
      hpTable(string myName, GNode *pNode) : GNode(myName, pNode){this.Init();};
      ///
      /// Мой графический узел изменил свою видимость.
      ///
      virtual void OnVisible(bool isVisible)
      {         
         if(isVisible)
         {
            bool res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_COLOR, backColor);
            if(!res)
               LogWriter("Changing color for element " + nameId + " was filed.", MESSAGE_TYPE_ERROR);
            else
               Print(nameId + " смена цвета прошла успешно");
         }
      }
      
   private:
      ///
      /// Цвет подложки таблицы.
      ///
      color backColor;
      ///
      /// Инициализация.
      ///
      void Init(void);
};

void hpTable::Init()
{
   ObjectType = OBJ_RECTANGLE_LABEL;
   backColor = C'0x00,0x00,0xFF';
}

///
/// Ячейка таблицы.
///
class GeneralForm : public GNode
{
   public:
      ///
      /// Инициализирует независимую графическую форму, не имющую родительского элемента.
      ///
      GeneralForm() : GNode("GeneralForm"){this.Init();};
      ///
      /// Инициализирует независимую графическую форму с именем myName, не имеющую родительскую форму.
      ///
      GeneralForm(string myName) : GNode(myName){this.Init();};
      ///
      /// Инициализирует дочернюю графическую форму, имеющую родительский элемент.
      ///
      GeneralForm(GNode *pNode) : GNode("GeneralForm", pNode){this.Init();};
      ///
      /// Инициализирует дочернюю графическую форму с именем myName, и родительским элементом pNode.
      ///
      GeneralForm(string myName, GNode *pNode) : GNode(myName, pNode){this.Init();};
      ///
      /// Диструктор формы. Удаляет все объекты выделенные динамически.
      ///
      ~GeneralForm();
      ///
      /// Размеры моего графического узла изменились.
      ///
      virtual void OnResize(long newWidth, long newHigh)
      {
         // Перебираю свои дочерние узлы и изменяю их свойства
         // в соответствии с моими новыми размерами.
         tableOpenPos.Resize(70, 70);
         Print("VirtualFunc. call");
      }
      ///
      /// Положение моего графического узла изменилось.
      ///
      virtual void OnMove(Coordinate *location)
      {
         // Перебираю свои дочерние узлы и изменяю их положение
         // в соответствии с моими новыми координатами.
      }
   private:
      ///
      /// Таблица открытых позиций.
      ///
      hpTable* tableOpenPos;
      
      void Init();
};

GeneralForm::~GeneralForm(void)
{
   delete tableOpenPos;
}

void GeneralForm::Init()
{
   
   ObjectType = OBJ_RECTANGLE_LABEL;
   tableOpenPos = new hpTable("TableOfOpenPos", GetPointer(this));
   //Таблица занимает всю высоту формы, за вычитом верхнего меню и нижней строки состояния.
   long thigh = 70;
   long twidth = 70;
   tableOpenPos.Resize(thigh, twidth);
   tableOpenPos.Move(0, 50 + minDist, COORDINATE_PARENT);
   tableOpenPos.SetVisible(true);
   childNodes.Add(tableOpenPos);
}
