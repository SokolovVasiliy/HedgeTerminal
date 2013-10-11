#include <Object.mqh>
#include <Arrays\ArrayLong.mqh>

///
/// ��������, �� ������� ����� ���� ������������ ������ �������.
///
enum ENUM_SORT_ORDER
{
   ///
   /// ���������� �� ������ ������
   ///
   SORT_ORDER_ID
};
///
/// �����, ��������������� ����� � ��� ������.
///
class COrder : public CObject
{
   public:
      ///
      /// ��� �������� ������ ������ ��������� ������� ��� �������������.
      ///
      COrder(const ulong order)
      {
         //��� �������� ��������� ������ ������ ������
         //������ � ������������� ����.
         listDeals.Sort();
         order_id = order;
         magic = HistoryOrderGetInteger(order, ORDER_MAGIC);
      }
      ~COrder()
      {
         listDeals.Shutdown();
      }
      ///
      /// ���������� ������������� ������.
      ///
      ulong OrderId()const{return order_id;}
      ///
      /// ���������� magic ����� ��������, ������������ �����.
      ///
      ulong Magic(){return magic;}
      ///
      /// ��������� ������ � ��������������� ticket � ������ ������.
      ///
      void AddDeal(const ulong ticket)
      {
         //������ ������ �� �����������.
         if(listDeals.Search(ticket) == -1)
            listDeals.InsertSort(ticket);
      }
      ///
      /// ���������� ������ ��������������� ������, ������� ���� ��������� �� ��������� ����� ������.
      ///
      CArrayLong* Deals()const
      {
         return GetPointer(listDeals);
      }
      virtual int Compare(const CObject *node, const int mode=0) const
      {
         const COrder* my_order = node;
         int LESS = -1;
         int GREATE = 1;
         int EQUAL = 0;
         switch(mode)
         {
            case SORT_ORDER_ID:
            default:
               if(order_id > my_order.order_id)
                  return GREATE;
               if(order_id < my_order.order_id)
                  return LESS;
               if(order_id == my_order.order_id)
                  return EQUAL;
         }
         return EQUAL;
      }
   private:
      ///
      /// Magic ����� ��������, ������������ �����.
      ///
      ulong magic;
      ///
      /// ������������� ������.
      ///
      ulong order_id;
      ///
      /// ������ ������, ������� ������������� � ���� �������.
      ///
      CArrayLong listDeals;
};
