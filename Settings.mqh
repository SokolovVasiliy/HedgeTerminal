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
/// Класс, содержащий все необходимые свойства элемента
///
class CElement : public CObject
{
   public:
      ///
      /// По-умолчанию, предоставляется конструктор, который опеределяет все свойства элемента.
      ///
      CElement(string name, long width, bool constW)
      {
         elementName = name;
         elementEnable = true;
         optimalWidth = width;
         constWidth = constW;
      }
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
      /// Конструктор скрыт для создания объекта из вне
      ///
      PanelSettings()
      {
         setForActivePos.Add(new CElement("CollapsePos.", 20, true));   setForHistoryPos.Add(new CElement("CollapsePos.", 20, true));
         setForActivePos.Add(new CElement("Magic", 90, false));         setForHistoryPos.Add(new CElement("Magic", 60, false));
         setForActivePos.Add(new CElement("Symbol", 90, false));        setForHistoryPos.Add(new CElement("Symbol", 90, false));
      }
      PanelSettings* operator=(const PanelSettings*);
};
