#ifndef FILTER_H
#define FILTER_H
#include "types.h"


/*
Optionall hardware-accelerated convolution which takes in the 
description of a sample buffer and a pointer to a filter. 


sample input:
x : points to the beginning of the sample buffer
xlen : total size of the sample buffer, in samples
xpos : pointer pointing to one-past-the-most-recent-sample,
that is, the next empty sample 

Samples must be added to the x buffer in increasing order;
that is, x[n+1] is added after x[n]

filter input:
h: pointer to filter input
hlen: length of filter. 

*/

int32_t convolve(int32_t x[], short xlen, int32_t * xpos, 
		 int32_t h[], short hlen); 



#endif // FILTER_H
