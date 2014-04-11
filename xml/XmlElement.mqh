//+------------------------------------------------------------------+
//|                                                   XmlElement.mqh |
//|                                                   yu-sha@ukr.net |
//+------------------------------------------------------------------+

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
   void              Init(const string aName,const CXmlElement *aParent=NULL,const string aText="");
   void              CopyTo(CXmlElement &aDst);
   virtual void      Clear();

   //--- main service methods
   string            GetName() const;
   void              SetName(const string aName);
   string            GetText() const;
   void              SetText(const string aText);
   CXmlElement      *GetParent() const;
   void              SetParent(CXmlElement *aParent);

   //--- attribute service methods
   int               GetAttributeCount() const;
   int               GetAttributeIndex(CXmlAttribute *aAttr) const;
   CXmlAttribute    *GetAttribute(const string aName) const;
   CXmlAttribute    *GetAttribute(int aPos) const;
   string            GetAttributeValue(const string aName) const;

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
   int               GetChildCount() const;
   int               GetChildIndex(CXmlElement *aElement) const;
   CXmlElement      *GetChild(const string aName) const;
   CXmlElement      *GetChild(int aPos) const;
   string            GetChildText(const string aName) const;

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
  };
//--------------------------------------------------------------------------------/
//                              CXmlElement :: implementation                     /
//--------------------------------------------------------------------------------/

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
void CXmlElement::Init(const string aName,const CXmlElement *aParent=NULL,const string aText="")
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
string CXmlElement::GetName() const
  {
   return FName;
  };
//+------------------------------------------------------------------+
//| SetName                                                          |
//+------------------------------------------------------------------+
void CXmlElement::SetName(const string aName)
  {
   FName=aName;
  };
//+------------------------------------------------------------------+
//| GetText                                                          |
//+------------------------------------------------------------------+
string CXmlElement::GetText() const
  {
   return FText;
  };
//+------------------------------------------------------------------+
//| SetText                                                          |
//+------------------------------------------------------------------+
void CXmlElement::SetText(const string aText)
  {
   FText=aText;
  };
//+------------------------------------------------------------------+
//| GetParent                                                        |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::GetParent() const
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
int CXmlElement::GetAttributeCount() const
  {
   return ArraySize(FAttributes);
  };
//+------------------------------------------------------------------+
//| GetAttributeIndex                                                |
//+------------------------------------------------------------------+
int CXmlElement::GetAttributeIndex(CXmlAttribute *aAttr) const
  {
   int i=0;
   while((i<ArraySize(FAttributes)) && (FAttributes[i]!=aAttr))
      ++i;

   return(i<ArraySize(FAttributes) ? i : INT_MAX);
  };
//+------------------------------------------------------------------+
//| GetAttribute                                                     |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlElement::GetAttribute(const string aName) const
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
CXmlAttribute *CXmlElement::GetAttribute(int aPos) const
  {
   return FAttributes[aPos];
  };
//+------------------------------------------------------------------+
//| GetAttributeValue                                                |
//+------------------------------------------------------------------+
string CXmlElement::GetAttributeValue(const string aName) const
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
int CXmlElement::GetChildCount() const
  {
   return ArraySize(FElements);
  };
//+------------------------------------------------------------------+
//| GetChildIndex                                                    |
//+------------------------------------------------------------------+
int CXmlElement::GetChildIndex(CXmlElement *aElement) const
  {
   int i=0;
   while((i<ArraySize(FElements)) && (FElements[i]!=aElement))
      ++i;

   return(i<ArraySize(FElements) ? i : INT_MAX);
  };
//+------------------------------------------------------------------+
//| GetChild                                                         |
//+------------------------------------------------------------------+
CXmlElement *CXmlElement::GetChild(const string aName) const
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
CXmlElement *CXmlElement::GetChild(int aPos) const
  {
   return FElements[aPos];
  };
//+------------------------------------------------------------------+
//| GetChildText                                                     |
//+------------------------------------------------------------------+
string CXmlElement::GetChildText(const string aName) const
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
string TextPreProcess(const string s)
  {
// Заменить " & < > на &quote, ...
   return(s);
  };
//+------------------------------------------------------------------+
