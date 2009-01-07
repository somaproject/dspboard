#ifndef EVENTTX_H
#define EVENTTX_H

#include <event.h>
#include <list>

class EventTX
{
public: 
  EventTX(); 
  
  void newEvent(const EventTX_t & evt); 
  bool sendEvent(); 
  void setup(); 
  bool txBufferFull(); 

  char mysrc; 

  std::list<EventTX_t> eventBuffer_; 
  
}; 


#endif

