
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
};


bool DoubleEquals(double a, double b)
{
   return(fabs(a-b)<=16*DBL_EPSILON*fmax(fabs(a),fabs(b)));
}