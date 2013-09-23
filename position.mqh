#include <Object.mqh>
#include "Log.mqh"
///
/// ������ �������.
///
enum ENUM_POSITION_STATUS
{
   POSITION_STATUS_OPEN,
   POSITION_STATUS_CLOSED
};
///
/// �������.
///
class Position : CObject
{
   public:
      Position(ENUM_POSITION_STATUS myStatus,
               ENUM_POSITION_TYPE myType,
               long myMagic,
               string mySymbol,
               long myOrderId,
               double myVolume,
               datetime myEntryTime,
               double myEntryPrice,
               datetime myExitTime,
               double myExitPrice,
               string myEntryComment)
      {
         magic = myMagic;
         status = myStatus;
         type = myType;
         symbol = mySymbol;
         entryOrderId = myOrderId;
         volume = myVolume;
         entryDate = myEntryTime;
         entryPrice = myEntryPrice;
         exitDate = myExitTime;
         exitPrice = myExitPrice;
         entryComment = myEntryComment;
      }
      ///
      /// ������� ����� ������������ ������� �� ��������� ��������� � ���������� ������
      ///
      Position(ulong in_ticket, ulong out_ticket)
      {
         Init(in_ticket);
         status = POSITION_STATUS_CLOSED;
         volume = HistoryOrderGetDouble(out_ticket, ORDER_VOLUME_CURRENT);
         entryDate = (datetime)HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE);
         exitPrice = HistoryOrderGetDouble(out_ticket, ORDER_PRICE_OPEN);
         exitComment = HistoryOrderGetString(out_ticket, ORDER_COMMENT);
      }
      
      Position(ulong in_ticket)
      {
         bool isHistory = true;
         LoadHistory();
         if(!HistoryOrderSelect(in_ticket))
         {
            LogWriter("History position not find", MESSAGE_TYPE_ERROR);
            return;            
         }
         status = POSITION_STATUS_OPEN;
         magic = HistoryOrderGetInteger(in_ticket, ORDER_MAGIC);
         entryOrderId = in_ticket;
         symbol = HistoryOrderGetString(in_ticket, ORDER_SYMBOL);
         volume = HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_INITIAL) - HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_CURRENT);
         entryDate = (datetime)HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE);
         entryPrice = HistoryOrderGetDouble(in_ticket, ORDER_PRICE_OPEN);
         entryComment = HistoryOrderGetString(in_ticket, ORDER_COMMENT);
      }
      ///
      /// ���������� ������ �������.
      ///
      ENUM_POSITION_STATUS Status(){return status;}
      ///
      /// ���������� ����������� �������.
      ///
      //ENUM_POSITION_TYPE Type(){return type;}
      ///
      /// ���������� ���������� ����� ��������, ���������� �������.
      ///
      long Magic(){return magic;}
      ///
      /// ���������� �������� �����������, �� �������� ������� �������.
      ///
      string Symbol(){return symbol;}
      ///
      /// ���������� ������������� �������.
      ///
      ulong EntryOrderID(){return entryOrderId;}
      ///
      /// ���������� ����� �������.
      ///
      double Volume(){return volume;}
      ///
      /// ���������� ����� ����� � �������.
      ///
      datetime EntryDate(){return entryDate;}
      ///
      /// ���������� ���� ����� � �������.
      ///
      double EntryPrice(){return entryPrice;}
      ///
      /// ���������� ���� ������ �� �������.
      /// ���������� ����, ���� ������� �������.
      ///
      datetime ExitDate(){return exitDate;}
      ///
      /// ���������� ���� ������ �� �������.
      /// ���������� ����, ���� ������� �������.
      ///
      double ExitPrice(){return exitPrice;}
      ///
      /// ���������� ������� �������� ��������� �������.
      ///
      double StopLoss(){return stopLoss;}
      ///
      /// ���������� ������� ������ ������� �������.
      ///
      double TakeProfit(){return takeProfit;}
      ///
      /// ���������� ������� ���� �����������, �� �������� ������� �������
      ///
      double CurrentPrice()
      {
         double last_price;
         if(type == POSITION_TYPE_BUY)
            last_price = SymbolInfoDouble(symbol, SYMBOL_BID);
         else
            last_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
         return last_price;
      }
      ///
      /// ���������� ����������� ���� �������.
      ///
      double Swap(){return swap;}
      ///
      /// ���������� ������� �������.
      ///
      double Profit()
      {
         if(type == POSITION_TYPE_BUY)
         {
            return CurrentPrice() - EntryPrice();
         }
         if(type == POSITION_TYPE_SELL)
         {
            return EntryPrice() - CurrentPrice();
         }
         return 0.0;
      }
      ///
      /// ���������� ����������� ������� ��� ������ ��� �������� �������.
      ///
      string EntryComment(){return entryComment;}
      ///
      /// ���������� ����������� ������� ��� ������ ��� �������� �������.
      ///
      string ExitComment(){return exitComment;}
      ///
      /// ������ ������ ��������� �������.
      ///
      Position* ListOpenDeals;
      ///
      /// ������ ������ ��������� ����������� �������.
      ///
      Position* ListClosedDeals;
   private:
      ///
      /// ������� ����� �������� �������.
      ///
      void Init(ulong in_ticket)
      {
         LoadHistory();
         if(!HistoryOrderSelect(in_ticket))
         {
            LogWriter("History position not find", MESSAGE_TYPE_ERROR);
            return;            
         }
         status = POSITION_STATUS_OPEN;
         magic = HistoryOrderGetInteger(in_ticket, ORDER_MAGIC);
         entryOrderId = in_ticket;
         symbol = HistoryOrderGetString(in_ticket, ORDER_SYMBOL);
         volume = HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_INITIAL) - HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_CURRENT);
         entryDate = (datetime)HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE);
         entryPrice = HistoryOrderGetDouble(in_ticket, ORDER_PRICE_OPEN);
         entryComment = HistoryOrderGetString(in_ticket, ORDER_COMMENT);
      }
      ///
      /// ��������� ������� �������
      ///
      void LoadHistory(void)
      {
         HistorySelect(D'1970.01.01', TimeCurrent());
      }
      ENUM_POSITION_STATUS status;
      ENUM_POSITION_TYPE type;
      long magic;
      string symbol;
      ulong entryOrderId;
      ulong exitOrderId;
      double volume;
      datetime entryDate;
      double entryPrice;
      datetime exitDate;
      double exitPrice;
      double stopLoss;
      double takeProfit;
      double swap;
      double profit;
      string entryComment;
      string exitComment;
};