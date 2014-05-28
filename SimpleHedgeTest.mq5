#include "Math.mqh"
#include "Grid.mqh"

Grid grid;
void OnStart()
{
   /*ulong value = 0x80FFFFFFFFFFFFFF;
   ulong cvalue = 0;
   ulong hash = grid.GenHash(value, 0);
   ulong chash = grid.GenValue(hash, 0);
   PrintBit(value);
   PrintBit(hash);
   PrintBit(chash);*/
   //printf((string)value);
   //printf((string)cvalue);
   /*Random rnd;
   ulong max = 0;
   ulong min = ULONG_MAX;
   for(int i = 0; i < 1000; i++)
   {
      ulong value = rnd.Rand(5, 64);
      if(value > max)max = value;
      if(value < min)min = value;
   }
   printf(max + " - " + min);*/
   Grid grid;
   //ulong hash = grid.GenHash(1010152769, "AUDCHF");
   HistorySelect(0, TimeCurrent());
   int total = HistoryOrdersTotal();
   for(int i = 0; i < total; i++)
   {
      ulong ticket = HistoryOrderGetTicket(i);
      ulong magic = HistoryOrderGetInteger(ticket, ORDER_MAGIC);
      string symbol = HistoryOrderGetString(ticket, ORDER_SYMBOL);
      //ulong hash = grid.GenHash(ticket, symbol);
      if(magic < LONG_MAX)continue;
      
      printf((string)magic + " - " + symbol + " (" + (string)ticket + ")   " + (string)hash);
   }
}
///
/// Печатает битовое представление числа.
///
void PrintBit(ulong value)
{
   uchar map[64];
   ArrayInitialize(map, 0);
   for(int i = 0; i < 64; i++)
   {
      bool bit = grid.GetBit(value, (uchar)i);
      if(bit)
         map[i] = 1;
   }
   string str = "";
   string t = "";
   for(int i = ArraySize(map)-1; i >= 0; i--)
   {
      if(i%4 == 0)t = " ";
      else t = "";
      str += (string)map[i] + t;
   }
   printf(str);
}