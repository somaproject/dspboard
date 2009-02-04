#include "acqstatecontrol.h"
#include <acqstatereceiver.h>
#define NULL 0


AcqStateControl::AcqStateControl(AcqSerialBase * aserial, AcqState *astate) :
  pAcqSerial_(aserial), 
  pAcqState_(astate), 
  pAcqStateReceiver_(NULL), 
  currentMaskPos_(0), 
  sequentialCMDID_(0), 
  controlstate_(STATE_LINK_DOWN), 
  cmdstate_(CMD_NONE)
{
  resetAll(); 

}

void AcqStateControl::setAcqStateReceiver(AcqStateReceiver * asr)
{
  pAcqStateReceiver_ = asr; 
}

void AcqStateControl::resetAll()
{
  controlstate_ = STATE_LINK_DOWN; 
  cmdstate_ = CMD_NONE; 
  
}

bool AcqStateControl::isReady()
{
  if(controlstate_ == STATE_NORMAL_OP) {
    return true; 
  }
  
  return false; 

}

bool AcqStateControl::setLinkStatus(bool linkup)
{
  /* setLinkStatus is called externally when the link state
     changes, and basically resets everything. 
     
  */
  if (pAcqState_->linkUp != linkup) {
    pAcqState_->linkUp = linkup; 
    resetAll();     
    if (!linkup) {
      pAcqStateReceiver_->onLinkChange(true); 
    } 
  }
  
}


bool AcqStateControl::newAcqFrame(AcqFrame * af)
{
  /*
    NewAcqFrame is the primary entry point for our FSMs
    
  */
  //std::cout << "new acq frame--------------------" << std::endl; 
  controlStateAdvance(af); 
  commandStateAdvance(af); 
  
}

void AcqStateControl::serialCommandSend()
{
  /* 
     Send the current serial command for currentMaskPos_
     
  */ 
  //std::cout << "serialCommandSend" << std::endl; 

  switch (cmdstate_) {
  case CMD_GAIN_SET: 
    {
      AcqCommand gcmd; 
      char cmdid = getNextCMDID(); 
      gcmd.cmdid = cmdid; 
      gcmd.cmd = 1; 
      gcmd.data = (currentMaskPos_ << 24) | cmdCurrentVal_ << 16; 

      pendingSerialCMDID_ = cmdid; 
      //std::cout << "sending gain command" << std::endl; 
      pAcqSerial_->sendCommand(&gcmd); 
    }
    break;
    
  case CMD_HPF_SET: 
    {
    AcqCommand hcmd; 
    char cmdid = getNextCMDID(); 
    hcmd.cmdid = cmdid; 
    hcmd.cmd = 2; 
    hcmd.data = (currentMaskPos_ << 24) | cmdCurrentVal_ << 16; 

    pendingSerialCMDID_ = cmdid; 
    pAcqSerial_->sendCommand(&hcmd); 
    break; 
    }

  case CMD_INSEL_SET: 
    {
    AcqCommand icmd; 
    char cmdid = getNextCMDID(); 
    char chan = cmdCurrentVal_; 
    icmd.cmdid = cmdid; 
    icmd.cmd = 3; 
    icmd.data = chan; 
    icmd.data = icmd.data << 24; 
    pendingSerialCMDID_ = cmdid; 
    pAcqSerial_->sendCommand(&icmd); 
    break; 
    }
  }
  

}


void AcqStateControl::send_changeMode(char mode) {
  // Mode changes are much more direct, and we 
  // simply create and send the command

//   AcqCommand changemodecmd; 
//   char cmdid = getNextCMDID(); 
  
//   changemodecmd.cmdid = cmdid;
//   changemodecmd.cmd = 7; 
//   changemodecmd.data = mode; 
//   changemodecmd.data =  changemodecmd.data << 24; 

//   pAcqSerial_->sendCommand(&changemodecmd); 

//   pendingSerialCMDID_ = cmdid;
//   pendingSerial_ = true; 
  

}

void AcqStateControl::send_setGain(chanmask_t * chanmask, int gainval)
{
  

  // decode the gainval
  char gainsetting = decodeGain(gainval); 

  // populate the mask
  resetCurrentChanMask(chanmask); 

  cmdCurrentVal_ = gainsetting; 
  
  cmdstate_ = CMD_GAIN_SET; // force change the state

}


void AcqStateControl::send_setHPF(chanmask_t * chanmask, bool enabled)
{
  
  resetCurrentChanMask(chanmask); 

  cmdCurrentVal_ = enabled; 

  cmdstate_ = CMD_HPF_SET; 


}

void AcqStateControl::send_setInput(char chan)
{
  
  cmdCurrentVal_ = chan; 

  cmdstate_ = CMD_INSEL_SET; 


}


bool AcqStateControl::changeMode(char mode) {
  // Mode changes are much more direct, and we 
  // simply create and send the command

  if ((controlstate_ != STATE_NORMAL_OP) or (cmdstate_ != CMD_NONE)) {
    return false; 
  }

//   AcqCommand changemodecmd; 
//   char cmdid = getNextCMDID(); 
  
//   changemodecmd.cmdid = cmdid;
//   changemodecmd.cmd = 7; 
//   changemodecmd.data = mode; 
//   changemodecmd.data =  changemodecmd.data << 24; 

//   pAcqSerial_->sendCommand(&changemodecmd); 

//   pendingSerialCMDID_ = cmdid;
//   pendingSerial_ = true; 
  

}

bool AcqStateControl::setGain(chanmask_t * chanmask, int gainval)
{
  if ((controlstate_ != STATE_NORMAL_OP) or (cmdstate_ != CMD_NONE)) {
    return false; 
  }

  send_setGain(chanmask, gainval); 
  
  return true; 
}


bool AcqStateControl::setHPF(chanmask_t * chanmask, bool enabled)
{
  
  if ((controlstate_ != STATE_NORMAL_OP) or (cmdstate_ != CMD_NONE)) {
    return false; 
  }

  send_setHPF(chanmask, enabled); 

  return true; 

}

bool AcqStateControl::setInput(char chan)
{
  if ((controlstate_ != STATE_NORMAL_OP) or (cmdstate_ != CMD_NONE)) {
    return false; 
  }
  send_setInput(chan); 
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

void AcqStateControl::resetCurrentChanMask(chanmask_t * chanmask) {
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

void AcqStateControl::controlStateAdvance(AcqFrame * af)
{
  /*
    The Control FSM handles link up / link down, 
    state initialization,  and the like. 
    

  */ 
  chanmask_t chanmask[AcqState::CHANNUM]; 
  chanmask[0] = 1; 
  chanmask[1] = 1; 
  chanmask[2] = 1; 
  chanmask[3] = 1; 
  chanmask[4] = 1; 

  mostRecentReceivedCMDID_ = af->cmdid; 

  switch(controlstate_) {
  case STATE_LINK_DOWN: 
    {
      //std::cout << "STATE_LINK_DOWN" << std::endl;
      if (pAcqState_->linkUp) {
	controlstate_ = STATE_LINK_UP; 
      }
    }
    break; 
  case STATE_LINK_UP:
    {
      //std::cout << "STATE_LINK_UP" << std::endl;
      // we've just brought up the link state; capture the CMDID 
      // as the current cmdID and capture the mode
      while (sequentialCMDID_ == af->cmdid ) {
	getNextCMDID(); 

      }
      pAcqState_->mode = af->mode; 
      pAcqStateReceiver_->onModeChange(af->mode); 
      pAcqStateReceiver_->onLinkChange(true); 
    
      controlstate_ = STATE_INIT_GAINS; 
    }
    break; 
  case STATE_INIT_GAINS:
    {
      //std::cout << "STATE_INIT_GAINS" << std::endl;
      send_setGain(chanmask, 0); 
      controlstate_ = STATE_INIT_GAINS_WAIT; 
    }
    break; 
  case STATE_INIT_GAINS_WAIT:
    {
      //std::cout << "STATE_INIT_GAINS_WAIT" << std::endl;

      if (cmdstate_ == CMD_GAIN_DONE) {
	controlstate_ = STATE_INIT_HPFS; // /STATE_INIT_HPFS; 
      }
    }
    break; 
  case STATE_INIT_HPFS:
    {
      //std::cout << "STATE_INIT_HPFS" << std::endl;
      send_setHPF(chanmask, false); 
      controlstate_ = STATE_INIT_HPFS_WAIT; 
    }
    break; 
  case STATE_INIT_HPFS_WAIT:
    {
      //std::cout << "STATE_INIT_HPFS_WAIT" << std::endl;
      
      if (cmdstate_ == CMD_HPF_DONE) {
	controlstate_ = STATE_INIT_INSEL; // /STATE_INIT_HPFS; 
      }
    }
    break; 
  case STATE_INIT_INSEL:
    {
      //std::cout << "STATE_INIT_INSEL" << std::endl;
      send_setInput(0); 
      controlstate_ = STATE_INIT_INSEL_WAIT; 
    }
    break; 
  case STATE_INIT_INSEL_WAIT:
    {
      //std::cout << "STATE_INIT_INSEL_WAIT" << std::endl;
      
      if (cmdstate_ == CMD_INSEL_DONE) {
	controlstate_ = STATE_NORMAL_OP; // /STATE_INIT_HPFS; 
      }
      
    }
    break; 
  case STATE_NORMAL_OP:
    {
      //std::cout << "STATE_NORMAL_OP" << std::endl; 
      
    }
    break; 
  default: 
    break; 
  }
  
}

void AcqStateControl::commandStateAdvance(AcqFrame * af)
{
  switch(cmdstate_) {
  case CMD_NONE: 
    {
      //std::cout << "CMD_NONE" << std::endl;
      // generally we just chill here

    }
    break; 

  case CMD_GAIN_SET:
    {
      //std::cout << "CMD_GAIN_SET" << std::endl;
      if( currentMask_[currentMaskPos_]) { 
	// send the actual command
	serialCommandSend(); 
	cmdstate_ = CMD_GAIN_WAIT; 

      } else { 
	currentMaskPos_++; 
	if (currentMaskPos_ == AcqState::CHANNUM) {
	  cmdstate_ = CMD_GAIN_DONE; 
	}
      }
      
    }
    break; 

  case CMD_GAIN_WAIT: 
    {
      //std::cout << "CMD_GAIN_WAIT" << std::endl;
      if (af->cmdid == pendingSerialCMDID_) {
	//std::cout << "Current gain command completed" << std::endl; 
	currentMaskPos_++; 
	if (currentMaskPos_ == AcqState::CHANNUM) {
	  // done 
	  cmdstate_ = CMD_GAIN_DONE; 
	} else { 
	  cmdstate_ = CMD_GAIN_SET; 
	}
      }
    }
    break; 

  case CMD_GAIN_DONE:
    {
      //std::cout << "CMD_GAIN_DONE" << std::endl;

      int gainrealvalue = encodeGain(cmdCurrentVal_);
      // update the state registers
      for (int i = 0; i < AcqState::CHANNUM; i++) {
	if (currentMask_[i] != 0) {
	  pAcqState_->gain[i] = gainrealvalue; 
	  pAcqState_->rangemin[i] = AcqState::RANGEMIN[cmdCurrentVal_]; 
	  pAcqState_->rangemax[i] = AcqState::RANGEMAX[cmdCurrentVal_]; 

	}
      }      
      pAcqStateReceiver_->onGainChange(currentMask_, gainrealvalue); 
      // trigger gain callback FIXME
      cmdstate_ = CMD_NONE; 
    }
    break; 

  case CMD_HPF_SET:
    {
      //std::cout << "CMD_HPF_SET" << std::endl;
      if( currentMask_[currentMaskPos_]) { 
	// send the actual command
	serialCommandSend(); 
	cmdstate_ = CMD_HPF_WAIT; 
	
      } else { 
	currentMaskPos_++; 
	if (currentMaskPos_ == AcqState::CHANNUM) {
	  cmdstate_ = CMD_HPF_DONE; 
	}
      }
      
    }
    break; 
    
  case CMD_HPF_WAIT: 
    {
      //std::cout << "CMD_HPF_WAIT" << std::endl;
      if (af->cmdid == pendingSerialCMDID_) {
	currentMaskPos_++; 
	if (currentMaskPos_ == AcqState::CHANNUM) {
	  // done 
	  cmdstate_ = CMD_HPF_DONE; 
	} else { 
	  cmdstate_ = CMD_HPF_SET; 
	}
      }
    }
    break; 
    
  case CMD_HPF_DONE:
    {
      //std::cout << "CMD_HPF_DONE" << std::endl;
      
      // update the state registers
      for (int i = 0; i < AcqState::CHANNUM; i++) {
	if (currentMask_[i] != 0) {
	  pAcqState_->hpfen[i] = cmdCurrentVal_; 
	  
	}
      }      
      pAcqStateReceiver_->onHPFChange(currentMask_, cmdCurrentVal_); 
      
      // trigger gain callback FIXME
      cmdstate_ = CMD_NONE; 
      
    }
    break;

  case CMD_INSEL_SET:
    {
      //std::cout << "CMD_INSEL_SET" << std::endl;
      // send the actual command
      serialCommandSend(); 
      cmdstate_ = CMD_INSEL_WAIT; 
	
    }
    break; 
    
  case CMD_INSEL_WAIT: 
    {
      //std::cout << "CMD_INSEL_WAIT" << std::endl;
      if (af->cmdid == pendingSerialCMDID_) {
	cmdstate_ = CMD_INSEL_DONE; 
      }
    }
    break; 
    
  case CMD_INSEL_DONE:
    {
      //std::cout << "CMD_INSEL_DONE" << std::endl;
      
      pAcqState_->inputSel = cmdCurrentVal_; 

      pAcqStateReceiver_->onInputSelChange(cmdCurrentVal_); 
      
      // trigger gain callback FIXME
      cmdstate_ = CMD_NONE; 
    }
    break;

  }
  
}
