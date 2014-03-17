#include <Object.mqh>
#include "XmlBase.mqh"
///
/// ��� ������������ ������.
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
      /// ����������� �����������.
      ///
      XmlHistPos(ulong id);
      ///
      /// ����������� �� ���������.
      ///
      XmlHistPos(CXmlElement* xmlItem);
      ///
      /// ���������� ������������� �������.
      ///
      ulong PosId(){return posId;}
      ///
      /// ������, ���� ����� ������������ xml ������� ����������� ������� �������.
      ///
      bool IsValid(){return valid;}
      ///
      /// ���������� ������� ������������ ����-�������.
      ///
      double TakeProfit(){return tp_level;}
      ///
      /// ���������� ������� ������������ ����-�����.
      ///
      double StopLoss(){return sl_level;}
   private:
      virtual int Compare(const CObject *node,const int mode=0)const
      {
         const XmlHistPos* hPos = node;
         if(posId > hPos.PosId())return 1;
         if(posId < hPos.PosId())return -1;
         return 0;
      }
      ///
      /// ������������� �������.
      ///
      ulong posId;
      ///
      /// ������� ������������ ����-�������.
      ///
      double tp_level;
      ///
      /// ������� ������������ ����-�����.
      ///
      double sl_level;
      ///
      /// ������, ���� ������������� ������� ������ �������, � ���� � ��������� ������.
      ///
      bool valid;
      ///
      /// ��� ������������ ������.
      ///
      ENUM_VIRTUAL_ORDER_TYPE typeOrder;
      ///
      /// ������ xml ��� ���������� ���������� � ����������� ������.
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