#ifdef RELEASE
   #include "Aliases.mqh"
#endif


class PanelSettings;
#include "Resources\Resources.mqh"
#ifdef HEDGE_PANEL
   ///
   /// Êíîïêà ñòàðòà.
   ///
   //#define IMG_MENU "::button_img.bmp"
   //#resource "button_img.bmp"
   //#resource "Resources\\Fonts\\Arial Rounded MT Bold Bold.ttf"
   //#resource "Resources\\Fonts\\test.fon"
#endif
#include "Prototypes.mqh"


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
// Êëàññû-ñîáûòèÿ.
/// Àáñòðàêòíûé áàçîâûé êëàññ ñîáûòèÿ, ñîäåðæàùèé îñíîâíûå îïðåäåëåíèÿ.
class Event;
/// Ñîáûòèå "Âèäèìîñòü âèçóàëüíîãî ýëåìåíòà èçìåíåíà".
class EventVisible;
/// Ñîáûòèå "Ðàçìåð âèçóàëüíîãî ýëåìåíòà èçìåíåí".
class EventResize;
/// Ñîáûòèå "Ïîëîæåíèå âèçóàëüíîãî ýëåìåíòà èçìåíåíî".
class EventMove;
/// Ñîáûòèå "Ïðèøåë íîâûé òèê".
class EventNewTick;
/// Ñîáûòèå "Âûïîëíÿåòñÿ èíèöèàëèçàöèÿ".
class EventInit;
/// Ñîáûòèå "Âûïîëíÿåòñÿ äåèíèöèàëèçàöèÿ".
class EventDeinit;
/// Ñîáûòèå "Êîìàíäà íà èçìåíåíèå âèäèìîñòè, ïîëîæåíèÿ è ðàçìåðà âèçóàëüíîãî ýëåìåíòà".
class EventNodeCommand;
/// Ñîáûòèå "Ñîçäàíà íîâàÿ ïîçèöèÿ".
class EventCreatePos;
/// Ñîáûòèå "Îêíî ïàíåëè òðåáóåòñÿ îáíîâèòü".
class EventRefresh;
/// Ñîáûòèå "Êíîïêà íàæàòà/îòæàòà".
class EventButtonPush;
/// Ñîáûòèå "Ïîçèöèÿ óäàëåíà".
class EventDelPos;
/// Ïðèêàç - çàêðûòü àêòèâíóþ ïîçèöèþ.
class EventClosePos;
/// Ñîáûòèå "Ýëåìåíò TreeViewBox ðàñêðûò/çàêðûò".
class EventCollapseTree;
/// Ñîáûòèå "Ïðèõîä íîâîãî âðåìåíè".
class EventTimer;
/// Ñîáûòèå "Ñîâåðøåíà íîâàÿ ñäåëêà".
class EventAddDeal;

//---------------------------------------------------------------------------------------------------------------------------
// Êëàññû âèçóàëüíûõ ýëåìåíòîâ.

/// Áàçîâûé êëàññ ëþáîãî âèçóàëüíîãî ýëåìåíòà.
class ProtoNode;
/// Êëàññ, ãðóïïèðóþùèé ýëåìåíòû ïî îïðåäåëåííûì àëãîðèòìàì.
class Line;
/// Àáñòðàêòíûé áàçîâûé êëàññ, ïîääåðæèâàþùèé ââîä è îòîáðàæåíèå òåêñòà.
class TextNode;
/// Âèçóàëüíûé ýëåìåíò "Òàáëèöà".
class Table;
/// Âèçóàëüíûé ýëåìåíò "Êíîïêà".
class Button;
/// Âèçóàëüíûé ýëåìåíò "CheckBox".
class CheckBox;
/// Âèçóàëüíûé ýëåìåíò "TreeViewBox".
class TreeViewBox;
/// Êëàññ "Âêëàäêè"
class Tab;
/// Êëàññ "Îñíîâíàÿ ôîðìà".
class MainForm;
/// Êëàññ "Ïðîêðóòêà ñïèñêà".
class Scroll;
/// êëàññ èçîáðàæåíèÿ.
class Image;

//Òèïû âèçóàëüíûõ ýëåìåíòîâ
///
/// Òèï ýëåìåíòà ãðàôè÷åñêîãî èíòåðôåéñà.
///
enum ENUM_ELEMENT_TYPE
{
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Ôîðìà".
   ///
   ELEMENT_TYPE_FORM,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Òàáëèöà".
   ///
   ELEMENT_TYPE_TABLE,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Çàãîëîâîê ôîðìû".
   ///
   ELEMENT_TYPE_FORM_HEADER,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Êíîïêà".
   ///
   ELEMENT_TYPE_BOTTON,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà CheckBox.
   ///
   ELEMENT_TYPE_CHECK_BOX,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Âêëàäêà".
   ///
   ELEMENT_TYPE_TAB,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Çàãîëîâîê êîëîíêè òàáëèöû".
   ///
   ELEMENT_TYPE_HEAD_COLUMN,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Ãîðèçîíòàëüíûé êîíòåéíåð".
   ///
   ELEMENT_TYPE_GCONTAINER,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Âåðòèêàëüíûé êîíòåéíåð".
   ///
   ELEMENT_TYPE_VCONTAINER,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Óíèâåðñàëüíûé êîíòåéíåð".
   ///
   ELEMENT_TYPE_UCONTAINER,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Ïîçóíîê".
   ///
   ELEMENT_TYPE_SCROLL,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Òåêñòîâàÿ ìåòêà".
   ///
   ELEMENT_TYPE_LABEL,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "ß÷åéêà òàáëèöû".
   ///
   ELEMENT_TYPE_CELL,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "Ðàñêðûâàþùàÿñÿ òàáëèöà".
   ///
   ELEMENT_TYPE_TREE_VIEW,
   ///
   /// Îôîðìëåíèå ðàñêðûâàþùåãîñÿ ñïèñêà.
   ///
   ELEMENT_TYPE_TREE_BORDER,
   ///
   /// Ñòðîêîâîå ïðåäñòàâëåíèå ïîçèöèè.
   ///
   ELEMENT_TYPE_POSITION,
   ///
   /// Ñòðîêîâîå ïðåäñòàâëåíèå ñäåëêè.
   ///
   ELEMENT_TYPE_DEAL,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà íàïðàâëÿþùàÿ ïîëçóíêà ñêðîëà.
   ///
   ELEMENT_TYPE_TODDLER,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà ïîëçóíîê ñêðîëà.
   ///
   ELEMENT_TYPE_LABTODDLER,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà òåëî òàáëèöû.
   ///
   ELEMENT_TYPE_WORK_AREA,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà çàãîëîâîê òàáëèöû.
   ///
   ELEMENT_TYPE_TABLE_HEADER,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà çàãîëîâîê òàáëèöû ïîçèöèé.
   ///
   ELEMENT_TYPE_TABLE_HEADER_POS,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà èòîãîâàÿ ñòðîêà.
   ///
   ELEMENT_TYPE_TABLE_SUMMARY,
   ///
   /// Ýëåìåíò ãðàôè÷åñêîãî èíòåðôåéñà "èçîáðàæåíèå"
   ///
   ELEMENT_TYPE_IMAGE,
   ///
   /// Èäåíòèôèêàòîð ýëåìåíòà ãðàôè÷åñêîãî èíòåðôåéñà, ïîääåðæèâàþùèé ñêðîëë.
   ///
   ELEMENT_TYPE_SCROLLING,
   ///
   /// Èäåíòèôèêàòîð êíîïêè ìåíþ HT.
   ///
   ELEMENT_TYPE_START_MENU
};

///
/// Îïðåäåëÿåò òèï òàáëèöû ïîçèöèé. Èñïîëüçóåòñÿ â êà÷åñòâå ÷àñòè êîìáèíèðîâàííîãî ïîëÿ ñîâìåñòíî ñ ENUM_TABLE_TYPE_ELEMENT.
///
enum ENUM_TABLE_TYPE
{
   ///
   /// Òàáëèöà ïî-óìîë÷àíèþ. Êîìáèíàöèÿ ôëàãîâ íå èñïîëüçóåòñÿ.
   ///
   TABLE_DEFAULT = 0,
   ///
   /// Òàáëèöà îòêðûòûõ ïîçèöèé.
   ///
   TABLE_POSACTIVE = 1,
   ///
   /// Òàáëèöà èñòîðè÷åñêèõ ïîçèöèé.
   ///
   TABLE_POSHISTORY = 2,
};
//------------------------------------------------------------------------------------------------------------------------------------
// Ïåðå÷èñëèòåëè è êîíñòàíòû
///
/// Èäåíòèôèêàòîð îêíà ãðàôèêà íà êîòîðîì çàïóùåíà ïàíåëü.
///
#define MAIN_WINDOW 0
///
/// Èäåíòèôèêàòîð ïîäîêíà ãðàôèêà, íà êîòîðîì çàïóùåíà ïàíåëü.
///
#define MAIN_SUBWINDOW 0

///
/// Êîíòåêñò ïåðåäâàåìûõ êîîðäèíàò äëÿ ôóíêöèè Move().
///
enum ENUM_COOR_CONTEXT
{
   ///
   /// Òåêóùèå êîîðäèíàòû çàäàþòñÿ îòíîñèòåëüíî ëåâîãî âåðõíåãî óãëà îêíà òåðìèíàëà.
   ///
   COOR_GLOBAL,
   ///
   /// Òåêóùèå êîîðäèíàòû çàäàþòñÿ îòíîñèòåëüíî ëåâîãî âåðõíåãî óãëà ðîäèòåëüñêîãî óçëà.
   ///
   COOR_LOCAL
};

///
/// Ñîñòîÿíèå êíîïêè
///
enum ENUM_BUTTON_STATE
{
   ///
   /// Êíîïêà âûêëþ÷åíà, èëè îòæàòà.
   ///
   BUTTON_STATE_OFF,
   ///
   /// Êíîïêà âêëþ÷åíà, èëè íàæàòà.
   ///
   BUTTON_STATE_ON
};
///
/// Èäåíòèôèêàòîð óêàçûâàþùèé, ÷òî íå íàæàòà íè îäíà èç êíîïîê ìûøè.
///
#define MOUSE_NOTHING_PUSH 0
///
/// Èäåíòèôèêàòîð óêàçûâàþùèé, ÷òî íàæàòà ïðàâàÿ êíîïêà ìûøè.
///
#define MOUSE_LEFT_BUTTON_PUSH 1
///
/// Èäåíòèôèêàòîð óêàçûâàþùèé, ÷òî íàæàòà ëåâàÿ êíîïêà ìûøè.
///
#define MOUSE_RIGHT_BUTTON_PUSH 2
///
/// Èäåíòèôèêàòîð óêàçûâàþùèé, ÷òî íàæàòà ñðåäíÿÿ êíîïêà ìûøè.
///
#define MOUSE_CENTER_BUTTON_PUSH 16

//-------------------------------------------------------------------------------------------------------
//
#include "Math\Math.mqh"
#include "Log.mqh"
#include "Settings.mqh"
#include "Keys.mqh"
#include "Time.mqh"
#include "Log.mqh"
#include "API\MqlTransactions.mqh"
#include "Events.mqh"
#include "API\API.mqh"
#include "API\Report.mqh"
#ifdef HEDGE_PANEL
   #include "Elements\Node.mqh"
   #include "Elements\Elements.mqh"
#endif

CResources Resources;
PanelSettings Settings;
//class CEventExchange;
CEventExchange EventExchange;
Crypto crypto;
Report report;
