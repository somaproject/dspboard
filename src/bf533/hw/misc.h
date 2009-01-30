#ifndef MISC_H
#define MISC_H

#include <cdefBF533.h>


inline void setEventLED(bool on) {
  *pFIO_DIR    |= 0x0100;
  if (on) {
    *pFIO_FLAG_D |= 0x0100;
  } else {
    *pFIO_FLAG_D &= ~0x0100;
  }
}

inline int cycles()
{
	int ret;
 
	__asm__ __volatile__("%0 = CYCLES;\n\t"
		:"=d"(ret));
 
	return ret;
}

#endif
