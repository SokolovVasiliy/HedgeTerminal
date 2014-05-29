#include "Math.mqh"
#include "Grid.mqh"
#include "Cripto.mqh"
#include "HashArray.mqh"
#include <Arrays\ArrayLong.mqh>

Grid grid;
void OnStart()
{
   uchar map[];
   uint tiks = GetTickCount();
   Cripto cripto(32);
   ulong v = 19;
   CArrayLong hashes;
   hashes.Resize(10000);
   hashes.Sort();
   //for(int i = 0; i < 10000; i++)
   //{
      ulong hash = cripto.Crypt(v);
      ulong value = cripto.Decrypt(hash);
      int index = hashes.Search(hash);
      //if(index != -1)
      //   printf("Найдено совпадение на i=" + i);
      //else
      //hashes.InsertSort(hash);
   //}
   /*int total = hashes.Total();
   for(int i = 1; i < hashes.Total(); i++)
   {
      if(hashes.At(i-1) == hashes.At(i))
         printf("Найдено совпадение" + (string)i);
   }*/
   //printf("Tiks: " + (string)(GetTickCount()-tiks));
   printf("Value: " + (string)v + "; Hash: " + (string)hash + "; Value: " + (string)value);
   /*for(int i = 0; i < 10000; i++)
   {
      //GenMap(1, map);
      cripto.f(1, 1);
   }*/
   
   //ulong hash = cripto.f(3, 1);
   //printf("Number: " + (string)hash);
   //string str = "";
   //for(int i = 0; i < ArraySize(map); i++)
   //   str += (string)map[i] + ",";
   //printf("Tiks: " + (string)(GetTickCount()-tiks) + "; countings: " + DoubleToString(CountWhile/10000.0, 2));
   //printf(str);
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