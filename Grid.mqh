#include <Arrays\ArrayChar.mqh>
#include "Math.mqh"
///
/// ��� ����������� ����.
///
/*enum ENUM_HASH_TYPE
{
   ///
   /// �������� ��� �� ��������.
   ///
   HASH_FROM_VALUE,
   ///
   /// �������� �������� �� ����.
   ///
   VALUE_FROM_HASH
};*/
///
/// �
///
class Grid
{
   public:
      ///
      /// ���������� ������, ���� ����� ������� ��� ����������� �������� value
      /// ����� 1. ���������� ���� � ��������� ������.
      ///
      static bool FirstBitIsHighest(ulong value)
      {
         long v = (long)value;
         if(v < 0)return true;
         return false;
      }
      ///
      /// ������������� ������� ��� ����� ulong � �������� 1.
      ///
      static void SetHighestBit(ulong& value)
      {
         ulong mask = 0x8000000000000000;
         value = (value | mask);
      }
      ///
      /// ���������� �������� �������� ���� ����� ulong � 0.
      ///
      static void ResetHighestBit(ulong& value)
      {
         ulong mask = 0x7fffffffffffffff;
         value = (value & mask);
      }
      ///
      /// ���������� ���, �� ������ ���������� ������������.
      ///
      ulong GenHash(long value, string key)
      {
         if(FirstBitIsHighest(value))
            ResetHighestBit(value);
         XOR(value);
         GenMap(Adler32(key));
         //PrintMap();
         ulong hash = 0x8000000000000000;
         for(uchar i = 0; i < 63; i++)
         {
            uchar ind = map[i];              // �������� ������ ����, ������� ���� ������ �����.
            bool bit = GetBit(value, ind);   // �������� �������� ���� �� �������.
            SetBit(hash, i, bit);            // ������������� ��� ����� � ������ ��������.
         }
         return hash;
      }
      ///
      /// ���������� �������������� �������� �� ����.
      ///
      ulong GenValue(ulong hash, string key)
      {
         GenMap(Adler32(key));
         ulong value = 0;
         for(uchar i = 0; i < 63; i++)
         {
            uchar ind = map[i];              // �������� ������ �������� ����
            bool bit = GetBit(hash, i);      // �������� ��� �� ��������� �����.
            SetBit(value, ind, bit);         // � ������ � ������� ���������.
         }
         XOR(value);
         if(FirstBitIsHighest(value))
            ResetHighestBit(value);
         return value;
      }
      ///
      /// ���������� �������� ����, ������������ �� ������� index � ���������� value.
      /// ���������� ������ ���� ��� ���������� � ������� � ���� � ��������� ������.
      ///
      bool GetBit(ulong value, uchar index)
      {
         ulong mask = 1;
         mask = mask << index;
         value = (value & mask);
         value = value >> index;
         if(value == 1)
            return true;
         return false;
      }
      ///
      /// ������������� �������� ���� � 'bit', ������������ �� ������� index � ���������� value.
      ///
      void SetBit(ulong& value, uchar index, bool bit)
      {
         ulong mask = bit ? 1 : 0;
         mask = mask << index;
         value = (value | mask);
      }
   private:
      ///
      /// ����� XOR ����� ���������� ������ � ������-����������.
      ///
      void XOR(ulong& value)
      {
         ulong max = ULONG_MAX;
         const ulong key = 0xEE9694526934DE8A;
         value = (key ^ value);
         int dbg = 4;
      }
      ///
      /// ���������� ����� ������������, �� ������ ����������� �����.
      ///
      void GenMap(ulong key)
      {
         CArrayChar cArray;
         cArray.Sort();
         Random rnd;
         rnd.Seed(key);
         int index = 0;
         string str = "";
         int max = 0;
         while(true)
         {
            uchar ch = (uchar)rnd.Rand(0, 63);
            if(ch > max)
               max = ch;
            int t = cArray.Total();
            if(cArray.Search((char)ch) == -1)
            {
               map[index++] = ch;
               str += (string)ch + ",";
               cArray.InsertSort((char)ch);
               if(cArray.Total() == 63)
                  break;
            }
            continue;
         }
         ulong m = cArray.At(cArray.Total()-1);
         int dbg = 5;
      }
      ///
      /// ������� ����� �����������.
      ///
      void PrintMap()
      {
         string str = "";
         for(int i = ArraySize(map)-1; i >= 0; i--)
         {
            uchar ch = map[i];
            str += (string)ch + ", ";
         }
         printf(str);
      }
      ///
      /// ���������� 32 ������ ��� ������.
      ///
      uint Adler32(string buf)
      {
         uint s1 = 1;
         uint s2 = 0;
         uint buflength=StringLen(buf);
         uchar array[];
         ArrayResize(array, buflength,0);
         StringToCharArray(buf, array, 0, -1, CP_ACP);
         for (uint n=0; n<buflength; n++)
         {
            s1 = (s1 + array[n]) % 65521;
            s2 = (s2 + s1)     % 65521;
         }
         return ((s2 << 16) + s1);
      }
      ///
      /// ����� ������������.
      ///
      uchar map[64];
};