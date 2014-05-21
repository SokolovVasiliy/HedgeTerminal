class Order;
#include "..\Math.mqh"

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
/// Содержит алгоритмы хеширования для работы с ордерами и позициями HedgeTerminal.
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
            ResetHighestBit(value);
            hash = Hashing(value, key);
            if(usingTimeHash)
               value = Hashing(value, order.TimeSetup());
         }
         return hash;
      }
      ///
      /// Возвращает ключ, рассчитанный на основе значения переданного идентификатора.
      ///
      ulong GetKeyFromId(ulong id)
      {
         rnd.Seed(id);
         return rnd.Rand();
      }
      ///
      /// Возвращает истину, если самый старший бит переданного значения value
      /// равен 1. Возвращает ложь в противном случае.
      ///
      bool FirstBitIsHighest(ulong value)
      {
         long v = (long)value;
         if(v < 0)return true;
         return false;
      }
   private:
      ///
      /// Устанавливает старший бит в значение 1.
      ///
      void SetHighestBit(ulong& value)
      {
         ulong mask = 0x8000000000000000;
         value = (value | mask);
      }
      ///
      /// Сбрасывает значение старшего бита в 0.
      ///
      void ResetHighestBit(ulong& value)
      {
         ulong mask = 0x7fffffffffffffff;
         value = (value & mask);
      }
      ///
      /// Обобщенный алгоритм получения хеша либо первоначального значения на основе ключа.
      /// Для рассчета хеша используется информация ордера. Если переданное значение/хеш равен
      /// нулю, то в качестве значения берется значение маджика.
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
      /// Хеширует или дехеширует значение с помощью ключа key.
      /// Если в качестве value - передается захешированное значение, функция вернет первоначальное значение,
      /// которое было ранее захешировано. Если в качестве value передается первоначальное значение,
      /// То функция вернет его захешированное значение, которое было получено с помощью ключа key.
      ulong Hashing(ulong value, ulong key)
      {
         return value ^ key;
      }
      ///
      /// Для получения ключа используем генератор случайных чисел.
      ///
      Random rnd;
      ///
      /// Истина, если для взятия хеша используется дополнительная информация о времени открытия ордера.
      ///
      bool usingTimeHash;
      
};
