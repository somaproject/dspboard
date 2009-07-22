#ifndef DSPBOARD_ACQBOARDIF_H
#define DSPBOARD_ACQBOARDIF_H

namespace dspboard { 
typedef bool chanmask_t; 

class AcqFrame
{
 public: 
  unsigned char mode; 
  unsigned char cmdid; 
  bool success; 
  bool loading; 
  unsigned char chksum; 
  short samples[10]; 
  unsigned char version; 
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
  AcqState() {
    // initialize to BS values
    mode = 0; 
    linkUp = false; 
    gain[0] = -1; 
    gain[1] = -1; 
    gain[2] = -1; 
    gain[3] = -1; 
    gain[4] = -1; 

    hpfen[0] = false; 
    hpfen[1] = false; 
    hpfen[2] = false; 
    hpfen[3] = false; 
    hpfen[4] = false;
    
    inputSel = 0; 
  }

  unsigned char mode; 
  bool linkUp; 
  short gain[CHANNUM]; 
  bool hpfen[CHANNUM]; 
  char inputSel; 
  int rangemin[CHANNUM]; 
  int rangemax[CHANNUM];
  // constant ranges
  static const int RANGEMAX[8]; 
				 
  static const int RANGEMIN[8];
				 
}; 


class AcqSerialBase
{
 public: 
  virtual bool checkRxEmpty() = 0; 
  virtual void getNextFrame(AcqFrame *) = 0; 
  virtual void sendCommand(AcqCommand *) = 0; 
  virtual bool checkLinkUp() = 0; 

}; 

}
#endif //ACQBOARDIF_H
