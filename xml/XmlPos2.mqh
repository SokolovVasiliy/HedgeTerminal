#include "FileInfo.mqh"
#include "..\LibXML\XmlBase.mqh"
#include "..\Log.mqh"
#include "..\Math\Math.mqh"

///
/// Àòðèáóòû ïîçèöèè.
///
enum ENUM_ATTRIBUTE_POS
{
         ///
         /// Èäåíòèôèêàòîð ñ÷åòà, ê êîòîðîìó ïðèíàäëåæèò ïîçèöèÿ.
         ///
         ATTR_ACCOUNT_ID,
         ///
         /// Èäåíòèôèêàòîð ïîçèöèè.
         ///
         ATTR_POSITION_ID,
         ///
         /// Çàêðûâàþùèé êîììåíòàðèé.
         ///
         ATTR_EXIT_COMMENT,
         ///
         /// Óðîâåíü âèðòóàëüíîãî òåéê-ïðîôèòà.
         ///
         ATTR_TAKE_PROFIT,
         ///
         /// Àòòðèáóò áëîêèðîâêè ïîçèöèè.
         ///
         ATTR_BLOCKED
      };
///
/// Òèï ñîñòîÿíèÿ, êîòîðîå íàäî ñîõðàíèòü.
///
enum ENUM_STATE_TYPE
{
   ///
   /// Íåîáõîäèìî óäàëèòü çàïèñü îá àêòèâíîé ïîçèöèè.
   ///
   STATE_DELETE,
   ///
   /// Íåîáõîäèìî îáíîâèòü çíà÷åíèÿ àòòðèáóòîâ.
   ///
   STATE_REFRESH
};
///
/// Ñîäåðæèò çíà÷åíèÿ àêòèâíîé ïîçèöèè è èõ xml-ïðåäñòàâëåíèå
///
class XPosValues
{
   public:
      XPosValues(Position* position)
      {
         pos = position;
         accountId = AccountInfoInteger(ACCOUNT_LOGIN);
         posId = pos.GetId();
      }
      ///
      /// 
      ///
      ulong PositionId(){return posId;}
      ///
      /// Âîçâðàùàåò ñôîðìèðîâàííûé XML óçåë.
      ///
      CXmlElement* GetXmlElement()
      {
         CXmlElement* element = new CXmlElement();
         element.SetName("Position");
         //Account.
         CXmlAttribute* attr = new CXmlAttribute();
         attr.SetName(GetAttributeName(ATTR_ACCOUNT_ID));
         attr.SetValue((string)accountId);
         element.AttributeAdd(attr);
         //Position ID
         attr = new CXmlAttribute();
         attr.SetName(GetAttributeName(ATTR_POSITION_ID));
         attr.SetValue((string)posId);
         element.AttributeAdd(attr);
         //Exit comment
         attr = new CXmlAttribute();
         attr.SetName(GetAttributeName(ATTR_EXIT_COMMENT));
         attr.SetValue(pos.ExitComment());
         element.AttributeAdd(attr);
         //TakeProfit
         attr = new CXmlAttribute();
         attr.SetName(GetAttributeName(ATTR_TAKE_PROFIT));
         attr.SetValue(pos.PriceToString(pos.TakeProfitLevel()));
         element.AttributeAdd(attr);
         //Blocked attribute
         if(pos.IsBlocked())
         {
            //printf("XML: position #" + (string)pos.GetId() + " is blocked.");
            attr = new CXmlAttribute();
            attr.SetName(GetAttributeName(ATTR_BLOCKED));
            attr.SetValue((string)TimeCurrent());
            element.AttributeAdd(attr);
         }
         //printf("Create: " + element.GetXml(3));
         return element;
      }
      ///
      /// Óñòàíàâëèâàåò ñîñòîÿíèå îáúåêòà ñîãëàñíî xml åëåìåíòó.
      ///
      bool SetXmlElement(CXmlElement* element)
      {
         if(!IsMyElement(element))return false;
         double tp = 0.0;
         string comment = "";
         datetime time = 0;
         CXmlAttribute* attr = element.GetAttribute(GetAttributeName(ATTR_TAKE_PROFIT));
         if(attr != NULL)
            tp = StringToDouble(attr.GetValue());
         attr = element.GetAttribute(GetAttributeName(ATTR_EXIT_COMMENT));
         if(attr != NULL)
            comment = attr.GetValue();
         attr = element.GetAttribute(GetAttributeName(ATTR_BLOCKED));
         if(attr != NULL)
         {
            string strTime = attr.GetValue();
            time = StringToTime(strTime);
         }
         return pos.AttributesChanged(tp, comment, time);
      }
      ///
      /// Èñòèíà, åñëè òåêóùèé ýëåìåíò ñîîòâåòñòâóåò òåêóùåìó ýêçìåìïëÿðó è ëîæü â ïðîòèâíîì ñëó÷àå.
      ///
      bool IsMyElement(CXmlElement* element)
      {
         if(CheckPointer(element) == POINTER_INVALID)
            return false;
         CXmlAttribute* attr = element.GetAttribute(GetAttributeName(ATTR_ACCOUNT_ID));
         if(attr == NULL)return false;
         if(StringToInteger(attr.GetValue()) != accountId)
            return false;
         attr = element.GetAttribute(GetAttributeName(ATTR_POSITION_ID));
         if(attr == NULL)return false;
         if(StringToInteger(attr.GetValue()) != posId)
            return false;
         return true;
      }
      ///
      /// Èñòèíà, åñëè ïåðåäàííûé ýëåìåíò ïðèíàäëåæèò òåêóùåé ïîçèöèè, íî åãî ïàðàìåòðû
      /// îòëè÷àþòñÿ îò íåå.
      ///
      bool DetectModify(CXmlElement* element)
      {
         if(!IsMyElement(element))
            return false;
         CXmlAttribute* attr = element.GetAttribute(GetAttributeName(ATTR_TAKE_PROFIT));
         if(DiffTP(attr))return true;
         if(!pos.UsingStopLoss())
         {
            attr = element.GetAttribute(GetAttributeName(ATTR_EXIT_COMMENT));
            if(DiffComment(attr))return true;
         }
         attr = element.GetAttribute(GetAttributeName(ATTR_BLOCKED));
         if(DiffBlock(attr))return true;
         return false;
      }
      ///
      /// Èñòèíà, åñëè àòòðèáóò òåéêïðîôèòà ðàçëè÷àåòñÿ îò òåéê-ïðîôèò ïîçèöèè.
      ///
      bool DiffTP(CXmlAttribute* attr)
      {
         if(attr == NULL)return true;
         double tp = StringToDouble(attr.GetValue());
         if(Math::DoubleEquals(pos.TakeProfitLevel(), tp))
            return false;
         return true;
      }
      ///
      /// Èñòèíà, åñëè àòòðèáóò èñõîäÿùåãî êîììåíòàðèÿ ðàçëè÷àåòñÿ îò èñõîäÿùåãî êîììåíòàðèÿ ïîçèöèè.
      ///
      bool DiffComment(CXmlAttribute* attr)
      {
         if(attr == NULL)return true;
         if(pos.ExitComment() == attr.GetValue())
            return false;
         return true;
      }
      ///
      /// Èñòèíà, ñòàòóñ áëîêèðîâêè óêàçàííûé â àòòðèáóòå, îòëè÷àåòñÿ îò ñòàòóñà áëîêèðîâêè ïîçèöèè.
      ///
      bool DiffBlock(CXmlAttribute* attr)
      {
         if(attr == NULL && !pos.IsBlocked())return false;
         if(attr != NULL && pos.IsBlocked())return false;
         return true;
      }
      ///
      /// Âîçâðàùàåò íàçâàíèå àòòðèáóòà â çàâèñèìîñòè îò åãî òèïà.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS attrType)
      {
         switch(attrType)
         {
            case ATTR_ACCOUNT_ID:
               return "AccountID";
            case ATTR_POSITION_ID:
               return "ID";
            case ATTR_EXIT_COMMENT:
               return "ExitComment";
            case ATTR_TAKE_PROFIT:
               return "TakeProfit";
            case ATTR_BLOCKED:
               return "Blocked";
         }
         return "";
      }
   private:
      Position* pos;
      ///
      /// Âèðòóàëüíûé óðîâåíü ñòîï-ëîññà.
      ///
      //double stopLoss;
      ///
      /// Âèðòóàëüíûé óðîâåíü òåéê-ïðîôèòà.
      ///
      //double takeProfit;
      ///
      /// Èäåíòèôèêàòîð ñ÷åòà.
      ///
      ulong accountId;
      ///
      /// Èäåíòèôèêàòîð ïîçèöèè.
      ///
      ulong posId;
      ///
      /// Èñõîäÿùèé êîììåíòàðèé.
      ///
      //string exitComment;
      ///
      /// Òåêñòîâîå çíà÷åíèå ïðåäûäóùåãî óçëà.
      ///
      string prevText;
};

///
/// Xml ïðåäñòàâëåíèå àêòèâíîé òàáëèöû.
///
class XmlPos2
{
   public:
      ///
      /// Êîíñòðóêòîð.
      ///
      XmlPos2(Position* pos);
      ///
      /// Äèñòðóêòîð.
      ///
      ~XmlPos2();
      ///
      /// Ïðîâåðÿåò ôàéë íà èçìåíåíèÿ (íîâàÿ âåðñèÿ CheckModify).
      ///
      bool LoadState();
      ///
      /// Ñîõðàíÿåò òåêóùåå ñîñòîÿíèå.
      ///
      bool SaveState(ENUM_STATE_TYPE type);
      bool SaveState2(ENUM_STATE_TYPE type);
   private:
      ///
      /// Èñòèíà, åñëè äîêóìåíò áûë çàãðóæåí, ëîæü åñëè çàãðóçêà íåóäàëàñü.
      ///
      bool LoadXmlDoc(int handle);
      ///
      /// Ñîõðàíÿåò òåêóùèé çàãðóæåííûé äîêóìåíò â ôàéë.
      ///
      void SaveXmlDoc(int handle);
      ///
      /// Óäàëÿåò òåêóùèé xml-óçåë èç ôàéëà.
      ///
      void DeleteMe(void);
      ///
      /// Ñîçäàåò òåêóùèé óçåë â xml ôàéëå.
      ///
      void CreateMe(void);
      ///
      /// Ïåðå÷èòûâàåò òåêóùèé xml-óçåë èç ôàéëà.
      /// \return Âîçâðàùàåò èñòèíó, åñëè óçåë áûë èçìåíåí è ëîæü â ïðîòèâíîì ñëó÷àå.
      /// 
      bool ReadMe(void);
      ///
      /// Èñòèíà, åñëè XML-ôàéë ñîäåðæèò òåêóùèé xml-óçåë è ëîæü â ïðîòèâíîì ñëó÷àå.
      ///
      bool ContainsMe(void);
      ///
      /// Èñòèíà, åñëè çàãðóæåííûé xml äîêóìåíò îòëè÷àåòñÿ îò ñòàðîãî.
      ///
      bool DetectModify(void);
      ///
      /// Ìåíÿåò ñîäåðæèìîå îòêðûòîãî ôàéëà íà ïðîáåëû.
      ///
      void FillSpace(int handle);
      ///
      /// Ïûòàåòñÿ îòêðûòü ôàéë. Â ñëó÷àå óñïåõà âîçâðàùàåò ôàéëîâûé äèñêðèïòîð íå íåãî, â 
      /// ñëó÷àå íåóäà÷ó êîíñòàíòó INVALID_HANDLE.
      /// \param flags - Íàáîð ôëàãîâ, óñòàíàâëèâàþùèõ ðåæèìû îòêðûòèÿ ôàéëà.
      ///
      int TryOpenFile(int flags);
      ///
      /// Çàãðóæåííûé Xml-äîêóìåíò.
      ///
      CXmlDocument* doc;
      ///
      ///
      ///
      XPosValues* xPos;
      ///
      /// XML ôàéë, êîòîðûé íåîáõîäèìî îòñëåæèâàòü.
      ///
      //FileInfo* file;
      ///
      /// Âîçâðàùàåò èìÿ xml-àòòðèáóòà â çàâèñèìîñòè îò åãî òèïà.
      ///
      string GetAttributeName(ENUM_ATTRIBUTE_POS);
      ///
      /// Èñòèíà, åñëè ïîñëåäíåå ñîñòîÿíèå ïîçèöèè áûëî óäà÷íî ñîõðàíåííî è ëîæü â ïðîòèâíîì ñëó÷àå.
      ///
      bool saveState;
      ///
      /// Èìÿ XML ôàéëà àêòèâíûõ ïîçèöèé.
      ///
      string fileName;
      ///
      /// Âåðñèÿ ïîñëåäíåãî èçâåñòíîãî XML äîêóìåíòà.
      ///
      string prevDoc;
      ///
      /// Óêàçàòåëü íà òåêóùèé xml-åëåìåíò, ñîîòâåòñòâóþùèé ïîçèöèè (èíèöèàëèçèðóåòñÿ LoadXmlDoc).
      ///
      CXmlElement* currElement;
};

XmlPos2::XmlPos2(Position* pos)
{
   saveState = true;
   xPos = new XPosValues(pos);
   fileName = Resources.GetFileNameByType(RES_ACTIVE_POS_XML);
   prevDoc = "";
   //file = new FileInfo(fileName, 0, 1);
   //file.SetMode(ACCESS_CHECK_AND_BLOCKED);
}

XmlPos2::~XmlPos2()
{
   delete xPos;
   //delete file;
}

bool XmlPos2::LoadXmlDoc(int handle)
{
   if(CheckPointer(doc) == POINTER_INVALID)
      doc = new CXmlDocument();
   else return true;
   string err;
   bool res = doc.ReadDocument(handle, err);
   if(!res)
   {
      delete doc;
      return res;
   }
   //Èùèì òåêóùèé xml-åëåìåíò, ñîîòâåòñòâóþùèé ïîçèöèè.
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         currElement = element;
   }
   return res;
}

void XmlPos2::SaveXmlDoc(int handle)
{
   if(CheckPointer(doc) == POINTER_INVALID)return;
   string err = "";
   doc.WriteDocument(handle, err);
   delete doc;
}

int XmlPos2::TryOpenFile(int flags)
{
   int handle = INVALID_HANDLE;
   //Êîëè÷åñòâî ïîïûòîê îòêðûòèÿ ôàéëà.
   int attempts = 30;
   for(int i = 0; i < attempts; i++)
   {
      handle = FileOpen(fileName, flags|Resources.FileCommon());
      //if(handle != INVALID_HANDLE)
      //   break;
      //Óñòàíàâëèâàåì ãåíåðàòîð â óíèêàëüíîå çíà÷åíèå äëÿ òåêóùåãî ýêçåìïëÿðà.
      //uint chartHandle = (int)ChartGetInteger(0, CHART_WINDOW_HANDLE);
      //srand(chartHandle);
      //Çàäåðæêà îò 10 äî 100 ìñåê êàæäóþ ïîïûòêó.
      //int msec = 10 + (rand()%90); 
      //int msec = 2;
      //Sleep(msec);
   }
   return handle;
}

bool XmlPos2::LoadState()
{
   bool res = false;
   int handle = TryOpenFile(FILE_BIN|FILE_READ);
   if(handle == INVALID_HANDLE || !LoadXmlDoc(handle))
      res = false;
   else
      FileClose(handle);
   if(!xPos.DetectModify(currElement))
      res = false;
   else
   {
      //printf("Load: Changes detected");
      res = ReadMe();
   }
   if(CheckPointer(doc) != POINTER_INVALID)
      delete doc;
   return res;
}

/*bool XmlPos2::SaveState2(ENUM_STATE_TYPE type = STATE_REFRESH)
{
   bool res = true;
   if(file.FileOpen(FILE_WRITE) == INVALID_HANDLE)
      return false;
   else if(!LoadXmlDoc(file.GetHandle()))
      res = false;
   else
   {
      //printf("I save new XML state" + (string)xPos.PositionId());
      file.FillSpace();
      DeleteMe();
      if(type == STATE_REFRESH)
         CreateMe();
      SaveXmlDoc(file.GetHandle());
   }
   file.FileClose();
   return res;
}*/

bool XmlPos2::SaveState(ENUM_STATE_TYPE type = STATE_REFRESH)
{
   int handle = TryOpenFile(FILE_BIN|FILE_READ|FILE_WRITE);
   bool res = false;
   if(handle != INVALID_HANDLE && LoadXmlDoc(handle))
   {
      FillSpace(handle);
      DeleteMe();
      if(type == STATE_REFRESH)
         CreateMe();
      SaveXmlDoc(handle);
      res = true;
   }
   if(handle != INVALID_HANDLE)
      FileClose(handle);
   return res;
}

void XmlPos2::FillSpace(int handle)
{
   int size = (int)FileSize(handle);
   uchar spaces[];
   ArrayResize(spaces, size);
   uchar ch = ' '; 
   ArrayInitialize(spaces, ch);
   FileSeek(handle, 0, SEEK_SET);
   FileWriteArray(handle, spaces, 0, ArraySize(spaces));
}

bool XmlPos2::ContainsMe(void)
{
   if(CheckPointer(currElement) != POINTER_INVALID)
      return true;
   return false;
   /*if(CheckPointer(doc) == POINTER_INVALID)return false;
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         return true;
   }
   return false;*/
}

void XmlPos2::CreateMe(void)
{
   if(CheckPointer(doc) == POINTER_INVALID)return;
   if(ContainsMe())
      DeleteMe();
   CXmlElement* element = xPos.GetXmlElement();
   doc.FDocumentElement.ChildAdd(element);
}

void XmlPos2::DeleteMe(void)
{
   if(!ContainsMe())return;
   doc.FDocumentElement.ChildDelete(currElement);
   /*int count = doc.FDocumentElement.GetChildCount();
   for(int i = count-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         doc.FDocumentElement.ChildDelete(i);
   }*/
}

bool XmlPos2::ReadMe()
{
   if(ContainsMe())
      return xPos.SetXmlElement(currElement);
   return false;
   /*if(CheckPointer(doc) == POINTER_INVALID)return false;
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0 ; i--)
   {
      CXmlElement* element = doc.FDocumentElement.GetChild(i);
      if(xPos.IsMyElement(element))
         return xPos.SetXmlElement(element);
   }
   return false;*/
}