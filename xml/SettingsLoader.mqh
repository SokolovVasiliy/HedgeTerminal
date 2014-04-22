#include <Arrays\ArrayObj.mqh>
#include "XmlBase.mqh"
#include "XmlDocument.mqh"
#include "XmlElement.mqh"
#include "XmlAttribute.mqh"


#include "..\Log.mqh"
#include "..\Settings.mqh"
#include "XmlHistPos.mqh"
///
/// Загружает настройки из XML файла.
///
class XmlLoader
{
   public:
      XmlLoader();
      CArrayObj* GetActiveColumns(){return GetPointer(activeTab);}
      CArrayObj* GetHistoryColumns(){return GetPointer(historyTab);}
      string GetNameExpertByMagic(ulong magic);
      double GetLevelVirtualOrder(ulong id, ENUM_VIRTUAL_ORDER_TYPE type);
      void SaveXmlAttr(ulong id, ENUM_VIRTUAL_ORDER_TYPE type, string level);
   private:
      ///
      /// Известные секции настроек.
      ///
      enum ENUM_SET_SECTIONS
      {
         ///
         /// Секция определяет колонки и их ширину.
         ///
         SET_COLUMNS_SHOW,
         ///
         /// Секция прочих настроек.
         ///
         SET_OTHER,
         ///
         /// Неопределенная секция настроек.
         ///
         SET_NOTDEF
      };
      ///
      /// Определяет тип вкладки, для которой будет парситься список колонок.
      ///
      enum ENUM_TAB_TYPE
      {
         ///
         /// Вкладка активных позиций
         ///
         TAB_ACTIVE,
         ///
         /// Вкладка исторических позиций.
         ///
         TAB_HISTORY
      };
      ///
      /// Список колонок для активных позиций.
      ///
      CArrayObj activeTab;
      ///
      /// Список колонок для исторических позиций.
      ///
      CArrayObj historyTab;
      ///
      /// Содежрит строковые псевдонимы экспертов.
      ///
      CArrayObj Aliases;
      ///
      /// Исторические позиции.
      ///
      CArrayObj HistPos;
      ///
      /// XML документ с информацией о позицияях.
      ///
      CXmlDocument XmlHistFile;
      ///
      /// Строковый псевдоноим для стратегии.
      ///
      class Aliase : public CObject
      {
         public:
            ulong Magic(void){return magic;}
            void Magic(ulong mg){magic = mg;}
            string Name(void){return name;}
            void Name(string n){name = n;}
            Aliase(){name = "";}
            Aliase(ulong ex_magic, string ex_name)
            {
               magic = ex_magic;
               name = ex_name;
            }
         private:
            virtual int Compare(CObject* node, int mode=0)
            {
               Aliase* aliase = node;
               if(magic > aliase.Magic())return 1;
               if(magic < aliase.Magic())return -1;
               return 0;
            }
            ulong magic;
            string name;
      };
      ENUM_SET_SECTIONS GetTypeSection(string nameNode);
      //Группа функций для парсинга прочих настроек.
      void ParseOtherSettings(CXmlElement* xmlItem);
      void ParseBeginMarker(CXmlElement* xmlItem);
      void ParseDeviation(CXmlElement* xmlItem);
      void ParseTimeout(CXmlElement* xmlItem);
      void ParseRefreshRates(CXmlElement* xmlItem);
      //Группа переменных содержащие значения прочих настроек.
      ulong beginMarker;
      int deviation;
      int timeout;
      int refrshRates;
      
      void ParseColumnsSettings(CXmlElement* xmlItem);
      void ParseColumns(CXmlElement* activeTab, ENUM_TAB_TYPE tabType);
      void ParseColumn(CXmlElement* activeTab, ENUM_TAB_TYPE tabType);
      ENUM_COLUMN_TYPE GetColumnType(string columnId);
      bool CheckCompatibleType(ENUM_COLUMN_TYPE, ENUM_TAB_TYPE tabType);
      bool CheckValidColumn(CXmlElement* xmlColumn);
      void LoadSettings(void);
      void LoadAliases(void);
      void LoadHistOrders(void);
      void TryParseAliase(CXmlElement* xmlItem);
      
};

///
/// Загружает настройки во время инициализации.
/// \param path - путь к файлу.
///
XmlLoader::XmlLoader()
{
   LoadSettings();
   LoadAliases();
   LoadHistOrders();
}

void XmlLoader::LoadSettings(void)
{
   CXmlDocument doc;
   string err;
   string path = ".\HedgeTerminal\HedgeTerminalSettings.xml";
   if(!doc.CreateFromFile(path, err))
   {
      printf(err);
      return;
   }
   for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
   {
      CXmlElement* xmlItem = doc.FDocumentElement.GetChild(i);
      switch(GetTypeSection(xmlItem.GetName()))
      {
         case SET_COLUMNS_SHOW:
            ParseColumnsSettings(xmlItem);
            break;
         case SET_OTHER:
            ParseOtherSettings(xmlItem);
            break;
      }
   }
}

void XmlLoader::LoadAliases(void)
{
   CXmlDocument doc;
   string err;
   string path = ".\HedgeTerminal\ExpertAliases.xml";
   if(!doc.CreateFromFile(path, err))
   {
      printf(err);
      return;
   }
   for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
   {
      CXmlElement* xmlItem = doc.FDocumentElement.GetChild(i);
      TryParseAliase(xmlItem);
   }
}

void XmlLoader::SaveXmlAttr(ulong id, ENUM_VIRTUAL_ORDER_TYPE type, string level)
{
   CXmlElement* xmlItem;
   XmlHistPos* hpos = new XmlHistPos(id);
   int index = HistPos.Search(hpos);
   delete hpos;
   if(index == -1)
   {
      xmlItem = new CXmlElement();
      xmlItem.SetName("Position");
      ulong accountId = AccountInfoInteger(ACCOUNT_LOGIN);
      CXmlAttribute* attr = new CXmlAttribute();
      attr.SetName("AccountID");
      attr.SetValue((string)accountId);
      xmlItem.AttributeAdd(attr);
      attr = new CXmlAttribute();
      attr.SetName("ID");
      attr.SetValue((string)id);
      xmlItem.AttributeAdd(attr);
      attr = new CXmlAttribute();
      string st = "";
      if(type == VIRTUAL_STOP_LOSS)
         st = "VirtualStopLoss";
      else
         st = "VirtualTakeProfit";
      attr.SetName(st);
      attr.SetValue(level);
      xmlItem.AttributeAdd(attr);
      XmlHistFile.FDocumentElement.ChildAdd(xmlItem);
      XmlHistFile.SaveToFile(Resources.GetFileNameByType(RES_HISTORY_POS_XML));
      string err;
      XmlHistFile.CreateFromFile(Resources.GetFileNameByType(RES_HISTORY_POS_XML), err);
   }
   
}

void XmlLoader::LoadHistOrders(void)
{
   if(HistPos.SortMode() == -1)
      HistPos.Sort();
   
   string err;
   string path = Resources.GetFileNameByType(RES_HISTORY_POS_XML);
   if(!XmlHistFile.CreateFromFile(path, err))
   {
      printf(err);
      return;
   }
   for(int i = 0; i < XmlHistFile.FDocumentElement.GetChildCount(); i++)
   {
      CXmlElement* xmlItem = XmlHistFile.FDocumentElement.GetChild(i);
      XmlHistPos* xmlPos = new XmlHistPos(xmlItem);
      if(!xmlPos.IsValid())
         delete xmlPos;
      HistPos.InsertSort(xmlPos);
   }
}

double XmlLoader::GetLevelVirtualOrder(ulong id, ENUM_VIRTUAL_ORDER_TYPE type)
{
   XmlHistPos* hpos = new XmlHistPos(id);
   int index = HistPos.Search(hpos);
   delete hpos;
   if(index == -1)
      return 0.0;
   hpos = HistPos.At(index);
   double value = 0.0;
   int dbg = 5;
   if(type == VIRTUAL_STOP_LOSS)
      value = hpos.StopLoss();
   if(type == VIRTUAL_TAKE_PROFIT)
      value = hpos.TakeProfit();
   return value;
}

string XmlLoader::GetNameExpertByMagic(ulong magic)
{
   if(Aliases.SortMode() == -1)
      Aliases.Sort();
   int dbg = 5;
   if(magic == 123847)
      dbg = 6;
   Aliase* aliase = new Aliase(magic, "");
   int index = Aliases.Search(aliase);
   delete aliase;
   if(index == -1)
      return IntegerToString(magic);
   else
   {
      aliase = Aliases.At(index);
      return aliase.Name();
   }
}

void XmlLoader::TryParseAliase(CXmlElement* xmlItem)
{
   if(xmlItem.GetName() != "Expert")return;
   CXmlAttribute* xmlName = xmlItem.GetAttribute("Name");
   if(xmlName == NULL)return;
   string ex_name = xmlName.GetValue();
   CXmlAttribute* xmlMagic = xmlItem.GetAttribute("Magic");
   if(xmlMagic == NULL)return;
   ulong ex_magic = StringToInteger(xmlMagic.GetValue());
   if(ex_magic == 0)return;
   if(ex_name == "")return;
   if(Aliases.SortMode() == -1)
      Aliases.Sort();
   Aliases.InsertSort(new Aliase(ex_magic, ex_name));
}

///
/// Возвращает идентификатор секции настроек, которому соответствует текущему узлу.
///
ENUM_SET_SECTIONS XmlLoader::GetTypeSection(string nameNode)
{
   if(nameNode == "Show-Columns")
      return SET_COLUMNS_SHOW;
   if(nameNode == "Other-Settings")
      return SET_OTHER;
   return SET_NOTDEF;
}

///
/// Разбирает секцию настройки колонок.
/// \param xmlItem - секция настроек колонок Show-Columns
///
void XmlLoader::ParseColumnsSettings(CXmlElement *xmlItem)
{
   for(int i = 0; i < xmlItem.GetChildCount(); i++)
   {
      CXmlElement* xmlTab = xmlItem.GetChild(i);
      if(xmlTab.GetName() == "Active-Position")
         ParseColumns(xmlTab, TAB_ACTIVE);
      else if(xmlTab.GetName() == "History-Position")
         ParseColumns(xmlTab, TAB_HISTORY);
   }
}

///
/// Разбирает секцию прочих настроек.
///
void XmlLoader::ParseOtherSettings(CXmlElement *xmlItem)
{
   for(int i = 0; i < xmlItem.GetChildCount(); i++)
   {
      CXmlElement* xmlTab = xmlItem.GetChild(i);
      if(xmlTab.GetName() == "Begin-Marker")
         ParseBeginMarker(xmlTab);
      else if(xmlTab.GetName() == "Deviation")
         ParseDeviation(xmlTab);
   }
}

///
/// Парсит узел настроек отвечающий за значение начального маркера.
///
void XmlLoader::ParseBeginMarker(CXmlElement* xmlTab)
{
   CXmlAttribute* attr = xmlTab.GetAttribute("ID");
   if(attr == NULL)return;
   int id = (int)StringToInteger(attr.GetValue());
   if(id > 0)
      beginMarker = id;
}

///
/// Парсит узел настроек отвечающий за велечину предельного отклонения цены.
///
void XmlLoader::ParseDeviation(CXmlElement *xmlTab)
{
   CXmlAttribute* attr = xmlTab.GetAttribute("Value");
   if(attr == NULL)return;
   int dev = (int)StringToInteger(attr.GetValue());
   if(dev > 0)
      deviation = dev;
}

///
/// Парсит узел настроек отвечающий за велечину предельного отклонения цены.
///
void XmlLoader::ParseTimeout(CXmlElement *xmlTab)
{
   CXmlAttribute* attr = xmlTab.GetAttribute("Seconds");
   if(attr == NULL)return;
   int sec = (int)StringToInteger(attr.GetValue());
   if(sec > 0)
      timeout = sec;
}

///
/// Парсит узел настроек отвечающий за велечину предельного отклонения цены.
///
void XmlLoader::ParseRefreshRates(CXmlElement *xmlTab)
{
   CXmlAttribute* attr = xmlTab.GetAttribute("Milliseconds");
   if(attr == NULL)return;
   int msc = (int)StringToInteger(attr.GetValue());
   if(msc > 0)
      refrshRates = msc;
}

///
/// Парсит список колонок для определенного типа таба
/// \param tabType - Тип таба, для которого будут парситься колонки.
///
void XmlLoader::ParseColumns(CXmlElement* xmlItem, ENUM_TAB_TYPE tabType)
{
   for(int i = 0; i < xmlItem.GetChildCount(); i++)
   {
      CXmlElement* xmlColumn = xmlItem.GetChild(i);
      if(!CheckValidColumn(xmlColumn))
      {
         LogWriter("Child node #" + (string)i + " in " + xmlItem.GetName() + " will be skip.", MESSAGE_TYPE_WARNING);
         continue;
      }
      CXmlAttribute* columnId = xmlColumn.GetAttribute("ID");
      ENUM_COLUMN_TYPE columnType = GetColumnType(columnId.GetValue());
      if(!CheckCompatibleType(columnType, tabType))
      {
         string typeTable = tabType == TAB_ACTIVE ? "table of active positions" : "table of history positions";
         LogWriter("Value of attribute's \'" + columnId.GetName() + "=" + columnId.GetValue() + "\' not compatible for " + typeTable, MESSAGE_TYPE_WARNING);
         continue;
      }
      ParseColumn(xmlColumn, tabType);
   }
}

///
/// Парсит конкретную xml колонку и переводит ее в DefColumn.
///
void XmlLoader::ParseColumn(CXmlElement *xmlColumn, ENUM_TAB_TYPE tabType)
{
   CXmlAttribute* id = xmlColumn.GetAttribute("ID");
   ENUM_COLUMN_TYPE colType = GetColumnType(id.GetValue());
   CXmlAttribute* xmlName = xmlColumn.GetAttribute("Name");
   string name = xmlName.GetValue();
   CXmlAttribute* xmlWidth = xmlColumn.GetAttribute("Width");
   int width = (int)StringToInteger(xmlWidth.GetValue());
   if(width <= 0)return;
   DefColumn* defColumn = new DefColumn(colType, name, width, colType == COLUMN_COLLAPSE);
   if(tabType == TAB_ACTIVE)
      activeTab.Add(defColumn);
   else if(tabType == TAB_HISTORY)
      historyTab.Add(defColumn);
   else
      delete defColumn;
}

///
/// Проверяет на корректность узел Column.
/// \return Истина, если узел column корректно составлен и ложь в противном случае.
///
bool XmlLoader::CheckValidColumn(CXmlElement* xmlColumn)
{
   if(xmlColumn.GetName() != "Column")
   {
      LogWriter("/'" + xmlColumn.GetName() + "/' - invalid node name " + "in xml file. Name of node must be only /'Column/'", MESSAGE_TYPE_WARNING);
      return false;
   }
   CXmlAttribute* attr = xmlColumn.GetAttribute("ID");
   if(attr == NULL)
   {
      LogWriter("missing attrbute /'ID/' in node column.", MESSAGE_TYPE_WARNING);
      return false;
   }
   attr = xmlColumn.GetAttribute("Name");
   if(attr == NULL)
   {
      LogWriter("missing attrbute /'Name/' in node column.", MESSAGE_TYPE_WARNING);
      return false;
   }
   attr = xmlColumn.GetAttribute("Width");
   if(attr == NULL)
   {
      LogWriter("missing attrbute /'Width/' in node column.", MESSAGE_TYPE_WARNING);
      return false;
   }
   return true;
}
///
/// Возвращает тип колонки, в зависимости от ее идентификатора
///
ENUM_COLUMN_TYPE XmlLoader::GetColumnType(string columnId)
{
   if(columnId == "CollapsePosition")
      return COLUMN_COLLAPSE;
   if(columnId == "Magic")
      return COLUMN_MAGIC;
   if(columnId == "Symbol")
      return COLUMN_SYMBOL;
   if(columnId == "EntryID")
      return COLUMN_ENTRY_ORDER_ID;
   if(columnId == "EntryDate")
      return COLUMN_ENTRY_DATE;
   if(columnId == "Type")
      return COLUMN_TYPE;
   if(columnId == "Volume")
      return COLUMN_VOLUME;
   if(columnId == "EntryPrice")
      return COLUMN_ENTRY_PRICE;
   if(columnId == "TralStopLoss")
      return COLUMN_TRAL;
   if(columnId == "StopLoss")
      return COLUMN_SL;
   if(columnId == "TakeProfit")
      return COLUMN_TP;
   if(columnId == "CurrentPrice")
      return COLUMN_CURRENT_PRICE;
   if(columnId == "Commission")
      return COLUMN_COMMISSION;
   if(columnId == "Profit")
      return COLUMN_PROFIT;
   if(columnId == "EntryComment")
      return COLUMN_ENTRY_COMMENT;
   if(columnId == "ExitDate")
      return COLUMN_EXIT_DATE;
   if(columnId == "ExitID")
      return COLUMN_EXIT_ORDER_ID;
   if(columnId == "ExitPrice")
      return COLUMN_EXIT_PRICE;
   if(columnId == "ExitComment")
      return COLUMN_EXIT_COMMENT;
   return COLUMN_NDEF;
};

///
/// Проверяет совместимость типа колонки с таблицей для которой она создается.
/// \return Истина, если колонка совместима, и ложь в противном случае.
///
bool XmlLoader::CheckCompatibleType(ENUM_COLUMN_TYPE colType, ENUM_TAB_TYPE tabType)
{
   if(colType == COLUMN_NDEF)
      return false;
   if(tabType == TAB_ACTIVE)
   {
      switch(colType)
      {
         case COLUMN_EXIT_PRICE:
         case COLUMN_EXIT_DATE:
         case COLUMN_EXIT_MAGIC:
         //case COLUMN_EXIT_COMMENT:
         case COLUMN_EXIT_ORDER_ID:
            return false;
         default:
            return true;
      }
   }
   else if(tabType == TAB_HISTORY)
   {
      switch(colType)
      {
         case COLUMN_TRAL:
         case COLUMN_CURRENT_PRICE:
            return false;
         default:
            return true;
      }
   }
   return false;
}


