#include "XmlBase.mqh"
#include "FileInfo.mqh"
#include "..\Log.mqh"
#include "..\Math.mqh"
#include "..\events.mqh"
class Position;
///
/// Xml-позиция.
///
class XmlPos
{
   public:
      ///
      /// Возвращает идентификатор счета, к которому принадлежит позиция.
      ///
      ulong AccountId(){return accountId;}
      ///
      /// Возвращает идентификатор позиции.
      ///
      ulong Id(){return id;}
      
      ///
      /// Возвращает уровень виртуального тейк-профита.
      ///
      double TakeProfit(){return takeProfit;}
      ///
      /// Устанавливает новое значение тейк-профита 
      ///
      void TakeProfit(double tp);
      
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
      void ExitComment(string comm);
      ///
      /// Конструктор.
      ///
      XmlPos(Position* pos);
      ///
      /// Создает новый экземпляр XmlPos на основе xml елемента.
      ///
      XmlPos(CXmlElement* xEl);
      ///
      /// Диструктор.
      ///
      ~XmlPos();
      ///
      /// Проверяет XML файл на обновление.
      ///
      void CheckModify(void);
      ///
      /// Истина, если текущая xml позиция содержит все необходимые данные.
      ///
      bool IsValid(void);
      ///
      /// Удаляет xml узел, лежащий в основе xml позиции.
      ///
      void DeleteXmlNode();
   private:
      
      ///
      /// Находит в 'doc' XML узел, связанный с текущей xml-позицией и возвращает указатель на него.
      /// Если узел не был найден возвращает NULL.
      ///
      CXmlElement* FindXmlNode(void);
      ///
      /// Перезагружает XML документ.
      ///
      void ReloadXmlDoc(void);
      ///
      /// Истина, если xml узел, лежащий в основе xml-позиции соответствует текущей xml позиции.
      ///
      bool IsSynchNode(void);
      ///
      /// Создает xml-узел, соответствующий текущей позиции.
      ///
      CXmlElement* CreateXmlNode();
      
      ///
      /// Изменяет xml-узел в соответствии с данными текущей xml-позиции.
      /// \return Истина, если изменение узла прошло успешно и ложь в противном случае.
      ///
      void LazyWriter(void);
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
      ///
      /// Задает новое значение аттрибута.
      /// \param attrType - Тип аттрибута, чье значение нужно изменить.
      /// \param value - Новое значение аттрибута.
      ///
      void ChangeAttribute(ENUM_ATTRIBUTE_POS attrType, string value);
      ///
      /// Вовзращает название аттрибута в зависимости от его типа.
      /// \param typeAttr - Перечеслитель, определяющий тип аттрибута.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS typeAttr);
      ///
      /// Проверяет на корректность составленный xml узел и синхронизирует данные
      /// текущего экземпляра c данными этого xml узла.
      ///
      bool ParsePositionNode(void);
      ///
      /// XML файл, который необходимо отслеживать.
      ///
      FileInfo* file;
      ///
      /// Истина, если содержимое XML файла соответствует
      //  загруженному документу 'doc' и ложь в противном случае.
      ///
      bool synchronize;
      ///
      /// Загруженный XML документ.
      ///
      CXmlDocument doc;
      ///
      /// Тестовый указатель на XML документ. 
      ///
      CXmlDocument tempDoc;
      ///
      /// Название xml файла, который требуется открыть.
      ///
      string xmlFile;
      ///
      /// Истина, если последняя операция по открытию файла прошла не удачно и ложь
      /// в противном случае.
      ///
      bool failedOpen;
      ///
      /// Указатель, на один из узлов 'doc', который соответствует текущей xml позиции.
      ///
      CXmlElement* xmlItem;
      ///
      /// Идентификатор счета, к которому принадлежит позиция.
      ///
      ulong accountId;
      ///
      /// Идентификатор позиции.
      ///
      ulong id;
      ///
      /// Уровень TakeProfit;
      ///
      double takeProfit;
      ///
      /// Уровень стоп-лосса.
      ///
      double stopLoss;
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
      /// Истина, если состояние xml-позиции было измененно и требуется обновить
      /// лежащий в ее основе xml-узел.
      ///
      bool isChanged;
      ///
      /// Счетчик попыток отложенной записи.
      ///
      int lazyCount;
};

XmlPos::XmlPos(Position* pos)
{
   //POSITION_STATUS st = pos.Status();
   xmlFile = Settings.GetActivePosXml();
   file = new FileInfo(xmlFile, FILE_COMMON, 1);
   position = pos;
   accountId = AccountInfoInteger(ACCOUNT_LOGIN);
   id = pos.GetId();
   strAccountId = IntegerToString(accountId);
   strId = IntegerToString(id);
   strExitComment = pos.ExitComment();
   if(strExitComment == NULL)strExitComment = "";
   takeProfit = pos.TakeProfitLevel();
   CheckModify();
}

XmlPos::~XmlPos()
{
   if(CheckPointer(file) != POINTER_INVALID)
      delete file;
}

XmlPos::XmlPos(CXmlElement *xEl)
{
   xmlItem = xEl;
   ParsePositionNode();
}

void XmlPos::CheckModify(void)
{
   if(file.IsModify())
      synchronize = false;
   if(!synchronize)
      ReloadXmlDoc();
   LazyWriter();
}

void XmlPos::ReloadXmlDoc(void)
{
   string error;
   //doc.Clear();
   //tempDoc.CopyTo(doc);
   bool res = tempDoc.CreateFromFile(xmlFile, error);
   if(!res && !failedOpen)
   {
      LogWriter("Failed read XML file. LastError:" + (string)GetLastError(), MESSAGE_TYPE_WARNING);
      xmlItem = NULL;
      failedOpen = true;
   }
   if(res)
   {
      doc.Clear();
      tempDoc.CopyTo(doc);
      synchronize = true;
      failedOpen = false;
      if(!IsSynchNode())
      {
         XmlPos* xPos = new XmlPos(xmlItem);
         strExitComment = xPos.ExitComment();
         takeProfit = xPos.TakeProfit();
         delete xPos;
         EventXmlActPosRefresh* event = new EventXmlActPosRefresh(GetPointer(this));
         position.Event(event);
         delete event;
      }
   }
}

CXmlElement* XmlPos::FindXmlNode(void)
{
   XmlPos* xmlPos = NULL;
   for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
   {
      xmlItem = doc.FDocumentElement.GetChild(i);
      if(xmlItem.GetName() != "Position")continue;
      if(CheckPointer(xmlPos) != POINTER_INVALID)
         delete xmlPos;
      xmlPos = new XmlPos(xmlItem);
      if(!xmlPos.IsValid())
         continue;
      if(xmlPos.AccountId() != accountId ||
         xmlPos.Id() != id)   
         continue;
      delete xmlPos;
      return xmlItem;  
   }
   if(CheckPointer(xmlPos) != POINTER_INVALID)
      delete xmlPos;
   return NULL;
}

bool XmlPos::IsSynchNode(void)
{
   if(CheckPointer(xmlItem) == POINTER_INVALID)
   {
      xmlItem = FindXmlNode();
      if(xmlItem == NULL)
      {
         //ReloadXmlDoc();
         xmlItem = CreateXmlNode();
         doc.FDocumentElement.ChildAdd(xmlItem);
         doc.SaveToFile(xmlFile);
         ReloadXmlDoc();
      }
   }
   XmlPos* xPos = new XmlPos(xmlItem);
   bool notEquals = xPos.ExitComment() != strExitComment || !Math::DoubleEquals(xPos.TakeProfit(), takeProfit);
   delete xPos;
   return !notEquals;
}

bool XmlPos::IsValid(void)
{
   if(accountId <= 0 || id <= 0)
      return false;
   return true;
}

CXmlElement* XmlPos::CreateXmlNode(void)
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

string XmlPos::GetAttributeName(ENUM_ATTRIBUTE_POS attr)
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

bool XmlPos::ParsePositionNode(void)
{
   if(CheckPointer(xmlItem) == POINTER_INVALID)
      return false;
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
      }
   }
   return true;
}

void XmlPos::DeleteXmlNode(void)
{
   if(CheckPointer(xmlItem))
   {
      //ReloadXmlDoc();
      doc.FDocumentElement.ChildDelete(xmlItem);
      doc.SaveToFile(xmlFile);
      ReloadXmlDoc();
   }
}

void XmlPos::TakeProfit(double tp)
{
   takeProfit = tp;
   string stp = position.PriceToString(tp);
   if(strTakeProfit != stp)
   {
      strTakeProfit = stp;
      ChangeAttribute(ATTR_TAKE_PROFIT, strTakeProfit);
   }
}

void XmlPos::ExitComment(string comm)
{
   if(strExitComment == comm)return;
   strExitComment = comm;
   ChangeAttribute(ATTR_EXIT_COMMENT, strExitComment);
}

void XmlPos::LazyWriter(void)
{
   if(isChanged && lazyCount++%5 == 0)
   {
      //ReloadXmlDoc();
      isChanged = !doc.SaveToFile(xmlFile);
      ReloadXmlDoc();
      //if(isChanged == false)
   }
}

void XmlPos::ChangeAttribute(ENUM_ATTRIBUTE_POS attrType, string value)
{
   if(CheckPointer(xmlItem) == POINTER_INVALID)
      return;
   string attrName = GetAttributeName(attrType);
   CXmlAttribute* attr = xmlItem.GetAttribute(attrName);
   attr.SetValue(value);
   isChanged = true;
}

