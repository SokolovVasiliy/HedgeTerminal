#include <Arrays\ArrayObj.mqh>
#include "..\Log.mqh"
///
/// Тип доступа к файлу.
///
enum ENUM_ACCESS_FILE
{
   ///
   /// Проверить файл на изменения и закрыть его.
   ///
   ACCESS_CHECK_AND_CLOSE,
   ///
   /// Проверить файл на изменения и держать открытым.
   ///
   ACCESS_CHECK_AND_BLOCKED
};
///
/// Содержит информацию для работы с файлами.
///
class FileInfo : CObject
{
   public:
      ///
      /// Устанавливает тип доступа к файлу.
      ///
      void SetMode(ENUM_ACCESS_FILE aType)
      {
         if(handle != INVALID_HANDLE)
         {
            LogWriter("File handle must be closed.", MESSAGE_TYPE_ERROR);
            return;
         }
         accessType = aType;
      }
      ///
      /// Открывает файл и возвращает дискриптор на него.
      /// \param writeMode - Открывает файл в режиме записи.
      ///
      int FileOpen(int writeMode);
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
         handle = INVALID_HANDLE;
      }
      ///
      /// Закрывает файл.
      ///
      void FileClose(void);
      ///
      /// Возвращает файловый дискриптор.
      ///
      int GetHandle(){return handle;}
      ///
      /// Заполняет открытый файл пробелами.
      ///
      void FillSpace()
      {
         int size = (int)FileSize(handle);
         uchar spaces[];
         ArrayResize(spaces, size);
         uchar ch = ' '; 
         ArrayInitialize(spaces, ch);
         FileSeek(handle, 0, SEEK_SET);
         FileWriteArray(handle, spaces, 0, ArraySize(spaces));
      }
   private:
      ///
      /// Истина, если файл изменен и ложь в противном случае.
      ///
      bool modify;
      ///
      /// Тип доступа к файлу.
      ///
      ENUM_ACCESS_FILE accessType;
      ///
      /// Содержит дискриптор файла.
      ///
      int handle;
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
   lastAccess = TimeCurrent();
   if(handle != INVALID_HANDLE)
      return modify;
   if(this.FileOpen() == INVALID_HANDLE)
      return false;
   datetime modifyNow = (datetime)FileGetInteger(handle, FILE_MODIFY_DATE);
   modify = modifyTime < modifyNow;
   if(modify)
   {
      //printf("Now modify time: " + TimeToString(modifyNow, TIME_MINUTES|TIME_SECONDS) +
      //       " Last modify time: " + TimeToString(modifyTime, TIME_MINUTES|TIME_SECONDS));
      modifyTime = modifyNow;
   }
   if(accessType == ACCESS_CHECK_AND_CLOSE || !modify)
   {
      FileClose(handle);
      handle = INVALID_HANDLE;
   }
   return modify;
}

int FileInfo::FileOpen(int writeMode = 0)
{
   //FileDelete
   if(writeMode == FILE_WRITE)
      handle = FileOpen(fileName, FILE_BIN|FILE_READ|FILE_WRITE|flagDist);
   else 
      handle = FileOpen(fileName, FILE_BIN|FILE_READ|flagDist);
   int size = (int)FileSize(handle);
   return handle;
}
void FileInfo::FileClose()
{
   if(handle != INVALID_HANDLE)
      FileClose(handle);
   modifyTime = TimeLocal();
   modify = false;
   handle = INVALID_HANDLE;
}