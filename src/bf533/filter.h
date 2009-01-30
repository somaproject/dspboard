#ifndef FILTER_H
#define FILTER_H
#include "types.h"


/*
Hardware-accelerated filter options

(see host/filter.h for function descriptions)

*/

int32_t convolve(int32_t x[], short xlen, int32_t * xpos, 
		 int32_t h[], short hlen); 


#endif // FILTER_H
