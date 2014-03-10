
#include <Arrays\ArrayObj.mqh>
///
/// �������� ���������� ��� ������ � �������.
///
class FileInfo : CObject
{
   public:
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
      }
   private:
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