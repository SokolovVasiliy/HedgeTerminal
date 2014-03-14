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

#include "..\Prototypes.mqh"
HedgeManager api;



///
/// Curent position selected HedgePositionSelect function.
///
Position* CurrentPosition;

int EntryOrderDealsTotal(){return 0;}

int ExitOrderDealsTotal(){return 0;}

int lastError;
///
/// Type of last api error.
///
ENUM_HEDGE_ERR hedgeErr;
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
/// \return Count of active and pending api position.
///
int HedgePositionTotal()export
{
   api.OnRefresh();
   return api.ActivePosTotal();
}

///
/// Return count history positions.
/// \return Count of history api position.
///
int HedgeHistoryPositionTotal() export
{
   api.OnRefresh();
   return api.HistoryPosTotal();
}

///
/// Closing of selected active position.
/// \param volume - The volume that you want to close.
/// \param comment - closing comment.
/// \param asynchMode - A flag indicating the asynchronous mode of closing.
/// True if you are want using asynchronous mode, false otherwise.
/// \return True if operation complete successfully, false otherwise.
///
bool HedgePositionClose(double volume, string comment, bool asynchMode=false)
{
   bool res = true;
   /*if(CheckPointer(CurrentPosition) != POINTER_INVALID)
   {
      hedgeErr = HEDGE_ERR_POS_NOTSELECT;
      res = false;
   }
   if(CurrentPosition.Status() == POSITION_NULL ||
      CurrentPosition.Status() == POSITION_HISTORY)
   {
      hedgeErr = HEDGE_ERR_POS_NOTCOMPATIBLE;
      res = false;
   }
   double posVol = CurrentPosition.VolumeExecuted();
   bool isRejected = Math::DoubleEquals(posVol, volume) ||
                   Math::DoubleEquals(volume, 0.0)||
                   volume < 0.0 ||
                   volume > posVol;
   if(isRejected)
   {
      hedgeErr = HEDGE_ERR_WRONG_VOLUME;
      res = false;
   }
   if(res)
   {
      if(asynchMode)
         res = CurrentPosition.AsynchClose(volume, comment);
      else
         res = CurrentPosition.AsynchClose(volume, comment);
   }*/
   return res;
}

///
/// Select active or history position.
/// \return True if selected was successful, false otherwise.
///
bool HedgePositionSelect(int index, ENUM_MODE_SELECT select = SELECT_BY_POS, ENUM_MODE_TRADES pool=MODE_ACTIVE)export
{
   api.OnRefresh();
   if(pool == MODE_ACTIVE)
   {
      if(select == SELECT_BY_POS)
      {
         if(index >= api.ActivePosTotal())
         {
            hedgeErr = HEDGE_ERR_POS_NOTFIND;
            return false;
         }
         CurrentPosition = api.ActivePosAt(index);
         if(CheckPointer(CurrentPosition) == POINTER_INVALID)
         {
            hedgeErr = HEDGE_ERR_POS_NOTCOMPATIBLE;
            CurrentPosition = NULL;
            return false;
         }
         return true;
      }
      return false;
   }
   return false;
}

///
/// Select order in selected position
///
///
bool HedgeOrderSelect()
{
   return true;
}

ulong HedgePositionGetInteger(ENUM_HEDGE_POSITION_PROP_INTEGER property) export
{
   if(CheckPointer(CurrentPosition) == POINTER_INVALID)
   {
      hedgeErr = HEDGE_ERR_POS_NOTFIND;
      return 0;
   }
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
   //CurrentPosition.AsynchClose(request.volume, request.comment);
   return true;
}