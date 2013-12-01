
///
/// Абстрактный класс одной из строк таблицы позиций. Строка может быть заголовком таблицы, позицией или сделкой.
/// Ее тип должен быть определен в момент создания.
///
class AbstractPos2 : public Line
{
   public:
      ///
      /// Возвращает тип таблицы, к которой принадлежит текущая строка.
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
         //Получаем список колонок, которые надо сгенерировать.
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
               //Если тип таблицы неизвестен, то и генерировать нечего.
               return; 
         }
         //Формируем линию.
         int total = scolumns.Total();
         for(int i = 0; i < total; i++)
            AddColumn(scolumns.At(i));
      }
      ///
      /// Создает элемент по-умолчанию.
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
/// Класс реализует строку-заголовок таблицы позиций.
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
         //В отличии от реализации по-умолчанию создается кнопка, а не текстовая метка.
         build = new Button(el.Name(), GetPointer(this));
         build.OptimalWidth(el.OptimalWidth());
         build.ConstWidth(el.ConstWidth());
         return build;
      }
      ///
      /// Создает элемент по-умолчанию.
      ///
      virtual TextNode* AddColumn(DefColumn* el)
      {
         ;
      }
      ///
      /// Наполняет строку в зависимости от типа текущей позиции. 
      ///
      virtual void BuilderLine()
      {
         AbstractPos2::BuilderLine();
      }
};

///
/// Класс реализует строку-позицию таблицы позиций.
///
class PosLine2 : AbstractPos2
{
   public:
      PosLine2(ProtoNode* parNode, ENUM_TABLE_TYPE tType, Position* m_pos) : AbstractPos2("header", ELEMENT_TYPE_POSITION, parNode, tType){;}
   private:
      ///
      /// Указатель на позицию, которую представляет данная строка.
      ///
      Position* pos;
};

///
/// Класс реализует строку-позицию таблицы позиций.
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
      /// Позиция, к которой принадлежат текущие трейды (если есть).
      ///
      Position* pos;
      ///
      /// Сделка входа в позицию (если есть).
      ///
      Deal* entryDeal;
      ///
      /// Сделка выхода из позиции (если есть).
      ///
      Deal* exitDeal;
      ///
      /// Истина, если текущая строка, представляющая трейд последняя в списке трейдов.
      ///
      bool isLastLine;
};


