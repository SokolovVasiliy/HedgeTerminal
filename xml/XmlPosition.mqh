#include "XmlBase.mqh"
#include "..\Log.mqh"
#include "..\Math.mqh"
#include "..\Settings.mqh"
///
/// XML �������.
///
class XmlPosition : CObject
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
      void TakeProfit(double tp){takeProfit = tp;}
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
      XmlPosition(string xmlFile, CXmlElement* xmlItem);
      
      XmlPosition(string xml_file);
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
      
   private:
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
      
      virtual int Compare(const CObject *node,const int mode=0) const
      {
         const XmlPosition* xmlPos = node;
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
};

XmlPosition::XmlPosition(string xml_file, CXmlElement *xmlItem)
{
   strAccountId = "";
   strExitComment = "";
   strId = "";
   strTakeProfit = "";
   valid = ParsePositionNode(xmlItem);
   xmlFile = xml_file;
}


CXmlDocument* XmlPosition::ReadXmlFile(void)
{
   CXmlDocument* doc = new CXmlDocument();
   string err;
   if(!doc.CreateFromFile(Settings.GetActivePosXml(), err))
   {
      LogWriter("XML file " + Settings.GetActivePosXml() + " is broked. Check sintax error.", MESSAGE_TYPE_WARNING);
      delete doc;
      return NULL;
   }
   return doc;
}

void XmlPosition::RefreshValues(CXmlElement* xmlItem)
{
   ParsePositionNode(xmlItem);
}


string XmlPosition::GetAttributeName(ENUM_ATTRIBUTE_POS attr)
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

///
/// �������������� ���� xml ����������� ������� � ������� ��������.
///
/*void XmlPosition::SyncronizeXml(void)
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
      {
         delete xmlPos;
         continue;
      }
      delete xmlPos;
      SyncronizeXmlAttr(xmlItem);
   }
   if(!doc.SaveToFile(Settings.GetActivePosXml()))
   {
      LogWriter("Save changes failed. Error: " + (string)GetLastError(), MESSAGE_TYPE_WARNING);
   }
}*/

bool XmlPosition::SaveToFile(void)
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

CXmlElement* XmlPosition::FindXmlNode(void)
{
   string err;
   CXmlDocument* doc = ReadXmlFile();
   if(doc == NULL)return NULL;
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
      return xmlItem;
   }
   return NULL;
}

CXmlElement* XmlPosition::CreateXmlNode(void)
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

bool XmlPosition::DeleteXmlNode(void)
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
   return NULL;
}


///
/// �������������� ��������� xml ���� ���������� � ������� xml-�������� �
/// ���������� ������� ������ �������.
///
/*void XmlPosition::SyncronizeXmlAttr(CXmlElement* xmlItem)
{
   if(strId != NULL && strId != "")
   {
      
   }
   //�������������� �����������.
   if(strExitComment != NULL && strExitComment != "")
   {
      
      CXmlAttribute* attr = xmlItem.GetAttribute(GetAttributeName(ATTR_EXIT_COMMENT));
      if(attr == NULL)
      {
         CXmlAttribute* comm = new CXmlAttribute();
         comm.SetName(GetAttributeName(ATTR_EXIT_COMMENT));
         comm.SetValue(strExitComment);
         xmlItem.AttributeAdd(comm);
      }
      else
      {
         if(strExitComment != attr.GetValue())
            attr.SetValue(strExitComment);
      }
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
}*/
///
///
///
void XmlPosition::SyncronizeXmlAttr(CXmlElement* xmlItem)
{
   
}

