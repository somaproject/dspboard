#ifndef DSPBOARD_FILTER_H
#define DSPBOARD_FILTER_H
#include "types.h"



/*
Hardware-accelerated filter options

(see host/filter.h for function descriptions)

*/

namespace dspboard { 

int32_t convolve(int32_t x[], short xlen, int32_t * xpos, 
		 int32_t h[], short hlen); 

}
#endif // FILTER_H
