#include "Math.mqh"
#include "Grid.mqh"

Grid grid;
void OnStart()
{
   ulong value = 0x80FFFFFFFFFFFFFF;
   ulong cvalue = 0;
   ulong hash = grid.GenHash(value, 0);
   ulong chash = grid.GenValue(hash, 0);
   PrintBit(value);
   PrintBit(hash);
   PrintBit(chash);
   //printf((string)value);
   //printf((string)cvalue);
   
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