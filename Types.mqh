#include <Arrays\ArrayObj.mqh>

///
/// ����� ������������ ��� �������.
///
class Type
{
   public:
      ///
      /// ������, ���� ������� ��� �������� �����������
      /// � ����� comparerType, ���� � ��������� ������.
      ///
      bool Is(Type comparerType);
   protected:
      Type();
   private:
      ///
      /// ������ �����, �� ������� ������� ������� ���.
      ///
      CArrayObj listTypes;
};
