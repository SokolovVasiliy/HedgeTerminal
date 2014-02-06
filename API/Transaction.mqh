#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Trade\Trade.mqh>
#include "..\Time.mqh"

class Position;
class Deal;
class Order;
#ifdef HEDGE_PANEL
class PosLine;
#endif

///
/// ��������, �� ������� ����� ���� ������������ ������ �������.
///
enum ENUM_SORT_TRANSACTION
{
   ///
   /// ���������� �� ����������� ������.
   ///
   SORT_MAGIC,
   ///
   /// ���������� �� ����������� �������������� ����������, ����������� �� ������� GetId().
   ///
   SORT_ORDER_ID,
   ///
   /// ���������� �� ���������� ������ ������� ��� ������ ������������ ������.
   ///
   SORT_EXIT_ORDER_ID,
   ///
   /// ���������� �� ������� ���������� ������, ����������� ������, ������������� �������.
   ///
   SORT_TIME,
   ///
   /// 
   ///
   SORT_EXIT_TIME
};

//#include "..\Elements\TablePositions.mqh"
///
/// ��� ����������.
///
enum ENUM_TRANSACTION_TYPE
{
   ///
   /// ���������� �������� ��������.
   ///
   TRANS_POSITION,
   ///
   /// ���������� �������� �������.
   ///
   TRANS_ORDER,
   ///
   /// ���������� �������� �������.
   ///
   TRANS_DEAL
};

///
/// ����������� � ������� ��������� ����������.
///
enum ENUM_DIRECTION_TYPE
{
   DIRECTION_NDEF,
   DIRECTION_LONG,
   DIRECTION_SHORT
};

///
/// ������������� ����������� ����������: ������, �����, ���� ����� ������ �������� �� �����.
///
class Transaction : public CObject
{
   public:
      ///
      /// ���������� ��� ����������.
      ///
      ENUM_TRANSACTION_TYPE TransactionType(){return transType;}
      
      ///
      /// ���������� �������� �������, �� �������� ���� ��������� ������.
      ///
      virtual string Symbol()
      {
         return symbol;
      }
      ///
      /// ���������� ���������� ����� ��������, �������� ����������� ������ ����������.
      ///
      virtual ulong Magic()
      {
         return 0;
      }
      ///
      /// ���������� ������� ���� �����������, �� �������� ��������� ����������.
      ///
      virtual double CurrentPrice()
      {
         double price = 0.0;
         //����� ���� � ���������?
         if(Direction() == DIRECTION_LONG)
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_BID);
         else if(Direction() == DIRECTION_SHORT)
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_ASK);
         else
            price = 0.0;
         return price;
      }
      
      ///
      /// ���������� ����������� ����������� ����� ����������.
      ///
      virtual double VolumeExecuted()
      {
         return 0.0;
      }
      ///
      /// ���������� ������ � ������� �����������.
      ///
      virtual double ProfitInPips()
      {
         double delta = CurrentPrice() - EntryExecutedPrice();
         if(direction == DIRECTION_SHORT)
            delta *= -1.0;
         return delta;
      }
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         return direction;
      }
      ///
      /// ���������� ������ � ���� ���������� �������������.
      ///
      string ProfitAsString()
      {
         double d = ProfitInPips();
         int digits = (int)SymbolInfoInteger(this.Symbol(), SYMBOL_DIGITS);
         double point = SymbolInfoDouble(this.Symbol(), SYMBOL_POINT);
         string points = point == 0 ? "0p." : DoubleToString(d/point, 0) + "p.";
         return points;
      }
      ///
      /// ���������� ���� ����������� � ���� ������.
      ///
      string PriceToString(double price)
      {
         int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
         string sprice = DoubleToString(price, digits);
         return sprice;
      }
      string VolumeToString(double vol)
      {
         double step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
         double mylog = MathLog10(step);
         string svol = mylog < 0 ? DoubleToString(vol,(int)(mylog*(-1.0))) : DoubleToString(vol, 0);
         return svol;
      }
      ///
      /// ���������� ���������� ������ ����� ������� � ���� �����������, �� �������� ���� ��������� ����������.
      ///
      int InstrumentDigits()
      {
         return (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
      }
      ///
      /// �������������� ���������.
      ///
      virtual int Compare(const CObject *node, const int mode=0)
      {
         const Transaction* myTrans = node;
         ulong nodeValue = myTrans.GetCompareValueInt((ENUM_SORT_TRANSACTION)mode);
         ulong myValue = GetCompareValueInt((ENUM_SORT_TRANSACTION)mode);
         if(myValue > nodeValue)return GREATE;
         if(myValue < nodeValue)return LESS;
         return EQUAL;
      }
      
      virtual ulong GetCompareValueInt(ENUM_SORT_TRANSACTION sortType)
      {
         switch(sortType)
         {
            case SORT_MAGIC:
               return Magic();
            case SORT_ORDER_ID:
            default:
               return currId;
         }
         return 0;
      }
      ///
      /// �������� ���������� ������������� ����������.
      ///
      ulong GetId(){return currId;}
      
      ///
      /// ���������� ��� ���������� � ���� ������.
      ///
      virtual string TypeAsString()
      {
         return "transaction";
      }
   protected:
      ///
      /// ���������� ���� ����� ���������� �� �����.
      ///
      virtual double EntryExecutedPrice(){return 0.0;}
      ///
      /// ���������� ��� ����������.
      ///
      Transaction(ENUM_TRANSACTION_TYPE trType){transType = trType;}
      
      ///
      /// ������������� ���������� ������������� ����������.
      ///
      void SetId(ulong id){currId = id;}
      
      ///
      /// ���������� ����� ������������ ������/���������� ������.
      ///
      virtual long TimeExecuted()
      {
         CTime* ctime = NULL;
         SelectHistoryTransaction();
         if(transType == TRANS_POSITION)
         {
            long msc = HistoryOrderGetInteger(currId, ORDER_TIME_DONE_MSC);
            return msc;
            //ctime = new CTime(msc);
            //return ctime;
         }
         if(transType == TRANS_DEAL)
         {
            long msc = HistoryDealGetInteger(currId, DEAL_TIME_MSC);
            return msc;
            //ctime = new CTime(msc);
            //return ctime;
         }
         return 0;
      }
      ///
      /// �������� ������� ���������� ��� ���������� ������ � ���.
      ///
      void SelectHistoryTransaction()
      {
         LoadHistory();
         if(transType == TRANS_DEAL)
            HistoryDealSelect(currId);
         if(transType == TRANS_POSITION)
            HistoryOrderSelect(currId);
      }
      ///
      /// �������� ������� ���������� ��� ���������� ������ � ���.
      ///
      void SelectPendingTransaction()
      {
         if(transType == TRANS_ORDER ||
            transType == TRANS_POSITION)
            OrderSelect(currId);   
      }
      
      /*��� �������� ���������, ���������� ����� ������������ ����, ������� � ���������� ����� ���������*/
      ///
      /// ������� ����������� ���� �� ������� ���� ��������� ������/����������.
      ///
      double entryPriceExecuted;
      ///
      /// ������, ���� ���� ���������� ���������� ���� ����������.
      ///
      bool isEntryPriceExecuted;
      ///
      /// ������, �� �������� ��������� ��������� (������������ ��� ������������������).
      ///
      string symbol;
      ///
      /// ������, ���� �������� ����������� ���� �������� ����� � ���������.
      ///
      bool isSymbol;
      ///
      /// ��������� ������� ������� � ������, ���� ��� �� ���������.
      ///
      void LoadHistory(void)
      {
         if(HistoryDealsTotal() < 2)
            HistorySelect(D'1970.01.01', TimeCurrent());
      }
      ENUM_DIRECTION_TYPE direction;
   private:
      ///
      /// ��� ����������.
      ///
      ENUM_TRANSACTION_TYPE transType;
      ///
      /// ������� ������������� ����������, � ������� �������� �������.
      ///
      ulong currId; 
};

//#include "Position.mqh"
//#include "Deal.mqh"
#include "Deal.mqh"
#include "Order.mqh"
#include "Position.mqh"
#include "Tasks.mqh"


