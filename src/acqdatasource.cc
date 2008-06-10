#include "acqdatasource.h"


AcqDataSource::AcqDataSource(AcqState * as) :
  pAcqState_(as), 
  bufferA_(BUFSIZE), 
  bufferB_(BUFSIZE), 
  bufferC_(BUFSIZE), 
  bufferD_(BUFSIZE), 
  bufferCont_(BUFSIZE), 
  bufferDummyCycle_(1), 
  sourceA(&bufferA_), 
  sourceB(&bufferB_), 
  sourceC(&bufferC_), 
  sourceD(&bufferD_), 
  sourceCont(&bufferCont_), 
  sourceSampleCycle(&bufferDummyCycle_)
{
  mainBuffers_[0] = &bufferA_; 
  mainBuffers_[1] = &bufferB_; 
  mainBuffers_[2] = &bufferC_; 
  mainBuffers_[3] = &bufferD_; 
  
}

void AcqDataSource::newAcqFrame(AcqFrame * af)
{
  sample_t samps[5]; 
  char sampos = 0; 
  if (dsppos_ == DSPA or dsppos_ == DSPC) {
    sampos = 0;     
  } else {
    sampos = 5; 
  }

  for (int i = 0; i < 5; i++) {
    // use 64-bit numbers for division dynamic range; we then cast to 32-bit 
    int64_t longsamp; 
    if(pAcqState_->gain[i] == 0) {
      longsamp = 0; 
    } else {
      longsamp = ACQRANGE; 
      longsamp = longsamp *  af->samples[i+sampos] ; 
      //longsamp = af->samples[i+sampos] ; 
      longsamp = longsamp / ACQBITRANGE; 
      longsamp = longsamp / pAcqState_->gain[i]; 
      
    }
    samps[i] = longsamp; 
  }

  bufferA_.append(samps[0]); 
  bufferB_.append(samps[1]); 
  bufferC_.append(samps[2]); 
  bufferD_.append(samps[3]); 
  bufferCont_.append(samps[4]); 

  sourceA.newSample(samps[0]); 
  sourceB.newSample(samps[1]); 
  sourceC.newSample(samps[2]); 
  sourceD.newSample(samps[3]); 
  sourceCont.newSample(samps[4]); 

  sourceSampleCycle.newSample(0); 

}


