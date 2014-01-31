//+------------------------------------------------------------------+
//|                                                   Prototypes.mqh |
//|                           Copyright 2013, Vasiliy Sokolov (C-4). |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Vasiliy Sokolov"
#property link      "https://login.mql5.com/ru/users/c-4"

///
/// Define type of parameter 'index' in function HedgePositionSelect().
///
enum ENUM_MODE_SELECT
{
   ///
   /// Parameter 'index' contains entry ticket of position. 
   ///
   SELECT_BY_POS,
   ///
   /// Parameter 'index' equal index of position in list positions. 
   ///
   SELECT_BY_TICKET
};

///
/// Define type of list wherein function HedgePositionSelect find position. 
///
enum ENUM_MODE_TRADES
{
   ///
   /// Order selected from trading pool(opened and pending orders).
   ///
   MODE_ACTIVE,
   ///
   /// Order selected from history pool (closed and canceled order).
   ///
   MODE_HISTORY
};

///
/// Define type integer property of hedge position.
/// This enum is analog ENUM_POSITION_PROPERTY_INTEGER and used by
/// HedgePositionGetInteger function.
///
enum ENUM_HEDGE_POSITION_PROP_INTEGER
{
   HEDGE_POSITION_ENTRY_TIME_SETUP,
   HEDGE_POSITION_ENTRY_TIME_EXECUTED,
   HEDGE_POSITION_EXIT_TIME_SETUP,
   HEDGE_POSITION_EXIT_TIME_EXECUTED,
   HEDGE_POSITION_TYPE,
   HEDGE_POSITION_MAGIC,
   HEDGE_POSITION_ENTRY_ORDER,
   HEDGE_POSITION_EXIT_ORDER,
   HEDGE_POSITION_STATUS,
   HEDGE_POSITION_DEALS_TOTAL
};

///
/// Define type double property of hedge position.
/// This enum is analog ENUM_POSITION_PROPERTY_DOUBLE and used by
/// HedgePositionGetDouble function.
///
enum ENUM_HEDGE_POSITION_PROP_DOUBLE
{
   HEDGE_POSITION_VOLUME,
   HEDGE_POSITION_PRICE_OPEN,
   HEDGE_POSITION_SL,
   HEDGE_POSITION_TP,
   HEDGE_POSITION_PRICE_CURRENT,
   HEDGE_POSITION_COMMISSION,
   HEDGE_POSITION_SWAP,
   HEDGE_POSITION_PROFIT_CURRENCY,
   HEDGE_POSITION_PROFIT_POINTS
};

///
/// Define type string property of hedge position.
/// This enum is analog ENUM_POSITION_PROPERTY_STRING and used by
/// HedgePositionGetString function.
///
enum ENUM_HEDGE_POSITION_PROP_STRING
{
   HEDGE_POSITION_SYMBOL,
   HEDGE_POSITION_ENTRY_COMMENT,
   HEDGE_POSITION_EXIT_COMMENT
};

///
/// Define type integer property of hedge notion deal.
/// This enum is analog ENUM_DEAL_PROPERTY_INTEGER and used by
/// HedgeDealGetInteger function.
///
enum ENUM_HEDGE_DEAL_PROP_INTEGER
{
   HEDGE_DEAL_ORDER,
   HEDGE_DEAL_TIME,
   HEDGE_DEAL_TIME_MSC,
   HEDGE_DEAL_TYPE,
   HEDGE_DEAL_ENTRY,
   HEDGE_DEAL_MAGIC
};

///
/// Define type double property of hedge notion deal.
/// This enum is analog ENUM_DEAL_PROPERTY_DOUBLE and used by
/// HedgeDealGetDouble function.
///
enum ENUM_HEDGE_DEAL_PROP_DOUBLE
{
   HEDGE_DEAL_VOLUME,
   HEDGE_DEAL_PRICE,
   HEDGE_DEAL_PROFIT
};

///
/// Define type string property of hedge notion deal.
/// This enum is analog ENUM_DEAL_PROPERTY_STRING and used by
/// HedgeDealGetString function.
///
enum ENUM_HEDGE_DEAL_PROP_STRING
{
   HEDGE_DEAL_SYMBOL,
   HEDGE_DEAL_COMMENT
};

///
/// Define type of action in struct HedgeTradeRequest.
/// This enum is analog ENUM_TRADE_REQUEST_ACTIONS and used
/// by OrderSendFunction.
///
enum ENUM_HEDGE_REQUEST_ACTIONS
{
   HEDGE_ACTION_DEAL,
   HEDGE_ACTION_PENDING,
   HEDGE_ACTION_SLTP,
   HEDGE_ACTION_MODIFY,
   HEDGE_ACTION_REMOVE,
   HEDGE_ACTION_CLOSE
};

enum ENUM_HEDGE_ORDER_TYPE
{
   HEDGE_ORDER_INIT,
   HEDGE_ORDER_CLOSED
};

///
/// Type of error genered of HedgePanel.
///
enum ENUM_HEDGE_ERR
{
   ///
   /// Request position not find.
   ///
   HEDGE_ERR_POS_NOTFIND,
   ///
   /// Position not select.
   ///
   HEDGE_ERR_POS_NOTSELECT,
   ///
   /// Selected position not compatible with current operation.
   ///
   HEDGE_ERR_POS_NOTCOMPATIBLE,
   ///
   /// Wrong setting of volume.
   ///
   HEDGE_ERR_WRONG_VOLUME
};
///
/// The Trade Request Structure used by HedgeOrderSend function.
/// This structure is analog of MqlTradeRequest structure and using
/// for managment hedge open position.
///
struct HedgeTradeRequest
{
   ENUM_HEDGE_REQUEST_ACTIONS action;
   bool asynch_mode;
   uint magic;
   ulong order;
   string symbol;
   double volume;
   double price;
   double sl;
   double tp;
   ulong deviation;
   ENUM_ORDER_TYPE type;
   ENUM_ORDER_TYPE_FILLING type_filling;
   ENUM_ORDER_TYPE_TIME type_time;
   datetime expiration;
   string comment;
};


#import "\API\HedgePanelAPI.ex5"
   int HedgePositionTotal(void);
   int HedgeHistoryPositionTotal(void);
   ulong HedgePositionGetInteger(ENUM_HEDGE_POSITION_PROP_INTEGER property);
   double HedgePositionGetDouble(ENUM_HEDGE_POSITION_PROP_DOUBLE property);
   string HedgePositionGetString(ENUM_HEDGE_POSITION_PROP_STRING property);
   bool HedgePositionSelect(int index, ENUM_MODE_SELECT select = SELECT_BY_POS, ENUM_MODE_TRADES pool=MODE_ACTIVE);
   bool HedgeOrderSend(HedgeTradeRequest& hrequest, MqlTradeResult& result);
#import