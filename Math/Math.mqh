///
/// �������������� ������������� �������.
///
class Math
{
   public:
      ///
      /// ������, ���� ���������� a ����� ���������� b.
      /// �����: ������������ ������� � �������� 4 ������� ����  ��������.
      /// ��� �������� ������� ������� �������� ���������� ����� �� �������� 16-�� ���������. 
      /// ��������: http://www.mql5.com/ru/forum/3872
      ///
      static bool DoubleEquals(double a, double b)
      {
         return(fabs(a-b)<=16*DBL_EPSILON*fmax(fabs(a),fabs(b)));
      }
      ///
      /// ���������� ������, ���� ���������� ����� 'n' �������,
      /// ���������� ���� � ��������� ������. ��������� �������
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