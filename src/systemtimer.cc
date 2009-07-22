#include <systemtimer.h>

namespace dspboard { 

SystemTimer::SystemTimer() :
  time_(0)
{
  for (int i = 0; i < MAXCONN; i++) {
    connectedUpdates_[i] = 0; 
  }
}

SystemTimer::SystemTimer(EventDispatch * ed) :
  time_(0)
{

  for (int i = 0; i < MAXCONN; i++) {
    connectedUpdates_[i] = 0; 
  }
  
  ed->registerCallback(0x10, 
		       fastdelegate::MakeDelegate(this, 
						  &SystemTimer::eventSetTime)); 
  

}

void SystemTimer::eventSetTime(dsp::Event_t * et)
{
  
  if (et->src == EADDR_TIMER ) {
    somatime_t time = et->data[0]; 
    time = (time << 16) | et->data[1]; 
    time = (time << 16) | et->data[2]; 
    setTime(time); 
  }


}
void SystemTimer::setTime(somatime_t t)
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

}
