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
         int handle = FileOpen(fileName, FILE_COMMON|FILE_READ|FILE_BIN, "");
         if(handle == -1)
         {
            printf("Filed open file " + fileName + ". Reason: " + (string)GetLastError());
            return false;
         }
         int size = ArrayResize(resource, (int)FileSize(handle));
         for(int seek = 0; seek < size; seek++)
         {
            FileSeek(handle, seek, SEEK_SET);
            ushort ch = (ushort)FileReadInteger(handle, CHAR_VALUE);
            resource[seek] = ch;
         }
         return true;
      }
      bool SaveResurce(string fileName, string nameArray)
      {
         int handle = FileOpen(fileName, FILE_WRITE|FILE_TXT, "");
         if(handle == -1)
            return false;
         int size = ArraySize(resource);
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
      ushort resource[];
      ///
      /// Экземпляр создать нельзя.
      ///
      //CreatedResources();
};

CreatedResources CR;

void OnStart()
{
   //Загружаем из папки Common\Files
   //CR.LoadResource("Prototypes.mqh");
   //Сохраняем в локальную папку \Files
   //CR.SaveResurce("Prototypes.mqh.mqh", "array_prototypes");
   
   CR.LoadResource("HedgeMAExpert.mq5");
   CR.SaveResurce("HedgeMA.mq5.mqh", "array_hedge_ma");
}