#include "acqstatecontrol.h"
#include <acqstatereceiver.h>

#define NULL 0

AcqStateControl::AcqStateControl(AcqSerialBase * aserial, AcqState *astate) :
  pAcqSerial_(aserial), 
  pAcqState_(astate), 
  pAcqStateReceiver_(NULL), 
  pendingCommand_(false), 
  currentOP_(NONE), 
  currentMaskPos_(0), 
  pendingSerialCMDID_(0), 
  pendingSerial_(false), 
  sequentialCMDID_(0), 
  waitForCMDID_(true), 
  initState_(INIT_NONE), 
  isInitializing_(false)
{
  

}

void AcqStateControl::setAcqStateReceiver(AcqStateReceiver * asr)
{
  pAcqStateReceiver_ = asr; 
}

bool AcqStateControl::setLinkStatus(bool linkup)
{
  // called externally when the link status changes
  if (pAcqState_->linkUp != linkup) {
    pAcqState_->linkUp = linkup; 
    
    // we've changed
    if (linkup ) {
      // FIXME: We should really reinitalize all the relevant settings
      waitForCMDID_ = true;  // wait until we get our next cmdid
      initState_ = INIT_INIT; 
      isInitializing_ = true; 
    } else {
      // link down FIXME: What to do here? Cancel all pending events? 
      cancelAllPending(); 
    }
    pAcqStateReceiver_->onLinkChange(linkup); 
    
  }
  
}


bool AcqStateControl::newAcqFrame(AcqFrame * af)
{
 
  if (waitForCMDID_) {
    waitForCMDID_ = false; 
    if (af->cmdid == sequentialCMDID_) {
      getNextCMDID(); 
    }

    return true; 
  }
 // if the mode has changed, notify the mode change interface
  if (af->mode != pAcqState_->mode) {

    pAcqState_->mode = af->mode; 
    
    pAcqStateReceiver_->onModeChange(pAcqState_->mode); 
    
    // cancell all pending commands? a no-op if we're not in a command
    cancelAllPending();  // 

    initState_ = INIT_GAINS; // kick it off??
    initStateAdvance();
  } 

  if ((af->cmdid == pendingSerialCMDID_) and pendingSerial_) {
    // a serial command is done
    serialCommandDone(); 
    
  } else {
    if (((sequentialCMDID_ + 2) % 16)  == af->cmdid) {
    // FIXME? If we are receiving a cmd that's supposed to be our
    // next cmdid, then inc the cmdid
      getNextCMDID(); 
    }
  }
  
}


void AcqStateControl::cancelAllPending()
{
  if (pendingCommand_) {
    pendingSerial_ = false; 
    pendingCommand_ = false; 
    //doneProc_(pendingHandle_, false); // FAILURE    FIXME? 

  }

}


void AcqStateControl::serialCommandDone()
{
  if (pendingSerial_) {
    if (currentMaskPos_ >= AcqState::CHANNUM - 1) {
      commandDone(); 
    } else {
      currentMaskPos_++; 
      while((currentMaskPos_ < AcqState::CHANNUM) and
	    ! currentMask_[currentMaskPos_]) {
	currentMaskPos_++; 
      }
      if (currentMaskPos_ >= AcqState::CHANNUM) {
	// oops, done
	commandDone(); 
      } else {
	serialCommandSend(); 
      }
    }
    
  }
  
}

void AcqStateControl::commandDone()
{
  
  switch (currentOP_) {
    // and now, it's time for the callbacks; 
  case NONE: // what?  
    break; 

  case SETGAIN: 
    {
      int gainrealvalue = encodeGain(currentVal_);
      // update the state registers
      for (int i = 0; i < AcqState::CHANNUM; i++) {
	if (currentMask_[i] != 0) {
	  pAcqState_->gain[i] = gainrealvalue; 
	}
      }      
      pAcqStateReceiver_->onGainChange(currentMask_, gainrealvalue); 
    }
    break; 

  case SETHPF: 
    {
      bool val  = false; // FIXME // get the current value
      for (int i = 0; i < AcqState::CHANNUM; i++) {
	if (currentMask_[i] != 0) {
	  pAcqState_->hpfen[i] = val; 
	}
      }      
      
      pAcqStateReceiver_->onHPFChange(currentMask_, val); 
    }
    break; 
  case SETINSEL: 
    {
      bool val  = false; // FIXME
      pAcqState_->inputSel = val; 
      pAcqStateReceiver_->onInputSelChange(val); 
    }
    break; 
  
  }

  pendingSerial_ = false; 
  pendingCommand_ = false; 
  if (initState_ != INIT_NONE) {
    initStateAdvance(); // advance state
    
  } else { 
    isInitializing_ = false; 
  }
}

void AcqStateControl::serialCommandSend()
{
  /* 
     Send the current serial command for currentMaskPos_
     
  */ 
  switch (currentOP_) {
  case NONE: 
    // not entirely sure what we should do here
    break; 

  case SETGAIN:
    {
      AcqCommand gcmd; 
      char cmdid = getNextCMDID(); 
      gcmd.cmdid = cmdid; 
      gcmd.cmd = 1; 
      gcmd.data = (currentMaskPos_ << 24) | currentVal_ << 16; 

      pendingSerialCMDID_ = cmdid; 
      pendingSerial_ = true; 
      pAcqSerial_->sendCommand(&gcmd); 
    }
    break;
    
  case SETHPF: 
      AcqCommand hcmd; 
      char cmdid = getNextCMDID(); 
      hcmd.cmdid = cmdid; 
      hcmd.cmd = 2; 
      hcmd.data = (currentMaskPos_ << 24) | currentVal_ << 16; 

      pendingSerialCMDID_ = cmdid; 
      pendingSerial_ = true; 
      pAcqSerial_->sendCommand(&hcmd); 


    break; 

  }
  

}

bool AcqStateControl::setInput(char chan)
{
  
  if (pendingCommand_)  // abort if currently sending a command
    return false; 

  if (!pAcqState_->linkUp) 
    return false; 
  
  currentMaskPos_ = AcqState::CHANNUM ;  // so when Done gets called we correctly dispatch
  currentOP_ = SETINSEL; 
  currentVal_ = chan; 
  char cmdid = getNextCMDID(); 

  AcqCommand changeinputcmd; 
  changeinputcmd.cmdid = cmdid; 
  changeinputcmd.cmd = 3; 
  changeinputcmd.data = chan; 
  changeinputcmd.data = changeinputcmd.data << 24; 
  

  
  pAcqSerial_->sendCommand(&changeinputcmd); 

  pendingSerialCMDID_ = cmdid;
  pendingSerial_ = true; 
     
}

bool AcqStateControl::changeMode(char mode) {
  // Mode changes are much more direct, and we 
  // simply create and send the command

  if (pendingCommand_)  // abort if currently sending a command
    return false; 

  if (!pAcqState_->linkUp) 
    return false; 
  

  AcqCommand changemodecmd; 
  char cmdid = getNextCMDID(); 
  
  changemodecmd.cmdid = cmdid;
  changemodecmd.cmd = 7; 
  changemodecmd.data = mode; 
  changemodecmd.data =  changemodecmd.data << 24; 

  pAcqSerial_->sendCommand(&changemodecmd); 

  pendingSerialCMDID_ = cmdid;
  pendingSerial_ = true; 
  

}

bool AcqStateControl::setGain(chanmask_t * chanmask, int gainval)
{
  
  if (pendingCommand_)  // abort if currently sending a command
    return false; 
  if (!pAcqState_->linkUp) 
    return false; 

  // decode the gainval
  char gainsetting = decodeGain(gainval); 

  pendingCommand_ = true; 

  // populate the mask
  resetChanMask(chanmask); 

  currentOP_ = SETGAIN; 
  currentVal_ = gainsetting; 

  if (currentMaskPos_ >= 0 ) {
    // at least one mask bit was non-zero, so send
    serialCommandSend(); 

  } else {
    commandDone(); 
  }
  return true; 
}


bool AcqStateControl::setHPF(chanmask_t * chanmask, bool enabled)
{
  
  if (pendingCommand_)  // abort if currently sending a command
    return false; 
  if (!pAcqState_->linkUp) 
    return false; 
  
  // decode the gainval

  pendingCommand_ = true; 
      
  // populate the mask
  resetChanMask(chanmask); 

  currentOP_ = SETHPF; 
  currentVal_ = enabled; 

  if (currentMaskPos_ >= 0 ) {
    // at least one mask bit was non-zero, so send
    serialCommandSend(); 

  } else {
    commandDone(); 
  }
  return true; 
}


unsigned char AcqStateControl::getNextCMDID()
{
  sequentialCMDID_ = (sequentialCMDID_ + 2) % 16; 
  return sequentialCMDID_; 
  
}

void AcqStateControl::setDSPPos(DSP_POSITION p)
{
  dsppos_ = p; 
  if (p == DSPA or p == DSPC) {
    sequentialCMDID_ = 0; 
  } else {
    sequentialCMDID_ = 1; 

  }
}

void AcqStateControl::resetChanMask(chanmask_t * chanmask) {
  currentMaskPos_ = -1; 

  for (int i = 0; i < AcqState::CHANNUM; i++) {
    if (chanmask[i]) {
      if (currentMaskPos_ < 0) {
	currentMaskPos_ = i; 
      }
    }
    currentMask_[i] = chanmask[i]; 
  }
  
}

void AcqStateControl::initStateAdvance()
{
  bool chanmask[AcqState::CHANNUM];
  chanmask[0] = true; 
  chanmask[1] = true; 
  chanmask[2] = true; 
  chanmask[3] = true; 
  chanmask[4] = true; 
  //std::cout << "AcqStateControl::initStateAdvance" << std::endl; 
  switch(initState_) {
  case INIT_NONE: 
    //std::cout << "AcqStateControl INIT_NONE" << std::endl; 
    // none
    break; 
  case INIT_INIT:
    {
      //std::cout << "AcqStateControl INIT_INIT" << std::endl; 
      changeMode(0); 
      initState_ = INIT_GAINS; 
      break; 
    }
  case INIT_GAINS: 
    {
      //std::cout << "AcqStateControl INIT_GAINS" << std::endl; 
      setGain(chanmask, 0); 
      initState_ = INIT_HPFS; 
      break; 
    }
  case INIT_HPFS:
    {
      //std::cout << "AcqStateControl INIT_HPFS" << std::endl; 
      setHPF(chanmask, false); 
      initState_ = INIT_INSEL; 
      break; 
    }
  case INIT_INSEL: 
    {
      //std::cout << "AcqStateControl INIT_INSEL" << std::endl; 
      setInput(0); 
      initState_ = INIT_NONE; 
      break; 
    }
  }
  
}
