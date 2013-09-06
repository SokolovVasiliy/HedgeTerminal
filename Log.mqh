//+------------------------------------------------------------------+
//|                                                      HedgePanel© |
//|          Copyright 2013, Vasiliy Sokolov, St.Petersburg, Russia. |
//|                                           e-mail: vs-box@mail.ru |
//|                              https://login.mql5.com/ru/users/c-4 |
//+------------------------------------------------------------------+
#include <Arrays\ArrayString.mqh>
///
/// Определяет пустой путь вывода. Сообщение выведено не будет
///
#define MESSAGE_NOTHING 0
///
/// Определяет вывод сообщения в лог-файл
///
#define MESSAGE_FILE 1

///
/// Определяет вывод сообщения в терминал MetaTrader
///
#define MESSAGE_TERMINAL 2

///
/// Текущий путь сообщений: запись в лог файл или (и) вывод в окне терминала. 
///
int CurrentOutput = MESSAGE_FILE | MESSAGE_TERMINAL;

///
/// Определяет уровень сообщения.
///
enum ENUM_MESSAGE_LEVEL
{
   ///
   /// Выводятся информационные, предупреждающие сообщения и сообщения об ошибках.
   ///
   INFO_AND_MORE,
   ///
   /// Выводятся предупреждающие сообщения и сообщения об ошибках.
   ///
   WARNING_AND_MORE,
   ///
   /// Выводятся только сообщения об ошибках
   ///
   ERROR_ONLY,
   ///
   ///
   ///
   NOTHING_MESSAGE
};

///
/// Тип выводимого сообщения.
///
enum ENUM_MESSAGE_TYPE
{
   ///
   /// Информационное сообщение.
   ///
   MESSAGE_TYPE_INFO,
   ///
   /// Предупреждающее сообщение.
   ///
   MESSAGE_TYPE_WARNING,
   ///
   /// Сообщение об ошибке.
   ///
   MESSAGE_TYPE_ERROR
};

///
/// Записывает сообщение в лог (текстовой файл)
///
void LogWriter(string message, ENUM_MESSAGE_TYPE type)
{
   if(type == MESSAGE_TYPE_ERROR && _LastError != 0)
   {
      message += ". LastError: " + (string)_LastError;
      ResetLastError();
   }
   // Если включен вывод в файл - открываем файл и записываем в него сообщение.
   if((CurrentOutput & MESSAGE_FILE) == MESSAGE_FILE)
   {
      //return;
   }
   // Если включен вывод в терминал - записываем сообщение в терминал.
   // В дальнейшем вывод будет осуществлятся в собственную лог-таблицу.
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


