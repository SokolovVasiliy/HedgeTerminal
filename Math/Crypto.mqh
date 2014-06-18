#include "Random.mqh"
#include <Arrays\ArrayChar.mqh>
#include <Arrays\List.mqh>
///
/// Количество раундов используемых для шифрования.
///
#define ROUNDS 8

///
/// Алгоритм шифрования на основе сети Фейстеля, с задаваемой величиной блока в битах.
///
class Crypto
{
   public:
      Crypto();
      ///
      /// Устанавливает длинну блока в битах, которую надо зашифровать.
      ///
      Crypto(uchar b);
      ///
      /// Деструктор.
      ///
      ~Crypto();
      ///
      /// Возвращает значение бита, находящегося по индексу 'index' в переменной 'value'.
      /// \return Истина, если бит установлен в единицу и ложь в противном случае.
      ///
      bool GetBit(ulong value, uchar index);
      ///
      /// Устанавливает значение бита в 'bit', находящегося по индексу 'index' в переменной 'value'.
      ///
      void SetBit(ulong& value, uchar index, bool bit);
      ///
      /// Шифрует переданное значение.
      ///
      ulong Crypt(ulong value);
      ///
      /// Дешифрует переданный шифр.
      ///
      ulong Decrypt(ulong hash);
      ///
      /// Возвращает хеш строки.
      ///
      ulong Adler32(string buf);
   private:
      ///
      /// Шифрование открытого текста.
      /// \param left - левый входной подблок.
      /// \param right - правый входной подблок.
      ///
      void Encryption(ulong& left, ulong& right);
      ///
      /// Расшифрование текста.
      /// \param left - левый зашифрованный подблок.
      /// \param right - правый зашифрованный подблок.
      ///
      void Decryption(ulong& left, ulong& right);
      ///
      /// Перестановочная функция. Перемешивает быты в зависимости от ключа. 
      /// \param subblock - субблок, биты в котором необходимо перемешать.
      /// \param keyIndex - индекс ключа, в массиве ключей, который необходимо использовать.
      ///
      ulong Commutator(ulong subblock, int keyIndex);
      ///
      /// Генерирует карту подстановок на основе ключа, индекс которого содержиться в keyIndex.
      /// \param keyIndex - Индекс ключа, в масиве ключей.
      ///
      CArrayChar* GenHashMap(int keyIndex);
      ///
      /// Инициирует вектор из которого формируется карта подстановок, а также ключи для работы с шифрованием.
      ///
      void InitCharArray();
      
      ///
      /// Разделяет блок на левую и правую части.
      /// \param block - блок, который необходимо разделить на подблоки.
      /// \param left - Левый подблок, который будет содержать левую часть block длинной sizeBlock/2 бит.
      /// \param rigth - Правый подблок, который будет содержать правую часть block длинной sizeBlock/2 бит.
      /// \param sizeBlock - Размер передаваемого блока в битах. Может быть меньше количества битов для типа данных ulong
      /// но обязательно должен быть кратен двум.
      ///
      void Split(ulong block, ulong& left, ulong& right);
      ///
      /// Объеденяет левый и правые подблоки в единый блок.
      ///
      ulong Merge(ulong left, ulong right);
      ///
      /// Выводит карту подстановок map.
      ///
      void PrintMap(CArrayChar* map);
      ///
      /// Генерирует ограничительную маску.
      ///
      void GenMask(void);
      ///
      /// Количество бит, которое используется в блоке шифрования. 
      /// Может быть четным значением и быть в деапазоне от 2 до 64.
      ///
      uchar bits;
      ///
      /// Вектор из которого будет формироваться карта подстановок.
      ///
      uchar c_array[];
      ///
      /// Массив уникальных ключей, по одному на каждый раунд.
      ///
      ulong keys[ROUNDS];
      ///
      /// Массивы сгенерированных карт перестановок. Т.к. ключи используемые
      /// для шифрования одни и теже, то карты перестановок сгенерированные ими будут одни и теже
      ///
      CArrayChar* maps[ROUNDS];
      ///
      /// Битовая маска. Используется в операции &, для сокращения хешей до величины 'bits'.
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
      uchar ind = map.At(i);              // Получаем индекс бита, который надо сейчас взять.
      bool bit = GetBit(subblock, ind);   // Получаем значение бита по индексу.
      SetBit(hash, i, bit);               // Устанавливаем бит шифра в нужное значение.
   }
   return hash;
   return 1;
}

CArrayChar* Crypto::GenHashMap(int keyIndex)
{
   //Пробуем найти карту перестановок по идексу ключа.
   if(keyIndex < ArraySize(maps) && maps[keyIndex] != NULL)
      return maps[keyIndex];
   //Иначе генерируем карту перестановок.
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
   //Получаем правую часть блока.
   uchar i = 0;
   for(; i < size; i++)
   {
      bool bit = GetBit(block, i);
      SetBit(uright, i, bit);
   }
   //Получаем левую часть блока.
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
/// Расшифрование текста.
/// \param left - левый зашифрованный подблок.
/// \param right - правый зашифрованный подблок.
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