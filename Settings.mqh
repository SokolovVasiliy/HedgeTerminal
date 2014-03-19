#include <Arrays\ArrayObj.mqh>

#define SETTINGS_MQH
///
/// �������� �������� ��������� ������.
///
class CTheme
{
   public:
      ///
      /// ���������� ���� ������� ���������.
      ///
      color GetBorderColor(){return clrBlack;}
      ///
      /// ���������� ���� ������.
      ///
      color GetTextColor(){return clrBlack;}
      ///
      /// ���������� �������� ��������� ����.
      ///
      color GetSystemColor1(){return clrWhiteSmoke;}
      ///
      /// ���������� ��������������� �������� ����.
      ///
      color GetSystemColor2(){return clrWhite;}
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
/// ��������� �������.
///
enum ENUM_COLUMN_TYPE
{
   COLUMN_COLLAPSE,
   COLUMN_MAGIC,
   COLUMN_SYMBOL,
   COLUMN_ENTRY_ORDER_ID,
   COLUMN_EXIT_ORDER_ID,
   COLUMN_EXIT_MAGIC,
   COLUMN_ENTRY_DATE,
   COLUMN_EXIT_DATE,
   COLUMN_VOLUME,
   COLUMN_TYPE,
   COLUMN_SL,
   COLUMN_TP,
   COLUMN_TRAL,
   COLUMN_ENTRY_PRICE,
   COLUMN_EXIT_PRICE,
   COLUMN_CURRENT_PRICE,
   COLUMN_PROFIT,
   COLUMN_ENTRY_COMMENT,
   COLUMN_EXIT_COMMENT,
   COLUMN_NDEF
};

///
/// �����, ���������� ��� ����������� �������� ������
///
class DefColumn : public CObject
{
   public:
      ///
      /// ��-���������, ��������������� �����������, ������� ����������� ��� �������� ��������.
      ///
      DefColumn(ENUM_COLUMN_TYPE cType, string name, long width, bool constW)
      {
         columnType = cType;
         elementName = name;
         elementEnable = true;
         optimalWidth = width;
         constWidth = constW;
      }
      ENUM_COLUMN_TYPE ColumnType(){return columnType;}
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
      /// ��� ��������.
      ///
      ENUM_COLUMN_TYPE columnType;
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

#include ".\xml\SettingsLoader.mqh"
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
      static PanelSettings* Init()
      {
         if(CheckPointer(set) == POINTER_INVALID)
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
      ///
      /// ����������� ��������������� ���������� �����������, ����� ����� � ����, ���� ��������, 
      ///
      int GetPriceStepCount(){return 100;}
      ///
      /// ���������� ���� � ����� � ����������� �� �������� ��������.
      ///
      string GetActivePosXml()
      {
         return "ActivePositions.xml";
      }
      ///
      /// ���������� ��������� ���������� ��� ������� ��������.
      ///
      string GetNameExpertByMagic(ulong magic)
      {
         return loader.GetNameExpertByMagic(magic);
      }
      double GetLevelVirtualOrder(ulong id, ENUM_VIRTUAL_ORDER_TYPE type)
      {
         return loader.GetLevelVirtualOrder(id, type);
      }
      
      void SaveXmlAttr(ulong id, ENUM_VIRTUAL_ORDER_TYPE type, string level)
      {
         loader.SaveXmlAttr(id, type, level);
      }
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
      /// ��������� XML ��������.
      ///
      XmlLoader loader;
      ///
      /// ����������� ����� ��� �������� ������� �� ���.
      ///
      PanelSettings()
      {
         setForActivePos.AssignArray(loader.GetActiveColumns());
         setForHistoryPos.AssignArray(loader.GetHistoryColumns());
      }
      PanelSettings* operator=(const PanelSettings*);
};
