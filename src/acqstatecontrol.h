#ifndef ACQSTATECONTROL_H
#define ACQSTATECONTROL_H
#include "FastDelegate.h"
#include <acqboardif.h>
#include <dsp.h>
#include <types.h>

class AcqStateReceiver; 

enum OPS {NONE, SETGAIN, SETHPF, SETINSEL, CHANGEMODE, 
	  OFFSETWRITE, SAMPLEBUFFERWRITE, FILTERWRITE}; 


class AcqStateControl
{

public:
  AcqStateControl(AcqSerialBase *, AcqState *); 
  // configure callbacks

  void setDSPPos(DSP_POSITION); 
  // interfaces
  bool setLinkStatus(bool); 
  bool newAcqFrame(AcqFrame* af); 
  void setAcqStateReceiver(AcqStateReceiver * as); 

  // commands
  bool setGain(chanmask_t * chanmask, int gain); 
  bool setHPF(chanmask_t * chanmask, bool enabled); 
  bool setInput(char chan); 
  bool changeMode(char mode); 
  
  bool isStateInit(); 
  
  AcqState * pAcqState_; 

  unsigned char sequentialCMDID_; 
  
  bool waitForCMDID_; 

  enum INIT_STATES {INIT_NONE, INIT_INIT, INIT_MODE, 
		      INIT_GAINS, INIT_HPFS, INIT_INSEL}; 
  
  bool isInitializing() {
    return isInitializing_; 
  }
private:
  AcqSerialBase * pAcqSerial_; 
  AcqStateReceiver * pAcqStateReceiver_; 
  DSP_POSITION dsppos_; 
  
  // pending / processing variables
  bool pendingCommand_; // is there a command pending?

  bool currentMask_[AcqState::CHANNUM]; 
  OPS currentOP_; 
  char currentMaskPos_; 
  int currentVal_; 

  // The acqserial-specific (single-channel at a time) state variables
  char pendingSerialCMDID_; 
  bool pendingSerial_; 

  // callbacks 

  void cancelAllPending(); 
  void serialCommandDone(); 
  void commandDone(); 
  void serialCommandSend(); 

  unsigned char getNextCMDID(); 
  
  void initStateAdvance();   // method that is called when 
  void resetChanMask(chanmask_t *); 
public:
  INIT_STATES initState_; 
  bool isInitializing_; 
}; 

#endif // ACQSTATECONTROL_H
