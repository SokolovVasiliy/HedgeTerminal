#include "Param.mqh"
///
///
///
class Transaction
{
   Param* Parameters;
   int TransType();
   protected:
      Transaction(){;}
   private:
      int transType;
};