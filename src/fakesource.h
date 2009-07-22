#ifndef DSPBOARD_FAKESOURCE_H
#define DSPBOARD_FAKESOURCE_H

#include "systemtimer.h"
#include "FastDelegate.h" 
#include "filterio.h"
#include "samplebuffer.hpp"

namespace dspboard { 

class FakeSource : public FilterLink
{
public:
  FakeSource(SystemTimer * pst); 
  
  static const int BUFSIZE = 128; 
  filterid_t getFilterID() {
    return 1712;
  }

  bool setFilterID(filterid_t) {
    return true; 
  }

private:
  void updateTime(somatime_t t); 
  somatime_t lasttime_; 
  SystemTimer* pSystemTimer_; 

  SampleRingBuffer<sample_t> buffer_; 

public:
  FilterLinkSource<sample_t> source; 
  sample_t val_; 
}; 

}

#endif 
