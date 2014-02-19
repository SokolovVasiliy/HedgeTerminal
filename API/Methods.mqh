#include "Transaction.mqh"
///
/// Абстрактный метод. Метод - это конкретное торговое действие в терминале: изменить стоп-лосс,
/// совершить сделку и т.д. 
///
class Method : public CObject
{
   public:
      bool Execute()
      {
         trade.SetAsyncMode(asynchMode);
         trade.SetExpertMagicNumber(magic);
         return OnExecute();
      }
   protected:
      Method(){;}
      Method(string symbol_op, ENUM_DIRECTION_TYPE direction, double volume, double price_order, string comment_op, ulong magic_op, bool asynch_mode)
      {
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
      CTrade trade;
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
class MethodTradeOnMarket : public Method
{
   public:
      MethodTradeOnMarket(string symbol_op, ENUM_DIRECTION_TYPE direction, double volume, string comment_op, ulong magic_op, bool asynch_mode):
      Method(symbol_op, direction, volume, 0.0, comment_op, magic_op, asynch_mode){;}
   private:
      ///
      /// Выполняет операцию. Истина, если операция была успешно выполнена и ложь в противном случае.
      ///
      virtual bool OnExecute()
      {
         if(dirType == DIRECTION_NDEF)
         {
            LogWriter("Trade on market: direction not defined.", MESSAGE_TYPE_ERROR);
            return false;
         }
         bool res = false;
         if(dirType == DIRECTION_LONG)
            res = trade.Buy(vol, symbol, 0.0, 0.0, 0.0, comment);
         else
            res = trade.Sell(vol, symbol, 0.0, 0.0, 0.0, comment);
         if(!res)
            SendError("Trade on market: rejected operation.");
         return res;
      }
};

///
/// Устанавливает отложенный стоп ордер.
///
class MethodSetStopOrder : public Method
{
   public:
      MethodSetStopOrder(string symbol_op, ENUM_DIRECTION_TYPE direction, double volume, double price_order, string comment_op, ulong magic_op, bool asynch_mode):
      Method(symbol_op, direction, volume, price_order, comment_op, magic_op, asynch_mode){;}
   private:
      virtual bool OnExecute()
      {
         if(dirType == DIRECTION_NDEF)
         {
            LogWriter("Set stop order: direction not defined.", MESSAGE_TYPE_ERROR);
            return false;
         }
         bool res = false;
         if(dirType == DIRECTION_LONG)
            res = trade.BuyStop(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
         else if(dirType == DIRECTION_SHORT)
            res = trade.SellStop(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
         if(!res)
            SendError("Failed to set stop order.");
         return res;
      }
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
      };
   private:
      ///
      /// Выполняет операцию. Истина, если операция была успешно выполнена и ложь в противном случае.
      ///
      virtual bool OnExecute()
      {
         if(!CheckValidPrice())return false;
         bool res = trade.OrderModify(orderId, price, 0.0, 0.0, ORDER_TIME_GTC, 0, 0);
         if(!res)
            SendError("Failed order modify.");
         return res;
      }
      ///
      /// Проверяет правильность цен. Истина, если метод может быть исполнен и ложь
      /// в противном случае.
      ///
      bool CheckValidPrice()
      {
         //Ордер должен существовать.
         if(!OrderSelect(orderId))
         {
            LogWriter("Pending order #" + (string)orderId + " not find.", MESSAGE_TYPE_ERROR);
            return false;
         }
         //Новая цена должна отличаться от цены отложенного ордера
         double oldPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         if(Math::DoubleEquals(oldPrice, price))
         {
            LogWriter("New price should be different from the old price.", MESSAGE_TYPE_ERROR);
            return false;
         }
         return true;
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
         asynchMode = asynchMode;
      };
   private:
      ///
      /// Выполняет операцию. Истина, если операция была успешно выполнена и ложь в противном случае.
      ///
      virtual bool OnExecute()
      {
         if(!OrderSelect(orderId))
         {
            LogWriter("Pending order #" + (string)orderId + " not find.", MESSAGE_TYPE_ERROR);
            return false;
         }
         bool res = trade.OrderDelete(orderId);
         if(!res)
            SendError("Failed order modify.");
         return res;
      }
      ///
      /// Идентификатор ордера, который необходимо удалить.
      ///
      ulong orderId;
};