#include "Transaction.mqh"

///
/// —татус ордера.
///
enum ENUM_ORDER_STATUS
{
   ///
   /// ‘иктивный ордер, не существующий в базе данных терминала.
   ///
   ORDER_NULL,
   ///
   /// ќтложенный, еще не исполненный ордер.
   ///
   ORDER_PENDING,
   ///
   /// »сполненный, исторический ордер.
   ///
   ORDER_HISTORY
};

class Order : public Transaction
{
   public:
      Order(ulong orderId);
      ENUM_ORDER_STATUS Status();
      ENUM_ORDER_STATUS CheckStatus(void);
      ulong Id();
   private:
      ENUM_ORDER_STATUS status;
};

/*PUBLIC MEMBERS*/

///
/// —оздает ордер с идентификтором idOrder. ќрдер с указанным идентификатором
/// должен существовать в базе данных ордеров терминала, в противном случае, статус
/// ордера ENUM_ORDER_STATUS будет соответствовать ORDER_NULL (недействительный ордер).
///
Order::Order(ulong idOrder):Transaction(TRANS_ORDER)
{
   SetId(idOrder);
   CheckStatus();
}
///
/// ¬озвращает последний известный статус ордера. —татус может отличатьс€ от фактического.
/// ƒл€ точного определени€ статуса используйте функцию Checkstatus(). 
/// \return ѕоследний известный статус ордера.
///
ENUM_ORDER_STATUS Order::Status(void)
{
   return status;
}

///
/// ¬озвращает статус ордера ENUM_ORDER_STATUS на основании информации полученной из
/// базы данных ордеров терминала. —инхранизирует последнее известное состо€ние статуса
/// ордера с текущим состо€нием.
///
ENUM_ORDER_STATUS Order::CheckStatus()
{
   if(OrderSelect(GetId()))
   {
      status = ORDER_PENDING;
      return status;
   }
   LoadHistory();
   if(HistoryOrderSelect(GetId()))
      status = ORDER_HISTORY;   
   else
   {
      SetId(0);
      status = ORDER_NULL;
   }
   return status;
}