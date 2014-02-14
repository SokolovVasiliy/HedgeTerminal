#include <Arrays\ArrayObj.mqh>

///
///  ласс определ€ющий тип объекта.
///
class Type
{
   public:
      ///
      /// »стина, если текущий тип €вл€етс€ совместимым
      /// с типом comparerType, ложь в противном случае.
      ///
      bool Is(Type comparerType);
   protected:
      Type();
   private:
      ///
      /// —писок типов, на которых основан текущий тип.
      ///
      CArrayObj listTypes;
};
