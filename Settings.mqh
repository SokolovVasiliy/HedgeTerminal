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
/// Класс-сингельтон глобальных настроек
///
class Settings
{
   public:
      ///
      /// Возвращает глобальный класс, содержащий настройки приложения.
      /// Если класс был уже ранее создан, будет возвращен указатель на ранее
      /// созданный класс.
      ///
      static Settings* GetSettings()
      {
         if(set == NULL)
            set = new Settings();
         return set;
      }
      ///
      /// Экземпляр может перечитать свои настройки из файла.
      ///
      void Reread()
      {
         ;
      }
      CTheme ColorTheme;
      CNameColumns ColumnsName;
   private:        
      static Settings* set;
      Settings(){};
      Settings* operator=(const Settings*);
      ~Settings();
};
