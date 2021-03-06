#include "Transaction.mqh"
#include "Order.mqh"
#include "Deal.mqh"
#include "Position.mqh"
#include "..\Settings.mqh"
#include "..\Time.mqh"
#include "..\LibXML\XmlAttribute.mqh"
#include "..\LibXML\XmlElement.mqh"
#include "..\LibXML\XmlDocument.mqh"
///
/// Òèï ãåíåðèðóåìîãî îò÷åòà.
///
enum ENUM_REPORT_TYPE
{
   REPORT_CSV,
   REPORT_XML,
   REPORT_HTML
};

///
/// Êëàññ êîíâåðòèðóåò ïîçèöèþ â îäèí èç ýëåìåíòîâ îò÷åòà. Ôîðìàò îò÷åòà
/// ìîæåò áûòü ðàçíûì, íàïðèìåð CSV èëè XML.
///
class Report
{
   private:
      ///
      /// Ðàçäåëèòüåëü äëÿ CSV-ñòðîêè.
      ///
      string csv_delimiter;
      ///
      /// Ïîëó÷àåò ñòðîêîâîå çíà÷åíèå ñâîéñòâà ïîçèöèè, îïðåäåëåííîå êîëîíêîé column.
      ///
      string GetStringValue(Position* pos, DefColumn* column);
      ///
      /// Ãåíåðèðóåò îò÷åò â CSV ôîðìàòå è ñîõðàíÿåò åãî.
      ///
      bool SaveToCsv(void);
      ///
      /// Ïîëó÷àåò çàãîëîâîê îò÷åòà äëÿ àêòèâíûõ èëè èñòîðè÷åñêèõ ïîçèöèé â csv ôîðìàòå.
      /// \param tType - Òèï òàáëèöû, îïðåäåëÿþùèé çàãîëîâîê äëÿ êàêîé òàáëèöû áóäåò âîçâðàùåí.
      ///
      string GetCsvHeader(ENUM_TABLE_TYPE tType);
      ///
      /// Âîçâðàùàåò ìàññèâ csv-ñòðîê ïðåäñòàâëÿþùèé çíà÷åíèÿ ïîçèöèé íàõîäÿùèõñÿ â òàáëèöå tType.
      /// \param tType
      ///
      CArrayString* GetCsvLines(ENUM_TABLE_TYPE tType);
      ///
      /// Âîçâðàùàåò csv-ñòðîêó ñîäåðæàùóþ äàííûå ïî ïîçèöèè 'pos'.
      ///
      string GetCsvLine(Position* pos);
      ///
      /// Ñîõðàíÿåò çàãîëîâîê è ìàññèâ csv-ñòðîê â ôàéë. 
      /// \return Èñòèíà, åñëè ñîõðàíåíèå â ôàéë óäëîñü è ëîæü â ïðîòèâíîì ñëó÷àå.
      ///
      bool SaveCsv(string header, CArrayString* lines, string fileName);
      ///
      bool SaveToXml(void);
      ///
      bool SaveToHtml(void){return false;}
      ///
      /// Âîçâðàùàåò xml-áëîê àêòèâíûõ èëè èñòîðè÷åñêèõ ïîçèöèé.
      ///
      CXmlElement* GetXmlPositions(ENUM_TABLE_TYPE tType);
      ///
      /// Âîçâðàùàåò xml-ïðåäñòàâëåíèå ïîçèöèè 'pos'.
      ///
      CXmlElement* GetXmlPosition(Position* pos);
      ///
      /// Êîíâåðòèðóåò ïàðàìåòð ïîçèöèè à àòðèáóò xml ïîçèöèè.
      ///
      CXmlAttribute* ValueToXmlAttribute(string name, string value);
   public:
      ///
      /// Êîíñòðóêòîð ïî-óìîë÷àíèþ.
      ///      
      Report();
      ///
      /// Ñîõðàíÿåò îò÷åò òèïà 'type' â ôàéë.
      ///
      bool SaveToFile(ENUM_REPORT_TYPE type);
      
};

Report::Report(void)
{
   csv_delimiter = ";";
}

bool Report::SaveToFile(ENUM_REPORT_TYPE type)
{
   switch(type)
   {
      case REPORT_CSV:
         return SaveToCsv();
      case REPORT_XML:
         return SaveToXml();
      case REPORT_HTML:
         return SaveToHtml();
   }
   return false;
}

bool Report::SaveToCsv(void)
{
   bool res = true;
   //Ñîõðàíÿåì àêòèâíûå ïîçèöèè â csv-ôàéë.
   string header = GetCsvHeader(TABLE_POSACTIVE);
   CArrayString* lines = GetCsvLines(TABLE_POSACTIVE);
   string path = Resources.GetBrokerDirectory() + "Active.csv";
   if(!SaveCsv(header, lines, path))
   {
      LogWriter("Filed save Active.csv in" + path + ". Reason: " + (string)GetLastError(), MESSAGE_TYPE_ERROR);
      res = false;
   }
   else
      LogWriter("Report Active.csv successfully saved in " + path, MESSAGE_TYPE_INFO);
   delete lines;
   //Ñîõðàíÿåì èñòîðè÷åñêèå ïîçèöèè â csv-ôàéë.
   header = GetCsvHeader(TABLE_POSHISTORY);
   lines = GetCsvLines(TABLE_POSHISTORY);
   path = Resources.GetBrokerDirectory() + "History.csv";
   if(!SaveCsv(header, lines, path))
   {
      LogWriter("Filed save History.csv in " + path + ". Reason: " + (string)GetLastError(), MESSAGE_TYPE_ERROR);
      res = false;
   }
   else
      LogWriter("Report History.csv successfully saved in " + path, MESSAGE_TYPE_INFO);
   delete lines;
   return res;
}
bool Report::SaveCsv(string header,CArrayString *lines,string fileName)
{
   int handle = FileOpen(fileName, FILE_WRITE|FILE_TXT|FILE_CSV|Resources.FileCommon());
   if(handle == INVALID_HANDLE)
      return false;
   FileWriteString(handle, header+"\n");
   for(int i = 0; i < lines.Total(); i ++)
   {
      string csv_line = lines.At(i);
      FileWriteString(handle, csv_line+"\n");
   }
   FileClose(handle);
   return true;
}

string Report::GetCsvHeader(ENUM_TABLE_TYPE tType)
{
   CArrayObj* columns = NULL;
   if(tType == TABLE_DEFAULT)
      return "";
   if(tType == TABLE_POSACTIVE)
      columns = Settings.GetSetForActiveTable();
   else
      columns = Settings.GetSetForHistoryTable();
   string header = "";
   for(int i = 0; i < columns.Total(); i++)
   {
      DefColumn* column = columns.At(i);
      header += column.Name() + csv_delimiter;
   }
   return header;
}

CArrayString* Report::GetCsvLines(ENUM_TABLE_TYPE tType)
{
   CArrayString* lines = NULL;
   if(tType == TABLE_DEFAULT)
      return lines;
   lines = new CArrayString();
   if(tType == TABLE_POSACTIVE)
   {
      lines.Reserve(callBack.ActivePosTotal());
      for(int i = 0; i < callBack.ActivePosTotal(); i++)
      {
         Position* pos = callBack.ActivePosAt(i);
         string csv_line = GetCsvLine(pos);
         if(csv_line != NULL && csv_line != "")
            lines.Add(csv_line);
      }
   }
   else
   {
      lines.Reserve(callBack.HistoryPosTotal());
      for(int i = 0; i < callBack.HistoryPosTotal(); i++)
      {
         Position* pos = callBack.HistoryPosAt(i);
         string csv_line = GetCsvLine(pos);
         if(csv_line != NULL && csv_line != "")
            lines.Add(csv_line);
      }
   }
   return lines;
}

string Report::GetCsvLine(Position *pos)
{
   if(pos.Status() == POSITION_NULL)
      return NULL;
   CArrayObj* columns = NULL;
   if(pos.Status() == POSITION_ACTIVE)
      columns = Settings.GetSetForActiveTable();
   else if(pos.Status() == POSITION_HISTORY)
      columns = Settings.GetSetForHistoryTable();
   else
      return NULL;
   string csv_line = "";
   for(int i = 0; i < columns.Total(); i++)
   {
      DefColumn* column = columns.At(i);
      string value = GetStringValue(pos, column);
      csv_line += value + csv_delimiter;
   }
   return csv_line;
}

string Report::GetStringValue(Position* pos, DefColumn* column)
{
   string value = "";
   switch(column.ColumnType())
   {
      case COLUMN_MAGIC:
         value = (string)pos.Magic();
         break;
      case COLUMN_SYMBOL:
         value = pos.Symbol();
         break;
      case COLUMN_ENTRY_ORDER_ID:
         value = (string)pos.GetId();
         break;
      case COLUMN_EXIT_ORDER_ID:
         value = (string)pos.ExitOrderId();
         break;
      case COLUMN_ENTRY_DATE:
      case COLUMN_EXIT_DATE:
      {
         CTime* ctime = NULL;
         if(column.ColumnType() == COLUMN_ENTRY_DATE)
            ctime = new CTime(pos.EntryExecutedTime());
         else
            ctime = new CTime(pos.ExitExecutedTime());
         value = ctime.TimeToString(TIME_DATE|TIME_MINUTES|TIME_SECONDS);
         delete ctime;
         break;
      }
      case COLUMN_TYPE:
         value = pos.TypeAsString();
         break;
      case COLUMN_VOLUME:
         value = pos.VolumeToString(pos.VolumeExecuted());
         break;
      case COLUMN_ENTRY_PRICE:
         value = pos.PriceToString(pos.EntryExecutedPrice());
         break;
      case COLUMN_EXIT_PRICE:
         value = pos.PriceToString(pos.ExitExecutedPrice());
         break;
      case COLUMN_SL:
         value = pos.PriceToString(pos.StopLossLevel());
         break;
      case COLUMN_TP:
         value = pos.PriceToString(pos.TakeProfitLevel());
         break;
      case COLUMN_CURRENT_PRICE:
         value = pos.PriceToString(pos.CurrentPrice());
         break;
      case COLUMN_COMMISSION:
         value = pos.PriceToString(pos.Commission());
         break;
      case COLUMN_PROFIT:
         value = DoubleToString(pos.ProfitInCurrency(), 8);
         break;
      case COLUMN_ENTRY_COMMENT:
         value = pos.EntryComment();
         break;
      case COLUMN_EXIT_COMMENT:
         value = pos.ExitComment();
         break;
      default:
         break;
   }
   return value;
}

bool Report::SaveToXml(void)
{
   CXmlDocument xDoc;
   xDoc.SetCommon(Resources.FileCommon());
   xDoc.FDocumentElement.SetName("Report");
   CXmlElement* xmlActive = GetXmlPositions(TABLE_POSACTIVE);
   xDoc.FDocumentElement.ChildAdd(xmlActive);
   //CXmlElement* xmlHistory = GetXmlPositions(TABLE_POSHISTORY);
   //xDoc.FDocumentElement.ChildAdd(xmlHistory);
   string path = Resources.GetBrokerDirectory() + "Report.xml";;
   xDoc.SaveToFile(path);
   xDoc.Clear();
   return true;   
}

CXmlElement* Report::GetXmlPositions(ENUM_TABLE_TYPE tType)
{
   if(tType == TABLE_DEFAULT)
      return NULL;
   CXmlElement* positions = new CXmlElement();
   
   if(tType == TABLE_POSACTIVE)
   {
      positions.SetName("Active-Positions");
      for(int i = 0; i < callBack.ActivePosTotal(); i++)
      {
         Transaction* trans = callBack.ActivePosAt(i);
         if(trans.TransactionType() != TRANS_POSITION)
            continue;
         Position* pos = trans;
         CXmlElement* xmlPos = GetXmlPosition(pos);
         positions.ChildAdd(xmlPos);
      }
   }
   if(tType == TABLE_POSHISTORY)
   {
      positions.SetName("History-Positions");
      for(int i = 0; i < callBack.HistoryPosTotal(); i++)
      {
         Transaction* trans = callBack.HistoryPosAt(i);
         if(trans.TransactionType() != TRANS_POSITION)
            continue;
         Position* pos = trans;
         CXmlElement* xmlPos = GetXmlPosition(pos);
         positions.ChildAdd(xmlPos);
      }
   }
   return positions;
}

CXmlElement* Report::GetXmlPosition(Position *pos)
{
   CArrayObj* columns = NULL;
   if(pos.Status() == POSITION_ACTIVE)
      columns = Settings.GetSetForActiveTable();
   else if(pos.Status() == POSITION_HISTORY)
      columns = Settings.GetSetForHistoryTable();
   else
      return NULL;
   CXmlElement* xmlPos = new CXmlElement();
   xmlPos.SetName("Position");
   for(int i = 0; i < columns.Total(); i++)
   {
      DefColumn* column = columns.At(i);
      string value = GetStringValue(pos, column);
      CXmlAttribute* attr = ValueToXmlAttribute(column.Name(), value);
      xmlPos.AttributeAdd(attr);
   }
   return xmlPos;
}

CXmlAttribute* Report::ValueToXmlAttribute(string name, string value)
{
   CXmlAttribute* attr = new CXmlAttribute();
   attr.SetName(name);
   attr.SetValue(value);
   return attr;
}