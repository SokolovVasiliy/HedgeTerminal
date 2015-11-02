
#include <Arrays\ArrayObj.mqh>
#include "..\Time.mqh"
///
/// Swap position.
///
class SwapPosition : public CObject
{
   public:
      ulong PositionId(void){return posId;}
      double Swap(void){return swap;}
      void Swap(double value){swap = value;}
      virtual int Compare(const CObject *node, const int mode=0)const;
      string Symbol(){return symbol;}
      void Symbol(string smb){symbol = smb;}
      void FirstSwapTime(ulong tiks){firstSwapTime.Tiks(tiks);}
      ulong FirstSwapTime(void){return firstSwapTime.Tiks();}
      void LastSwapTime(ulong tiks){lastSwapTime.Tiks(tiks);}
      ulong LastSwapTime(void){return lastSwapTime.Tiks();}
      double Volume(void){return volume;}
      void Volume(double value){volume = value;}
   private:
      ///
      /// Уникальный идентификатор позиции, которой принадлежит своп.
      ///
      ulong posId;
      ///
      /// Значение свопа.
      ///
      double swap;
      ///
      /// Символ, по которому начисляется своп.
      ///
      string symbol;
      ///
      /// Время когда на позицию начислился своп впервые.
      ///
      CTime firstSwapTime;
      ///
      /// Время когда на позицию начислился своп в последний раз.
      ///
      CTime lastSwapTime;
      ///
      /// Объем совокупной позиции, на которую был произведено начисление свопа.
      ///
      double volume;
};

///
/// Сравнивает текущий SwapPosition с переданным по PositionId()
///
int SwapPosition::Compare(const CObject *node, const int mode=0) const
{
     SwapPosition* sp = node;
   if(sp.PositionId() == posId)return 0;
   if(sp.PositionId() < posId)return 1;
   else return -1;
}
