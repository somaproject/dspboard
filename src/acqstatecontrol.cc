#include "acqstatecontrol.h"


AcqStateControl::AcqStateControl(AcqSerialBase * aserial, AcqState *astate) :
  pAcqSerial_(aserial), 
  pAcqState_(astate), 
  pendingCommand_(false), 
  pendingHandle_(0), 
  currentOP_(NONE), 
  currentMaskPos_(0), 
  pendingSerialCMDID_(0), 
  pendingSerial_(false), 
  sequentialCMDID_(0), 
  lcp_(0), 
  mcp_(0)
{
  

}

void AcqStateControl::setLinkChangeCallback(LinkChangeProc_t lcp)
{
  lcp_ = lcp; 
}

void AcqStateControl::setModeChangeCallback(ModeChangeProc_t mcp)
{
  mcp_ = mcp; 
}

bool AcqStateControl::setLinkStatus(bool linkup)
{
  
  if (pAcqState_->linkUp != linkup) {
    pAcqState_->linkUp = linkup; 
    
    // we've changed
    if (linkup ) {
      // FIXME: We shoul really reinitalize all the relevant settings
      
    } else {
      // link down FIXME: What to do here? Cancel all pending events? 
      cancelAllPending(); 
    }
    if (lcp_) 
      lcp_(linkup); 
    
  }
  
}


bool AcqStateControl::newAcqFrame(AcqFrame * af)
{
  // if the mode has changed, notify the mode change interface
  if (af->mode != pAcqState_->mode) {

    pAcqState_->mode = af->mode; 
    
    if(mcp_) 
      mcp_(pAcqState_->mode); 
    
    // cancell all pending commands? a no-op if we're in a command
    cancelAllPending();  // 

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
    doneProc_(pendingHandle_, false); // FAILURE    

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
      if (currentMaskPos_ == AcqState::CHANNUM) {
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
    doneProc_(pendingHandle_, true); 
    break; 

  case SETHPF: 
    doneProc_(pendingHandle_, true); 
    break; 

  
  }

  pendingHandle_ = 0; 
  pendingSerial_ = false; 
  pendingCommand_ = false; 

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

bool AcqStateControl::setInput(char chan, CommandDoneProc_t proc, short donehandle)
{
  
  if (pendingCommand_)  // abort if currently sending a command
    return false; 

  if (!pAcqState_->linkUp) 
    return false; 
  
  currentMaskPos_ = AcqState::CHANNUM -1;  // so when Done gets called we correctly dispatch
  currentVal_ = chan; 
  char cmdid = getNextCMDID(); 

  AcqCommand changeinputcmd; 
  changeinputcmd.cmdid = cmdid; 
  changeinputcmd.cmd = 2; 
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

bool AcqStateControl::setGain(char chanmask, int gainval, CommandDoneProc_t proc, 
			      short donehandle)
{
  
  if (pendingCommand_)  // abort if currently sending a command
    return false; 
  if (!pAcqState_->linkUp) 
    return false; 
  

  // decode the gainval
  char gainsetting = decodeGain(gainval); 

  pendingCommand_ = true; 
  pendingHandle_ = donehandle; 
  doneProc_ = proc; 

  
  // populate the mask
  currentMaskPos_ = -1; 
  for (int i = 0; i < AcqState::CHANNUM; i++) {
    if (chanmask & 0x01) {
      if (currentMaskPos_ < 0) {
	currentMaskPos_ = i; 
      }
      currentMask_[i] = true; 
    } else {
      currentMask_[i] = false; 
    } 
    chanmask = chanmask >> 1; 
  }

  currentOP_ = SETGAIN; 
  currentVal_ = gainsetting; 

  if (currentMaskPos_ >= 0 ) {
    // at least one mask bit was non-zero, so send
    serialCommandSend(); 

  } else {
    commandDone(); 
  }
  
}


bool AcqStateControl::setHPF(char chanmask, bool enabled, CommandDoneProc_t proc, 
			      short donehandle)
{
  
  if (pendingCommand_)  // abort if currently sending a command
    return false; 
  if (!pAcqState_->linkUp) 
    return false; 
  

  // decode the gainval

  pendingCommand_ = true; 
  pendingHandle_ = donehandle; 
  doneProc_ = proc; 
  
  // populate the mask
  currentMaskPos_ = -1; 
  for (int i = 0; i < AcqState::CHANNUM; i++) {
    if (chanmask & 0x01) {
      if (currentMaskPos_ < 0) {
	currentMaskPos_ = i; 
      }
      currentMask_[i] = true; 
    } else {
      currentMask_[i] = false; 
    } 
    chanmask = chanmask >> 1; 
  }

  currentOP_ = SETHPF; 
  currentVal_ = enabled; 

  if (currentMaskPos_ >= 0 ) {
    // at least one mask bit was non-zero, so send
    serialCommandSend(); 

  } else {
    commandDone(); 
  }
  
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
