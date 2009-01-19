#include "somamainloop.h"

void SomaMainLoop::setup(EventDispatch * ed, EventTX * etx, 
			    AcqSerial * as, DataOut * dout, 
			    DSPConfig * config)
{
  pEventDispatch_ = ed; 
  pEventTX_ = etx; 
  pAcqSerial_ = as; 
  pDataOut_ = dout; 
  pConfig_ = config; 

  timer_ = new SystemTimer(pEventDispatch_); 
  eep_ = new EventEchoProc(pEventDispatch_, pEventTX_, 
			   timer_, pConfig_->getEventDevice()); 

  acqState_.linkUp = false; 
  pAcqStateControl_ = new AcqStateControl(pAcqSerial_, &acqState_); 
  
  pAcqStateControl_->setDSPPos(pConfig_->getDSPPos()); 
  
  pAcqDataSource_ = new AcqDataSource(&acqState_); 
  pAcqDataSource_->setDSP(pConfig_->getDSPPos()); 
  
  pAcqDataSourceControl_ = new AcqDataSourceControl(pEventDispatch_,
							   pEventTX_,
							   pAcqStateControl_);


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
//   pAcqDataSource_->sourceCont.connect(pWaveFilter_->input); 

//   // FIXME: wave sink


  pAcqDataSource_->sourceSampleCycle.connect(pTSpikeSink_->samplesink); 
  
}

void SomaMainLoop::runloop()
{
  eep_->benchStart(0); 
  pAcqStateControl_->setLinkStatus(pAcqSerial_->checkLinkUp()); 
  if (! pAcqSerial_->checkRxEmpty())
    {
      //*pFIO_FLAG_T = 0x0100;
      eep_->debugdata[0] = acqFrame_.cmdid; 
      eep_->debugdata[1] = pAcqStateControl_->sequentialCMDID_; 
      
      pAcqSerial_->getNextFrame(&acqFrame_); 
      pAcqStateControl_->newAcqFrame(&acqFrame_); 
      // trigger the set of filterlinks
      eep_->benchStart(1);
      pAcqDataSource_->newAcqFrame(&acqFrame_); 
      eep_->benchStop(1);
      
    }
  eep_->benchStop(0); 

}
