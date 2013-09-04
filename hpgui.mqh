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

class hpTable : public GNode
{
   public:
      ///
      /// �������������� ����������� �������, �� ������ ������������� ��������.
      ///
      hpTable() : GNode("hpTable"){this.Init();};
      ///
      /// �������������� ����������� ������� � ������ myName, �� ������� ������������ �����.
      ///
      hpTable(string myName) : GNode(myName){this.Init();};
      ///
      /// �������������� �������� �������, ������� ������������ �������.
      ///
      hpTable(GNode *pNode) : GNode("hpTable", pNode){this.Init();};
      ///
      /// �������������� �������� ������� � ������ myName, � ������������ ��������� pNode.
      ///
      hpTable(string myName, GNode *pNode) : GNode(myName, pNode){this.Init();};
      ///
      /// ��� ����������� ���� ������� ���� ���������.
      ///
      virtual void OnVisible(bool isVisible)
      {         
         if(isVisible)
         {
            bool res = ObjectSetInteger(MAIN_WINDOW, nameId, OBJPROP_COLOR, backColor);
            if(!res)
               LogWriter("Changing color for element " + nameId + " was filed.", MESSAGE_TYPE_ERROR);
            else
               Print(nameId + " ����� ����� ������ �������");
         }
      }
      
   private:
      ///
      /// ���� �������� �������.
      ///
      color backColor;
      ///
      /// �������������.
      ///
      void Init(void);
};

void hpTable::Init()
{
   ObjectType = OBJ_RECTANGLE_LABEL;
   backColor = C'0x00,0x00,0xFF';
}

///
/// ������ �������.
///
class GeneralForm : public GNode
{
   public:
      ///
      /// �������������� ����������� ����������� �����, �� ������ ������������� ��������.
      ///
      GeneralForm() : GNode("GeneralForm"){this.Init();};
      ///
      /// �������������� ����������� ����������� ����� � ������ myName, �� ������� ������������ �����.
      ///
      GeneralForm(string myName) : GNode(myName){this.Init();};
      ///
      /// �������������� �������� ����������� �����, ������� ������������ �������.
      ///
      GeneralForm(GNode *pNode) : GNode("GeneralForm", pNode){this.Init();};
      ///
      /// �������������� �������� ����������� ����� � ������ myName, � ������������ ��������� pNode.
      ///
      GeneralForm(string myName, GNode *pNode) : GNode(myName, pNode){this.Init();};
      ///
      /// ���������� �����. ������� ��� ������� ���������� �����������.
      ///
      ~GeneralForm();
      ///
      /// ������� ����� ������������ ���� ����������.
      ///
      virtual void OnResize(long newWidth, long newHigh)
      {
         // ��������� ���� �������� ���� � ������� �� ��������
         // � ������������ � ����� ������ ���������.
         tableOpenPos.Resize(70, 70);
         Print("VirtualFunc. call");
      }
      ///
      /// ��������� ����� ������������ ���� ����������.
      ///
      virtual void OnMove(Coordinate *location)
      {
         // ��������� ���� �������� ���� � ������� �� ���������
         // � ������������ � ����� ������ ������������.
      }
   private:
      ///
      /// ������� �������� �������.
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
   //������� �������� ��� ������ �����, �� ������� �������� ���� � ������ ������ ���������.
   long thigh = 70;
   long twidth = 70;
   tableOpenPos.Resize(thigh, twidth);
   tableOpenPos.Move(0, 50 + minDist, COORDINATE_PARENT);
   tableOpenPos.SetVisible(true);
   childNodes.Add(tableOpenPos);
}
