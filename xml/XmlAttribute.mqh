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

   void              Init(const string aName,const string aValue);
   virtual void      Clear();
   virtual CXmlAttribute *Clone();

   //--- service methods
   string            GetName() const;
   void              SetName(const string aName);
   string            GetValue() const;
   void              SetValue(const string aValue);
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
void CXmlAttribute::Init(const string aName,const string aValue="")
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
string CXmlAttribute::GetName() const
  {
   return FName;
  };
//+------------------------------------------------------------------+
//| SetName                                                          |
//+------------------------------------------------------------------+
void CXmlAttribute::SetName(const string aName)
  {
   FName=aName;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CXmlAttribute::GetValue() const
  {
   return FValue;
  };
//+------------------------------------------------------------------+
//| SetValue                                                         |
//+------------------------------------------------------------------+
void CXmlAttribute::SetValue(const string aValue)
  {
   FValue=aValue;
  };
//+------------------------------------------------------------------+
