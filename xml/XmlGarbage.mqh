#include <Arrays\ArrayObj.mqh>
#include <XML\XmlBase.mqh>
#include <XML\XmlDocument.mqh>
#include "..\Log.mqh"
///
/// —борщик устаревших узлов XML
///
class XmlGarbage
{
   public:
      ///
      /// ”дал€ет xml узлы из файла активных позиций, которые не соответствуют ни
      /// одной из активных позиций в списке активных позиций.
      ///
      void ClearActivePos(string fileName, CArrayObj* posList);
   private:
      bool FindPosWithId(long id, CArrayObj* posList);
};

void XmlGarbage::ClearActivePos(string fileName, CArrayObj *posList)
{
   if(MQLInfoInteger(MQL_TESTER))
      return;
   CXmlDocument doc;
   string error;
   if(!doc.CreateFromFile(fileName, error))
      return;
   ulong accountId = AccountInfoInteger(ACCOUNT_LOGIN);
   bool res = false;
   //XmlPos* xPos;
   for(int i = doc.FDocumentElement.GetChildCount()-1; i >= 0; i--)
   {
      CXmlElement* xmlItem = doc.FDocumentElement.GetChild(i);
      CXmlAttribute* attr = xmlItem.GetAttribute("AccountID");
      if(attr != NULL)
      {
         long id = StringToInteger(attr.GetValue());
         if(id != accountId)continue;
      }
      else
      {
         LogWriter(fileName + ": Detect bad xml node. Attribute \'AccountID\'. Node will be removed.", MESSAGE_TYPE_ERROR);
         doc.FDocumentElement.ChildDelete(i);
         continue;
      }
      attr = xmlItem.GetAttribute("ID");
      if(attr != NULL)
      {
         long id = StringToInteger(attr.GetValue());
         if(!FindPosWithId(id, posList))
            doc.FDocumentElement.ChildDelete(i);
      }
      else
      {
         LogWriter(fileName + ": Detect bad xml node. Attribute \'ID\' missing. Node will be removed.", MESSAGE_TYPE_ERROR);
         doc.FDocumentElement.ChildDelete(i);
         continue;
      }
   }
   doc.SaveToFile(fileName);
}

bool XmlGarbage::FindPosWithId(long id, CArrayObj* posList)
{
   for(int i = 0; i < posList.Total(); i++)
   {
      Transaction* trans = posList.At(i);
      if(trans.GetId() == id)
         return true;
   }
   return false;
}