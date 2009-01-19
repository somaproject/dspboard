#include "filter.h"
int32_t convolve(int32_t * x, short xlen, int32_t * xpos, 
		 int32_t * h, short hlen) {

  int64_t value = 0;   
//   for (short i = 0; i < hlen; i++) {
//     value += x[(xpos - i) % xlen]* h[i];
//   }

  return value >> 32; 
}

