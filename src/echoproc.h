#ifndef ECHOPROC
#define ECHOPROC

#include <event.h>
#include <hw/eventtx.h>
#include <dsp.h>
#include <eventdispatch.h>
#include <systemtimer.h>
#include <benchmark.h>


class EventEchoProc
{
  
public:
  EventEchoProc(EventDispatch * ed, EventTX* etx, SystemTimer * pst, 
		unsigned char device); 
  void eventTimeRX(dsp::Event_t * et); 
  void eventEcho(dsp::Event_t * et); 
  void eventLED(dsp::Event_t * et); 
  void eventMemCheck(dsp::Event_t * et); 
  void eventBenchQuery(dsp::Event_t * et); 
  void eventDebugQuery(dsp::Event_t * et); 
  
  void benchStart(char counter); 
  void benchStop(char counter); 
  uint16_t debugdata[6]; 

private:  
  short eventpos; 
  EventTX* petx; 
  short time[3]; 
  short iterations; 
  char device_; 
  SystemTimer* ptimer_; 

  // benchmarking / performance
  
  uint16_t etx_errors; 
  Benchmark benchmark_; 
};


#endif // ECHOPROC
