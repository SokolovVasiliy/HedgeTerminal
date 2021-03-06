///
/// Идентификатор миллисекунд
///
#define TIME_MSC 8
///
/// Класс для работы с временем, поддерживающий как точный, так и общий формат времени.
///
class CTime
{
   public:
      CTime(){;}
      CTime(datetime set_time)
      {
         tiks = set_time*1000;
      }
      CTime(long set_time)
      {
         tiks = set_time;
      }
      ///
      /// Устанавливает время.
      ///
      void SetDateTime(datetime time)
      {
         tiks = time*1000;
      }
      ///
      /// Возвращает количество милисекунд прошедших с 1 января 1970 года.
      ///
      long Tiks(){return tiks;}
      ///
      /// Устанавливает время.
      /// \param value - количество тиков.
      ///
      void Tiks(long value){tiks = value;}
      
      ///
      /// Возвращает количество секунд прошедших с 1 января 1970 года.
      ///
      datetime ToDatetime()
      {
         return(datetime)MathFloor(tiks/1000.0);
      }
      ///
      /// Получает компоненту миллисекунд.
      ///
      int Milliseconds()
      {
         long d = (long)tiks % 1000;
         return (int)d;
      }
      ///
      /// Преобразование значения, содержащего время в секундах, прошедшее с 01.01.1970, в строку формата "yyyy.mm.dd hh:mi:ss:msc".
      ///
      string TimeToString(int format)
      {
         string out = "";
         datetime stime = ToDatetime();
         out = ::TimeToString(stime, format);
         if((format & TIME_MSC) == TIME_MSC)
            out += ":" + (string)Milliseconds();
         return out;
      }
      /* >/<*/
      bool operator>(  CTime* t) 
      {
         if(this.tiks > t.Tiks())return true;
         else return false;
      }
      bool operator<(  CTime* t) 
      {
         if(this.tiks > t.Tiks())return false;
         else return true;
      }
      bool operator>(  long t) 
      {
         if(this.tiks > t)return true;
         else return false;
      }
      bool operator<(  long t) 
      {
         if(this.tiks > t)return false;
         else return true;
      }
      bool operator>(  datetime t) 
      {
         if(this.tiks > t*1000)return true;
         else return false;
      }
      bool operator<(  datetime t) 
      {
         if(this.tiks > t*1000)return false;
         else return true;
      }
      /* == */
      bool operator==(  CTime* t) 
      {
         if(this.tiks == t.Tiks())return true;
         else return false;
      }
      bool operator==(  long t) 
      {
         if(this.tiks == t)return true;
         else return false;
      }
      bool operator==(  datetime t) 
      {
         if(this.tiks == t*1000)return true;
         else return false;
      }
      /*Set timer*/
      void operator=(  CTime* value)
      {
         tiks = value.Tiks();
      }
      void operator=(  long value)
      {
         tiks = value;
      }
      void operator=(  datetime t)
      {
         tiks = t*1000;
      }
   private:
      long tiks;
};
