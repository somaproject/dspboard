#ifndef FILTERLINK_FIR_H
#define FILTERLINK_FIR_H

#include <filterio.h>
#include <samplebuffer.hpp>
#include <filterlinks/availablefirs.h>

class FIR : FilterLink
{
  typedef int32_t sample_t; 
  static const short FIRLENMAX = 256; 
 public: 
  FIR(AvailableFIRs* af); 
  ~FIR(); 
  
  FilterLinkSink<sample_t> input; 
  FilterLinkSource<sample_t> output; 
  bool setFilterID(filterid_t); 
  filterid_t getFilterID(); 

 private: 
  SampleRingBuffer<sample_t> buffer_; 
  sample_t * filter_; 
  short filterLen_; 
  filterid_t filterID_; 
  
  void newSample(sample_t); 
  AvailableFIRs* afs; 
}; 

#endif // FILTERLINK_FIR_H
