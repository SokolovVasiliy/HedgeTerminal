#include "Transaction.mqh"

///
/// ��� ������ �� ������ HedgePanel.
///
enum ENUM_DEAL_HEDGE_TYPE
{
   ///
   /// ������ �������� ����� �� ������ ����������� �������.
   ///
   DEAL_IN,
   ///
   /// ������ �������� ����� �� ������ ����������� �������.
   ///
   DEAL_OUT,
   ///
   /// ������ �������� ���������� ��������� �� �����. 
   ///
   DEAL_NO_TRADE
};

class Deal : public Transaction
{
   public:
      Deal(ulong inId) : Transaction(TRANS_DEAL)
      {
         SetId(inId);
         SelectHistoryTransaction();
         volExecuted = HistoryDealGetDouble(GetId(), DEAL_VOLUME);
         //�������� ���������� ��� ������.
         //DetectTypeOfDeal();
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
   private:
      ENUM_DEAL_HEDGE_TYPE InfoTypeOfDeal()
      {
         ulong dealId = GetId();
         //LoadHistory();
         orderId = HistoryDealGetInteger(dealId, DEAL_ORDER);
         if((DealType() != DEAL_TYPE_BUY &&
            DealType() != DEAL_TYPE_SELL) ||
            orderId == 0)
         {
            return DEAL_NO_TRADE;
         }
         ulong magic = HistoryOrderGetInteger(orderId, ORDER_MAGIC);
         ulong inOrderId = MagicToTicket(magic);
         if(inOrderId == 0)
            return DEAL_IN;
         else
            return DEAL_OUT;
      }
      //void FindInOrderId
      ulong MagicToTicket(ulong magic)
      {
         if(magic == 0)return 0;
         //TODO: �������� ������� ���������� �������.
         ulong inOrderId = magic;
         //LoadHistory();
         if(!HistoryOrderSelect(inOrderId))return 0;
         return inOrderId;
      }
      ///
      /// ����� ����������� ����� �������.
      ///
      double volExecuted;
      ///
      /// ������, ���� ����� ������� ��� ����� ���������.
      ///
      bool isVolExecuted;
      ///
      /// ������������� ������, �� ��������� �������� ��������� ������.
      ///
      ulong orderId;
};
