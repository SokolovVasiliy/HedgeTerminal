#include "\Files\ActivePosition.xml.mqh"
#include <Files\File.mqh>
///
/// Тип ресурса
///
enum ENUM_RESOURCES
{
   ///
   /// XML файл настроек HedgeTerminal
   ///
   RES_SETTINGS_XML,
   ///
   /// Xml файл активных позиций.
   ///
   RES_ACTIVE_POS_XML,
   ///
   /// XML файл исторических позиций.
   ///
   RES_HISTORY_POS_XML,
};
///
/// Инсталлирует ресурс на жесткий диск пользователя.
///
class Resources
{
   public:
      ///
      /// Проверяет существование файла ресурса.
      /// Возвращает истину если ресурс существует и ложь в противном случае.
      ///
      static bool CheckResource(ENUM_RESOURCES typeRes)
      {
         return false;
      }
      ///
      /// Инсталлирует ресурс выбранного типа на жесткий диск пользователя.
      ///
      static bool InstallResource(ENUM_RESOURCES typeRes)
      {
         switch(typeRes)
         {
            case RES_SETTINGS_XML:
               InstallSettingsXml();
               break;
         }
         return true;
      }
   private:
      ///
      /// Инсталлирует файл настроек HedgeTreminal на жесткий диск пользователя.
      ///
      static bool InstallSettingsXml()
      {
         string fileName = ".\HedgeTerminal\HedgeTerminalSettings.xml";
         bool res = FolderCreate("HedgeTerminal");
         if(!res)
         {
            printf("Failed create directory of HedgeTerminal. LastError:", GetLastError());
            return false;
         }
         if(file.IsExist(fileName))
         {
            printf("File \'" + fileName + "\' already exits, for reinstalling file delete it.");
            return false;
         }
         int handle = FileOpen(fileName, FILE_BIN|FILE_WRITE, "");
         if(handle == -1)
         {
            printf("Failed create file \'" + fileName + "\'. LastError: " + (string)GetLastError());
            return false;
         }
         FileWriteArray(handle, test_mqh);
         FileClose(handle);
         printf("File \'" + fileName + "\' successfully created.");
         return true;
      }
      static CFile file;
};