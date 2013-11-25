#include <Arrays\ArrayObj.mqh>
#define SETTINGS_MQH
///
/// Содержит цветовые константы панели.
///
class CTheme
{
   public:
      ///
      /// Возвращает основной цвет фона.
      ///
      color GetBackgroundColor(){return clrWhite;}
      ///
      /// Возвращает цвет границы элементов.
      ///
      color GetBorderColor(){return clrBlack;}
      ///
      /// Возвращает цвет системных элементов.
      ///
      color GetSystemColor(){return clrWhiteSmoke;}
      ///
      /// Возвращает цвет курсора.
      ///
      color GetCursorColor(){return clrLightSteelBlue;}
};
///
/// Содержит названия колонок.
///
class CNameColumns
{
   public:
      ///
      /// Возвращает имя элемента TreeViewBox.
      ///
      string Collapse(){return "CollapsePos.";}
      ///
      /// Возвращает имя ячейки магического номера.
      ///
      string Magic(){return "Magic";}
      ///
      /// Возвращает имя ячейки символа.
      ///
      string Symbol(){return "Symbol";}
      ///
      /// Возвращает имя ячейки отображающей id входящего ордера.
      ///
      string EntryOrderId(){return "Entry Order ID";}
};

///
/// Содержит ширину колонок.
///
class CWidthColumns
{
   public:
      ///
      /// Возвращает ширину элемента TreeViewBox.
      ///
      long Collapse(){return 20;}
      ///
      /// Возвращает ширину ячейки магического номера.
      ///
      long Magic(){return 60;}
      ///
      /// Возвращает ширину ячейки символа.
      ///
      long Symbol(){return 60;}
      ///
      /// Возвращает ширину ячейки отображающей id входящего ордера.
      ///
      long EntryOrderId(){return 90;}
};

///
/// Константы колонок.
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
/// Класс, содержащий все необходимые свойства колнки
///
class DefColumn : public CObject
{
   public:
      ///
      /// По-умолчанию, предоставляется конструктор, который опеределяет все свойства элемента.
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
      /// Возвращает имя элемента.
      ///
      string Name(){return elementName;}
      ///
      /// Возвращает активность элемента.
      ///
      bool Enable(){return elementEnable;}
      ///
      /// Возвращает оптимальную ширину элемента.
      ///
      long OptimalWidth(){return optimalWidth;}
      ///
      /// Возвращает истину, если оптимальная ширина элемента является константой. 
      ///
      bool ConstWidth(){return constWidth;}
   private:
      ///
      /// Имя элемента.
      ///
      string elementName;
      ///
      /// Тип элемента.
      ///
      ENUM_COLUMN_TYPE columnType;
      ///
      /// Флаг, указывающий включен ли данный элемент, отображается ли он на форме.
      ///
      bool elementEnable;
      ///
      /// Содержит оптимальную ширину элемента в пикселях.
      ///
      long optimalWidth;
      ///
      /// Флаг, указывающий, является ли ширина данного элемента константой.
      ///
      bool constWidth;
};
///
/// Класс-сингельтон глобальных настроек
///
class PanelSettings
{
   public:
      ///
      /// Возвращает глобальный класс, содержащий настройки приложения.
      /// Если класс был уже ранее создан, будет возвращен указатель на ранее
      /// созданный класс.
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
      /// Возвращает список настроек для каждого элемента таблицы активных позиций.
      ///
      CArrayObj* GetSetForActiveTable(){return GetPointer(setForActivePos);}
      ///
      /// Возвращает список настроек для каждого элемента таблицы исторических позиций.
      ///
      CArrayObj* GetSetForHistoryTable(){return GetPointer(setForHistoryPos);}
   private:        
      static PanelSettings* set;
      ///
      /// Список настроек, для элементов таблицы активных позиций.
      ///
      CArrayObj setForActivePos;
      ///
      /// Список настроек, для элементов таблицы исторических позиций.
      ///
      CArrayObj setForHistoryPos;
      ///
      /// Конструктор скрыт для создания объекта из вне.
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
