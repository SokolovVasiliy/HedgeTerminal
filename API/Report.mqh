///
/// Класс формирует требуемый отчет и сохраняет его в файл.
///
class Report
{
   public:
      ///
      /// Формирует отчет в виде CSV файла и сохраняет его на диск.
      ///
      static void SaveCSV();
      ///
      /// Формирует отчет в виде XML файла и сохраняет его на диск.
      ///
      static void SaveXML();
   private:
      Report();
      ///
      /// Возвращает линию.
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