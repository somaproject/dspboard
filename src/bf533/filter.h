#ifndef FILTER_H
#define FILTER_H
#include "types.h"


/*
Hardware-accelerated filter options

(see host/filter.h for function descriptions)

*/

int32_t convolve(int32_t x[], short xlen, int32_t * xpos, 
		 int32_t h[], short hlen); 

inline int cycles()
{
	int ret;
 
	__asm__ __volatile__("%0 = CYCLES;\n\t"
		:"=d"(ret));
 
	return ret;
}

#endif // FILTER_H
