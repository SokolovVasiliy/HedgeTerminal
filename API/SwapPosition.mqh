
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
      /// ���������� ������������� �������, ������� ����������� ����.
      ///
      ulong posId;
      ///
      /// �������� �����.
      ///
      double swap;
      ///
      /// ������, �� �������� ����������� ����.
      ///
      string symbol;
      ///
      /// ����� ����� �� ������� ���������� ���� �������.
      ///
      CTime firstSwapTime;
      ///
      /// ����� ����� �� ������� ���������� ���� � ��������� ���.
      ///
      CTime lastSwapTime;
      ///
      /// ����� ���������� �������, �� ������� ��� ����������� ���������� �����.
      ///
      double volume;
};

///
/// ���������� ������� SwapPosition � ���������� �� PositionId()
///
int SwapPosition::Compare(const CObject *node, const int mode=0) const
{
     SwapPosition* sp = node;
   if(sp.PositionId() == posId)return 0;
   if(sp.PositionId() < posId)return 1;
   else return -1;
}
