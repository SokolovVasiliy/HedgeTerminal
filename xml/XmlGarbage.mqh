#include <Arrays\ArrayObj.mqh>
#include "XmlBase.mqh"
#include "XmlDocument.mqh"
#include "XmlPos.mqh"
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
};

void XmlGarbage::ClearActivePos(string fileName, CArrayObj *posList)
{
   CXmlDocument doc;
   string error;
   if(!doc.CreateFromFile(fileName, error))
      return;
   ulong accountId = AccountInfoInteger(ACCOUNT_LOGIN);
   bool res = false;
   XmlPos* xPos;
   for(int i = 0; i < doc.FDocumentElement.GetChildCount(); i++)
   {
      CXmlElement* xmlItem = doc.FDocumentElement.GetChild(i);
      xPos = new XmlPos(xmlItem);
      if(!xPos.IsValid())
      {
         doc.FDocumentElement.ChildDelete(i);
         i--;
         res = true;
      }  
      else if((xPos.IsValid() && xPos.AccountId() == accountId))
      {
         TransId* trans = new TransId(xPos.Id());
         int index = posList.Search(trans);
         delete trans;
         if(index == -1)
         {
            doc.FDocumentElement.ChildDelete(i);
            i--;
            res = true;
         }
      }
      delete xPos;
   }
   if(res)
      doc.SaveToFile(fileName);
}