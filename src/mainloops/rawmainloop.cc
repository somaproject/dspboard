#include "rawmainloop.h"
void RawMainLoop::setup(EventDispatch * ed, EventTX * etx, 
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
  
  pAcqStateControl_->setAcqStateReceiver(pAcqDataSourceControl_); 


  RawSink * pRawSinkA_ = new RawSink(timer_, pDataOut_, pConfig_->getDataSrc(), 0); 
  RawSink * pRawSinkB_ = new RawSink(timer_, pDataOut_, pConfig_->getDataSrc(), 1); 
  RawSink * pRawSinkC_ = new RawSink(timer_, pDataOut_, pConfig_->getDataSrc(), 2); 
  RawSink * pRawSinkD_ = new RawSink(timer_, pDataOut_, pConfig_->getDataSrc(), 3); 

  pAcqDataSource_->sourceA.connect(pRawSinkA_->sink); 
  pAcqDataSource_->sourceB.connect(pRawSinkB_->sink); 
  pAcqDataSource_->sourceC.connect(pRawSinkC_->sink); 
  pAcqDataSource_->sourceD.connect(pRawSinkD_->sink); 


}

void RawMainLoop::runloop()
{
  Benchmark benchmark; 
  benchmark.start(4); 
  pAcqStateControl_->setLinkStatus(pAcqSerial_->checkLinkUp()); 
  if (! pAcqSerial_->checkRxEmpty())
    {
      //*pFIO_FLAG_T = 0x0100;
      eep_->debugdata[0] = acqFrame_.cmdid; 
      eep_->debugdata[1] = pAcqStateControl_->sequentialCMDID_; 
      
      pAcqSerial_->getNextFrame(&acqFrame_); 
      // trigger the set of filterlinks
      benchmark.start(5); 
      //pAcqDataSource_->newAcqFrame(&acqFrame_); 
      benchmark.stop(5); 
      
    }
  benchmark.stop(4); 

}
