#ifndef FILTERLINK_DELTA_H
#define FILTERLINK_DELTA_H

#include <filterio.h>
#include <samplebuffer.hpp>
#include <types.h>

class Delta 
{
  typedef int32_t sample_t; 
 public: 
  Delta(); 
  ~Delta(); 
  FilterLinkSink<sample_t> input; 
  FilterLinkSource<sample_t> output; 
 private: 
  SampleRingBuffer<sample_t> buffer_; 
  void newSample(sample_t); 
}; 

#endif // FILTERLINK_DELTA_H
