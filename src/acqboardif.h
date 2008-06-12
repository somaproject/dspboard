#ifndef ACQBOARDIF_H
#define ACQBOARDIF_H

class AcqFrame
{
 public: 
  unsigned char mode; 
  unsigned char cmdid; 
  bool success; 
  bool loading; 
  unsigned char chksum; 
  short samples[10]; 
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

class AcqState
{
public:
  static const int CHANNUM = 5; 

  unsigned char mode; 
  bool linkUp; 
  short gain[CHANNUM]; 
  bool hpfen[CHANNUM]; 
  char inputSel; 
}; 

class AcqSerialBase
{
 public: 
  virtual bool checkRxEmpty() = 0; 
  virtual void getNextFrame(AcqFrame *) = 0; 
  virtual void sendCommand(AcqCommand *) = 0; 
  virtual bool linkUp() = 0; 

}; 

#endif //ACQBOARDIF_H
