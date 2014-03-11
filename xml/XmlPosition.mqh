#include "XmlBase.mqh"
#include "..\Log.mqh"
#include "..\Math.mqh"
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
      string ExitComment(){return exitComment;}
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
   private:
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
      /// ����������� �����������.
      ///
      string exitComment;
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
};

///
/// ��� �������� xml ������� ��������� ���� xml ���������� ���������� � �������.
///
XmlPosition::XmlPosition(string xml_file, CXmlElement *xmlItem)
{
   valid = ParsePositionNode(xmlItem);
   xmlFile = xml_file;
}
///
/// ��������� �������� � ������������ xml �������.
///
void XmlPosition::RefreshValues(CXmlElement* xmlItem)
{
   ParsePositionNode(xmlItem);
}

///
/// ���������� �������� �����, � ����������� �� ����
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
/// ��������� �� ������������ ������������ xml ����.
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
   //�������� ���� ��������������, � ������� ������� ��������� �������.
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
/// �������������� ���� xml ����������� ������� � ������� ��������.
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
/// �������������� xml ��������� ���� � ������� ���������� xml �������.
///
void XmlPosition::SyncronizeXmlAttr(CXmlElement* xmlItem)
{
   if(exitComment != NULL && exitComment != "")
   {
      //�������� �����������.
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

