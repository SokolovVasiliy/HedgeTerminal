#define FILE_ACTIVE_POSITION "ActivePosition.xml.mqh"
#define ARRAY_ACT_POS array_active_pos

#define FILE_HISTORY_POSITION "HistoryPositions.xml.mqh"
#define ARRAY_HIST_POS array_hist_pos

#define FILE_HT_SETTINGS "Settings.xml.mqh"
#define ARRAY_HT_SETTINGS array_settings

#define FILE_EXPERT_ALIASES "ExpertAliases.xml.mqh"
#define ARRAY_EXP_ALIASES array_aliases

#define FILE_EXCLUDE_ALIASES "ExcludeOrders.xml.mqh"
#define ARRAY_EXCLUDE_ORDERS array_exclude_orders

#define FILE_FONT_BOLT "Font_MT_Bold.ttf.mqh"
#define ARRAY_FONT_BOLT array_font_bolt

#define FILE_PROTOTYPES "Prototypes.mqh"
#define ARRAY_PROTOTYPES array_prototypes

#ifndef MAKE_UTIL
   #include "ActivePositions.xml.mqh"
   #include "HistoryPositions.xml.mqh"
   #include "ExpertAliases.xml.mqh"
   #include "ExcludeOrders.xml.mqh"
   #ifdef HEDGE_PANEL
      #include "Settings.xml.mqh"
      #include "Font_MT_Bold.ttf.mqh"
   #endif
   #ifdef HLIBRARY
      #include "Prototypes.mqh.mqh"
   #endif
#endif
#include <Files\File.mqh>
#include <Arrays\ArrayLong.mqh>

#include "..\XML\XmlAttribute.mqh"
#include "..\XML\XmlElement.mqh"
#include "..\XML\XmlDocument.mqh"

class HedgeManager;
class Position;
class Order;
//class 
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
   RES_PROTOTYPES,
   ///
   /// ������ ����������� �������.
   ///
   RES_EXCLUDE_ORDERS
};
///
/// ������������ ������ �� ������� ���� ������������.
///
class CResources
{
   public:
      CResources()
      {
         if(!MQLInfoInteger(MQL_TESTER))
            failed = !CheckInstall();
      }
      ///
      /// ������, ���� ����������� ��� ������ ����� �� ��������������.
      ///
      bool Failed(){return failed;}
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
         if(!MQLInfoInteger(MQL_TESTER))
         {
            int res = MessageBox("HedgeTerminal detected first time use. This master help you install" + 
            " HedgeTerminal on your PC. Press \'OK' for continue or cancel for exit HedgeTerminal.", VERSION, MB_OKCANCEL);
            if(res == IDCANCEL)
               return false;
            res = MessageBox("For corectly work HedgeTerminal needed install some files in" +
            " .\MQL5\Files\HedgeTerminal derectory. For install files press \'��\' or cancel for exit.", VERSION, MB_OKCANCEL);
            if(res == IDCANCEL)
               return false;
         }
         return InstallMissingFiles();
      }
      ///
      /// ������ ���������� ����������� �������.
      ///
      void WizardInstallExclude(HedgeManager* manager)
      {
         if(CheckResource(RES_EXCLUDE_ORDERS))return;
         int total = manager.ActivePosTotal();
         if(total == 0 || manager.HistoryPosTotal())
         {
            if(!InstallResource(RES_EXCLUDE_ORDERS))
               ExpertRemove();
            return;
         }
         int res = MessageBox("HedgeTerminal detected first time use, but your have " + (string)total + " active orders."+
         " You can manually close them in HedgeTeminal or hide it in HedgeTerminal. If you want close orders manuale, press \'YES\' "+
         "In this case, you have to make a further " + (string)total + " trading activities. If you want to hide these orders from HedgeTerminal,"+
         " press \'NO\' and go into the next step. If you are not ready continue press \'CANCEL\'. In this case HedgeTerminal complete its work.",
         VERSION, MB_YESNOCANCEL);
         switch(res)
         {
            case IDYES:
               if(!InstallResource(RES_EXCLUDE_ORDERS))
                  ExpertRemove();
               return;
            case IDNO:
               if(!WizardClosePositions())
                  ExpertRemove();
               else
               {
                  manager.OnRefresh();
                  InstallResource(RES_EXCLUDE_ORDERS);
                  AddExcludeOrders(manager);
               }
               return;
            case IDCANCEL:
               ExpertRemove();
               break;
         }
      }
      ///
      /// ������ �������� �������.
      ///
      bool WizardClosePositions()
      {
         int res = IDRETRY;
         while(res == IDRETRY && PositionsTotal()>0)
         {
            res = MessageBox("To hide the orders need to close all positions. You have " + (string)PositionsTotal() + " positions to be closed." +
            " Now close them in MetaTrader 5 and press \'RETRY\' to continue. If you can not close a position or change your mind, click \'CANCEL\'.",
            VERSION, MB_RETRYCANCEL);
         }
         if(PositionsTotal()>0)
            return false;
         return true;
      }
      
      /*bool AutomateClosePos()
      {
         for(int i = PositionsTotal(); i >= 0; i--)
         {
            string smb = PositionGetSymbol(i);
            if(!PositionSelect(smb))
            {
               intr res = MessageBox("Filed close position on symbol " + smb +
               ". HedgeTerminal complete its work. Close position manuale and try run HedgeTerminal after.", VERSION, MB_OK);
               return false;
            }
            
         }
      }*/
      
      void AddExcludeOrders(HedgeManager* manager)
      {
         CXmlDocument doc;
         string err = "";
         if(!doc.CreateFromFile(GetFileNameByType(RES_EXCLUDE_ORDERS), err))
            return;
         CXmlElement* element = NULL;
         int total = manager.ActivePosTotal();
         for(int i = 0; i < total; i++)
         {
            element = new CXmlElement();
            element.SetName("Order");
            CXmlAttribute* attr = new CXmlAttribute();
            attr.SetName("AccountID");
            attr.SetValue(IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));   
            element.AttributeAdd(attr);
            Position* pos = manager.ActivePosAt(i);
            ulong id = pos.GetId();
            attr = new CXmlAttribute();
            attr.SetName("ID");
            attr.SetValue(IntegerToString(pos.GetId()));
            element.AttributeAdd(attr);
            doc.FDocumentElement.ChildAdd(element);
         }
         doc.SaveToFile(GetFileNameByType(RES_EXCLUDE_ORDERS));
      }
      ///
      /// ������������ ������������� ����� � ���������� HedgeTerminal.
      ///
      bool InstallMissingFiles(void)
      {
         printf("����������� ������������� �����");
         bool res = true;
         if(!CheckResource(RES_ACTIVE_POS_XML))
            res = InstallResource(RES_ACTIVE_POS_XML);
         if(!CheckResource(RES_SETTINGS_XML))
            res = InstallResource(RES_SETTINGS_XML);
         if(!CheckResource(RES_HISTORY_POS_XML))
            res = InstallResource(RES_HISTORY_POS_XML);
         if(!CheckResource(RES_EXPERT_ALIASES))
            res = InstallResource(RES_EXPERT_ALIASES);
         //if(!CheckResource(RES_FONT_MT_BOLT))
         //   res = InstallResource(RES_FONT_MT_BOLT);
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
               fileName = ".\HedgeTerminal\Settings.xml";
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
            case RES_EXCLUDE_ORDERS:
               fileName = ".\HedgeTerminal\ExcludeOrders.xml";
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
            case RES_EXCLUDE_ORDERS:
               FileWriteArray(handle, ARRAY_EXCLUDE_ORDERS);
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
      /// ��������� ����������� ������. (������ ��� HLYBRARY)
      ///
      bool CheckInstall()
      {
         bool res = true;
         if(UsingFirstTime())
         {
            printf("���������� ������ �������������");
            if(!WizardForUseFirstTime())
            {
               printf("Installing HedgeTerminal filed. Unable to continue. Goodbuy:(");
               ExpertRemove();
               return false;
            }
            res = InstallMissingFiles();
         }
         return res;
      }
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
         int handle = FileOpen(fileName, FILE_BIN|FILE_WRITE);
         if(handle == -1)
            printf("Failed create file \'" + fileName + "\'. LastError: " + (string)GetLastError());
         return handle;
      }
      /*static*/ CFile file;
      ///
      /// ������, ����������� ��� ������ ����� �� ��������������.
      ///
      bool failed;
};