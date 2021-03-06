//+------------------------------------------------------------------+
//|                                                 XmlAttribute.mqh |
//|                                                   yu-sha@ukr.net |
//+------------------------------------------------------------------+

//-----------------------------------------------------------------------------
//                                  CXmlAttribute                             !
//-----------------------------------------------------------------------------
class CXmlAttribute
  {
private:
   string            FName;
   string            FValue;
public:
   //--- constructor methods
   void              CXmlAttribute();
   void             ~CXmlAttribute();

   void              Init(  string aName,  string aValue);
   virtual void      Clear();
   virtual CXmlAttribute *Clone();

   //--- service methods
   string            GetName()  ;
   void              SetName(  string aName);
   string            GetValue()  ;
   void              SetValue(  string aValue);
  };
//--------------------------------------------------------------------------------/
//                              CXmlAttribute :: implementation                   /
//--------------------------------------------------------------------------------/

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CXmlAttribute::CXmlAttribute()
  {
   FName="";
   FValue="";
  };
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CXmlAttribute::~CXmlAttribute()
  {
   Clear();
  };
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
void CXmlAttribute::Init(  string aName,  string aValue="")
  {
   SetName(aName);
   SetValue(aValue);
  };
//+------------------------------------------------------------------+
//| Clear                                                            |
//+------------------------------------------------------------------+
void CXmlAttribute::Clear()
  {
  };
//+------------------------------------------------------------------+
//| Clone                                                            |
//+------------------------------------------------------------------+
CXmlAttribute *CXmlAttribute::Clone()
  {
   CXmlAttribute *a=new CXmlAttribute;
   a.FName=FName;
   a.FValue=FValue;
   return a;
  };
//+------------------------------------------------------------------+
//| GetName                                                          |
//+------------------------------------------------------------------+
string CXmlAttribute::GetName()  
  {
   return FName;
  };
//+------------------------------------------------------------------+
//| SetName                                                          |
//+------------------------------------------------------------------+
void CXmlAttribute::SetName(  string aName)
  {
   FName=aName;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CXmlAttribute::GetValue()  
  {
   return FValue;
  };
//+------------------------------------------------------------------+
//| SetValue                                                         |
//+------------------------------------------------------------------+
void CXmlAttribute::SetValue(  string aValue)
  {
   FValue=aValue;
  };
//+------------------------------------------------------------------+
