///
/// ����� ��������� ��������� ����� � ��������� ��� � ����.
///
class Report
{
   public:
      ///
      /// ��������� ����� � ���� CSV ����� � ��������� ��� �� ����.
      ///
      static void SaveCSV();
      ///
      /// ��������� ����� � ���� XML ����� � ��������� ��� �� ����.
      ///
      static void SaveXML();
   private:
      Report();
      ///
      /// ���������� �����.
      ///
      static string GetLine(Transaction* trans)
      {
         CArrayObj* obj = Settings.GetSetForActiveTable();
         string line = "";
         for(int i = 0; i < obj.Total(); i++)
         {
            DefColumn* column = obj.At(i);
            /*switch(column.ColumnType())
            {
               case COLUMN_COLLAPSE:
                  
            }*/
         }
         return line;  
      }
};