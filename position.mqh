///
/// Статус позиции.
///
enum ENUM_POSITION_STATUS
{
   POSITION_STATUS_OPEN,
   POSITION_STATUS_CLOSED
};
///
/// Позиция.
///
class Position
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
         orderId = myOrderId;
         volume = myVolume;
         entryDate = myEntryTime;
         entryPrice = myEntryPrice;
         exitDate = myExitTime;
         exitPrice = myExitPrice;
         entryComment = myEntryComment;
      }
      ///
      /// Возвращает статус позиции.
      ///
      ENUM_POSITION_STATUS Status(){return status;}
      ///
      /// Возвращает направление позиции.
      ///
      ENUM_POSITION_TYPE Type(){return type;}
      ///
      /// Возвращает магический номер эксперта, открывшего позицию.
      ///
      long Magic(){return magic;}
      ///
      /// Возвращает название инструмента, по которому открыта позиция.
      ///
      string Symbol(){return symbol;}
      ///
      /// Возвращает идентификатор позиции.
      ///
      long OrderID(){return orderId;}
      ///
      /// Возвращает объем позиции.
      ///
      double Volume(){return volume;}
      ///
      /// Возвращает время входа в позицию.
      ///
      datetime EntryDate(){return entryDate;}
      ///
      /// Возвращает цену входа в позицию.
      ///
      double EntryPrice(){return entryPrice;}
      ///
      /// Возвращает дату выхода из позиции.
      /// Возвращает ноль, если позиция открыта.
      ///
      datetime ExitDate(){return exitDate;}
      ///
      /// Возвращает цену выхода из позиции.
      /// Возвращает ноль, если позиция открыта.
      ///
      double ExitPrice(){return exitPrice;}
      ///
      /// Возвращает уровень защитной остановки позиции.
      ///
      double StopLoss(){return stopLoss;}
      ///
      /// Возвращает уровень взятия прибыли позиции.
      ///
      double TakeProfit(){return takeProfit;}
      ///
      /// Возвращает накопленный своп позиции.
      ///
      double Swap(){return swap;}
      ///
      /// Возвращает прибыль позиции.
      ///
      double Profit(){return profit;}
      ///
      /// Возвращает комментарий который был введен при открытии позиции.
      ///
      string EntryComment(){return entryComment;}
      ///
      /// Возвращает комментарий который был введен при закрытии позиции.
      ///
      string ExitComment(){return exitComment;}
   private:
      ENUM_POSITION_STATUS status;
      ENUM_POSITION_TYPE type;
      long magic;
      string symbol;
      long orderId;
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