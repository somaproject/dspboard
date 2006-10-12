#include "acqboarddatasrc.h"

AcqboardDataSrc::AcqboardDataSrc(AcqSerial * as, ChanSet cs) :
  pAcqSerial_(as), 
  cs_(cs)
{
  
  // allocate new ring buffers
  for (int i = 0; i < CHANNUM; i++){
    channels_[i] = new SampleRingBuffer<sample_t>(BUFLEN); 
  }
  
  

} 


AcqboardDataSrc::sampleProcess()
{
  // extract out the frames
  AcqFrame af; 
  pAcqSerial_->getNextFrame( &af ); 
  
  // scale the samples and put them in our buffer
  int chanos = 0; 
  if (cs_ == CHANSET_B ) {
    chanos = 5; 
  }
  for (int i = 0; i < CHANNUM, i++) {
    float fx = ACQV_MAX / gains_[i] / (float(af.samples[chanos + i]) / 2**15); 
    sample_t x = fx * 1000000000; 
  }
  
  // check to see if the date is updated


}

AcqboardDataSrc::getChanNum(void)
{
  return CHANNUM; 
}

AcqboardDataSrc::getChannelBuffer(int i)
{
  return channels_[i]; 
}

AcqboardDataSrc::onEvent(const Event& e)
{

}
