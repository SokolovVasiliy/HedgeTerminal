#include "Transaction.mqh"
#include "Trade2.mqh"
///
/// Абстрактный метод. Метод - это конкретное торговое действие в терминале: изменить стоп-лосс,
/// совершить сделку и т.д. 
///
class Method : public CObject
{
   public:
      ///
      /// Возвращает код последней операции.
      ///
      uint Retcode(void)
      {
         return trade.ResultRetcode();
      }
      bool Execute()
      {
         trade.SetAsyncMode(asynchMode);
         trade.SetExpertMagicNumber(magic);
         return OnExecute();
      }
      ///
      /// Возвращает корректированную цену, для инструмента
      /// Например для фьючерса RTS цена 102333 будет скорректирована до 102330
      ///
      double CorrectPrice(double nprice)
      {
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
         nprice = NormalizeDouble(nprice, digits);
         double tsize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
         int priceSteps = (int)MathFloor(nprice/tsize);
         double corrPrice = priceSteps*tsize;
         return corrPrice;
      }
   protected:
      Method()
      {
         trade.LogLevel(LOG_LEVEL_NO);
      }
      Method(string symbol_op, ENUM_DIRECTION_TYPE direction, double volume, double price_order, string comment_op, ulong magic_op, bool asynch_mode)
      {
         trade.LogLevel(LOG_LEVEL_NO);
         dirType = direction;
         vol = volume;
         magic = magic_op;
         asynchMode = asynch_mode;
         comment = comment_op;
         symbol = symbol_op;
         price = price_order;
      }
      virtual bool OnExecute(){return false;}
      ///
      /// Проверяет последнюю ошибку торговой операции.
      ///
      void SendError(string msg)
      {
         string err = trade.ResultRetcodeDescription();
         LogWriter(msg + " Reason: " + err, MESSAGE_TYPE_ERROR);
      }
      ///
      /// Стандартный модуль совершения торговых операций.
      ///
      Trade trade;
      ///
      /// Стандартный модуль получения информации о символе.
      ///
      CSymbolInfo symbolInfo;
      ///
      /// Направление торговой операции.
      ///
      ENUM_DIRECTION_TYPE dirType;
      ///
      /// Объем торговой операции.
      ///
      double vol;
      ///
      /// Магический номер торговой операции.
      ///
      ulong magic;
      ///
      /// Флаг, указывающий на асинхронный режим торговой операции.
      ///
      bool asynchMode;
      ///
      /// Комментарий к торговой операции.
      ///
      string comment;
      ///
      /// Символ, по которому необходимо совершить торговую операцию.
      ///
      string symbol;
      ///
      /// Новая цена отложенного ордера.
      ///
      double price;
};

///
/// Совершает торговые операции с помощью рыночных ордеров.
///
class MethodTradeByMarket : public Method
{
   public:
      MethodTradeByMarket(string symbol_op, ENUM_DIRECTION_TYPE direction, double volume, ulong deviation, string comment_op, ulong magic_op, bool asynch_mode):
      Method(symbol_op, direction, volume, 0.0, comment_op, magic_op, asynch_mode)
      {
         m_deviation = deviation;
         m_exe = (ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(symbol, SYMBOL_TRADE_EXEMODE);
         trade.SetDeviationInPoints(deviation);
      }
      ///
      /// Возвращает уникальный идентификатор ордера.
      ///
      ulong Magic(){return magic;}
      ///
      /// Возвращает идентификатор ордера, который будет исполнен.
      ///
      uint RequestId()
      {
         return trade.ResultRequestId();
      }
   private:
      ///
      /// Предельное отклонение в пунктах
      ///
      ulong m_deviation;
      ///
      /// Режим исполнения рыночных приказов
      ///
      ENUM_SYMBOL_TRADE_EXECUTION m_exe;
      ///
      /// Выполняет операцию. Истина, если операция была успешно выполнена и ложь в противном случае.
      ///
      virtual bool OnExecute()
      {
         if(dirType == DIRECTION_UNDEFINED)
         {
            LogWriter("Trade on market: direction not defined.", MESSAGE_TYPE_ERROR);
            return false;
         }
         bool res = false;
         if(m_exe == SYMBOL_TRADE_EXECUTION_EXCHANGE && m_deviation > 0)
            res = LimitAsMarket();
         else
         {
            if(dirType == DIRECTION_LONG)
               res = trade.Buy(vol, symbol, 0.0, 0.0, 0.0, comment);
            else
               res = trade.Sell(vol, symbol, 0.0, 0.0, 0.0, comment);
         }
         return res;
      }
      ///
      /// Выставляет отложенный ордер, так, что бы он сработал по рыночным ценам, контролируя таким образом максимальное проскальзывание
      /// Этот режим доступен только для биржевого исполнения, когда лимитный ордер может быть установлен по ценам ХУЖЕ текущих.
      ///
      bool LimitAsMarket()
      {
         double dev_level = SymbolInfoDouble(symbol, SYMBOL_POINT)*(double)m_deviation;
         if(dirType == DIRECTION_SHORT)
         {
            double best_price = SymbolInfoDouble(symbol, SYMBOL_BID);
            if(best_price <= 0.0)return false;
            double price_exit = best_price - dev_level;
            price_exit = CorrectPrice(price_exit);
            return trade.SellLimit(vol, price_exit, symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, comment);
         }
         else if(dirType == DIRECTION_LONG)
         {
            double best_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
            if(best_price <= 0.0)return false;
            double price_exit = best_price + dev_level;
            price_exit = CorrectPrice(price_exit);
            return trade.BuyLimit(vol, price_exit, symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, comment);
         }
         return false;
      }
};


///
/// Устанавливает отложенный стоп ордер.
///
class MethodSetPendingOrder : public Method
{
   public:
      MethodSetPendingOrder(string symbol_op, ENUM_ORDER_TYPE typeOrder, double volume, double price_order, string comment_op, ulong magic_op, bool asynch_mode):
      Method(symbol_op, DIRECTION_UNDEFINED, volume, price_order, comment_op, magic_op, asynch_mode)
      {
         orderType = typeOrder;
      }
      ///
      /// Возвращает маджик отложенного ордера.
      ///
      ulong Magic(){return magic;}
      ///
      /// Возвращает символ отложенного ордера.
      ///
      string Symbol(){return symbol;}
      ///
      /// Возвращает тип отложенного ордера.
      ///
      ENUM_ORDER_TYPE OrderType(){return orderType;}
      
   private:
      virtual bool OnExecute()
      {
         bool res = false;
         datetime exp_time = (datetime)SymbolInfoInteger(symbol, SYMBOL_EXPIRATION_TIME);
         switch(orderType)
         {
            case ORDER_TYPE_BUY:
            case ORDER_TYPE_SELL:
            case ORDER_TYPE_BUY_STOP_LIMIT:
            case ORDER_TYPE_SELL_STOP_LIMIT:
               LogWriter("This type of pending order not support.", MESSAGE_TYPE_ERROR);
               res = true;
               break;
            case ORDER_TYPE_BUY_STOP:
               
               if(exp_time == 0)
                  res = trade.BuyStop(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
               else
                  res = trade.BuyStop(vol, price, symbol, 0.0, 0.0, ORDER_TIME_SPECIFIED, exp_time+86400, comment);
               break;
            case ORDER_TYPE_SELL_STOP:
               if(exp_time == 0)
                  res = trade.SellStop(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
               else
                  res = trade.SellStop(vol, price, symbol, 0.0, 0.0, ORDER_TIME_SPECIFIED_DAY, exp_time+86400, comment);
               break;
            case ORDER_TYPE_BUY_LIMIT:
               if(exp_time == 0)
                  res = trade.BuyLimit(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
               else
                  res = trade.BuyLimit(vol, price, symbol, 0.0, 0.0, ORDER_TIME_SPECIFIED, exp_time+86400, comment);
               break;
            case ORDER_TYPE_SELL_LIMIT:
               if(exp_time == 0)
                  res = trade.SellLimit(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
               else
                  res = trade.SellLimit(vol, price, symbol, 0.0, 0.0, ORDER_TIME_SPECIFIED, exp_time+86400, comment);
               break;
         }
         //if(!res)
         //   SendError("Installation pending order was fails.");
         return res;
      }
      ///
      /// Тип ордера.
      ///
      ENUM_ORDER_TYPE orderType;
};

///
/// Модифицирует отложенный ордер
///
class MethodModifyPendingOrder : public Method
{
   public:
      MethodModifyPendingOrder(ulong order_id, double newPrice, bool asynch_mode)
      {
         orderId = order_id;
         price = newPrice;
         asynchMode = asynch_mode;
      }
      ///
      /// Возвращает идентификатор отложенного ордера.
      ///
      ulong OrderId(){return orderId;}
      ///
      /// Возвращает новую цену, которую надо установить отложенному ордеру.
      ///
      double NewPrice(){return price;}
      
      ///
      /// Проверяет правильность цен. Истина, если метод может быть исполнен и ложь
      /// в противном случае.
      ///
      bool CheckValidPrice()
      {
         //Ордер должен существовать.
         if(!OrderSelect(orderId))
         {
            //LogWriter("Pending order #" + (string)orderId + " not find.", MESSAGE_TYPE_ERROR);
            return false;
         }
         //Новая цена должна отличаться от цены отложенного ордера
         double oldPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         if(Math::DoubleEquals(oldPrice, price))
         {
            //LogWriter("New price should be different from the old price.", MESSAGE_TYPE_ERROR);
            return false;
         }
         return true;
      }
   private:
      ///
      /// Выполняет операцию. Истина, если операция была успешно выполнена и ложь в противном случае.
      ///
      virtual bool OnExecute()
      {
         if(!CheckValidPrice())return false;
         bool res = trade.OrderModify(orderId, price, 0.0, 0.0, ORDER_TIME_GTC, 0, 0);
         //if(!res)
         //   SendError("Failed order modify.");
         return res;
      }
      ///
      /// Идентификатор отложенного ордера, цену срабатывания которому надо изменить.
      ///
      ulong orderId;
};

///
/// Удаляет отложенный ордер.
///
class MethodDeletePendingOrder : public Method
{
   public:
      MethodDeletePendingOrder(ulong order_id, bool asynch_mode)
      {
         orderId = order_id;
         asynchMode = asynch_mode;
      };
      ///
      /// Возвращает идентификатор ордера, который требуется удалить.
      ///
      ulong OrderId(){return orderId;}
   private:
      ///
      /// Выполняет операцию. Истина, если операция была успешно выполнена и ложь в противном случае.
      ///
      virtual bool OnExecute()
      {
         trade.SetAsyncMode(asynchMode);
         if(!OrderSelect(orderId))
         {
            //LogWriter("Pending order #" + (string)orderId + " not find.", MESSAGE_TYPE_ERROR);
            return false;
         }
         bool res = trade.OrderDelete(orderId);
         //if(!res)
         //   SendError("Failed order modify.");
         return res;
      }
      ///
      /// Идентификатор ордера, который необходимо удалить.
      ///
      ulong orderId;
};

