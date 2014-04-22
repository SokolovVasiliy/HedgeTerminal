#include "FileInfo.mqh"
#include "XmlBase.mqh"
#include "..\Log.mqh"
#include "..\Math.mqh"

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
         ATTR_TAKE_PROFIT,
         ///
         /// Аттрибут блокировки позиции.
         ///
         ATTR_BLOCKED
      };
///
/// Тип состояния, которое надо сохранить.
///
enum ENUM_STATE_TYPE
{
   ///
   /// Необходимо удалить запись об активной позиции.
   ///
   STATE_DELETE,
   ///
   /// Необходимо обновить значения аттрибутов.
   ///
   STATE_REFRESH
};
///
/// Содержит значения активной позиции и их xml-представление
///
class XPosValues
{
   public:
      XPosValues(Position* position)
      {
         pos = position;
         accountId = AccountInfoInteger(ACCOUNT_LOGIN);
         posId = pos.GetId();
      }
      ///
      /// 
      ///
      ulong PositionId(){return posId;}
      ///
      /// Возвращает сформированный XML узел.
      ///
      CXmlElement* GetXmlElement()
      {
         CXmlElement* element = new CXmlElement();
         element.SetName("Position");
         //Account.
         CXmlAttribute* attr = new CXmlAttribute();
         attr.SetName(GetAttributeName(ATTR_ACCOUNT_ID));
         attr.SetValue((string)accountId);
         element.AttributeAdd(attr);
         //Position ID
         attr = new CXmlAttribute();
         attr.SetName(GetAttributeName(ATTR_POSITION_ID));
         attr.SetValue((string)posId);
         element.AttributeAdd(attr);
         //Exit comment
         attr = new CXmlAttribute();
         attr.SetName(GetAttributeName(ATTR_EXIT_COMMENT));
         attr.SetValue(pos.ExitComment());
         element.AttributeAdd(attr);
         //TakeProfit
         attr = new CXmlAttribute();
         attr.SetName(GetAttributeName(ATTR_TAKE_PROFIT));
         attr.SetValue(pos.PriceToString(pos.TakeProfitLevel()));
         element.AttributeAdd(attr);
         //Blocked attribute
         if(pos.IsBlocked())
         {
            printf("XML: position #" + (string)pos.GetId() + " is blocked.");
            attr = new CXmlAttribute();
            attr.SetName(GetAttributeName(ATTR_BLOCKED));
            attr.SetValue((string)TimeCurrent());
            element.AttributeAdd(attr);
         }
         else
            printf("XML: blocked will be reset");
         return element;
      }
      ///
      /// Устанавливает состояние объекта согласно xml елементу.
      ///
      bool SetXmlElement(CXmlElement* element)
      {
         if(!IsMyElement(element))return false;
         double tp = 0.0;
         string comment = "";
         datetime time = 0;
         CXmlAttribute* attr = element.GetAttribute(GetAttributeName(ATTR_TAKE_PROFIT));
         if(attr != NULL)
            tp = StringToDouble(attr.GetValue());
         attr = element.GetAttribute(GetAttributeName(ATTR_EXIT_COMMENT));
         if(attr != NULL)
            comment = attr.GetValue();
         attr = element.GetAttribute(GetAttributeName(ATTR_BLOCKED));
         if(attr != NULL)
         {
            string strTime = attr.GetValue();
            time = (datetime)StringToInteger(strTime);
         }
         return pos.AttributesChanged(tp, comment, time);
      }
      ///
      /// Истина, если текущий элемент соответствует текущему экзмемпляру и ложь в противном случае.
      ///
      bool IsMyElement(CXmlElement* element)
      {
         CXmlAttribute* attr = element.GetAttribute(GetAttributeName(ATTR_ACCOUNT_ID));
         if(attr == NULL)return false;
         if(StringToInteger(attr.GetValue()) != accountId)
            return false;
         attr = element.GetAttribute(GetAttributeName(ATTR_POSITION_ID));
         if(attr == NULL)return false;
         if(StringToInteger(attr.GetValue()) != posId)
            return false;
         return true;
      }
      ///
      /// Возвращает название аттрибута в зависимости от его типа.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS attrType)
      {
         switch(attrType)
         {
            case ATTR_ACCOUNT_ID:
               return "AccountID";
            case ATTR_POSITION_ID:
               return "ID";
            case ATTR_EXIT_COMMENT:
               return "ExitComment";
            case ATTR_TAKE_PROFIT:
               return "TakeProfit";
            case ATTR_BLOCKED:
               return "Blocked";
         }
         return "";
      }
   private:
      Position* pos;
      ///
      /// Виртуальный уровень стоп-лосса.
      ///
      //double stopLoss;
      ///
      /// Виртуальный уровень тейк-профита.
      ///
      //double takeProfit;
      ///
      /// Идентификатор счета.
      ///
      ulong accountId;
      ///
      /// Идентификатор позиции.
      ///
      ulong posId;
      ///
      /// Исходящий комментарий.
      ///
      //string exitComment;
};

///
/// Xml представление активной таблицы.
///
class XmlPos2
{
   public:
      ///
      /// Конструктор.
      ///
      XmlPos2(Position* pos);
      ///
      /// Диструктор.
      ///
      ~XmlPos2();
      ///
      /// Проверяет файл на изменения.
      ///
      bool CheckModify();
      ///
      /// Сохраняет текущее состояние.
      ///
      bool SaveState(ENUM_STATE_TYPE type);
   private:
      ///
      /// В случае успеха возвращает указатель на XML-документ, в случае неудачи возвращает NULL
      ///
      bool LoadXmlDoc(int handle);
      ///
      /// Сохраняет текущий загруженный документ в файл.
      ///
      void SaveXmlDoc(int handle);
      ///
      /// Удаляет текущий xml-узел из файла.
      ///
      void DeleteMe(void);
      ///
      /// Создает текущий узел в xml файле.
      ///
      void CreateMe(void);
      ///
      /// Перечитывает текущий xml-узел из файла.
      /// \return Возвращает истину, если узел был изменен и ложь в противном случае.
      /// 
      bool ReadMe(void);
      ///
      /// Истина, если XML-файл содержит текущий xml-узел и ложь в противном случае.
      ///
      bool ContainsMe(void);
      ///
      /// Загруженный Xml-документ.
      ///
      CXmlDocument* doc;
      ///
      ///
      ///
      XPosValues* xPos;
      ///
      /// XML файл, который необходимо отслеживать.
      ///
      FileInfo* file;
      ///
      /// Возвращает имя xml-аттрибута в зависимости от его типа.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS);
      ///
      /// Истина, если последнее состояние позиции было удачно сохраненно и ложь в противном случае.
      ///
      bool saveState;
};

XmlPos2::XmlPos2(Position* pos)
{
   saveState = true;
   xPos = new XPosValues(pos);
   string fileName = Resources.GetFileNameByType(RES_ACTIVE_POS_XML);
   file = new FileInfo(fileName, 0, 1);
   file.SetMode(ACCESS_CHECK_AND_BLOCKED);
}

XmlPos2::~XmlPos2()
{
   delete xPos;
   delete file;
}

bool XmlPos2::LoadXmlDoc(int handle)
{
   if(CheckPointer(doc) == POINTER_INVALID)
      doc = new CXmlDocument();
   else return true;
   string err;
   bool res = doc.ReadDocument(handle, err);
   if(!res)
      delete doc;
   return res;
}

/*bool XmlPos2::LoadXmlDoc(string name)
{
   if(CheckPointer(doc) == POINTER_INVALID)
      doc = new CXmlDocument();
   string err;
   doc.Clear();
   if(!doc.CreateFromFile(name , err))
   {
      delete doc;
      return false;
   }
   return true;
}*/

void XmlPos2::SaveXmlDoc(int handle)
{
   if(CheckPointer(doc) == POINTER_INVALID)return;
   string err = "";
   doc.WriteDocument(handle, err);
   delete doc;
}

bool XmlPos2::CheckModify(void)
{
   ulong id = xPos.PositionId();
   bool res = true;
   int handle = -2;
   if(!file.IsModify())
      return false;
   else if(!LoadXmlDoc(file.GetHandle())) 
      res = false;
   else if(!ContainsMe())
      res = false;
   else
      res = ReadMe();
   if(CheckPointer(doc) != POINTER_INVALID)
      delete doc;
   file.FileClose();
   return res;
}

bool XmlPos2::SaveState(ENUM_STATE_TYPE type = STATE_REFRESH)
{
   bool res = true;
   if(file.FileOpen(FILE_WRITE) == INVALID_HANDLE)
      return false;
   else if(!LoadXmlDoc(file.GetHandle()))
      res = false;
   else
   {
      file.FillSpace();
      DeleteMe();
      if(type == STATE_REFRESH)
         CreateMe();
      SaveXmlDoc(file.GetHandle());
   }
   file.FileClose();
   return res;
}

bool XmlPos2::ContainsMe(void)
{
   if(CheckPointer(doc) == POINTER_INVALID)return false;
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         return true;
   }
   return false;
}

void XmlPos2::CreateMe(void)
{
   if(ContainsMe())
      DeleteMe();
   if(CheckPointer(doc) == POINTER_INVALID)return;
   CXmlElement* element = xPos.GetXmlElement();
   doc.FDocumentElement.ChildAdd(element);
}

void XmlPos2::DeleteMe(void)
{
   if(CheckPointer(doc) == POINTER_INVALID)return;
   int count = doc.FDocumentElement.GetChildCount();
   for(int i = count-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         doc.FDocumentElement.ChildDelete(i);
   }
}

bool XmlPos2::ReadMe()
{
   if(CheckPointer(doc) == POINTER_INVALID)return false;
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         return xPos.SetXmlElement(element);
   }
   return false;
}