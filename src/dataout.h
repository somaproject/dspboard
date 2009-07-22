#ifndef DSPBOARD_DATAOUT_H
#define DSPBOARD_DATAOUT_H

#include <types.h>

namespace dspboard { 

class Data_t {

public:
  virtual void toBuffer(unsigned char * c) = 0; 
  // toBuffer NEEDS to put the type first, i.e. if
  // len(desired data ) = 100 bytes (i.e. 0x64); 
  // then 
  // uint16_t lendata = len(desired data)
  // c[0] = lendata>> 8; 
  // c[1] = lendata & 0xFF; 
};


class DataOut {
public:
  virtual void sendData(Data_t &) = 0; 
  virtual void sendPending() = 0; 
  virtual bool txBufferFull() = 0; 

}; 

}
#endif

