#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>

///
/// Represents a collection of keys and values. Contrasts the unique key 'key' value 'value'.
/// As a key can be any object that inherits from CObject and implements the method Compare.
/// The value can be any object type of CObject. Access speed is a key value in the limit
/// Is log2(MathCeil(n)) and, in the worst case requires 32 iterations to find a key.
///
class DictObj : protected CArrayObj
{
   public:
      ///
      /// Init DictObj default with mode of sort = 0.
      ///
      DictObj() : CArrayObj()
      {
         Sort(0);
      }
      ///
      /// Init DictObj class with mode of sort. Using this constructor if your CObject not realization
      /// sort mode 0.
      /// \param sortMode - Mode of sort.
      ///
      DictObj(int sortMode) : CArrayObj()
      {
         Sort(sortMode);
      }
      ///
      /// Add KeyValuePair  with unique key in collection.
      ///
      bool Add(CObject* key, CObject* value)
      {
         //Only valid pointer.
         if(CheckPointer(key) == POINTER_INVALID ||
            CheckPointer(value) == POINTER_INVALID)
            return false;
         int pos = SearchLessOrEqual(key);
         // Only unique values.
         if(pos >= 0 && pos+1 < Total() && m_data[pos+1].Compare(key) == 0)
            return false;
         InsertSort(key);
         m_values.Insert(value, pos+1);
         return true;
      }
      ///
      /// True if dictionary contains this key
      /// \return True if dictionary contains this key, false otherwise.
      bool Contains(CObject* key)
      {
         int pos = Search(key);
         if(pos == -1)
            return false;
         return true;
      }
   private:
      /*
         Collection of keys is inherited CObject* m_data[].
      */
      ///
      /// Contains an ordered collection of values.
      ///
      //CObject* m_values[];
      CArrayObj* m_values;
      
};