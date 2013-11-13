#include <Arrays\ArrayObj.mqh>
#define SETTINGS_MQH
///
/// �������� �������� ��������� ������.
///
class CTheme
{
   public:
      ///
      /// ���������� �������� ���� ����.
      ///
      color GetBackgroundColor(){return clrWhite;}
      ///
      /// ���������� ���� ������� ���������.
      ///
      color GetBorderColor(){return clrBlack;}
      ///
      /// ���������� ���� ��������� ���������.
      ///
      color GetSystemColor(){return clrWhiteSmoke;}
      ///
      /// ���������� ���� �������.
      ///
      color GetCursorColor(){return clrLightSteelBlue;}
};
///
/// �������� �������� �������.
///
class CNameColumns
{
   public:
      ///
      /// ���������� ��� �������� TreeViewBox.
      ///
      string Collapse(){return "CollapsePos.";}
      ///
      /// ���������� ��� ������ ����������� ������.
      ///
      string Magic(){return "Magic";}
      ///
      /// ���������� ��� ������ �������.
      ///
      string Symbol(){return "Symbol";}
      ///
      /// ���������� ��� ������ ������������ id ��������� ������.
      ///
      string EntryOrderId(){return "Entry Order ID";}
};

///
/// �������� ������ �������.
///
class CWidthColumns
{
   public:
      ///
      /// ���������� ������ �������� TreeViewBox.
      ///
      long Collapse(){return 20;}
      ///
      /// ���������� ������ ������ ����������� ������.
      ///
      long Magic(){return 60;}
      ///
      /// ���������� ������ ������ �������.
      ///
      long Symbol(){return 60;}
      ///
      /// ���������� ������ ������ ������������ id ��������� ������.
      ///
      long EntryOrderId(){return 90;}
};

///
/// �����, ���������� ��� ����������� �������� ��������
///
class CElement : public CObject
{
   public:
      ///
      /// ��-���������, ��������������� �����������, ������� ����������� ��� �������� ��������.
      ///
      CElement(string name, long width, bool constW)
      {
         elementName = name;
         elementEnable = true;
         optimalWidth = width;
         constWidth = constW;
      }
      ///
      /// ���������� ��� ��������.
      ///
      string Name(){return elementName;}
      ///
      /// ���������� ���������� ��������.
      ///
      bool Enable(){return elementEnable;}
      ///
      /// ���������� ����������� ������ ��������.
      ///
      long OptimalWidth(){return optimalWidth;}
      ///
      /// ���������� ������, ���� ����������� ������ �������� �������� ����������. 
      ///
      bool ConstWidth(){return constWidth;}
   private:
      ///
      /// ��� ��������.
      ///
      string elementName;
      ///
      /// ����, ����������� ������� �� ������ �������, ������������ �� �� �� �����.
      ///
      bool elementEnable;
      ///
      /// �������� ����������� ������ �������� � ��������.
      ///
      long optimalWidth;
      ///
      /// ����, �����������, �������� �� ������ ������� �������� ����������.
      ///
      bool constWidth;
};
///
/// �����-���������� ���������� ��������
///
class PanelSettings
{
   public:
      ///
      /// ���������� ���������� �����, ���������� ��������� ����������.
      /// ���� ����� ��� ��� ����� ������, ����� ��������� ��������� �� �����
      /// ��������� �����.
      ///
      static PanelSettings* GetSettings()
      {
         if(set == NULL)
            set = new PanelSettings();
         return set;
      }
      
      CTheme ColorTheme;
      //CNameColumns ColumnsName;
      //CWidthColumns ColumnsWidth;
      ///
      /// ���������� ������ �������� ��� ������� �������� ������� �������� �������.
      ///
      CArrayObj* GetSetForActiveTable(){return GetPointer(setForActivePos);}
      ///
      /// ���������� ������ �������� ��� ������� �������� ������� ������������ �������.
      ///
      CArrayObj* GetSetForHistoryTable(){return GetPointer(setForHistoryPos);}
   private:        
      static PanelSettings* set;
      ///
      /// ������ ��������, ��� ��������� ������� �������� �������.
      ///
      CArrayObj setForActivePos;
      ///
      /// ������ ��������, ��� ��������� ������� ������������ �������.
      ///
      CArrayObj setForHistoryPos;
      ///
      /// ����������� ����� ��� �������� ������� �� ���
      ///
      PanelSettings()
      {
         setForActivePos.Add(new CElement("CollapsePos.", 20, true));   setForHistoryPos.Add(new CElement("CollapsePos.", 20, true));
         setForActivePos.Add(new CElement("Magic", 90, false));         setForHistoryPos.Add(new CElement("Magic", 60, false));
         setForActivePos.Add(new CElement("Symbol", 90, false));        setForHistoryPos.Add(new CElement("Symbol", 90, false));
      }
      PanelSettings* operator=(const PanelSettings*);
};
