#define FILE_ACTIVE_POSITION "ActivePosition.xml.mqh"
#define ARRAY_ACT_POS array_active_pos

#define FILE_HISTORY_POSITION "HistoryPositions.xml.mqh"
#define ARRAY_HIST_POS array_hist_pos

#define FILE_HT_SETTINGS "HedgeTerminalSettings.xml.mqh"
#define ARRAY_HT_SETTINGS array_settings

#define FILE_EXPERT_ALIASES "ExpertAliases.xml.mqh"
#define ARRAY_EXP_ALIASES array_aliases

#define FILE_FONT_BOLT "Font_MT_Bold.ttf.mqh"
#define ARRAY_FONT_BOLT array_font_bolt

#define FILE_PROTOTYPES "Prototypes.mqh"
#define ARRAY_PROTOTYPES array_prototypes

#ifndef MAKE_UTIL
   #include "ActivePositions.xml.mqh"
   #include "HistoryPositions.xml.mqh"
   #include "ExpertAliases.xml.mqh"
   #ifdef HEDGE_PANEL
      #include "HedgeTerminalSettings.xml.mqh"
      #include "Font_MT_Bold.ttf.mqh"
   #endif
   #ifdef HLIBRARY
      #include "Prototypes.mqh.mqh"
   #endif
#endif
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
   ///
   /// XML ���� ����������� ��������.
   ///
   RES_EXPERT_ALIASES,
   ///
   /// ����� ��� ����������� �������� ������.
   ///
   RES_FONT_MT_BOLT,
   ///
   /// MQH ���� ���������� �������.
   ///
   RES_PROTOTYPES
};
///
/// ������������ ������ �� ������� ���� ������������.
///
class CResources
{
   public:
      ///
      /// ���������� ������, ���� �������� ���������, ��� �� ������������
      /// ������� �� ���� ���������. � ��������� ������ ���������� ����.
      ///
      bool UsingFirstTime()
      {
         string name;
         long handle = FileFindFirst(".\HedgeTerminal\*", name);
         if(handle != INVALID_HANDLE)
         {
            FileFindClose(handle);
            return false;
         }
         return true;
      }
      ///
      /// ������ ���������� HedgeTerminal ����������� � ������ ���.
      ///
      bool WizardForUseFirstTime()
      {
         int res =  MessageBox("HedgeTerminal detected first time use. This master help you install" + 
         " HedgeTerminal on your PC. Press \'OK' for continue or cancel for exit HedgeTerminal.", VERSION, MB_OKCANCEL);
         if(res == IDCANCEL)
            return false;
         /*HistorySelect(0, TimeCurrent());
         if(HistoryOrdersTotal() > 0)
         {
            if(PositionsTotal() > 0)
            {
               //MessageBox("HedgeTerminal detected using active positions on your account, but . ");
            }
            //SetMarkerOrder();
         }*/
         res = MessageBox("For corectly work HedgeTerminal needed install some files in" +
         " .\MQL5\Files\HedgeTerminal derectory. For install files press \'��\' or cancel for exit.", VERSION, MB_OKCANCEL);
         if(res == IDCANCEL)
            return false;
         res = InstallMissingFiles();
         return true;
      }
      ///
      /// ������������ ������������� ����� � ���������� HedgeTerminal.
      ///
      bool InstallMissingFiles(void)
      {
         bool res = true;
         if(!CheckResource(RES_SETTINGS_XML))
            res = InstallResource(RES_SETTINGS_XML);
         if(!CheckResource(RES_ACTIVE_POS_XML))
            res = InstallResource(RES_ACTIVE_POS_XML);
         if(!CheckResource(RES_HISTORY_POS_XML))
            res = InstallResource(RES_HISTORY_POS_XML);
         if(!CheckResource(RES_EXPERT_ALIASES))
            res = InstallResource(RES_EXPERT_ALIASES);
         if(!CheckResource(RES_FONT_MT_BOLT))
            res = InstallResource(RES_FONT_MT_BOLT);
         return res;
      }
      ///
      /// ��������� ������������� ����� �������.
      /// ���������� ������ ���� ������ ���������� � ���� � ��������� ������.
      ///
      bool CheckResource(ENUM_RESOURCES typeRes)
      {
         string fileName = GetFileNameByType(typeRes);
         if(file.IsExist(fileName))
            return true;
         return false;
      }
      ///
      /// ���������� ��� ����� � ����������� �� ���� �������.
      ///
      string GetFileNameByType(ENUM_RESOURCES typeRes)
      {
         string fileName = "";
         switch(typeRes)
         {
            case RES_SETTINGS_XML:
               fileName = ".\HedgeTerminal\HedgeTerminalSettings.xml";
               break;
            case RES_ACTIVE_POS_XML:
               fileName = ".\HedgeTerminal\ActivePositions.xml";
               break;
            case RES_HISTORY_POS_XML:
               fileName = ".\HedgeTerminal\HistoryPositions.xml";
               break;
            case RES_EXPERT_ALIASES:
               fileName = ".\HedgeTerminal\ExpertAliases.xml";
               break;
            case RES_FONT_MT_BOLT:
               fileName = ".\HedgeTerminal\Arial Rounded MT Bold.ttf";
               break;
            case RES_PROTOTYPES:
               fileName = ".\HedgeTerminal\Prototypes.mqh";
               break;
         }
         return fileName;
      }
      ///
      /// ������������ ���� ���������������� ����.
      /// \param typeRes - ��� ��������������� �����.
      ///
      bool InstallResource(ENUM_RESOURCES typeRes)
      {
         string fileName = GetFileNameByType(typeRes);
         if(!CheckCreateFile(fileName))return false;
         int handle = CreateFile(fileName);
         if(handle == -1)return false;
         switch(typeRes)
         {
            #ifdef HEDGE_PANEL
            case RES_SETTINGS_XML:
               FileWriteArray(handle, ARRAY_HT_SETTINGS);
               break;
            case RES_FONT_MT_BOLT:
               FileWriteArray(handle, ARRAY_FONT_BOLT);
               break;
            #endif
            case RES_ACTIVE_POS_XML:
               FileWriteArray(handle, ARRAY_ACT_POS);
               break;
            case RES_HISTORY_POS_XML:
               FileWriteArray(handle, ARRAY_HIST_POS);
               break;
            case RES_EXPERT_ALIASES:
               FileWriteArray(handle, ARRAY_EXP_ALIASES);
               break;
            #ifdef HLIBRARY
            case RES_PROTOTYPES:
               FileWriteArray(handle, ARRAY_PROTOTYPES);
               break;
            #endif
            default:
               printf("HedgeTerminal is not unable to create the file " + fileName + ". Check your permission and settings.");
               FileClose(handle);
               return false;
         }
         FileClose(handle);
         printf("HedgeTerminal install " + fileName + " on your PC.");
         return true;
      }
   private:
      ///
      /// ��������� ����������� �������� �����. ���������� ������,
      /// ���� ���� ����� ������� � ���� � ��������� ������.
      ///
      bool CheckCreateFile(string fileName)
      {
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
         return true;
      }
      ///
      /// ��������� ���� ��� ������ � ���������� ��� �����. ���������� -1 � ������ �������.
      ///
      int CreateFile(string fileName)
      {
         int handle = FileOpen(fileName, FILE_BIN|FILE_WRITE, "");
         if(handle == -1)
            printf("Failed create file \'" + fileName + "\'. LastError: " + (string)GetLastError());
         return handle;
      }
      /*static*/ CFile file;
};