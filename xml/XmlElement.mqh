//+------------------------------------------------------------------+
//|                                                   XmlElement.mqh |
//|                                                   yu-sha@ukr.net |
//+------------------------------------------------------------------+
class CXmlAttribute;
//-----------------------------------------------------------------------------
//                                  CXmlElement                               !
//-----------------------------------------------------------------------------
class CXmlElement
  {
private:
   string            FName;
   CXmlAttribute    *FAttributes[];
   CXmlElement      *FElements[];
   string            FText;
   CXmlElement      *FParent;

public:
   //--- constructor methods
   void              CXmlElement();
   void             ~CXmlElement();
   void              Init(  string aName,  CXmlElement *aParent=NULL,  string aText="");
   void              CopyTo(CXmlElement &aDst);
   virtual void      Clear();

   //--- main service methods
   string            GetName()  ;
   void              SetName(  string aName);
   string            GetText()  ;
   void              SetText(  string aText);
   CXmlElement      *GetParent()  ;
   void              SetParent(CXmlElement *aParent);

   //--- attribute service methods
   int               GetAttributeCount()  ;
   int               GetAttributeIndex(CXmlAttribute *aAttr)  ;
   CXmlAttribute    *GetAttribute(  string aName)  ;
   CXmlAttribute    *GetAttribute(int aPos)  ;
   string            GetAttributeValue(  string aName)  ;

   CXmlAttribute    *AttributeInsertAt(CXmlAttribute *aAttr,int aPos);
   CXmlAttribute    *AttributeAdd(CXmlAttribute *aAttr);
   CXmlAttribute    *AttributeInsertAfter(CXmlAttribute *aAfter,CXmlAttribute *aAttr);
   CXmlAttribute    *AttributeInsertBefore(CXmlAttribute *aBefore,CXmlAttribute *aAttr);
   CXmlAttribute    *AttributeRemove(CXmlAttribute *aAttr);
   CXmlAttribute    *AttributeRemove(int aPos);
   void              AttributeDelete(CXmlAttribute *aAttr);
   void              AttributeDelete(int aPos);
   void              AttributeDeleteAll();

   //--- child service methods
   int               GetChildCount()  ;
   int               GetChildIndex(CXmlElement *aElement)  ;
   CXmlElement      *GetChild(  string aName)  ;
   CXmlElement      *GetChild(int aPos)  ;
   string            GetChildText(  string aName)  ;

   CXmlElement      *ChildInsertAt(CXmlElement *aElement,int aPos);
   CXmlElement      *ChildAdd(CXmlElement *aElement);
   CXmlElement      *ChildInsertAfter(CXmlElement *aAfter,CXmlElement *aElement);
   CXmlElement      *ChildInsertBefore(CXmlElement *aBefore,CXmlElement *aElement);
   CXmlElement      *ChildRemove(CXmlElement *aElement);
   CXmlElement      *ChildRemove(int aPos);
   void              ChildDelete(CXmlElement *aElement);
   void              ChildDelete(int aPos);
   void              ChildDeleteAll();

   string            GetXml(int aLevel);
   bool              InitByXmlText(string text, CXmlElement* xelement);
   void              DoElementTrimText(CXmlElement &aXmlItem);
  };
//--------------------------------------------------------------------------------/
//                              CXmlElement :: implementation                     /
//--------------------------------------------------------------------------------/
//+------------------------------------------------------------------+
//| Init from xml text                                               |
//+------------------------------------------------------------------+
bool CXmlElement::InitByXmlText(string text, CXmlElement* xelement)
{
   CXmlElement       FDocumentElement;
   
   string err;
   /* В text приходит текст XML документа
     - переведенный в Юникод
     - очищенный от BOM заголовка UTF-8 */

// #define _PubidChar   _WhiteSpace+_LatinLetter+_Digit+"\'" + "-()+,./:=?;!*#@$_%"
// #define Utf8BOM    "\xEF\xBB\xBF"
     string  WhiteSpace  = " \r\n\t";
     string  LatinLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
     string  ANSIILetter = "\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF";
     string  Digit       = "0123456789";
     string  QuoteChar   = "\'\"";
   string  Letter      = LatinLetter + ANSIILetter;
   string  NameChar    = Letter + Digit + ".-_:\xB7";
   string  NameStart   = Letter + "_:";
   
   Clear();
   int p=0;

   CXmlElement *CurElement=NULL;
   do 
     {
      if(p>=StringLen(text)) 
        {
         err="Unexpected end of document by position " + IntegerToString(p) +
         ". Check valid text or exits file.";
         return(false);
        }
      bool res = StringSubstr(text,p,5)=="<?xml";
      if((StringSubstr(text,p,5)=="<?xml") && StringFind(WhiteSpace,StringSubstr(text,p+5,1))>=0)
        { // Prolog
         p=StringFind(text,"?>",p+StringLen("<?xml"));
         if(p<0) 
           {
            err="Not find '?>' from position "+IntegerToString(p) + ".";
            return(false);
           }
         p+=StringLen("?>");
        }
      else
      if(StringSubstr(text,p,StringLen("<?"))=="<?") 
        {
         // PI
        }
      else
      if(StringSubstr(text,p,StringLen("<!--"))=="<!--") 
        {
         // Comment
         p=StringFind(text,"-->",p+StringLen("<!--"));
         if(p<0) 
           {
            err="Not find '-->' from position " + IntegerToString(p) + ".";
            return(false);
           }
         p+=3;
        }
      else
      if(StringSubstr(text,p,StringLen("<!DOCTYPE"))=="<!DOCTYPE")
        {
         // Dtdc
        }
      else
      if(StringSubstr(text,p,StringLen("<![CDATA["))=="<![CDATA[")
        {
         // Cdata
         p=StringFind(text,"]]>",p+StringLen("<![CDATA["));
         if(p<0) 
           {
            err="Not find ']]>' from position "+IntegerToString(p) + ".";
            return(false);
           }
         p+=StringLen("]]>");
        }
      else
      if(StringSubstr(text,p,StringLen("</"))=="</")
        {
         // End tag
         p+=2;
         string name="";
         if(StringFind(NameStart,StringSubstr(text,p,1))<0) 
           {
            err="Invalid character in position "+IntegerToString(p) + ".";
            return(false);
           }
         StringAdd(name,StringSubstr(text,p++,1));
         while(p<StringLen(text) && StringFind(NameChar,StringSubstr(text,p,1))>=0)
            StringAdd(name,StringSubstr(text,p++,1));
         while(p<StringLen(text) && StringFind(WhiteSpace,StringSubstr(text,p,1))>=0)
            p++;
         if(CurElement==NULL || CurElement.GetName()!=name || StringSubstr(text,p,1)!=">") 
           {
            err="Invalid closing tag in position "+IntegerToString(p) + ".";
            return(false);
           }
         p++;
         /*if(CurElement==GetPointer(FDocumentElement))
            CurElement=NULL;
         else 
           {
            CXmlElement *parent=GetPointer(FDocumentElement);
            while(parent!=NULL && parent.GetChildCount()>0 && parent.GetChild(parent.GetChildCount()-1)!=CurElement)
               parent=parent.GetChild(parent.GetChildCount()-1);
            if(parent.GetChild(parent.GetChildCount()-1)!=CurElement) 
              {
               err="Error in nested position "+IntegerToString(p) + ".";
               return(false);
              }
            CurElement=parent;
           };*/
        }
      else
      if(StringSubstr(text,p,StringLen("<"))=="<") 
      {
         // Start tag
         p++;
         CXmlElement *element=NULL;
         if(CurElement != NULL) 
         {
            element=new CXmlElement;
            CurElement.ChildAdd(element);
         }
         else 
            element=GetPointer(FDocumentElement);
         
         // Tag name
         if(StringFind(NameStart,StringSubstr(text,p,1))<0) 
           {
            err="Substring " + (string)p + " not find";
            return(false);
           }
         element.SetName(element.GetName()+StringSubstr(text,p++,1));
         while(p<StringLen(text) && StringFind(NameChar,StringSubstr(text,p,1))>=0)
            element.SetName(element.GetName()+StringSubstr(text,p++,1));
         while(p<StringLen(text) && StringFind(WhiteSpace,StringSubstr(text,p,1))>=0)
            p++;
         string n = element.GetName();
         xelement.SetName(n);
         // Attributes
         while(p<StringLen(text) && StringSubstr(text,p,2)!="/>" && StringSubstr(text,p,1)!=">") 
         {

            // Attribute's name
            while(p<StringLen(text) && StringFind(WhiteSpace,StringSubstr(text,p,1))>=0)
               p++;
            if(StringFind(NameStart,StringSubstr(text,p,1))<0) 
              {
               err="Substring " + (string)p + " not find";
               return(false);
              }
            CXmlAttribute *attribute=new CXmlAttribute;
            element.AttributeAdd(attribute);
            attribute.SetName(attribute.GetName()+StringSubstr(text,p++,1));
            while(p<StringLen(text) && StringFind(NameChar,StringSubstr(text,p,1))>=0)
               attribute.SetName(attribute.GetName()+StringSubstr(text,p++,1));

            // =
            while(p<StringLen(text) && StringFind(WhiteSpace,StringSubstr(text,p,1))>=0)
               p++;
            if(StringSubstr(text,p,1)!="=") 
              {
               err="Substring " + (string)p + " not find";
               return(false);
              }
            p++;

            // Value
            while(p<StringLen(text) && StringFind(WhiteSpace,StringSubstr(text,p,1))>=0)
               p++;
            if(StringFind(QuoteChar,StringSubstr(text,p,1))<0) 
              {
               err="Substring " + (string)p + " not find";
               return(false);
              }
            string quote=StringSubstr(text,p++,1);
            while(p<StringLen(text) && StringSubstr(text,p,1)!=quote)
               attribute.SetValue(attribute.GetValue()+StringSubstr(text,p++,1));
            p++;
            while(p<StringLen(text) && StringFind(WhiteSpace,StringSubstr(text,p,1))>=0)
               p++;
            // init node
            CXmlAttribute* attr = new CXmlAttribute();
            attr.SetName(attribute.GetName());
            attr.SetValue(attribute.GetValue());
            xelement.AttributeAdd(attr);
         }
         if(StringSubstr(text,p,2)=="/>")
            p+=2;
         else
         if(StringSubstr(text,p,1)==">") 
         {
            p++;
            CurElement=element;
         }
         else
         {
            err="Substring " + (string)p + " not find";
            return(false);
         }
      }
      else
      {
         // Text
         if(CurElement!=NULL)
            CurElement.SetText(CurElement.GetText()+StringSubstr(text,p++,1));
         else if(p<StringLen(text) && StringFind(WhiteSpace,StringSubstr(text,p,1))>=0)
            p++;
         else
            return(false);
      }
   }
   while(p<StringLen(text));
   DoElementTrimText(FDocumentElement);
   
   return(true);
}
//+------------------------------------------------------------------+
//| DoElementTrimText                                                |
//+------------------------------------------------------------------+
void CXmlElement::DoElementTrimText(CXmlElement &aXmlItem)
  {
   string s=aXmlItem.GetText();
   StringTrimLeft(s);
   StringTrimRight(s);
   aXmlItem.SetText(s);
   for(int i=0; i<aXmlItem.GetChildCount();++i)
      DoElementTrimText(aXmlItem.GetChild(i));
  }
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CXmlElement::CXmlElement()
  {
   FParent=NULL;
  };
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CXmlElement::~CXmlElement()
  {
   Clear();
  };
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
void CXmlElement::Init(  string aName,  CXmlElement *aParent=NULL,  string aText="")
  {
   Clear();
   SetName(aName);
   SetParent(aParent);
   SetText(aText);
  };
//+------------------------------------------------------------------+
//| CopyTo                                                           |
//+------------------------------------------------------------------+
void CXmlElement::CopyTo(CXmlElement &aDst)
  {
   aDst.Clear();

   aDst.FName = FName;
   aDst.FText = FText;
   aDst.FParent=NULL;

   for(int i=0; i<ArraySize(FAttributes);++i)
      aDst.AttributeAdd(FAttributes[i].Clone());

   for(int i=0; i<ArraySize(FElements);++i)
     {
      CXmlElement *aItem=new CXmlElement;
      FElements[i].CopyTo(aItem);
      aDst.ChildAdd(aItem);
     };
  };
//+------------------------------------------------------------------+
//| Clear                                                            |
//+------------------------------------------------------------------+
void CXmlElement::Clear()
  {
   FName = "";
   FText = "";
   AttributeDeleteAll();
   ChildDeleteAll();
  };

// Main service methods
//+------------------------------------------------------------------+
//| GetName                                                          |
//+------------------------------------------------------------------+
string CXmlElement::GetName()  
  {
   return FName;
  };
//+------------------------------------------------------------------+
//| SetName                                                          |
//+------------------------------------------------------------------+
void CXmlElement::SetName(  string aName)
  {
   FName=aName;
  };
//+------------------------------------------------------------------+
//| GetText                                                          |
//+------------------------------------------------------------------+
string CXmlElement::GetText()  
  {
   return FText;
  };
//+------------------------------------------------------------------+
//| SetText                                                          |
//+------------------------------------------------------------------+
void CXmlElement::SetText(  string aText)
  {
   FText=aText;
  };
//+------------------------------------------------------------------+
//| GetParent                                                        |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::GetParent()  
  {
   return FParent;
  };
//+------------------------------------------------------------------+
//| SetParent                                                        |
//+------------------------------------------------------------------+
void CXmlElement::SetParent(CXmlElement *aParent)
  {
   FParent=aParent;
  };
  
// Attribute service methods
//+------------------------------------------------------------------+
//| GetAttributeCount                                                |
//+------------------------------------------------------------------+
int CXmlElement::GetAttributeCount()  
  {
   return ArraySize(FAttributes);
  };
//+------------------------------------------------------------------+
//| GetAttributeIndex                                                |
//+------------------------------------------------------------------+
int CXmlElement::GetAttributeIndex(CXmlAttribute *aAttr)  
  {
   int i=0;
   while((i<ArraySize(FAttributes)) && (FAttributes[i]!=aAttr))
      ++i;

   return(i<ArraySize(FAttributes) ? i : INT_MAX);
  };
//+------------------------------------------------------------------+
//| GetAttribute                                                     |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlElement::GetAttribute(  string aName)  
  {
   int i=0;
   while((i<ArraySize(FAttributes)) && (aName!=FAttributes[i].GetName()))
      ++i;

   if(i<ArraySize(FAttributes))
      return FAttributes[i];
   else
      return NULL;
  };
//+------------------------------------------------------------------+
//| GetAttribute                                                     |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlElement::GetAttribute(int aPos)  
  {
   return FAttributes[aPos];
  };
//+------------------------------------------------------------------+
//| GetAttributeValue                                                |
//+------------------------------------------------------------------+
string CXmlElement::GetAttributeValue(  string aName)  
  {
   int i=0;
   while((i<ArraySize(FAttributes)) && (aName!=FAttributes[i].GetName()))
      ++i;
   return(i<ArraySize(FAttributes) ? FAttributes[i].GetValue() : "");
  };
//+------------------------------------------------------------------+
//| AttributeInsertAt                                                |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlElement::AttributeInsertAt(CXmlAttribute *aAttr,int aPos)
  {
   ArrayResize(FAttributes,ArraySize(FAttributes)+1);
   for(int i=ArraySize(FAttributes)-1; i>(aPos); --i)
      FAttributes[i]=FAttributes[i-1];
   FAttributes[aPos]=aAttr;
   return aAttr;
  };
//+------------------------------------------------------------------+
//| AttributeAdd                                                     |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlElement::AttributeAdd(CXmlAttribute *aAttr)
  {
   return AttributeInsertAt(aAttr,GetAttributeCount());
  };
//+------------------------------------------------------------------+
//| AttributeInsertAfter                                             |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlElement::AttributeInsertAfter(CXmlAttribute *aAfter,CXmlAttribute *aAttr)
  {
   return AttributeInsertAt(aAttr,GetAttributeIndex(aAfter)+1);
  };
//+------------------------------------------------------------------+
//| AttributeInsertBefore                                            |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlElement::AttributeInsertBefore(CXmlAttribute *aBefore,CXmlAttribute *aAttr)
  {
   return AttributeInsertAt(aAttr,GetAttributeIndex(aBefore));
  };
//+------------------------------------------------------------------+
//| AttributeRemove                                                  |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlElement::AttributeRemove(CXmlAttribute *aAttr)
  {
   return AttributeRemove(GetAttributeIndex(aAttr));
  };
//+------------------------------------------------------------------+
//| AttributeRemove                                                  |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlElement::AttributeRemove(int aPos)
  {
   CXmlAttribute *attr=FAttributes[aPos];

   for(int i=aPos; i<ArraySize(FAttributes)-1;++i)
      FAttributes[i]=FAttributes[i+1];

   ArrayResize(FAttributes,ArraySize(FAttributes)-1);

   return attr;
  };
//+------------------------------------------------------------------+
//| AttributeDelete                                                  |
//+------------------------------------------------------------------+
void CXmlElement::AttributeDelete(CXmlAttribute *aAttr)
  {
   delete AttributeRemove(aAttr);
  };
//+------------------------------------------------------------------+
//| AttributeDelete                                                  |
//+------------------------------------------------------------------+
void CXmlElement::AttributeDelete(int aPos)
  {
   delete AttributeRemove(aPos);
  };
//+------------------------------------------------------------------+
//| AttributeDeleteAll                                               |
//+------------------------------------------------------------------+
void CXmlElement::AttributeDeleteAll()
  {
   for(int i=ArraySize(FAttributes)-1; i>=0; i--)
      delete FAttributes[i];
   ArrayResize(FAttributes,0);
  };

// Child service methods
//+------------------------------------------------------------------+
//| GetChildCount                                                    |
//+------------------------------------------------------------------+
int CXmlElement::GetChildCount()  
  {
   return ArraySize(FElements);
  };
//+------------------------------------------------------------------+
//| GetChildIndex                                                    |
//+------------------------------------------------------------------+
int CXmlElement::GetChildIndex(CXmlElement *aElement)  
  {
   int i=0;
   while((i<ArraySize(FElements)) && (FElements[i]!=aElement))
      ++i;

   return(i<ArraySize(FElements) ? i : INT_MAX);
  };
//+------------------------------------------------------------------+
//| GetChild                                                         |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::GetChild(  string aName)  
  {
   int i=0;
   while((i<ArraySize(FElements)) && (aName!=FElements[i].GetName()))
      ++i;

   if(i<ArraySize(FElements))
      return FElements[i];
   else
      return NULL;
  };
//+------------------------------------------------------------------+
//| GetChild                                                         |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::GetChild(int aPos)  
  {
   return FElements[aPos];
  };
//+------------------------------------------------------------------+
//| GetChildText                                                     |
//+------------------------------------------------------------------+
string CXmlElement::GetChildText(  string aName)  
  {
   CXmlElement *child=GetChild(aName);
   return child!=NULL ? child.GetText() : "";
  };
//+------------------------------------------------------------------+
//| ChildInsertAt                                                    |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::ChildInsertAt(CXmlElement *aElement,int aPos)
  {
   ArrayResize(FElements,ArraySize(FElements)+1);

   for(int i=ArraySize(FElements)-1; i>(aPos); --i)
      FElements[i]=FElements[i-1];

   FElements[aPos]=aElement;
   aElement.SetParent(GetPointer(this));

   return aElement;
  };
//+------------------------------------------------------------------+
//| ChildAdd                                                         |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::ChildAdd(CXmlElement *aElement)
  {
   return ChildInsertAt(aElement,GetChildCount());
  };
//+------------------------------------------------------------------+
//| ChildInsertAfter                                                 |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::ChildInsertAfter(CXmlElement *aAfter,CXmlElement *aElement)
  {
   return ChildInsertAt(aElement,GetChildIndex(aAfter)+1);
  };
//+------------------------------------------------------------------+
//| ChildInsertBefore                                                |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::ChildInsertBefore(CXmlElement *aBefore,CXmlElement *aElement)
  {
   return ChildInsertAt(aElement,GetChildIndex(aBefore));
  };
//+------------------------------------------------------------------+
//| ChildRemove                                                      |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::ChildRemove(CXmlElement *aElement)
  {
   return ChildRemove(GetChildIndex(aElement));
  };
//+------------------------------------------------------------------+
//| ChildRemove                                                      |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::ChildRemove(int aPos)
  {
   //delete FElements[aPos];
   //for(int i=aPos; i<ArraySize(FElements)-1;++i)
   //   FElements[i]=FElements[i+1];
   CXmlElement *child=FElements[aPos];
   child.SetParent(NULL);

   for(int i=aPos; i<ArraySize(FElements)-1;++i)
      FElements[i]=FElements[i+1];

   ArrayResize(FElements,ArraySize(FElements)-1);
   return child;
  };
//+------------------------------------------------------------------+
//| ChildDelete                                                      |
//+------------------------------------------------------------------+
void CXmlElement::ChildDelete(CXmlElement *aElement)
  {
   delete ChildRemove(aElement);
  };
//+------------------------------------------------------------------+
//| ChildDelete                                                      |
//+------------------------------------------------------------------+
void CXmlElement::ChildDelete(int aPos)
  {
   delete ChildRemove(aPos);
  };
//+------------------------------------------------------------------+
//| ChildDeleteAll                                                   |
//+------------------------------------------------------------------+
void CXmlElement::ChildDeleteAll()
  {
   for(int i=ArraySize(FElements)-1; i>=0; i--)
      delete FElements[i];
   ArrayResize(FElements,0);
  };
//+------------------------------------------------------------------+
//| GetXml                                                           |
//+------------------------------------------------------------------+
string CXmlElement::GetXml(int aLevel)
  {
   string t="";;
   for(int i=0; i<aLevel;++i)
      t+="\t";
   string s;
   s=t+"<"+FName;
   for(int i=0; i<ArraySize(FAttributes); i++)
      StringAdd(s," "+FAttributes[i].GetName()+"=\""+TextPreProcess(FAttributes[i].GetValue())+"\"");
   if((ArraySize(FElements)==0) && (FText==""))
      StringAdd(s,"/>");
   else
     {
      StringAdd(s,">");
      for(int i=0; i<ArraySize(FElements); i++)
         StringAdd(s,"\r\n"+FElements[i].GetXml(aLevel+1));
      if((ArraySize(FElements)>0) && (FText!=""))
         StringAdd(s,"\r\n");
      //    StringAdd(s,TextPreProcess(FText));
      StringAdd(s,FText);
      //FText="*"+FText+"*";
      if((ArraySize(FElements)>0))
         StringAdd(s,"\r\n"+t);
      StringAdd(s,"</"+FName+">");
     }
   return(s);
  };
//+------------------------------------------------------------------+
//| TextPreProcess                                                   |
//+------------------------------------------------------------------+
string TextPreProcess(  string s)
  {
// Заменить " & < > на &quote, ...
   return(s);
  };
//+------------------------------------------------------------------+
