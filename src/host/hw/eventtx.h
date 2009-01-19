#ifndef EVENTTX_H
#define EVENTTX_H

#include <event.h>
#include <list>

class EventTX
{
public: 
  EventTX(); 
  
  bool newEvent(const  dsp::EventTX_t & evt); 
  bool sendEvent(); 
  void setup(); 
  bool txBufferFull(); 

  char mysrc; 

  std::list<dsp::EventTX_t> eventBuffer_; 
  uint16_t getFIFOFullCount();  // FOR DEBUGGING BUFFER OVERFLOW PROBLEMS
  uint16_t getFPGAFullCount();  

  
}; 


#endif

