input string FileName;
#include <Files\FileBin.mqh>
#include <Files\FileTxt.mqh>

void OnStart()
{
   bool res = FolderCreate("HedgeTerminal");
   printf(res);
   CreatedResources::LoadResource("test.xml");
   CreatedResources::SaveResurce("test.mqh", "test_mqh");
}

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
      static bool LoadResource(string fileName)
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
      static bool SaveResurce(string fileName, string nameArray)
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
      ///
      /// ������� ������ ������� � ��������� ��� � ���� ���������� ������� � ����� fileName
      /// \param fileName - ��� ����� � ������� ����� ������������� ������ �������.
      /// \param nameArray - ��� ������� �������.
      /// \return 
      ///
      /*static bool SaveResurce(string fileName, string nameArray)
      {
         int handle = FileOpen(fileName, FILE_WRITE|FILE_TXT, "");
         
         if(!fileOut.Open(fileName, FILE_WRITE|FILE_TXT, ""))
            return false;
         int size = ArraySize(resource);
         string strSize = (string)size;
         //fileOut.WriteString("// This file was created automated. Manual editing not welcome.");
         fileOut.WriteString("uchar " +nameArray + "[" + strSize + "] = {" );
         // ���������� ���� � ����� ������
         int chaptersLine = 32;
         string line = "";
         for(int i = 0; i < size; i++)
         {
            ushort ch = resource[i];
            line += "," + (string)ch;
            if(i%chaptersLine == 0)
            {
               fileOut.WriteString(line + ",");
               line = "";
            }
         }
         fileOut.WriteString("};");
         fileOut.Close();
         
         return true;
      }*/
   private:
      ///
      /// �������� ��������� �����.
      ///
      static CFileBin fileIn;
      ///
      /// ��������� ����� �������.
      ///
      static CFileTxt fileOut;
      ///
      /// ������������ ������, ���������� �������� ������������� �������.
      ///
      static ushort resource[];
      ///
      /// ��������� ������� ������.
      ///
      CreatedResources();
};
