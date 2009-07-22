#ifndef DSPBOARD_FILTERLINK_DELTA_H
#define DSPBOARD_FILTERLINK_DELTA_H

#include <filterio.h>
#include <samplebuffer.hpp>
#include <types.h>

namespace dspboard { 

class Delta : FilterLink
{
  typedef int32_t sample_t; 
 public: 
  Delta(); 
  ~Delta(); 
  FilterLinkSink<sample_t> input; 
  FilterLinkSource<sample_t> output; 
  filterid_t getFilterID(); 
  bool setFilterID(filterid_t ); 
  
 private: 
  SampleRingBuffer<sample_t> buffer_; 
  void newSample(sample_t); 
}; 

}


#endif // FILTERLINK_DELTA_H
