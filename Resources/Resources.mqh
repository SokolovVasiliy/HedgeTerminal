#include "\Files\ActivePosition.xml.mqh"
#include <Files\File.mqh>
///
/// ��� �������
///
enum ENUM_RESOURCES
{
   ///
   /// XML ���� �������� HedgeTerminal
   ///
   RES_SETTINGS_XML,
   ///
   /// Xml ���� �������� �������.
   ///
   RES_ACTIVE_POS_XML,
   ///
   /// XML ���� ������������ �������.
   ///
   RES_HISTORY_POS_XML,
};
///
/// ������������ ������ �� ������� ���� ������������.
///
class Resources
{
   public:
      ///
      /// ��������� ������������� ����� �������.
      /// ���������� ������ ���� ������ ���������� � ���� � ��������� ������.
      ///
      static bool CheckResource(ENUM_RESOURCES typeRes)
      {
         return false;
      }
      ///
      /// ������������ ������ ���������� ���� �� ������� ���� ������������.
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
      /// ������������ ���� �������� HedgeTreminal �� ������� ���� ������������.
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