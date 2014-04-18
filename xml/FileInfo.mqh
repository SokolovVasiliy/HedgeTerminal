#include <Arrays\ArrayObj.mqh>
#include "..\Log.mqh"
///
/// ��� ������� � �����.
///
enum ENUM_ACCESS_FILE
{
   ///
   /// ��������� ���� �� ��������� � ������� ���.
   ///
   ACCESS_CHECK_AND_CLOSE,
   ///
   /// ��������� ���� �� ��������� � ������� ��������.
   ///
   ACCESS_CHECK_AND_BLOCKED
};
///
/// �������� ���������� ��� ������ � �������.
///
class FileInfo : CObject
{
   public:
      ///
      /// ������������� ��� ������� � �����.
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
      /// ��������� ���� � ���������� ���������� �� ����.
      /// \param writeMode - ��������� ���� � ������ ������.
      ///
      int FileOpen(int writeMode);
      bool IsModify(void);
      string Name(){return fileName;}
      int FlagDist(){return flagDist;}
      datetime LastAccess(){return lastAccess;}
      ///
      /// ������� ����.
      /// \name - ��� �����.
      /// \flagDist - ����, ����������� �� ������������ ����� � ��������� ��������.
      /// \refreshValue - ���������� ������, ����� ������� ��������� ��������� ����������� �����.
      ///
      FileInfo(string name, int flagDistance, int refreshValue)
      {
         fileName = name;
         flagDist = flagDistance;
         refresh = refreshValue;
         handle = INVALID_HANDLE;
      }
      ///
      /// ��������� ����.
      ///
      void FileClose(void);
      ///
      /// ���������� �������� ����������.
      ///
      int GetHandle(){return handle;}
      ///
      /// ��������� �������� ���� ���������.
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
      /// ������, ���� ���� ������ ������ ��� ������ � ���� � ��������� ������.
      ///
      bool ReadOnly();
   private:
      ///
      /// ������, ���� ���� ������� � ���� � ��������� ������.
      ///
      bool modify;
      ///
      /// ��� ������� � �����.
      ///
      ENUM_ACCESS_FILE accessType;
      ///
      /// �������� ���������� �����.
      ///
      int handle;
      ///
      /// ��� �����.
      ///
      string fileName;
      ///
      /// ����, ����������� �� ������������ �����.
      ///
      int flagDist;
      ///
      /// ���������� ������, ����� ������� ��������� ��������� ����������� �����.
      ///
      int refresh;
      ///
      /// ����� ����������� �����.
      ///
      datetime lastAccess;
      ///
      /// ����� ���������� ������� � �����.
      ///
      datetime deltaAccess;
};

///
/// ������, ���� ���� ��� ������������� � ���� � ��������� ������.
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
   datetime modifyNow = (datetime)FileGetInteger(handle, FILE_MODIFY_DATE);
   modify = lastAccess != modifyNow;
   if(modify)
      lastAccess = modifyNow;
   if(accessType == ACCESS_CHECK_AND_CLOSE || !modify)
      this.FileClose();
   return modify;
}

int FileInfo::FileOpen(int writeMode = 0)
{
   if(handle != INVALID_HANDLE)
      return -1;
   if(writeMode == FILE_WRITE)
      handle = FileOpen(fileName, FILE_BIN|FILE_READ|FILE_WRITE|flagDist);
   else 
      handle = FileOpen(fileName, FILE_BIN|FILE_READ|flagDist);
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
   FileClose(handle);
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