#ifndef DSPBOARD_AUDIOMONITOR_H
#define DSPBOARD_AUDIOMONITOR_H


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
   We ripped out the old audio monitor hack and replaced
   it with this more robust filter-link-based version. 
   
 */
 
namespace dspboard {
class AudioMonitor 
{
  static const unsigned char AUDIO_OUTPUT_CMD = 0x18; 
  static const unsigned char AUDIO_COMMAND = 0x30; 
  
public:
  AudioMonitor(EventDispatch *, 
	       EventTX * etx,  DSPConfig * ); 

  FilterLinkSink<sample_t> sink1; 
  FilterLinkSink<sample_t> sink2; 
  FilterLinkSink<sample_t> sink3; 
  FilterLinkSink<sample_t> sink4; 
  FilterLinkSink<sample_t> sinkC; 

private:

  EventDispatch * ed_; 
  EventTX * etx_; 

  dsp::EventTX_t bcastEventTX_  __attribute__ ((aligned (4))); 

  void processSample1(sample_t); 
  void processSample2(sample_t); 
  void processSample3(sample_t); 
  void processSample4(sample_t); 
  void processSampleC(sample_t); 
  
  void processSample(sample_t); 
  
  void command(dsp::Event_t* et); 

  bool enabled_; 
  char chansel_; 
  sample_t samples_[4]; 
  char samplepos_; 
  unsigned char volume_;
}; 



}

#endif
