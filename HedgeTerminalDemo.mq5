#property copyright  "Copyright 2013-2015, Vasiliy Sokolov, St.Petersburg, Russia."
#property link      "https://login.mql5.com/ru/users/c-4"
#property version   "1.11"
#define VERSION "HedgeTerminal 1.11"
#property description "HedgeTerminal is designed for hedging net positions in MetaTrader 5 and for simple control over expert advisors."
#property description "DEMO version works only on demo accounts. In this limited version only AUDCAD and VTBR-* symbols can be used. History of positions is limited to the last 10 records. Please purchase full-featured version for real trading and technical support."

#property icon ".\\img\\HedgeTerminalDemo64x64.ico"
///
/// Компиляция демонстрационной версии терминала.
///
#define DEMO
#include "HedgeTerminal.mqh"