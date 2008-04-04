#include ACQDATASOURCE_H
#include ACQDATASOURCE_H

#include <acqboardif.h>
#include <dsp.h>

class AcqDataSource
{
public:
  AcqDataSource(AcqState * as); 

  void setDSP(DSP_POSITION dsppos) {
    dsppos_ = dsppos; 
  }
  DSP_POSITION dsppos_; 

  static const int BUFSIZE = 256; 
  static const int ACQBITS = 16;
  static const int ACQBITRANGE = 1 << (16 -1); 
  static const int ACQRANGE = 1 << 31; 


private:
  AcqState * pAcqState_; 
  void newAcqFrame(AcqFrame *); 
  SampleRingBuffer<sample_t> * mainBuffers_[4]; 
  SampleRingBuffer<sample_t> bufferA_; 
  SampleRingBuffer<sample_t> bufferB_; 
  SampleRingBuffer<sample_t> bufferC_; 
  SampleRingBuffer<sample_t> bufferD_; 
  SampleRingBuffer<sample_t> bufferCont_; 
  
  

}; 

#endif // ACQDATASOURCE_H
