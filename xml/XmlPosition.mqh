#include "XmlBase.mqh"
#include "..\Log.mqh"
#include "..\Math.mqh"
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
      double TakeProfit(){return takeProfit;}
      void TakeProfit(double tp){takeProfit = tp;}
      ///
      /// Возвращает уровень стоп-лосса.
      ///
      double StopLoss(){return stopLoss;}
      ///
      /// Возвращает исходящий комментарий.
      ///
      string ExitComment(){return exitComment;}
      ///
      /// Обновляет значения XML позициции из xml узла позиции.
      /// \param xmlItem - Узел xml позиции.
      ///
      void RefreshValues(CXmlElement* xmlItem);
      ///
      /// Создает XML позицию из xml узла xmlItem.
      /// \param xmlFile - Название xml файла в котором содержится сведенья о xml позиции.
      /// \param xmlItem - xml узел, описывающий xml позицию.
      ///
      XmlPosition(string xmlFile, CXmlElement* xmlItem);
      ///
      /// Истина, если xml позиция верно сконфигурированна.
      ///
      bool IsValid(void){return valid;}
      ///
      /// Истина, если значения xml позиции были изменены.
      ///
      bool IsRefresh(void){return isRefresh;}
      ///
      /// Сбрасывает флаг изменений в позиции.
      ///
      void ResetRefresh(void){isRefresh = false;}
      void SyncronizeXml(void);
   private:
      ///
      /// Атрибуты позиции.
      ///
      enum ENUM_ATTRIBUTE_POS
      {
         ///
         /// Идентификатор счета, к которому принадлежит позиция.
         ///
         ATTR_ACCOUNT_ID,
         ///
         /// Идентификатор позиции.
         ///
         ATTR_POSITION_ID,
         ///
         /// Закрывающий комментарий.
         ///
         ATTR_EXIT_COMMENT,
         ///
         /// Уровень виртуального тейк-профита.
         ///
         ATTR_TAKE_PROFIT
      };
      virtual int Compare(const CObject *node,const int mode=0) const
      {
         const XmlPosition* xmlPos = node;
         if(xmlPos.Id() < id)
            return -1;
         if(xmlPos.Id() > id)
            return 1;
         return 0;
      }
      bool ParsePositionNode(CXmlElement* xmlItem);
      void ParseParams(CXmlElement* xmlItem);
      string GetAttributeName(ENUM_ATTRIBUTE_POS attr);
      
      void SyncronizeXmlAttr(CXmlElement* xmlItem);
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
      ///
      /// Истина, если xml позиция верно сконфигурирована.
      ///
      bool valid;
      ///
      /// Флаг, указывающий, что значения xml позиции были изменены.
      ///
      bool isRefresh;
      ///
      /// Название XML файла, в котором содержится xml узел, описывающий данную позицию.
      ///
      string xmlFile;
};

///
/// Для создания xml позиции требуется узел xml содержащий информацию о позиции.
///
XmlPosition::XmlPosition(string xml_file, CXmlElement *xmlItem)
{
   valid = ParsePositionNode(xmlItem);
   xmlFile = xml_file;
}
///
/// Обновляет значения у существующей xml позиции.
///
void XmlPosition::RefreshValues(CXmlElement* xmlItem)
{
   ParsePositionNode(xmlItem);
}

///
/// Вовзращает название файла, в зависимости от типа
///
string XmlPosition::GetAttributeName(ENUM_ATTRIBUTE_POS attr)
{
   switch(attr)
   {
      case ATTR_ACCOUNT_ID:
         return "AccountID";
      case ATTR_POSITION_ID:
         return "ID";
      case ATTR_EXIT_COMMENT:
         return "ExitComment";
      case ATTR_TAKE_PROFIT:
         return "TakeProfit";
   }
   return "";
}

///
/// Проверяет на корректность составленный xml узел.
///
bool XmlPosition::ParsePositionNode(CXmlElement* xmlItem)
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
      int accId = (int)StringToInteger(attr.GetValue());
      if(accId <= 0 ||(accId != accountId && accountId > 0))
      {
         LogWriter("XML attribute \'" + GetAttributeName(ATTR_ACCOUNT_ID) + "\' has not compatible value.", MESSAGE_TYPE_WARNING);
         return false;
      }
      accountId = accId;
   }
   attr = xmlItem.GetAttribute(GetAttributeName(ATTR_POSITION_ID));
   if(attr == NULL)
   {
      LogWriter("XML attribute \'" + GetAttributeName(ATTR_POSITION_ID) + "\' in position node is missing.", MESSAGE_TYPE_WARNING);
      return false;
   }
   else
   {
      int mId = (int)StringToInteger(attr.GetValue());
      if(mId <= 0 || (mId != id && id > 0))
      {
         LogWriter("XML attribute \'" + GetAttributeName(ATTR_POSITION_ID) + "\' has not compatible value.", MESSAGE_TYPE_WARNING);
         return false;
      }
      id = mId;
   }
   //Следущие теги необязательные, и парсинг позиции считается удачным.
   attr = xmlItem.GetAttribute(GetAttributeName(ATTR_EXIT_COMMENT));
   if(attr != NULL)
   {
      string comment = attr.GetValue();
      if(exitComment != comment)
      {
         exitComment = comment;
         isRefresh = true;
      }
   }
   attr = xmlItem.GetAttribute(GetAttributeName(ATTR_TAKE_PROFIT));
   if(attr != NULL)
   {
      double level = StringToDouble(attr.GetValue());
      if(!Math::DoubleEquals(level, takeProfit) && level > 0.0)
      {
         takeProfit = level;
         isRefresh = true;
      }
   }
   return true;
}
///
/// Синхранизирует узел xml описывающий позицию с текущей позицией.
///
void XmlPosition::SyncronizeXml(void)
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
      if(xmlItem.GetName() != "Position")continue;
      XmlPosition* xmlPos = new XmlPosition(Settings.GetActivePosXml(), xmlItem);
      if(xmlPos.AccountId() != accountId ||
         xmlPos.Id() != id)
         return;
      delete xmlPos;
      SyncronizeXmlAttr(xmlItem);
   }
   if(!doc.SaveToFile(Settings.GetActivePosXml()))
   {
      LogWriter("Save changes failed. Error: " + (string)GetLastError(), MESSAGE_TYPE_WARNING);
   }
}
///
/// Синхранизирует xml аттрибуты узла с текущем состоянием xml позиции.
///
void XmlPosition::SyncronizeXmlAttr(CXmlElement* xmlItem)
{
   if(exitComment != NULL && exitComment != "")
   {
      //Изменяем комментарий.
      CXmlAttribute* attr = xmlItem.GetAttribute(GetAttributeName(ATTR_EXIT_COMMENT));
      if(attr == NULL)
      {
         CXmlAttribute* comm = new CXmlAttribute();
         comm.SetName(GetAttributeName(ATTR_EXIT_COMMENT));
         comm.SetValue(exitComment);
         xmlItem.AttributeAdd(comm);
      }
      else
      {
         if(exitComment != attr.GetValue())
            attr.SetValue(exitComment);
      }
      attr = xmlItem.GetAttribute(GetAttributeName(ATTR_TAKE_PROFIT));
      if(attr == NULL)
      {
         CXmlAttribute* profit = new CXmlAttribute();
         string value = DoubleToString(takeProfit, 4);
         profit.SetName(GetAttributeName(ATTR_TAKE_PROFIT));
         profit.SetValue(value);
         xmlItem.AttributeAdd(profit);
      }
      else
      {
         string value = DoubleToString(takeProfit, 4);
         if(value != attr.GetValue())
            attr.SetValue(value);
      }
   }
}

