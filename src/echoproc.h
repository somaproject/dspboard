#ifndef DSPBOARD_ECHOPROC
#define DSPBOARD_ECHOPROC

#include <event.h>
#include <hw/eventtx.h>
#include <dsp.h>
#include <eventdispatch.h>
#include <systemtimer.h>
#include <benchmark.h>


/*

*/ 
namespace dspboard { 

extern const uint16_t VERSION_MAJOR;
extern const uint16_t VERSION_MINOR;
extern const char * FIRMWARENAME;
extern const uint64_t GITHASH; 
extern const uint32_t BUILDTIME; 

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
  void eventVersionQuery(dsp::Event_t * et); 

  static const int ECMD_VERSION_QUERY = 0x04; 

  
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
}


#endif // ECHOPROC
