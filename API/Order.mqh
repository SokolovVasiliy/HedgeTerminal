#include "Transaction.mqh"

///
/// ������ ������.
///
enum ENUM_ORDER_STATUS
{
   ///
   /// ��������� �����, �� ������������ � ���� ������ ���������.
   ///
   ORDER_NULL,
   ///
   /// ����������, ��� �� ����������� �����.
   ///
   ORDER_PENDING,
   ///
   /// �����������, ������������ �����.
   ///
   ORDER_HISTORY
};

class Order : public Transaction
{
   public:
      Order(ulong orderId);
      ENUM_ORDER_STATUS Status();
      ENUM_ORDER_STATUS CheckStatus(void);
      ulong Id();
   private:
      ENUM_ORDER_STATUS status;
};

/*PUBLIC MEMBERS*/

///
/// ������� ����� � �������������� idOrder. ����� � ��������� ���������������
/// ������ ������������ � ���� ������ ������� ���������, � ��������� ������, ������
/// ������ ENUM_ORDER_STATUS ����� ��������������� ORDER_NULL (���������������� �����).
///
Order::Order(ulong idOrder):Transaction(TRANS_ORDER)
{
   SetId(idOrder);
   CheckStatus();
}
///
/// ���������� ��������� ��������� ������ ������. ������ ����� ���������� �� ������������.
/// ��� ������� ����������� ������� ����������� ������� Checkstatus(). 
/// \return ��������� ��������� ������ ������.
///
ENUM_ORDER_STATUS Order::Status(void)
{
   return status;
}

///
/// ���������� ������ ������ ENUM_ORDER_STATUS �� ��������� ���������� ���������� ��
/// ���� ������ ������� ���������. �������������� ��������� ��������� ��������� �������
/// ������ � ������� ����������.
///
ENUM_ORDER_STATUS Order::CheckStatus()
{
   if(OrderSelect(GetId()))
   {
      status = ORDER_PENDING;
      return status;
   }
   LoadHistory();
   if(HistoryOrderSelect(GetId()))
      status = ORDER_HISTORY;   
   else
   {
      SetId(0);
      status = ORDER_NULL;
   }
   return status;
}