
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

class Random
{
   public:
      Random()
      {
         InitValues(RANDOM_KNUTH);
      }
      
      void Seed(ulong seed)
      {
         prevValue = seed;
      }
      ///
      /// ���������� ulong ��������������� �����.
      ///
      ulong Rand()
      {
         ulong value = (ulong)((a*prevValue+c)%m);
         prevValue = value;
         return value;
      }
      ///
      /// ���������� ��������� ����� �� min �� max-1 ������������.
      ///
      ulong Rand(ulong min, ulong max)
      {
         ulong delta = max - min;
         if(delta <= 0)return min;
         ulong value = Rand();
         ulong m_value = value%delta;
         m_value += min;
         return m_value;
      }
   private:
      enum ENUM_RANDOM_TYPE
      {
         RANDOM_KNUTH,
         RANDOM_NEWLIB,
         RANDOM_RECIPES,
         RANDOM_BORLAND,
         RANDOM_ANSI_C,
         RANDOM_VBASIC
      };
      void InitValues(ENUM_RANDOM_TYPE type)
      {
         prevValue = 0;
         switch(type)
         {
            case RANDOM_KNUTH:
               m = ULONG_MAX;
               a = 6364136223846793005;
               c = 1442695040888963407;
               break;
            case RANDOM_NEWLIB:
               m = ULONG_MAX;
               a = 6364136223846793005;
               c = 1;
               break;
            //(������ ���������� 2 147 483 648 ���� (2^31 ���))
            case RANDOM_ANSI_C:
               m = 2147483648; //(2^31)
               a = 1103515245;
               c = 12345;
               break;
            case RANDOM_BORLAND:
               m = UINT_MAX;
               a = 22695477;
               c = 1;
               break;
            case RANDOM_RECIPES:
               m = UINT_MAX; //(������ ���������� 65 536 ����)
               a = 1664525;
               c = 1013904223;
               break;
            case RANDOM_VBASIC:
               m = 16777216; // (2^24)
               a = 1140671485;
               c = 12820163;
               break;
         }
      }
      ulong m;
      ulong a;
      ulong c;
      ulong prevValue;
};
