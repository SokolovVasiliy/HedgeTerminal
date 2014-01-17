#include "Transaction.mqh"

///
/// Статус позиции/Сделки.
///
enum ENUM_POSITION_STATUS
{
   ///
   /// Позиция не определена.
   ///
   POSITION_STATUS_NULL,
   ///
   /// Позиция находится в состоянии изменения и недоступна для управления.
   ///
   POSITION_STATUS_BLOCKED,
   ///
   /// Позиция открыта.
   ///
   POSITION_STATUS_OPEN,
   ///
   /// Позиция закрыта.
   ///
   POSITION_STATUS_CLOSED,
   ///
   /// Позиция отложена.
   ///
   POSITION_STATUS_PENDING
};

///
/// Класс представляет позицию.
///
class Position : public Transaction
{
   public:
      ///
      /// Инициирует отложенную позицию.
      ///
      Position(ulong in_ticket) : Transaction(TRANS_POSITION)
      {
         InitPosition(in_ticket);
      }
      ///
      /// Инициирует активную позицию.
      ///
      Position(ulong in_ticket, CArrayLong* in_deals) : Transaction(TRANS_POSITION)
      {
         InitPosition(in_ticket, in_deals);
      }
      ///
      /// Инициирует завершенную позицию.
      ///
      Position(ulong in_ticket, CArrayLong* in_deals, ulong out_ticket, CArrayLong* out_deals) : Transaction(TRANS_POSITION)
      {
         InitPosition(in_ticket, in_deals, out_ticket, out_deals);
      }
      
      Position(ulong in_ticket, CArrayObj* in_deals, ulong out_ticket, CArrayObj* out_deals): Transaction(TRANS_POSITION)
      {
         InitPositionByDeal(in_ticket, in_deals, out_ticket, out_deals);
      }
      ///
      /// Возвращает указатель на строку отображающей представление позиции.
      ///
      #ifndef HLIBRARY
      PosLine* PositionLine()
      {
         return positionLine;
      }
      #endif
      ///
      /// Устанавливает указатель на строку отображающей представление позиции.
      ///
      #ifndef HLIBRARY
      void PositionLine(CObject* pLine){positionLine = pLine;}
      #endif
      
      ///
      /// Закрывает часть объема позиции закрывающим трейдом с тикетом dealId.
      ///
      CArrayObj* AnnihilationDeal(ulong tradeId)
      {
         CArrayObj* resDeals = new CArrayObj();
         if(posStatus != POSITION_STATUS_OPEN)
         {
            LogWriter("Selected position #" + (string)EntryOrderID() + " has status" + EnumToString(posStatus) +
                      ". Closing deal #" + (string)tradeId + " will be not close this position.", MESSAGE_TYPE_WARNING);
            return resDeals;
         }
         Deal* newTrade = new Deal(tradeId);
         double volDel = newTrade.VolumeExecuted();
         //формируем трейды исторической позиции.
         for(int i = 0; i < entryDeals.Total(); i++)
         {
            Deal* deal = entryDeals.At(i);
            Deal* resDeal = new Deal(deal.Ticket());
            resDeals.Add(resDeal);
            resDeal.AddVolume((-1)* resDeal.VolumeExecuted());
            if(volDel >= deal.VolumeExecuted())
            {
               resDeal.AddVolume(deal.VolumeExecuted());
               volDel -= deal.VolumeExecuted();
               entryDeals.Delete(i);
               i--;
            }
            else
            {
               resDeal.AddVolume(volDel);
               deal.AddVolume((-1)*volDel);
               break;
            }
         }
         return resDeals;
      }
      ///
      /// Добавляет к активной позиции новую входящую сделку с тикетом dealId.
      /// \return Истина, если добавление прошло успешно, ложь в противном случае.
      ///
      bool AddActiveDeal(ulong dealId)
      {
         if(posStatus != POSITION_STATUS_PENDING &&
            posStatus != POSITION_STATUS_OPEN)
         {
            LogWriter("Status of selected position is " + EnumToString(posStatus) +
            ". Add new deal not possible", MESSAGE_TYPE_WARNING);
            return false;
         }
         Deal* deal = new Deal(dealId);
         int iDeal = entryDeals.Search(deal);
         if(iDeal == -1)
         {
            posStatus = POSITION_STATUS_OPEN;
            return entryDeals.InsertSort(deal);
         }
         else
         {
            LogWriter("Deal with #" + (string)dealId + " already exists in position #" + (string)EntryOrderID() +
                      " Double adding not effect.", MESSAGE_TYPE_WARNING);
            return false;
         }
      }
      ///
      /// Объединяет сделки. 
      ///
      void MergeDeals(CArrayObj* resDeals, ulong dealId)
      {
         exitDeals.Add(new Deal(dealId));
         for(int i = 0; i < resDeals.Total(); i++)
         {
            Deal* addDeal = resDeals.At(i);
            int iDeal = entryDeals.Search(addDeal);
            if(iDeal == -1)
               entryDeals.InsertSort(addDeal);
            else
            {
               Deal* deal = entryDeals.At(iDeal);
               deal.AddVolume(addDeal.VolumeExecuted());
            }
         }
      }
      ///
      /// Возвращает направление, в котором совершена транзакция
      ///
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         if(PositionType() % 2 == 0)
            return DIRECTION_LONG;
         return DIRECTION_SHORT;
      }
      ///
      /// Возвращает сделки совершенные при входе в позицию.
      ///
      CArrayObj* EntryDeals()
      {
         return GetPointer(entryDeals);
      }
      ///
      /// Возвращает сделки совершенные при выходе из позиции.
      ///
      CArrayObj* ExitDeals()
      {
         return GetPointer(exitDeals);
      }
      ///
      /// Возвращает магический номер позиции/сделки.
      ///
      virtual ulong Magic()
      {
         Context(TRANS_IN);
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return OrderGetInteger(ORDER_MAGIC);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            return HistoryOrderGetInteger(GetId(), ORDER_MAGIC);
         }
         return 0;
      }
      ///
      /// Возвращает магический номер позиции/сделки.
      ///
      virtual ulong ExitMagic()
      {
         Context(TRANS_OUT);
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return OrderGetInteger(ORDER_MAGIC);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            return HistoryOrderGetInteger(GetId(), ORDER_MAGIC);
         }
         return 0;
      }
      ///
      /// Закрывает текущую позицию асинхронно.
      ///
      void AsynchClose(double vol, string comment = NULL)
      {
         trading.SetAsyncMode(true);
         trading.SetExpertMagicNumber(EntryOrderID());
         if(Direction() == DIRECTION_LONG)
            trading.Sell(vol, Symbol(), 0.0, 0.0, 0.0, comment);
         else if(Direction() == DIRECTION_SHORT)
            trading.Buy(vol, Symbol(), 0.0, 0.0, 0.0, comment);
      }
      ///
      /// Возвращает название символа, по которому была совершена сделка.
      ///
      virtual string Symbol()
      {
         if(isSymbol)return symbol;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            symbol = OrderGetString(ORDER_SYMBOL);
            isSymbol = true;
            return symbol;
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            symbol = HistoryOrderGetString(GetId(), ORDER_SYMBOL);
            isSymbol = true;
            return symbol;
         }
         return "";
      }
      ///
      /// Возвращает профит в пунктах инструмента.
      ///
      virtual double ProfitInPips()
      {
         
         double delta = 0.0;
         if(posStatus == POSITION_STATUS_NULL ||
            posStatus == POSITION_STATUS_PENDING)
            return 0.0;
         if(posStatus == POSITION_STATUS_OPEN)
            delta = CurrentPrice() - EntryPriceExecuted();   
         if(posStatus == POSITION_STATUS_CLOSED)
            delta = ExitPriceExecuted() - EntryPriceExecuted();
         if(Direction() == DIRECTION_SHORT)
            delta *= -1.0;
         return delta;
      }
      ///
      /// Возвращает тип позиции.
      ///
      ENUM_ORDER_TYPE PositionType()
      {
         Context(TRANS_IN);
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            return (ENUM_ORDER_TYPE)HistoryOrderGetInteger(GetId(), ORDER_TYPE);
         }
         return (ENUM_ORDER_TYPE)0;
      }
      ///
      /// Возвращает тип позиции в виде текстовой строки.
      ///
      string PositionTypeAsString()
      {
         ENUM_ORDER_TYPE posType = PositionType();
         string type = EnumToString(posType);
         type = StringSubstr(type, 11);
         StringReplace(type, "_", " ");
         //StringReplace(type, "STOP LIMIT", "SL");
         //StringReplace(type, "STOP", "S");
         //StringReplace(type, "LIMIT", "L");
         return type;
         //ORDER_TYPE_
      }
      ///
      /// Возвращает статус позиции.
      ///
      ENUM_POSITION_STATUS PositionStatus()
      {
         return posStatus;
      }
      ///
      /// Комментарий входа в позицию.
      ///
      string EntryComment()
      {
         Context(TRANS_IN);
         return GetComment();
      }
      ///
      /// Комментарий входа в позицию.
      ///
      string ExitComment()
      {
         Context(TRANS_OUT);
         return GetComment();
      }
      ///
      /// Возвращает идентификатор ордера, открывающего позицию.
      ///
      ulong EntryOrderID()
      {
         Context(TRANS_IN);
         return GetId();
      }
      ///
      /// Возвращает идентификатор ордера, закрывающего позицию.
      ///
      ulong ExitOrderID()
      {
         Context(TRANS_OUT);
         return GetId();
      }
      ///
      /// Возвращает цену, по которой был размещен ОТЛОЖЕННЫЙ ордер на вход в позицию.
      /// Если ордер на вход в позицию рыночный будет возвращено 0.0.
      ///
      double EntryPricePlaced()
      {
         Context(TRANS_IN);
         return GetPricePlaced();
      }
      ///
      /// Возвращает цену, по которой фактически произошло срабатывания ордера.
      ///
      virtual double EntryPriceExecuted()
      {
         Context(TRANS_IN);
         return GetPriceExecuted();
      }
      ///
      /// Возвращает цену, по которой был размещен ордер на выход из позиции.
      ///
      double ExitPricePlaced()
      {
         Context(TRANS_OUT);
         return GetPricePlaced();
      }
      ///
      /// Возвращает цену, по которой фактически произошло срабатывания ордера.
      ///
      virtual double ExitPriceExecuted()
      {
         if(posStatus != POSITION_STATUS_CLOSED)return 0.0;
         Context(TRANS_OUT);
         return GetPriceExecuted();
      }
      ///
      /// Возвращает время установки ордера.
      ///
      CTime* EntrySetupDate()
      {
         Context(TRANS_IN);
         return SetupTime();
      }
      ///
      /// Возвращает время установки ордера.
      ///
      CTime* ExitSetupDate()
      {
         // Если позиция еще не закрылась, то и времени размещения закрывающего
         // ее ордера у нее нет.
         if(POSITION_STATUS_CLOSED)
         {
            Context(TRANS_OUT);
            return SetupTime();
         }
         else return NULL;
      }
      ///
      /// Возвращает время фактического выполнения ордера. Ордер, чье время исполнения существует, должен быть исполненным.
      ///
      CTime* EntryExecutedDate()
      {
         Context(TRANS_IN);
         if(posStatus == POSITION_STATUS_NULL || posStatus == POSITION_STATUS_PENDING)return NULL;
         return new CTime(TimeExecuted());
      }
      ///
      /// Возвращает время фактического выхода из позиции. Позиция должна быть закрыта.
      ///
      CTime* ExitExecutedDate()
      {
         Context(TRANS_OUT);
         if(posStatus == POSITION_STATUS_NULL ||
            posStatus != POSITION_STATUS_CLOSED)return NULL;
         return new CTime(TimeExecuted());
      }
      ///
      /// Возвращает первоначальный размещенный объем
      ///
      double VolumeInit()
      {
         Context(TRANS_IN);
         double vol = 0.0;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            vol = OrderGetDouble(ORDER_VOLUME_INITIAL);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            vol = HistoryOrderGetDouble(GetId(), ORDER_VOLUME_INITIAL);
         }
         return vol;
      }
      ///
      /// Невыполненный объем ордера.
      ///
      double VolumeReject()
      {
         Context(TRANS_IN);
         double vol = 0.0;
         //Не активные позиции по определению не имеют невыполненого объема ?
         //if(posStatus == NULL || posStatus == POSITION_STATUS_PENDING)return 0;
         if(posStatus == NULL)return vol;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            vol = OrderGetDouble(ORDER_VOLUME_CURRENT);
         }
         else if(posStatus != POSITION_STATUS_NULL)
         {
            SelectHistoryTransaction();
            vol = HistoryOrderGetDouble(GetId(), ORDER_VOLUME_CURRENT);
         }
         return vol;
      }
      ///
      /// Выполненный объем позиции.
      ///
      double VolumeExecuted()
      {
         if(posStatus == POSITION_STATUS_PENDING ||
            posStatus == POSITION_STATUS_NULL)
            return 0.0;
         // Объем у активных и исторических позиций равен
         // сумме объемов всех входящих сделок.
         int total = entryDeals.Total();
         double total_vol = 0.0;
         for(int i = 0; i < total; i++)
         {
            Deal* deal = entryDeals.At(i);
            total_vol += deal.VolumeExecuted();
         }
         return total_vol;
      }
      ///
      /// Возвращает текущую цену инструмента, по которому совершена транзакция.
      ///
      virtual double CurrentPrice()
      {
         double price = 0.0;
         //Имеем дело с покупками?
         if(PositionType() % 2 == 0)
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_BID);
         else
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_ASK);
         //printf("CurentPrice(): " + price);
         return price;
      }
      ///
      /// Возвращает позицию, ассоциированную с защитной остановкой StopLoss
      ///
      Position* StopLoss()
      {
         return stopLoss;
      }
      ///
      /// Возвращает позицию, ассоциированную с защитной остановкой TakeProfit
      ///
      Position* TakeProfit()
      {
         return takeProfit;
      }
      ///
      /// Возвращает истину, если используется стоп-лосс.
      ///
      bool UsingStopLoss()
      {
         if(CheckPointer(stopLoss) != POINTER_INVALID)return true;
         return false;
      }
      ///
      /// Возвращает истину, если используется тейк-профит.
      ///
      bool UsingTakeProfit()
      {
         if(CheckPointer(takeProfit) != POINTER_INVALID)return true;
         return false;
      }
      ///
      /// Возвращает уровень защитной остановки stoploss.
      ///
      double StopLossLevel()
      {
         if(CheckPointer(stopLoss) == POINTER_INVALID)return 0.0;
         return stopLoss.EntryPricePlaced();
      }
      ///
      /// Устанавливает новый уровень защитной остановки stoploss.
      ///
      void StopLossLevel(double level)
      {
         ;
      }
      ///
      /// Устанавливает новый уровень взятия прибыли takeprofit.
      ///
      void TakeProfitLevel(double level)
      {
         ;
      }
      ///
      /// Возвращает уровень защитной остановки takeprofit.
      ///
      double TakeProfitLevel()
      {
         if(CheckPointer(takeProfit) == POINTER_INVALID)return 0.0;
         return takeProfit.EntryPricePlaced();
      }
      ///
      /// Удаляет защитную остановку stoploss.
      ///
      void DeleteStopLoss()
      {
         ;
      }
      ///
      /// Удаляет уровень взятия прибыли takeprofit.
      ///
      void DeleteTakeProfit()
      {
         ;
      }
      ///
      /// Добавляет новую входящую сделку в список входящих сделок.
      ///
      void AddEntryDeal(Deal* deal)
      {
         entryDeals.Add(deal);
      }
      ///
      /// Добавляет новую исходящую сделку в список исходящих сделок.
      ///
      void AddExitDeal(Deal* deal)
      {
         //Добавить исходящую сделку можно только в закрытую позицию.
         if(posStatus != POSITION_STATUS_CLOSED)return;
         entryDeals.Add(deal);
      }
      
      ///
      /// Переопределяем сравнение.
      ///
      virtual int Compare(const CObject *node, const int mode=0)
      {
         const Position* myPos = node;
         //Значение, которое будет сравниваться.
         switch(mode)
         {
            case SORT_ORDER_ID:
               SetId(inOrderId);
            default:
            {
               ulong orderId = myPos.EntryOrderID();
               if(GetId() > orderId)
                  return GREATE;
               if(GetId() < orderId)
                  return LESS;
               //else
               return EQUAL;
            }
         }
         return EQUAL;
      }
      ///
      /// Возвращает целочисленное значение, которое необходимо сравнить с другим экземляром Transaction
      ///
      virtual ulong GetCompareValueInt(ENUM_SORT_TRANSACTION sortType)
      {
         switch(sortType)
         {
            case SORT_ORDER_ID:
               return inOrderId;
            case SORT_EXIT_ORDER_ID:
               return outOrderId;
         }
         return 0;
      }
   private:
      enum ENUM_TRANSACTION_CONTEXT
      {
         TRANS_IN,
         TRANS_OUT
      };
      ///
      /// Инициализирует новую отрытую позицию с уже готовыми сделками.
      ///
      void InitPosition(ulong in_ticket, CArrayLong* in_deals = NULL, ulong out_ticket = 0, CArrayLong* out_deals = NULL)
      {
         #ifndef HLIBRARY
         positionLine = NULL;
         #endif
         //entryDeals = new CArrayObj();
         //exitDeals = new CArrayObj();
         SetStatus(in_ticket, in_deals, out_ticket, out_deals);
         if(posStatus == POSITION_STATUS_NULL)return;
         inOrderId = in_ticket;
         //Добавляем сделки инициирующего ордера.
         if(posStatus == POSITION_STATUS_OPEN ||
            posStatus == POSITION_STATUS_CLOSED)
         {
            for(int i = 0; i < in_deals.Total(); i++)
            {
               ulong id = in_deals.At(i);
               Deal* deal = new Deal(id);
               entryDeals.Add(deal);
            }
         }
         //Добавляем сделки закрывающего ордера.
         if(posStatus == POSITION_STATUS_CLOSED)
         {
            for(int i = 0; i < out_deals.Total(); i++)
            {
               ulong id = out_deals.At(i);
               Deal* deal = new Deal(id);
               exitDeals.Add(deal);
            }
         }
         outOrderId = out_ticket;
      }
      ///
      /// Инициирует позицию с уже готовыми входящими и исходящими трейдами
      ///
      void InitPositionByDeal(ulong in_ticket, CArrayObj* in_deals = NULL, ulong out_ticket = 0, CArrayObj* out_deals = NULL)
      {
         SetStatus(in_ticket, in_deals, out_ticket, out_deals);
         if(posStatus == POSITION_STATUS_NULL)return;
         //if(CheckPointer(in_deals) != POINTER_INVALID)
         //   entryDeals = in_deals;
         //if(CheckPointer(out_deals) != POINTER_INVALID)
         //   exitDeals = out_deals;   
      }
      ///
      /// Устанавливает статус текущей позиции, на основании переданных значений.
      ///
      void SetStatus(ulong in_ticket, CArray* in_deals = NULL, ulong out_ticket = 0, CArray* out_deals = NULL)
      {
         if(in_ticket > 0)
            inOrderId = in_ticket;
         if(out_ticket > 0)
            outOrderId = out_ticket;
         SetId(inOrderId);
         entryDeals.Sort(SORT_ORDER_ID);
         exitDeals.Sort(SORT_ORDER_ID);
         if(in_ticket == 0)
         {
            posStatus = POSITION_STATUS_NULL;
            return;
         }
         if(CheckPointer(in_deals) == POINTER_INVALID)
            posStatus = POSITION_STATUS_PENDING;
         else if(out_ticket == 0 || CheckPointer(out_deals) == POINTER_INVALID)
            posStatus = POSITION_STATUS_OPEN;
         else
            posStatus = POSITION_STATUS_CLOSED;
      }
      ///
      /// Возвращает время установки открывающего/закрывающего ордера. Если время установки ордера не известно, например, ордер не инициализирован,
      /// будет возвращено NULL.
      ///
      CTime* SetupTime()
      {
         CTime* ctime = NULL;
         if(posStatus == POSITION_STATUS_NULL)return ctime;
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            long msc = OrderGetInteger(ORDER_TIME_SETUP_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
         else
         {
            SelectHistoryTransaction();
            long msc = HistoryOrderGetInteger(GetId(), ORDER_TIME_SETUP_MSC);
            ctime = new CTime(msc);
            return ctime;
         }
      }
      ///
      /// Получает комментарий, ассоциированный с текущим оредром.
      ///
      string GetComment()
      {
         if(posStatus == POSITION_STATUS_NULL)return "not def.";
         if(posStatus == POSITION_STATUS_PENDING)
         {
            SelectPendingTransaction();
            return OrderGetString(ORDER_COMMENT);
         }
         else
         {
            SelectHistoryTransaction();
            return HistoryOrderGetString(GetId(), ORDER_COMMENT);
         }
      }
      ///
      /// Возвращает цену, по которой был размещен ордер.
      ///
      double GetPricePlaced()
      {
         if(posStatus != POSITION_STATUS_PENDING)
            return Price();
         else
            return Price(true);
      }
      ///
      /// Возвращает цену, по которой был размещен ордер.
      ///
      double GetPriceExecuted()
      {
         if(Context() == TRANS_IN && isEntryPriceExecuted)
            return entryPriceExecuted;
         //Считаем среднюю эффективную цену входа
         CArrayObj* deals = NULL;
         if(Context() == TRANS_IN)
            deals = GetPointer(entryDeals);
         else
            deals = GetPointer(exitDeals);
         double vol_total = 0.0;
         double price_total = 0.0;
         for(int i = 0; i < deals.Total(); i++)
         {
            Deal* deal = deals.At(i);
            vol_total += deal.VolumeExecuted();
            price_total += deal.VolumeExecuted() * deal.EntryPriceExecuted();
         }
         double avrg_price = vol_total == 0 ? 0.0 : price_total / vol_total;
         if(Context() == TRANS_IN)
         {
            entryPriceExecuted = avrg_price;
            isEntryPriceExecuted = true;
         }
         return avrg_price;
      }
      ///
      /// Устанавливает контекст - идентификатор входящей или исходящей транзакции, с которым производится работа.
      ///
      void Context(ENUM_TRANSACTION_CONTEXT context)
      {
         currContext = context;
         ulong id = currContext == TRANS_IN ? inOrderId : outOrderId;
         SetId(id);
      }
      ///
      /// Возвращает текущий контекст.
      ///
      ENUM_TRANSACTION_CONTEXT Context(){return currContext;}
      ///
      /// Статус позиции.
      ///
      ENUM_POSITION_STATUS posStatus;
      ///
      /// Текущий установленный контекст.
      ///
      ENUM_TRANSACTION_CONTEXT currContext;
      ///
      /// Уникальный идентификатор ордера, открывающего сделку.
      ///
      ulong inOrderId;
      ///
      /// Уникальный идентификатор ордера, закрывающего сделку.
      ///
      ulong outOrderId;
      ///
      /// Связанная с этой позицией другая позиция, представляющая защитную остановку stoploss.
      ///
      Position* stopLoss;
      ///
      /// Связанная с этой позицией другая позиция, представляющая уровень взятия прибыли takeprofit.
      ///
      Position* takeProfit;
      ///
      /// Содержит сделки инициирующие выход из позиции.
      ///
      CArrayObj entryDeals;
      ///
      /// Содержит сделки инициирующие выход из позиции.
      ///
      CArrayObj exitDeals;
      ///
      /// Класс, для совершения торговых операций.
      ///
      CTrade trading;
      ///
      /// Указатель на строку, - визуальное представление данной позиции.
      ///
      #ifndef HLIBRARY
      PosLine* positionLine;
      #endif
      ///
      /// Истина, если требуется полный пересчет параметра позиции. Ложь -
      /// когда будет возвращен ранее расчитанный параметр позиции.
      ///
      bool fullCounting;
      ///
      /// Истина, если позиция заблокирована для изменений. Ложь в противном случае.
      /// Заблокированная позиция не может быть изменена, закрыта, в нее не может быть добавлен
      /// новый трейд.
      ///
      //bool isBlocked;
};
