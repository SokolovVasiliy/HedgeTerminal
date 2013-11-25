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
/// ��������� �������.
///
enum ENUM_COLUMN_TYPE
{
   COLUMN_COLLAPSE,
   COLUMN_MAGIC,
   COLUMN_SYMBOL,
   COLUMN_ENTRY_ORDER_ID,
   COLUMN_EXIT_ORDER_ID,
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
   COLUMN_EXIT_COMMENT
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
      /// ����������� ����� ��� �������� ������� �� ���.
      ///
      PanelSettings()
      {
         string collapse = "CollapsePos.";
         string magic = "Magic";
         string symbol = "Symbol";
         string entryOrderId = "Entry ID";
         string exitOrderId = "Exit ID";
         string entryDate = "Entry Date";
         string exitDate = "Exit Date";
         string type = "Type";
         string vol = "Vol.";
         string entryVol = "InVol.";
         string exitVol = "OutVol.";
         string entryPrice = "Entry Price";
         string exitPrice = "Exit Price";
         string sl = "S/L";
         string tp = "T/P";
         string tral = "Tral";
         string currentPrice = "Price";
         string profit = "Profit";
         string entryComment = "Entry Comment";
         string exitComment = "Exit Comment";
         
         setForActivePos.Add(new DefColumn(COLUMN_COLLAPSE ,collapse, 20, true));            setForHistoryPos.Add(new DefColumn(COLUMN_COLLAPSE, collapse, 20, true));
         setForActivePos.Add(new DefColumn(COLUMN_MAGIC, magic, 100, false));                setForHistoryPos.Add(new DefColumn(COLUMN_MAGIC, magic, 100, false));
         setForActivePos.Add(new DefColumn(COLUMN_SYMBOL, symbol, 70, false));               setForHistoryPos.Add(new DefColumn(COLUMN_SYMBOL, symbol, 70, false));
         setForActivePos.Add(new DefColumn(COLUMN_ENTRY_ORDER_ID, entryOrderId, 80, false)); setForHistoryPos.Add(new DefColumn(COLUMN_ENTRY_ORDER_ID, entryOrderId, 80, false));
                                                                                             setForHistoryPos.Add(new DefColumn(COLUMN_ENTRY_DATE, entryDate, 110, false));
                                                                                             setForHistoryPos.Add(new DefColumn(COLUMN_ENTRY_PRICE, entryPrice, 50, false));
                                                                                             setForHistoryPos.Add(new DefColumn(COLUMN_VOLUME, entryVol, 30, false));
                                                                                             setForHistoryPos.Add(new DefColumn(COLUMN_VOLUME, exitVol, 30, false));
                                                                                             setForHistoryPos.Add(new DefColumn(COLUMN_EXIT_PRICE, exitPrice, 50, false));
                                                                                             setForHistoryPos.Add(new DefColumn(COLUMN_EXIT_DATE, exitDate, 110, false));
                                                                                             setForHistoryPos.Add(new DefColumn(COLUMN_EXIT_ORDER_ID, exitOrderId, 80, false));
         setForActivePos.Add(new DefColumn(COLUMN_ENTRY_DATE, entryDate, 110, false));       
                                                                                             
         setForActivePos.Add(new DefColumn(COLUMN_TYPE, type, 80, false));                   setForHistoryPos.Add(new DefColumn(COLUMN_TYPE, type, 80, false));
         setForActivePos.Add(new DefColumn(COLUMN_VOLUME, vol, 30, false));                  
         setForActivePos.Add(new DefColumn(COLUMN_ENTRY_PRICE, entryPrice, 50, false));      
         setForActivePos.Add(new DefColumn(COLUMN_SL, sl, 50, false));                       setForHistoryPos.Add(new DefColumn(COLUMN_SL, sl, 50, false));
         setForActivePos.Add(new DefColumn(COLUMN_TP, tp, 50, false));                       setForHistoryPos.Add(new DefColumn(COLUMN_TP, tp, 50, false));
         setForActivePos.Add(new DefColumn(COLUMN_TRAL, tral, 20, true));
         setForActivePos.Add(new DefColumn(COLUMN_CURRENT_PRICE, currentPrice, 50, false));  
         setForActivePos.Add(new DefColumn(COLUMN_PROFIT, profit, 60, false));               setForHistoryPos.Add(new DefColumn(COLUMN_PROFIT, profit, 50, false));
         setForActivePos.Add(new DefColumn(COLUMN_ENTRY_COMMENT, entryComment, 150, false));  setForHistoryPos.Add(new DefColumn(COLUMN_ENTRY_COMMENT, entryComment, 90, false));
                                                                                             setForHistoryPos.Add(new DefColumn(COLUMN_EXIT_COMMENT, exitComment, 90, false));
      }
      PanelSettings* operator=(const PanelSettings*);
};
