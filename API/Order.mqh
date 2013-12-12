#include <Object.mqh>
#include <Arrays\ArrayLong.mqh>
#include "Transaction.mqh"

///
/// ���������� ��� ������.
///
enum ENUM_ORDER_DIRECTION
{
   ///
   /// ����� ��������� �������.
   ///
   ORDER_IN,
   ///
   /// ����� ��������� �������.
   ///
   ORDER_OUT
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
         listTickets.Sort();
         order_id = order;
         magic = HistoryOrderGetInteger(order, ORDER_MAGIC);
         orderDir = ORDER_IN;
      }
      ~COrder()
      {
         listTickets.Shutdown();
      }
      ///
      /// ���������� ������ �� ���������� �����,
      /// ���� ���� ����� �������� �����������, � ���������
      /// ������ ���������� NULL.
      ///
      COrder* InOrder()
      {
         // � ������������ ������ ��� ������� ������������ ������.
         if(orderDir == ORDER_IN)
            return NULL;
         return inOrder;
      }
      ///
      /// ������������� ������ �� ����������� �����. ����� ���������
      /// ������, ������� ����� ������������� ����������� �����������.
      ///
      void InOrder(COrder* order)
      {
         if(CheckPointer(order) == POINTER_INVALID)return;
         if(orderDir == ORDER_IN)
            orderDir = ORDER_OUT;
         inOrder = order;
      }
      ///
      /// ���������� ������ �� ����������� �����,
      /// ���� ���� ����� �������� �����������, � ���������
      /// ������ ���������� NULL.
      ///
      COrder* OutOrder()
      {
         // � ������������ ������ ��� ������� ������������ ������.
         if(orderDir == ORDER_OUT)
            return NULL;
         return outOrder;
      }
      ///
      /// ������������� ������ �� ����������� �����. ����� ���������
      /// ������, ������� ����� ������������� ����������� �����������.
      ///
      void OutOrder(COrder* order)
      {
         if(CheckPointer(order) == POINTER_INVALID)return;
         if(orderDir == ORDER_OUT)
            orderDir = ORDER_IN;
         outOrder = order;
      }
      ///
      /// ���������� ����������� �������� ������.
      ///
      ENUM_ORDER_DIRECTION Direction(){return orderDir;}
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
         if(listTickets.Search(ticket) == -1)
            listTickets.InsertSort(ticket);
      }
      ///
      /// ���������� ������ ��������������� ������, ������� ���� ��������� �� ��������� ����� ������.
      ///
      CArrayLong* Tickets()const
      {
         return GetPointer(listTickets);
      }
      ///
      /// ���������� ������ ������ �� ������ ������� � ����������
      /// ���� ������.
      ///
      CArrayObj* Deals()
      {
         CArrayObj* deals = new CArrayObj();
         int total = listTickets.Total();
         for(int i = 0; i < total; i++)
            deals.Add(new Deal(listTickets.At(i)));
         return deals;
      }
      virtual int Compare(const CObject *node, const int mode=0) const
      {
         const COrder* my_order = node;
         /*int LESS = -1;
         int GREATE = 1;
         int EQUAL = 0;*/
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
      CArrayLong listTickets;
      
      ENUM_ORDER_DIRECTION orderDir;
      ///
      /// ������ �� ����������� �����.
      ///
      COrder* inOrder;
      ///
      /// ������ �� ����������� �����.
      ///
      COrder* outOrder;
};
