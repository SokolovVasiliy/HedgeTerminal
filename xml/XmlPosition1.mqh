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
      /// ������������� ����� �������� ����-������� 
      ///
      void TakeProfit(double tp){takeProfit = tp;}
      ///
      /// ���������� ������� ����-�����.
      ///
      double StopLoss(){return stopLoss;}
      ///
      /// ������������� ����� �������� ����-�����.
      ///
      void StopLoss(double sl){stopLoss = sl;}
      ///
      /// ���������� ��������� �����������.
      ///
      string ExitComment(){return strExitComment;}
      ///
      /// ������������� ����� �������� ���������� �����������.
      ///
      void ExitComment(string comm){strExitComment = comm;}
      ///
      /// ��������� �������� XML ��������� �� xml ���� �������.
      /// \param xmlItem - ���� xml �������.
      ///
      void LoadXmlNode(void);
      ///
      /// ������� �� XML ����� ��������������� ����, ��������� � ������� xml-��������.
      /// \return ������, ���� ���� ��� ������ � ������� ������ �� �����, ���� � ��������� ������.
      ///
      bool DeleteXmlNode();
      ///
      /// �������������� ������ � xml-���� � ������� ���������� xml-�������.
      ///
      void RefreshXmlNode();
      ///
      /// ������� XML ������� �� xml ���� xmlItem.
      /// \param xmlFile - �������� xml ����� � ������� ���������� �������� � xml �������.
      /// \param xmlItem - xml ����, ����������� xml �������.
      ///
      XmlPosition1(Position* pos);
      ///
      /// ����������.
      ///
      ~XmlPosition1();
      ///
      /// ������, ���� xml ������� ����� �����������������.
      ///
      bool IsValid(void){return valid;}
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
      /// ��������� ��������� �������� xml ��������� ������������� ������� ������ �������.
      ///
      void StringTakeProfit(string tp){strTakeProfit = tp;}
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
      /// ��������� xml-������� � ���� ���� � XML �����, ����������� �� ������������.
      ///
      bool SaveToFile();
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
      /// ������ �� XML ����� xml-�������� � ���������� ������ �� ����.
      /// � ������ ���� �������� ��������� ��������� ���������� NULL.
      /// \return ������ �� XML �������� � ������ ����� � NULL � ��������� ������.
      ///
      CXmlDocument* ReadXmlFile(void);
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
      ///
      /// XML ��������, ���������� �������� � ������� ����.
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
      //���������� ������� �� ��������� ����������.
   }   
}



