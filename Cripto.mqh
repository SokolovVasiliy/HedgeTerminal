#include "Math.mqh"
#include <Arrays\ArrayChar.mqh>
#include <Arrays\List.mqh>
#define ROUND 8
///
/// �������� ���������� �� ������ ���� ��������.
///
class Cripto
{
   public:
      
      Cripto();
      ///
      /// ������������� ������ ����� � �����, ������� ���� �����������.
      ///
      Cripto(uchar b);
      ///
      /// ����������.
      ///
      ~Cripto();
      ///
      /// ������� ���������� ��������.
      ///
      ulong Crypt(ulong value);
      ///
      /// ��������� ���������� ����.
      ///
      ulong Decrypt(ulong hash);
   //private:
      void crypt(ulong& left, ulong& right);
      void decrypt(ulong& left, ulong& right);
      ulong Commutator(ulong subblock, int keyIndex);
      int f1(ulong subblock, ulong key);
      ///
      /// ���������� ����� ����������� �� ������ ������� � �����.
      ///
      CArrayChar* GenHashMap(int keyIndex);
      ///
      /// ���������� ������ �� �������� ����������� ����� �����������.
      ///
      void InitCharArray();
      ///
      /// ���������� �������� ����, ������������ �� ������� index � ���������� value.
      /// ���������� ������ ���� ��� ���������� � ������� � ���� � ��������� ������.
      ///
      bool GetBit(ulong value, uchar index);
      ///
      /// ������������� �������� ���� � 'bit', ������������ �� ������� index � ���������� value.
      ///
      void SetBit(ulong& value, uchar index, bool bit);
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
      /// ������� ����� �����������.
      ///
      void PrintMap(CArrayChar* map);
      ///
      /// ���������� ��������������� �����.
      ///
      void GenMask(void);
      ///
      /// ���������� ���, ������� ����� �������������� ��� ������� �� ���� ������ ����������.
      /// bits = ���� ���������� / 2.
      ///
      uchar bits;
      ///
      /// ������ �� �������� ����� ������������� ����� �����������.
      ///
      uchar c_array[];
      ///
      /// ������ ���������� ������, �� ������ �� ������ �����.
      ///
      ulong keys[ROUND];
      ///
      /// ������� ��������������� ���� ������������. �.�. ����� ������������
      /// ��� ���������� ���� � ����, �� ����� ������������ ��������������� ��� ����� ���� � ����
      ///
      CArrayChar* maps[ROUND];
      ///
      /// ������� �����.
      ///
      ulong mask;
      
};

Cripto::Cripto(void)
{
   bits = 64;
   InitCharArray();
}

Cripto::Cripto(uchar b)
{
   if(b%2 != 0)
      b--;
   bits = b;
   InitCharArray();
}

Cripto::~Cripto(void)
{
   for(int i = 0; i < ArraySize(maps); i++)
      delete maps[i];
}
void Cripto::InitCharArray(void)
{
   ArrayResize(c_array, bits);
   for(uchar i = 0; i < bits; i++)
      c_array[i] = i;
   Random rnd;
   for(uchar i = 0; i < ROUND; i++)
      keys[i] = rnd.Rand();
   GenMask();
}

void Cripto::GenMask(void)
{
   for(uchar i = 0; i < bits; i++)
      SetBit(mask, i, true);
}
/* ������� �������������� �������� �� ����� (������� �� ����������� ���������)
subblock - ������������� �������
key - ����
������������� �������� - ��������������� ����*/
ulong Cripto::Commutator(ulong subblock, int keyIndex)
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
   //PrintMap(map);
   return hash;
   return 1;
}
 
CArrayChar* Cripto::GenHashMap(int keyIndex)
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

bool Cripto::GetBit(ulong value, uchar index)
{
   ulong m_mask = 1;
   m_mask = m_mask << index;
   value = (value & m_mask);
   value = value >> index;
   if(value == 1)
      return true;
   return false;
}

void Cripto::SetBit(ulong& value, uchar index, bool bit)
{
   ulong m_mask = bit ? 1 : 0;
   m_mask = m_mask << index;
   value = (value | m_mask);
}

void Cripto::PrintMap(CArrayChar* map)
{
   string str = "";
   for(int i = 0; i < map.Total(); i++)
   {
      uchar ch = map.At(i);
      str += (string)ch + ", ";
   }
   printf(str);
}

void Cripto::Split(ulong block, ulong& left, ulong& right)
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

ulong Cripto::Merge(ulong left, ulong right)
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

ulong Cripto::Crypt(ulong value)
{
   ulong left=0, right = 0;
   Split(value, left, right);
   crypt(left, right);
   return Merge(left, right);
}

ulong Cripto::Decrypt(ulong hash)
{
   ulong left=0, right=0;
   Split(hash, left, right);
   decrypt(left, right);
   return Merge(left, right);
}
  
/*���������� ��������� ������
left - ����� ������� �������
right - ������ ������� �������
* key - ������ ������ (�� ����� �� �����)
rounds - ���������� �������*/
void Cripto::crypt(ulong& left, ulong& right)
{
	ulong temp = 0;
	for(int i = 0; i < ROUND; i++)
	{
		temp = right ^ Commutator(left, i);
		temp = temp & mask;
		right = left;
		left = temp;
	}
}
 
/*������������� ������
left - ����� ������������� �������
right - ������ ������������� �������*/
void Cripto::decrypt(ulong& left, ulong& right)
 {
	ulong temp;
	for(int i = ROUND-1; i >= 0; i--)
	{
		temp = left ^ Commutator(right, i);
		temp = temp & mask;
		left = right;
		right = temp;
	}	
 }
int CountWhile;

void GenMap(ulong key, uchar& map[])
{
         ArrayResize(map, 63);
         CArrayChar cArray;
         cArray.Sort();
         Random rnd;
         rnd.Seed(key);
         int index = 0;
         string str = "";
         int max = 0;
         while(true)
         {
            CountWhile++;
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