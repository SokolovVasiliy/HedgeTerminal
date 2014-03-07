//+------------------------------------------------------------------+
//|                                                     XML_test.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "XmlBase.mqh"

CXmlDocument doc;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   string file="test.xml";
   string err;
   bool res = FileIsExist(file);
   string name = "";
   FileFindFirst("*.*", name, FILE_COMMON);
   if(doc.CreateFromFile(file, err))
     {
      for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
      {
         CXmlElement* xmlItem = doc.FDocumentElement.GetChild(i);
         printf(xmlItem.GetName());
      }
      //printf(doc.FDocumentElement.GetText());
      //CXmlElement*xmlItem=doc.FDocumentElement.GetChild(0);
      
      //int total = xmlItem.GetChildCount();
      /*for(int i=0; i<xmlItem.GetChildCount(); i++)
         if(xmlItem.GetChild(i).GetName()=="Global")
           {
            CXmlElement *layer=xmlItem.GetChild(i);
            for(int j=0; j<layer.GetChildCount();++j)
              {
               if(layer.GetChild(j).GetName()=="Symbol-Name")
                 {
        
                 }
              }
           }*/
     }
  printf(err);
  }
//+------------------------------------------------------------------+
