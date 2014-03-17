#include <Object.mqh>
#include "XmlBase.mqh"
///
/// Тип виртуального ордера.
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
      /// Облегченный конструктор.
      ///
      XmlHistPos(ulong id);
      ///
      /// Конструктор по умолчанию.
      ///
      XmlHistPos(CXmlElement* xmlItem);
      ///
      /// Возвращает идентификатор позиции.
      ///
      ulong PosId(){return posId;}
      ///
      /// Истина, если класс исторической xml позиции инициирован верными данными.
      ///
      bool IsValid(){return valid;}
      ///
      /// Возвращает уровень виртуального тейк-профита.
      ///
      double TakeProfit(){return tp_level;}
      ///
      /// Возвращает уровень виртуального стоп-лосса.
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
      /// Идентификатор позиции.
      ///
      ulong posId;
      ///
      /// Уровень виртуального тейк-профита.
      ///
      double tp_level;
      ///
      /// Уровень виртуального стоп-лосса.
      ///
      double sl_level;
      ///
      /// Истина, если инициализация объекта прошла успешно, и ложь в противном случае.
      ///
      bool valid;
      ///
      /// Тип виртуального ордера.
      ///
      ENUM_VIRTUAL_ORDER_TYPE typeOrder;
      ///
      /// Парсит xml тег содержащий информацию о виртуальном ордере.
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