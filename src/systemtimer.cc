#include <systemtimer.h>

SystemTimer::SystemTimer() :
  time_(0)
{
  for (int i = 0; i < MAXCONN; i++) {
    connectedUpdates_[i] = 0; 
  }
}


void SystemTimer::setTime(uint64_t t)
{
  time_ = t;
  for (char i = 0; i < MAXCONN; i++) {
    if (connectedUpdates_[i] != 0) {
      connectedUpdates_[i](t); 
    }
  }
  
}

uint64_t SystemTimer::getTime() 
{
  return time_; 
}

void SystemTimer::connect(timeUpdateDelegate_t update) {
  for (char i = 0; i < MAXCONN; i++) {
    if (connectedUpdates_[i] == 0) {
      connectedUpdates_[i] = update; 
	break; 
    }
  }
  
}

