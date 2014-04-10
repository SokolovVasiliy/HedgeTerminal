#include "FileInfo.mqh"
#include "XmlBase.mqh"
#include "..\Log.mqh"
#include "..\Math.mqh"

///
/// �������� �������.
///
/*enum ENUM_ATTRIBUTE_POS
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
   ATTR_TAKE_PROFIT
};*/

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
         
         return element;
      }
      ///
      /// ������������� ��������� ������� �������� xml ��������.
      ///
      void SetXmlElement(CXmlElement* element)
      {
         if(!IsMyElement(element))return;
         double tp = 0.0;
         string comment = "";
         CXmlAttribute* attr = element.GetAttribute(GetAttributeName(ATTR_TAKE_PROFIT));
         if(attr != NULL)
            tp = StringToDouble(attr.GetValue());
         attr = element.GetAttribute(GetAttributeName(ATTR_EXIT_COMMENT));
         if(attr != NULL)
            comment = attr.GetValue();
         pos.AttributesChanged(tp, comment);
      }
      ///
      /// ������, ���� ������� ������� ������������� �������� ����������� � ���� � ��������� ������.
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
      XmlPos2(Position* pos)
      {
         xPos = new XPosValues(pos);
      }
      ///
      /// ��������� ���� �� ���������.
      ///
      bool CheckModify();
      ///
      /// ��������� ������� ���������.
      ///
      bool SaveState(ENUM_STATE_TYPE type);
   private:
      ///
      /// � ������ ������ ���������� ��������� �� XML-��������, � ������ ������� ���������� NULL
      ///
      bool LoadXmlDoc();
      ///
      /// ��������� ������� ����������� �������� � ����.
      ///
      void SaveXmlDoc();
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
      ///
      void ReadMe(void);
      ///
      /// ������, ���� XML-���� �������� ������� xml-���� � ���� � ��������� ������.
      ///
      bool ContainsMe(void);
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
      FileInfo* file;
      ///
      /// ���������� ��� xml-��������� � ����������� �� ��� ����.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS);
      ///
      /// ������, ���� ��������� ������ XML ��������� ����������� ��������.
      ///
      bool isFailedRead;
      ///
      /// ������, ���� ������������� ����������� ��������.
      ///
      bool isFailedSynch;
};

bool XmlPos2::LoadXmlDoc(void)
{
   if(CheckPointer(doc) == POINTER_INVALID)
   {
      doc = new CXmlDocument();
      doc.BlockedMode(true);
   }
   else return true;
   string err;
   return doc.CreateFromFile(file.Name(), err);
}

void XmlPos2::SaveXmlDoc()
{
   if(CheckPointer(doc) == POINTER_INVALID)return;
   doc.SaveToFile(file.Name());
   delete doc;
}

bool XmlPos2::CheckModify(void)
{
   if(file == NULL)
   {
      string fileName = Resources::GetFileNameByType(RES_ACTIVE_POS_XML);
      file = new FileInfo(fileName, 0, 1);
   }
   if(isFailedSynch)
      return SaveState();
   //xPos.
   if(!file.IsModify() && !isFailedRead)return false;
   //���-�� ��� �������� ����? - ������� ��������� � �������� ���.
   printf("ModifyDetect");
   if(!LoadXmlDoc())
   {
      isFailedRead = true;
      return false;
   }
   isFailedRead = false;
   if(!ContainsMe())
      CreateMe();
   else
      ReadMe();
   SaveXmlDoc();
   file.IsModify();
   return true;
}

bool XmlPos2::SaveState(ENUM_STATE_TYPE type = STATE_REFRESH)
{
   printf("SaveState");
   if(!LoadXmlDoc())
   {
      isFailedSynch = true;
      return false;
   }
   isFailedSynch = false;
   DeleteMe();
   if(type == STATE_REFRESH)
      CreateMe();
   SaveXmlDoc();
   return true;
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
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         doc.FDocumentElement.ChildDelete(i);
   }
}

void XmlPos2::ReadMe()
{
   if(CheckPointer(doc) == POINTER_INVALID)return;
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         xPos.SetXmlElement(element);
   }
}