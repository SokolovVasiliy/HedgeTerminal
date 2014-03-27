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
#include "TaskLog.mqh"

///
/// 
///
//#define 
 
HedgeManager api;

///
/// Curent position selected HedgePositionSelect function.
///
Position* CurrentPosition;

int EntryOrderDealsTotal(){return 0;}

int ExitOrderDealsTotal(){return 0;}

//int lastError;
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
/// Return count active and pending positions.
/// \return Count of active and pending api position.
///
int ActivePositionsTotal(void)export
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
bool HedgePositionClose(HedgeClosingRequest& request)export
{
   if(!CheckRequest(request))return false;
   CurrentPosition.ExitComment(request.exit_comment);
   bool res = CurrentPosition.AddTask(new TaskClosePartPosition(CurrentPosition, request.volume));
   return res;
}

///
/// True if request valid, otherwise false.
///
bool CheckRequest(HedgeClosingRequest& request)
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
/// Select active or history position.
/// \return True if selected was successful, false otherwise.
///
bool HedgePositionSelect(int index, ENUM_MODE_SELECT select = SELECT_BY_POS, ENUM_MODE_TRADES pool=MODE_TRADES)export
{
   api.OnRefresh();
   //printf("Select " + index + " " + EnumToString(select) + " " + EnumToString(pool));
   if(pool == MODE_TRADES)
   {
      if(select == SELECT_BY_POS)
      {
         //printf("Active total: " + api.ActivePosTotal());
         if(index >= api.ActivePosTotal())
         {
            hedgeErr = HEDGE_ERR_WRONG_INDEX;
            return false;
         }
         CurrentPosition = api.ActivePosAt(index);
         if(CheckPointer(CurrentPosition) == POINTER_INVALID)
         {
            hedgeErr = HEDGE_ERR_TRANS_NOTSELECTED;
            CurrentPosition = NULL;
            return false;
         }
         return true;
      }
      else if(select == SELECT_BY_TICKET)
      {
         CurrentPosition = api.FindActivePosById(index);
         if(CheckPointer(CurrentPosition) == POINTER_INVALID)
         {
            hedgeErr = HEDGE_ERR_TRANS_NOTFIND;
            return false;
         }
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
      hedgeErr = HEDGE_ERR_TRANS_NOTSELECTED;
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
      case HEDGE_POSITION_ACTIONS_TOTAL:
      {
         TaskLog* taskLog = CurrentPosition.GetTaskLog();
         return taskLog.Total();
      }
      case HEDGE_POSITION_TASK_STATUS:
      {
         TaskLog* taskLog = CurrentPosition.GetTaskLog();
         return taskLog.Status();
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

void GetActionResult(uint index, ENUM_TARGET_TYPE& target_type, uint& retcode)export
{
   if(CheckPointer(CurrentPosition))return;
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
