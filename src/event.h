#ifndef EVENT_H
#define EVENT_H

class Event
{
 public: 
  uint8_t cmd; 
  uint8_t src; 
  uint16_t data[5]; 
  
};

class EventOut
{
 public: 
  Event event; 
  bool addr[78]; 
}; 

#endif // EVENT_H
