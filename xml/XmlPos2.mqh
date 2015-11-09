#include "FileInfo.mqh"
#include <XML\XmlBase.mqh>
#include "..\Log.mqh"
#include "..\Math\Math.mqh"

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
            //printf("XML: position #" + (string)pos.GetId() + " is blocked.");
            attr = new CXmlAttribute();
            attr.SetName(GetAttributeName(ATTR_BLOCKED));
            attr.SetValue((string)TimeCurrent());
            element.AttributeAdd(attr);
         }
         //printf("Create: " + element.GetXml(3));
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
            time = StringToTime(strTime);
         }
         return pos.AttributesChanged(tp, comment, time);
      }
      ///
      /// Истина, если текущий элемент соответствует текущему экзмемпляру и ложь в противном случае.
      ///
      bool IsMyElement(CXmlElement* element)
      {
         if(CheckPointer(element) == POINTER_INVALID)
            return false;
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
      /// Истина, если переданный элемент принадлежит текущей позиции, но его параметры
      /// отличаются от нее.
      ///
      bool DetectModify(CXmlElement* element)
      {
         if(!IsMyElement(element))
            return false;
         CXmlAttribute* attr = element.GetAttribute(GetAttributeName(ATTR_TAKE_PROFIT));
         if(DiffTP(attr))return true;
         if(!pos.UsingStopLoss())
         {
            attr = element.GetAttribute(GetAttributeName(ATTR_EXIT_COMMENT));
            if(DiffComment(attr))return true;
         }
         attr = element.GetAttribute(GetAttributeName(ATTR_BLOCKED));
         if(DiffBlock(attr))return true;
         return false;
      }
      ///
      /// Истина, если аттрибут тейкпрофита различается от тейк-профит позиции.
      ///
      bool DiffTP(CXmlAttribute* attr)
      {
         if(attr == NULL)return true;
         double tp = StringToDouble(attr.GetValue());
         if(Math::DoubleEquals(pos.TakeProfitLevel(), tp))
            return false;
         return true;
      }
      ///
      /// Истина, если аттрибут исходящего комментария различается от исходящего комментария позиции.
      ///
      bool DiffComment(CXmlAttribute* attr)
      {
         if(attr == NULL)return true;
         if(pos.ExitComment() == attr.GetValue())
            return false;
         return true;
      }
      ///
      /// Истина, статус блокировки указанный в аттрибуте, отличается от статуса блокировки позиции.
      ///
      bool DiffBlock(CXmlAttribute* attr)
      {
         if(attr == NULL && !pos.IsBlocked())return false;
         if(attr != NULL && pos.IsBlocked())return false;
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
      ///
      /// Текстовое значение предыдущего узла.
      ///
      string prevText;
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
      /// Проверяет файл на изменения (новая версия CheckModify).
      ///
      bool LoadState();
      ///
      /// Сохраняет текущее состояние.
      ///
      bool SaveState(ENUM_STATE_TYPE type);
      bool SaveState2(ENUM_STATE_TYPE type);
   private:
      ///
      /// Истина, если документ был загружен, ложь если загрузка неудалась.
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
      /// Истина, если загруженный xml документ отличается от старого.
      ///
      bool DetectModify(void);
      ///
      /// Меняет содержимое открытого файла на пробелы.
      ///
      void FillSpace(int handle);
      ///
      /// Пытается открыть файл. В случае успеха возвращает файловый дискриптор не него, в 
      /// случае неудачу константу INVALID_HANDLE.
      /// \param flags - Набор флагов, устанавливающих режимы открытия файла.
      ///
      int TryOpenFile(int flags);
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
      //FileInfo* file;
      ///
      /// Возвращает имя xml-аттрибута в зависимости от его типа.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS);
      ///
      /// Истина, если последнее состояние позиции было удачно сохраненно и ложь в противном случае.
      ///
      bool saveState;
      ///
      /// Имя XML файла активных позиций.
      ///
      string fileName;
      ///
      /// Версия последнего известного XML документа.
      ///
      string prevDoc;
      ///
      /// Указатель на текущий xml-елемент, соответствующий позиции (инициализируется LoadXmlDoc).
      ///
      CXmlElement* currElement;
};

XmlPos2::XmlPos2(Position* pos)
{
   saveState = true;
   xPos = new XPosValues(pos);
   fileName = Resources.GetFileNameByType(RES_ACTIVE_POS_XML);
   prevDoc = "";
   //file = new FileInfo(fileName, 0, 1);
   //file.SetMode(ACCESS_CHECK_AND_BLOCKED);
}

XmlPos2::~XmlPos2()
{
   delete xPos;
   //delete file;
}

bool XmlPos2::LoadXmlDoc(int handle)
{
   if(CheckPointer(doc) == POINTER_INVALID)
      doc = new CXmlDocument();
   else return true;
   string err;
   bool res = doc.ReadDocument(handle, err);
   if(!res)
   {
      delete doc;
      return res;
   }
   //Ищим текущий xml-елемент, соответствующий позиции.
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         currElement = element;
   }
   return res;
}

void XmlPos2::SaveXmlDoc(int handle)
{
   if(CheckPointer(doc) == POINTER_INVALID)return;
   string err = "";
   doc.WriteDocument(handle, err);
   delete doc;
}

int XmlPos2::TryOpenFile(int flags)
{
   int handle = INVALID_HANDLE;
   //Количество попыток открытия файла.
   int attempts = 30;
   for(int i = 0; i < attempts; i++)
   {
      handle = FileOpen(fileName, flags|Resources.FileCommon());
      //if(handle != INVALID_HANDLE)
      //   break;
      //Устанавливаем генератор в уникальное значение для текущего экземпляра.
      //uint chartHandle = (int)ChartGetInteger(0, CHART_WINDOW_HANDLE);
      //srand(chartHandle);
      //Задержка от 10 до 100 мсек каждую попытку.
      //int msec = 10 + (rand()%90); 
      //int msec = 2;
      //Sleep(msec);
   }
   return handle;
}

bool XmlPos2::LoadState()
{
   bool res = false;
   int handle = TryOpenFile(FILE_BIN|FILE_READ);
   if(handle == INVALID_HANDLE || !LoadXmlDoc(handle))
      res = false;
   else
      FileClose(handle);
   if(!xPos.DetectModify(currElement))
      res = false;
   else
   {
      //printf("Load: Changes detected");
      res = ReadMe();
   }
   if(CheckPointer(doc) != POINTER_INVALID)
      delete doc;
   return res;
}

/*bool XmlPos2::SaveState2(ENUM_STATE_TYPE type = STATE_REFRESH)
{
   bool res = true;
   if(file.FileOpen(FILE_WRITE) == INVALID_HANDLE)
      return false;
   else if(!LoadXmlDoc(file.GetHandle()))
      res = false;
   else
   {
      //printf("I save new XML state" + (string)xPos.PositionId());
      file.FillSpace();
      DeleteMe();
      if(type == STATE_REFRESH)
         CreateMe();
      SaveXmlDoc(file.GetHandle());
   }
   file.FileClose();
   return res;
}*/

bool XmlPos2::SaveState(ENUM_STATE_TYPE type = STATE_REFRESH)
{
   int handle = TryOpenFile(FILE_BIN|FILE_READ|FILE_WRITE);
   bool res = false;
   if(handle != INVALID_HANDLE && LoadXmlDoc(handle))
   {
      FillSpace(handle);
      DeleteMe();
      if(type == STATE_REFRESH)
         CreateMe();
      SaveXmlDoc(handle);
      res = true;
   }
   if(handle != INVALID_HANDLE)
      FileClose(handle);
   return res;
}

void XmlPos2::FillSpace(int handle)
{
   int size = (int)FileSize(handle);
   uchar spaces[];
   ArrayResize(spaces, size);
   uchar ch = ' '; 
   ArrayInitialize(spaces, ch);
   FileSeek(handle, 0, SEEK_SET);
   FileWriteArray(handle, spaces, 0, ArraySize(spaces));
}

bool XmlPos2::ContainsMe(void)
{
   if(CheckPointer(currElement) != POINTER_INVALID)
      return true;
   return false;
   /*if(CheckPointer(doc) == POINTER_INVALID)return false;
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         return true;
   }
   return false;*/
}

void XmlPos2::CreateMe(void)
{
   if(CheckPointer(doc) == POINTER_INVALID)return;
   if(ContainsMe())
      DeleteMe();
   CXmlElement* element = xPos.GetXmlElement();
   doc.FDocumentElement.ChildAdd(element);
}

void XmlPos2::DeleteMe(void)
{
   if(!ContainsMe())return;
   doc.FDocumentElement.ChildDelete(currElement);
   /*int count = doc.FDocumentElement.GetChildCount();
   for(int i = count-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         doc.FDocumentElement.ChildDelete(i);
   }*/
}

bool XmlPos2::ReadMe()
{
   if(ContainsMe())
      return xPos.SetXmlElement(currElement);
   return false;
   /*if(CheckPointer(doc) == POINTER_INVALID)return false;
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         return xPos.SetXmlElement(element);
   }
   return false;*/
}