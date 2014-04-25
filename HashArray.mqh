//+------------------------------------------------------------------+
//|                                                    HashArray.mqh |
//|                                                            micle |
//|                            https://login.mql5.com/ru/users/micle |
//+------------------------------------------------------------------+
#property copyright "micle"
#property link      "https://login.mql5.com/ru/users/micle"
#property version   "1.00"

class HashNodeStringString{
   public:
      string                  key;
      string                  value;
      HashNodeStringString   *operator=(const HashNodeStringString &n) { key=n.key; value=n.value; return GetPointer(this); }
      HashNodeStringString   *operator=(const string v) { value=v; return GetPointer(this); }
      void                    HashNodeStringString() {}
      void                    HashNodeStringString(const string k, const string v) {key = k; value = v;}
      //bool                    operator==(const HashNodeStringString &n) { return value == n.value; }
};

class HashEntryStringString{
   protected:
      HashNodeStringString   *m_nodes[];
      
   public:
      void                    HashEntryStringString(void) {}
      void                    HashEntryStringString(const string k, const string v);
      void                   ~HashEntryStringString();
      int                     Size() { return ArraySize(m_nodes); }
      HashNodeStringString   *operator[](const int i) { return GetPointer(m_nodes[i]); }
      HashNodeStringString   *add(const string k, int &size);
};

void HashEntryStringString::~HashEntryStringString()
{
   for(int n=0;n<ArraySize(m_nodes);n++)
   {
      if(CheckPointer(m_nodes[n])) delete m_nodes[n];
   }
   ArrayFree(m_nodes);
}

HashNodeStringString *HashEntryStringString::add(const string k, int &size)
{
   int sz = ArraySize(m_nodes);
   for(int n=0; n<sz; n++)
   {
      if(m_nodes[n].key == k)
      {
         return GetPointer(m_nodes[n]);
      }
   } 
   
   ArrayResize(m_nodes, sz+1, 5);
   m_nodes[sz] = new HashNodeStringString;
   m_nodes[sz].key = k;
   size++;
   return GetPointer(m_nodes[sz]);
}

void HashEntryStringString::HashEntryStringString(const string k, const string v)
{
   ArrayResize(m_nodes, 1, 5);
   HashNodeStringString n;
   n.key = k;
   n.value = v;
   m_nodes[ArraySize(m_nodes)-1] = n;
   return;
}

class CHashArrayStringString
{
   protected:
      double                  m_multiplier;
      double                  m_loadFactor;
      int                     m_limit;
      int                     m_size;
      int                     m_arr_size;
      HashEntryStringString   m_data[];
 
   private:
      void                    rehash(void);
      void                    raw_put(HashEntryStringString &data[], const HashNodeStringString &node);
      
   public:

      //void                    CHashArrayStringString(void);
      void                    CHashArrayStringString(int size = 0);
      void                   ~CHashArrayStringString(void) { ArrayFree(m_data); }
      static ulong            hash64(const string data);
      int                     Size(void) { return m_size; }
      void                    Put(const string key,  const string value);
      
      HashNodeStringString   *operator[](const string key);
};

HashNodeStringString *CHashArrayStringString::operator[](const string key)
{
   if(m_limit < m_size+1) rehash();
   ulong hash = hash64(key);
   int pos = (int)hash%ArraySize(m_data);
   //m_size += 1;
   return m_data[pos].add(key, m_size);
}

void CHashArrayStringString::Put(const string key,const string value)
{
   if(m_limit < m_size+1) rehash();
   HashNodeStringString new_node(key, value);
   raw_put(m_data, new_node);
   m_size += 1;
   return;
}

void CHashArrayStringString::rehash(void)
{
   int new_arr_size = (int)( m_arr_size * m_multiplier);
   HashEntryStringString new_data[];
   ArrayResize(new_data, new_arr_size);
   int new_sz = 0;
   for(int e=0; e<ArraySize(m_data); e++)
   {
      for(int n=0; n < m_data[e].Size(); n++)
      {
         if(!CheckPointer(m_data[e][n])) continue;
         if(m_data[e][n].value=="") continue;
         raw_put(new_data, m_data[e][n]);
         new_sz++;
      }
   }
   m_arr_size = new_arr_size;
   m_size = new_sz;
   ArrayResize(m_data, new_arr_size);
   ArrayCopy(m_data, new_data);
   m_limit = (int)(new_arr_size*m_loadFactor);
   return;
}

void CHashArrayStringString::raw_put(HashEntryStringString &data[], const HashNodeStringString &node)
{
   ulong hash = hash64(node.key);
   int pos = (int)hash%ArraySize(data);
   int d =0;
   data[pos].add(node.key, d) = node.value;
   return;
}

ulong CHashArrayStringString::hash64(const string data){
   ulong hash = 39123;
   int n = 0;
   ushort c;
   while ( (c = StringGetCharacter(data, n)) != 0) {
      hash = ((hash << 5) + hash) ^ c;
      n++;
   }
   return hash;
}

void CHashArrayStringString::CHashArrayStringString(int size = 0)
{
   m_multiplier = 2;
   m_loadFactor = 0.72;
   if(size > 0){
      ArrayResize(m_data, size-1);  
   }
   m_limit = (int)(size*m_loadFactor);
   m_size = 0;
   m_arr_size = MathMax(1, size);
   return;
}
