#include "Transaction.mqh"
#include "..\Log.mqh"
///
/// Статус ордера.
///
enum ENUM_ORDER_STATUS
{
   ///
   /// Фиктивный ордер, не существующий в базе данных терминала.
   ///
   ORDER_NULL,
   ///
   /// Отложенный, еще не исполненный ордер.
   ///
   ORDER_PENDING,
   ///
   /// Исполненный, исторический ордер.
   ///
   ORDER_HISTORY
};

class Order : public Transaction
{
   public:
      Order(void);
      Order(ulong orderId);
      Order(CDeal* deal);
      void AddDeal(CDeal* deal);
      ENUM_ORDER_STATUS Status();
      ENUM_ORDER_STATUS RefreshStatus(void);
      void Init(ulong orderId);
      ulong InOrderId();
      bool IsPending();
      ~Order();
   private:
      virtual bool MTContainsMe();
      ENUM_ORDER_STATUS status;
      CArrayObj* deals;
};

/*PUBLIC MEMBERS*/
Order::Order() : Transaction(TRANS_ORDER)
{
   status = ORDER_NULL;
}
///
/// Создает ордер с идентификтором idOrder. Ордер с указанным идентификатором
/// должен существовать в базе данных ордеров терминала, в противном случае, статус
/// ордера ENUM_ORDER_STATUS будет соответствовать ORDER_NULL (недействительный ордер).
///
Order::Order(ulong idOrder):Transaction(TRANS_ORDER)
{
   Init(idOrder);
}

///
/// Создает новый ордер на одной из его сделок.
///
Order::Order(CDeal* deal) : Transaction(TRANS_ORDER)
{
   SetId(deal.OrderId());
   AddDeal(deal);
   RefreshStatus();
}

Order::~Order(void)
{
   if(deals != NULL)
   {
      deals.Clear();
      delete deals;
   }
}

void Order::Init(ulong orderId)
{
   SetId(orderId);
   RefreshStatus();
}

ulong Order::InOrderId()
{
   return 0;
}
///
/// Возвращает последний известный статус ордера. Статус может отличаться от фактического.
/// Для точного определения статуса используйте функцию Checkstatus(). 
/// \return Последний известный статус ордера.
///
ENUM_ORDER_STATUS Order::Status(void)
{
   return status;
}

///
/// Возвращает статус ордера ENUM_ORDER_STATUS на основании информации полученной из
/// базы данных ордеров терминала. Синхранизирует последнее известное состояние статуса
/// ордера с текущим состоянием.
///
ENUM_ORDER_STATUS Order::RefreshStatus()
{
   if(IsPending())
   {
      status = ORDER_PENDING;
      return status;
   }
   if(MTConteinsMe())
   {
      if(deals == NULL || deals.Total() == 0)
      {
         SetId(0);
         status = ORDER_NULL;
      }
      else
         status = ORDER_HISTORY;   
   }
   else
   {
      SetId(0);
      status = ORDER_NULL;
   }
   return status;
}

///
/// Добавляет сделку в список сделок ордера.
///
void Order::AddDeal(CDeal* deal)
{
   if(deal.Status() == DEAL_BROKERAGE ||
      deal.Status() == DEAL_NULL)
   {
      LogWriter("Type of the deal '" + EnumToString(deal.Status()) + "' not supported in order.", MESSAGE_TYPE_WARNING);
      return;
   }
   if(deal.OrderId() != GetId() && GetId() != 0)
   {
      LogWriter("Order ID #" + deal.OrderId() + " in the deal #" + deal.GetId() +
                " is not equal order id. Adding failed.", MESSAGE_TYPE_WARNING);
      return;
   }
   if(GetId() == 0)
      SetId(deal.OrderId());
   if(deals == NULL)
      deals = new CArrayObj();
   deals.Add(deal);
   RefreshStatus();
}

///
/// Истина, если терминал содержит информацию об ордере с
/// с текущим идентификатором и ложь в противном случае. Перед вызовом
/// функции в терминал должна быть загружена история сделок и ордеров.
///
bool Order::MTContainsMe()
{
   if(HistoryOrderGetInteger(GetId(), ORDER_TIME_SETUP) > 0)
      return true;
   return false;
}

bool Order::IsPending()
{
   return OrderSelect(GetId());
}