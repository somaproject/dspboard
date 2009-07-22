#include "filter.h"
namespace dspboard { 

int32_t convolve(int32_t * x, short xlen, int32_t * xpos, 
		 int32_t * h, short hlen) {

  int64_t value = 0;   
  int32_t * curpos = xpos; 
  if (curpos == x) {
    curpos = x + xlen; 
  }
  
  curpos--; 
  
  for (short i = 0; i < hlen; i++) {
    value += *curpos * h[i];
    if (curpos == x) {
      curpos = x + xlen; 
    } 
    curpos --; 

  }

  return value >> 32; 
}

}
