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
      /// Передвигает стоп-лосс в след за ценой.
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
      /// Включает или выключает трал в зависимости от enable.
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
      /// Возвращает статус активности трейлинга.
      ///
      bool TralEnable()
      {
         return isTral;
      }
      ///
      /// Возвращает уровень трал-дельты.
      ///
      double TralDelta()
      {
         return tralDelta;
      }
   private:
      ///
      /// Получает текущую цену.
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
      /// Истина, если трал всключен, ложь в противном случае.
      ///
      bool isTral;
      ///
      /// Дельта между текущей ценой и уровнем трала.
      ///
      double tralDelta;
      ///
      /// Ссылка на позицию, к которой прикреплен трал.
      ///
      Position* position;
      ///
      /// Истина, если позиция находится в процессе изменения стопа.
      ///
      bool isExecuting;
};
