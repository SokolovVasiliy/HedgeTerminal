#include "..\Math\Math.mqh"
class Position;
///
/// 
///
class TrallStopLoss
{
   public:
      TrallStopLoss(Position* pos)
      {
         isTral = false;
         tralDelta = 0.0;
         position = pos;
         isExecuting = false;
      }
      ///
      /// ����������� ����-���� � ���� �� �����.
      ///
      void Trailing()
      {
         if(!isTral || !position.UsingStopLoss())return;
         if(position.IsBlocked() || isExecuting)return;
         double price = GetCurrentPrice();
         double curDelta = MathAbs(price - position.StopLossLevel());
         if(curDelta > tralDelta)
         {
            isExecuting = true;
            if(position.Direction() == DIRECTION_LONG)
               position.StopLossLevel(price-tralDelta);
            else
               position.StopLossLevel(price+tralDelta);
            isExecuting = false;
         }
      }
      ///
      /// �������� ��� ��������� ���� � ����������� �� enable.
      ///
      void TralEnable(bool enable)
      {
         if(position.UsingStopLoss() && enable)
         {
            tralDelta = MathAbs(GetCurrentPrice() - position.StopLossLevel());
            isTral = true;
         }
         if(!enable)
         {
            tralDelta = 0.0;
            isTral = false;
         }
      }
      ///
      /// ���������� ������ ���������� ���������.
      ///
      bool TralEnable()
      {
         return isTral;
      }
      ///
      /// ���������� ������� ����-������.
      ///
      double TralDelta()
      {
         return tralDelta;
      }
   private:
      ///
      /// �������� ������� ����.
      ///
      double GetCurrentPrice()
      {
         double price = 0.0;
         if(position.Direction() == DIRECTION_LONG)
            price = SymbolInfoDouble(position.Symbol(), SYMBOL_BID);
         else
            price = SymbolInfoDouble(position.Symbol(), SYMBOL_ASK);
         price = NormalizeDouble(price, position.InstrumentDigits());
         return price;
      }
      ///
      /// ������, ���� ���� ��������, ���� � ��������� ������.
      ///
      bool isTral;
      ///
      /// ������ ����� ������� ����� � ������� �����.
      ///
      double tralDelta;
      ///
      /// ������ �� �������, � ������� ���������� ����.
      ///
      Position* position;
      ///
      /// ������, ���� ������� ��������� � �������� ��������� �����.
      ///
      bool isExecuting;
};
