//+------------------------------------------------------------------+
//|                                           LoadingProgressBar.mqh |
//|                                 Copyright 2014, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+


class ProgressBar
{
private:
   ///
   /// Ширина прогресс бара.
   ///
   long m_xsize;
   ///
   /// Высота прогресс бара.
   ///
   long m_ysize;
   ///
   /// Имя текста.
   ///
   string m_name_text;
   ///
   /// Истина, если прогресс бар отображен.
   ///
   bool m_show;
public:
   ProgressBar();
   void ShowProgressBar();
   void HideProgressBar();
   void SetPercentProgress(int progress);
   void ShowPanelBuilding();
};

ProgressBar::ProgressBar(void)
{
   m_name_text = "ht_text23827";
   m_xsize = 100;
   m_ysize = 50;
   m_show = false;
}

///
/// Отображает панель прогресс бара.
///
void ProgressBar::ShowProgressBar(void)
{
   long X = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   long Y = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   double median_x = MathRound(X/2.0);
   double median_y = MathRound(Y/2.0);
   long x_snap = (long)MathRound(median_x - (m_xsize/2.0));
   long y_snap = (long)MathRound(median_y - (m_ysize/2.0));
   string m_name = m_name_text;
   if(ObjectFind(0, m_name) < 0)
      ObjectCreate(0, m_name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, m_name, OBJPROP_XDISTANCE, x_snap);
   ObjectSetInteger(0, m_name, OBJPROP_YDISTANCE, y_snap);
   ObjectSetInteger(0, m_name, OBJPROP_XSIZE, m_xsize);
   ObjectSetInteger(0, m_name, OBJPROP_YSIZE, m_ysize);
   ObjectSetInteger(0, m_name, OBJPROP_BORDER_COLOR, clrBlack);
   ObjectSetInteger(0, m_name, OBJPROP_BGCOLOR, clrWhiteSmoke);
   ObjectSetInteger(0, m_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetString(0, m_name, OBJPROP_TEXT, "loading...");
   ChartRedraw();
}

void ProgressBar::HideProgressBar(void)
{
   if(ObjectFind(0, m_name_text) >= 0)
      ObjectDelete(0, m_name_text);
   ChartRedraw();
}

void ProgressBar::SetPercentProgress(int progress)
{
   if(!m_show)
      ShowProgressBar();
   string value = NULL;
   if(progress <= 99)
      value = "loading " + (string)progress + "%";
   ObjectSetString(0, m_name_text, OBJPROP_TEXT, value);
   ChartRedraw();
}

void ProgressBar::ShowPanelBuilding(void)
{
   if(!m_show)
      ShowProgressBar();
   ObjectSetString(0, m_name_text, OBJPROP_TEXT, "panel building...");
   ChartRedraw();
}