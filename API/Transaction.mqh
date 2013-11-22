#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include "..\Time.mqh"
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
   TRANS_DEAL
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
         return 0.0;
      }
   protected:
      Transaction(ENUM_TRANSACTION_TYPE trType){transType = trType;}
      ///
      /// �������� ���������� ������������� ����������.
      ///
      ulong GetId(){return currId;}
      ///
      /// ������������� ���������� ������������� ����������.
      ///
      void SetId(ulong id){currId = id;}
      ///
      /// ������� ���������� ����, �� ������� ���� ��������� ������, ���� ����, �� ������� ���� ����������� ������������ ������.
      /// \param isPending - ������, ���� ����� ���������� ������ ����� ����������, �������� �������, � ����, ���� ����� ��� ��������,
      /// � ���������� � ��� ���������� ������ � ������ ������������ �������.
      double Price(bool isPending = false)
      {
         double price = 0.0;
         if(!isPending){
            SelectHistoryTransaction();
            switch(transType)
            {
               case TRANS_DEAL:
                  return HistoryDealGetDouble(currId, DEAL_PRICE);
               case TRANS_POSITION:
                  return HistoryOrderGetDouble(currId, ORDER_PRICE_OPEN);
               default:
                  return 0.0;
            }
         }
         else
         {
            SelectPendingTransaction();
            switch(transType)
            {
               case TRANS_POSITION:
                  return OrderGetDouble(ORDER_PRICE_OPEN);
               // ����������� ����� ���� ������ ������, ������� ������ �������� ��������
               // ������ � �������� ������� ������������.
               default:
                  return 0.0;
            }
         }
      }
      ///
      /// ���������� ����� ������������ ������/���������� ������.
      ///
      CTime* TimeExecuted()
      {
         CTime* ctime = NULL;
         SelectHistoryTransaction();
         if(transType == TRANS_POSITION)
         {
            long msc = HistoryOrderGetInteger(currId, ORDER_TIME_DONE_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
         if(transType == TRANS_DEAL)
         {
            long msc = HistoryDealGetInteger(currId, DEAL_TIME_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
         return NULL;
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
         if(transType == TRANS_POSITION)
            OrderSelect(currId);
      }
      ///
      /// ���������� ������ � ������� �����������.
      ///
      double ProfitInPips(double entryPrice, double exitPrice, double vol, string m_smb)
      {
         return 0.0;
      }
      ///
      /// ���������� ������ � ���� ���������� �������������.
      ///
      string ProfitAsString()
      {
         return "";
      }
      
   private:
      
      ///
      /// ��������� ������� ������� � ������.
      ///
      void LoadHistory(void)
      {
         HistorySelect(D'1970.01.01', TimeCurrent());
      }
      ///
      /// ��� ����������.
      ///
      ENUM_TRANSACTION_TYPE transType;
      ///
      /// ������� ������������� ����������, � ������� �������� �������.
      ///
      ulong currId;
      ///
      /// ������, �� �������� ��������� ��������� (������������ ��� ������������������).
      ///
      string symbol;
};

///
/// ������ �������/������.
///
enum ENUM_POSITION_STATUS
{
   ///
   /// ������� �� ����������.
   ///
   POSITION_STATUS_NULL,
   ///
   /// ������� �������.
   ///
   POSITION_STATUS_OPEN,
   ///
   /// ������� �������.
   ///
   POSITION_STATUS_CLOSED,
   ///
   /// ������� ��������.
   ///
   POSITION_STATUS_PENDING
};

///
/// ����� ������������ �������.
///
class Position : Transaction
{
   public:
      ///
      /// ���������� ���������� �������.
      ///
      Position(ulong in_ticket) : Transaction(TRANS_POSITION)
      {
         InitPosition(in_ticket);
      }
      ///
      /// ���������� �������� �������.
      ///
      Position(ulong in_ticket, CArrayLong* in_deals) : Transaction(TRANS_POSITION)
      {
         InitPosition(in_ticket, in_deals);
      }
      ///
      /// ���������� ����������� �������.
      ///
      Position(ulong in_ticket, CArrayLong* in_deals, ulong out_ticket, CArrayLong* out_deals) : Transaction(TRANS_POSITION)
      {
         InitPosition(in_ticket, in_deals);
      }
      ///
      /// ���������� ���������� ����� �������/������.
      ///
      virtual ulong Magic()
      {
         Context(TRANS_IN);
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return OrderGetInteger(ORDER_MAGIC);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            return HistoryOrderGetInteger(GetId(), ORDER_MAGIC);
         }
         return 0;
      }
      ///
      /// ���������� �������� �������, �� �������� ���� ��������� ������.
      ///
      virtual string Symbol()
      {
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return OrderGetString(ORDER_SYMBOL);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            return HistoryOrderGetString(GetId(), ORDER_SYMBOL);
         }
         return "";
      }
      
      ///
      /// ���������� ��� �������.
      ///
      ENUM_ORDER_TYPE PositionType()
      {
         Context(TRANS_IN);
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            return (ENUM_ORDER_TYPE)HistoryOrderGetInteger(GetId(), ORDER_TYPE);
         }
         return (ENUM_ORDER_TYPE)0;
      }
      ///
      /// ���������� ������ �������.
      ///
      ENUM_POSITION_STATUS PositionStatus()
      {
         return posStatus;
      }
      ///
      /// ����������� ����� � �������.
      ///
      string EntryComment()
      {
         Context(TRANS_IN);
         return GetComment();
      }
      ///
      /// ����������� ����� � �������.
      ///
      string ExitComment()
      {
         Context(TRANS_OUT);
         return GetComment();
      }
      ///
      /// ���������� ������������� ������, ������������ �������.
      ///
      ulong EntryOrderId()
      {
         Context(TRANS_IN);
         return GetId();
      }
      ///
      /// ���������� ������������� ������, ������������ �������.
      ///
      ulong ExitOrderId()
      {
         Context(TRANS_OUT);
         return GetId();
      }
      ///
      /// ���������� ����, �� ������� ��� �������� ����� �� ���� � �������.
      ///
      double EntryPricePlaced()
      {
         Context(TRANS_IN);
         return GetPricePlaced();
      }
      ///
      /// ���������� ����, �� ������� ��� �������� ����� �� ����� �� �������.
      ///
      double ExitPricePlaced()
      {
         Context(TRANS_OUT);
         return GetPricePlaced();
      }
      ///
      /// ���������� ����� ��������� ������.
      ///
      CTime* EntrySetupDate()
      {
         Context(TRANS_IN);
         return SetupTime();
      }
      ///
      /// ���������� ����� ��������� ������.
      ///
      CTime* ExitSetupDate()
      {
         // ���� ������� ��� �� ���������, �� � ������� ���������� ������������
         // �� ������ � ��� ���.
         if(POSITION_STATUS_CLOSED)
         {
            Context(TRANS_OUT);
            return SetupTime();
         }
         else return NULL;
      }
      ///
      /// ���������� ����� ������������ ���������� ������. �����, ��� ����� ���������� ����������, ������ ���� �����������.
      ///
      CTime* EntryExecutedDate()
      {
         Context(TRANS_IN);
         if(posStatus == POSITION_STATUS_NULL || posStatus == POSITION_STATUS_PENDING)return NULL;
         return TimeExecuted();
      }
      ///
      /// ���������� ����� ������������ ������ �� �������. ������� ������ ���� �������.
      ///
      CTime* ExitExecutedDate()
      {
         Context(TRANS_OUT);
         if(posStatus == POSITION_STATUS_NULL ||
            posStatus != POSITION_STATUS_CLOSED)return NULL;
         return TimeExecuted();
      }
      ///
      /// ���������� �������������� ����������� �����
      ///
      double VolumeInit()
      {
         Context(TRANS_IN);
         double vol = 0.0;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            vol = OrderGetDouble(ORDER_VOLUME_INITIAL);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            vol = HistoryOrderGetDouble(GetId(), ORDER_VOLUME_INITIAL);
         }
         return vol;
      }
      ///
      /// ������������� ����� ������.
      ///
      double VolumeReject()
      {
         Context(TRANS_IN);
         double vol = 0.0;
         //�� �������� ������� �� ����������� �� ����� ������������� ������ ?
         //if(posStatus == NULL || posStatus == POSITION_STATUS_PENDING)return 0;
         if(posStatus == NULL)return vol;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            vol = OrderGetDouble(ORDER_VOLUME_CURRENT);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            vol = HistoryOrderGetDouble(GetId(), ORDER_VOLUME_CURRENT);
         }
         return vol;
      }
      ///
      /// ����������� ����� �������.
      ///
      double VolumeExecuted()
      {
         return VolumeInit() - VolumeReject();
      }
      ///
      /// ���������� ������� ���� �����������, �� �������� ��������� ����������.
      ///
      virtual double CurrentPrice()
      {
         double price = 0.0;
         //����� ���� � ���������?
         if(PositionType() % 2 == 0)
            price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         else
            price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         return price;
      }
      
      ///
      /// ���������� ������, ���� ������������ ����-����.
      ///
      bool UsingStopLoss()
      {
         if(CheckPointer(stopLoss) != POINTER_INVALID)return true;
         return false;
      }
      ///
      /// ���������� ������, ���� ������������ ����-������.
      ///
      bool UsingTakeProfit()
      {
         if(CheckPointer(takeProfit) != POINTER_INVALID)return true;
         return false;
      }
      ///
      /// ������������� ����� ������� �������� ��������� stoploss.
      ///
      void SetStopLoss(double level)
      {
         ;
      }
      ///
      /// ������������� ����� ������� ������ ������� takeprofit.
      ///
      void SetTakeProfit(double level)
      {
         ;
      }
      ///
      /// ������� �������� ��������� stoploss.
      ///
      void DeleteStopLoss()
      {
         ;
      }
      ///
      /// ������� ������� ������ ������� takeprofit.
      ///
      void DeleteTakeProfit()
      {
         ;
      }
   private:
      enum ENUM_TRANSACTION_CONTEXT
      {
         TRANS_IN,
         TRANS_OUT
      };
      ///
      /// �������������� ����� ������� �������
      ///
      void InitPosition(ulong in_ticket, CArrayLong* in_deals = NULL, ulong out_ticket = 0, CArrayLong* out_deals = NULL)
      {
         if(in_ticket == 0) return;
         if(in_deals == NULL || in_deals.Total() == 0)
            posStatus = POSITION_STATUS_PENDING;
         else if(out_ticket == 0 || out_deals == NULL)
            posStatus = POSITION_STATUS_OPEN;
         else if(out_deals.Total() != 0)
            posStatus = POSITION_STATUS_CLOSED;
         inOrderId = in_ticket;
         
         //��������� ������ ������������� ������.
         if(posStatus == POSITION_STATUS_OPEN ||
            posStatus == POSITION_STATUS_CLOSED)
         {
            for(int i = 0; i < in_deals.Total(); i++)
            {
               ulong id = in_deals.At(i);
               Deal* deal = new Deal(id);
               entryDeals.Add(deal);
            }
         }
         //��������� ������ ������������ ������.
         if(posStatus == POSITION_STATUS_CLOSED)
         {
            for(int i = 0; i < out_deals.Total(); i++)
            {
               ulong id = out_deals.At(i);
               Deal* deal = new Deal(id);
               exitDeals.Add(deal);
            }
         }
      }
      
      ///
      /// ���������� ����� ��������� ������������/������������ ������. ���� ����� ��������� ������ �� ��������, ��������, ����� �� ���������������,
      /// ����� ���������� NULL.
      ///
      CTime* SetupTime()
      {
         CTime* ctime = NULL;
         if(posStatus == POSITION_STATUS_NULL)return ctime;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            long msc = OrderGetInteger(ORDER_TIME_SETUP_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
         else
         {
            SelectHistoryTransaction();
            long msc = HistoryOrderGetInteger(GetId(), ORDER_TIME_SETUP_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
      }
      ///
      /// �������� �����������, ��������������� � ������� �������.
      ///
      string GetComment()
      {
         if(posStatus == POSITION_STATUS_NULL)return "not def.";
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return OrderGetString(ORDER_COMMENT);
         }
         else
         {
            SelectHistoryTransaction();
            return HistoryOrderGetString(GetId(), ORDER_COMMENT);
         }
      }
      ///
      /// ���������� ����, �� ������� ��� �������� �����.
      ///
      double GetPricePlaced()
      {
         if(posStatus != POSITION_STATUS_PENDING)
            return Price();
         else
            return Price(true);
      }
      ///
      /// ������������� �������� - ������������� �������� ��� ��������� ����������, � ������� ������������ ������.
      ///
      void Context(ENUM_TRANSACTION_CONTEXT context)
      {
         currContext = context;
         ulong id = currContext == TRANS_IN ? inOrderId : outOrderId;
         SetId(id);
      }
      ///
      /// ���������� ������� ��������.
      ///
      ENUM_TRANSACTION_CONTEXT Context(){return currContext;}
      ///
      /// ������ �������.
      ///
      ENUM_POSITION_STATUS posStatus;
      ///
      /// ������� ������������� ��������.
      ///
      ENUM_TRANSACTION_CONTEXT currContext;
      ///
      /// ���������� ������������� ������, ������������ ������.
      ///
      ulong inOrderId;
      ///
      /// ���������� ������������� ������, ������������ ������.
      ///
      ulong outOrderId;
      ///
      /// ��������� � ���� �������� ������ �������, �������������� �������� ��������� stoploss.
      ///
      Position* stopLoss;
      ///
      /// ��������� � ���� �������� ������ �������, �������������� ������� ������ ������� takeprofit.
      ///
      Position* takeProfit;
      ///
      /// �������� ������ ������������ ����� �� �������.
      ///
      CArrayObj entryDeals;
      ///
      /// �������� ������ ������������ ����� �� �������.
      ///
      CArrayObj exitDeals;
   
};

class Deal : Transaction
{
   public:
      Deal(ulong inId) : Transaction(TRANS_DEAL)
      {
         SetId(inId);
      }
      ///
      /// ���������� ���������� ������������� ��������, �������� ����������� ������ ������.
      ///
      virtual ulong Magic()
      {
         SelectHistoryTransaction();
         return HistoryDealGetInteger(GetId(), DEAL_MAGIC);
      }
      ///
      /// ���������� �������� �������, �� �������� ���� ��������� ������.
      ///
      virtual string Symbol()
      {
         SelectHistoryTransaction();
         return HistoryDealGetString(GetId(), DEAL_SYMBOL);
      }
      ///
      /// ���������� ��� ������.
      ///
      ENUM_DEAL_TYPE DealType()
      {
         SelectHistoryTransaction();
         return (ENUM_DEAL_TYPE)HistoryDealGetInteger(GetId(), DEAL_TYPE);
      }
      ///
      /// ���������� ����, �� ������� ���� ��������� ������.
      ///
      double PriceExecuted()
      {
         return Price();
      }
      ///
      /// ���������� ����� ���������� ������.
      ///
      CTime* DateExecuted()
      {
         return TimeExecuted();
      }
      ///
      /// ���������� ���������� ������������� ������.
      ///
      ulong DealId(){return GetId();}
      ///
      /// ����� ������.
      ///
      double VolumeExecuted()
      {
         SelectHistoryTransaction();
         return HistoryDealGetDouble(GetId(), DEAL_VOLUME);
      }
      ///
      /// ���������� ����������� � ������.
      ///
      string Comment()
      {
         SelectHistoryTransaction();
         return HistoryDealGetString(GetId(), DEAL_COMMENT);
      }
      ///
      /// ���������� ������� ���� �����������, �� �������� ��������� ������.
      ///
      virtual double CurrentPrice()
      {
         double price = 0.0;
         if(DealType() == DEAL_TYPE_BUY)
            price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         if(DealType() == DEAL_TYPE_SELL)
            price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         return price;
      }
};

/*void foo()
{
   Transaction trans = new Transaction(TRANS_POSITION);
   //trans.
}*/


