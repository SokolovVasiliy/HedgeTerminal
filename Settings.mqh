#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>

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
   COLUMN_COMMISSION,
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
      /*PanelSettings* Init()
      {
         if(CheckPointer(set) == POINTER_INVALID)
         {
            if(!CheckInstall())
               return NULL;
            set = new PanelSettings();
         }
         return set;
      }*/
      
      CTheme ColorTheme;
      //CNameColumns ColumnsName;
      //CWidthColumns ColumnsWidth;
      CArrayLong* GetExcludeOrders()
      {
         return loader.GetExcludeOrders();
      }
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
      /// ���������� ��������� ���������� ��� ������� ��������.
      ///
      string GetNameExpertByMagic(ulong magic)
      {
         if(MQLInfoInteger(MQL_TESTER))
            return IntegerToString(magic);
         return loader.GetNameExpertByMagic(magic);
      }
      double GetLevelVirtualOrder(ulong id, ENUM_VIRTUAL_ORDER_TYPE type)
      {
         if(MQLInfoInteger(MQL_TESTER))
            return 0.0;
         return loader.GetLevelVirtualOrder(id, type);
      }
      
      void SaveXmlHistPos(ulong id, ENUM_VIRTUAL_ORDER_TYPE type, string level)
      {
         if(!MQLInfoInteger(MQL_TESTER))
            loader.SaveXmlHistPos(id, type, level);
      }
      ///
      /// �����������.
      ///
      PanelSettings()
      {
         if(!MQLInfoInteger(MQL_TESTER) && !Resources.Failed())
         {
            loader = new XmlLoader();
            setForActivePos.AssignArray(loader.GetActiveColumns());
            setForHistoryPos.AssignArray(loader.GetHistoryColumns());
         }
      }
      ~PanelSettings()
      {
         if(CheckPointer(loader) != POINTER_INVALID)
            delete loader;
      }
      ///
      /// ���������� ���������� ���������� ���� � �����������.
      ///
      ulong GetDeviation()
      {
         if(!MQLInfoInteger(MQL_TESTER))
            return loader.GetDeviation();
         return 3;
      }
      uint GetRefreshRates()
      {
         if(!MQLInfoInteger(MQL_TESTER))
            return loader.GetRefreshRates();
         return 200;
      }
   private:        
      /*static*/ PanelSettings* set;
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
      XmlLoader* loader;
      
      ///
      /// ��������� ����������� ������. (������ ��� HLYBRARY)
      ///
      bool CheckInstall()
      {
         bool res = true;
         if(Resources.UsingFirstTime())
         {
            if(!Resources.WizardForUseFirstTime())
            {
               printf("Installing HedgeTerminal filed. Unable to continue. Goodbuy:(");
               ExpertRemove();
               return false;
            }
         }
         else
            res = Resources.InstallMissingFiles();
         return res;
      }
      
      PanelSettings* operator=(  PanelSettings*);
      ///
      /// �������� ���������� � �������.
      ///
      ulong deviation;
      ///
      /// ������, ���� ���������� �������� � ������ ������������.
      ///
      bool isTesting;
};
