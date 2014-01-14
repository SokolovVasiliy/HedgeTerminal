#include "Transaction.mqh"
#include "Order.mqh"
#include "..\Log.mqh"

class CPosition;

///
/// Info about the Integration.
///
class InfoIntegration
{
   public:
      InfoIntegration();
      bool IsSuccess;
      string InfoMessage;
      CPosition* ActivePosition;
      CPosition* HistoryPosition;
};


InfoIntegration::InfoIntegration(void)
{
   ActivePosition = new CPosition();
   HistoryPosition = new CPosition();
}

///
/// Статус позиции.
///
enum POSITION_STATUS
{
   ///
   /// Нулевая позиция.
   ///
   POSITION_NULL,
   ///
   /// Активная позиция.
   ///
   POSITION_ACTIVE,
   ///
   /// Бывшая активная позиция, которая была полностью
   /// перекрыта встречными сделками и перестала существовать.
   ///
   POSITION_CLOSE,
   ///
   /// Историческая позиция.
   ///
   POSITION_HISTORY,
};

///
/// Используется для компановки ордеров как параметр функции ExchangerOrder.
///
struct ExchangerList
{
   public:
      Order* inOrder;
      Order* outOrder;
      Order* histInOrder;
      Order* histOutOrder;
};

class CPosition : Transaction
{
   public:
      CPosition(void);
      CPosition(Order* inOrder);
      CPosition(Order* inOrder, Order* outOrder);
      InfoIntegration* Integrate(Order* order);
      static bool CheckOrderType(Order* checkOrder);
      POSITION_STATUS Status();
      static void ExchangerOrder(ExchangerList& list);
      bool Merge(CPosition* pos);
      Order* InitOrder(){return initOrder;}
      Order* ClosingOrder(){return closingOrder;}
      bool Compatible(CPosition* pos);
      virtual int Compare(const CObject* node, const int mode=0);
   private:
      static void SplitOrder(ExchangerList& list);
      virtual bool MTContainsMe();
      bool CompatibleForInit(Order* order);
      bool CompatibleForClose(Order* order);
      InfoIntegration* AddClosingOrder(Order* outOrder);
      void AddInitialOrder(Order* inOrder);
      CPosition* AddOrder(Order* order);
      POSITION_STATUS RefreshType(void);
      Order* initOrder;
      Order* closingOrder;
      POSITION_STATUS status;
      string lastMessage;
};

///
/// Создает неактивную позицию со статусом POSITION_NULL.
///
CPosition::CPosition() : Transaction(TRANS_POSITION)
{
   status = POSITION_NULL;
}

///
/// В случае успеха создает активную позицию. В случае неудачи
/// будет создана позиция со статусом POSITION_NULL.
///
CPosition::CPosition(Order* inOrder) : Transaction(TRANS_POSITION)
{
   Integrate(inOrder);
}
///
/// Создает историческу позицию. Объемы исходящего и входящего ордеров должны быть равны.
///
CPosition::CPosition(Order* inOrder, Order* outOrder) : Transaction(TRANS_POSITION)
{
   if(inOrder == NULL || outOrder == NULL)
      return;
   if(inOrder.ExecutedVolume() != outOrder.ExecutedVolume())
      return;
   //if(inOrder.PositionId() != outOrder.PositionId())
   //   return;
   status = POSITION_HISTORY;
   initOrder = inOrder;
   outOrder = outOrder;
   Integrate(inOrder);
}

bool CPosition::Compatible(CPosition *pos)
{
   if(pos.Status() == POSITION_NULL ||
      pos.Status() == POSITION_CLOSE)
      return false;
   if(pos.GetId() != GetId())
      return false;
   if(pos.Status() != pos.Status())
      return false;
   if(pos.Status() == POSITION_HISTORY)
   {
      Order* clOrder = pos.ClosingOrder();
      if(clOrder.GetId() != closingOrder.GetId())
         return false;
   }
   return true;
}
///
/// Объединяет переданную позицию с текущей позицией.
/// После удачного объеденения переданная позиция лишается всех ее сделок
/// и переходит в состояние POSITION_NULL.
///
bool CPosition::Merge(CPosition *pos)
{
   if(!Compatible(pos))
      return false;
   
   //Merge init deals.
   Order* order = pos.InitOrder();
   //CArrayObj inDeals = in.D
   while(order.DealsTotal())
   {
      CDeal* ndeal = new CDeal(order.DealAt(0));
      initOrder.AddDeal(ndeal);
      order.DeleteDealAt(0);
   }
   order = pos.ClosingOrder();
   if(order == NULL)
      return true;
   while(order.DealsTotal())
   {
      CDeal* ndeal = new CDeal(order.DealAt(0));
      closingOrder.AddDeal(ndeal);
      order.DeleteDealAt(0);
   }
   return true;
}

///
/// Интегрирует ордер в текущую позицию. После успешной интеграции статус позиции
/// и все ее свойства могут измениться. Результатом интеграции могут стать
/// новые созданные позиции, как активные так и исторические.
/// \return Класс содержит информацию об интеграции и может быть уничтожен внешним
/// объектом.
///
InfoIntegration* CPosition::Integrate(Order* order)
{
   InfoIntegration* info = NULL;
   if(CompatibleForInit(order))
   {
      AddInitialOrder(order);
      info = new InfoIntegration();
   }
   else if(CompatibleForClose(order))
      /*info =*/ AddClosingOrder(order);
   else
   {
      info = new InfoIntegration();
      info.InfoMessage = "Proposed order #" + (string)order.GetId() +
      "can not be integrated in position #" + (string)GetId() +
      ". Position and order has not compatible types";
   }
   return info;
}

///
/// Возвращает истину, если ордер может быть добавлен в позицию как открывающий.
///
bool CPosition::CompatibleForInit(Order *order)
{
   if(status == POSITION_NULL)
      return true;
   if(initOrder.GetId() == order.GetId() && status == POSITION_ACTIVE)
      return true;
   else
      return false;
}

///
/// Возвращает истину, если ордер может быть закрывающим ордером позиции.
///
bool CPosition::CompatibleForClose(Order *order)
{
   //Закрыть можно только активную позицию.
   if(status != POSITION_ACTIVE)
      return false;
   if(order.PositionId() == GetId())
      return true;
   return false;
}

///
/// Добавляет инициирующий ордер в позицию.
///
void CPosition::AddInitialOrder(Order *inOrder)
{
   //contextOrder = initOrder;
   //CPosition* pos = AddOrder(inOrder);
   if(initOrder == NULL || status == POSITION_NULL)
   {
      initOrder = inOrder;
      status = POSITION_ACTIVE;
   }
   else if(status == POSITION_ACTIVE)
   {
      for(int i = 0; i < inOrder.DealsTotal(); i++)
      {
         CDeal* deal = inOrder.DealAt(i);
         initOrder.AddDeal(deal);
      }
   }
   return;
}

///
/// Добавляет закрывающий ордер в активную позицию.
///
InfoIntegration* CPosition::AddClosingOrder(Order* outOrder)
{
   InfoIntegration* info = NULL;
   if(!CompatibleForClose(outOrder))
   {
      info.InfoMessage = "Closing order has not compatible id with position id.";
      return info;
   }
   info = new InfoIntegration();
   ExchangerList list;
   bool revers = false;
   if(outOrder.ExecutedVolume() <= initOrder.ExecutedVolume())
   {
      list.inOrder = initOrder;
      list.outOrder = outOrder;
   }
   else
   {
      list.outOrder = initOrder;
      list.inOrder = outOrder;
      revers = true;
   }
   SplitOrder(list);
   if(revers)
   {
      delete info.ActivePosition;
      info.ActivePosition = new CPosition(list.outOrder);
      Order* tmp = list.histInOrder;
      list.inOrder = list.histOutOrder;
      list.outOrder = tmp;   
   }
   delete info.HistoryPosition;
   info.HistoryPosition = new CPosition(list.histInOrder, list.histOutOrder);
   return info;
}

///
/// Проверяет, является ли статус переданного ордера совместимым с понятием "позиция".
/// \return Истина, если ордер может принадлежать позиции, ложь в противном случае.
///
static bool CPosition::CheckOrderType(Order* checkOrder)
{
   bool isNull = CheckPointer(checkOrder) == POINTER_INVALID;
   if(isNull || checkOrder.Type() == ORDER_NULL ||
      checkOrder.Type() == ORDER_PENDING)
   {
      return false;
   }
   return true;
}

///
/// Обновляет статус позиции.
///
POSITION_STATUS CPosition::RefreshType()
{
   if(CheckPointer(initOrder) == POINTER_INVALID)
   {
      status = POSITION_NULL;
      return status;
   }
   if(CheckPointer(closingOrder) != POINTER_INVALID)
      status = POSITION_HISTORY;
   else
      status = POSITION_ACTIVE;
   SetId(initOrder.GetId());
   return status;
}

POSITION_STATUS CPosition::Status()
{
   return status;
}

///
/// Истина, если терминал содержит информацию об позиции с
/// с текущим идентификатором и ложь в противном случае.
///
bool CPosition::MTContainsMe()
{
   if(status == POSITION_NULL)
      return false;
   return true;
}

void CPosition::ExchangerOrder(ExchangerList& list)
{
   if(list.inOrder == NULL || list.outOrder == NULL)
      return;
   if(list.outOrder.ExecutedVolume() <= list.inOrder.ExecutedVolume())
   {
      SplitOrder(list);
   }
   else
   {
      ExchangerList exchList;
      exchList.inOrder = list.outOrder;
      exchList.outOrder = list.outOrder;
      SplitOrder(exchList);
      exchList.inOrder = list.outOrder;
      exchList.outOrder = list.outOrder;
   }
}

///
/// Иземеняет структуру ордеров и создает новые.
///
void CPosition::SplitOrder(ExchangerList &list)
{
   //Объем, который нужно выполнить.
   double volTotal = list.outOrder.ExecutedVolume();
   if(list.inOrder.ExecutedVolume() < volTotal)
      return;
   list.histOutOrder = list.outOrder.Clone();
   if(list.histInOrder == NULL)
      list.histInOrder = new Order();
   //Выполненный объем
   double exVol = 0.0;
   for(int i = 0; i < list.inOrder.DealsTotal(); i++)
   {
      //Объем, который осталось выполнить.
      double rVol = volTotal - exVol;
      //Если весь объем выполнен - выходим.
      if(rVol == 0.0)break;
      CDeal* deal = list.inOrder.DealAt(i);
      double curVol = deal.ExecutedVolume();
      if(deal.ExecutedVolume() > rVol)
      {
         CDeal* hDeal = deal.Clone();
         hDeal.ExecutedVolume(rVol);
         list.histInOrder.AddDeal(hDeal);
         deal.ExecutedVolume(deal.ExecutedVolume() - rVol);
         exVol += rVol;
      }
      else if(deal.ExecutedVolume() <= rVol)
      {
         exVol += deal.ExecutedVolume();
         list.histInOrder.AddDeal(deal.Clone());
         list.inOrder.DeleteDealAt(i);
         i--;
      }
   }   
}

int CPosition::Compare(const CObject* node, const int mode=0)
{
   switch(mode)
   {
      case SORT_ORDER_ID:
      {
         const Transaction* trans = node;
         ulong m_id = GetId();
         ulong p_id = trans.GetId();
         if(GetId() == trans.GetId())
            return EQUAL;
         if(GetId() < trans.GetId())
            return LESS;
         return GREATE;
      }
   }
   return 0;
}
