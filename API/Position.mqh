#include "Transaction.mqh"

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
   /// ������� ��������� � ��������� ��������� � ���������� ��� ����������.
   ///
   POSITION_STATUS_BLOCKED,
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
      #ifndef HLIBRARY
      PosLine* PositionLine()
      {
         return positionLine;
      }
      #endif
      ///
      /// ������������� ��������� �� ������ ������������ ������������� �������.
      ///
      #ifndef HLIBRARY
      void PositionLine(CObject* pLine){positionLine = pLine;}
      #endif
      
      ///
      /// ��������� ����� ������ ������� ����������� ������� � ������� dealId.
      ///
      CArrayObj* AnnihilationDeal(ulong tradeId)
      {
         CArrayObj* resDeals = new CArrayObj();
         if(posStatus != POSITION_STATUS_OPEN)
         {
            LogWriter("Selected position #" + (string)EntryOrderID() + " has status" + EnumToString(posStatus) +
                      ". Closing deal #" + (string)tradeId + " will be not close this position.", MESSAGE_TYPE_WARNING);
            return resDeals;
         }
         Deal* newTrade = new Deal(tradeId);
         double volDel = newTrade.VolumeExecuted();
         //��������� ������ ������������ �������.
         for(int i = 0; i < entryDeals.Total(); i++)
         {
            Deal* deal = entryDeals.At(i);
            Deal* resDeal = new Deal(deal.Ticket());
            resDeals.Add(resDeal);
            resDeal.AddVolume((-1)* resDeal.VolumeExecuted());
            if(volDel >= deal.VolumeExecuted())
            {
               resDeal.AddVolume(deal.VolumeExecuted());
               volDel -= deal.VolumeExecuted();
               entryDeals.Delete(i);
               i--;
            }
            else
            {
               resDeal.AddVolume(volDel);
               deal.AddVolume((-1)*volDel);
               break;
            }
         }
         return resDeals;
      }
      ///
      /// ��������� � �������� ������� ����� �������� ������ � ������� dealId.
      /// \return ������, ���� ���������� ������ �������, ���� � ��������� ������.
      ///
      bool AddActiveDeal(ulong dealId)
      {
         if(posStatus != POSITION_STATUS_PENDING &&
            posStatus != POSITION_STATUS_OPEN)
         {
            LogWriter("Status of selected position is " + EnumToString(posStatus) +
            ". Add new deal not possible", MESSAGE_TYPE_WARNING);
            return false;
         }
         Deal* deal = new Deal(dealId);
         int iDeal = entryDeals.Search(deal);
         if(iDeal == -1)
         {
            posStatus = POSITION_STATUS_OPEN;
            return entryDeals.InsertSort(deal);
         }
         else
         {
            LogWriter("Deal with #" + (string)dealId + " already exists in position #" + (string)EntryOrderID() +
                      " Double adding not effect.", MESSAGE_TYPE_WARNING);
            return false;
         }
      }
      ///
      /// ���������� ������. 
      ///
      void MergeDeals(CArrayObj* resDeals, ulong dealId)
      {
         exitDeals.Add(new Deal(dealId));
         for(int i = 0; i < resDeals.Total(); i++)
         {
            Deal* addDeal = resDeals.At(i);
            int iDeal = entryDeals.Search(addDeal);
            if(iDeal == -1)
               entryDeals.InsertSort(addDeal);
            else
            {
               Deal* deal = entryDeals.At(iDeal);
               deal.AddVolume(addDeal.VolumeExecuted());
            }
         }
      }
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
      void AsynchClose(double vol, string comment = NULL)
      {
         trading.SetAsyncMode(true);
         trading.SetExpertMagicNumber(EntryOrderID());
         if(Direction() == DIRECTION_LONG)
            trading.Sell(vol, Symbol(), 0.0, 0.0, 0.0, comment);
         else if(Direction() == DIRECTION_SHORT)
            trading.Buy(vol, Symbol(), 0.0, 0.0, 0.0, comment);
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
         return new CTime(TimeExecuted());
      }
      ///
      /// ���������� ����� ������������ ������ �� �������. ������� ������ ���� �������.
      ///
      CTime* ExitExecutedDate()
      {
         Context(TRANS_OUT);
         if(posStatus == POSITION_STATUS_NULL ||
            posStatus != POSITION_STATUS_CLOSED)return NULL;
         return new CTime(TimeExecuted());
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
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_BID);
         else
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_ASK);
         //printf("CurentPrice(): " + price);
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
      /// �������������� ���������.
      ///
      virtual int Compare(const CObject *node, const int mode=0)
      {
         const Position* myPos = node;
         //��������, ������� ����� ������������.
         switch(mode)
         {
            case SORT_ORDER_ID:
               SetId(inOrderId);
            default:
            {
               ulong orderId = myPos.EntryOrderID();
               if(GetId() > orderId)
                  return GREATE;
               if(GetId() < orderId)
                  return LESS;
               //else
               return EQUAL;
            }
         }
         return EQUAL;
      }
      ///
      /// ���������� ������������� ��������, ������� ���������� �������� � ������ ���������� Transaction
      ///
      virtual ulong GetCompareValueInt(ENUM_SORT_TRANSACTION sortType)
      {
         switch(sortType)
         {
            case SORT_ORDER_ID:
               return inOrderId;
            case SORT_EXIT_ORDER_ID:
               return outOrderId;
         }
         return 0;
      }
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
         #ifndef HLIBRARY
         positionLine = NULL;
         #endif
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
      #ifndef HLIBRARY
      PosLine* positionLine;
      #endif
      ///
      /// ������, ���� ��������� ������ �������� ��������� �������. ���� -
      /// ����� ����� ��������� ����� ����������� �������� �������.
      ///
      bool fullCounting;
      ///
      /// ������, ���� ������� ������������� ��� ���������. ���� � ��������� ������.
      /// ��������������� ������� �� ����� ���� ��������, �������, � ��� �� ����� ���� ��������
      /// ����� �����.
      ///
      //bool isBlocked;
};
