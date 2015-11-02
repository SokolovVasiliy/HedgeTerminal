input string FileName;
#include <Files\FileBin.mqh>
#include <Files\FileTxt.mqh>

///
/// ��������� ��������.
///
class CreatedResources
{
   public:
      ///
      /// ��������� ������ �� �����.
      /// \return ������, ���� �������� ������ ������� � ���� � ��������� ������.
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
      /// �������� ��������� �����.
      ///
      CFileBin fileIn;
      ///
      /// ��������� ����� �������.
      ///
      CFileTxt fileOut;
      ///
      /// ������������ ������, ���������� �������� ������������� �������.
      ///
      ushort resource[];
      ///
      /// ��������� ������� ������.
      ///
      //CreatedResources();
};

CreatedResources CR;

void OnStart()
{
   //��������� �� ����� Common\Files
   //CR.LoadResource("Prototypes.mqh");
   //��������� � ��������� ����� \Files
   //CR.SaveResurce("Prototypes.mqh.mqh", "array_prototypes");
   
   CR.LoadResource("HedgeMAExpert.mq5");
   CR.SaveResurce("HedgeMA.mq5.mqh", "array_hedge_ma");
}