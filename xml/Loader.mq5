//+------------------------------------------------------------------+
//|                                                       Loader.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "XmlBase.mqh"

input string FileName = "test.xml"; //Name of xml file
///
/// Известные секции настроек.
///
enum ENUM_SET_SECTIONS
{
   ///
   /// Секция определяет колонки и их ширину.
   ///
   SET_COLUMNS_SHOW,
   ///
   /// Неопределенная секция настроек.
   ///
   SET_NOTDEF
};
///
///
///
void OnStart()
{
   CXmlDocument doc;
   string err;
   if(!doc.CreateFromFile(FileName, err))
   {
      printf(err);
      return;
   }   
   for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
   {
      CXmlElement* xmlItem = doc.FDocumentElement.GetChild(i);
      switch(GetTypeSection(xmlItem.GetText()))
      {
         case SET_COLUMNS_SHOW:
            
      }
      printf(xmlItem.GetName());
   }
   
}

///
/// Возвращает идентификатор секции настроек, которому соответствует текущему узлу.
///
ENUM_SET_SECTIONS GetTypeSection(string nameNode)
{
   if(nameNode == "Show-Columns")
      return SET_COLUMNS_SHOW;
   return SET_NOTDEF;
}


