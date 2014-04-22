///
/// ������������� �����������
///
#define TIME_MSC 8
///
/// ����� ��� ������ � ��������, �������������� ��� ������, ��� � ����� ������ �������.
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
      /// ������������� �����.
      ///
      void SetDateTime(datetime time)
      {
         tiks = time*1000;
      }
      ///
      /// ���������� ���������� ���������� ��������� � 1 ������ 1970 ����.
      ///
      long Tiks(){return tiks;}
      ///
      /// ������������� �����.
      /// \param value - ���������� �����.
      ///
      void Tiks(long value){tiks = value;}
      
      ///
      /// ���������� ���������� ������ ��������� � 1 ������ 1970 ����.
      ///
      datetime ToDatetime()
      {
         return(datetime)MathFloor(tiks/1000.0);
      }
      ///
      /// �������� ���������� �����������.
      ///
      int Milliseconds()
      {
         long d = (long)tiks % 1000;
         return (int)d;
      }
      ///
      /// �������������� ��������, ����������� ����� � ��������, ��������� � 01.01.1970, � ������ ������� "yyyy.mm.dd hh:mi:ss:msc".
      ///
      string TimeToString(int format)
      {
         string out = "";
         datetime stime = ToDatetime();
         out = TimeToString(stime, format);
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
