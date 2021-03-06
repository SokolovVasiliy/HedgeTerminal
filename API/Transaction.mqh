//#include <Arrays\ArrayObj.mqh>
//#include <Arrays\ArrayLong.mqh>
#include <Trade\Trade.mqh>
#include "..\Time.mqh"
#include "..\Prototypes.mqh"

class Position;
class Deal;
class Order;
#ifdef HEDGE_PANEL
class PosLine;
#endif

///
/// 砎鳿縺膱, 瀁 膰襜蹖?斁緪?朢譔 闅勷貗麃鍒鳧 厴黓鍧 闉麧豂?
///
enum ENUM_SORT_TRANSACTION
{
   ///
   /// 栦貗麃鍒罻 瀁 憵蜼灚齕鍎?膼懤賾.
   ///
   SORT_MAGIC,
   ///
   /// 栦貗麃鍒罻 瀁 鵯鴀鳪鍎?鳼樇蠂鐓罻襜賾 襝鳧諘艖鳷, 瀁鋹欑樦鍎?闅 鏵臌灕?GetId().
   ///
   SORT_ORDER_ID,
   ///
   /// 栦貗麃鍒罻 瀁 黓羻?╝檍 蠂耪覷 瀁賥灕?鳹?蠂膱覷 諘膴僠╝蜦 襝樥魡.
   ///
   SORT_EXIT_ORDER_ID,
   ///
   /// 栦貗麃鍒罻 瀁 硾樦樇?勷瞂蹢樇? 襝樥魡, 禖嚦飶錼膻?闉麧譇, 魛蠂睯豂瘔膻 瀁賥灕?
   ///
   SORT_TIME,
   ///
   /// 
   ///
   SORT_EXIT_TIME
};

//#include "..\Elements\TablePositions.mqh"
///
/// 祏?襝鳧諘艖鳷.
///
enum ENUM_TRANSACTION_TYPE
{
   ///
   /// 秮鳧諘艖? 碲殣? 瀁賥灕樥.
   ///
   TRANS_POSITION,
   ///
   /// 秮鳧諘艖? 碲殣? 闉麧豂?
   ///
   TRANS_ORDER,
   ///
   /// 秮鳧諘艖? 碲殣? 鼥槶膰?
   ///
   TRANS_DEAL,
   ///
   /// 挓錼裱樇縺 瞂貘? 鵯魤歑黟錪膼?襝鳧諘艖鳷 勷麧謷僓?
   /// 鵯鴀鳪 鳼樇蠂鐓罻襜?
   ///
   TRANS_ABSTR
};

///
/// 侲瀔飶錼膻??膰襜豂?勷瞂蹢樇?襝鳧諘艖?.
///
/*enum ENUM_DIRECTION_TYPE
{
   DIRECTION_UNDEFINED,
   DIRECTION_LONG,
   DIRECTION_SHORT
};*/

///
/// 砎槼闃蠉碲殣 颬嚦譇膷薃?襝鳧諘艖噮: 鼥槶膧, 闉麧? 錒搿 錌摷?僽鵽嚲 闀歑僪噮 縺 壝殣?
///
class Transaction : public CObject
{
   public:
      ///
      /// 鎬誺譇╠殣 蠂?襝鳧諘艖鳷.
      ///
      ENUM_TRANSACTION_TYPE TransactionType(){return transType;}
      
      ///
      /// 鎬誺譇╠殣 縺誺鳧鳺 鼨懧鎀? 瀁 膰襜豂檍 朢錟 勷瞂蹢樇?鼥槶罻.
      ///
      virtual string Symbol()
      {
         return symbol;
      }
      ///
      /// 鎬誺譇╠殣 憵蜼灚齕鴇 膼懤?厴歑蠉, 膰襜豂檍 瀔鴈馯錼緡?魡臇? 襝鳧諘艖?.
      ///
      virtual ulong Magic() const
      {
         return 0;
      }
      ///
      /// 鎬誺譇╠殣 蠈膧╫?欈薃 鴈嚦賾懤艜? 瀁 膰襜豂檍 勷瞂蹢樇?襝鳧諘艖?.
      ///
      virtual double CurrentPrice()
      {
         double price = 0.0;
         //槫?麧鋋 ?瀁膧氋鳭?
         if(Direction() == DIRECTION_LONG)
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_BID);
         else if(Direction() == DIRECTION_SHORT)
            price = SymbolInfoDouble(this.Symbol(), SYMBOL_ASK);
         else
            price = 0.0;
         return NormalizePrice(price);
      }
      ///
      /// 侹謽鳪鳿鵴?欈薃 ?勷闅瞂襙蠋鳷 ?膰錒灚嚦碭?賝魛鍒 蠈膧╝蜦 鴈嚦賾懤艜?
      ///
      double NormalizePrice(double price)
      {
         if(this.Symbol() == NULL || this.Symbol() == "")
            return price;
         int digits = (int)SymbolInfoInteger(this.Symbol(), SYMBOL_DIGITS);
         return NormalizeDouble(price, digits);
      }
      ///
      /// 鎬誺譇╠殣 邍膷儚殥膱?禖瀁錍樇蕻?鍕?襝鳧諘艖鳷.
      ///
      virtual double VolumeExecuted()
      {
         return 0.0;
      }
      ///
      /// 鎬誺譇╠殣 瀔隮鼏 ?瀀臌蠉?鴈嚦賾懤艜?
      ///
      virtual double ProfitInPips()
      {
         double cp = EntryExecutedPrice();
         double delta = CurrentPrice() - EntryExecutedPrice();
         if(Direction() == DIRECTION_SHORT)
            delta *= -1.0;
         return delta;
      }
      ///
      /// 鎬誺譇╠殣 瀔隮鼏 ?瀀臌蠉?鴈嚦賾懤艜?
      ///
      virtual double ProfitInCurrency()
      {
         int dbg = 5;
         if(GetId() == 6389544)
            dbg = 6;
         double pips = ProfitInPips();
         //栺鍞斁嚦?鍱膼蜦 蠂罻 ?瘔錌蠈 麧瀁賥蠉.
         double tickValueCurrency = 0.0;
         double point = SymbolInfoDouble(this.Symbol(), SYMBOL_POINT);
         if(point == 0.0)return 0.0;
         pips /= point;
         symbolInfo.Name(this.Symbol());
         if(pips < 0.0)
            tickValueCurrency = symbolInfo.TickValueLoss();
         else
            tickValueCurrency = symbolInfo.TickValueProfit();
         //if(this.Symbol() == "USDCAD")
         //   printf(tickValueCurrency);
         double currency = tickValueCurrency * pips * VolumeExecuted() + Commission();
         return currency;
      }
      virtual ENUM_DIRECTION_TYPE Direction()
      {
         return DIRECTION_UNDEFINED;
      }
      ///
      /// 扻擯嚭? 諘 勷瞂蹢樇鳺 襝鳧諘艖鳷.
      ///
      virtual double Commission()
      {
         return 0.0;
      }
      ///
      /// 鎬誺譇╠殣 瀔隮鼏 ?睯麧 蠈膲襜碭蜦 瀔槼嚦飶錼膻.
      ///
      string ProfitAsString()
      {
         double d = ProfitInPips();
         int digits = (int)SymbolInfoInteger(this.Symbol(), SYMBOL_DIGITS);
         double point = SymbolInfoDouble(this.Symbol(), SYMBOL_POINT);
         string points = point == 0 ? "0p." : DoubleToString(d/point, 0) + "p.";
         return points;
      }
      ///
      /// 鎬誺譇╠殣 欈薃 鴈嚦賾懤艜??睯麧 嚦豂膱.
      ///
      string PriceToString(double price)
      {
         int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
         string sprice = DoubleToString(price, digits);
         return sprice;
      }
      string VolumeToString(double vol)
      {
         double step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
         double mylog = MathLog10(step);
         string svol = mylog < 0 ? DoubleToString(vol,(int)(mylog*(-1.0))) : DoubleToString(vol, 0);
         return svol;
      }
      ///
      /// 鎬誺譇╠殣 膰錒灚嚦碭 賝魛鍒 瀁儴?諘?襜??欈翴 鴈嚦賾懤艜? 瀁 膰襜豂檍 朢錟 勷瞂蹢樇?襝鳧諘艖?.
      ///
      int InstrumentDigits()
      {
         return (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
      }
      ///
      /// 盷謥闀謥麧?樦 嚫飶翴膻?
      ///
      virtual int Compare(const CObject *node, const int mode=0)const
      {
         const Transaction* myTrans = node;
         ulong nodeValue = myTrans.GetCompareValueInt((ENUM_SORT_TRANSACTION)mode);
         ulong myValue = GetCompareValueInt((ENUM_SORT_TRANSACTION)mode);
         if(myValue > nodeValue)return GREATE;
         if(myValue < nodeValue)return LESS;
         return EQUAL;
      }
      
      virtual ulong GetCompareValueInt(ENUM_SORT_TRANSACTION sortType)const
      {
         switch(sortType)
         {
            case SORT_MAGIC:
               return Magic();
            case SORT_ORDER_ID:
            default:
               return currId;
         }
         return 0;
      }
      ///
      /// 砐鋹欑殣 鵯鴀鳪 鳼樇蠂鐓罻襜?襝鳧諘艖鳷.
      ///
      ulong GetId()const{return currId;}
      
      ///
      /// 鎬誺譇╠殣 蠂?襝鳧諘艖鳷 ?睯麧 嚦豂膱.
      ///
      virtual string TypeAsString()
      {
         return "transaction";
      }
      
   protected:
      ///
      /// 鎬誺譇╠殣 欈薃 碬鍱?襝縺諘艖鳷 縺 蹖膼?
      ///
      virtual double EntryExecutedPrice(){return 0.0;}
      ///
      /// 鎬誺譇╠殣 蠂?襝鳧諘艖鳷.
      ///
      Transaction(ENUM_TRANSACTION_TYPE trType){transType = trType;}
      
      ///
      /// 迶蠉縺碲魤馲?鵯鴀鳪 鳼樇蠂鐓罻襜?襝鳧諘艖鳷.
      ///
      void SetId(ulong id){currId = id;}
      
      ///
      /// 鎬誺譇╠殣 硾樦 嚫颬僗鳧? 闉麧譇/勷瞂蹢樇? 鼥槶膱.
      ///
      virtual long TimeExecuted()
      {
         CTime* HtTime = NULL;
         SelectHistoryTransaction();
         if(transType == TRANS_POSITION)
         {
            long msc = HistoryOrderGetInteger(currId, ORDER_TIME_DONE_MSC);
            return msc;
            //HtTime = new HtTime(msc);
            //return HtTime;
         }
         if(transType == TRANS_DEAL)
         {
            long msc = HistoryDealGetInteger(currId, DEAL_TIME_MSC);
            return msc;
            //HtTime = new HtTime(msc);
            //return HtTime;
         }
         return 0;
      }
      ///
      /// 雞摜譇殣 蠈膧╫?襝鳧諘艖噮 儇 魡錪翴澮樥 譇搿譖 ?翴?
      ///
      void SelectHistoryTransaction()
      {
         LoadHistory();
         if(transType == TRANS_DEAL)
            HistoryDealSelect(currId);
         if(transType == TRANS_POSITION)
            HistoryOrderSelect(currId);
      }
      ///
      /// 雞摜譇殣 蠈膧╫?襝鳧諘艖噮 儇 魡錪翴澮樥 譇搿譖 ?翴?
      ///
      void SelectPendingTransaction()
      {
         if(transType == TRANS_ORDER ||
            transType == TRANS_POSITION)
            bool t = OrderSelect(currId);   
      }
      
      /*犧 鵨膰謥? 譇嚭灚襜? 諘瀁擯縺殣 譇翴?譇嚭玁蠉臇 欈蕻, 膰襜蹖??魡錪翴澮樦 摷劌?翴鳿懤臇?*/
      ///
      /// 栮槼? 醲膷魤縺 欈縺 瀁 膰襜豂?朢錟 勷瞂蹢樇?鼥槶罻/襝鳧諘艖?.
      ///
      double entryPriceExecuted;
      ///
      /// 蠂縺, 殥錒 欈縺 勷瞂蹢樇? 襝鳧諘艖鳷 朢錟 譇嚭玁蠉縺.
      ///
      bool isEntryPriceExecuted;
      ///
      /// 桎懧鎀, 瀁 膰襜豂檍 勷瞂蹢樇?襝馵魛灕 (諘瀁擯縺殣? 儇 瀔鍞誺鍱鼏槶闃蠂).
      ///
      string symbol;
      ///
      /// 蠂縺, 殥錒 縺誺鳧鳺 鴈嚦賾懤艜?朢鋋 瀁鋹灚膼 譇翴??諘瀁擨樇?
      ///
      bool isSymbol;
      ///
      /// 蜸鵵馲?黓襜謶?闉麧豂??鼥槶鍧, 殥錒 鍙?翴 諘蜸鵵樇?
      ///
      void LoadHistory(void)
      {
         if(HistoryDealsTotal() < 2)
            HistorySelect(D'1970.01.01', TimeCurrent()+100);
      }
      //ENUM_DIRECTION_TYPE direction;
   private:
      
      ///
      /// 祏?襝鳧諘艖鳷.
      ///
      ENUM_TRANSACTION_TYPE transType;
      ///
      /// 砱膧╕?鳼樇蠂鐓罻襜?襝鳧諘艖鳷, ?膰襜蹖?譇搿蠉 鏵臌灕?
      ///
      ulong currId;
      ///
      /// 鎚瀁斁蜬蠈錪蕻?鴈嚦賾懤艜.  
      ///
      CSymbolInfo symbolInfo;
};

///
/// 鎔貗鶆錪縺 襝鳧諘艖? 儇 朢嚦豂蜦 瀁黓罻.
///
class TransId : public Transaction
{
   public:
      TransId(ulong id) : Transaction(TRANS_ABSTR)
      {
         SetId(id);
      }
};

#include "Deal.mqh"
#include "Order.mqh"
#include "Position.mqh"



