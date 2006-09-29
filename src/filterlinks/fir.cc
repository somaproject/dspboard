#include <filterlinks/FIR.h>
#include <dspmath.h>

FIR::FIR(SampleBuffer<sample_t> * sampleBuf, sample_t * h) : 
  sampBuf_(sampleBuf), 
  ph_(h)
{
  
}

sample_t FIR::nextSample(void)
{
  sample_t y;
  
  
  y = dsp_dot_circbuffer(sampBuf_->start(), sampBuf_->head(), 
			 sampBuf_->N, ph_, sizeof(ph_)); 
  
}

FIR::~FIR()
{

}
