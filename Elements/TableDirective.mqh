#define TABLE_DIRECTIVE_MQH
///
/// ���������� ��� ������� �������. ������������ � �������� ����� ���������������� ���� ��������� � ENUM_TABLE_TYPE_ELEMENT.
///
enum ENUM_TABLE_TYPE
{
   ///
   /// ������� ��-���������. ���������� ������ �� ������������.
   ///
   TABLE_DEFAULT = 0,
   ///
   /// ������� �������� �������.
   ///
   TABLE_POSACTIVE = 1,
   ///
   /// ������� ������������ �������.
   ///
   TABLE_POSHISTORY = 2,
};

///
/// ���������� ��� ����������� ����������� ��������, ������� ������ � 
/// ������� ����������� ������������� �������/������/��������� �������.
///
enum ENUM_TABLE_TYPE_ELEMENT
{
   ///
   /// ������������ ������� ������ � ������ ��������� �������.
   ///
   TABLE_HEADER = 4,
   ///
   /// ������������ ������� ������ � ������ ������������ ������������� �������.
   ///
   TABLE_POSITION = 8,
   ///
   /// ����������� ������� ������ � ������ ������������ ������������� ������.
   ///
   TABLE_DEAL = 16
};

///
/// ����� �������� ����������, ����������� ��� �������� �����������
/// ����������� �������� �������. ���������� �������� � ����: ��� �������,
/// ��� ������ (���������, �������, ������ � �.�.). �� ���� ���������� � ����� �����
/// ����������� �������������� ���������� ����������� ��� ���������� ���������.
///
class TableDirective
{
   public:  
      //TableDirective()
      ///
      /// ���������� ��� �������, � ������� ����� ������������ �������.
      ///
      ENUM_TABLE_TYPE TableType(){return tableType;}
      ///
      /// ������������� ��� �������, � ������� ����� ������������ �������.
      ///
      void TableType(ENUM_TABLE_TYPE tType){tableType = tType;}
      
      ///
      /// ���������� ��� ��������, ������� ��������� �������������.
      ///
      ENUM_TABLE_TYPE_ELEMENT TableElement(){return tableElement;}
      ///
      /// ������������� ��� ��������, ������� ��������� �������������.
      ///
      void TableElement(ENUM_TABLE_TYPE_ELEMENT el){tableElement = el;}
      ///
      /// ���������� ������, ���� ������ ������, ���������� ������������� ������� ���������
      /// �������������, �������� ��������� � ������.
      ///
      bool IsLastDeal(){return lastDeal;}
      ///
      /// ������������� ������, �����������, �������� �� ������ ������ ��������� � ������
      /// ������. ������������ ��� ����������� ������ �������� TrewViewBox ��� ������.
      ///
      void IsLastDeal(bool lDeal){lastDeal = lDeal;}
      ///
      /// ���������� ������, ���� �������, ��� ������� ���������� ���������� �������
      /// ���������� � ������ ������ ������� (������������ � ��������).
      ///
      bool IsPositionTable()
      {
         if(tableType == TABLE_POSACTIVE || tableType == TABLE_POSHISTORY)
            return true;
         return false;
      }
   private:
      ///
      /// �������� ��� �������, � ������� ����� ������������ �������.
      ///
      ENUM_TABLE_TYPE tableType;
      ///
      /// �������� ��� ��������, ������� ��������� �������������.
      ///
      ENUM_TABLE_TYPE_ELEMENT tableElement;
      ///
      /// ������ ��� ������. �������� ������, ���� ������ ������, ���������� �������������
      /// ������� ��������� �������������, �������� ��������� � ������.
      ///
      bool lastDeal;
};