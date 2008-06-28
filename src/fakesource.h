#ifndef FAKESOURCE_H
#define FAKESOURCE_H

#include "systemtimer.h"
#include "FastDelegate.h" 
#include "filterio.h"
#include "samplebuffer.hpp"

class FakeSource
{
public:
  FakeSource(SystemTimer * pst); 
  
  static const int BUFSIZE = 128; 

private:
  void updateTime(somatime_t t); 
  somatime_t lasttime_; 
  SystemTimer* pSystemTimer_; 

  SampleRingBuffer<sample_t> buffer_; 

public:
  FilterLinkSource<sample_t> source; 
  sample_t val_; 
}; 


#endif 
