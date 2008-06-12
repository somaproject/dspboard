#ifndef FILTERLINK_FIR_H
#define FILTERLINK_FIR_H

#include <filterio.h>
#include <samplebuffer.hpp>

class FIR
{
  typedef int32_t sample_t; 
  static const short FIRLENMAX = 256; 
 public: 
  FIR(); 
  ~FIR(); 
  FilterLinkSink<sample_t> input; 
  FilterLinkSource<sample_t> output; 
 private: 
  SampleRingBuffer<sample_t> buffer_; 
  sample_t filter_[FIRLENMAX]; 

  void newSample(sample_t); 

}; 

#endif // FILTERLINK_FIR_H
