input string FileName;
#include <Files\FileBin.mqh>
#include <Files\FileTxt.mqh>

///
/// Создатель ресурсов.
///
class CreatedResources
{
   public:
      ///
      /// Загружает ресурс из файла.
      /// \return Истина, если загрузка прошла успешно и ложь в противном случае.
      ///
      bool LoadResource(string fileName)
      {
         int handle = FileOpen(fileName, FILE_READ|FILE_BIN, "");
         if(handle == -1)
         {
            printf("Filed open file " + fileName + ". Reason: " + (string)GetLastError());
            return false;
         }
         FileReadArray(handle, resource, WHOLE_ARRAY);
         FileClose(handle);
         return true;
      }
      
      bool SaveResurce(string fileName, string nameArray)
      {
         int size = ArraySize(resource);
         if(size == 0)
            return false;
         int handle = FileOpen(fileName, FILE_WRITE|FILE_TXT, "");
         if(handle == -1)
            return false;
         string strSize = (string)size;
         string strArray = "uchar " +nameArray + "[" + strSize + "] = \n{\n";
         FileWriteString(handle, strArray);
         string line = "   ";
         int chaptersLine = 32;
         for(int i = 0; i < size; i++)
         {
            ushort ch = resource[i];
            line += (string)ch;
            if(i == size - 1)
               line += "\n";
            if(i>0 && i%chaptersLine == 0)
            {
               if(i < size-1)
                  line += ",\n";
               FileWriteString(handle, line);
               line = "   ";
            }
            else if(i < size - 1)
               line += ",";
         }
         if(line != "")
            FileWriteString(handle, line);
         FileWriteString(handle, "};");
         FileClose(handle);
         ArrayResize(resource, 0);
         return true;
      }
      
   private:
      ///
      /// Читатель бинарного файла.
      ///
      CFileBin fileIn;
      ///
      /// Создатель файла ресурса.
      ///
      CFileTxt fileOut;
      ///
      /// Динамический массив, содержащий байтовое представление ресурса.
      ///
      uchar resource[];
};

CreatedResources CR;

void OnStart()
{
   //Загружаем из папки Common\Files
   /*CR.LoadResource("COT - SYMBOLS.xml");
   CR.SaveResurce("COT - SYMBOLS.xml.mqh", "array_cot_symbols_xml");
   
   CR.LoadResource("COT - CONTINUES.xml");
   CR.SaveResurce("COT - CONTINUES.xml.mqh", "array_cot_cont_xml");
   
   CR.LoadResource("DCOT - SYMBOLS.xml");
   CR.SaveResurce("DCOT - SYMBOLS.xml.mqh", "array_dcot_symbols_xml");
   
   CR.LoadResource("DCOT - CONTINUES.xml");
   CR.SaveResurce("DCOT - CONTINUES.xml.mqh", "array_dcot_cont_xml");
   
   CR.LoadResource("TFF - SYMBOLS.xml");
   CR.SaveResurce("TFF - SYMBOLS.xml.mqh", "array_tff_symbols_xml");
   
   CR.LoadResource("CIT - SYMBOLS.xml");
   CR.SaveResurce("CIT - SYMBOLS.xml.mqh", "array_cit_symbols_xml");
   
   CR.LoadResource("CIT - CONTINUES.xml");
   CR.SaveResurce("CIT - CONTINUES.xml.mqh", "array_cit_cont_xml");*/
   
   CR.LoadResource("USDCHF_M5.csv");
   CR.SaveResurce("ds.mqh", "ds");
}