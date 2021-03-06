#include <Arrays\ArrayObj.mqh>
#include "..\Log.mqh"
#include ".\MD5Hash.mqh"
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
      datetime LastAccess(){return lastAccess;}
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
      ///
      /// Истина, если файл открыт только для чтения и ложь в противном случае.
      ///
      bool ReadOnly();
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
      datetime lastAccess;
      ///
      /// Время последнего доступа к файлу.
      ///
      datetime deltaAccess;
};

///
/// Истина, если файл был модифицирован и ложь в противном случае.
///
bool FileInfo::IsModify(void)
{
   if(TimeLocal() - deltaAccess < refresh)
      return false;
   deltaAccess = TimeLocal();
   if(handle != INVALID_HANDLE)
      return modify;
   if(this.FileOpen() == INVALID_HANDLE)
      return false;
   uchar array[];
   FileReadArray(handle, array);
   datetime modifyNow = (datetime)FileGetInteger(handle, FILE_MODIFY_DATE);
   modify = lastAccess != modifyNow;
   if(modify)
   {
      //printf("IsModify: " + TimeToString(modifyNow));
      lastAccess = modifyNow;
   }
   if(accessType == ACCESS_CHECK_AND_CLOSE || !modify)
      this.FileClose();
   return modify;
}

int FileInfo::FileOpen(int writeMode = 0)
{
   if(handle != INVALID_HANDLE)
      return -1;
   if(writeMode == FILE_WRITE)
      handle = ::FileOpen(fileName, FILE_BIN|FILE_READ|FILE_WRITE|flagDist);
   else 
      handle = ::FileOpen(fileName, FILE_BIN|FILE_READ|flagDist);
   //if(handle == -1)
   //   LogWriter("FileInfo: Error read|write file. Last Error:" + (string)GetLastError(), MESSAGE_TYPE_ERROR);
   return handle;
}
void FileInfo::FileClose()
{
   if(handle == INVALID_HANDLE)
      return;
   if(ReadOnly())
      lastAccess = (datetime)FileGetInteger(handle, FILE_MODIFY_DATE);
   else
      lastAccess = TimeLocal();   
   ::FileClose(handle);
   modify = false;
   handle = INVALID_HANDLE;
}

bool FileInfo::ReadOnly(void)
{
   if(handle == INVALID_HANDLE)
      return false;
   bool w = FileGetInteger(handle, FILE_IS_READABLE);
   bool r = FileGetInteger(handle, FILE_IS_WRITABLE);
   return w&&!r;
}

class ModifyDetect
{
   public:
      ModifyDetect(){prevHash = "";}
      ///
      /// Истина, если файл был изменен и ложь в противном случае.
      ///
      bool IsModify(int handle)
      {
         uchar array[];
         FileReadArray(handle, array);
         int size = (int)ArraySize(array);
         if(size == 0)
            return false;
         string nextHash = md5.Hash(array, size);
         if(nextHash == prevHash)
            return false;
         return true;
      }
      /*void RefreshHash(int handle)
      {
      }*/
   private:
      ///
      /// MD5-хеш функция для определения изменения файла.
      ///
      CMD5Hash md5;
      ///
      /// Предыдущий хеш файла.
      ///
      string prevHash;
};