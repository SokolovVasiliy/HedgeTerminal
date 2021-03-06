#include <Object.mqh>
#include "..\LibXML\XmlBase.mqh"
///
/// Òèï âèðòóàëüíîãî îðäåðà.
///
enum ENUM_VIRTUAL_ORDER_TYPE
{
   VIRTUAL_STOP_LOSS,
   VIRTUAL_TAKE_PROFIT
};

class XmlHistPos : public CObject
{
   public:
      ///
      /// Îáëåã÷åííûé êîíñòðóêòîð.
      ///
      XmlHistPos(ulong id);
      ///
      /// Êîíñòðóêòîð ïî óìîë÷àíèþ.
      ///
      XmlHistPos(CXmlElement* xmlItem);
      ///
      /// Âîçâðàùàåò èäåíòèôèêàòîð ïîçèöèè.
      ///
      ulong PosId()const{return posId;}
      ///
      /// Èñòèíà, åñëè êëàññ èñòîðè÷åñêîé xml ïîçèöèè èíèöèèðîâàí âåðíûìè äàííûìè.
      ///
      bool IsValid(){return valid;}
      ///
      /// Âîçâðàùàåò óðîâåíü âèðòóàëüíîãî òåéê-ïðîôèòà.
      ///
      double TakeProfit(){return tp_level;}
      ///
      /// Âîçâðàùàåò óðîâåíü âèðòóàëüíîãî ñòîï-ëîññà.
      ///
      double StopLoss(){return sl_level;}
   private:
      virtual int Compare(const CObject *node, const int mode=0)const
      {
         const XmlHistPos* hPos = node;
         if(posId > hPos.PosId())return 1;
         if(posId < hPos.PosId())return -1;
         return 0;
      }
      ///
      /// Èäåíòèôèêàòîð ïîçèöèè.
      ///
      ulong posId;
      ///
      /// Óðîâåíü âèðòóàëüíîãî òåéê-ïðîôèòà.
      ///
      double tp_level;
      ///
      /// Óðîâåíü âèðòóàëüíîãî ñòîï-ëîññà.
      ///
      double sl_level;
      ///
      /// Èñòèíà, åñëè èíèöèàëèçàöèÿ îáúåêòà ïðîøëà óñïåøíî, è ëîæü â ïðîòèâíîì ñëó÷àå.
      ///
      bool valid;
      ///
      /// Òèï âèðòóàëüíîãî îðäåðà.
      ///
      ENUM_VIRTUAL_ORDER_TYPE typeOrder;
      ///
      /// Ïàðñèò xml òåã ñîäåðæàùèé èíôîðìàöèþ î âèðòóàëüíîì îðäåðå.
      ///
      bool ParseXml(CXmlElement* xmlItem);
      
};

XmlHistPos::XmlHistPos(CXmlElement *xmlItem)
{
   valid = ParseXml(xmlItem);
}

XmlHistPos::XmlHistPos(ulong id)
{
   posId = id;
}

bool XmlHistPos::ParseXml(CXmlElement* xmlItem)
{
   ulong login = AccountInfoInteger(ACCOUNT_LOGIN);
   if(xmlItem.GetName() != "Position")return false;
   CXmlAttribute* attr = xmlItem.GetAttribute("AccountID");
   if(attr == NULL)return false;
   ulong accountId = StringToInteger(attr.GetValue());
   if(login != accountId)return false;
   attr = xmlItem.GetAttribute("ID");
   if(attr == NULL)return false;
   posId = StringToInteger(attr.GetValue());
   attr = xmlItem.GetAttribute("VirtualTakeProfit");
   if(attr != NULL)
   {
      typeOrder = VIRTUAL_TAKE_PROFIT;
      tp_level = StringToDouble(attr.GetValue());
      return true;
   }
   return false;
}