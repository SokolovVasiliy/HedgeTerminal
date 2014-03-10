
#include <Arrays\ArrayObj.mqh>
///
/// Содержит информацию для работы с файлами.
///
class FileInfo : CObject
{
   public:
      bool IsModify(void);
      string Name(){return fileName;}
      int FlagDist(){return flagDist;}
      datetime ModifyTime(){return modifyTime;}
      ///
      /// Создает файл.
      /// \name - Имя файла.
      /// \flagDist - Флаг, указывающий на расположение файла в структуре каталога.
      /// \refreshValue - количество секунд, через которое требуется проверять модификацию файла.
      ///
      FileInfo(string name, int flagDistance, int refreshValue)
      {
         fileName = name;
         flagDist = flagDistance;
         refresh = refreshValue;
      }
   private:
      ///
      /// Имя файла.
      ///
      string fileName;
      ///
      /// Флаг, указывающий на расположение файла.
      ///
      int flagDist;
      ///
      /// Количество секунд, через которое требуется проверять модификацию файла.
      ///
      int refresh;
      ///
      /// Время модификации файла.
      ///
      datetime modifyTime;
      ///
      /// Время последнего доступа к файлу.
      ///
      datetime lastAccess;
};

///
/// Истина, если файл был модифицирован и ложь в противном случае.
///
bool FileInfo::IsModify(void)
{
   if(TimeCurrent() - lastAccess < refresh)
      return false;
   int handle = FileOpen(fileName, FILE_BIN|FILE_READ|flagDist);
   if(handle == -1)
      return false;
   datetime modify = (datetime)FileGetInteger(handle, FILE_MODIFY_DATE);
   FileClose(handle);
   if(modify != modifyTime)
   {
      modifyTime = modify;
      return true;
   }
   return false;
}