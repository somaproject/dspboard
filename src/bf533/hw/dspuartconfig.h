#ifndef DSPUARTCONFIG_H
#define DSPUARTCONFIG_H

#include <dsp.h>

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

#endif // DSPUARTCONFIG_H
