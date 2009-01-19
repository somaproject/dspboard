#ifndef SOMAMAINLOOP_H
#define SOMAMAINLOOP_H

#include "mainloop.h"
#include <systemtimer.h>
#include <echoproc.h>
#include <acqstatecontrol.h>
#include <acqdatasourcecontrol.h>
#include <acqdatasource.h>
#include <sinks/tspikesink.h>
#include <dsp.h>
#include <filterlinks/availablefirs.h>
#include <filterlinkcontroller.h>

#include <filterlinks/fir.h>

//making this static
static AvailableFIRs availableFIRs; 

class SomaMainLoop : public MainLoop
{
 public:  
  void setup(EventDispatch * ed, EventTX * etx, AcqSerial * as, DataOut *, DSPConfig * ); 
  
  void runloop(); 

  // The following are only public for debugging
  // and testing

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
  FilterLinkController * pFilterLinkController_; 
  AvailableFIRs * pAvailableFIRs_; 

  TSpikeSink * pTSpikeSink_; 
  
  FIR * pSpikeFilterA_; 
  FIR * pSpikeFilterB_; 
  FIR * pSpikeFilterC_; 
  FIR * pSpikeFilterD_; 

  FIR * pWaveFilter_; 
  
}; 


#endif 
