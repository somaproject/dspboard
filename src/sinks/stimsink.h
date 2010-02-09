#ifndef DSPBOARD_STIMSINK_H
#define DSPBOARD_STIMSINK_H

#include <systemtimer.h>
#include <samplebuffer.hpp>
#include <filterio.h>
#include <dataout.h>
#include <eventdispatch.h>
#include <filterlinkcontroller.h>
#include <acqstatecontrol.h> 
#include <hw/eventtx.h>
#include <hw/memory.h>

/*
  Extremely simple threshold-crossing-based 

 */ 

namespace dspboard { 


class StimSink
{

 public:
  StimSink(
	   EventDispatch * ed, EventTX* etx, 
	   unsigned char DataSrc); 
  
 private: 
  EventDispatch * pEventDispatch_; 
  EventTX * pEventTX_; 
public:
  FilterLinkSink<sample_t> sink; 

  static  const unsigned char SRC_DIGITAL_OUT = 0x4A; 
  static const unsigned char ECMD_DIGITAL_WRITE = 0x30; 

//   void setThreshold(char chan, int32_t value); 
//   int32_t getThreshold(char chan); 

  enum INCMDS { 
    ECMD_ENABLE = 0x50
  }; 

  //  static const char CMDRESPBCAST = 0x45; 

  void setstate(dsp::Event_t* et); 
private: 
  void processSample(sample_t); 

  unsigned char dataSource_  __attribute__ ((aligned (4))); 
  
  // event processing
  void query(dsp::Event_t* et); 

  dsp::EventTX_t eventTX_  __attribute__ ((aligned (4))); 

  uint8_t chansrc_; 

  bool enabled_; 
  sample_t threshold_; 
  sample_t lastdata_; 


  
}; 
}


#endif // WAVESINK_H
