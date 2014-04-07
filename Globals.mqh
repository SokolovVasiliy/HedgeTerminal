#define VERSION "HedgeTerminal 1.0"
class PanelSettings;
#ifdef HEDGE_PANEL
   ///
   /// ������ ������.
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
// ������-�������.
/// ����������� ������� ����� �������, ���������� �������� �����������.
class Event;
/// ������� "��������� ����������� �������� ��������".
class EventVisible;
/// ������� "������ ����������� �������� �������".
class EventResize;
/// ������� "��������� ����������� �������� ��������".
class EventMove;
/// ������� "������ ����� ���".
class EventNewTick;
/// ������� "����������� �������������".
class EventInit;
/// ������� "����������� ���������������".
class EventDeinit;
/// ������� "������� �� ��������� ���������, ��������� � ������� ����������� ��������".
class EventNodeCommand;
/// ������� "������� ����� �������".
class EventCreatePos;
/// ������� "���� ������ ��������� ��������".
class EventRefresh;
/// ������� "������ ������/������".
class EventButtonPush;
/// ������� "������� �������".
class EventDelPos;
/// ������ - ������� �������� �������.
class EventClosePos;
/// ������� "������� TreeViewBox �������/������".
class EventCollapseTree;
/// ������� "������ ������ �������".
class EventTimer;
/// ������� "��������� ����� ������".
class EventAddDeal;

//---------------------------------------------------------------------------------------------------------------------------
// ������ ���������� ���������.

/// ������� ����� ������ ����������� ��������.
class ProtoNode;
/// �����, ������������ �������� �� ������������ ����������.
class Line;
/// ����������� ������� �����, �������������� ���� � ����������� ������.
class TextNode;
/// ���������� ������� "�������".
class Table;
/// ���������� ������� "������".
class Button;
/// ���������� ������� "CheckBox".
class CheckBox;
/// ���������� ������� "TreeViewBox".
class TreeViewBox;
/// ����� "�������"
class Tab;
/// ����� "�������� �����".
class MainForm;
/// ����� "��������� ������".
class Scroll;
/// ����� �����������.
class Image;

//���� ���������� ���������
///
/// ��� �������� ������������ ����������.
///
enum ENUM_ELEMENT_TYPE
{
   ///
   /// ������� ������������ ���������� "�����".
   ///
   ELEMENT_TYPE_FORM,
   ///
   /// ������� ������������ ���������� "�������".
   ///
   ELEMENT_TYPE_TABLE,
   ///
   /// ������� ������������ ���������� "��������� �����".
   ///
   ELEMENT_TYPE_FORM_HEADER,
   ///
   /// ������� ������������ ���������� "������".
   ///
   ELEMENT_TYPE_BOTTON,
   ///
   /// ������� ������������ ���������� CheckBox.
   ///
   ELEMENT_TYPE_CHECK_BOX,
   ///
   /// ������� ������������ ���������� "�������".
   ///
   ELEMENT_TYPE_TAB,
   ///
   /// ������� ������������ ���������� "��������� ������� �������".
   ///
   ELEMENT_TYPE_HEAD_COLUMN,
   ///
   /// ������� ������������ ���������� "�������������� ���������".
   ///
   ELEMENT_TYPE_GCONTAINER,
   ///
   /// ������� ������������ ���������� "������������ ���������".
   ///
   ELEMENT_TYPE_VCONTAINER,
   ///
   /// ������� ������������ ���������� "������������� ���������".
   ///
   ELEMENT_TYPE_UCONTAINER,
   ///
   /// ������� ������������ ���������� "�������".
   ///
   ELEMENT_TYPE_SCROLL,
   ///
   /// ������� ������������ ���������� "��������� �����".
   ///
   ELEMENT_TYPE_LABEL,
   ///
   /// ������� ������������ ���������� "������ �������".
   ///
   ELEMENT_TYPE_CELL,
   ///
   /// ������� ������������ ���������� "�������������� �������".
   ///
   ELEMENT_TYPE_TREE_VIEW,
   ///
   /// ���������� ��������������� ������.
   ///
   ELEMENT_TYPE_TREE_BORDER,
   ///
   /// ��������� ������������� �������.
   ///
   ELEMENT_TYPE_POSITION,
   ///
   /// ��������� ������������� ������.
   ///
   ELEMENT_TYPE_DEAL,
   ///
   /// ������� ������������ ���������� ������������ �������� ������.
   ///
   ELEMENT_TYPE_TODDLER,
   ///
   /// ������� ������������ ���������� �������� ������.
   ///
   ELEMENT_TYPE_LABTODDLER,
   ///
   /// ������� ������������ ���������� ���� �������.
   ///
   ELEMENT_TYPE_WORK_AREA,
   ///
   /// ������� ������������ ���������� ��������� �������.
   ///
   ELEMENT_TYPE_TABLE_HEADER,
   ///
   /// ������� ������������ ���������� ��������� ������� �������.
   ///
   ELEMENT_TYPE_TABLE_HEADER_POS,
   ///
   /// ������� ������������ ���������� �������� ������.
   ///
   ELEMENT_TYPE_TABLE_SUMMARY,
   ///
   /// ������� ������������ ���������� "�����������"
   ///
   ELEMENT_TYPE_IMAGE,
   ///
   /// ������������� �������� ������������ ����������, �������������� ������.
   ///
   ELEMENT_TYPE_SCROLLING,
   ///
   /// ������������� ������ ���� HT.
   ///
   ELEMENT_TYPE_START_MENU
};

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
//------------------------------------------------------------------------------------------------------------------------------------
// ������������� � ���������
///
/// ������������� ���� ������� �� ������� �������� ������.
///
#define MAIN_WINDOW 0
///
/// ������������� ������� �������, �� ������� �������� ������.
///
#define MAIN_SUBWINDOW 0

///
/// �������� ����������� ��������� ��� ������� Move().
///
enum ENUM_COOR_CONTEXT
{
   ///
   /// ������� ���������� �������� ������������ ������ �������� ���� ���� ���������.
   ///
   COOR_GLOBAL,
   ///
   /// ������� ���������� �������� ������������ ������ �������� ���� ������������� ����.
   ///
   COOR_LOCAL
};

///
/// ��������� ������
///
enum ENUM_BUTTON_STATE
{
   ///
   /// ������ ���������, ��� ������.
   ///
   BUTTON_STATE_OFF,
   ///
   /// ������ ��������, ��� ������.
   ///
   BUTTON_STATE_ON
};
///
/// ������������� �����������, ��� �� ������ �� ���� �� ������ ����.
///
#define MOUSE_NOTHING_PUSH 0
///
/// ������������� �����������, ��� ������ ������ ������ ����.
///
#define MOUSE_LEFT_BUTTON_PUSH 1
///
/// ������������� �����������, ��� ������ ����� ������ ����.
///
#define MOUSE_RIGHT_BUTTON_PUSH 2
///
/// ������������� �����������, ��� ������ ������� ������ ����.
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

