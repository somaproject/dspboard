#ifndef ACQBOARDIF_H
#define ACQBOARDIF_H

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

#endif //ACQBOARDIF_H
