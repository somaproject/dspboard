#include "somamainloop.h"
#include <filter.h>
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
  firstpass_ = true; 
  loopcnt = 0; 
  delay = 10; 

}

void SomaMainLoop::runloop()
{
  if (!firstpass_) {
    eep_->benchStop(3); 
  }
  firstpass_ = false; 
  
  eep_->benchStart(2); 
  pAcqStateControl_->setLinkStatus(pAcqSerial_->checkLinkUp()); 
  eep_->benchStop(2); 

  if (! pAcqSerial_->checkRxEmpty())
    {

      pAcqSerial_->getNextFrame(&acqFrame_); 
      pAcqStateControl_->newAcqFrame(&acqFrame_); 
      // trigger the set of filterlinks
//       eep_->benchStart(1);
//       pAcqDataSource_->newAcqFrame(&acqFrame_); 
//       eep_->benchStop(1);
      eep_->benchStart(0); 

      for(unsigned short i = 0; i < delay; i++) {
	cycles();
      }
      eep_->benchStop(0); 

      if (loopcnt == 14000) {
	delay++;
	loopcnt = 0; 
      } 
      loopcnt++; 
    }

  eep_->benchStart(3); 
}
