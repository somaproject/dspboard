#include <cdefBF533.h>


inline void setEventLED(bool on) {
  *pFIO_DIR    |= 0x0100;
  if (on) {
    *pFIO_FLAG_D |= 0x0100;
  } else {
    *pFIO_FLAG_D &= ~0x0100;
  }
}
