// blackfin is a little-endian architecture
// and all of our network data is big-endian

#include <arpa/inet.h>
#include <iostream>

namespace dspboard { 

inline unsigned int hostToNet(unsigned int x) 
{
  return htonl(x); 
}

inline int hostToNet(int x) 
{
  return htonl(x); 
}

inline short hostToNet(short x)
{
  return htons(x); 
}

inline unsigned short hostToNet(unsigned short x)
{
  return htons(x); 

} 

inline unsigned long long  hostToNet(unsigned long long x)
{
  int x1 = x & 0xFFFFFFFF; 
  int x2 = (x >> 32) & 0xFFFFFFFF; 
  
  unsigned long long int x1n = hostToNet(x1); 
  unsigned long long int x2n = hostToNet(x2); 
  //std::cout << "Converting " << std::hex << x << " to "
  //<<  x1n << ' ' << x2n << std::endl; 

  unsigned long long res =  (x1n << 32) | x2n; 
  
  return res; 

} 

}
