
#include <samplebuffer.h>
     
/*

The goal here is to take in a circular buffer and an array to a
impulse response and return the fixed-point dotproduct (convolution)
of them.

This is a function that may be optimized for the DSP's
accelerated-math library and its internal circular buffer DAGs.

xbuf is the beginning of the x buffer in memory
xpos is our current location in that buffer
xlen is the total buffer length (for wrap-around) 

hbuf is the base of our filter
hlen is the total length of the fitler

we compute: 
     hlen -1
    -----
y = \      hbuf[i] * xbuf[(i + xpos) % xlen]
    /
    -----
     i=0

Note that this assumes that higher values of x are older. 

Damn, this is actually harder than it looks. 



*/
namespace dspboard { 

sample_t dsp_dot_circbuffer(sample_t[] xbuf, sample_t * xpos, sample_t *xlen, sample_t[] hbuf, unsigned int hlen)
{
  int64_t result = 0; 
  
  for (int i = 0; i < hlen; i++)
    {
      result += hbuf[i] * xbuf[(i + xpos) % xlen] ; 
    }

  return result >> (sizeof(sample_t) -2); 

}

}
