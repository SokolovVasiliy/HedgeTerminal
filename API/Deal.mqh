#include "Transaction.mqh"

///
/// Тип сделки по версии HedgePanel.
///
enum ENUM_DEAL_HEDGE_TYPE
{
   ///
   /// Сделка является одной из сделок открывающих позицию.
   ///
   DEAL_IN,
   ///
   /// Сделка является одной из сделок закрывающих позицию.
   ///
   DEAL_OUT,
   ///
   /// Сделка является неторговой операцией на счете. 
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
         //Пытаемся определить тип сделки.
         //DetectTypeOfDeal();
      }
      
      ///
      /// Возвращает уникальный идентификатор эксперта, которому принадлежит данная сделка.
      ///
      virtual ulong Magic()
      {
         SelectHistoryTransaction();
         return HistoryDealGetInteger(GetId(), DEAL_MAGIC);
      }
      ///
      /// Возвращает название символа, по которому была совершена сделка.
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
      /// Возвращает тип сделки.
      ///
      ENUM_DEAL_TYPE DealType()
      {
         SelectHistoryTransaction();
         return (ENUM_DEAL_TYPE)HistoryDealGetInteger(GetId(), DEAL_TYPE);
      }
      ///
      /// Возвращает направление, в котором совершена транзакция
      ///
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         if(DealType() == DEAL_TYPE_BUY)
            return DIRECTION_LONG;
         else
            return DIRECTION_SHORT;
      }
      ///
      /// Возвращает тип сделки, в виде строки.
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
      /// Возвращает цену, по которой была выполнина сделка.
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
      /// Возвращает время совершения сделки.
      ///
      CTime* Date()
      {
         return TimeExecuted();
      }
      ///
      /// Возвращает уникальный идентификатор сделки.
      ///
      ulong Ticket(){return GetId();}
      ///
      /// Объем сделки.
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
      /// Возвращает комментарий к сделке.
      ///
      string Comment()
      {
         SelectHistoryTransaction();
         return HistoryDealGetString(GetId(), DEAL_COMMENT);
      }
      ///
      /// Возвращает текущую цену инструмента, по которому совершена сделка.
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
      /// Добавляет либо отнимает указаный объем к сделке
      /// \param vol - Объем, который надо прибавить либо отнять.
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
         //TODO: Написать функцию шифрования маджика.
         ulong inOrderId = magic;
         //LoadHistory();
         if(!HistoryOrderSelect(inOrderId))return 0;
         return inOrderId;
      }
      ///
      /// Ранее рассчитаный объем позиции.
      ///
      double volExecuted;
      ///
      /// Истина, если объем позиции был ранее рассчитан.
      ///
      bool isVolExecuted;
      ///
      /// Идентификатор ордера, на основании которого совершена сделка.
      ///
      ulong orderId;
};
