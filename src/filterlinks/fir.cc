#include <filterlinks/fir.h>
#include <filter.h>
#include <filterlinks/delta.h>

FIR::FIR() :
  input(fastdelegate::MakeDelegate(this, &FIR::newSample)),
  buffer_(1), 
  output(&buffer_)
{

  output.samplerate = 0;  // FIXME need to compute from source
  
}


void FIR::newSample(sample_t data)
{
  
  int32_t val = convolve(input.pSampleBuffer_->start(), input.pSampleBuffer_->length(), 
			 input.pSampleBuffer_->head(), filter_, FIRLENMAX); 
  
	   
  // get the connected 
  buffer_.append(val); 
  output.newSample(val); 
  
}

FIR::~FIR()
{


}
