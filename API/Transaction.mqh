#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Trade\Trade.mqh>
#include "..\Time.mqh"

class COrder;
class Deal;
class Position;
class PosLine;

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
   TRANS_DEAL
};

///
/// ����������� � ������� ��������� ����������.
///
enum ENUM_DIRECTION_TYPE
{
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
         return 0.0;
      }
      ///
      /// ���������� ������ � ������� �����������.
      ///
      virtual double ProfitInPips()
      {
         double delta = 0.0;
         delta = CurrentPrice() - EntryPriceExecuted();
         if(Direction() == DIRECTION_SHORT)
            delta *= -1.0;
         return delta;
      }
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         return DIRECTION_LONG;
      }
      ///
      /// ���������� ������ � ���� ���������� �������������.
      ///
      string ProfitAsString()
      {
         double d = ProfitInPips();
         int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
         double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
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
      virtual int Compare(const CObject *node, const int mode=0) const
      {
         const Transaction* my_order = node;
         int LESS = -1;
         int GREATE = 1;
         int EQUAL = 0;
         switch(mode)
         {
            case SORT_ORDER_ID:
            default:
               if(currId > my_order.GetId())
                  return GREATE;
               if(currId < my_order.GetId())
                  return LESS;
               if(currId == my_order.GetId())
                  return EQUAL;
         }
         return EQUAL;
      }
      ///
      /// �������� ���������� ������������� ����������.
      ///
      ulong GetId(){return currId;}
      
   protected:
      ///
      /// ���������� ���� ����� ���������� �� �����.
      ///
      virtual double EntryPriceExecuted(){return 0.0;}
      ///
      /// ���������� ��� ����������.
      ///
      Transaction(ENUM_TRANSACTION_TYPE trType){transType = trType;}
      
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
class Position : public Transaction
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
         InitPosition(in_ticket, in_deals, out_ticket, out_deals);
      }
      
      Position(ulong in_ticket, CArrayObj* in_deals, ulong out_ticket, CArrayObj* out_deals): Transaction(TRANS_POSITION)
      {
         InitPositionByDeal(in_ticket, in_deals, out_ticket, out_deals);
      }
      ///
      /// ���������� ��������� �� ������ ������������ ������������� �������.
      ///
      PosLine* PositionLine()
      {
         return positionLine;
      }
      ///
      /// ������������� ��������� �� ������ ������������ ������������� �������.
      ///
      void PositionLine(CObject* pLine){positionLine = pLine;}
      ///
      /// ���������� �����������, � ������� ��������� ����������
      ///
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         if(PositionType() % 2 == 0)
            return DIRECTION_LONG;
         return DIRECTION_SHORT;
      }
      ///
      /// ���������� ������ ����������� ��� ����� � �������.
      ///
      CArrayObj* EntryDeals()
      {
         return GetPointer(entryDeals);
      }
      ///
      /// ���������� ������ ����������� ��� ������ �� �������.
      ///
      CArrayObj* ExitDeals()
      {
         return GetPointer(exitDeals);
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
      /// ���������� ���������� ����� �������/������.
      ///
      virtual ulong ExitMagic()
      {
         Context(TRANS_OUT);
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
      /// ��������� ������� ������� ����������.
      ///
      void AsynchClose(string comment = NULL)
      {
         trading.SetAsyncMode(true);
         trading.SetExpertMagicNumber(EntryOrderID());
         if(Direction() == DIRECTION_LONG)
            trading.Sell(VolumeExecuted(), Symbol(), 0.0, 0.0, 0.0, comment);
         else if(Direction() == DIRECTION_SHORT)
            trading.Buy(VolumeExecuted(), Symbol(), 0.0, 0.0, 0.0, comment);
         
      }
      ///
      /// ���������� �������� �������, �� �������� ���� ��������� ������.
      ///
      virtual string Symbol()
      {
         if(isSymbol)return symbol;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            symbol = OrderGetString(ORDER_SYMBOL);
            isSymbol = true;
            return symbol;
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            symbol = HistoryOrderGetString(GetId(), ORDER_SYMBOL);
            isSymbol = true;
            return symbol;
         }
         return "";
      }
      ///
      /// ���������� ������ � ������� �����������.
      ///
      virtual double ProfitInPips()
      {
         
         double delta = 0.0;
         if(posStatus == POSITION_STATUS_NULL ||
            posStatus == POSITION_STATUS_PENDING)
            return 0.0;
         if(posStatus == POSITION_STATUS_OPEN)
            delta = CurrentPrice() - EntryPriceExecuted();
         if(posStatus == POSITION_STATUS_CLOSED)
            delta = ExitPriceExecuted() - EntryPriceExecuted();
         if(Direction() == DIRECTION_SHORT)
            delta *= -1.0;
         return delta;
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
      /// ���������� ��� ������� � ���� ��������� ������.
      ///
      string PositionTypeAsString()
      {
         ENUM_ORDER_TYPE posType = PositionType();
         string type = EnumToString(posType);
         type = StringSubstr(type, 11);
         StringReplace(type, "_", " ");
         //StringReplace(type, "STOP LIMIT", "SL");
         //StringReplace(type, "STOP", "S");
         //StringReplace(type, "LIMIT", "L");
         return type;
         //ORDER_TYPE_
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
      ulong EntryOrderID()
      {
         Context(TRANS_IN);
         return GetId();
      }
      ///
      /// ���������� ������������� ������, ������������ �������.
      ///
      ulong ExitOrderID()
      {
         Context(TRANS_OUT);
         return GetId();
      }
      ///
      /// ���������� ����, �� ������� ��� �������� ���������� ����� �� ���� � �������.
      /// ���� ����� �� ���� � ������� �������� ����� ���������� 0.0.
      ///
      double EntryPricePlaced()
      {
         Context(TRANS_IN);
         return GetPricePlaced();
      }
      ///
      /// ���������� ����, �� ������� ���������� ��������� ������������ ������.
      ///
      virtual double EntryPriceExecuted()
      {
         Context(TRANS_IN);
         return GetPriceExecuted();
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
      /// ���������� ����, �� ������� ���������� ��������� ������������ ������.
      ///
      virtual double ExitPriceExecuted()
      {
         if(posStatus != POSITION_STATUS_CLOSED)return 0.0;
         Context(TRANS_OUT);
         return GetPriceExecuted();
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
         if(posStatus == POSITION_STATUS_PENDING ||
            posStatus == POSITION_STATUS_NULL)
            return 0.0;
         // ����� � �������� � ������������ ������� �����
         // ����� ������� ���� �������� ������.
         int total = entryDeals.Total();
         double total_vol = 0.0;
         for(int i = 0; i < total; i++)
         {
            Deal* deal = entryDeals.At(i);
            total_vol += deal.VolumeExecuted();
         }
         return total_vol;
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
      /// ���������� �������, ��������������� � �������� ���������� StopLoss
      ///
      Position* StopLoss()
      {
         return stopLoss;
      }
      ///
      /// ���������� �������, ��������������� � �������� ���������� TakeProfit
      ///
      Position* TakeProfit()
      {
         return takeProfit;
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
      /// ���������� ������� �������� ��������� stoploss.
      ///
      double StopLossLevel()
      {
         if(CheckPointer(stopLoss) == POINTER_INVALID)return 0.0;
         return stopLoss.EntryPricePlaced();
      }
      ///
      /// ������������� ����� ������� �������� ��������� stoploss.
      ///
      void StopLossLevel(double level)
      {
         ;
      }
      ///
      /// ������������� ����� ������� ������ ������� takeprofit.
      ///
      void TakeProfitLevel(double level)
      {
         ;
      }
      ///
      /// ���������� ������� �������� ��������� takeprofit.
      ///
      double TakeProfitLevel()
      {
         if(CheckPointer(takeProfit) == POINTER_INVALID)return 0.0;
         return takeProfit.EntryPricePlaced();
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
      ///
      /// ��������� ����� �������� ������ � ������ �������� ������.
      ///
      void AddEntryDeal(Deal* deal)
      {
         entryDeals.Add(deal);
      }
      ///
      /// ��������� ����� ��������� ������ � ������ ��������� ������.
      ///
      void AddExitDeal(Deal* deal)
      {
         //�������� ��������� ������ ����� ������ � �������� �������.
         if(posStatus != POSITION_STATUS_CLOSED)return;
         entryDeals.Add(deal);
      }
      ///
      /// ������������ ����� ����� � ��������� ��� ������ � �������.
      ///
      /*void AddOrder1(COrder* order)
      {
         COrder* in_order = order.InOrder();
         //� �������� �������?
         if(posStatus == POSITION_STATUS_OPEN)
         {
            //���� ����� ���� ���������?
            if(in_order != NULL && in_order.OrderId() == EntryOrderID())
            {
               //�������� ������ ����������� �������.
               CArrayObj* deals = order.Deals();
               int total = deals.Total();
               for(int i = 0; i < total;)
               {
                  int index = 0;
                  Deal* out_deal = deals.At(i);
                  if(index == entryDeals.Total())break;
                  for(;index < entryDeals.Total();)
                  {
                     
                  }
                  
                     Deal* in_deal = entryDeals.At(index);
                     //����� ������ ������� ����� �������!!!
                     double vdelta = in_deal.VolumeExecuted() - out_deal.VolumeExecuted(); 
                     //������� ����� ����� ��� ������������ �������.
                     Deal* inDeal = new Deal(in_deal.Ticket());
                     //��� ����� ����� �����
                     in_deal.AddVolume((-1)*out_deal.VolumeExecuted());
                     
                     inDeal.AddVolume((-1)* in_deal);
                     //�������� ������ ��������� ��������� � ������������ �������.
                     //� ��������� �� �������� �������.
                     if(vdelta <= 0.0000)
                     {
                        entryDeals.Delete(index);
                        index++;
                     } 
                     // ����� ��������� ��������� �����.
                     else
                     {
                        i++;
                     }
                  
               }
               //������� ������� ���������? - ����� ��� �� ����� ������������.
               if(entryDeals.Total() == 0)
               {
                  posStatus = POSITION_STATUS_NULL;
               }
               return;
            }
            // ���� ����� ��������� ����� ������ � ���� �������?
            else if(in_order == NULL && order.OrderId() == EntryOrderID())
            {
               //�������� ����� ������ � ������ �������� �������.
               CArrayObj* deals = order.Deals();
               entryDeals.AddArray(deals);
               return;
            }
         }
         // � ������������ �������?
         else if(posStatus == POSITION_STATUS_CLOSED)
         {
            //���� ����� ��������� ��� ����� ��������� ������?
            if(in_order != NULL && in_order.OrderId() == EntryOrderID())
            {
               exitDeals.AddArray(order.Deals());
            }
         }
      }*/
      
   private:
      enum ENUM_TRANSACTION_CONTEXT
      {
         TRANS_IN,
         TRANS_OUT
      };
      ///
      /// �������������� ����� ������� ������� � ��� �������� ��������.
      ///
      void InitPosition(ulong in_ticket, CArrayLong* in_deals = NULL, ulong out_ticket = 0, CArrayLong* out_deals = NULL)
      {
         positionLine = NULL;
         //entryDeals = new CArrayObj();
         //exitDeals = new CArrayObj();
         SetStatus(in_ticket, in_deals, out_ticket, out_deals);
         if(posStatus == POSITION_STATUS_NULL)return;
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
         outOrderId = out_ticket;
      }
      ///
      /// ���������� ������� � ��� �������� ��������� � ���������� ��������
      ///
      void InitPositionByDeal(ulong in_ticket, CArrayObj* in_deals = NULL, ulong out_ticket = 0, CArrayObj* out_deals = NULL)
      {
         SetStatus(in_ticket, in_deals, out_ticket, out_deals);
         if(posStatus == POSITION_STATUS_NULL)return;
         //if(CheckPointer(in_deals) != POINTER_INVALID)
         //   entryDeals = in_deals;
         //if(CheckPointer(out_deals) != POINTER_INVALID)
         //   exitDeals = out_deals;   
      }
      ///
      /// ������������� ������ ������� �������, �� ��������� ���������� ��������.
      ///
      void SetStatus(ulong in_ticket, CArray* in_deals = NULL, ulong out_ticket = 0, CArray* out_deals = NULL)
      {
         if(in_ticket > 0)
            inOrderId = in_ticket;
         if(out_ticket > 0)
            outOrderId = out_ticket;
         SetId(inOrderId);
         entryDeals.Sort(SORT_ORDER_ID);
         exitDeals.Sort(SORT_ORDER_ID);
         if(in_ticket == 0)
         {
            posStatus = POSITION_STATUS_NULL;
            return;
         }
         if(CheckPointer(in_deals) == POINTER_INVALID)
            posStatus = POSITION_STATUS_PENDING;
         else if(out_ticket == 0 || CheckPointer(out_deals) == POINTER_INVALID)
            posStatus = POSITION_STATUS_OPEN;
         else
            posStatus = POSITION_STATUS_CLOSED;
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
      /// ���������� ����, �� ������� ��� �������� �����.
      ///
      double GetPriceExecuted()
      {
         if(Context() == TRANS_IN && isEntryPriceExecuted)
            return entryPriceExecuted;
         //������� ������� ����������� ���� �����
         CArrayObj* deals = NULL;
         if(Context() == TRANS_IN)
            deals = GetPointer(entryDeals);
         else
            deals = GetPointer(exitDeals);
         double vol_total = 0.0;
         double price_total = 0.0;
         for(int i = 0; i < deals.Total(); i++)
         {
            Deal* deal = deals.At(i);
            vol_total += deal.VolumeExecuted();
            price_total += deal.VolumeExecuted() * deal.EntryPriceExecuted();
         }
         double avrg_price = vol_total == 0 ? 0.0 : price_total / vol_total;
         if(Context() == TRANS_IN)
         {
            entryPriceExecuted = avrg_price;
            isEntryPriceExecuted = true;
         }
         return avrg_price;
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
      ///
      /// �����, ��� ���������� �������� ��������.
      ///
      CTrade trading;
      ///
      /// ��������� �� ������, - ���������� ������������� ������ �������.
      ///
      PosLine* positionLine;
      ///
      /// ������, ���� ��������� ������ �������� ��������� �������. ���� -
      /// ����� ����� ��������� ����� ����������� �������� �������.
      ///
      bool fullCounting;
};

class Deal : public Transaction
{
   public:
      Deal(ulong inId) : Transaction(TRANS_DEAL)
      {
         SetId(inId);
         SelectHistoryTransaction();
         volExecuted = HistoryDealGetDouble(GetId(), DEAL_VOLUME);
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
         if(isSymbol)return symbol;
         SelectHistoryTransaction();
         symbol = HistoryDealGetString(GetId(), DEAL_SYMBOL);
         isSymbol = true;
         return symbol;
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
      /// ���������� �����������, � ������� ��������� ����������
      ///
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         if(DealType() == DEAL_TYPE_BUY)
            return DIRECTION_LONG;
         else
            return DIRECTION_SHORT;
      }
      ///
      /// ���������� ��� ������, � ���� ������.
      ///
      string DealTypeAsString()
      {
         ENUM_DEAL_TYPE eType = DealType();
         string type = EnumToString(eType);
         type = StringSubstr(type, 10);
         StringReplace(type, "_", " ");
         return type;
      }
      ///
      /// ���������� ����, �� ������� ���� ��������� ������.
      ///
      virtual double EntryPriceExecuted()
      {
         if(isEntryPriceExecuted)
            return entryPriceExecuted;
         entryPriceExecuted = Price();
         isEntryPriceExecuted = true;
         return entryPriceExecuted;
      }
      ///
      /// ���������� ����� ���������� ������.
      ///
      CTime* Date()
      {
         return TimeExecuted();
      }
      ///
      /// ���������� ���������� ������������� ������.
      ///
      ulong Ticket(){return GetId();}
      ///
      /// ����� ������.
      ///
      double VolumeExecuted()
      {
         if(volExecuted < 0.0)
         {
            SelectHistoryTransaction();
            volExecuted = HistoryDealGetDouble(GetId(), DEAL_VOLUME);
         }
         return volExecuted;
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
      ///
      /// ��������� ���� �������� �������� ����� � ������
      /// \param vol - �����, ������� ���� ��������� ���� ������.
      ///
      void AddVolume(double vol)
      {
         volExecuted += vol;
         if(volExecuted < 0)volExecuted = 0;
      }
      ///
      /// ����� ����������� ����� �������.
      ///
      double volExecuted;
      ///
      /// ������, ���� ����� ������� ��� ����� ���������.
      ///
      bool isVolExecuted;
};

/*void foo()
{
   Transaction trans = new Transaction(TRANS_POSITION);
   //trans.
}*/


