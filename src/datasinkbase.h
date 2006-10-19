#ifndef DATASINKBASE_H
#define DATASINKBASE_H

#include <event.h>

class DataSinkBase
{
  virtual void sampleProcess(void) = 0; 
  virtual void onEvent(const Event&) = 0; 

};

#endif // DATASINKBASE_H

