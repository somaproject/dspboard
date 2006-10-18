#include <acqboarddatasrc.h>
#include <acqboardif.h>
#include <stdexcept>

const unsigned short AcqboardDataSrc::ACQGAINS[]  = {0, 100, 200, 500, 
				     1000, 2000, 5000, 10000}; 

AcqboardDataSrc::AcqboardDataSrc(AcqSerialBase * as, ChanSets cs) :
  pAcqSerial_(as), 
  cs_(cs), 
  pendingCommand_(false), 
  pendingOp_(SETGAIN), 
  pendingValue_(0), 
  pendingChannel_(0), 
  linkState_(0)
{
  
  // allocate new ring buffers
  for (int i = 0; i < CHANNUM; i++){
    channels_[i] = new SampleRingBuffer<sample_t>(BUFLEN); 
  }

  if (cs == CHANSET_A) {
    currentCMDID_ = 1; 
  } else {
    currentCMDID_ = 2; 
  }
  

} 

void AcqboardDataSrc::setLinkState(bool state) 
{
  // set state
  // send event


}  

bool AcqboardDataSrc::readySample()
{
  
  bool curLinkState = pAcqSerial_->linkUp(); 
  if (curLinkState != linkState_) {
    setLinkState( curLinkState ); 
  } else {
    if (linkState_ == 0) {
      return false; 
    } else {
      return (not pAcqSerial_->checkRxEmpty()); 
    }
  }

}


void AcqboardDataSrc::sampleProcess()
{
  // extract out the frames
  AcqFrame af; 
  pAcqSerial_->getNextFrame( &af ); 
  
  // scale the samples and put them in our buffer
  int chanos = 0; 
  if (cs_ == CHANSET_B ) {
    chanos = 5; 
  }

  for (int i = 0; i < CHANNUM; i++) {
    float fx = ACQV_RANGE / gains_[i] *  (float(af.samples[chanos + i]) / 32768.0); 
    sample_t x = sample_t(fx * 1e9); 
    // stick in the output buffer
    channels_[i]->append(x); 
    
  }
  
  // check to see if the date is updated
  if (pendingCommand_) {
    
    if (af.cmdid == currentCMDID_) {
      pendingCommand_ = false; 
      if (pendingOp_ == SETGAIN) {
	gains_[pendingChannel_] = pendingValue_; 
      } else if (pendingOp_ == SETHPF) {
	hpfs_[pendingChannel_] = pendingValue_; 
      }
    }
  }

}

int AcqboardDataSrc::getChanNum(void)
{
  return CHANNUM; 
}

SampleBuffer<sample_t> * AcqboardDataSrc::getChannelBuffer(int i)
{
  return channels_[i]; 
}

//AcqboardDataSrc::onEvent(const Event& e)
//{
//
//}

void AcqboardDataSrc::setGain(int chan, int value)
{
  int gsetting = -1; 
  for (int i = 0; i < sizeof(ACQGAINS); i++)
    {
      if (ACQGAINS[i] == value)
	{
	  gsetting = i; 
	  break; 
	}
    }
  if (gsetting == -1) {
    // respond with error
  } else {

    char cmd = 1; 
    uint32_t data = ((chan & 0xFF) << 24) |
      ((gsetting & 0xFF) << 16); 
    sendCmd(cmd, data); 
    pendingOp_ = SETGAIN; 
    pendingValue_ = value; 
    pendingChannel_ = chan; 

  }

}

int AcqboardDataSrc::getGain(int chan) {
  return gains_[chan]; 
}

bool AcqboardDataSrc::getHPFilter(int chan) {
  return hpfs_[chan]; 
}

void AcqboardDataSrc::setHPFilter(int chan, bool state)
{
  char cmd = 2; 
  uint32_t data = ((chan & 0xFF) << 24) |
    ((state& 0xFF) << 16); 
  sendCmd(cmd, data); 
  pendingOp_ = SETHPF; 
  pendingValue_ =  state; 
  pendingChannel_ = chan; 
}


void AcqboardDataSrc::sendCmd(char cmd, uint32_t data) {
  // get next cmdid: 
  
  if (pendingCommand_ ) {
    throw std::runtime_error("Pending Command"); 
	
  } else {
    char cmdid = (currentCMDID_ + 2) % 16; 
    
    AcqCommand acmd; 
    acmd.cmd = cmd; 
    acmd.cmdid = cmdid; 
    acmd.data = data; 
    pAcqSerial_->sendCommand(&acmd); 
    
    currentCMDID_ = cmdid; 
    pendingCommand_ = true; 

  }
  
}

