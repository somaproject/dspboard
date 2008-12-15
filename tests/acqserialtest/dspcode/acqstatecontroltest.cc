#include "acqstatecontroltest.h"
#include <acqstatecontrol.h>

class CallbackFuncs
{
public: 
  CallbackFuncs()  :
    linkUp_(false), 
    linkChangeNum_(0), 
    latestHandle_(0)
  { } 
  bool linkUp_; 
  int linkChangeNum_; 
  void LinkChange(bool lu) {
    linkUp_ = lu; 
    linkChangeNum_++; 
  }
  
  short latestHandle_; 
  bool lastSuccess_; 
  int doneNum_; 
  
  void CommandDone(short handle, bool success) {
    latestHandle_ = handle; 
    lastSuccess_ = success; 
    doneNum_++; 
  }

}; 

void 
acqstatecontroltest1(AcqSerial * acqserial)
{
  /* a test of the acq state control ... 
     we simply try and set the gain on channel 1 to 100 
  
  */ 
  
  AcqFrame af; 
  AcqState acqstate; 
  AcqStateControl asc(acqserial, &acqstate); 

  CallbackFuncs cfs; 


  acqserial->start(); 
  


  int framecount = 0; 
  while(1) {
    asc.setLinkStatus(acqserial->checkLinkUp()); 
    if (! acqserial->checkRxEmpty())
      {
	
	acqserial->getNextFrame(&af); 
	asc.newAcqFrame(&af); 
	
	framecount++; 
	if (framecount %  32000 == 1000) {
	  asc.setGain(1, 100, 
		      fastdelegate::MakeDelegate(&cfs, &CallbackFuncs::CommandDone), 
		      0x1234); 
	}
      }
  }
  
     
  while(1) {


  }

}
