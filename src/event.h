#ifndef EVENT_H
#define EVENT_H

#include <types.h>

typedef uint8_t eventsource_t ; 
typedef uint8_t eventcmd_t; 

class Event_t
{
 public: 
  eventcmd_t cmd; 
  eventsource_t src; 
  uint16_t data[5]; 

  inline void clear()
  {
    cmd = 0; 
    src = 0; 
    data[0] = 0; 
    data[1] = 0; 
    data[2] = 0; 
    data[3] = 0; 
    data[4] = 0; 

  }
  
};

class EventTX_t
{
  static const int ADDRSIZE = 10; 
 public: 
  char addr[ADDRSIZE]; 
  Event_t event; 
  
  inline EventTX_t() {
    // constructor to zero
    clear(); 
  }

  inline void clear() {
    for (int i = 0; i < ADDRSIZE; i++) {
      addr[i] = 0; 
    }
    event.clear(); 
  }
  
}; 

#endif // EVENT_H
