#ifndef ECHOPROC
#define ECHOPROC

#include <cdefBF533.h>
#include <event.h>
#include <hw/eventtx.h>
#include <hw/eventrx.h>
#include <hw/dspuartconfig.h>
#include <eventdispatch.h>
#include <systemtimer.h>



class EventEchoProc
{
public:
  EventEchoProc(EventDispatch * ed, EventTX* etx, SystemTimer * pst, 
		unsigned char device); 
  void eventTimeRX(Event_t * et); 
  void eventEcho(Event_t * et); 
  void eventLED(Event_t * et); 
  void eventBenchQuery(Event_t * et); 
  void eventDebugQuery(Event_t * et); 
  
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
  static const short NUMBENCH = 4; 
  int latest_[NUMBENCH]; 
  int starttime_[NUMBENCH]; 
  int max_[NUMBENCH]; 


};


#endif // ECHOPROC
