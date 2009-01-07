#ifndef DEFAULTMAINLOOP_H
#define DEFAULTMAINLOOP_H

#include "mainloop.h"
#include <systemtimer.h>
#include <echoproc.h>
#include <acqstatecontrol.h>
#include <acqdatasourcecontrol.h>
#include <acqdatasource.h>
#include <sinks/rawsink.h>
#include <dsp.h>

class RawMainLoop : public MainLoop
{
 public:  
  void setup(EventDispatch * ed, EventTX * etx, AcqSerial * as, DataOut *, DSPConfig * ); 
  
  void runloop(); 

 private:
  // pointers to external state
  EventDispatch *  pEventDispatch_; 
  EventTX * pEventTX_; 
  AcqSerial * pAcqSerial_; 
  DataOut * pDataOut_; 
  DSPConfig * pConfig_; 
  // local components
  SystemTimer * timer_; 
  EventEchoProc * eep_;

  AcqFrame acqFrame_; 
  AcqState acqState_; 
  AcqStateControl * pAcqStateControl_; 
  AcqDataSourceControl * pAcqDataSourceControl_; 
  AcqDataSource * pAcqDataSource_; 
  
  RawSink * pRawSinkA_; 
  RawSink * pRawSinkB_; 
  RawSink * pRawSinkC_;  
  RawSink * pRawSinkD_;  
  
}; 


#endif 
