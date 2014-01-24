//+------------------------------------------------------------------+
//|                                                HedgePanelAPI.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

//#define DEBUG
#define HLIBRARY
#include "..\Globals.mqh"

#include "..\Prototypes.mqh"
HedgeManager hedge;


///
/// Modify active and pending hedge position.
/// \param index - index of position in list active and pending hedge position.
/// \param price - new price entry for pending hedge position.
/// \param stoploss - new level stop-loss for active and pending hedge position.
/// \param takeprofit - new level take-profit for active and pending hedge position.
/// \param expiration - time expiration for pending hedge position.
/// \param isAsync - true if the modification of position in asynchronously mode, otherwise false.
/// \return True if the modification is successful, otherwise false.
///
/*bool HedgePositionModify(int index, double price, double stoploss, double takeprofit, datetime expiration, bool isAsync=false)
{
   return true;
}*/

///
/// Close active hedge position.
/// \param index - index of active position in list active and pending positions which must be closed.
/// \param lots - volume which must be closed.
/// \param slipage - max slippage in points of symbol.
/// \param isAsync - true if the closing of position in asynchronously mode, otherwise false.
/// \return True if the closing is successful, otherwise false.
///
/*bool HedgePositionClose(int index, double lots, double price, int slippage, bool isAsync=false)
{
   return true;
}*/

///
/// Curent position selected HedgePositionSelect function.
///
Position* CurrentPosition;

int EntryOrderDealsTotal(){return 0;}

int ExitOrderDealsTotal(){return 0;}

int lastError;
///
/// Return code last error.
///
int HedgeGetLastError() export
{
   int error = lastError;
   lastError = 0;
   return error;
}
///
/// Return count active and pending positions.
/// \return Count of active and pending hedge position.
///
int HedgePositionTotal()export
{
   hedge.OnRefresh();
   return hedge.ActivePosTotal();
}

///
/// Return count history positions.
/// \return Count of history hedge position.
///
int HedgeHistoryPositionTotal() export
{
   hedge.OnRefresh();
   return hedge.HistoryPosTotal();
}

///
/// Select active, pending or history position.
/// \return True if selected was successful, false otherwise.
///
bool HedgePositionSelect(int index, ENUM_MODE_SELECT select = SELECT_BY_POS, ENUM_MODE_TRADES pool=MODE_ACTIVE)export
{
   hedge.OnRefresh();
   if(pool == MODE_ACTIVE)
   {
      if(select == SELECT_BY_POS)
      {
         if(index >= hedge.ActivePosTotal())
         {
            lastError = ERR_INTERNAL_ERROR;
            return false;
         }
         CurrentPosition = hedge.ActivePosAt(index);
         if(CheckPointer(CurrentPosition) == POINTER_INVALID)
         {
            lastError = ERR_INTERNAL_ERROR;
            return false;
         }
         return true;
      }
      return false;
   }
   return false;
}

ulong HedgePositionGetInteger(ENUM_HEDGE_POSITION_PROP_INTEGER property) export
{
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
      return 0;
   switch(property)
   {
      case HEDGE_POSITION_MAGIC:
         return CurrentPosition.Magic();
      case HEDGE_POSITION_ENTRY_TIME_SETUP:
         return CurrentPosition.EntryExecutedTime();
      case HEDGE_POSITION_ENTRY_TIME_EXECUTED:
         return CurrentPosition.EntryExecutedTime();
      case HEDGE_POSITION_EXIT_TIME_SETUP:
         return CurrentPosition.ExitExecutedTime(); 
      case HEDGE_POSITION_EXIT_TIME_EXECUTED:
         return CurrentPosition.ExitExecutedTime(); 
   }
   return 0;
}
ulong GetTiks(CTime* time)
{
   if(time == NULL)return 0;
   return time.Tiks();
}

double HedgePositionGetDouble(ENUM_HEDGE_POSITION_PROP_DOUBLE property) export
{
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
      return 0;
   switch(property)
   {
      case HEDGE_POSITION_VOLUME:
         return CurrentPosition.VolumeExecuted();
      case HEDGE_POSITION_PRICE_OPEN:
         return CurrentPosition.EntryExecutedPrice();
      case HEDGE_POSITION_PROFIT_POINTS:
         return CurrentPosition.ProfitInPips();
   }
   return 0;
}

string HedgePositionGetString(ENUM_HEDGE_POSITION_PROP_STRING property) export
{
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
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

bool HedgeDealSelect(int index)
{
   return true;
}


int HedgePositionDealsTotal(){return 0;}

bool HedgePositionEntryDealSelect(int index)
{
   return true;
}

bool HedgePositionExitDealSelect(int index)
{
   return true;
}

CObject* EntryDeals() export
{
   CObject* deals = new CObject();
   return deals;
}

bool HedgeOrderSend(HedgeTradeRequest& hRequest, MqlTradeResult& result) export
{
   printf(EnumToString(hRequest.action));
   switch(hRequest.action)
   {
      case HEDGE_ACTION_SLTP:
         break;
      case HEDGE_ACTION_CLOSE:
         return ClosePos(hRequest, result);
      default:
      {
         MqlTradeRequest mRequest;
         HedgeToMqlRequest(hRequest, mRequest);
         OrderSend(mRequest, result);
         if(result.retcode > 0)
            printf(result.comment);
      }
   }
   return true;
}

void HedgeToMqlRequest(HedgeTradeRequest& hRequest, MqlTradeRequest& mRequest)
{
   switch(hRequest.action)
   {
      case HEDGE_ACTION_DEAL:
         mRequest.action = TRADE_ACTION_DEAL;
         break;
      case HEDGE_ACTION_MODIFY:
         mRequest.action = TRADE_ACTION_MODIFY;
         break;
      case HEDGE_ACTION_PENDING:
         mRequest.action = TRADE_ACTION_PENDING;
         break;
      case HEDGE_ACTION_REMOVE:
         mRequest.action = TRADE_ACTION_REMOVE;
         break;
      case HEDGE_ACTION_SLTP:
         mRequest.action = TRADE_ACTION_SLTP;
         break;
   }
   mRequest.magic = hRequest.magic;
   mRequest.order = hRequest.order;
   mRequest.symbol = hRequest.symbol;
   mRequest.volume = hRequest.volume;
   mRequest.price = hRequest.price;
   mRequest.sl = hRequest.sl;
   mRequest.tp = hRequest.tp;
   mRequest.deviation = hRequest.deviation;
   mRequest.type = hRequest.type;
   mRequest.type_filling = hRequest.type_filling;
   mRequest.type_time = hRequest.type_time;
   mRequest.expiration = hRequest.expiration;
   mRequest.comment = hRequest.comment;
}

bool ClosePos(HedgeTradeRequest& request, MqlTradeResult& result)
{
   if(request.action != HEDGE_ACTION_CLOSE)
   {
      result.retcode = TRADE_RETCODE_INVALID_ORDER;
      result.comment = "Incorrect or prohibited action";
      return false;
   }
   /*if(request.type != ORDER_TYPE_BUY ||
      request.type != ORDER_TYPE_SELL)
   {
      result.retcode = TRADE_RETCODE_INVALID_ORDER;
      result.comment = "Incorrect or prohibited order type";
      return false;
   }*/
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
   {
      result.retcode = TRADE_RETCODE_ERROR;
      result.comment = "Hedge position not selected.";
      return false;
   }
   if(CurrentPosition.Status() == POSITION_NULL)
   {
      result.retcode = TRADE_RETCODE_LOCKED;
      result.comment = "Hedge position is locked.";
      return false;
   }
   if(CurrentPosition.Status() == POSITION_HISTORY)
   {
      result.retcode = TRADE_RETCODE_POSITION_CLOSED;
      result.comment = "Position has already been closed.";
   }
   if(request.volume > CurrentPosition.VolumeExecuted())
   {
      result.retcode = TRADE_RETCODE_INVALID_VOLUME;
      result.comment = "Volume must be less or equal volume of position.";
      return false;
   }
   CurrentPosition.AsynchClose(request.volume, request.comment);
   return true;
}