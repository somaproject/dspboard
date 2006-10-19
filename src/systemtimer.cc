#include <systemtimer.h>

SystemTimer::SystemTimer() :
  time_(0)
{


}

void SystemTimer::setTime(uint64_t t)
{
  time_ = t;
}

uint64_t SystemTimer::getTime() 
{
  return time_; 
}
