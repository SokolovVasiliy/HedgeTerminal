//+------------------------------------------------------------------+
//|                                          ActivePositionsLoop.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#define POS_NAME ("ht_" + (string)pos_id)
#define TP_NAME ("ht_" + (string)pos_id + "_tp")
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
//+------------------------------------------------------------------+
//| ��������� ������ �������� �������. ��������� � �������� ������   |
//| ��� ��������� ������ �������� �������:                           |
//| 1. ����� ���������� �������� �������                             |
//| 2. ������� ����-������ �������� �������                          |
//+------------------------------------------------------------------+
class CLocalLoop
{
private:
public:
   void DeleteRecord(ulong pos_id);
   void SaveState(ulong pos_id, datetime blocktime, double tp);
   bool LoadState(ulong pos_id, datetime& blocktime, double& tp);
};
//+------------------------------------------------------------------+
//| ��������� ��������� ��������� ������� � ���������� ����������    |
//+------------------------------------------------------------------+
bool CLocalLoop::LoadState(ulong pos_id,datetime &blocktime,double &tp)
{
   if(!GlobalVariableCheck(POS_NAME))
      return false;
   DblStr dbl;
   GlobalVariableGet(POS_NAME, dbl.dbl);
   DateStr date;
   date = (DateStr)dbl;
   tp = 0.0;
   if(GlobalVariableCheck(TP_NAME))
      GlobalVariableGet(TP_NAME, tp);
   return true;
}

//+------------------------------------------------------------------+
//| ��������� ��������� ��������� ������� � ���������� ����������    |
//+------------------------------------------------------------------+
void CLocalLoop::SaveState(ulong pos_id, datetime blocktime, double tp)
{
   DateStr date;
   date.dt = blocktime;
   DblStr dbl = (DblStr)date;
   GlobalVariableSet(POS_NAME, dbl.dbl);
   if(tp > 0.0)
      GlobalVariableSet(TP_NAME, tp);
}
//+------------------------------------------------------------------+
//| ������� ������ �� �������� ������� �� ���������� ����������      |
//| ���������                                                        |
//+------------------------------------------------------------------+
void CLocalLoop::DeleteRecord(ulong pos_id)
{
   if(GlobalVariableCheck(POS_NAME))
      GlobalVariableDel(POS_NAME);
   if(GlobalVariableCheck(TP_NAME))
      GlobalVariableDel(TP_NAME);
}