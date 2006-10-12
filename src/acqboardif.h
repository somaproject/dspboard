#ifndef ACQBOARDIF_H
#define ACQBOARDIF_H

#include <stdint.h>

struct AcqFrame
{
  uint8_t cmdsts; 
  uint8_t cmdid; 
  uint16_t samples[10]; 
}; 

struct AcqCommand
{
  uint8_t cmd; 
  uint8_t cmdid; 
  uint32_t data; 
}; 

class AcqSerialBase
{
 public: 
  virtual bool checkRxEmpty() = 0; 
  virtual void getNextFrame(AcqFrame *) = 0; 
  virtual void sendCommand(const AcqCommand &) = 0; 
};

#endif //ACQBOARDIF_H
