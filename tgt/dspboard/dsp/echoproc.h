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
  
private:  
  short eventpos; 
  EventTX* petx; 
  short time[3]; 
  short iterations; 
  char device_; 
  SystemTimer* ptimer_; 

};


#endif // ECHOPROC
