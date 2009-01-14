#include "acqdatasource.h"
#include "dsp.h"
const int32_t AcqDataSource::GAINS[] = {0, 100, 200, 500, 1000, 
				      2000, 5000, 10000}; 

const int32_t AcqDataSource::GAINSCALE[] = 
  { 0, 
    ACQRANGE / ACQBITRANGE / 100, 
    ACQRANGE / ACQBITRANGE / 200, 
    ACQRANGE / ACQBITRANGE / 500, 
    ACQRANGE / ACQBITRANGE / 1000, 
    ACQRANGE / ACQBITRANGE / 2000, 
    ACQRANGE / ACQBITRANGE / 5000, 
    ACQRANGE / ACQBITRANGE / 10000};
    

AcqDataSource::AcqDataSource(AcqState * as) :
  pAcqState_(as), 
  bufferA_(BUFSIZE), 
  bufferB_(BUFSIZE), 
  bufferC_(BUFSIZE), 
  bufferD_(BUFSIZE), 
  bufferCont_(BUFSIZE), 
  bufferDummyCycle_(1), 
  sourceA(&bufferA_, this), 
  sourceB(&bufferB_, this), 
  sourceC(&bufferC_, this), 
  sourceD(&bufferD_, this), 
  sourceCont(&bufferCont_, this), 
  sourceSampleCycle(&bufferDummyCycle_, this)
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
    samps[i] = sample * scale; 
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


filterid_t AcqDataSource::getFilterID()
{
  return 2; 
}
