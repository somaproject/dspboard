#include "somastimmainloop.h"
#include <filter.h>

namespace dspboard { 

SomaStimMainLoop::SomaStimMainLoop()
{

}

void SomaStimMainLoop::setup(EventDispatch * ed, EventTX * etx, 
			 AcqSerial * as, 
			 SystemTimer * timer, EventEchoProc * eep, 
			 DataOut * dout, DSPConfig * config)
{
  pEventDispatch_ = ed; 
  pEventTX_ = etx; 
  pAcqSerial_ = as; 
  pDataOut_ = dout; 
  pConfig_ = config; 

  timer_ = timer; 
  eep_ = eep; 

  acqState_.linkUp = false; 
  pAcqStateControl_ = new AcqStateControl(pAcqSerial_, &acqState_); 
  
  pAcqStateControl_->setDSPPos(pConfig_->getDSPPos()); 
  
  pAcqDataSource_ = new AcqDataSource(&acqState_); 
  pAcqDataSource_->setDSP(pConfig_->getDSPPos()); 
  
  pAcqDataSourceControl_ = new AcqDataSourceControl(pEventDispatch_,
							   pEventTX_,
							   pAcqStateControl_);
  


  // audio monitor
  pAudioMonitor_ = new AudioMonitor(pEventDispatch_, pEventTX_, pConfig_); 

  pAcqDataSource_->sourceA.connect(pAudioMonitor_->sink1); 
  pAcqDataSource_->sourceB.connect(pAudioMonitor_->sink2); 
  pAcqDataSource_->sourceC.connect(pAudioMonitor_->sink3); 
  pAcqDataSource_->sourceD.connect(pAudioMonitor_->sink4); 
  pAcqDataSource_->sourceCont.connect(pAudioMonitor_->sinkC); 

  

  pFilterLinkController_ = new FilterLinkController(pEventDispatch_, 
						    pEventTX_, 
						    &availableFIRs); 

  pSpikeFilterA_ = new FIR(&availableFIRs); 
  pSpikeFilterB_ = new FIR(&availableFIRs); 
  pSpikeFilterC_ = new FIR(&availableFIRs); 
  pSpikeFilterD_ = new FIR(&availableFIRs); 

  pWaveFilter_ = new FIR(&availableFIRs); 

  pAcqStateControl_->setAcqStateReceiver(pAcqDataSourceControl_); 

  pTSpikeSink_ = new 
    TSpikeSink(timer_, pDataOut_, pEventDispatch_, pEventTX_, 
	       pFilterLinkController_, pConfig_->getDataSrc());
  
  
  pWaveSink_ = new 
    WaveSink(timer_, pDataOut_, pEventDispatch_, pEventTX_, 
	       pFilterLinkController_, pConfig_->getDataSrc());
  
  pStimSink_ = new StimSink(pEventDispatch_, pEventTX_, pConfig_->getDataSrc()); 
  
  
//   //Create the filter links. 

//   pAcqDataSource_->sourceA.connect(pSpikeFilterA_->input); 
//   pAcqDataSource_->sourceB.connect(pSpikeFilterB_->input); 
//   pAcqDataSource_->sourceC.connect(pSpikeFilterC_->input); 
//   pAcqDataSource_->sourceD.connect(pSpikeFilterD_->input); 
//   pAcqDataSource_->sourceCont.connect(pWaveFilter_->input); 

//  pSpikeFilterA_->output.connect(pTSpikeSink_->sink1); 
//   pSpikeFilterB_->output.connect(pTSpikeSink_->sink2); 
//   pSpikeFilterC_->output.connect(pTSpikeSink_->sink3); 
//   pSpikeFilterD_->output.connect(pTSpikeSink_->sink4); 

  pAcqDataSource_->sourceA.connect(pTSpikeSink_->sink1); 
  pAcqDataSource_->sourceB.connect(pTSpikeSink_->sink2); 
  pAcqDataSource_->sourceC.connect(pTSpikeSink_->sink3); 
  pAcqDataSource_->sourceD.connect(pTSpikeSink_->sink4); 
  pAcqDataSource_->sourceCont.connect(pWaveSink_->sink); 
  pAcqDataSource_->sourceCont.connect(pStimSink_->sink); 

//   // FIXME: wave sink


  pAcqDataSource_->sourceSampleCycle.connect(pTSpikeSink_->samplesink); 
  //  firstpass_ = true; 
  //  loopcnt = 0; 

}

void SomaStimMainLoop::runloop()
{

  // what if we add some linkup hyseresis
  bool linkup = pAcqSerial_->checkLinkUp(); 
  pAcqStateControl_->setLinkStatus(linkup); 
  if (linkup) {
    if (! pAcqSerial_->checkRxEmpty())
      {
	eep_->benchStart(0); 
	pAcqSerial_->getNextFrame(&acqFrame_); 
	pAcqStateControl_->newAcqFrame(&acqFrame_); 
	eep_->benchStop(0); 

	eep_->benchStart(1); 
	pAcqDataSource_->newAcqFrame(&acqFrame_); 
	eep_->benchStop(1); 
      }
  }
}

}
