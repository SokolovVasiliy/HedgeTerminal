//+------------------------------------------------------------------+
//|                                          ActivePositionsLoop.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#define POS_NAME ("ht_" + (string)pos_id)
#define TP_NAME ("ht_" + (string)pos_id + "_tp")
#define COMM_NAME ("ht_" + (string)pos_id + "_comm")
//+------------------------------------------------------------------+
//| Double To datetime                                               |
//+------------------------------------------------------------------+
struct DblStr
{
   double dbl;
};
//+------------------------------------------------------------------+
//| Datetime to double                                               |
//+------------------------------------------------------------------+
struct DateStr
{
   datetime dt;
};
struct CharStr
{
   uchar array[8];
};
//+------------------------------------------------------------------+
//| Ћокальный контур активной позиции. —охран€ет и получает доступ   |
//| дл€ следующих данных активной позиции:                           |
//| 1. врем€ блокировки активной позиции                             |
//| 2. уровень тейк-профит активной позиции                          |
//+------------------------------------------------------------------+
class CLocalLoop
{
private:
   void   SaveComment(string comment, ulong pos_id);
   string LoadComment(ulong pos_id);
public:
   void DeleteRecord(ulong pos_id);
   void SaveState(ulong pos_id, datetime blocktime, double tp, string comment);
   bool LoadState(ulong pos_id, datetime& blocktime, double& tp, string& comment);
};
//+------------------------------------------------------------------+
//| —охран€ет локальное состо€ние позиции в глобальных переменных    |
//+------------------------------------------------------------------+
bool CLocalLoop::LoadState(ulong pos_id,datetime &blocktime,double &tp, string& comment)
{
   if(!GlobalVariableCheck(POS_NAME))
      return false;
   DblStr dbl;
   comment = LoadComment(pos_id);
   GlobalVariableGet(POS_NAME, dbl.dbl);
   DateStr date;
   date = (DateStr)dbl;
   tp = 0.0;
   if(GlobalVariableCheck(TP_NAME))
      GlobalVariableGet(TP_NAME, tp);
   return true;
}

//+------------------------------------------------------------------+
//| —охран€ет локальное состо€ние позиции в глобальных переменных    |
//+------------------------------------------------------------------+
void CLocalLoop::SaveState(ulong pos_id, datetime blocktime, double tp, string comment)
{
   DateStr date;
   date.dt = blocktime;
   DblStr dbl = (DblStr)date;
   SaveComment(comment, pos_id);
   GlobalVariableSet(POS_NAME, dbl.dbl);
   if(tp > 0.0)
      GlobalVariableSet(TP_NAME, tp);
}
//+------------------------------------------------------------------+
//| ”дал€ет запись об активной позиции из глобальных переменных      |
//| терминала                                                        |
//+------------------------------------------------------------------+
void CLocalLoop::DeleteRecord(ulong pos_id)
{
   if(GlobalVariableCheck(POS_NAME))
      GlobalVariableDel(POS_NAME);
   if(GlobalVariableCheck(TP_NAME))
      GlobalVariableDel(TP_NAME);
}
//+------------------------------------------------------------------+
//| —охран€ет комментарий ордера в локальных переменных              |
//+------------------------------------------------------------------+
void CLocalLoop::SaveComment(string comment, ulong pos_id)
{
   comment = StringSubstr(comment, 0, 32);
   uchar ch_array[32];
   StringToCharArray(comment, ch_array, 0);
   for(int i = 0; i < 4; i++)
   {
      CharStr ch;
      ArrayCopy(ch.array, ch_array, 0, i*8, 8);
      DblStr dbl = (DblStr)ch;
      GlobalVariableSet(POS_NAME + "_" +(string)(i+1), dbl.dbl);
   }
}
//+------------------------------------------------------------------+
//| —охран€ет комментарий ордера в локальных переменных              |
//+------------------------------------------------------------------+
string CLocalLoop::LoadComment(ulong pos_id)
{
   uchar ch_array[32];
   for(int i = 0; i < 4; i++)
   {
      if(!GlobalVariableCheck(POS_NAME + "_" +(string)(i+1)))
         break;
      DblStr dbl;
      dbl.dbl = GlobalVariableGet(POS_NAME + "_" +(string)(i+1));
      CharStr ch;
      ch = (CharStr)dbl;
      ArrayCopy(ch_array, ch.array, i*8, 0, 8);
   }
   string comment = CharArrayToString(ch_array);
   return comment;
}