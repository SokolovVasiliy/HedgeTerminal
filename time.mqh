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
      /// ���������� ���������� ���������� ��������� � 1 ������ 1970 ����.
      ///
      long Tiks(){return tiks;}
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
      bool operator>(const CTime* t)const
      {
         if(this.tiks > t.Tiks())return true;
         else return false;
      }
      bool operator<(const CTime* t)const
      {
         if(this.tiks > t.Tiks())return false;
         else return true;
      }
      bool operator>(const long t)const
      {
         if(this.tiks > t)return true;
         else return false;
      }
      bool operator<(const long t)const
      {
         if(this.tiks > t)return false;
         else return true;
      }
      bool operator>(const datetime t)const
      {
         if(this.tiks > t*1000)return true;
         else return false;
      }
      bool operator<(const datetime t)const
      {
         if(this.tiks > t*1000)return false;
         else return true;
      }
      /* == */
      bool operator==(const CTime* t)const
      {
         if(this.tiks == t.Tiks())return true;
         else return false;
      }
      bool operator==(const long t)const
      {
         if(this.tiks == t)return true;
         else return false;
      }
      bool operator==(const datetime t)const
      {
         if(this.tiks == t*1000)return true;
         else return false;
      }
      /*Set timer*/
      void operator=(const long value)
      {
         tiks = value;
      }
      void operator=(const datetime t)
      {
         tiks = t*1000;
      }
   private:
      long tiks;
};
