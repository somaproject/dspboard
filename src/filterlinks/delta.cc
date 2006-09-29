#include <filterlinks/delta.h>

Delta::Delta(SampleBuffer<sample_t> * sampleBuf)
{
  sampBuf_ = sampleBuf; 
}

sample_t Delta::nextSample(void)
{
  return (*sampBuf_)[0]; 
}

Delta::~Delta()
{

}
