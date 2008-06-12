#include "acqdatasource.h"
#include "dsp.h"

const int32_t AcqDataSource::GAINS[] = {0, 100, 200, 500, 1000, 
				      2000, 5000, 10000}; 

const int32_t AcqDataSource::GAINSCALE[] = 
  { ACQRANGE / ACQBITRANGE / GAINS[0], 
    ACQRANGE / ACQBITRANGE / GAINS[1], 
    ACQRANGE / ACQBITRANGE / GAINS[2], 
    ACQRANGE / ACQBITRANGE / GAINS[3], 
    ACQRANGE / ACQBITRANGE / GAINS[4], 
    ACQRANGE / ACQBITRANGE / GAINS[5], 
    ACQRANGE / ACQBITRANGE / GAINS[6], 
    ACQRANGE / ACQBITRANGE / GAINS[7]}; 
    

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
    sample_t sample = af->samples[i+sampos]; 
    char gainpos = decodeGain(pAcqState_->gain[i]); 
    int32_t scale = GAINSCALE[gainpos]; 

    samps[i] = 10000000; // FIXME sample * scale;  
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


