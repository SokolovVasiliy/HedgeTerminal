#include "XmlBase.mqh"
#include "FileInfo.mqh"
#include "..\Log.mqh"
#include "..\Math.mqh"
#include "..\events.mqh"
class Position;
///
/// Xml-�������.
///
class XmlPos
{
   public:
      ///
      /// ���������� ������������� �����, � �������� ����������� �������.
      ///
      ulong AccountId(){return accountId;}
      ///
      /// ���������� ������������� �������.
      ///
      ulong Id(){return id;}
      
      ///
      /// ���������� ������� ������������ ����-�������.
      ///
      double TakeProfit(){return takeProfit;}
      ///
      /// ������������� ����� �������� ����-������� 
      ///
      void TakeProfit(double tp);
      
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
      /// �����������.
      ///
      XmlPos(Position* pos);
      ///
      /// ����������.
      ///
      ~XmlPos();
      ///
      /// ��������� XML ���� �� ����������.
      ///
      void CheckModify(void);
      ///
      /// ������, ���� ������� xml ������� �������� ��� ����������� ������.
      ///
      bool IsValid(void);
      ///
      /// ������� xml ����, ������� � ������ xml �������.
      ///
      void DeleteXmlNode();
   private:
      ///
      /// ������� ����� ��������� XmlPos �� ������ xml ��������.
      ///
      XmlPos(CXmlElement* xEl);
      ///
      /// ������� � 'doc' XML ����, ��������� � ������� xml-�������� � ���������� ��������� �� ����.
      /// ���� ���� �� ��� ������ ���������� NULL.
      ///
      CXmlElement* FindXmlNode(void);
      ///
      /// ������������� XML ��������.
      ///
      void ReloadXmlDoc(void);
      ///
      /// ������, ���� xml ����, ������� � ������ xml-������� ������������� ������� xml �������.
      ///
      bool IsSynchNode(void);
      ///
      /// ������� xml-����, ��������������� ������� �������.
      ///
      CXmlElement* CreateXmlNode();
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
      ///
      /// ���������� �������� ��������� � ����������� �� ��� ����.
      /// \param typeAttr - �������������, ������������ ��� ���������.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS typeAttr);
      ///
      /// ��������� �� ������������ ������������ xml ���� � �������������� ������
      /// �������� ���������� c ������� ����� xml ����.
      ///
      bool ParsePositionNode(void);
      ///
      /// XML ����, ������� ���������� �����������.
      ///
      FileInfo* file;
      ///
      /// ������, ���� ���������� XML ����� �������������
      //  ������������ ��������� 'doc' � ���� � ��������� ������.
      ///
      bool synchronize;
      ///
      /// ����������� XML ��������.
      ///
      CXmlDocument doc;
      ///
      /// �������� xml �����, ������� ��������� �������.
      ///
      string xmlFile;
      ///
      /// ������, ���� ��������� �������� �� �������� ����� ������ �� ������ � ����
      /// � ��������� ������.
      ///
      bool failedOpen;
      ///
      /// ���������, �� ���� �� ����� 'doc', ������� ������������� ������� xml �������.
      ///
      CXmlElement* xmlItem;
      ///
      /// ������������� �����, � �������� ����������� �������.
      ///
      ulong accountId;
      ///
      /// ������������� �������.
      ///
      ulong id;
      ///
      /// ������� TakeProfit;
      ///
      double takeProfit;
      ///
      /// ������� ����-�����.
      ///
      double stopLoss;
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
};

XmlPos::XmlPos(Position* pos)
{
   xmlFile = Settings.GetActivePosXml();
   file = new FileInfo(xmlFile, FILE_COMMON, 1);
   position = pos;
   accountId = AccountInfoInteger(ACCOUNT_LOGIN);
   id = pos.GetId();
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
}

void XmlPos::ReloadXmlDoc(void)
{
   string error;
   bool res = doc.CreateFromFile(xmlFile, error);
   if(!res && !failedOpen)
   {
      LogWriter("Failed read XML file. LastError:" + (string)GetLastError(), MESSAGE_TYPE_WARNING);
      xmlItem = NULL;
      failedOpen = true;
   }
   if(res)
   {
      synchronize = true;
      failedOpen = false;
      if(!IsSynchNode())
      {
         XmlPos* xPos = new XmlPos(xmlItem);
         strExitComment = xPos.ExitComment();
         takeProfit = xPos.TakeProfit();
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
   return NULL;
}

bool XmlPos::IsSynchNode(void)
{
   if(CheckPointer(xmlItem) == POINTER_INVALID)
   {
      xmlItem = FindXmlNode();
      if(xmlItem == NULL)
      {
         xmlItem = CreateXmlNode();
         doc.FDocumentElement.ChildAdd(xmlItem);
         doc.SaveToFile(xmlFile);
      }
   }
   XmlPos* xPos = new XmlPos(xmlItem);
   if(xPos.ExitComment() != strExitComment ||
      !Math::DoubleEquals(xPos.TakeProfit(), takeProfit))
   {
      return false;
   }
   return true;
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
   //�������� ���� ��������������, � ������� ������� ��������� �������.
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
      doc.FDocumentElement.ChildDelete(xmlItem);
      doc.SaveToFile(xmlFile);
   }
}

void XmlPos::TakeProfit(double tp)
{
   takeProfit = tp;
   string stp = position.PriceToString(tp);
   if(strTakeProfit != stp)
   {
      strTakeProfit = stp;
   }
}