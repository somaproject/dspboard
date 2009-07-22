#ifndef DSPBOARD_MAINLOOP_H
#define DSPBOARD_MAINLOOP_H

#include <eventdispatch.h>
#include <dataout.h>
#include <hw/acqserial.h> 
#include <hw/eventtx.h>
#include <dsp.h>
#include <echoproc.h>
#include <systemtimer.h>

/*
   Defines the architecture-independent parts of a processing loop. 

   Placed in the context of an architecture-specific mainloop runner. 

*/

namespace dspboard { 

class MainLoop 
{
public:
  virtual void setup(EventDispatch * ed, EventTX * etx, AcqSerial * as, 
		     SystemTimer *, EventEchoProc *, 
		     DataOut *, DSPConfig *) = 0; 
  
  virtual void runloop() = 0; 

}; 

}


#endif // MAINLOOP_H
