#include "events.mqh"
#include "hpapi.mqh"
#include "gelements.mqh"
///
///  ласс-адаптер позвол€ющий обмениватьс€ событи€ми двум независимым классам.
///
class EventExchange
{
   public:
      static void PushEvent(Event* myEvent)
      {
         if(api != NULL)
            api.Event(myEvent);
         if(panel != NULL)
            panel.Event(myEvent);
      }
      static Event* PopEvent()
      {
         return event;
      }
      static void DeleteEvent()
      {
         event = NULL;
      }
      static void Add(CHedge* myHedge)
      {
         api = myHedge;
      }
      static void Add(ProtoNode* node)
      {
         panel = node;
      }
   private:
      void ExecuteEvent()
      {
         ;
      }
      static Event* event;
      static CHedge* api;
      static ProtoNode* panel;
};
