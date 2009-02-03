#ifndef ACQSTATECONTROL_H
#define ACQSTATECONTROL_H
#include "FastDelegate.h"
#include <acqboardif.h>
#include <dsp.h>
#include <types.h>

class AcqStateReceiver; 

enum OPS {NONE, SETGAIN, SETHPF, SETINSEL, CHANGEMODE, 
	  OFFSETWRITE, SAMPLEBUFFERWRITE, FILTERWRITE}; 

/*

  The AcqStateControl handles updating the external AcqState and initializing
  the acqstate upon a link status change. 
  
  

*/ 

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
  
  // commands, external 
  bool setGain(chanmask_t * chanmask, int gain); 
  bool setHPF(chanmask_t * chanmask, bool enabled); 
  bool setInput(char chan); 
  bool changeMode(char mode); 
  
  bool isStateInit(); 
  
  AcqState * pAcqState_; 
  
  unsigned char sequentialCMDID_;  
  // This is the current pending cmdid
  unsigned char mostRecentReceivedCMDID_;  
  
  bool isReady(); 
  
  //private: // FIXME
  
  enum CONTROL_STATES {STATE_LINK_DOWN = 0 , STATE_LINK_UP = 1, 
		       STATE_INIT_MODE = 2,  
		       STATE_INIT_GAINS = 3, STATE_INIT_GAINS_WAIT = 4, 
		       STATE_INIT_HPFS = 5 , STATE_INIT_HPFS_WAIT = 6, 
		       STATE_INIT_INSEL = 7, STATE_INIT_INSEL_WAIT = 8, 
		       STATE_NORMAL_OP = 9}; 
  
  enum COMMAND_STATES 
    {CMD_NONE = 0, 
     CMD_GAIN_SET = 1, CMD_GAIN_WAIT = 2, CMD_GAIN_DONE = 3, 
     CMD_HPF_SET = 4, CMD_HPF_WAIT = 5, CMD_HPF_DONE = 6, 
     CMD_INSEL_SET = 7 , CMD_INSEL_WAIT = 8, CMD_INSEL_DONE = 9
    }; 
  
  
  AcqSerialBase * pAcqSerial_; 
  AcqStateReceiver * pAcqStateReceiver_; 
  DSP_POSITION dsppos_; 
  
  // pending / processing variables

  bool currentMask_[AcqState::CHANNUM]; 
  OPS currentOP_; 
  char currentMaskPos_; 

  int cmdCurrentVal_;  // generinc state


  // The acqserial-specific (single-channel at a time) state variables
  char pendingSerialCMDID_; 

  // callbacks 

  void resetAll(); 
  void serialCommandDone(); 
  void commandDone(); 
  void serialCommandSend(); 

  unsigned char getNextCMDID(); 
  
  void controlStateAdvance(AcqFrame * af);   // method that is called when 
  void commandStateAdvance(AcqFrame * af); 
  void resetCurrentChanMask(chanmask_t *); 

  void send_setGain(chanmask_t * chanmask, int gain); 
  void send_setHPF(chanmask_t * chanmask, bool enabled); 
  void send_setInput(char chan); 
  void send_changeMode(char mode); 

  CONTROL_STATES controlstate_; 
  COMMAND_STATES cmdstate_; 

}; 

#endif // ACQSTATECONTROL_H
