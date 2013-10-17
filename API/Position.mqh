#include <Object.mqh>
#include "..\Time.mqh"
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
///
/// ������ �������/������.
///
enum ENUM_POSITION_STATUS
{
   ///
   /// ������� �������.
   ///
   POSITION_STATUS_OPEN,
   ///
   /// ������� �������.
   ///
   POSITION_STATUS_CLOSED
};

///
/// ��������� ����� ���������� ������ �������.
///
enum ENUM_POSITION_SORT
{
   POSITION_SORT_MAGIC,
   POSITION_SORT_SYMBOL,
   POSITION_SORT_ENTRY_ORDERID,
   POSITION_SORT_ENTRY_DATE,
   POSITION_SORT_ENTRY_PRICE,
   POSITION_SORT_ENTRY_COMMENT,
   POSITION_SORT_EXIT_ORDERID,
   POSITION_SORT_EXIT_PRICE,
   POSITION_SORT_EXIT_DATE,
   POSITION_SORT_EXIT_COMMENT,
   POSITION_SORT_TYPE,
   POSITION_SORT_VOL,
   POSITION_SORT_STOPLOSS,
   POSITION_SORT_TAKEPROFIT,
   POSITION_SORT_LASTPRICE,
   POSITION_SORT_PROFIT,
   POSITION_SORT_SWAP
};
///
/// ��������� ������� �������
///
void LoadHistory(void)
{
   HistorySelect(D'1970.01.01', TimeCurrent());
}

class Deal : CObject
{
   public:
      ///
      /// ������� ����� ������ � ��������� �� ���������, �� ������ �� ������ ������.
      ///
      Deal(ulong dticket)
      {
         date = new CTime();
         LoadHistory();
         if(!HistoryDealSelect(dticket))
         {
            LogWriter("Deal with ticket #" + (string)dticket + " not find.", MESSAGE_TYPE_ERROR);
            return;
         }
         ticket = dticket;
         volume = HistoryDealGetDouble(dticket, DEAL_VOLUME);
         date = HistoryDealGetInteger(dticket, DEAL_TIME_MSC);
         price = HistoryDealGetDouble(dticket, DEAL_PRICE);
         commission = HistoryDealGetDouble(dticket, DEAL_COMMISSION);
         type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dticket, DEAL_TYPE);
         symbol = HistoryDealGetString(dticket, DEAL_SYMBOL);
         comment = HistoryDealGetString(dticket, DEAL_COMMENT);
      }
      ~Deal()
      {
         delete date;
      }
      ulong Ticket(){return ticket;}
      CTime* Date(){return date;}
      double Volume(){return volume;}
      double Comission(){return commission;}
      double Price(){return price;}
      ENUM_DEAL_TYPE DealType(){return type;}
      string Symbol(){return symbol;}
      ///
      /// ���������� ������� ������.
      ///
      double Profit()
      {
         double profit;
         switch(type)
         {
            case DEAL_TYPE_BUY:
               return CurrentPrice() - Price();
            case DEAL_TYPE_SELL:
               return Price() - CurrentPrice();
            default:
                HistoryDealSelect(ticket);
                profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                return profit;
         }
         return 0.0;
      }
      ///
      /// ���������� ������� ���� �����������, �� �������� ������� �������
      ///
      double CurrentPrice()
      {
         double last_price;
         //������ �������� - �������, �������� - �������.
         if(type == DEAL_TYPE_BUY)
            last_price = SymbolInfoDouble(symbol, SYMBOL_BID);
         else
            last_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
         return last_price;
      }
      ///
      /// ������������ ������ ������� � ��������� ������������� �������
      ///
      string ProfitAsString()
      {
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
         double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
         string points = DoubleToString(Profit()/point, 0) + "p.";
         return points;
      }
   private:
      ///
      /// ���������� ������������� ������.
      ///
      ulong ticket;
      ///
      /// ����� ���������� ������.
      ///
      CTime* date; 
      ///
      /// ����� ����������� ������.
      ///
      double volume;
      ///
      /// ����, �� ������� ���� ��������� ������.
      ///
      double price;
      ///
      /// �������� �� ������.
      ///
      double commission;
      ///
      /// ��� ������.
      ///
      ENUM_DEAL_TYPE type;
      ///
      /// ��� �������, �� ������� ����������� ������.
      ///
      string symbol;
      ///
      /// ����������� � ������.
      ///
      string comment;
};
///
/// �������.
///
class Position : CObject
{
   public:
      
      Position(ulong in_ticket, CArrayLong* in_deals, ulong out_ticket, CArrayLong* out_deals)
      {
         Init();
      }
      Position(ulong in_ticket, CArrayLong* in_deals)
      {
         Init();
         InitPosition(in_ticket, in_deals);
      }
      ~Position()
      {
         delete entryDate;
         delete exitDate;
         int total = entryDeals.Total();
         for(int i = 0; i < total; i++)
         {
            Deal* deal = entryDeals.At(i);
            delete deal;
         }
         entryDeals.Clear();
         for(int i = 0; i < exitDeals.Total(); i++)
         {
            Deal* deal = exitDeals.At(i);
            delete deal;
         }
         exitDeals.Clear();
      }
      ///
      /// ���������� ������ �������.
      ///
      ENUM_POSITION_STATUS Status(){return status;}
      ///
      /// ���������� ����������� �������.
      ///
      ENUM_ORDER_TYPE PositionType(){return type;}
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
      CTime* EntryDate(){return entryDate;}
      ///
      /// ���������� ���� ����� � �������.
      ///
      double EntryPrice(){return entryPrice;}
      ///
      /// ���������� ���� ������ �� �������.
      /// ���������� ����, ���� ������� �������.
      ///
      CTime* ExitDate(){return exitDate;}
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
         //������ �������� - �������, �������� - �������.
         if(type % 2 == 0)
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
         switch(type)
         {
            case ORDER_TYPE_BUY:
            case ORDER_TYPE_BUY_STOP:
            case ORDER_TYPE_BUY_LIMIT:
            case ORDER_TYPE_BUY_STOP_LIMIT:
               return CurrentPrice() - EntryPrice();
            default:
               return EntryPrice() - CurrentPrice();   
         }
         return 0.0;
      }
      ///
      /// ������������ ������ ������� � ��������� ������������� �������
      ///
      string ProfitAsString()
      {
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
         double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
         string points = DoubleToString(Profit()/point, 0) + "p.";
         return points;
      }
      ///
      /// ���������� ����������� ������� ��� ������ ��� �������� �������.
      ///
      string EntryComment(){return entryComment;}
      ///
      /// ���������� ����������� ������� ��� ������ ��� �������� �������.
      ///
      string ExitComment(){return exitComment;}
      CArrayObj* EntryDeals()
      {
         return GetPointer(entryDeals);
      }
      CArrayObj* ExitDeals()
      {
         return GetPointer(exitDeals);
      }
      virtual int Compare(const CObject *node,const int mode=0) const
      {
         const Position* pos = node;
         int LESS = -1;
         int GREATE = 1;
         int EQUAL = 0;
         switch(mode)
         {
            case POSITION_SORT_ENTRY_ORDERID:
               if(entryOrderId > pos.EntryOrderID())
                  return GREATE;
               if(entryOrderId > pos.EntryOrderID())
                  return LESS;
               if(entryOrderId == pos.EntryOrderID())
                  return EQUAL;
               break;
            case POSITION_SORT_ENTRY_DATE:
               if(entryDate > pos.EntryDate())
                  return GREATE;
               if(entryDate > pos.EntryDate())
                  return LESS;
               if(entryDate == pos.EntryDate())
                  return EQUAL;
               break;
            default:
               return 0;
         }
         return 0;
      }
   private:
      ///
      /// ������� ����� �������� �������.
      ///
      void InitPosition(ulong in_ticket, CArrayLong* deals)
      {
         LoadHistory();
         if(!HistoryOrderSelect(in_ticket))
         {
            LogWriter("History position not find", MESSAGE_TYPE_ERROR);
            return;            
         }
         magic = HistoryOrderGetInteger(in_ticket, ORDER_MAGIC);
         entryOrderId = in_ticket;
         symbol = HistoryOrderGetString(in_ticket, ORDER_SYMBOL);
         //������ ���� �����
         double best_price = HistoryOrderGetDouble(in_ticket, ORDER_PRICE_OPEN);
         // ���� ������� ����� ������, �� �� ��� �������� �� sell ��� buy, �
         // ����� � ����� ����� �������� �� ������.
         ENUM_ORDER_TYPE op_type = (ENUM_ORDER_TYPE)HistoryOrderGetInteger(in_ticket, ORDER_TYPE);
         if(deals != NULL && deals.Total()>0)
         {
            switch(op_type)
            {
               case ORDER_TYPE_BUY:
               case ORDER_TYPE_BUY_STOP:
               case ORDER_TYPE_BUY_LIMIT:
               case ORDER_TYPE_BUY_STOP_LIMIT:
                  type = ORDER_TYPE_BUY;
                  break;
               default:
                  type = ORDER_TYPE_SELL;
            }
            //��� �������� � �������� ������� ������ ���� ������� � ������. 
            //���� ������ ���� �� �������, ���� ������������ ��������
            //������, ������ ���� ����� �������� �������� ������.
            bool find = (NormalizeDouble(best_price, 6) == 0.000000) ||
                        (op_type == ORDER_TYPE_BUY_LIMIT) || (op_type == ORDER_TYPE_SELL_LIMIT);
            //������ ������ ������������ � ������ ������.
            int total = deals.Total();
            for(int i = 0; i < total; i++)
            {
               ulong dticket = deals.At(i);
               Deal* cdeal = new Deal(dticket);
               entryDeals.Add(cdeal);
               volume += cdeal.Volume();
               //���� ����� ������ ����� ���������� ������ ������
               entryDate = HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE_MSC);
               /*if(op_type == ORDER_TYPE_BUY || op_type == ORDER_TYPE_SELL)
               {
                  entryDate = HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE_MSC);
               }
               else if(i == 0)entryDate.operator=(cdeal.Date());
               else if(entryDate > cdeal.Date())
                  entryDate.operator=(cdeal.Date());
               */
               //entryDate.operator<(cdeal.Date());
               //���� ����� �������� ���� ������
               if(find && type == ORDER_TYPE_BUY)
               {
                  if(i == 0)best_price = cdeal.Price();
                  else if(cdeal.Price() < best_price)
                     best_price = cdeal.Price();
               }
               else if(find && type == ORDER_TYPE_SELL)
               {
                  if(i == 0)best_price = cdeal.Price();
                  else if(cdeal.Price() > best_price)
                     best_price = cdeal.Price();
               }
            }
         }
         //����� ���� � ����������� ��������
         else
         {
            volume = HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_INITIAL) - HistoryOrderGetDouble(in_ticket, ORDER_VOLUME_CURRENT);
            entryDate = HistoryOrderGetInteger(in_ticket, ORDER_TIME_DONE) * 1000;
         }
         entryPrice = best_price;
         entryComment = HistoryOrderGetString(in_ticket, ORDER_COMMENT);
         type = op_type;
      }
      
      void ClosePosition()
      {
         ;
      }
      void Init()
      {
         entryDate = new CTime();
         exitDate = new CTime();
      }
      ENUM_POSITION_STATUS status;
      ENUM_ORDER_TYPE type;
      long magic;
      string symbol;
      ulong entryOrderId;
      ulong exitOrderId;
      double volume;
      ///
      /// ����� ����� � �������.
      ///
      CTime* entryDate;
      double entryPrice;
      CTime* exitDate;
      double exitPrice;
      double stopLoss;
      double takeProfit;
      double swap;
      double profit;
      string entryComment;
      string exitComment;
      ///
      /// ������ ������, ����������� ������� �������.
      ///
      CArrayObj entryDeals;
      ///
      /// ������ ������, ����������� ������� �������.
      ///
      CArrayObj exitDeals;
};