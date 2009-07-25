#ifndef DSPBOARD_EVENT_H
#define DSPBOARD_EVENT_H

#include "types.h"

namespace dspboard { 
namespace dsp { 
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
  public: 
    static const int ADDRSIZE = 10; 

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

    inline void setall() {
      for (int i = 0; i < ADDRSIZE; i++) {
	addr[i] = 0xff; 
      }
    }

    inline void set(char pos) {
      char byte = pos >> 3; 
      char os = pos & 0x7; 
      addr[byte] |= (0x01) <<os; 
    }

  }; 
}
}

#endif // EVENT_H
