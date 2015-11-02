
///
/// Запоминает, устанавливает и возвращает свойства графика.
///
class Environment
{
private:
   bool show_data_scale;
   bool show_price_scale;
   bool shift;
   bool object_descr;
   bool drag_trade_levels;
   color color_bg;
   color color_fr;
   color color_font;
public:
   Environment();
   void RememberCaption();
   void RestoreCaption();
   void SetNewCaption();
};

Environment::Environment()
{
   RememberCaption();
}

Environment::RememberCaption(void)
{
   drag_trade_levels = (bool)ChartGetInteger(ChartID(), CHART_DRAG_TRADE_LEVELS);
   show_price_scale = (bool)ChartGetInteger(ChartID(), CHART_SHOW_PRICE_SCALE);
   show_data_scale = (bool)ChartGetInteger(ChartID(), CHART_SHOW_DATE_SCALE);
   object_descr = (bool)ChartGetInteger(ChartID(), CHART_SHOW_OBJECT_DESCR);
   color_bg = (color)ChartGetInteger(ChartID(), CHART_COLOR_BACKGROUND);
   color_fr = (color)ChartGetInteger(ChartID(), CHART_COLOR_FOREGROUND);
   shift = (bool)ChartGetInteger(ChartID(), CHART_SHIFT);
}

Environment::RestoreCaption(void)
{
   ChartSetInteger(ChartID(), CHART_DRAG_TRADE_LEVELS, drag_trade_levels);
   ChartSetInteger(ChartID(), CHART_SHOW_PRICE_SCALE, show_price_scale);
   ChartSetInteger(ChartID(), CHART_SHOW_DATE_SCALE, show_data_scale);
   ChartSetInteger(ChartID(), CHART_SHOW_OBJECT_DESCR, object_descr);
   ChartSetInteger(ChartID(), CHART_COLOR_BACKGROUND, color_bg);
   ChartSetInteger(ChartID(), CHART_COLOR_FOREGROUND, color_fr);
   ChartSetInteger(ChartID(), CHART_SHIFT, shift);
}

Environment::SetNewCaption(void)
{
   ChartSetInteger(ChartID(), CHART_DRAG_TRADE_LEVELS, false);
   ChartSetInteger(ChartID(), CHART_SHOW_PRICE_SCALE, false);
   ChartSetInteger(ChartID(), CHART_SHOW_DATE_SCALE, false);
   ChartSetInteger(ChartID(), CHART_SHOW_OBJECT_DESCR, false);
   ChartSetInteger(ChartID(), CHART_COLOR_BACKGROUND, clrWhite);
   ChartSetInteger(ChartID(), CHART_COLOR_FOREGROUND, clrWhiteSmoke);
   ChartSetInteger(ChartID(), CHART_SHIFT, false);
}
