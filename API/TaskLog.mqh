#include "..\Prototypes.mqh"
#include <Arrays\ArrayInt.mqh>
///
/// Ëîãèðîâàíèå ñîáûòèé äëÿ çàäà÷è.
///
class TaskLog
{
   public:
      ///
      /// Äîáàâëÿåò êîä âûïîëíåíèÿ òàðãåòà.
      /// \param target_type - Òèï òàðãåòà.
      /// \param retcode - Êîä âûïîëíåíèÿ òàðãåòà.
      ///
      void AddRedcode(ENUM_TARGET_TYPE target_type, uint retcode)
      {
         if(targetTypes.Total() == 0)
            firstRecord = TimeCurrent();
         targetTypes.Add(target_type);
         targetRetcodes.Add(retcode);
      }
      ///
      /// Äîáàâëÿåò çàïèñè ëîãîâ â ñóùåñòâóþùèé ëîã.
      ///
      void AddLogs(TaskLog* task_log)
      {
         for(uint i = 0; i < task_log.Total(); i++)
         {
            ENUM_TARGET_TYPE targetType;
            uint retcode;
            task_log.GetRetcode(i, targetType, retcode);
            AddRedcode(targetType, retcode);
         }
      }
      ///
      /// Îáùåå êîëè÷åñòâî âûïîëíåííûõ äåéñòâèé.
      ///
      uint Total(){return (uint)targetTypes.Total();}
      void GetRetcode(uint index, ENUM_TARGET_TYPE& target_type, uint& retcode)
      {
         
         if(index > (uint)targetTypes.Total() || index > (uint)targetRetcodes.Total())
         {
            target_type = TARGET_NDEF;
            retcode = 0;
         }
         else
         {
            target_type = (ENUM_TARGET_TYPE)targetTypes.At(index);
            retcode = targetRetcodes.At(index);
         }
      }
      ///
      /// Î÷èùàåò ëîã çàäàíèÿ.
      ///
      void Clear()
      {
         targetTypes.Clear();
         targetRetcodes.Clear();
      }
      ///
      /// Âðåìÿ ïåðâîé çàïèñè.
      ///
      datetime FirstRecord(){return firstRecord;}
      ///
      /// Âîçâðàùàåò ïîñëåäíèé ñòàòóñ çàäàíèÿ.
      ///
      ENUM_TASK_STATUS Status(){return status;}
      void Status(ENUM_TASK_STATUS stat){status = stat;}
   private:
      ///
      /// Ñòàòóñ çàäàíèÿ.
      ///
      ENUM_TASK_STATUS status;
      ///
      /// Âðåìÿ ïåðâîé çàïèñè.
      ///
      datetime firstRecord;
      ///
      /// Ñîäåðæèò ïîñëåäîâàòåëüíîñòü èäåíòèôèêàòîðîâ òàðãåòîâ.
      ///
      CArrayInt targetTypes;
      ///
      /// Ñîäåðæèò ïîñëåäîâàòåëüíîñòü èäåíòèôèêàòîðû
      ///
      CArrayInt targetRetcodes;
};
