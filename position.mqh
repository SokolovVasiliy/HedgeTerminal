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
      /// ���������� ������ �������.
      ///
      ENUM_POSITION_STATUS Status(){return status;}
      ///
      /// ���������� ����������� �������.
      ///
      ENUM_POSITION_TYPE Type(){return type;}
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
      long OrderID(){return orderId;}
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
      /// ���������� ����������� ���� �������.
      ///
      double Swap(){return swap;}
      ///
      /// ���������� ������� �������.
      ///
      double Profit(){return profit;}
      ///
      /// ���������� ����������� ������� ��� ������ ��� �������� �������.
      ///
      string EntryComment(){return entryComment;}
      ///
      /// ���������� ����������� ������� ��� ������ ��� �������� �������.
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