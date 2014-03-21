//+------------------------------------------------------------------+
//|                                                   Prototypes.mqh |
//|                           Copyright 2013, Vasiliy Sokolov (C-4). |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Vasiliy Sokolov"
#property link      "https://login.mql5.com/ru/users/c-4"

///
/// Targets ID.
///
enum ENUM_TARGET_TYPE
{
   ///
   /// Not define target.
   ///
   TARGET_NDEF,
   ///
   /// Delete pending order.
   ///
   TARGET_DELETE_PENDING_ORDER,
   ///
   /// Set pending order.
   ///
   TARGET_SET_PENDING_ORDER,
   ///
   /// Change price of pending order.
   ///
   TARGET_MODIFY_PENDING_ORDER,
   ///
   /// Trade by market.
   ///
   TARGET_TRADE_BY_MARKET
};

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
   /// Position selected from trading pool.
   ///
   MODE_TRADES,
   ///
   /// Position selected from history pool (closed and canceled order).
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
/// This enum mark closing order as special order type.
///
enum ENUM_CLOSE_TYPE
{
   ///
   /// Mark closing position as market.
   ///
   CLOSE_AS_MARKET,
   ///
   /// Mark closing position as stop-loss.
   ///
   CLOSE_AS_STOP_LOSS,
   ///
   /// Mark closing position as take-profit.
   ///
   CLOSE_AS_TAKE_PROFIT,
};

///
/// This structure used by HedgePositionClose function.
/// This structure define params which need for closing hedge position.
///
struct HedgeClosingRequest
{
   ///
   /// Volume of position to be closed. May be less or equal than executed volume position.
   /// If equal 0.0 closing all executed volume position.
   ///
   double volume;
   ///
   /// Outgoing comment.
   ///
   string exit_comment;
   ///
   /// Marker of closing order. See ENUM_CLOSE_TYPE description.
   ///
   ENUM_CLOSE_TYPE close_type;
   ///
   /// True if the closure is performed asynchronously, otherwise false.
   ///
   bool asynch_mode;
};


#import ".\API\HedgePanelAPI.ex5"
   int ActivePositionsTotal(void);
   int HistoryPositionsTotal(void);
   ulong HedgePositionGetInteger(ENUM_HEDGE_POSITION_PROP_INTEGER property);
   double HedgePositionGetDouble(ENUM_HEDGE_POSITION_PROP_DOUBLE property);
   string HedgePositionGetString(ENUM_HEDGE_POSITION_PROP_STRING property);
   ///
   /// Select hedge position from hedge terminal history.
   ///
   bool HedgePositionSelect(int index, ENUM_MODE_SELECT select = SELECT_BY_POS, ENUM_MODE_TRADES pool=MODE_TRADES);
   ///
   /// Return true if position was selected, otherwise false.
   ///
   bool HedgePositionSelect(void);
   ///
   /// Closing hedge position. The position should be selected.
   /// \param request - define params which need for closing hedge position.
   ///
   bool HedgePositionClose(HedgeClosingRequest& request);
   ///
   /// Return count actions of last task, if task was executed. Current position should be selected.
   /// This function is used for the analysis of trade and the possible errors.
   /// \return Count of last task;
   ///
   uint TotalActionsTask(void);
   ///
   /// Get result of target by it's index 'index'. The values returned by reference.
   /// Current position should be selected. This function is used for the analysis of trade and the possible errors.
   /// \param index - Index of target in last task.
   /// \param target_type - Type of target.
   /// \param retcode - Result of executed target. This value return codes of the Trade Server in MetaTrader 5.
   /// You can see the constant code in documentation 'http://www.mql5.com/en/docs/constants/errorswarnings/enum_trade_return_codes'
   void GetResultTarget(uint index, ENUM_TARGET_TYPE &target_type, uint& retcode);
#import