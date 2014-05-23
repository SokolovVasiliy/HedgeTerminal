#include <Arrays\ArrayChar.mqh>
#include "Math.mqh"
///
/// ��� ����������� ����.
///
enum ENUM_HASH_TYPE
{
   ///
   /// �������� ��� �� ��������.
   ///
   HASH_FROM_VALUE,
   ///
   /// �������� �������� �� ����.
   ///
   VALUE_FROM_HASH
};
///
/// �
///
class Grid
{
   public:
      Grid()
      {
         ;
      }
      ///
      /// ���������� ���, �� ������ ���������� ������������.
      ///
      ulong GenHash(ulong value, ulong key)
      {
         //XOR(value);
         GenMap(key);
         PrintMap();
         ulong hash = 0;
         for(uchar i = 0; i < 63; i++)
         {
            uchar ind = map[i];              // �������� ������ ����, ������� ���� ������ �����.
            bool bit = GetBit(value, ind);   // �������� �������� ���� �� �������.
            SetBit(hash, i, bit);            // ������������� ��� ����� � ������ ��������.
         }
         return hash;
      }
      ulong GenValue(ulong hash, ulong key)
      {
         GenMap(key);
         ulong value = 0;
         for(uchar i = 0; i < 63; i++)
         {
            uchar ind = map[i];              // �������� ������ �������� ����
            bool bit = GetBit(hash, i);      // �������� ��� �� ��������� �����.
            SetBit(value, ind, bit);         // � ������ � ������� ���������.
         }
         //XOR(value);
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
         const ulong key = 3356470703969066634;
         value = value ^ key;
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
      /// ����� ������������.
      ///
      uchar map[64];
};