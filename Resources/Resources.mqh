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
   #include ".\Files\ActivePositions.xml.mqh"
   #include ".\Files\HistoryPositions.xml.mqh"
   #include ".\Files\ExpertAliases.xml.mqh"
   #include ".\Files\ExcludeOrders.xml.mqh"
   #ifdef HEDGE_PANEL
      #include ".\Files\Settings.xml.mqh"
      //#include "Font_MT_Bold.ttf.mqh"
   #endif
   #ifdef HLIBRARY
      #include "Prototypes.mqh.mqh"
   #endif
#endif
#include <Files\File.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Trade\Trade.mqh>

#include "..\XML\XmlAttribute.mqh"
#include "..\XML\XmlElement.mqh"
#include "..\XML\XmlDocument.mqh"
#include "..\Log.mqh"

class HedgeManager;
class Position;
class Order;
//class 
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
   ///
   /// XML файл псевдонимов экпертов.
   ///
   RES_EXPERT_ALIASES,
   ///
   /// Шрифт для отображение итоговой строки.
   ///
   RES_FONT_MT_BOLT,
   ///
   /// MQH файл прототипов функций.
   ///
   RES_PROTOTYPES,
   ///
   /// Список исключенных ордеров.
   ///
   RES_EXCLUDE_ORDERS
};
///
/// Инсталлирует ресурс на жесткий диск пользователя.
///
class CResources
{
   public:
      CResources()
      {
         CommonFlag = FILE_COMMON;
         path = ".\HedgeTerminal\\" +
                AccountInfoString(ACCOUNT_COMPANY) + " - " +
                (string)AccountInfoInteger(ACCOUNT_LOGIN) + "\\";
         if(!MQLInfoInteger(MQL_TESTER))
            failed = !CheckInstall();
      }
      ///
      /// Возвращает флаг, указывающий на тип используемой директории.
      ///
      int FileCommon(){return CommonFlag;}
      ///
      /// Истина, если необходимые для работы файлы не инсталлированы.
      ///
      bool Failed(){return failed;}
      ///
      /// Возвращает истину, если терминал определил, что он используется
      /// впервые на этом комьютере. В противном случае возвращает ложь.
      ///
      bool UsingFirstTime()
      {
         string name;
         string filter = path+"*";
         long handle = FileFindFirst(filter, name, CommonFlag);
         if(handle != INVALID_HANDLE)
         {
            FileFindClose(handle);
            return false;
         }
         return true;
      }
      ///
      /// Мастер инсталяции HedgeTerminal запускаемый в первый раз.
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
            " .\MQL5\Files\HedgeTerminal derectory. For install files press \'ОК\' or cancel for exit.", VERSION, MB_OKCANCEL);
            if(res == IDCANCEL)
               return false;
         }
         return InstallMissingFiles();
      }
      ///
      /// Мастер инсталяции исключающих ордеров.
      ///
      void WizardInstallExclude(HedgeManager* manager)
      {
         if(CheckResource(RES_EXCLUDE_ORDERS))return;
         int total = manager.ActivePosTotal();
         //Удаляем проэкспирированные контракты
         for(int i = manager.ActivePosTotal()-1; i >= 0; i--)
         {
            Position* pos = manager.ActivePosAt(i);
            if(manager.IsExpiration(pos.Symbol()))
               total--;
         }
         if(total == 0)
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
      /// Мастер закрытия позиций.
      ///
      bool WizardClosePositions()
      {
         int res = IDRETRY;
         int autoClose = MessageBox("The HedgeTerminal can automatically close all active positions." + 
         " Click 'OK' if you want to automatically close all positions. Click 'Cancel' if you want to close a position manually.", VERSION, MB_OKCANCEL);
         if(autoClose == IDOK)
            AutoClose();
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
      ///
      /// Автоматически пытается закрыть все активные позиции.
      ///
      void AutoClose()
      {
         if(PositionsTotal() == 0)return;
         CTrade trade;
         for(int i = PositionsTotal()-1; i >= 0; i++)
         {
            string symbol = PositionGetSymbol(i);
            bool res = trade.PositionClose(symbol, Settings.GetDeviation());
            if(res == false)
               LogWriter("Trying to close the position on symbol "+ symbol +
               " failed. Reason: " + trade.ResultRetcodeDescription(), MESSAGE_TYPE_WARNING);
            else
               LogWriter("Position on the " + symbol + " successfully closed.", MESSAGE_TYPE_INFO);
         }
         if(PositionsTotal() > 0)
         {
            int res = MessageBox("Automatic closing of positions failed. Check the settings of the terminal and try to close the position manually.",
            VERSION, MB_OK);
         }
      }
      
      
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
      /// Инсталлирует отсутствующие файлы в директорию HedgeTerminal.
      ///
      bool InstallMissingFiles(void)
      {
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
         //string fail = res ? "O.K." : "Failed";
         //printf("Check the missing files and install them... " + fail);
         return res;
      }
      ///
      /// Проверяет существование файла ресурса.
      /// Возвращает истину если ресурс существует и ложь в противном случае.
      ///
      bool CheckResource(ENUM_RESOURCES typeRes)
      {
         string fileName = GetFileNameByType(typeRes);
         if(FileIsExist(fileName, CommonFlag))
            return true;
         return false;
      }
      ///
      /// Возвращает имя файла в зависимости от типа ресурса.
      ///
      string GetFileNameByType(ENUM_RESOURCES typeRes)
      {
         string fileName = path;
         switch(typeRes)
         {
            case RES_SETTINGS_XML:
               #ifdef HEDGE_PANEL
                  fileName += SettingsPath;
               #endif
               //#ifndef HEDGE_PANEL
               //   fileName += "Settings.xml";
               //#endif
               break;
            case RES_ACTIVE_POS_XML:
               fileName += "ActivePositions.xml";
               break;
            case RES_HISTORY_POS_XML:
               fileName += "HistoryPositions.xml";
               break;
            case RES_EXPERT_ALIASES:
               fileName += "ExpertAliases.xml";
               break;
            case RES_FONT_MT_BOLT:
               fileName += "Arial Rounded MT Bold.ttf";
               break;
            case RES_PROTOTYPES:
               fileName += "Prototypes.mqh";
               break;
            case RES_EXCLUDE_ORDERS:
               fileName += "ExcludeOrders.xml";
         }
         return fileName;
      }
      ///
      /// Инсталлирует файл соответствующего типа.
      /// \param typeRes - Тип инсталлируемого файла.
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
            /*case RES_FONT_MT_BOLT:
               FileWriteArray(handle, ARRAY_FONT_BOLT);
               break;*/
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
      /// Проверяет инсталляцию файлов. (Только для HLYBRARY)
      ///
      bool CheckInstall()
      {
         bool res = true;
         if(UsingFirstTime())
         {
            printf("Defined first use. The installation wizard starts...");
            if(!WizardForUseFirstTime())
            {
               printf("Installing HedgeTerminal filed. Unable to continue. Goodbuy:(");
               ExpertRemove();
               return false;
            }
         }
         res = InstallMissingFiles();
         return res;
      }
      ///
      /// Проверяет возможность создания файла. Возвращает истину,
      /// если файл можно создать и ложь в противном случае.
      ///
      bool CheckCreateFile(string fileName)
      {
         bool res = FolderCreate("HedgeTerminal", CommonFlag);
         if(!res)
         {
            printf("Failed create directory of HedgeTerminal. LastError:", GetLastError());
            return false;
         }
         if(FileIsExist(fileName, CommonFlag))
         {
            printf("File \'" + fileName + "\' already exits, for reinstalling file delete it.");
            return false;
         }
         return true;
      }
      ///
      /// Открывает файл для записи и возвращает его хэндл. Возвращает -1 в случае неудачи.
      ///
      int CreateFile(string fileName)
      {
         int handle = FileOpen(fileName, CommonFlag|FILE_BIN|FILE_WRITE);
         if(handle == -1)
            printf("Failed create file \'" + fileName + "\'. LastError: " + (string)GetLastError());
         return handle;
      }
      
      ///
      /// Истина, необходимые для работы файлы не инсталлированы.
      ///
      bool failed;
      ///
      /// Флаг, указывающий расположение директорий.
      ///
      int CommonFlag;
      ///
      /// Путь к директории с файлами.
      ///
      string path;
};