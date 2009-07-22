#include "fakerawmainloop.h"

namespace dspboard { 

void FakeRawMainLoop::setup(EventDispatch * ed, EventTX * etx, 
			AcqSerial * as, 
			SystemTimer * timer, EventEchoProc * eep, 
			DataOut * dout, 
			DSPConfig * config) 
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

  pAcqDataSourceControl_ = new AcqDataSourceControl(pEventDispatch_,
							   pEventTX_,
							   pAcqStateControl_);
  
  pAcqStateControl_->setAcqStateReceiver(pAcqDataSourceControl_); 

  pFakeSource_ = new FakeSource(timer_); 

  RawSink * pRawSinkA_ = new RawSink(timer_, pDataOut_, pConfig_->getDataSrc(), 0); 
  RawSink * pRawSinkB_ = new RawSink(timer_, pDataOut_, pConfig_->getDataSrc(), 1); 
  RawSink * pRawSinkC_ = new RawSink(timer_, pDataOut_, pConfig_->getDataSrc(), 2); 
  RawSink * pRawSinkD_ = new RawSink(timer_, pDataOut_, pConfig_->getDataSrc(), 3); 

  pFakeSource_->source.connect(pRawSinkA_->sink); 
  pFakeSource_->source.connect(pRawSinkB_->sink); 
  pFakeSource_->source.connect(pRawSinkC_->sink); 
  pFakeSource_->source.connect(pRawSinkD_->sink); 

}

void FakeRawMainLoop::runloop()
{
  bool linkup = pAcqSerial_->checkLinkUp(); 
  pAcqStateControl_->setLinkStatus(linkup); 
  if (linkup) {
    if (! pAcqSerial_->checkRxEmpty())
      {
	pAcqSerial_->getNextFrame(&acqFrame_); 
	pAcqStateControl_->newAcqFrame(&acqFrame_); 
      }
  }
  
}
}
