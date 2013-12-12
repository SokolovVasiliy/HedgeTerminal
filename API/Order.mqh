#include <Object.mqh>
#include <Arrays\ArrayLong.mqh>
#include "Transaction.mqh"

///
/// ќпредел€ет тип ордера.
///
enum ENUM_ORDER_DIRECTION
{
   ///
   /// ќрдер открывает позицию.
   ///
   ORDER_IN,
   ///
   /// ќрдер закрывает позицию.
   ///
   ORDER_OUT
};
///
///  ласс, предоставл€ющий ордер и его сделки.
///
class COrder : public CObject
{
   public:
      ///
      /// ƒл€ создани€ нового ордера требуетс€ указать его идентификатор.
      ///
      COrder(const ulong order)
      {
         //ƒл€ быстрого обращени€ список сделок храним
         //всегда в сортированном виде.
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
      /// ¬озвращает ссылку на открыающий ордер,
      /// если этот ордер €вл€етс€ закрывающим, в противном
      /// случае возвращает NULL.
      ///
      COrder* InOrder()
      {
         // ” открывающего ордера нет другого открывающего ордера.
         if(orderDir == ORDER_IN)
            return NULL;
         return inOrder;
      }
      ///
      /// ”станавливает ссылку на открывающий ордер. ѕосле установки
      /// ссылки, текущий ордер автоматически становитьс€ закрывающим.
      ///
      void InOrder(COrder* order)
      {
         if(CheckPointer(order) == POINTER_INVALID)return;
         if(orderDir == ORDER_IN)
            orderDir = ORDER_OUT;
         inOrder = order;
      }
      ///
      /// ¬озвращает ссылку на закрывающий ордер,
      /// если этот ордер €вл€етс€ открывающим, в противном
      /// случае возвращает NULL.
      ///
      COrder* OutOrder()
      {
         // ” открывающего ордера нет другого открывающего ордера.
         if(orderDir == ORDER_OUT)
            return NULL;
         return outOrder;
      }
      ///
      /// ”станавливает ссылку на закрывающий ордер. ѕосле установки
      /// ссылки, текущий ордер автоматически становитьс€ открывающим.
      ///
      void OutOrder(COrder* order)
      {
         if(CheckPointer(order) == POINTER_INVALID)return;
         if(orderDir == ORDER_OUT)
            orderDir = ORDER_IN;
         outOrder = order;
      }
      ///
      /// ¬озвращает направление текущего ордера.
      ///
      ENUM_ORDER_DIRECTION Direction(){return orderDir;}
      ///
      /// ¬озвращает идентификатор ордера.
      ///
      ulong OrderId()const{return order_id;}
      ///
      /// ¬озвращает magic номер эксперта, выставившего ордер.
      ///
      ulong Magic(){return magic;}
      ///
      /// ƒобавл€ет сделку с идентификатором ticket в список сделок.
      ///
      void AddDeal(const ulong ticket)
      {
         //ѕовтор сделок не допускаетс€.
         if(listTickets.Search(ticket) == -1)
            listTickets.InsertSort(ticket);
      }
      ///
      /// ¬озвращает список идентификаторов сделок, которые были совершены на основании этого ордера.
      ///
      CArrayLong* Tickets()const
      {
         return GetPointer(listTickets);
      }
      ///
      /// √енерирует список сделок на основе тикетов и возвращает
      /// этот список.
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
      /// Magic номер эксперта, выставившего ордер.
      ///
      ulong magic;
      ///
      /// »дентификатор ордера.
      ///
      ulong order_id;
      ///
      /// —писок сделок, которые ассоциированы с этим ордером.
      ///
      CArrayLong listTickets;
      
      ENUM_ORDER_DIRECTION orderDir;
      ///
      /// —сылка на открывающий ордер.
      ///
      COrder* inOrder;
      ///
      /// —ыллка на закрывающий ордер.
      ///
      COrder* outOrder;
};
