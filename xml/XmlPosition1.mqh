#include "XmlBase.mqh"
#include "..\Settings.mqh"
#include "..\Log.mqh"
#include "..\Math.mqh"
#include "FileInfo.mqh"
class Position;
///
/// XML �������.
///
class XmlPosition1 : CObject
{
   public:
      ///
      /// ���������� ������������� �������.
      ///
      ulong Id(){return id;}
      ///
      /// ���������� ������������� �����.
      ///
      ulong AccountId(){return accountId;}
      ///
      /// ���������� ������� ������������ ����-�������.
      ///
      double TakeProfit(){return takeProfit;}
      ///
      /// ���������� ������� ����-�����.
      ///
      double StopLoss(){return stopLoss;}
      ///
      /// ���������� ��������� �����������.
      ///
      string ExitComment(){return strExitComment;}
      ///
      /// ��������� �������� XML ��������� �� xml ���� �������.
      /// \param xmlItem - ���� xml �������.
      ///
      void RefreshValues(CXmlElement* xmlItem);
      ///
      /// ������� XML ������� �� xml ���� xmlItem.
      /// \param xmlFile - �������� xml ����� � ������� ���������� �������� � xml �������.
      /// \param xmlItem - xml ����, ����������� xml �������.
      ///
      XmlPosition1(Position* pos);
      ~XmlPosition1();
      
      //XmlPosition(string xml_file)
      ///
      /// ������, ���� xml ������� ����� �����������������.
      ///
      bool IsValid(void){return valid;}
      ///
      /// ������, ���� �������� xml ������� ���� ��������.
      ///
      bool IsRefresh(void){return isRefresh;}
      ///
      /// ���������� ���� ��������� � �������.
      ///
      void ResetRefresh(void){isRefresh = false;}
      
      void SyncronizeXml(void);
      ///
      /// ��������� xml-������� � ���� ���� � XML �����, ����������� �� ������������.
      ///
      bool SaveToFile();
      ///
      /// ���������� ��������� �������� xml ��������� ������������� ������������� �����.
      ///
      string StringAccountId(void){return strAccountId;}
      ///
      /// ���������� ��������� �������� xml ��������� ������������� ������������� �������.
      ///
      string StringId(void){return strAccountId;}
      ///
      /// ���������� ��������� �������� xml ��������� ������������� ������� ������ �������.
      ///
      string StringTakeProfit(){return strTakeProfit;}
      ///
      /// ��������� ���������� ����� XML.
      ///
      void CheckModify(void);
      ///
      /// ������, ���� �������� xml ����, ���������� � ������� �����������, ���� ��������.
      ///
      bool ChangedValues(void);
   private:
      ///
      /// ����������� ��� ����������� �������������.
      ///
      XmlPosition1(CXmlElement* xmlItem);
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
      /// ��������� �� ������������ ������������ xml ���� � �������������� ������
      /// �������� ���������� c ������� ����� xml ����.
      ///
      bool ParsePositionNode(CXmlElement* xmlItem);
      
      ///
      /// ���������� �������� ��������� � ����������� �� ��� ����.
      /// \param typeAttr - �������������, ������������ ��� ���������.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS typeAttr);
      ///
      /// ������� � ����� XML ����, ��������� � ������� xml-��������. ���� ����� ���� �� ��� ������, �� ���������� NULL.
      /// \return �������� ���� ���� NULL � ������ �������.
      ///
      CXmlElement* FindXmlNode(void);
      ///
      /// ������� ����� xml-���� ��������������� �������� ���������� xml-�������.
      ///
      CXmlElement* CreateXmlNode(void);
      ///
      /// ������� �� XML ����� ��������������� ����, ��������� � ������� xml-��������.
      /// \return ������, ���� ���� ��� ������ � ������� ������ �� �����, ���� � ��������� ������.
      ///
      bool DeleteXmlNode();
      ///
      /// ������ �� XML ����� xml-�������� � ���������� ������ �� ����.
      /// � ������ ���� �������� ��������� ��������� ���������� NULL.
      /// \return ������ �� XML �������� � ������ ����� � NULL � ��������� ������.
      ///
      CXmlDocument* ReadXmlFile(void);
      ///
      /// ���������, ����������� �� ���������� xml ���� �������� ���������� xml-�������.
      /// \return ������, ���� ���������� ���� �������� �������������� xml-�������
      /// � ���� � ��������� ������.
      ///
      bool IsMyXmlNode(CXmlElement* xmlItem);
      void SyncronizeXmlAttr(CXmlElement* xmlItem);
      ///
      /// ������������� �������.
      ///
      ulong id;
      ///
      /// ������������� �����.
      ///
      ulong accountId;
      ///
      /// ������� TakeProfit;
      ///
      double takeProfit;
      ///
      /// ������� ����-�����.
      ///
      double stopLoss;
      ///
      /// ������, ���� xml ������� ����� ����������������.
      ///
      bool valid;
      ///
      /// ����, �����������, ��� �������� xml ������� ���� ��������.
      ///
      bool isRefresh;
      ///
      /// �������� XML �����, � ������� ���������� xml ����, ����������� ������ �������.
      ///
      string xmlFile;
      ///
      /// ��������� �������� AccountId.
      ///
      string strAccountId;
      ///
      /// ��������� �������� �������������� �������.
      ///
      string strId;
      ///
      /// ��������� �������� �������� ����-�������.
      ///
      string strTakeProfit;
      ///
      /// ��������� �������� ������������ �����������.
      ///
      string strExitComment;
      ///
      /// �������, � ������� ����������� ������� XML �������������.
      ///
      Position* position;
      ///
      /// ����, ������� ���������� �����������.
      ///
      FileInfo* file;
};

XmlPosition1::~XmlPosition1()
{
   if(CheckPointer(file) != POINTER_INVALID)
      delete file;
}

XmlPosition1::XmlPosition1(Position* pos)
{
   strAccountId = "";
   strExitComment = "";
   strId = "";
   strTakeProfit = "";
   accountId = AccountInfoInteger(ACCOUNT_LOGIN);
   id = pos.GetId();
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

void XmlPosition1::RefreshValues(CXmlElement* xmlItem)
{
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
         return "strExitComment";
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
   //�������� ���� ��������������, � ������� ������� ��������� �������.
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
   return false;
   //return doc.SaveToFile();
   
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
      {
         doc.FDocumentElement.ChildDelete(i);
         i--;
         continue;
      }
      if(xmlPos.AccountId() != accountId ||
         xmlPos.Id() != id)
      {
         delete xmlPos;
         continue;
      }
      delete xmlPos;
      return xmlItem;
   }
   return NULL;
}

CXmlElement* XmlPosition1::CreateXmlNode(void)
{
   CXmlElement* element = new CXmlElement();
   // ������������� �����
   CXmlAttribute* attr = new CXmlAttribute();
   attr.SetName(GetAttributeName(ATTR_ACCOUNT_ID));
   attr.SetValue(strAccountId);
   element.AttributeAdd(attr);
   // ������������� �������.
   attr = new CXmlAttribute();
   attr.SetName(GetAttributeName(ATTR_POSITION_ID));
   attr.SetValue(strId);
   element.AttributeAdd(attr);
   // ��������� �����������.
   attr = new CXmlAttribute();
   attr.SetName(GetAttributeName(ATTR_EXIT_COMMENT));
   attr.SetValue(strExitComment);
   element.AttributeAdd(attr);
   // ������� ����-�������.
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
   /*for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
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
   }*/
   return NULL;
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
   if(file.IsModify() && ChangedValues())
   {
      //���������� ������� �� ��������� ����������.
   }   
}

