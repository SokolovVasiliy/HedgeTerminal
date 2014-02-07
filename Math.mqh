
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
};


bool DoubleEquals(double a, double b)
{
   return(fabs(a-b)<=16*DBL_EPSILON*fmax(fabs(a),fabs(b)));
}