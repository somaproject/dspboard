#ifndef ACQBOARDIF_H
#define ACQBOARDIF_H

struct AcqFrame
{
  unsigned char cmdsts; 
  unsigned char cmdid; 
  unsigned short samples[10]; 
}; 

struct AcqCommand
{
  unsigned char cmd; 
  unsigned char cmdid; 
  unsigned int data; 
}; 

class AcqSerialBase
{
 public: 
  virtual bool checkRxEmpty() = 0; 
  virtual void getNextFrame(AcqFrame *) = 0; 
  virtual void sendCommand(const AcqCommand &) = 0; 
}; 

#endif //ACQBOARDIF_H
