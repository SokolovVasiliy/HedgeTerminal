#include <Object.mqh>
#include <Arrays\ArrayLong.mqh>

///
/// Признаки, по которым может быть отсортирован список ордеров.
///
enum ENUM_SORT_ORDER
{
   ///
   /// Сортировка по тикету ордера
   ///
   SORT_ORDER_ID
};
///
/// Класс, предоставляющий ордер и его сделки.
///
class COrder : public CObject
{
   public:
      ///
      /// Для создания нового ордера требуется указать его идентификатор.
      ///
      COrder(const ulong order)
      {
         //Для быстрого обращения список сделок храним
         //всегда в сортированном виде.
         listDeals.Sort();
         order_id = order;
         magic = HistoryOrderGetInteger(order, ORDER_MAGIC);
      }
      ~COrder()
      {
         listDeals.Shutdown();
      }
      ///
      /// Возвращает идентификатор ордера.
      ///
      ulong OrderId()const{return order_id;}
      ///
      /// Возвращает magic номер эксперта, выставившего ордер.
      ///
      ulong Magic(){return magic;}
      ///
      /// Добавляет сделку с идентификатором ticket в список сделок.
      ///
      void AddDeal(const ulong ticket)
      {
         //Повтор сделок не допускается.
         if(listDeals.Search(ticket) == -1)
            listDeals.InsertSort(ticket);
      }
      ///
      /// Возвращает список идентификаторов сделок, которые были совершены на основании этого ордера.
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
      /// Magic номер эксперта, выставившего ордер.
      ///
      ulong magic;
      ///
      /// Идентификатор ордера.
      ///
      ulong order_id;
      ///
      /// Список сделок, которые ассоциированы с этим ордером.
      ///
      CArrayLong listDeals;
};
