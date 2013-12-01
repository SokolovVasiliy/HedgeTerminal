
///
/// ����������� ����� ����� �� ����� ������� �������. ������ ����� ���� ���������� �������, �������� ��� �������.
/// �� ��� ������ ���� ��������� � ������ ��������.
///
class AbstractPos2 : public Line
{
   public:
      ///
      /// ���������� ��� �������, � ������� ����������� ������� ������.
      ///
      ENUM_TABLE_TYPE TableType(){return tblType;}
   protected:
      AbstractPos2(string myName, ENUM_ELEMENT_TYPE elType, ProtoNode* parNode, ENUM_TABLE_TYPE tType) : Line(myName, elType, parNode)
      {
         tblType = tType;
      }
      void BuilderLine()
      {
         if(CheckPointer(Settings) == POINTER_INVALID)return;
         //�������� ������ �������, ������� ���� �������������.
         CArrayObj* scolumns = NULL;
         switch(tblType)
         {
            case TABLE_POSACTIVE:
               scolumns = Settings.GetSetForActiveTable();
               break;
            case TABLE_POSHISTORY:
               scolumns = Settings.GetSetForHistoryTable();
               break;
            default:
               //���� ��� ������� ����������, �� � ������������ ������.
               return; 
         }
         //��������� �����.
         int total = scolumns.Total();
         for(int i = 0; i < total; i++)
            AddColumn(scolumns.At(i));
      }
      ///
      /// ������� ������� ��-���������.
      ///
      virtual TextNode* AddColumn(DefColumn* el)
      {
         ENUM_COLUMN_TYPE cType = el.ColumnType();
         TextNode* element = NULL;
         switch(cType)
         {
            case COLUMN_COLLAPSE:
               element = DefaultBuilder(el);
               element.Text("+");
               break;
            default:
               element = DefaultBuilder(el);
               break;
         }
         if(element != NULL)
            Add(element);
         return element;
      }
      virtual TextNode* AddCollapseEl(DefColumn* el)
      {
         Label* tbox = NULL;
         tbox = new Label(el.Name(), GetPointer(this));
         tbox.Text("+");
         return tbox;
      }
      virtual TextNode* DefaultBuilder(DefColumn* el)
      {
         TextNode* build = NULL;
         build = new Label(el.Name(), GetPointer(this));
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
   private:      
      ENUM_TABLE_TYPE tblType;
};

///
/// ����� ��������� ������-��������� ������� �������.
///
class HeaderPos : public AbstractPos2
{
   public:
      HeaderPos(ProtoNode* parNode, ENUM_TABLE_TYPE tType) : AbstractPos2("header", ELEMENT_TYPE_TABLE_HEADER_POS, parNode, tType)
      {
         BuilderLine();
      }
   private:
      virtual TextNode* DefaultBuilder(DefColumn* el)
      {
         TextNode* build = NULL;
         //� ������� �� ���������� ��-��������� ��������� ������, � �� ��������� �����.
         build = new Button(el.Name(), GetPointer(this));
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      ///
      /// ������� ������� ��-���������.
      ///
      virtual TextNode* AddColumn(DefColumn* el)
      {
         ;
      }
      ///
      /// ��������� ������ � ����������� �� ���� ������� �������. 
      ///
      virtual void BuilderLine()
      {
         AbstractPos2::BuilderLine();
      }
};

///
/// ����� ��������� ������-������� ������� �������.
///
class PosLine2 : AbstractPos2
{
   public:
      PosLine2(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* m_pos) : AbstractPos2("header", ELEMENT_TYPE_POSITION, parNode, tType){;}
   private:
      ///
      /// ��������� �� �������, ������� ������������ ������ ������.
      ///
      Position* pos;
};

///
/// ����� ��������� ������-������� ������� �������.
///
class DealLine2 : public AbstractPos2
{
   public:
      DealLine2(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* mpos, Deal* EntryDeal, Deal* ExitDeal, bool IsLastLine):
      AbstractPos2("Deal", ELEMENT_TYPE_DEAL, parNode, tType)
      {
         ;
      }
   private:
      virtual TextNode* DefaultBuilder(DefColumn* el)
      {
         TextNode* build = AbstractPos2::DefaultBuilder(el);
         build.FontSize(9);
         return build;
      }
      ///
      /// �������, � ������� ����������� ������� ������ (���� ����).
      ///
      Position* pos;
      ///
      /// ������ ����� � ������� (���� ����).
      ///
      Deal* entryDeal;
      ///
      /// ������ ������ �� ������� (���� ����).
      ///
      Deal* exitDeal;
      ///
      /// ������, ���� ������� ������, �������������� ����� ��������� � ������ �������.
      ///
      bool isLastLine;
};


