#include "FileInfo.mqh"
#include <XML\XmlBase.mqh>
#include "..\Log.mqh"
#include "..\Math\Math.mqh"

///
/// �������� �������.
///
enum ENUM_ATTRIBUTE_POS
{
         ///
         /// ������������� �����, � �������� ����������� �������.
         ///
         ATTR_ACCOUNT_ID,
         ///
         /// ������������� �������.
         ///
         ATTR_POSITION_ID,
         ///
         /// ����������� �����������.
         ///
         ATTR_EXIT_COMMENT,
         ///
         /// ������� ������������ ����-�������.
         ///
         ATTR_TAKE_PROFIT,
         ///
         /// �������� ���������� �������.
         ///
         ATTR_BLOCKED
      };
///
/// ��� ���������, ������� ���� ���������.
///
enum ENUM_STATE_TYPE
{
   ///
   /// ���������� ������� ������ �� �������� �������.
   ///
   STATE_DELETE,
   ///
   /// ���������� �������� �������� ����������.
   ///
   STATE_REFRESH
};
///
/// �������� �������� �������� ������� � �� xml-�������������
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
      /// ���������� �������������� XML ����.
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
      /// ������������� ��������� ������� �������� xml ��������.
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
      /// ������, ���� ������� ������� ������������� �������� ����������� � ���� � ��������� ������.
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
      /// ������, ���� ���������� ������� ����������� ������� �������, �� ��� ���������
      /// ���������� �� ���.
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
      /// ������, ���� �������� ����������� ����������� �� ����-������ �������.
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
      /// ������, ���� �������� ���������� ����������� ����������� �� ���������� ����������� �������.
      ///
      bool DiffComment(CXmlAttribute* attr)
      {
         if(attr == NULL)return true;
         if(pos.ExitComment() == attr.GetValue())
            return false;
         return true;
      }
      ///
      /// ������, ������ ���������� ��������� � ���������, ���������� �� ������� ���������� �������.
      ///
      bool DiffBlock(CXmlAttribute* attr)
      {
         if(attr == NULL && !pos.IsBlocked())return false;
         if(attr != NULL && pos.IsBlocked())return false;
         return true;
      }
      ///
      /// ���������� �������� ��������� � ����������� �� ��� ����.
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
      /// ����������� ������� ����-�����.
      ///
      //double stopLoss;
      ///
      /// ����������� ������� ����-�������.
      ///
      //double takeProfit;
      ///
      /// ������������� �����.
      ///
      ulong accountId;
      ///
      /// ������������� �������.
      ///
      ulong posId;
      ///
      /// ��������� �����������.
      ///
      //string exitComment;
      ///
      /// ��������� �������� ����������� ����.
      ///
      string prevText;
};

///
/// Xml ������������� �������� �������.
///
class XmlPos2
{
   public:
      ///
      /// �����������.
      ///
      XmlPos2(Position* pos);
      ///
      /// ����������.
      ///
      ~XmlPos2();
      ///
      /// ��������� ���� �� ��������� (����� ������ CheckModify).
      ///
      bool LoadState();
      ///
      /// ��������� ������� ���������.
      ///
      bool SaveState(ENUM_STATE_TYPE type);
      bool SaveState2(ENUM_STATE_TYPE type);
   private:
      ///
      /// ������, ���� �������� ��� ��������, ���� ���� �������� ���������.
      ///
      bool LoadXmlDoc(int handle);
      ///
      /// ��������� ������� ����������� �������� � ����.
      ///
      void SaveXmlDoc(int handle);
      ///
      /// ������� ������� xml-���� �� �����.
      ///
      void DeleteMe(void);
      ///
      /// ������� ������� ���� � xml �����.
      ///
      void CreateMe(void);
      ///
      /// ������������ ������� xml-���� �� �����.
      /// \return ���������� ������, ���� ���� ��� ������� � ���� � ��������� ������.
      /// 
      bool ReadMe(void);
      ///
      /// ������, ���� XML-���� �������� ������� xml-���� � ���� � ��������� ������.
      ///
      bool ContainsMe(void);
      ///
      /// ������, ���� ����������� xml �������� ���������� �� �������.
      ///
      bool DetectModify(void);
      ///
      /// ������ ���������� ��������� ����� �� �������.
      ///
      void FillSpace(int handle);
      ///
      /// �������� ������� ����. � ������ ������ ���������� �������� ���������� �� ����, � 
      /// ������ ������� ��������� INVALID_HANDLE.
      /// \param flags - ����� ������, ��������������� ������ �������� �����.
      ///
      int TryOpenFile(int flags);
      ///
      /// ����������� Xml-��������.
      ///
      CXmlDocument* doc;
      ///
      ///
      ///
      XPosValues* xPos;
      ///
      /// XML ����, ������� ���������� �����������.
      ///
      //FileInfo* file;
      ///
      /// ���������� ��� xml-��������� � ����������� �� ��� ����.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS);
      ///
      /// ������, ���� ��������� ��������� ������� ���� ������ ���������� � ���� � ��������� ������.
      ///
      bool saveState;
      ///
      /// ��� XML ����� �������� �������.
      ///
      string fileName;
      ///
      /// ������ ���������� ���������� XML ���������.
      ///
      string prevDoc;
      ///
      /// ��������� �� ������� xml-�������, ��������������� ������� (���������������� LoadXmlDoc).
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
   //���� ������� xml-�������, ��������������� �������.
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
   //���������� ������� �������� �����.
   int attempts = 30;
   for(int i = 0; i < attempts; i++)
   {
      handle = FileOpen(fileName, flags|Resources.FileCommon());
      //if(handle != INVALID_HANDLE)
      //   break;
      //������������� ��������� � ���������� �������� ��� �������� ����������.
      //uint chartHandle = (int)ChartGetInteger(0, CHART_WINDOW_HANDLE);
      //srand(chartHandle);
      //�������� �� 10 �� 100 ���� ������ �������.
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