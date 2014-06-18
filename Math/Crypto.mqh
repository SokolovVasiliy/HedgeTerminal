#include "Random.mqh"
#include <Arrays\ArrayChar.mqh>
#include <Arrays\List.mqh>
///
/// ���������� ������� ������������ ��� ����������.
///
#define ROUNDS 8

///
/// �������� ���������� �� ������ ���� ��������, � ���������� ��������� ����� � �����.
///
class Crypto
{
   public:
      Crypto();
      ///
      /// ������������� ������ ����� � �����, ������� ���� �����������.
      ///
      Crypto(uchar b);
      ///
      /// ����������.
      ///
      ~Crypto();
      ///
      /// ���������� �������� ����, ������������ �� ������� 'index' � ���������� 'value'.
      /// \return ������, ���� ��� ���������� � ������� � ���� � ��������� ������.
      ///
      bool GetBit(ulong value, uchar index);
      ///
      /// ������������� �������� ���� � 'bit', ������������ �� ������� 'index' � ���������� 'value'.
      ///
      void SetBit(ulong& value, uchar index, bool bit);
      ///
      /// ������� ���������� ��������.
      ///
      ulong Crypt(ulong value);
      ///
      /// ��������� ���������� ����.
      ///
      ulong Decrypt(ulong hash);
      ///
      /// ���������� ��� ������.
      ///
      ulong Adler32(string buf);
   private:
      ///
      /// ���������� ��������� ������.
      /// \param left - ����� ������� �������.
      /// \param right - ������ ������� �������.
      ///
      void Encryption(ulong& left, ulong& right);
      ///
      /// ������������� ������.
      /// \param left - ����� ������������� �������.
      /// \param right - ������ ������������� �������.
      ///
      void Decryption(ulong& left, ulong& right);
      ///
      /// ��������������� �������. ������������ ���� � ����������� �� �����. 
      /// \param subblock - �������, ���� � ������� ���������� ����������.
      /// \param keyIndex - ������ �����, � ������� ������, ������� ���������� ������������.
      ///
      ulong Commutator(ulong subblock, int keyIndex);
      ///
      /// ���������� ����� ����������� �� ������ �����, ������ �������� ����������� � keyIndex.
      /// \param keyIndex - ������ �����, � ������ ������.
      ///
      CArrayChar* GenHashMap(int keyIndex);
      ///
      /// ���������� ������ �� �������� ����������� ����� �����������, � ����� ����� ��� ������ � �����������.
      ///
      void InitCharArray();
      
      ///
      /// ��������� ���� �� ����� � ������ �����.
      /// \param block - ����, ������� ���������� ��������� �� ��������.
      /// \param left - ����� �������, ������� ����� ��������� ����� ����� block ������� sizeBlock/2 ���.
      /// \param rigth - ������ �������, ������� ����� ��������� ������ ����� block ������� sizeBlock/2 ���.
      /// \param sizeBlock - ������ ������������� ����� � �����. ����� ���� ������ ���������� ����� ��� ���� ������ ulong
      /// �� ����������� ������ ���� ������ ����.
      ///
      void Split(ulong block, ulong& left, ulong& right);
      ///
      /// ���������� ����� � ������ �������� � ������ ����.
      ///
      ulong Merge(ulong left, ulong right);
      ///
      /// ������� ����� ����������� map.
      ///
      void PrintMap(CArrayChar* map);
      ///
      /// ���������� ��������������� �����.
      ///
      void GenMask(void);
      ///
      /// ���������� ���, ������� ������������ � ����� ����������. 
      /// ����� ���� ������ ��������� � ���� � ��������� �� 2 �� 64.
      ///
      uchar bits;
      ///
      /// ������ �� �������� ����� ������������� ����� �����������.
      ///
      uchar c_array[];
      ///
      /// ������ ���������� ������, �� ������ �� ������ �����.
      ///
      ulong keys[ROUNDS];
      ///
      /// ������� ��������������� ���� ������������. �.�. ����� ������������
      /// ��� ���������� ���� � ����, �� ����� ������������ ��������������� ��� ����� ���� � ����
      ///
      CArrayChar* maps[ROUNDS];
      ///
      /// ������� �����. ������������ � �������� &, ��� ���������� ����� �� �������� 'bits'.
      ///
      ulong mask;
};

Crypto::Crypto(void)
{
   bits = 62;
   InitCharArray();
}

Crypto::Crypto(uchar b)
{
   if(b%2 != 0)
      b--;
   bits = b;
   InitCharArray();
}

Crypto::~Crypto(void)
{
   for(int i = 0; i < ArraySize(maps); i++)
   {
      if(CheckPointer(maps[i]) != POINTER_INVALID)
         delete maps[i];
   }
}

void Crypto::InitCharArray(void)
{
   ArrayResize(c_array, bits);
   for(uchar i = 0; i < bits; i++)
      c_array[i] = i;
   Random rnd;
   for(uchar i = 0; i < ROUNDS; i++)
      keys[i] = rnd.Rand();
   GenMask();
}

void Crypto::GenMask(void)
{
   for(uchar i = 0; i < bits; i++)
      SetBit(mask, i, true);
}

ulong Crypto::Commutator(ulong subblock, int keyIndex)
{
   CArrayChar* map = GenHashMap(keyIndex);
   CArrayChar* obj = maps[keyIndex];
   ulong hash = 0;
   int total = map.Total();
   for(uchar i = 0; i < total; i++)
   {
      uchar ind = map.At(i);              // �������� ������ ����, ������� ���� ������ �����.
      bool bit = GetBit(subblock, ind);   // �������� �������� ���� �� �������.
      SetBit(hash, i, bit);               // ������������� ��� ����� � ������ ��������.
   }
   return hash;
   return 1;
}

CArrayChar* Crypto::GenHashMap(int keyIndex)
{
   //������� ����� ����� ������������ �� ������ �����.
   if(keyIndex < ArraySize(maps) && maps[keyIndex] != NULL)
      return maps[keyIndex];
   //����� ���������� ����� ������������.
   ulong key = keys[keyIndex];
   Random rnd;
   rnd.Seed(key);
   CArrayChar vector;
   CArrayChar* map = new CArrayChar();
   int size = bits/2;
   vector.Resize(size);
   map.Resize(size);
   vector.InsertArray(c_array, 0);
   for(int i = size-1; i >= 0; i--)
   {
      int index = (int)rnd.Rand(0, i+1);
      uchar ch = vector.At(index);
      map.Add(ch);
      vector.Delete(index);
   }
   maps[keyIndex] = map;
   CArrayChar* obj = maps[keyIndex];
   return map;
}

bool Crypto::GetBit(ulong value, uchar index)
{
   ulong m_mask = 1;
   m_mask = m_mask << index;
   value = (value & m_mask);
   value = value >> index;
   if(value == 1)
      return true;
   return false;
}

void Crypto::SetBit(ulong& value, uchar index, bool bit)
{
   ulong m_mask = bit ? 1 : 0;
   m_mask = m_mask << index;
   value = (value | m_mask);
}

void Crypto::PrintMap(CArrayChar* map)
{
   string str = "";
   for(int i = 0; i < map.Total(); i++)
   {
      uchar ch = map.At(i);
      str += (string)ch + ", ";
   }
   printf(str);
}

void Crypto::Split(ulong block, ulong& left, ulong& right)
{
   ulong uleft = 0, uright = 0;
   uchar size = bits/2;
   //�������� ������ ����� �����.
   uchar i = 0;
   for(; i < size; i++)
   {
      bool bit = GetBit(block, i);
      SetBit(uright, i, bit);
   }
   //�������� ����� ����� �����.
   for(; i < bits; i++)
   {
      bool bit = GetBit(block, i);
      uchar ch = (uchar)(i-size);
      SetBit(uleft, ch, bit);
   }
   left = uleft;
   right = uright;
}

ulong Crypto::Merge(ulong left, ulong right)
{
   ulong block = 0;
   uchar size = bits/2;
   for(uchar i = 0; i < size; i++)
   {
      bool bit = GetBit(right, i);
      SetBit(block, i, bit);
   }
   for(uchar i = 0; i < bits; i++)
   {
      bool bit = GetBit(left, i);
      uchar ch = (uchar)(i+size);
      SetBit(block, ch, bit);
   }
   return block;
}

ulong Crypto::Crypt(ulong value)
{
   ulong left=0, right = 0;
   Split(value, left, right);
   Encryption(left, right);
   return Merge(left, right);
}

ulong Crypto::Decrypt(ulong hash)
{
   ulong left=0, right=0;
   Split(hash, left, right);
   Decryption(left, right);
   return Merge(left, right);
}

void Crypto::Encryption(ulong& left, ulong& right)
{
	ulong temp = 0;
	for(int i = 0; i < ROUNDS; i++)
	{
		temp = right ^ Commutator(left, i);
		temp = temp & mask;
		right = left;
		left = temp;
	}
}

///
/// ������������� ������.
/// \param left - ����� ������������� �������.
/// \param right - ������ ������������� �������.
///
void Crypto::Decryption(ulong& left, ulong& right)
{
	ulong temp;
	for(int i = ROUNDS-1; i >= 0; i--)
	{
		temp = left ^ Commutator(right, i);
		temp = temp & mask;
		left = right;
		right = temp;
	}	
}

ulong Crypto::Adler32(string buf)
  {
     ulong s1 = 1;
     ulong s2 = 0;
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