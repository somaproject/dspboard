#ifndef DSPBOARD_DSPUARTCONFIG_H
#define DSPBOARD_DSPUARTCONFIG_H

#include <dsp.h>

namespace dspboard { 
class DSPUARTConfig: public DSPConfig
{
public:
  DSPUARTConfig(); 

  inline DSP_POSITION getDSPPos() {
    return pos_;
  }

  unsigned char getEventDevice(); 
  unsigned char getDataSrc(); 

private:
  DSP_POSITION pos_; 
  unsigned char device_; 
  unsigned char datasrc_; 
  void enableSerial(); 
  void readAndParseBytes(); 
  void disableSerial(); 

}; 

}

#endif // DSPUARTCONFIG_H
