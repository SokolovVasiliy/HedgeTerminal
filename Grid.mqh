#include <Arrays\ArrayChar.mqh>
#include "Math.mqh"
///
/// Тип получаемого хеша.
///
enum ENUM_HASH_TYPE
{
   ///
   /// Получаем хеш из значения.
   ///
   HASH_FROM_VALUE,
   ///
   /// Получаем значение из хеша.
   ///
   VALUE_FROM_HASH
};
///
/// п
///
class Grid
{
   public:
      Grid()
      {
         ;
      }
      ///
      /// Возвращает хеш, на основе квадратных перестановок.
      ///
      ulong GenHash(ulong value, ulong key)
      {
         //XOR(value);
         GenMap(key);
         PrintMap();
         ulong hash = 0;
         for(uchar i = 0; i < 63; i++)
         {
            uchar ind = map[i];              // Получаем индекс бита, который надо сейчас взять.
            bool bit = GetBit(value, ind);   // Получаем значение бита по индексу.
            SetBit(hash, i, bit);            // Устанавливаем бит шифра в нужное значение.
         }
         return hash;
      }
      ulong GenValue(ulong hash, ulong key)
      {
         GenMap(key);
         ulong value = 0;
         for(uchar i = 0; i < 63; i++)
         {
            uchar ind = map[i];              // Получаем индекс текущего бита
            bool bit = GetBit(hash, i);      // Забераем его из указаного места.
            SetBit(value, ind, bit);         // И ставим в текущее положение.
         }
         //XOR(value);
         return value;
      }
      ///
      /// Возвращает значение бита, находящегося по индексу index в переменной value.
      /// Возвращает истину если бит установлен в единицу и ложь в противном случае.
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
      /// Устанавливает значение бита в 'bit', находящегося по индексу index в переменной value.
      ///
      void SetBit(ulong& value, uchar index, bool bit)
      {
         ulong mask = bit ? 1 : 0;
         mask = mask << index;
         value = (value | mask);
      }
   private:
      ///
      /// Берет XOR между переданным числом и ключом-константой.
      ///
      void XOR(ulong& value)
      {
         const ulong key = 3356470703969066634;
         value = value ^ key;
      }
      ///
      /// Генерирует карту перестановок, на основе переданного ключа.
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
      /// Выводит карту подстоновок.
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
      /// Карта перестановок.
      ///
      uchar map[64];
};