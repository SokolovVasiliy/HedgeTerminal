//+------------------------------------------------------------------+
//|                                                      HedgePanel© |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+

/*
 * ‘айл содержит конкретные реализации графических объектов, основанных на классе GNode
 */

#property copyright   "2013, , Vasiliy Sokolov, St.Petersburg, Russia."
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.001"

#include "Log.mqh"
#include "gui.mqh"

///
/// ячейка таблицы.
///
class GraphCell : public GNode
{
   public:
   ///
   /// »нициализирует независимую €чейку, не имющую родительского графического элемента.
   ///
   GraphCell(void) : GNode("cell"){};
   ///
   /// »нициализирует дочернюю €чейку, имеющую родительских графический элемент.
   ///
   GraphCell(GNode *pNode) : GNode("cell", pNode){};
};

///
/// ячейка таблицы.
///
class GraphForm : public GNode
{
   public:
      ///
      /// »нициализирует независимую графическую форму, не имющую родительского элемента.
      ///
      GraphForm() : GNode("form"){this.Init();};
      ///
      /// »нициализирует независимую графическую форму с именем myName, не имеющую родительскую форму.
      ///
      GraphForm(string myName) : GNode(myName){this.Init();};
      ///
      /// »нициализирует дочернюю графическую форму, имеющую родительский элемент.
      ///
      GraphForm(GNode *pNode) : GNode("form", pNode){this.Init();};
   private:
      void Init();
};

void GraphForm::Init(void)
{
   ObjectType = OBJ_RECTANGLE_LABEL;
}

class Panel
{
   public:
      GraphForm form;
      ///
      /// »нициализирует главную форму HedgePanel
      ///
      void Init()
      {
         //GraphForm form("general form");
         GNode* s2 = GetPointer(form);
         //GraphForm f2(s2);
         form.Resize(500, 50);
         form.SetVisible(true);
      }
      ///
      /// ƒеинициализирует главную форму HedgePanel
      ///
      void Deinit()
      {
         form.SetVisible(false);
      }
};
