//+------------------------------------------------------------------+
//|                                                HedgePanelAPI.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#define HLIBRARY
#include "..\Globals.mqh"
#include "TaskLog.mqh"

 
HedgeManager api;

///
/// Curent position selected HedgePositionSelect function.
///
Position* CurrentPosition;
///
/// Current Order.
///
Order* CurrentOrder;
///
/// Current deal.
///
Deal* CurrentDeal;

///
/// True if position was selected, otherwise false.
///
bool CheckPosition()
{
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
   {
      hedgeErr = HEDGE_ERR_TRANS_NOTSELECTED;
      return false;
   }
   return true;
}

///
/// True if order was selected, otherwise false.
///
bool CheckOrder()
{
   if(CheckPointer(CurrentOrder) == POINTER_INVALID)
   {
      hedgeErr = HEDGE_ERR_TRANS_NOTSELECTED;
      return false;
   }
   return true;
}
///
/// True if order was selected, otherwise false.
///
bool CheckDeal()
{
   if(CheckPointer(CurrentDeal) == POINTER_INVALID)
   {
      hedgeErr = HEDGE_ERR_TRANS_NOTSELECTED;
      return false;
   }
   return true;
}
///
/// Type of last api error.
///
ENUM_HEDGE_ERR hedgeErr;
///
/// Return last hedge error.
///
ENUM_HEDGE_ERR GetHedgeError() export
{
   return hedgeErr;
}

///
/// Closing of selected active position if seleted asynch mode.
///
bool AsynchClose(HedgeTradeRequest& request)
{
   CurrentPosition.ExitComment(request.exit_comment, false);
   ENUM_HEDGE_ERR err = CurrentPosition.AddTask(new TaskClosePartPosition(CurrentPosition, request.volume, true));
   hedgeErr = err;
   if(hedgeErr == HEDGE_ERR_NOT_ERROR)
      return true;
   return false;
}

bool SynchClose(HedgeTradeRequest& request)
{
   //Если необходимо изменяем комментарий у стоп-ордера.
   bool res = false;
   if(CurrentPosition.ExitComment() != request.exit_comment)
   {
      CurrentPosition.ExitComment(request.exit_comment, true, request.asynch_mode);
      if(!SynchEmulator(CurrentPosition))
         return false;
   }
   ENUM_HEDGE_ERR err = CurrentPosition.AddTask(new TaskClosePartPosition(CurrentPosition, request.volume, false));
   if(err == HEDGE_ERR_NOT_ERROR)
      return SynchEmulator(CurrentPosition);
   return false;
}
///
/// Эмулятор синхронного выполнения задачи. Сопровождает задачу позиции
/// до полного ее выполнения, либо провала.
/// \return Истина, если задача была выполнена успешно и ложь в противном случае.
/// 
bool SynchEmulator(Position* pos)
{
   if(CheckPointer(pos)==POINTER_INVALID)
      return true;
   Task2* task = pos.GetTask();
   if(CheckPointer(task) == POINTER_INVALID)
      return true;
   if(task.AsynchMode())
      return true;
   //Асинхорнный режим отключен? - Выполняем задачу дальше.
   for(int i = 0; i < 20; i++)
   {
      api.OnRefresh();
      if(CheckPointer(task) == POINTER_INVALID)      
         return true;
      if(task.Status() == TASK_STATUS_FAILED)
      {
         printf("Task failed.");
         hedgeErr = HEDGE_ERR_TASK_FAILED;
         return false;
      }
      if(task.Status() == TASK_STATUS_COMPLETE)
         return true;
      if(task.Status() == TASK_STATUS_WAITING)      
         task.Execute();
      else
      {
         //LogWriter("Task is hung. Try sleep 200 msec and continue.", MESSAGE_TYPE_ERROR);
         Sleep(200);
         continue;
      }
   }
   LogWriter("Attempts end. Failed task.", MESSAGE_TYPE_ERROR);
   return false;
}

///
/// Selected order in current position by it type.
/// \return True - if order was selected, otherwise false.
///
bool HedgeOrderSelect(ENUM_ORDER_SELECTED_TYPE type)export
{
   if(!CheckPosition())
      return false;
   hedgeErr = HEDGE_ERR_TRANS_NOTFIND;
   switch(type)
   {
      case ORDER_SELECTED_INIT:
         CurrentOrder = CurrentPosition.EntryOrder();
         return true;
      case ORDER_SELECTED_CLOSED:
         if(CurrentPosition.Status() != POSITION_HISTORY)
            return false;
         CurrentOrder = CurrentPosition.ExitOrder();
         return true;
      case ORDER_SELECTED_SL:
         if(!CurrentPosition.UsingStopLoss())
            return false;
         CurrentOrder = CurrentPosition.StopOrder();
         return true;
   }
   return false;
}

bool HedgeDealSelect(int index) export
{
   if(!CheckOrder())
      return false;
   int total = CurrentOrder.DealsTotal();
   if(index < 0 || index >= total)
   {
      hedgeErr = HEDGE_ERR_WRONG_INDEX;
      return false;
   }
   CurrentDeal = CurrentOrder.DealAt(index);
   return true;
}

ulong HedgePositionGetInteger(ENUM_HEDGE_POSITION_PROP_INTEGER property) export
{
   if(!CheckPosition())
      return 0;
   switch(property)
   {
      case HEDGE_POSITION_MAGIC:
         return CurrentPosition.Magic();
      case HEDGE_POSITION_ENTRY_TIME_SETUP_MSC:
         return CurrentPosition.EntryExecutedTime();
      case HEDGE_POSITION_ENTRY_TIME_EXECUTED_MSC:
         return CurrentPosition.EntryExecutedTime();
      case HEDGE_POSITION_ID:
      case HEDGE_POSITION_ENTRY_ORDER_ID:
         return CurrentPosition.GetId();
      case HEDGE_POSITION_EXIT_ORDER_ID:
      {
         if(CurrentPosition.Status() != POSITION_HISTORY)
            return 0;
         Order* order = CurrentPosition.ExitOrder();
         return order.GetId();
      }   
      case HEDGE_POSITION_EXIT_TIME_SETUP_MSC:
         return CurrentPosition.ExitExecutedTime(); 
      case HEDGE_POSITION_EXIT_TIME_EXECUTED_MSC:
         return CurrentPosition.ExitExecutedTime();
      case HEDGE_POSITION_CLOSE_TYPE:
         return GetCloseType();
      case HEDGE_POSITION_USING_SL:
         return CurrentPosition.UsingStopLoss();
      case HEDGE_POSITION_USING_TP:
         return CurrentPosition.UsingTakeProfit(); 
      case HEDGE_POSITION_TYPE:
      {
         Order* inOrder = CurrentPosition.EntryOrder();
         if(inOrder != NULL)
            return inOrder.OrderType();
      }
      case HEDGE_POSITION_DIRECTION:
         return GetDirection();
      case HEDGE_POSITION_ACTIONS_TOTAL:
      {
         TaskLog* taskLog = CurrentPosition.GetTaskLog();
         if(CheckPointer(taskLog) == POINTER_INVALID)
            return 0;
         return taskLog.Total();
      }
      case HEDGE_POSITION_TASK_STATUS:
      {
         TaskLog* taskLog = CurrentPosition.GetTaskLog();
         return taskLog.Status();
      }
      case HEDGE_POSITION_STATUS:
         if(CurrentPosition.Status() == POSITION_HISTORY)
            return POS_HEDGE_HISTORY;
         else return POS_HEDGE_ACTIVE;
   }
   return 0;
}

ENUM_TRANS_DIRECTION GetDirection()
{
   ENUM_TRANS_DIRECTION dir = TRANS_NDEF;
   switch(CurrentPosition.Direction())
   {
      case DIRECTION_LONG:
         dir = TRANS_LONG;
         break;
      case DIRECTION_SHORT:
         dir = TRANS_SHORT;
         break;
      case DIRECTION_NDEF:
         dir = TRANS_NDEF;
         break;
   }
   return dir;
}

ENUM_CLOSE_TYPE GetCloseType()
{
   if(CurrentPosition.Status() != POSITION_HISTORY)
   {
      hedgeErr = HEDGE_ERR_WRONG_PARAMETER;
      return 0;
   }
   Order* eOrder = CurrentPosition.ExitOrder();
   if(eOrder.IsStopLoss())
      return CLOSE_AS_STOP_LOSS;
   if(eOrder.IsTakeProfit())
      return CLOSE_AS_TAKE_PROFIT;
   return CLOSE_AS_MARKET;
}

double HedgePositionGetDouble(ENUM_HEDGE_POSITION_PROP_DOUBLE property) export
{
   if(!CheckPosition())
      return 0.0;
   switch(property)
   {
      case HEDGE_POSITION_VOLUME:
         return CurrentPosition.VolumeExecuted();
      case HEDGE_POSITION_PRICE_OPEN:
         return CurrentPosition.EntryExecutedPrice();
      case HEDGE_POSITION_PRICE_CLOSED:
         return CurrentPosition.ExitExecutedPrice();
      case HEDGE_POSITION_PRICE_CURRENT:
         return CurrentPosition.CurrentPrice();
      case HEDGE_POSITION_SL:
         return CurrentPosition.StopLossLevel();
      case HEDGE_POSITION_TP:
         return CurrentPosition.TakeProfitLevel();
      case HEDGE_POSITION_SLIPPAGE:
         return CurrentPosition.Slippage();
      case HEDGE_POSITION_COMMISSION:
         return CurrentPosition.Commission();
      case HEDGE_POSITION_PROFIT_CURRENCY:
         return CurrentPosition.ProfitInCurrency();
      case HEDGE_POSITION_PROFIT_POINTS:
         return CurrentPosition.ProfitInPips();
   }
   return 0.0;
}

string HedgePositionGetString(ENUM_HEDGE_POSITION_PROP_STRING property) export
{
   if(!CheckPosition())
      return "";
   switch(property)
   {
      case HEDGE_POSITION_SYMBOL:
         return CurrentPosition.Symbol();
      case HEDGE_POSITION_ENTRY_COMMENT:
         return CurrentPosition.EntryComment();
      case HEDGE_POSITION_EXIT_COMMENT:
         return CurrentPosition.ExitComment();
   }
   return "";
}

ulong HedgeOrderGetInteger(ENUM_HEDGE_ORDER_PROP_INTEGER type)export
{
   if(!CheckOrder())
      return 0;
   switch(type)
   {
      case HEDGE_ORDER_ID:
         return CurrentOrder.GetId();
      case HEDGE_ORDER_STATUS:
         if(CurrentOrder.Status() == ORDER_PENDING)
            return ORDER_HEDGE_PENDING;
         return ORDER_HEDGE_HISTORY;
      case HEDGE_ORDER_DEALS_TOTAL:
         return CurrentOrder.DealsTotal();
      case HEDGE_ORDER_TIME_SETUP_MSC:
         return CurrentOrder.TimeSetup();
      case HEDGE_ORDER_TIME_EXECUTED_MSC:
         return CurrentOrder.TimeExecuted();
      case HEDGE_ORDER_TIME_CANCELED_MSC:
         return CurrentOrder.TimeCanceled();
   }
   return 0;
}

double HedgeOrderGetDouble(ENUM_HEDGE_ORDER_PROP_DOUBLE type)export
{
   if(!CheckOrder())
      return 0.0;
   switch(type)
   {
      case HEDGE_ORDER_VOLUME_SETUP:
         return CurrentOrder.VolumeSetup();
      case HEDGE_ORDER_VOLUME_EXECUTED:
         return CurrentOrder.VolumeExecuted();
      case HEDGE_ORDER_VOLUME_REJECTED:
         return CurrentOrder.VolumeReject();
      case HEDGE_ORDER_PRICE_SETUP:
         return CurrentOrder.PriceSetup();
      case HEDGE_ORDER_PRICE_EXECUTED:
         return CurrentOrder.EntryExecutedPrice();
      case HEDGE_ORDER_COMMISSION:
         return CurrentOrder.Commission();
      case HEDGE_ORDER_SLIPPAGE:
         return CurrentOrder.Slippage();
   }
   return 0.0;
}

ulong HedgeDealGetInteger(ENUM_HEDGE_DEAL_PROP_INTEGER type) export
{
   if(!CheckDeal())
      return 0;
   switch(type)
   {
      case HEDGE_DEAL_ID:
         return CurrentDeal.GetId();
      case HEDGE_DEAL_TIME_EXECUTED_MSC:
         return CurrentDeal.TimeExecuted();
   }
   return 0;
}

double HedgeDealGetDouble(ENUM_HEDGE_DEAL_PROP_DOUBLE type) export
{
   if(!CheckDeal())
      return 0.0;
   switch(type)
   {
      case HEDGE_DEAL_PRICE_EXECUTED:
         return CurrentDeal.EntryExecutedPrice();
      case HEDGE_DEAL_VOLUME_EXECUTED:
         return CurrentDeal.VolumeExecuted();
      case HEDGE_DEAL_COMMISSION:
         return CurrentDeal.Commission();
   }
   return 0.0;
}

void GetActionResult(uint index, ENUM_TARGET_TYPE& target_type, uint& retcode)export
{
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)return;
   TaskLog* taskLog = CurrentPosition.GetTaskLog();
   taskLog.GetRetcode(index, target_type, retcode);
}

void GetResultTarget(uint index, ENUM_TARGET_TYPE &target_type, uint& retcode)export
{
   target_type = TARGET_NDEF;
   retcode = 0;
   if(CheckPointer(CurrentPosition) != POINTER_INVALID)
      return;
   TaskLog* taskLog = CurrentPosition.GetTaskLog();
   if(taskLog.Total() >= index)
      return;
   taskLog.GetRetcode(index, target_type, retcode);
}

int TransactionsTotal(ENUM_MODE_TRADES trades = MODE_TRADES)export
{
   api.OnRefresh();
   switch(trades)
   {
      case MODE_TRADES:
         return api.ActivePosTotal();
      case MODE_HISTORY:
         return api.HistoryPosTotal();
   }
   return 0;
}

ENUM_TRANS_TYPE TransactionType()
{
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
      return TRANS_NOT_DEFINED;
   return TRANS_HEDGE_POSITION;
}

bool TransactionSelect(int index, ENUM_MODE_SELECT select = SELECT_BY_POS, ENUM_MODE_TRADES pool=MODE_TRADES)export
{
   api.OnRefresh();
   if(select == SELECT_BY_POS)
      return SelectByPos(index, pool);
   else if(select == SELECT_BY_TICKET && pool == MODE_TRADES)
   {
      CurrentPosition = api.FindActivePosById(index);
      if(CheckPointer(CurrentPosition) == POINTER_INVALID)
      {
         hedgeErr = HEDGE_ERR_TRANS_NOTFIND;
         return false;
      }
   }
   hedgeErr = HEDGE_ERR_WRONG_PARAMETER;
   return false;
   return false;
}

bool SelectByPos(int index, ENUM_MODE_TRADES pool=MODE_TRADES)
{
   int total = 0;
   if(pool == MODE_TRADES)
   {
      total = api.ActivePosTotal();
      if(index >= total)
      {
         hedgeErr = HEDGE_ERR_WRONG_INDEX;
         return false;
      }
      CurrentPosition = api.ActivePosAt(index);
   }
   if(pool == MODE_HISTORY)
   {
      total = api.HistoryPosTotal();
      if(index >= total)
      {
         hedgeErr = HEDGE_ERR_WRONG_INDEX;
         return false;
      }
      CurrentPosition = api.HistoryPosAt(index);
   }
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
   {
       hedgeErr = HEDGE_ERR_TRANS_NOTSELECTED;
       CurrentPosition = NULL;
       return false;
   }
   return true;
}

bool SendTradeRequest(HedgeTradeRequest& request)export
{
   switch(request.action)
   {
      case REQUEST_CLOSE_POSITION:
         return PositionClose(request);
      case REQUEST_MODIFY_SLTP:
         return ModifySLTP(request);
   }
   return false;
}

bool PositionClose(HedgeTradeRequest& request)
{
   if(!CheckMarketRequest(request))
      return false;
   if(request.asynch_mode)
   {
      printf("Warning! Asynchronise mode enable.");
      return AsynchClose(request);  
   }
   else
      return SynchClose(request);
}
///
/// True if request valid, otherwise false.
///
bool CheckMarketRequest(HedgeTradeRequest& request)
{
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
   {
      hedgeErr = HEDGE_ERR_TRANS_NOTSELECTED;
      return false;
   }
   if(request.exit_comment == NULL)
      request.exit_comment = "";
   request.volume = NormalizeDouble(request.volume, 3);
   double exVol = CurrentPosition.VolumeExecuted();
   bool eqExVol = Math::DoubleEquals(request.volume, exVol);
   bool eqNull = Math::DoubleEquals(request.volume, 0.0);
   
   if((!eqExVol && request.volume > exVol) ||
      (!eqNull && request.volume < 0.0))
   {
      hedgeErr = HEDGE_ERR_WRONG_VOLUME;
      return false;
   }
   if(eqNull || eqExVol)
      request.volume = exVol;
   double step = SymbolInfoDouble(CurrentPosition.Symbol(), SYMBOL_VOLUME_STEP);
   if(request.volume < step)
   {
      hedgeErr = HEDGE_ERR_WRONG_VOLUME;
      return false;
   }
   return true;
}
///
/// Модифицирует или устанавливает уровни тейк-профита/стоп-лосса.
///
bool ModifySLTP(HedgeTradeRequest& request)
{
   bool res = false;
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
   {
      hedgeErr = HEDGE_ERR_TRANS_NOTSELECTED;
      return res;
   }
   string oldComment = CurrentPosition.ExitComment();
   if(request.exit_comment != NULL && request.exit_comment != "")
      CurrentPosition.ExitComment(request.exit_comment, true, request.asynch_mode);
   //No changes?
   if(oldComment == CurrentPosition.ExitComment() &&
      Math::DoubleEquals(CurrentPosition.StopLossLevel(), request.sl)&&
      Math::DoubleEquals(CurrentPosition.TakeProfitLevel(), request.tp))
   {
      hedgeErr = HEDGE_ERR_POS_NO_CHANGES;
      return false;
   }
   if(!Math::DoubleEquals(request.sl, CurrentPosition.StopLossLevel()))
   {
      ulong id = CurrentPosition.GetId();
      hedgeErr = CurrentPosition.StopLossLevel(request.sl, request.asynch_mode);
      if(!SynchEmulator(CurrentPosition))
      {
         LogWriter("Set or modify stop order was failed.", MESSAGE_TYPE_ERROR);
         return false;
      }
      res = true;
   }
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
      return true;
   if(!Math::DoubleEquals(request.tp, CurrentPosition.TakeProfitLevel()))
   {
      hedgeErr = CurrentPosition.TakeProfitLevel(request.tp, true);
      res = true;
   }
   return res;
}

bool ModifyComment(HedgeTradeRequest& request)
{
   bool res = false;
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
      return res;
   return true;
}

