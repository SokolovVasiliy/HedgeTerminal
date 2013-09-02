//+------------------------------------------------------------------+
//|                                                      HedgePanel� |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+

/*
 * ���� �������� ���������� ���������� ����������� ��������, ���������� �� ������ GNode
 */

#property copyright   "2013, , Vasiliy Sokolov, St.Petersburg, Russia."
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.001"

#include "Log.mqh"
#include "gui.mqh"

///
/// ������ �������.
///
class GraphCell : public GNode
{
   public:
   ///
   /// �������������� ����������� ������, �� ������ ������������� ������������ ��������.
   ///
   GraphCell(void) : GNode("cell"){};
   ///
   /// �������������� �������� ������, ������� ������������ ����������� �������.
   ///
   GraphCell(GNode *pNode) : GNode("cell", pNode){};
};

///
/// ������ �������.
///
class GraphForm : public GNode
{
   public:
      ///
      /// �������������� ����������� ����������� �����, �� ������ ������������� ��������.
      ///
      GraphForm() : GNode("form"){this.Init();};
      ///
      /// �������������� ����������� ����������� ����� � ������ myName, �� ������� ������������ �����.
      ///
      GraphForm(string myName) : GNode(myName){this.Init();};
      ///
      /// �������������� �������� ����������� �����, ������� ������������ �������.
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
      /// �������������� ������� ����� HedgePanel
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
      /// ���������������� ������� ����� HedgePanel
      ///
      void Deinit()
      {
         form.SetVisible(false);
      }
};
