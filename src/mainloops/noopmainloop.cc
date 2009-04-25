#include "noopmainloop.h"

void NoOpMainLoop::setup(EventDispatch * ed, EventTX * etx, 
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
  
  pAcqDataSource_ = new AcqDataSource(&acqState_); 
  pAcqDataSource_->setDSP(pConfig_->getDSPPos()); 
  
  pAcqDataSourceControl_ = new AcqDataSourceControl(pEventDispatch_,
							   pEventTX_,
							   pAcqStateControl_);
  
  pAcqStateControl_->setAcqStateReceiver(pAcqDataSourceControl_); 

}

void NoOpMainLoop::runloop()
{
  eep_->benchStart(0); 
  bool linkup = pAcqSerial_->checkLinkUp(); 
  pAcqStateControl_->setLinkStatus(linkup); 
  if (linkup) {
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
}
