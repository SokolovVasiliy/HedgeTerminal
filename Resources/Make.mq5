#define MAKE_UTIL
//#include "Resources.mqh"

#include <Files\FileBin.mqh>
#include <Files\FileTxt.mqh>

void OnStart()
{
   CCreatedResources CreatedResources;
   // Файл настроек
   CreatedResources.LoadResource(".\HedgeTerminal\Settings.xml");
   CreatedResources.SaveResurce(".\HedgeTerminal\MQH\Settings.xml.mqh", "array_settings");
   // Файл активных позиций.
   CreatedResources.LoadResource(".\HedgeTerminal\ActivePositions.xml");
   CreatedResources.SaveResurce(".\HedgeTerminal\MQH\ActivePositions.xml.mqh", "array_active_pos");
   // Файл исторических позиций.
   CreatedResources.LoadResource(".\HedgeTerminal\HistoryPositions.xml");
   CreatedResources.SaveResurce(".\HedgeTerminal\MQH\HistoryPositions.xml.mqh", "array_hist_pos");
   // Файл псевдонимов.
   CreatedResources.LoadResource(".\HedgeTerminal\ExpertAliases.xml");
   CreatedResources.SaveResurce(".\HedgeTerminal\MQH\ExpertAliases.xml.mqh", "array_aliases");
   // Файл шрифта 
   CreatedResources.LoadResource(".\HedgeTerminal\Arial Rounded MT Bold Bold.ttf");
   CreatedResources.SaveResurce(".\HedgeTerminal\MQH\Font_MT_Bold.ttf.mqh", "array_font_bolt");
   // Файл прототипов.
   CreatedResources.LoadResource(".\HedgeTerminal\Prototypes.mqh");
   CreatedResources.SaveResurce(".\HedgeTerminal\MQH\Prototypes.mqh.mqh", "array_prototypes");
   //
   CreatedResources.LoadResource(".\HedgeTerminal\ExcludeOrders.xml");
   CreatedResources.SaveResurce(".\HedgeTerminal\MQH\ExcludeOrders.xml.mqh", "array_exclude_orders");
}

///
/// Создатель ресурсов.
///
class CCreatedResources
{
   public:
      ///
      /// Загружает ресурс из файла.
      /// \return Истина, если загрузка прошла успешно и ложь в противном случае.
      ///
      bool LoadResource(string fileName)
      {
         int handle = FileOpen(fileName, FILE_READ|FILE_BIN, "");
         if(handle == -1)return false;
         int size = ArrayResize(resource, (int)FileSize(handle));
         for(int seek = 0; seek < size; seek++)
         {
            FileSeek(handle, seek, SEEK_SET);
            ushort ch = (ushort)FileReadInteger(handle, CHAR_VALUE);
            resource[seek] = ch;
         }
         return true;
      }
      ///
      /// Сохраняет ресурс в указанном файле.
      ///
      bool SaveResurce(string fileName, string nameArray)
      {
         if(fileOut.IsExist(fileName))
         {
            if(!FileDelete(fileName))
            {
               printf("File " + fileName + " already exits.");
               return false;
            }
         }
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
