#ifndef ACQBOARDIF_H
#define ACQBOARDIF_H

class AcqFrame
{
 public: 
  unsigned char cmdsts; 
  unsigned char cmdid; 
  unsigned char success; 
  unsigned short samples[10]; 
}; 

class AcqCommand
{
 public: 
  unsigned char cmd; 
  unsigned char cmdid; 
  unsigned int data; 
  AcqCommand() :
    cmd(0), 
    cmdid(0), 
    data(0) {
  }

}; 

class AcqSerialBase
{
 public: 
  virtual bool checkRxEmpty() = 0; 
  virtual void getNextFrame(AcqFrame *) = 0; 
  virtual void sendCommand(AcqCommand *) = 0; 
}; 

#endif //ACQBOARDIF_H
