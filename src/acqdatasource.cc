#include "acqdatasource.h"


AcqDataSource::AcqDataSource(AcqState * as) :
  pAcqState_(as), 
  bufferX_(BUFSIZE), 
  bufferY_(BUFSIZE), 
  bufferA_(BUFSIZE), 
  bufferB_(BUFSIZE), 
  bufferCont_(BUFSIZE)
{
  mainBuffers[0] = &bufferX_; 
  mainBuffers[1] = &bufferY_; 
  mainBuffers[2] = &bufferA_; 
  mainBuffers[3] = &bufferB_; 
  
}

void AcqDataSource::newAcqFrame(AcqFrame * af)
{
  sample_t samps[5]; 
  char sampos = 0; 
  if (dsppos_ = DSPA or dsppos_ = DSPC) {
    sampos = 0;     
  } else {
    sampos = 5; 
  }

  for (int i = 0; i < 5; i++) {
    // use 64-bit numbers for division dynamic range; we then cast to 32-bit 
    uint64_t longsamp = (ACQRANGE * af->samples[i+sampos])  / pAcqState_->gain[i] / ACQBITRANGE; 
    samps[i] = longsamp; 
  }

  bufferA_.append(samps[0]); 
  bufferB_.append(samps[1]); 
  bufferC_.append(samps[2]); 
  bufferD_.append(samps[3]); 
  bufferCont_.append(samps[4]); 
  bufferA_.newSample(); 
  bufferB_.newSample(); 
  bufferC_.newSample(); 
  bufferD_.newSample(); 
  bufferCont_.newSample(); 

}


