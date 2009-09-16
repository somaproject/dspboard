#ifndef DSPBOARD_SOMAMAINLOOP_H
#define DSPBOARD_SOMAMAINLOOP_H

#include "mainloop.h"
#include <systemtimer.h>
#include <echoproc.h>
#include <acqstatecontrol.h>
#include <acqdatasourcecontrol.h>
#include <acqdatasource.h>
#include <sinks/tspikesink.h>
#include <sinks/wavesink.h>
#include <dsp.h>
#include <filterlinks/availablefirs.h>
#include <filterlinkcontroller.h>

#include <filterlinks/fir.h>
#include <audiomon.h>

//making this static

namespace dspboard { 

static AvailableFIRs availableFIRs; 

class SomaMainLoop : public MainLoop
{
 public:  
  SomaMainLoop(); 

  void setup(EventDispatch * ed, EventTX * etx, AcqSerial * as, 
	     SystemTimer * timer, EventEchoProc * eep, 
	     DataOut *, DSPConfig * ); 
  
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

  AcqFrame acqFrame_ __attribute__ ((aligned (4))); 
  AcqState acqState_ __attribute__ ((aligned (4))); 
  AcqStateControl * pAcqStateControl_; 
  AcqDataSourceControl * pAcqDataSourceControl_; 
  AcqDataSource * pAcqDataSource_; 
  AudioMonitor * pAudioMonitor_; 
  FilterLinkController * pFilterLinkController_; 
  AvailableFIRs * pAvailableFIRs_; 

  TSpikeSink * pTSpikeSink_; 
  WaveSink * pWaveSink_; 
  
  FIR * pSpikeFilterA_; 
  FIR * pSpikeFilterB_; 
  FIR * pSpikeFilterC_; 
  FIR * pSpikeFilterD_; 

  FIR * pWaveFilter_; 
  
}; 
}

#endif 
