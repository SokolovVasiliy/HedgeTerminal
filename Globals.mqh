#define VERSION "HedgeTerminal 1.0"
class PanelSettings;
#ifdef HEDGE_PANEL
   ///
   /// Кнопка старта.
   ///
   #define IMG_MENU "::button_img.bmp"
   #resource "button_img.bmp"
   //#resource "Resources\\Fonts\\Arial Rounded MT Bold Bold.ttf"
   //#resource "Resources\\Fonts\\test.fon"
#endif
#include "Prototypes.mqh"
PanelSettings* Settings;

enum ENUM_COLOR_TYPE
{
   COLOR_TEXT,
   COLOR_SYSTEM1,
   COLOR_SYSTEM2,
};

#define LESS -1;
#define GREATE 1;
#define EQUAL 0;


//---------------------------------------------------------------------------------------------------------------------------
// Классы-события.
/// Абстрактный базовый класс события, содержащий основные определения.
class Event;
/// Событие "Видимость визуального элемента изменена".
class EventVisible;
/// Событие "Размер визуального элемента изменен".
class EventResize;
/// Событие "Положение визуального элемента изменено".
class EventMove;
/// Событие "Пришел новый тик".
class EventNewTick;
/// Событие "Выполняется инициализация".
class EventInit;
/// Событие "Выполняется деинициализация".
class EventDeinit;
/// Событие "Команда на изменение видимости, положения и размера визуального элемента".
class EventNodeCommand;
/// Событие "Создана новая позиция".
class EventCreatePos;
/// Событие "Окно панели требуется обновить".
class EventRefresh;
/// Событие "Кнопка нажата/отжата".
class EventButtonPush;
/// Событие "Позиция удалена".
class EventDelPos;
/// Приказ - закрыть активную позицию.
class EventClosePos;
/// Событие "Элемент TreeViewBox раскрыт/закрыт".
class EventCollapseTree;
/// Событие "Приход нового времени".
class EventTimer;
/// Событие "Совершена новая сделка".
class EventAddDeal;

//---------------------------------------------------------------------------------------------------------------------------
// Классы визуальных элементов.

/// Базовый класс любого визуального элемента.
class ProtoNode;
/// Класс, группирующий элементы по определенным алгоритмам.
class Line;
/// Абстрактный базовый класс, поддерживающий ввод и отображение текста.
class TextNode;
/// Визуальный элемент "Таблица".
class Table;
/// Визуальный элемент "Кнопка".
class Button;
/// Визуальный элемент "CheckBox".
class CheckBox;
/// Визуальный элемент "TreeViewBox".
class TreeViewBox;
/// Класс "Вкладки"
class Tab;
/// Класс "Основная форма".
class MainForm;
/// Класс "Прокрутка списка".
class Scroll;
/// класс изображения.
class Image;

//Типы визуальных элементов
///
/// Тип элемента графического интерфейса.
///
enum ENUM_ELEMENT_TYPE
{
   ///
   /// Элемент графического интерфейса "Форма".
   ///
   ELEMENT_TYPE_FORM,
   ///
   /// Элемент графического интерфейса "Таблица".
   ///
   ELEMENT_TYPE_TABLE,
   ///
   /// Элемент графического интерфейса "Заголовок формы".
   ///
   ELEMENT_TYPE_FORM_HEADER,
   ///
   /// Элемент графического интерфейса "Кнопка".
   ///
   ELEMENT_TYPE_BOTTON,
   ///
   /// Элемент графического интерфейса CheckBox.
   ///
   ELEMENT_TYPE_CHECK_BOX,
   ///
   /// Элемент графического интерфейса "Вкладка".
   ///
   ELEMENT_TYPE_TAB,
   ///
   /// Элемент графического интерфейса "Заголовок колонки таблицы".
   ///
   ELEMENT_TYPE_HEAD_COLUMN,
   ///
   /// Элемент графического интерфейса "Горизонтальный контейнер".
   ///
   ELEMENT_TYPE_GCONTAINER,
   ///
   /// Элемент графического интерфейса "Вертикальный контейнер".
   ///
   ELEMENT_TYPE_VCONTAINER,
   ///
   /// Элемент графического интерфейса "Универсальный контейнер".
   ///
   ELEMENT_TYPE_UCONTAINER,
   ///
   /// Элемент графического интерфейса "Позунок".
   ///
   ELEMENT_TYPE_SCROLL,
   ///
   /// Элемент графического интерфейса "Текстовая метка".
   ///
   ELEMENT_TYPE_LABEL,
   ///
   /// Элемент графического интерфейса "Ячейка таблицы".
   ///
   ELEMENT_TYPE_CELL,
   ///
   /// Элемент графического интерфейса "Раскрывающаяся таблица".
   ///
   ELEMENT_TYPE_TREE_VIEW,
   ///
   /// Оформление раскрывающегося списка.
   ///
   ELEMENT_TYPE_TREE_BORDER,
   ///
   /// Строковое представление позиции.
   ///
   ELEMENT_TYPE_POSITION,
   ///
   /// Строковое представление сделки.
   ///
   ELEMENT_TYPE_DEAL,
   ///
   /// Элемент графического интерфейса направляющая ползунка скрола.
   ///
   ELEMENT_TYPE_TODDLER,
   ///
   /// Элемент графического интерфейса ползунок скрола.
   ///
   ELEMENT_TYPE_LABTODDLER,
   ///
   /// Элемент графического интерфейса тело таблицы.
   ///
   ELEMENT_TYPE_WORK_AREA,
   ///
   /// Элемент графического интерфейса заголовок таблицы.
   ///
   ELEMENT_TYPE_TABLE_HEADER,
   ///
   /// Элемент графического интерфейса заголовок таблицы позиций.
   ///
   ELEMENT_TYPE_TABLE_HEADER_POS,
   ///
   /// Элемент графического интерфейса итоговая строка.
   ///
   ELEMENT_TYPE_TABLE_SUMMARY,
   ///
   /// Элемент графического интерфейса "изображение"
   ///
   ELEMENT_TYPE_IMAGE,
   ///
   /// Идентификатор элемента графического интерфейса, поддерживающий скролл.
   ///
   ELEMENT_TYPE_SCROLLING,
   ///
   /// Идентификатор кнопки меню HT.
   ///
   ELEMENT_TYPE_START_MENU
};

///
/// Определяет тип таблицы позиций. Используется в качестве части комбинированного поля совместно с ENUM_TABLE_TYPE_ELEMENT.
///
enum ENUM_TABLE_TYPE
{
   ///
   /// Таблица по-умолчанию. Комбинация флагов не используется.
   ///
   TABLE_DEFAULT = 0,
   ///
   /// Таблица открытых позиций.
   ///
   TABLE_POSACTIVE = 1,
   ///
   /// Таблица исторических позиций.
   ///
   TABLE_POSHISTORY = 2,
};
//------------------------------------------------------------------------------------------------------------------------------------
// Перечислители и константы
///
/// Идентификатор окна графика на котором запущена панель.
///
#define MAIN_WINDOW 0
///
/// Идентификатор подокна графика, на котором запущена панель.
///
#define MAIN_SUBWINDOW 0

///
/// Контекст передваемых координат для функции Move().
///
enum ENUM_COOR_CONTEXT
{
   ///
   /// Текущие координаты задаются относительно левого верхнего угла окна терминала.
   ///
   COOR_GLOBAL,
   ///
   /// Текущие координаты задаются относительно левого верхнего угла родительского узла.
   ///
   COOR_LOCAL
};

///
/// Состояние кнопки
///
enum ENUM_BUTTON_STATE
{
   ///
   /// Кнопка выключена, или отжата.
   ///
   BUTTON_STATE_OFF,
   ///
   /// Кнопка включена, или нажата.
   ///
   BUTTON_STATE_ON
};
///
/// Идентификатор указывающий, что не нажата ни одна из кнопок мыши.
///
#define MOUSE_NOTHING_PUSH 0
///
/// Идентификатор указывающий, что нажата правая кнопка мыши.
///
#define MOUSE_LEFT_BUTTON_PUSH 1
///
/// Идентификатор указывающий, что нажата левая кнопка мыши.
///
#define MOUSE_RIGHT_BUTTON_PUSH 2
///
/// Идентификатор указывающий, что нажата средняя кнопка мыши.
///
#define MOUSE_CENTER_BUTTON_PUSH 16

//-------------------------------------------------------------------------------------------------------
//
#include "Math.mqh"
#include "Log.mqh"
#include "Resources\Resources.mqh"
#ifndef SETTINGS_MQH
   #include "Settings.mqh"
#endif
#include "Keys.mqh"
#include "Time.mqh"
#include "Log.mqh"
#include "API\MqlTransactions.mqh"
#include "Events.mqh"
#include "API\API.mqh"

#ifdef HEDGE_PANEL
   #include "Elements\Node.mqh"
   #include "Elements\Elements.mqh"
#endif

