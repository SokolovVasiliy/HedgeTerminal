
#include <Trade\Trade.mqh>

class HtTrade : public CTrade
{
   public:
      uint ResultRequestId(){return m_result.request_id;}
};
