#include "acqserial.h"

AcqSerial::AcqSerial()
{
  pRXbuffer_ = new uint16_t[16*RXBUFLEN_];
  
  // configure SPORT
  

  // install interrupt handlers

  // 
}
