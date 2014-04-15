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
      datetime ModifyTime(){return modifyTime;}
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
      datetime modifyTime;
      ///
      /// ����� ���������� ������� � �����.
      ///
      datetime lastAccess;
};

///
/// ������, ���� ���� ��� ������������� � ���� � ��������� ������.
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