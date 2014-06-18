///
/// Дополнительные математически функции.
///
class Math
{
   public:
      ///
      /// Истина, если переменная a равна переменной b.
      /// ВАЖНО: Игнорируется разница в примерно 4 младших бита  мантиссы.
      /// Или примерно полторы младшие значащие десятичные цифры из примерно 16-ти имеющихся. 
      /// Источник: http://www.mql5.com/ru/forum/3872
      ///
      static bool DoubleEquals(double a, double b)
      {
         return(fabs(a-b)<=16*DBL_EPSILON*fmax(fabs(a),fabs(b)));
      }
      ///
      /// Возвращает истину, если переданное число 'n' простое,
      /// Возвращает ложь в противном случае. Сложность расчета
      /// O(sqrt(N)).
      ///
      static bool PrimeTest(ulong n)
      {
         uint total = (uint)(MathFloor(sqrt(n))+1);
         if(total <= 1)total = ULONG_MAX;
         for(uint i = 2; i < total; i++)
         {
            if((n%i)==0)
               return false;
         }
         return true;
      }
};