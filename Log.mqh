//+------------------------------------------------------------------+
//|                                                      HedgePanel� |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+
#include <Arrays\ArrayString.mqh>
///
/// ���������� ������ ���� ������. ��������� �������� �� �����
///
#define MESSAGE_NOTHING 0
///
/// ���������� ����� ��������� � ���-����
///
#define MESSAGE_FILE 1

///
/// ���������� ����� ��������� � �������� MetaTrader
///
#define MESSAGE_TERMINAL 2

///
/// ������� ���� ���������: ������ � ��� ���� ��� (�) ����� � ���� ���������. 
///
int CurrentOutput = MESSAGE_FILE | MESSAGE_TERMINAL;

///
/// ���������� ������� ���������.
///
enum ENUM_MESSAGE_LEVEL
{
   ///
   /// ��������� ��������������, ��������������� ��������� � ��������� �� �������.
   ///
   INFO_AND_MORE,
   ///
   /// ��������� ��������������� ��������� � ��������� �� �������.
   ///
   WARNING_AND_MORE,
   ///
   /// ��������� ������ ��������� �� �������
   ///
   ERROR_ONLY,
   ///
   ///
   ///
   NOTHING_MESSAGE
};

///
/// ��� ���������� ���������.
///
enum ENUM_MESSAGE_TYPE
{
   ///
   /// �������������� ���������.
   ///
   MESSAGE_TYPE_INFO,
   ///
   /// ��������������� ���������.
   ///
   MESSAGE_TYPE_WARNING,
   ///
   /// ��������� �� ������.
   ///
   MESSAGE_TYPE_ERROR
};

///
/// ���������� ��������� � ��� (��������� ����)
///
void LogWriter(string message, ENUM_MESSAGE_TYPE type)
{
   if(type == MESSAGE_TYPE_ERROR && _LastError != 0)
   {
      message += ". LastError: " + (string)_LastError;
      ResetLastError();
   }
   // ���� ������� ����� � ���� - ��������� ���� � ���������� � ���� ���������.
   if((CurrentOutput & MESSAGE_FILE) == MESSAGE_FILE)
   {
      //return;
   }
   // ���� ������� ����� � �������� - ���������� ��������� � ��������.
   // � ���������� ����� ����� ������������� � ����������� ���-�������.
   if((CurrentOutput & MESSAGE_TERMINAL) == MESSAGE_TERMINAL)
   {
      Print(message);
   }
}



CArrayString logs;

CArrayString* TraceGetStack()
{
   return GetPointer(logs);
}

void TracePop()
{
   int total = logs.Total();
   if(total > 0)
      logs.Delete(total-1);
}

void TracePush(string fname)
{
   logs.Add(fname);
}


