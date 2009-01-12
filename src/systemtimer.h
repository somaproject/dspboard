#ifndef SYSTEMTIMER_H
#define SYSTEMTIMER_H

#include <stdint.h>
#include <eventdispatch.h>

#include <FastDelegate.h>

typedef uint64_t somatime_t; 

class SystemTimer
{
  
 public: 
  SystemTimer(); 
  SystemTimer(EventDispatch * ed); 

  typedef fastdelegate::FastDelegate1<somatime_t>  timeUpdateDelegate_t; 
  
  somatime_t getTime(); 
  void setTime(somatime_t); 
  void connect(timeUpdateDelegate_t update); 

 private:

  static const int MAXCONN = 6; 

  void eventSetTime(dsp::Event_t * event); 

  timeUpdateDelegate_t connectedUpdates_[MAXCONN]; 

  somatime_t time_; 
  
  
}; 


#endif // SYSTEMTIMER_H
