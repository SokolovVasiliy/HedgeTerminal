#include "XmlBase.mqh"
#include "..\Settings.mqh"
#include "..\Log.mqh"
#include "..\Math.mqh"
#include "FileInfo.mqh"
class Position;
///
/// XML Позиция.
///
class XmlPosition1 : CObject
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
      ///
      /// Устанавливает новое значение тейк-профита 
      ///
      void TakeProfit(double tp){takeProfit = tp;}
      ///
      /// Возвращает уровень стоп-лосса.
      ///
      double StopLoss(){return stopLoss;}
      ///
      /// Устанавливает новое значение стоп-лосса.
      ///
      void StopLoss(double sl){stopLoss = sl;}
      ///
      /// Возвращает исходящий комментарий.
      ///
      string ExitComment(){return strExitComment;}
      ///
      /// Устанавливает новое значение исходящиго комментария.
      ///
      void ExitComment(string comm){strExitComment = comm;}
      ///
      /// Обновляет значения XML позициции из xml узла позиции.
      /// \param xmlItem - Узел xml позиции.
      ///
      void LoadXmlNode(void);
      ///
      /// Удаляет из XML файла соответствующий узел, связанный с текущей xml-позицией.
      /// \return Истина, если узел был найден и успешно удален из файла, ложь в противном случае.
      ///
      bool DeleteXmlNode();
      ///
      /// Синхранизирует данные в xml-узле с текущим состоянием xml-позиции.
      ///
      void RefreshXmlNode();
      ///
      /// Создает XML позицию из xml узла xmlItem.
      /// \param xmlFile - Название xml файла в котором содержится сведенья о xml позиции.
      /// \param xmlItem - xml узел, описывающий xml позицию.
      ///
      XmlPosition1(Position* pos);
      ///
      /// Диструктор.
      ///
      ~XmlPosition1();
      ///
      /// Истина, если xml позиция верно сконфигурированна.
      ///
      bool IsValid(void){return valid;}
      ///
      /// Возвращает текстовое значение xml аттрибута определяющего идентификатор счета.
      ///
      string StringAccountId(void){return strAccountId;}
      ///
      /// Возвращает текстовое значение xml аттрибута определяющего идентификатор позиции.
      ///
      string StringId(void){return strAccountId;}
      ///
      /// Возвращает текстовое значение xml аттрибута определяющего уровень взятия прибыли.
      ///
      string StringTakeProfit(){return strTakeProfit;}
      ///
      /// Сохраняет текстовое значение xml аттрибута определяющего уровень взятия прибыли.
      ///
      void StringTakeProfit(string tp){strTakeProfit = tp;}
      ///
      /// Проверяет обновление файла XML.
      ///
      void CheckModify(void);
      ///
      /// Истина, если значения xml узла, связанного с текущем экзмепляром, были изменены.
      ///
      bool ChangedValues(void);
   private:
      ///
      /// Сохраняет xml-позицию в виде узла в XML файле, обеспечивая ее уникальность.
      ///
      bool SaveToFile();
      ///
      /// Конструктор для внутреннего использования.
      ///
      XmlPosition1(CXmlElement* xmlItem);
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
         const XmlPosition1* xmlPos = node;
         if(xmlPos.Id() < id)
            return -1;
         if(xmlPos.Id() > id)
            return 1;
         return 0;
      }
      ///
      /// Проверяет на корректность составленный xml узел и синхронизирует данные
      /// текущего экземпляра c данными этого xml узла.
      ///
      bool ParsePositionNode(CXmlElement* xmlItem);
      
      ///
      /// Вовзращает название аттрибута в зависимости от его типа.
      /// \param typeAttr - Перечеслитель, определяющий тип аттрибута.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS typeAttr);
      ///
      /// Находит в файле XML узел, связанный с текущей xml-позицией. Если такой узел не был найден, то возвращает NULL.
      /// \return Найденый узел либо NULL в случае неудачи.
      ///
      CXmlElement* FindXmlNode(void);
      ///
      /// Создает новый xml-узел соответствующий текущему экземпляру xml-позиции.
      ///
      CXmlElement* CreateXmlNode(void);

      ///
      /// Читает из XML файла xml-документ и возвращает ссылку на него.
      /// В случае если документ неудалось прочитать возвращает NULL.
      /// \return ссылка на XML документ в случае удачи и NULL в противном случае.
      ///
      CXmlDocument* ReadXmlFile(void);
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
      ///
      /// Строковое значение AccountId.
      ///
      string strAccountId;
      ///
      /// Строковое значение идентификатора позиции.
      ///
      string strId;
      ///
      /// Строковое значение величины тейк-профита.
      ///
      string strTakeProfit;
      ///
      /// Строковое значение закрывающего комментария.
      ///
      string strExitComment;
      ///
      /// Позиция, к которой принадлежит текущее XML представление.
      ///
      Position* position;
      ///
      /// Файл, который необходимо отслеживать.
      ///
      FileInfo* file;
      ///
      /// XML документ, содержащий сведенья о текущем узле.
      ///
      CXmlDocument* doc;
};

XmlPosition1::~XmlPosition1()
{
   if(CheckPointer(file) != POINTER_INVALID)
      delete file;
}

XmlPosition1::XmlPosition1(Position* pos)
{
   accountId = AccountInfoInteger(ACCOUNT_LOGIN);
   id = pos.GetId();
   takeProfit = pos.TakeProfitLevel();
   
   strAccountId = IntegerToString(accountId);
   strId = IntegerToString(id);
   strExitComment = pos.ExitComment();
   strTakeProfit = DoubleToString(takeProfit, 5);
   xmlFile = Settings.GetActivePosXml();
   CXmlElement* xmlItem = FindXmlNode();
   if(xmlItem == NULL)
      valid = SaveToFile();
   else
      valid = ParsePositionNode(xmlItem);
}

XmlPosition1::XmlPosition1(CXmlElement* xmlItem)
{
   strAccountId = "";
   strExitComment = "";
   strId = "";
   strTakeProfit = "";
   valid = ParsePositionNode(xmlItem);
}


CXmlDocument* XmlPosition1::ReadXmlFile(void)
{
   CXmlDocument* doc = new CXmlDocument();
   string err;
   if(!doc.CreateFromFile(xmlFile, err))
   {
      LogWriter("XML file " + xmlFile + " is broked. Check sintax error.", MESSAGE_TYPE_WARNING);
      delete doc;
      return NULL;
   }
   return doc;
}

void XmlPosition1::LoadXmlNode(void)
{
   CXmlElement* xmlItem = FindXmlNode();
   if(xmlItem != NULL)
      ParsePositionNode(xmlItem);
}


string XmlPosition1::GetAttributeName(ENUM_ATTRIBUTE_POS attr)
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


bool XmlPosition1::ParsePositionNode(CXmlElement* xmlItem)
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
      strAccountId = attr.GetValue();
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
      strId = attr.GetValue();
      id = mId;
   }
   //Следущие теги необязательные, и парсинг позиции считается удачным.
   attr = xmlItem.GetAttribute(GetAttributeName(ATTR_EXIT_COMMENT));
   if(attr != NULL)
   {
      string comment = attr.GetValue();
      if(strExitComment != comment)
      {
         strExitComment = comment;
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
         strTakeProfit = attr.GetValue();
         isRefresh = true;
      }
   }
   return true;
}

bool XmlPosition1::SaveToFile(void)
{
   CXmlElement* oldNode;
   do
   {
      oldNode = FindXmlNode();
      if(oldNode != NULL)
         DeleteXmlNode();
   }
   while(oldNode != NULL);
   CXmlDocument* doc = ReadXmlFile();
   doc.FDocumentElement.ChildAdd(CreateXmlNode());
   return doc.SaveToFile(xmlFile);
}

CXmlElement* XmlPosition1::FindXmlNode(void)
{
   string err;
   CXmlDocument* doc = ReadXmlFile();
   if(doc == NULL)return NULL;
   for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
   {
      CXmlElement* xmlItem = doc.FDocumentElement.GetChild(i);
      if(xmlItem.GetName() != "Position")continue;
      XmlPosition1* xmlPos = new XmlPosition1(xmlItem);
      if(!xmlPos.IsValid())
         continue;
      if(xmlPos.AccountId() != accountId ||
         xmlPos.Id() != id)
      {
         delete xmlPos;
         continue;
      }
      delete xmlPos;
      //delete doc;
      return xmlItem;
   }
   //delete doc;
   return NULL;
}

CXmlElement* XmlPosition1::CreateXmlNode(void)
{
   CXmlElement* element = new CXmlElement();
   element.SetName("Position");
   // Идентификатор счета
   CXmlAttribute* attr = new CXmlAttribute();
   attr.SetName(GetAttributeName(ATTR_ACCOUNT_ID));
   attr.SetValue(strAccountId);
   element.AttributeAdd(attr);
   // Идентификатор позиции.
   attr = new CXmlAttribute();
   attr.SetName(GetAttributeName(ATTR_POSITION_ID));
   attr.SetValue(strId);
   element.AttributeAdd(attr);
   // Исходящий комментарий.
   attr = new CXmlAttribute();
   attr.SetName(GetAttributeName(ATTR_EXIT_COMMENT));
   attr.SetValue(strExitComment);
   element.AttributeAdd(attr);
   // Уровень тейк-профита.
   attr = new CXmlAttribute();
   attr.SetName(GetAttributeName(ATTR_TAKE_PROFIT));
   attr.SetValue(strTakeProfit);
   element.AttributeAdd(attr);
   
   return element;
}

bool XmlPosition1::DeleteXmlNode(void)
{
   string err;
   CXmlDocument* doc = ReadXmlFile();
   if(doc == NULL)return false;
   for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
   {
      CXmlElement* xmlItem = doc.FDocumentElement.GetChild(i);
      if(xmlItem.GetName() != "Position")continue;
      XmlPosition* xmlPos = new XmlPosition(Settings.GetActivePosXml(), xmlItem);
      if(xmlPos.AccountId() != accountId ||
         xmlPos.Id() != id)
      {
         delete xmlPos;
         continue;
      }
      delete xmlPos;
      doc.FDocumentElement.ChildDelete(i);
      return doc.SaveToFile(Settings.GetActivePosXml());
   }
   return false;
}

void  XmlPosition1::RefreshXmlNode(void)
{
   
}

bool XmlPosition1::ChangedValues(void)
{
   CXmlElement* xmlItem = FindXmlNode();
   if(xmlItem)return true;
   XmlPosition1* xPos = new XmlPosition1(xmlItem);
   if(!xPos.IsValid())
   {
      DeleteXmlNode();
      SaveToFile();
      return true;
   }
   if(xPos.ExitComment() != strExitComment ||
      Math::DoubleEquals(xPos.TakeProfit(), takeProfit))
      return true;
   return false;
}
void XmlPosition1::CheckModify(void)
{
   if(file.IsModify())
   {
      if(CheckPointer(doc)!= POINTER_INVALID)
         delete doc;
      doc = ReadXmlFile();
      //Отправляем событие об изменении параметров.
   }   
}



