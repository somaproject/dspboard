#ifndef DSPBOARD_ACQSTATERECEIVER_H
#define DSPBOARD_ACQSTATERECEIVER_H

/*
  A set of interfaces that receive state updates. 

*/ 

#include "acqstatecontrol.h"

namespace dspboard { 

class AcqStateReceiver {
public:
  virtual void onLinkChange(bool) = 0; 
  virtual void onModeChange(char mode) = 0; 
  virtual void onGainChange(chanmask_t * chanmask, int gain) = 0; 
  virtual void onHPFChange(chanmask_t * chanmask, bool enabled) = 0; 
  virtual void onInputSelChange(char chan) = 0; 
}; 

}

#endif // ACQSTATERECEIVER_H
