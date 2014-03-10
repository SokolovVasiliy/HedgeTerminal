#include <Arrays\ArrayObj.mqh>
#include "FileInfo.mqh"
#include "..\xml\XmlBase.mqh"
#include "..\Log.mqh"

///
/// XML Позиция.
///
class XmlPosition : CObject
{
   public:
      ///
      /// Возвращает идентификатор позиции.
      ///
      ulong Id(){return id;}
      ///
      /// Возвращает идентификатор счета.
      ///
      ulong AccountId(){return accountId;}
      ///
      /// Возвращает уровень виртуального тейк-профита.
      ///
      double TakeProfit(){return takeProdit;}
      ///
      /// Возвращает уровень стоп-лосса.
      ///
      double StopLoss(){return stopLoss;}
      ///
      /// Возвращает исходящий комментарий.
      ///
      string ExitComment();
   private:
      ///
      /// Идентификатор позиции.
      ///
      ulong id;
      ///
      /// Идентификатор счета.
      ///
      ulong accountId;
      ///
      /// Уровень TakeProfit;
      ///
      double takeProfit;
      ///
      /// Уровень стоп-лосса.
      ///
      double stopLoss;
      ///
      /// Закрывающий комментарий.
      ///
      string exitComment;
};
///
/// Считывает информацию из xml файлов для активных и исторических позиций.
///
class XmlInfo
{
   public:
      void Event(Event* event);
      XmlInfo();
   private:
      ///
      /// Перечеслитель, указывающий на тип xml файла.
      ///
      enum ENUM_XML_TYPE
      {
         ///
         /// Файл, содержащий дополнотиельную информацию об активных позициях.
         ///
         XML_ACTIVE_POS,
         ///
         /// Файл, содержащий дполнительную информацию об исторических позициях.
         ///
         XML_HISTORY_POS
      };
      ///
      /// Атрибуты позиции.
      ///
      enum ENUM_ATTRIBUTE_POS
      {
         ATTR_ACCOUNT_ID,
         ATTR_POSITION_ID
      };
      string GetXmlName(ENUM_XML_TYPE);
      string GetAttributeName(ENUM_ATTRIBUTE_POS attr);
      void CheckXmlChanged();
      void OnModify(string name);
      void ReadActivePosXml();
      void ReadHistoryPosXml();
      bool CheckPositionNode(CXmlElement* xmlItem);
      void RefreshValues(CXmlElement* xmlItem);
      ///
      /// Список XML файлов, который необходимо отслеживать.
      ///
      CArrayObj files;
      
};

void XmlInfo::Event(Event *event)
{
   switch(event.EventId())
   {
      case EVENT_REFRESH:
         CheckXmlChanged();
         break;
   }
}
///
///
///
XmlInfo::XmlInfo()
{
   files.Add(new FileInfo(GetXmlName(XML_ACTIVE_POS), FILE_COMMON, 1));
   //files.Add(new FileInfo("", FILE_COMMON, 5);
}

///
/// Проверяет на изменения файлы
///
void XmlInfo::CheckXmlChanged(void)
{
   for(int i = 0; i < files.Total(); i++)
   {
      FileInfo* file = files.At(i);
      if(file.IsModify())
         OnModify(file.Name());
   }
}
///
/// Вызывается для изменненного файла.
///
void XmlInfo::OnModify(string name)
{
   if(name == GetXmlName(XML_ACTIVE_POS))
      ReadActivePosXml();
   //else if(name == GetXmlName(XML_HISTORY_POS))
      //ReadHistoryPosXml();
      
}
///
/// Вовзращает название файла, в зависимости от типа
///
string XmlInfo::GetXmlName(ENUM_XML_TYPE type)
{
   switch(type)
   {
      case XML_ACTIVE_POS:
         return "ActivePositions.xml";
      case XML_HISTORY_POS:
         return "HistoryPositions.xml";
   }
   return "";
}

///
/// Вовзращает название файла, в зависимости от типа
///
string XmlInfo::GetAttributeName(ENUM_ATTRIBUTE_POS attr)
{
   switch(attr)
   {
      case ATTR_ACCOUNT_ID:
         return "AccountID";
      case ATTR_POSITION_ID:
         return "ID";
   }
   return "";
}

///
/// Читает информацию об активных позициях из файла.
///
void XmlInfo::ReadActivePosXml(void)
{
   CXmlDocument doc;
   string err;
   if(!doc.CreateFromFile(Settings.GetActivePosXml(), err))
   {
      LogWriter("XML file " + Settings.GetActivePosXml() + " is broked. Check sintax error.", MESSAGE_TYPE_WARNING);
      return;
   }
   for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
   {
      CXmlElement* xmlItem = doc.FDocumentElement.GetChild(i);
      if(xmlItem.GetName() == "Position")
      {
         if(!CheckPositionNode(xmlItem))
         {
            LogWriter("Node is broken and will be removed from file.", MESSAGE_TYPE_INFO);
            doc.FDocumentElement.ChildDelete(xmlItem);
            i--;
            continue;
         }
         RefreshValues(xmlItem);
      }
   }
}
///
/// Истина, если xml узел 'Position' составлен верно и ложь в противном случае.
///
bool XmlInfo::CheckPositionNode(CXmlElement* xmlItem)
{
   if(xmlItem.GetName() != "Position")
      return false;
   CXmlAttribute* attr = xmlItem.GetAttribute(GetAttributeName(ATTR_ACCOUNT_ID));
   if(attr == NULL)
   {
      LogWriter("XML attribute \'" + GetAttributeName(ATTR_ACCOUNT_ID) + "\' in position node is missing.", MESSAGE_TYPE_WARNING);
      return false;
   }
   else
   {
      int accountId = (int)StringToInteger(attr.GetValue());
      if(accountId <= 0)
      LogWriter("XML attribute \'" + GetAttributeName(ATTR_ACCOUNT_ID) + "\' has not compatible value.", MESSAGE_TYPE_WARNING);
      return false;
   }
   attr = xmlItem.GetAttribute(GetAttributeName(ATTR_POSITION_ID));
   if(attr == NULL)
   {
      LogWriter("XML attribute \'" + GetAttributeName(ATTR_POSITION_ID) + "\' in position node is missing.", MESSAGE_TYPE_WARNING);
      return false;
   }
   else
   {
      int accountId = (int)StringToInteger(attr.GetValue());
      if(accountId <= 0)
      LogWriter("XML attribute \'" + GetAttributeName(ATTR_POSITION_ID) + "\' has not compatible value.", MESSAGE_TYPE_WARNING);
      return false;
   }
   return true;
}

///
/// Парсит новые значения активной позиции и создает новые события, уведомляющие об изменениях.
///
void XmlInfo::RefreshValues(CXmlElement* xmlItem)
{
   long id = AccountInfoInteger(ACCOUNT_LOGIN);
   CXmlAttribute* attr = xmlItem.GetAttribute(GetAttributeName(ATTR_ACCOUNT_ID));
   long value = StringToInteger(attr.GetValue());
   if(value != id)return;
   
}
