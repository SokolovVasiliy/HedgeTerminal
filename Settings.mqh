#define SETTINGS_MQH
///
/// �������� �������� ��������� ������.
///
class CTheme
{
   public:
      ///
      /// ���������� �������� ���� ����.
      ///
      color GetBackgroundColor(){return clrWhite;}
      ///
      /// ���������� ���� ������� ���������.
      ///
      color GetBorderColor(){return clrBlack;}
      ///
      /// ���������� ���� ��������� ���������.
      ///
      color GetSystemColor(){return clrWhiteSmoke;}
      ///
      /// ���������� ���� �������.
      ///
      color GetCursorColor(){return clrLightSteelBlue;}
};
///
/// �������� �������� �������.
///
class CNameColumns
{
   public:
      ///
      /// ���������� ��� �������� TreeViewBox.
      ///
      string Collapse(){return "CollapsePos.";}
      ///
      /// ���������� ��� ������ ����������� ������.
      ///
      string Magic(){return "Magic";}
      ///
      /// ���������� ��� ������ �������.
      ///
      string Symbol(){return "Symbol";}
      ///
      /// ���������� ��� ������ ������������ id ��������� ������.
      ///
      string EntryOrderId(){return "Entry Order ID";}
};
///
/// �����-���������� ���������� ��������
///
class Settings
{
   public:
      ///
      /// ���������� ���������� �����, ���������� ��������� ����������.
      /// ���� ����� ��� ��� ����� ������, ����� ��������� ��������� �� �����
      /// ��������� �����.
      ///
      static Settings* GetSettings()
      {
         if(set == NULL)
            set = new Settings();
         return set;
      }
      ///
      /// ��������� ����� ���������� ���� ��������� �� �����.
      ///
      void Reread()
      {
         ;
      }
      CTheme ColorTheme;
      CNameColumns ColumnsName;
   private:        
      static Settings* set;
      Settings(){};
      Settings* operator=(const Settings*);
      ~Settings();
};
