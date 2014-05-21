void OnStart()
{
   string values = "";
   for(int i = 0; i < 256; i++)
   {
      values += CharToString((char)i) + ", ";
   }
   ObjectCreate(0, "name", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "name", OBJPROP_YDISTANCE, 50);
   ObjectSetString(0, "name", OBJPROP_TEXT, values);
   printf(values);
}