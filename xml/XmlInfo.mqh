#include <Arrays\ArrayObj.mqh>
#include "FileInfo.mqh"
#include "XmlBase.mqh"
#include "XmlPosition.mqh"
#include "..\Log.mqh"
#include "..\events.mqh"
///
/// ��������� ���������� �� xml ������ ��� �������� � ������������ �������.
///
class XmlInfo
{
   public:
      void Event(Event* event);
      XmlInfo();
   private:
      ///
      /// �������������, ����������� �� ��� xml �����.
      ///
      enum ENUM_XML_TYPE
      {
         ///
         /// ����, ���������� ��������������� ���������� �� �������� ��������.
         ///
         XML_ACTIVE_POS,
         ///
         /// ����, ���������� ������������� ���������� �� ������������ ��������.
         ///
         XML_HISTORY_POS
      };
      
      string GetXmlName(ENUM_XML_TYPE);
      string GetAttributeName(ENUM_ATTRIBUTE_POS attr);
      void CheckXmlChanged();
      void OnModify(string name);
      void ReadActivePosXml();
      void ReadHistoryPosXml();
      bool CheckPositionNode(CXmlElement* xmlItem);
      void RefreshValues(CXmlElement* xmlItem);
      void SendXmlChanger(XmlPosition* xPos);
      ///
      /// ������ XML ������, ������� ���������� �����������.
      ///
      CArrayObj files;
      ///
      /// ������ xml �������.
      ///
      CArrayObj xmlPositions;
};

void XmlInfo::Event(Event *event)
{
   switch(event.EventId())
   {
      case EVENT_REFRESH:
         CheckXmlChanged();
         break;
   }
}
///
///
///
XmlInfo::XmlInfo()
{
   files.Add(new FileInfo(GetXmlName(XML_ACTIVE_POS), FILE_COMMON, 1));
   //files.Add(new FileInfo("", FILE_COMMON, 5);
   xmlPositions.Sort(0);
}

///
/// ��������� �� ��������� �����
///
void XmlInfo::CheckXmlChanged(void)
{
   for(int i = 0; i < files.Total(); i++)
   {
      FileInfo* file = files.At(i);
      if(file.IsModify())
         OnModify(file.Name());
   }
}
///
/// ���������� ��� ������������ �����.
///
void XmlInfo::OnModify(string name)
{
   if(name == GetXmlName(XML_ACTIVE_POS))
      ReadActivePosXml();
   //else if(name == GetXmlName(XML_HISTORY_POS))
      //ReadHistoryPosXml();
      
}
///
/// ���������� �������� �����, � ����������� �� ����
///
string XmlInfo::GetXmlName(ENUM_XML_TYPE type)
{
   switch(type)
   {
      case XML_ACTIVE_POS:
         return "ActivePositions.xml";
      case XML_HISTORY_POS:
         return "HistoryPositions.xml";
   }
   return "";
}

///
/// ������ ���������� �� �������� �������� �� �����.
///
void XmlInfo::ReadActivePosXml(void)
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
      
      if(!xmlPos.IsValid())continue;
      int index = xmlPositions.Search(xmlPos);
      if(index == -1)
      {
         xmlPositions.Add(xmlPos);
         SendXmlChanger(xmlPos);
         xmlPos.ResetRefresh();
      }
      else
      {
         delete xmlPos;
         XmlPosition* xPos = xmlPositions.At(index);
         xPos.RefreshValues(xmlItem);
         if(!xPos.IsRefresh())continue;
         SendXmlChanger(xPos);
         xPos.ResetRefresh();
      }
   }
}

void XmlInfo::SendXmlChanger(XmlPosition* xPos)
{
   if(CheckPointer(api) != POINTER_INVALID)
   {
      EventXmlActPosRefresh* event = new EventXmlActPosRefresh(xPos);
      api.Event(event);
      delete event;
   }
}
