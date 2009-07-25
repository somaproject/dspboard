#ifndef DSPBOARD_ACQSERIAL_H
#define DSPBOARD_ACQSERIAL_H

#include "acqboardif.h"
#include <vector>
#include <list>
#include "types.h"

/*
  if autosend = 1, then we always have data to send, 
  otherwise we can put new sample sets in via appendSamples(); 

*/

namespace dspboard { 

class AcqSerial: public AcqSerialBase
{
public: 
  AcqSerial(bool autosend); 
  ~AcqSerial(); 
  
  bool checkRxEmpty(); 
  void getNextFrame(AcqFrame *); 
  void sendCommand(AcqCommand *); 
  bool checkLinkUp(); 
  bool autosend; 
  bool linkUpState_; 
  void appendSamples(std::vector<int16_t> samps); 


  std::vector<int> gains_; 
  std::vector<bool> hpfs_; 
  int chanSel_;
  int recentCMDID_; 
  int mode_; 

  AcqCommand acPending_; 
  int acDelaycnt_; 
  
  std::list<std::vector<int16_t> > pendingSamples;
  
  short fpos_; 
}; 

}

#endif // ACQSERIAL_H
