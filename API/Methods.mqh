#include "Transaction.mqh"
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
      CTrade trade;
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
class MethodTradeOnMarket : public Method
{
   public:
      MethodTradeOnMarket(string symbol_op, ENUM_DIRECTION_TYPE direction, double volume, string comment_op, ulong magic_op, bool asynch_mode):
      Method(symbol_op, direction, volume, 0.0, comment_op, magic_op, asynch_mode){;}
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
      };
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
         asynchMode = asynchMode;
      };
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