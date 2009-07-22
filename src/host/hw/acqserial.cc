#include "acqserial.h"
#include <stdexcept>
#include <iostream>
#include <stdexcept>

namespace dspboard { 

AcqSerial::AcqSerial(bool autosend) :
  autosend(autosend),
  gains_(10), 
  hpfs_(10),
  recentCMDID_ (0), 
  fpos_ (0), 
  mode_(0), 
  linkUpState_(false), 
  acDelaycnt_( -1)
{
  // zero gains and filters
  for (int i = 0; i < 10; i++)
    {
      gains_[i] = 0; 
      hpfs_[i] = 0; 
    }; 
  chanSel_ = 0; 

}

AcqSerial::~AcqSerial()
{
}
void AcqSerial::appendSamples(std::vector<int16_t> samps)
{
  if(autosend) {
    throw std::runtime_error("Can't append samples to an autosend AcqSerial"); 
  }
  pendingSamples.push_back(samps); 

}

bool AcqSerial::checkLinkUp(){
  return linkUpState_; 
}

bool AcqSerial::checkRxEmpty(){
  // we always have sim packets to send
  if (autosend) {
    return false; 
  } else {
    return pendingSamples.empty(); 
  }

}

void AcqSerial::sendCommand(AcqCommand * ac)
{

  if (acDelaycnt_ >= 0) {
    std::cout << "Command send before previous command had completed" 
	      << std::endl; 
    throw std::runtime_error("command sent before previous had completed"); 
  } else {
    std::cout << "AcqSerial sending command" << std::endl; 
    acDelaycnt_ = 5; 
    acPending_ = *ac; 
  }

}

void AcqSerial::getNextFrame(AcqFrame * af) {

  af->mode = mode_; 
  
  if (acDelaycnt_ == 0) {
    af->mode = mode_; 
    af->cmdid = acPending_.cmdid; 
    
    if (acPending_.cmd == 0x01) {
      // set gain
      char chan = acPending_.data >> 24; 
      char val = (acPending_.data >> 16) & 0xFF; 
      std::cout << "AcqSerial setting gain[" << (int)chan << "] = " 
		<< (int) val << std::endl ; 
      gains_[chan] = val; 
    } else  if (acPending_.cmd == 0x02) {
      // set hpf
      char chan = acPending_.data >> 24; 
      bool val = (acPending_.data >> 16) & 0xFF; 

      hpfs_[chan] = val; 
      std::cout << "AcqSerial setting hpf[" << (int)chan << "] = " 
		<< (int) val << std::endl ;
    } else if (acPending_.cmd == 0x3) {
      char chan = acPending_.data >> 24; 
      chanSel_ = chan; 
      std::cout << "AcqSerial setting insel = " 
		<< (int)chanSel_ << std::endl; 

    }
  }

  af->success = true; 
  
  
  // populate data
  if (autosend) {
    for (int i = 0; i < 10; i++)
      {
	af->samples[i] = (fpos_ << 4) + i; 
      }
  } else {
    for (int i = 0; i < 10; i++) {
      af->samples[i] = pendingSamples.front()[i]; 
    }
    pendingSamples.pop_front(); 
  }
  fpos_ += 1; 

  acDelaycnt_--; 
  
}

}
