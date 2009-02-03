#ifndef ECHOPROC
#define ECHOPROC

#include <event.h>
#include <hw/eventtx.h>
#include <dsp.h>
#include <eventdispatch.h>
#include <systemtimer.h>
#include <benchmark.h>


/*

*/ 
class EventEchoProc
{
  
public:
  EventEchoProc(EventDispatch * ed, EventTX* etx, SystemTimer * pst, 
		Benchmark *  bm, unsigned char device); 
  void eventTimeRX(dsp::Event_t * et); 
  void eventEcho(dsp::Event_t * et); 
  void eventLED(dsp::Event_t * et); 
  void eventMemCheck(dsp::Event_t * et); 
  void eventBenchQuery(dsp::Event_t * et); 
  void eventDebugQuery(dsp::Event_t * et); 
  
  uint16_t debugdata[6]; 
  void benchStart(short counter); 
  void benchStop(short counter); 

  uint16_t erx_errors; 
private:  
  short eventpos; 
  EventTX* petx; 
  short time[3]; 
  short iterations; 
  char device_; 
  SystemTimer* ptimer_; 
  
  uint16_t etx_errors; 

  Benchmark * pBenchmark_; 

};


#endif // ECHOPROC
