#include "Transaction.mqh"
#include "Trade2.mqh"
///
/// ����������� �����. ����� - ��� ���������� �������� �������� � ���������: �������� ����-����,
/// ��������� ������ � �.�. 
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
      /// ��������� ��������� ������ �������� ��������.
      ///
      void SendError(string msg)
      {
         string err = trade.ResultRetcodeDescription();
         LogWriter(msg + " Reason: " + err, MESSAGE_TYPE_ERROR);
      }
      ///
      /// ����������� ������ ���������� �������� ��������.
      ///
      Trade trade;
      ///
      /// ����������� ������ ��������� ���������� � �������.
      ///
      CSymbolInfo symbolInfo;
      ///
      /// ����������� �������� ��������.
      ///
      ENUM_DIRECTION_TYPE dirType;
      ///
      /// ����� �������� ��������.
      ///
      double vol;
      ///
      /// ���������� ����� �������� ��������.
      ///
      ulong magic;
      ///
      /// ����, ����������� �� ����������� ����� �������� ��������.
      ///
      bool asynchMode;
      ///
      /// ����������� � �������� ��������.
      ///
      string comment;
      ///
      /// ������, �� �������� ���������� ��������� �������� ��������.
      ///
      string symbol;
      ///
      /// ����� ���� ����������� ������.
      ///
      double price;
};

///
/// ��������� �������� �������� � ������� �������� �������.
///
class MethodTradeByMarket : public Method
{
   public:
      MethodTradeByMarket(string symbol_op, ENUM_DIRECTION_TYPE direction, double volume, string comment_op, ulong magic_op, bool asynch_mode):
      Method(symbol_op, direction, volume, 0.0, comment_op, magic_op, asynch_mode){;}
      ///
      /// ���������� ���������� ������������� ������.
      ///
      ulong Magic(){return magic;}
      ///
      /// ���������� ������������� ������, ������� ����� ��������.
      ///
      uint RequestId()
      {
         return trade.ResultRequestId();
      }
   private:
      ///
      /// ��������� ��������. ������, ���� �������� ���� ������� ��������� � ���� � ��������� ������.
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
/// ������������� ���������� ���� �����.
///
class MethodSetPendingOrder : public Method
{
   public:
      MethodSetPendingOrder(string symbol_op, ENUM_ORDER_TYPE typeOrder, double volume, double price_order, string comment_op, ulong magic_op, bool asynch_mode):
      Method(symbol_op, DIRECTION_NDEF, volume, price_order, comment_op, magic_op, asynch_mode)
      {
         orderType = typeOrder;
      }
      ///
      /// ���������� ������ ����������� ������.
      ///
      ulong Magic(){return magic;}
      ///
      /// ���������� ������ ����������� ������.
      ///
      string Symbol(){return symbol;}
      ///
      /// ���������� ��� ����������� ������.
      ///
      ENUM_ORDER_TYPE OrderType(){return orderType;}
      
   private:
      virtual bool OnExecute()
      {
         bool res = false;
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
               res = trade.BuyStop(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
               break;
            case ORDER_TYPE_SELL_STOP:
               res = trade.SellStop(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
               break;
            case ORDER_TYPE_BUY_LIMIT:
               res = trade.BuyLimit(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
               break;
            case ORDER_TYPE_SELL_LIMIT:
               res = trade.SellLimit(vol, price, symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, comment);
               break;
         }
         if(!res)
            SendError("Installation pending order was fails.");
         return res;
      }
      ///
      /// ��� ������.
      ///
      ENUM_ORDER_TYPE orderType;
};

///
/// ������������ ���������� �����
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
      /// ���������� ������������� ����������� ������.
      ///
      ulong OrderId(){return orderId;}
      ///
      /// ���������� ����� ����, ������� ���� ���������� ����������� ������.
      ///
      double NewPrice(){return price;}
      
      ///
      /// ��������� ������������ ���. ������, ���� ����� ����� ���� �������� � ����
      /// � ��������� ������.
      ///
      bool CheckValidPrice()
      {
         //����� ������ ������������.
         if(!OrderSelect(orderId))
         {
            LogWriter("Pending order #" + (string)orderId + " not find.", MESSAGE_TYPE_ERROR);
            return false;
         }
         //����� ���� ������ ���������� �� ���� ����������� ������
         double oldPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         if(Math::DoubleEquals(oldPrice, price))
         {
            LogWriter("New price should be different from the old price.", MESSAGE_TYPE_ERROR);
            return false;
         }
         return true;
      }
   private:
      ///
      /// ��������� ��������. ������, ���� �������� ���� ������� ��������� � ���� � ��������� ������.
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
      /// ������������� ����������� ������, ���� ������������ �������� ���� ��������.
      ///
      ulong orderId;
};

///
/// ������� ���������� �����.
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
      /// ���������� ������������� ������, ������� ��������� �������.
      ///
      ulong OrderId(){return orderId;}
   private:
      ///
      /// ��������� ��������. ������, ���� �������� ���� ������� ��������� � ���� � ��������� ������.
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
      /// ������������� ������, ������� ���������� �������.
      ///
      ulong orderId;
};

