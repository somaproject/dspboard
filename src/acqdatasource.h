#ifndef ACQDATASOURCE_H
#define ACQDATASOURCE_H

#include <samplebuffer.hpp>
#include <acqboardif.h>
#include <filterio.h>
#include <dsp.h>
#include <types.h>

class AcqDataSource : public FilterLink
{
public:
  AcqDataSource(AcqState * as); 

  void setDSP(DSP_POSITION dsppos) {
    dsppos_ = dsppos; 
  }
  DSP_POSITION dsppos_; 

  static const int BUFSIZE = 256; 
  static const int ACQBITS = 16;
  static const int ACQBITRANGE = 32768;
  static const int ACQRANGE = 2048000000; 
  /*
    Precomputed gain scalings: because the BF533 is slow,
    esp. wrt divison, we precompute the mapping from sample
    to nV for a given gain at startup. 
    
  */
  static const int32_t GAINS[]; 

  static const int32_t GAINSCALE[]; 

  void newAcqFrame(AcqFrame *); 
  filterid_t getFilterID(); 
  bool setFilterID(filterid_t); 

private:
  AcqState * pAcqState_; 
  SampleRingBuffer<sample_t> * mainBuffers_[4]; 
  SampleRingBuffer<sample_t> bufferA_; 
  SampleRingBuffer<sample_t> bufferB_; 
  SampleRingBuffer<sample_t> bufferC_; 
  SampleRingBuffer<sample_t> bufferD_; 
  SampleRingBuffer<sample_t> bufferCont_; 
  SampleRingBuffer<char> bufferDummyCycle_; 
  
public:
  FilterLinkSource<sample_t> sourceA; 
  FilterLinkSource<sample_t> sourceB; 
  FilterLinkSource<sample_t> sourceC; 
  FilterLinkSource<sample_t> sourceD; 

  FilterLinkSource<sample_t> sourceCont; 
  FilterLinkSource<char> sourceSampleCycle; 

}; 




#endif // ACQDATASOURCE_H
