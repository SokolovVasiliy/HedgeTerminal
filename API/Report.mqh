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
         return "development";
      }
};