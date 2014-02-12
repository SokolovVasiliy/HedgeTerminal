

///
/// Полный аналог MqlTradeTransaction. Определение полей см. в документации по
/// MqlTradeTransaction.
///
class TradeTransaction
{
   public:
      TradeTransaction(void);
      TradeTransaction(MqlTradeTransaction& trans);
      TradeTransaction(const MqlTradeTransaction& trans);
      bool IsUpdate(void);
      void CopyFrom(MqlTradeTransaction& trans);
      void CopyFrom(const MqlTradeTransaction& trans);
      ulong deal;
      ulong order;
      string symbol;
      ENUM_TRADE_TRANSACTION_TYPE type;
      ENUM_ORDER_TYPE order_type;
      ENUM_ORDER_STATE order_state;
      ENUM_DEAL_TYPE deal_type;
      ENUM_ORDER_TYPE_TIME time_type;
      datetime time_expiration;
      double price;
      double price_trigger;
      double price_sl;
      double price_tp;
      double volume;
};
///
/// Инициализирует экземпляр по-умолчанию.
///
TradeTransaction::TradeTransaction(void){;}
///
/// Инициализирует текущий экзмепляр идентичный переданной транзакции.
///
TradeTransaction::TradeTransaction(const MqlTradeTransaction& trans)
{
   CopyFrom(trans);
}
///
/// Заполняет текущий экземпляр значениями из MqlTradeTransaction.
///
void TradeTransaction::CopyFrom(const MqlTradeTransaction &trans)
{
   deal = trans.deal;
   order = trans.order;
   symbol = trans.symbol;
   type = trans.type;
   order_type = trans.order_type;
   order_state = trans.order_state;
   deal_type = trans.deal_type;
   time_type = trans.time_type;
   time_expiration = trans.time_expiration;
   price = trans.price;
   price_trigger = trans.price_trigger;
   price_sl = trans.price_sl;
   price_tp = trans.price_tp;
   volume = trans.volume;
}

///
/// Истина, если транзакция уведомляет о изменении отложенного ордера.
///
bool TradeTransaction::IsUpdate(void)
{
   if(type == TRADE_TRANSACTION_ORDER_UPDATE)
      return true;
   else
      return false;
}

///
/// Полный аналог MqlTradeRequest. Определение полей см. в документации
/// по MqlTradeRequest.
///
class TradeRequest
{
   public:
      TradeRequest(void);
      TradeRequest(const MqlTradeRequest& request);
      void CopyFrom(const MqlTradeRequest& request);
      ENUM_TRADE_REQUEST_ACTIONS    action;           // Тип выполняемого действия
      ulong                         magic;            // Штамп эксперта (идентификатор magic number)
      ulong                         order;            // Тикет ордера
      string                        symbol;           // Имя торгового инструмента
      double                        volume;           // Запрашиваемый объем сделки в лотах
      double                        price;            // Цена 
      double                        stoplimit;        // Уровень StopLimit ордера
      double                        sl;               // Уровень Stop Loss ордера
      double                        tp;               // Уровень Take Profit ордера
      ulong                         deviation;        // Максимально приемлемое отклонение от запрашиваемой цены
      ENUM_ORDER_TYPE               type;             // Тип ордера
      ENUM_ORDER_TYPE_FILLING       type_filling;     // Тип ордера по исполнению
      ENUM_ORDER_TYPE_TIME          type_time;        // Тип ордера по времени действия
      datetime                      expiration;       // Срок истечения ордера (для ордеров типа ORDER_TIME_SPECIFIED)
      string                        comment;          // Комментарий к ордеру

};
///
/// Инициализирует экземпляр по-умолчанию.
///
TradeRequest::TradeRequest(void){;}
///
/// Инициализирует экземпляр идентичный переданному запросу.
///
TradeRequest::TradeRequest(const MqlTradeRequest& request)
{
   CopyFrom(request);
}
///
/// Заполняет текущий экземпляр значениями из MqlTradeRequest.
///
void TradeRequest::CopyFrom(const MqlTradeRequest& request)
{
   action = request.action;
   magic = request.magic;
   order = request.order;
   symbol = request.symbol;
   volume = request.volume;
   price = request.price;
   stoplimit = request.stoplimit;
   sl = request.sl;
   tp = request.tp;
   deviation = request.deviation;
   type = request.type;
   type_filling = request.type_filling;
   type_time = request.type_time;
   expiration = request.expiration;
   comment = request.comment;
}

///
/// Полный аналог MqlTradeResult. Определение полей см. в документации
/// по MqlTradeResult.
///
class TradeResult
{
   public:
      TradeResult(void);
      TradeResult(const MqlTradeResult& result);
      void CopyFrom(const MqlTradeResult& result);
      bool IsRejected(void);
      string CodeDescription(void);
      uint     retcode;          // Код результата операции
      ulong    deal;             // Тикет сделки, если она совершена
      ulong    order;            // Тикет ордера, если он выставлен
      double   volume;           // Объем сделки, подтверждённый брокером
      double   price;            // Цена в сделке, подтверждённая брокером
      double   bid;              // Текущая рыночная цена предложения (цены реквота)
      double   ask;              // Текущая рыночная цена спроса (цены реквота)
      string   comment;          // Комментарий брокера к операции (по умолчанию заполняется расшифровкой)
      uint     request_id;       // Идентификатор запроса, устанавливается терминалом при отправке 
};
///
/// Инициализирует экземпляр по-умолчанию.
///
TradeResult::TradeResult(void){;}
///
/// Инициализирует экземпляр идентичный переданному результату.
///
TradeResult::TradeResult(const MqlTradeResult &result)
{
   CopyFrom(result);
}
///
/// Заполняет текущий экземпляр значениями из MqlTradeResult.
///
TradeResult::CopyFrom(const MqlTradeResult& result)
{
   retcode = result.retcode;
   deal = result.deal;
   order = result.order;
   volume = result.volume;
   price = result.price;
   bid = result.bid;
   ask = result.ask;
   comment = result.comment;
   request_id = result.request_id;
}
///
/// Истина, если торговый запрос был отвергнут.
///
bool TradeResult::IsRejected(void)
{
   switch(retcode)
   {
      case 0:
      case TRADE_RETCODE_PLACED:
      case TRADE_RETCODE_DONE:
      case TRADE_RETCODE_DONE_PARTIAL:
         return false;
      default:
         return true;
   }
   return false;
}
///
/// Возвращает строковое описание кода возврата торгового сервера.
///
string TradeResult::CodeDescription(void)
{
   string str = "";
   switch(retcode)
   {
      case TRADE_RETCODE_REQUOTE           : str="requote";                         break;
      case TRADE_RETCODE_DONE              : str="done";                            break;
      case TRADE_RETCODE_DONE_PARTIAL      : str="done partial";                    break;
      case TRADE_RETCODE_REJECT            : str="rejected";                        break;
      case TRADE_RETCODE_CANCEL            : str="canceled";                        break;
      case TRADE_RETCODE_PLACED            : str="placed";                          break;
      case TRADE_RETCODE_ERROR             : str="common error";                    break;
      case TRADE_RETCODE_TIMEOUT           : str="timeout";                         break;
      case TRADE_RETCODE_INVALID           : str="invalid request";                 break;
      case TRADE_RETCODE_INVALID_VOLUME    : str="invalid volume";                  break;
      case TRADE_RETCODE_INVALID_PRICE     : str="invalid price";                   break;
      case TRADE_RETCODE_INVALID_STOPS     : str="invalid stops";                   break;
      case TRADE_RETCODE_TRADE_DISABLED    : str="trade disabled";                  break;
      case TRADE_RETCODE_MARKET_CLOSED     : str="market closed";                   break;
      case TRADE_RETCODE_NO_MONEY          : str="not enough money";                break;
      case TRADE_RETCODE_PRICE_CHANGED     : str="price changed";                   break;
      case TRADE_RETCODE_PRICE_OFF         : str="off quotes";                      break;
      case TRADE_RETCODE_INVALID_EXPIRATION: str="invalid expiration";              break;
      case TRADE_RETCODE_ORDER_CHANGED     : str="order changed";                   break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS : str="too many requests";               break;
      case TRADE_RETCODE_NO_CHANGES        : str="no changes";                      break;
      case TRADE_RETCODE_SERVER_DISABLES_AT: str="auto trading disabled by server"; break;
      case TRADE_RETCODE_CLIENT_DISABLES_AT: str="auto trading disabled by client"; break;
      case TRADE_RETCODE_LOCKED            : str="locked";                          break;
      case TRADE_RETCODE_FROZEN            : str="frozen";                          break;
      case TRADE_RETCODE_INVALID_FILL      : str="invalid fill";                    break;
      case TRADE_RETCODE_CONNECTION        : str="no connection";                   break;
      case TRADE_RETCODE_ONLY_REAL         : str="only real";                       break;
      case TRADE_RETCODE_LIMIT_ORDERS      : str="limit orders";                    break;
      case TRADE_RETCODE_LIMIT_VOLUME      : str="limit volume";                    break;
      case TRADE_RETCODE_POSITION_CLOSED   : str="position closed";                 break;
      case TRADE_RETCODE_INVALID_ORDER     : str="invalid order";                   break;
      default:
         str="unknown retcode "+(string)retcode;
         break;
   }
   return str;
}
