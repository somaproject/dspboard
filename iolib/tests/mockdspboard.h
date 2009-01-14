#ifndef MOCKDSPBOARD_H
#define MOCKDSPBOARD_H

#include <filterio.h>
#include <eventdispatch.h>
#include <systemtimer.h>
#include <acqdatasource.h>
#include <sinks/rawsink.h>
#include <hostdataout.h>
#include <vector>
#include <iostream>
#include <mainloops/rawmainloop.h>
#include <dspfixedconfig.h>
#include <event.h>
#include <somanetwork/eventtx.h>
#include <sigc++/sigc++.h>

class MockDSPBoard; 
void dspboard_run(MockDSPBoard & dspboard, int iters); 

class MockDSPBoard
{
public:
  MockDSPBoard(char dsrc, dsp::eventsource_t esrc); 

  void setEventCallback(sigc::slot<void, somanetwork::Event_t> eventcb); 
  
  char dsrc_; 
  dsp::eventsource_t esrc_; 
  SystemTimer timer; 
  HostDataOut dataout; 
  DSPFixedConfig config; 

  EventDispatch ed; 
  EventTX eventtx; 
  
  AcqSerial acqserial; 
  RawMainLoop mainloop; 

  void runloop(); 
  void sendEvents(const somanetwork::EventTX_t & etx); 

  std::list<dsp::EventTX_t> events; 
  sigc::slot<void, somanetwork::Event_t> eventcb_; 
}; 

#endif // MOCKDSPBOARD_H
