#ifndef SYSTEMTIMER_H
#define SYSTEMTIMER_H

#include <stdint.h>

class SystemTimer
{
  
 public: 
  SystemTimer(); 
  
  uint64_t getTime(); 
  void setTime(uint64_t); 

 private:
  uint64_t time_; 


}; 


#endif // SYSTEMTIMER_H
