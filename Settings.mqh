#include <Arrays\ArrayObj.mqh>

#define SETTINGS_MQH
///
/// Содержит цветовые константы панели.
///
class CTheme
{
   public:
      ///
      /// Возвращает цвет границы элементов.
      ///
      color GetBorderColor(){return clrBlack;}
      ///
      /// Возвращает цвет текста.
      ///
      color GetTextColor(){return clrBlack;}
      ///
      /// Возвращает основной системный цвет.
      ///
      color GetSystemColor1(){return clrWhiteSmoke;}
      ///
      /// Возвращает вспомогательный системны цвет.
      ///
      color GetSystemColor2(){return clrWhite;}
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

#include ".\xml\SettingsLoader.mqh"
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
      ///
      /// Возвращает список настроек для каждого элемента таблицы активных позиций.
      ///
      CArrayObj* GetSetForActiveTable(){return GetPointer(setForActivePos);}
      ///
      /// Возвращает список настроек для каждого элемента таблицы исторических позиций.
      ///
      CArrayObj* GetSetForHistoryTable(){return GetPointer(setForHistoryPos);}
      ///
      /// Вовзвращает рекомендованное количество прайсстепов, между ценой и стоп, тейк ордерами, 
      ///
      int GetPriceStepCount(){return 100;}
      ///
      /// Вовзращает строковый псевдоноим для маджика эксперта.
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
      ///
      /// Конструктор скрыт для создания объекта из вне.
      ///
      PanelSettings()
      {
         //EventExchange = new CEventExchange();
         //Resources = new CResources();
         setForActivePos.AssignArray(loader.GetActiveColumns());
         setForHistoryPos.AssignArray(loader.GetHistoryColumns());
      }
   private:        
      /*static*/ PanelSettings* set;
      ///
      /// Список настроек, для элементов таблицы активных позиций.
      ///
      CArrayObj setForActivePos;
      ///
      /// Список настроек, для элементов таблицы исторических позиций.
      ///
      CArrayObj setForHistoryPos;
      ///
      /// Загрузчик XML настроек.
      ///
      XmlLoader loader;
      
      ///
      /// Проверяет инсталляцию файлов. (Только для HLYBRARY)
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
};
