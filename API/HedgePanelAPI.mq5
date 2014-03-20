//+------------------------------------------------------------------+
//|                                                HedgePanelAPI.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

//#define HLIBRARY
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
int ActivePositionsTotal()export
{
   api.OnRefresh();
   return api.ActivePosTotal();
}

///
/// Return count history positions.
/// \return Count of history api position.
///
int HistoryPositionsTotal() export
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
bool HedgePositionClose(HedgeClosingRequest& request)
{
   if(request.volume < 0.0 || request.volume > CurrentPosition.VolumeExecuted())
   {
      LogWriter("request failed. Volume must be more 0.0 and less executed volume", MESSAGE_TYPE_ERROR);
      return false;
   }
   double vol;
   if(Math::DoubleEquals(request.volume, 0.0) || Math::DoubleEquals(request.volume, CurrentPosition.VolumeExecuted()))
      vol = CurrentPosition.VolumeExecuted();
   else vol = request.volume;
   //CurrentPosition.AddTask(new TaskClosePartPosition();
   bool res = false;
   return res;
}

///
/// Select active or history position.
/// \return True if selected was successful, false otherwise.
///
bool HedgePositionSelect(int index, ENUM_MODE_SELECT select = SELECT_BY_POS, ENUM_MODE_TRADES pool=MODE_TRADES)export
{
   api.OnRefresh();
   if(pool == MODE_TRADES)
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
/// Return true if position was selected, otherwise false.
///
bool HedgePositionSelect(void)export
{
   if(CheckPointer(CurrentPosition)!= POINTER_INVALID)
      return true;
   return false;
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
      case HEDGE_POSITION_TYPE:
      {
         Order* inOrder = CurrentPosition.EntryOrder();
         if(inOrder != NULL)
            return inOrder.OrderType();
      }
   }
   return 0;
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
