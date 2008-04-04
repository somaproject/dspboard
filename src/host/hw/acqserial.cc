#include "acqserial.h"
#include <stdexcept>
#include <iostream>

AcqSerial::AcqSerial() :
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

}

AcqSerial::~AcqSerial()
{
}

bool AcqSerial::linkUp(){
  return linkUpState_; 
}

bool AcqSerial::checkRxEmpty(){
  // we always have sim packets to send
  
  return false; 

}

void AcqSerial::sendCommand(AcqCommand * ac)
{

  if (acDelaycnt_ >= 0) {
    throw std::runtime_error("command sent before previous had completed"); 
  } else {
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

    }
  }

  af->success = true; 
  
  
  // populate data
  for (int i = 0; i < 10; i++)
    {
      af->samples[i] = (fpos_ << 4) + i; 
    }
  
  fpos_ += 1; 

  acDelaycnt_--; 
  
}
