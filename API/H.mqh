class Order;
#include "..\Math.mqh"

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
/// �������� ��������� ����������� ��� ������ � �������� � ��������� HedgeTerminal.
///
class Hash
{
   public:
      Hash()
      {
         usingTimeHash = false;
      }
      
      ulong GetHash(Order* order, ulong value, ENUM_HASH_TYPE type)
      {
         ulong hash = 0;
         rnd.Seed(order.GetId());
         ulong key = rnd.Rand();
         if(type == HASH_FROM_VALUE)
         {
            if(usingTimeHash)
               value = Hashing(value, order.TimeSetup());
            hash = Hashing(value, key);
            SetHighestBit(hash);
         }
         else
         {
            if(!FirstBitIsHighest(key))
               ResetHighestBit(value);
            hash = Hashing(value, key);
            if(usingTimeHash)
               return Hashing(hash, order.TimeSetup());
         }
         return hash;
      }
      ///
      /// ���������� ������, ���� ����� ������� ��� ����������� �������� value
      /// ����� 1. ���������� ���� � ��������� ������.
      ///
      bool FirstBitIsHighest(ulong value)
      {
         long v = (long)value;
         if(v < 0)return true;
         return false;
      }
      ///
      /// ������������� ���� ��������������� ����������� �� �������.
      ///
      void TimeHashing(bool flag){usingTimeHash = flag;}
      ///
      /// ���������� ���� ��������������� ����������� �� �������.
      ///
      bool TimeHashing(){return usingTimeHash;}
   private:
      
      ///
      /// ������������� ������� ��� ����� uchar � �������.
      ///
      void SetHighestBit(uchar& ch)
      {
         uchar mask = 0x80;
         ch = (ch | mask);
      }
      ///
      /// ���������� ������� ��� ����� uchar � ����.
      ///
      void ResetHighestBit(uchar& ch)
      {
         uchar mask = 0x7f;
         ch = (ch & mask);
      }
      ///
      /// ������������� ������� ��� ����� ulong � �������� 1.
      ///
      void SetHighestBit(ulong& value)
      {
         ulong mask = 0x8000000000000000;
         value = (value | mask);
      }
      ///
      /// ���������� �������� �������� ���� ����� ulong � 0.
      ///
      void ResetHighestBit(ulong& value)
      {
         ulong mask = 0x7fffffffffffffff;
         value = (value & mask);
      }
      ///
      /// ���������� �������� ��������� ���� ���� ��������������� �������� �� ������ �����.
      /// ��� �������� ���� ������������ ���������� ������. ���� ���������� ��������/��� �����
      /// ����, �� � �������� �������� ������� �������� �������.
      ///
      ulong GetHashOrder(Order* order, ulong value = 0)
      {
         if(value == 0)
            value = order.Magic();
         rnd.Seed(order.GetId());
         ulong key = rnd.Rand();
         ulong hash = Hashing(value, key);
         return hash;
      }
      ///
      /// �������� ��� ���������� �������� � ������� ����� key.
      /// ���� � �������� value - ���������� �������������� ��������, ������� ������ �������������� ��������,
      /// ������� ���� ����� ������������. ���� � �������� value ���������� �������������� ��������,
      /// �� ������� ������ ��� �������������� ��������, ������� ���� �������� � ������� ����� key.
      ulong Hashing(ulong value, ulong key)
      {
         return value ^ key;
      }
      ///
      /// ��� ��������� ����� ���������� ��������� ��������� �����.
      ///
      Random rnd;
      ///
      /// ������, ���� ��� ������ ���� ������������ �������������� ���������� � ������� �������� ������.
      ///
      bool usingTimeHash;
      
};
