#ifndef ACQSTATECONTROL_H
#define ACQSTATECONTROL_H
#include "FastDelegate.h"
#include <acqboardif.h>
#include <dsp.h>


typedef fastdelegate::FastDelegate1<bool> LinkChangeProc_t; 
typedef fastdelegate::FastDelegate1<char> ModeChangeProc_t; 

typedef fastdelegate::FastDelegate2<short, bool> CommandDoneProc_t; 

enum OPS {NONE, SETGAIN, SETHPF, CHANGEMODE, 
	  OFFSETWRITE, SAMPLEBUFFERWRITE, FILTERWRITE}; 


class AcqStateControl
{

public:
  AcqStateControl(AcqSerialBase *, AcqState *); 
  // configure callbacks
  void setLinkChangeCallback(LinkChangeProc_t lcp); 
  void setModeChangeCallback(ModeChangeProc_t mcp); 

  void setDSPPos(DSP_POSITION); 
  // interfaces
  bool setLinkStatus(bool); 
  bool newAcqFrame(AcqFrame* af); 

  // commands
  bool setGain(char chanmask, int gain, CommandDoneProc_t proc, short donehandle); 
  bool setHPF(char chanmask, bool enabled, CommandDoneProc_t proc, short donehandle); 
  bool setInput(char chan, CommandDoneProc_t proc, short donehandle); 
  bool changeMode(char mode); 
  
  

 private:
  AcqSerialBase * pAcqSerial_; 
  AcqState * pAcqState_; 

  DSP_POSITION dsppos_; 
  
  // pending / processing variables
  bool pendingCommand_; // is there a command pending?
  short pendingHandle_; // handle for when we're done
  CommandDoneProc_t doneProc_; // delegate for when we're done
  bool currentMask_[AcqState::CHANNUM]; 
  OPS currentOP_; 
  char currentMaskPos_; 
  int currentVal_; 

  // The acqserial-specific (single-channel at a time) state variables
  char pendingSerialCMDID_; 
  bool pendingSerial_; 

  // callbacks 
  LinkChangeProc_t lcp_; 
  ModeChangeProc_t mcp_; 

  void cancelAllPending(); 
  void serialCommandDone(); 
  void commandDone(); 
  void serialCommandSend(); 

  unsigned char getNextCMDID(); 

  unsigned char sequentialCMDID_; 
  
}; 

#endif // ACQSTATECONTROL_H
