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

#define FILE_PROTOTYPES "Prototypes.mqh.mqh"
#define ARRAY_PROTOTYPES array_prototypes

#define FILE_HEDGE_MA "HedgeMA.mq5.mqh"
#define ARRAY_HEDGE_MA array_hedge_ma

#define FILE_CHAOS2 "Chaos2.mq5.mqh"
#define ARRAY_CHAOS2 array_chaos2

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
      #include ".\Files\Prototypes.mqh.mqh"
      #include ".\Files\Chaos2.mq5.mqh"
      //#include ".\Files\HedgeMA.mq5.mqh"
   #endif
#endif
#include <Files\File.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Trade\Trade.mqh>

#include <XML\XmlAttribute.mqh>
#include <XML\XmlElement.mqh>
#include <XML\XmlDocument.mqh>
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
   /// Список исключенных ордеров.
   ///
   RES_EXCLUDE_ORDERS,
   ///
   /// MQH файл прототипов функций.
   ///
   RES_PROTOTYPES,
   ///
   /// Файл эксперта Chaos2 описанный в статье.
   ///
   RES_CHAOS2
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
         path = ".\\HedgeTerminal\\Brokers\\" + AccountCompany() + " - " +
                (string)AccountInfoInteger(ACCOUNT_LOGIN) + "\\";
         if(!MQLInfoInteger(MQL_TESTER))
            failed = !CheckInstall();
      }
      ///
      /// Возвращает название компании удаляя символы, которые
      /// не могу использоваться в названии файлов.
      ///
      string AccountCompany(void)
      {
         string acc = AccountInfoString(ACCOUNT_COMPANY);
         uchar acc_array[];
         StringToCharArray(acc, acc_array, 0, WHOLE_ARRAY, CP_ACP);
         uchar acc_result[];
         ArrayResize(acc_result, ArraySize(acc_array));
         int r = 0;
         for(int i = 0; i < ArraySize(acc_array); i++)
         {
            uchar ch = acc_array[i];
            if(!IsAsciiCharValid(ch))
               continue;
            acc_result[r] = ch;
            r++;
         }
         string company = CharArrayToString(acc_result, 0, WHOLE_ARRAY, CP_ACP);
         return company;
      }
      ///
      /// Истина, если переданный символ может быть частью названия файла. 
      /// Ложь в противном случае.
      ///
      bool IsAsciiCharValid(uchar ch)
      {
         if(ch == ' ')
            return true;
         if(ch < 48)
            return false;
         if(ch > 57 && ch < 65)
            return false;
         switch(ch)
         {
            case 124: return false;
            case 126: return false;
            case 128: return false;
            case 155: return false;
            case 156: return false;
         }
         return true;
      }
      ///
      /// Возвращает путь к директории текущего брокера.
      ///
      string GetBrokerDirectory()
      {
         return path;
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
         #ifdef DEMO
         useFirstTime = false;
         #endif
         string name;
         string filter = path+"*";
         long handle = FileFindFirst(filter, name, CommonFlag);
         //printf("handle: " + (string)handle + " filter: " + filter + " Common: " + (string)CommonFlag);
         if(handle != INVALID_HANDLE)
         {
            FileFindClose(handle);
            return false;
         }
         #ifdef DEMO
         useFirstTime = true;
         #endif
         return true;
      }
      ///
      /// Мастер инсталяции HedgeTerminal запускаемый в первый раз.
      ///
      bool WizardForUseFirstTime()
      {
         if(!MQLInfoInteger(MQL_TESTER))
         {
            //
            // HedgeTerminal определил, что используется впервые. Этот мастер установки поможет вам инсталлировать
            // HedgeTerminal на Ваш компьютер. Для корректной работы, HedgeTerminal'у необходимо установить некоторые файлы
            // на Ваш компьютер, в директорию .\HedgeTerminal. Для начала установки файлов нажмите O.K. или CANCEL для выхода.
            //
            int res = MessageBox("HedgeTerminal is used for the first time. This Wizard will help you to install" + 
            " HedgeTerminal on your PC. For its corect operation, HedgeTerminal is required to install some files to the " +
            ".\\HedgeTerminal folder. Click \'ОК\' to begin installation or \'Cancel\' to exit.", VERSION, MB_OKCANCEL);
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
         //
         // HedgeTerminal определил, что используется впервые, однако вы имеете #total активных ордеров (разнонаправленных позиций). Вы можете скрыть их в 
         // HedgeTerminal сейчас, или вручную закрыть их позже. Если Вы хотите скрыть эти ордера (разнонаправленные позиции) сейчас, то нажмите кнопку YES
         // и перейдите к следующему шагу установки. Если Вы хотите закрыть ордера позже, вручную, нажмите NO. В этом случае, в будущем, Вам потребуется
         // совершить #total торговых действий по закрытию этих ордеров, ордерами противоположного направления.Если Вы не готовы продолжать,
         // или не знаете, какой вариант выбрать - нажмите CANCEL. В этом случае HedgeTerminal завершит свою работу.
         //
         int res = MessageBox("HedgeTerminal is used for the first time, but your have " + (string)total + " active orders."+
         " You can hide them in HedgeTerminal or close manually later. To hide these orders, click \'Yes\' and go into the next step." + 
         " Click \'No\' if you want close these orders manually later. In this case, you have to perform " + (string)total + " trades of opposite direction." +
         " Click \'Cancel\' if you are not ready to continue. In this case HedgeTerminal will be terminated.",
         VERSION, MB_YESNOCANCEL);
         switch(res)
         {
            case IDNO:
               if(!InstallResource(RES_EXCLUDE_ORDERS))
                  ExpertRemove();
               return;
            case IDYES:
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
         if(PositionsTotal() == 0)return true;
         int res = IDRETRY;
         //
         // HedgeTerminal может автоматически закрыть все активные ордера (разнонаправленные позиции). Нажмите OK, если Вы хотите
         // закрыть их автоматически. Нажмите CANCEL, если Вы хотите закрыть позиции вручную.
         //
         int autoClose = MessageBox("HedgeTerminal can automatically close all active positions." + 
         " Click 'OK' if you want to close all positions automatically. Click 'Cancel' if you want to close positions manually.", VERSION, MB_OKCANCEL);
         if(autoClose == IDOK)
            AutoClose();
         while(res == IDRETRY && PositionsTotal()>0)
         {
            //
            // Прежде чем скрыть все активные ордера, необходимо закрыть #PositionsTotal существующих нетто-позиций в MetaTrader 5. Сейчас закройте
            // их в MetaTrader 5 и нажмите RETRY для продолжения. Если Вы не можете закрыть позиции или передумали - нажмите CANCEL.
            //
            res = MessageBox("Prior to hiding all the active orders, you need to close " + (string)PositionsTotal() + " active positions." +
            " Close them in MetaTrader 5 now and click \'Retry\' to continue. Click \'Cancel\' if you cannot close positions or if you've changed your mind.",
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
         trade.LogLevel(LOG_LEVEL_NO);
         for(int i = PositionsTotal()-1; i >= 0; i--)
         {
            string symbol = PositionGetSymbol(i);
            bool res = trade.PositionClose(symbol, Settings.GetDeviation());
            if(PositionSelect(symbol))
               //
               // Попытка закрыть позицию на символе symbol 'symbol' завершилась неудачей. Причина: trade.ResultRetcodeDescription()
               //
               LogWriter("Failed to close position on symbol "+ symbol+". Reason: " + trade.ResultRetcodeDescription(), MESSAGE_TYPE_WARNING);
            else
               LogWriter("Position on " + symbol + " successfully closed.", MESSAGE_TYPE_INFO);
         }
         if(PositionsTotal() > 0)
         {
            //
            // Автоматическое закрытие позиции завершилось неудачей. Проверьте настройки терминала или попробуйте закрыть позиции вручную, через MetaTrader 5.
            //
            int res = MessageBox("Failed to close positions automatically. Check terminal settings and try to close positions manually.",
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
         #ifdef HEDGE_PANEL
         if(!CheckResource(RES_SETTINGS_XML))
            res = InstallResource(RES_SETTINGS_XML);
         #endif
         if(!MQLInfoInteger(MQL_TESTER))
         {
            if(!CheckResource(RES_ACTIVE_POS_XML))
               res = InstallResource(RES_ACTIVE_POS_XML);
            if(!CheckResource(RES_HISTORY_POS_XML))
               res = InstallResource(RES_HISTORY_POS_XML);
            if(!CheckResource(RES_EXPERT_ALIASES))
               res = InstallResource(RES_EXPERT_ALIASES);
         }
         #ifdef HLIBRARY
         if(!CheckResource(RES_PROTOTYPES))
            res = InstallResource(RES_PROTOTYPES);
         if(!CheckResource(RES_CHAOS2))
            res = InstallResource(RES_CHAOS2);
         #endif
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
         string dir = ".\\HedgeTerminal\\";
         switch(typeRes)
         {
            case RES_SETTINGS_XML:
               #ifdef HEDGE_PANEL
                  fileName = dir + SettingsPath;
               #endif
               break;
            case RES_ACTIVE_POS_XML:
               fileName += "ActivePositions.xml";
               break;
            case RES_HISTORY_POS_XML:
               fileName += "HistoryPositions.xml";
               break;
            case RES_EXCLUDE_ORDERS:
               fileName += "ExcludeOrders.xml";
               break;
            case RES_EXPERT_ALIASES:
               fileName = dir + "ExpertAliases.xml";
               break;
            /*case RES_FONT_MT_BOLT:
               fileName += "Arial Rounded MT Bold.ttf";
               break;*/
            case RES_PROTOTYPES:
               fileName = dir + "MQL5\\Include\\Prototypes.mqh";
               break;
            case RES_CHAOS2:
               fileName = dir + "MQL5\\Experts\\Chaos2.mq5";
               break;
         }
         return fileName;
      }
      ///
      /// Инсталлирует файл соответствующего типа.
      /// \param typeRes - Тип инсталлируемого файла.
      ///
      bool  InstallResource(ENUM_RESOURCES typeRes)
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
            case RES_CHAOS2:
               FileWriteArray(handle, ARRAY_CHAOS2);
               break;
            #endif
            default:
               //
               // HedgeTerminal не смог создать файл fileName. Проверте Ваши разрешения в системе на создание файлов.
               //
               printf("HedgeTerminal failed to create the '" + fileName + "' file. Check your system permissions to create files.");
               FileClose(handle);
               return false;
         }
         FileClose(handle);
         //
         // HedgeTerminal инсталлирован на Ваш компьютер.
         //
         printf("HedgeTerminal installed '" + fileName + "' on your PC.");
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
            //
            // Определено первое использование. Запускается мастер установки...
            //
            printf("First time use. Starting the Installation Wizard...");
            if(!WizardForUseFirstTime())
            {
               //
               // Инсталляция HedgeTerminal завершилась неудачей. Продолжение невозможно. Пока:(
               //
               printf("Failed to install HedgeTerminal. Unable to continue.");
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
            //
            // Не удалось создать директорию для HedgeTerminal. Последняя ошибка GetLastError().
            //
            printf("Failed to create HedgeTerminal folder. LastError:", GetLastError());
            return false;
         }
         if(FileIsExist(fileName, CommonFlag))
         {
            //
            // Файл 'fileName' уже существует, для переустановки файла удалите его старую версию.
            //
            printf("File \'" + fileName + "\' already exits. To reinstall the file, simply delete its older version.");
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
            //
            // Не удалось создать файл 'fileName' + последняя ошибка GetLastError()
            //
            printf("Failed to create \'" + fileName + "\' file. LastError: " + (string)GetLastError());
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