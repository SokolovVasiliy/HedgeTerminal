//+------------------------------------------------------------------+
//|                                                      XmlBase.mqh |
//|                                                   yu-sha@ukr.net |
//+------------------------------------------------------------------+
//             Библиотека предназначена для парсинга XML документов.
// пример использования:
// CXmlDocument doc;
// doc.CreateFromFile (...);
// doc.DocumentElement.Elements[i].Text - получить содержимое i-го элемента

#include "XmlAttribute.mqh"
#include "XmlElement.mqh"
#include "XmlDocument.mqh"