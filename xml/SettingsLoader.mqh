#include <Arrays\ArrayObj.mqh>
#include "XmlBase.mqh"
#include "..\Log.mqh"
#include "..\Settings.mqh"
///
/// ��������� ��������� �� XML �����.
///
class XmlLoader
{
   public:
      XmlLoader();
      CArrayObj* GetActiveColumns(){return GetPointer(activeTab);}
      CArrayObj* GetHistoryColumns(){return GetPointer(historyTab);}
   private:
      ///
      /// ��������� ������ ��������.
      ///
      enum ENUM_SET_SECTIONS
      {
         ///
         /// ������ ���������� ������� � �� ������.
         ///
         SET_COLUMNS_SHOW,
         ///
         /// �������������� ������ ��������.
         ///
         SET_NOTDEF
      };
      ///
      /// ���������� ��� �������, ��� ������� ����� ��������� ������ �������.
      ///
      enum ENUM_TAB_TYPE
      {
         ///
         /// ������� �������� �������
         ///
         TAB_ACTIVE,
         ///
         /// ������� ������������ �������.
         ///
         TAB_HISTORY
      };
      ///
      /// ������ ������� ��� �������� �������.
      ///
      CArrayObj activeTab;
      ///
      /// ������ ������� ��� ������������ �������.
      ///
      CArrayObj historyTab;
      
      ENUM_SET_SECTIONS GetTypeSection(string nameNode);
      void ParseColumnsSettings(CXmlElement* xmlItem);
      void ParseColumns(CXmlElement* activeTab, ENUM_TAB_TYPE tabType);
      void ParseColumn(CXmlElement* activeTab, ENUM_TAB_TYPE tabType);
      ENUM_COLUMN_TYPE GetColumnType(string columnId);
      bool CheckCompatibleType(ENUM_COLUMN_TYPE, ENUM_TAB_TYPE tabType);
      bool CheckValidColumn(CXmlElement* xmlColumn);
};

///
/// ��������� ��������� �� ����� �������������.
/// \param path - ���� � �����.
///
XmlLoader::XmlLoader()
{
   CXmlDocument doc;
   string err;
   string path = "test.xml";
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
      }
      printf(xmlItem.GetName());
   }
   
}

///
/// ���������� ������������� ������ ��������, �������� ������������� �������� ����.
///
ENUM_SET_SECTIONS XmlLoader::GetTypeSection(string nameNode)
{
   if(nameNode == "Show-Columns")
      return SET_COLUMNS_SHOW;
   return SET_NOTDEF;
}

///
/// ��������� ������ ��������� �������.
/// \param xmlItem - ������ �������� ������� Show-Columns
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
/// ������ ������ ������� ��� ������������� ���� ����
/// \param tabType - ��� ����, ��� �������� ����� ��������� �������.
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
         LogWriter("Column /'" + columnId.GetName() + "/' not compatible for table.", MESSAGE_TYPE_WARNING);
         continue;
      }
      ParseColumn(xmlColumn, tabType);
   }
}

///
/// ������ ���������� xml ������� � ��������� �� � DefColumn.
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
/// ��������� �� ������������ ���� Column.
/// \return ������, ���� ���� column ��������� ��������� � ���� � ��������� ������.
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
/// ���������� ��� �������, � ����������� �� �� ��������������
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
/// ��������� ������������� ���� ������� � �������� ��� ������� ��� ���������.
/// \return ������, ���� ������� ����������, � ���� � ��������� ������.
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
         case COLUMN_EXIT_COMMENT:
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
