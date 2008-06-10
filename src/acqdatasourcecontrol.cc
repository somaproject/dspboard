#include "acqdatasourcecontrol.h"
#include "FastDelegate.h"

AcqDataSourceControl::AcqDataSourceControl(EventDispatch * ed, EventTX* etx, 
					   AcqStateControl * as):
  pEventTX_(etx), 
  pAcqStateControl_(as), 
  pendinghandle_(false), 
  nexthandle_(0)
{
  
  // prime broadcast event (to save time)
  bcastEventTX_.clear(); 
  bcastEventTX_.setall();   
  
  as->setLinkChangeCallback(fastdelegate::MakeDelegate(this, 
						       &AcqDataSourceControl::linkChange)); 
  as->setModeChangeCallback(fastdelegate::MakeDelegate(this, 
						       &AcqDataSourceControl::modeChange)); 
  
  ed->registerCallback(QUERY, fastdelegate::MakeDelegate(this, 
							 &AcqDataSourceControl::query)); 

  ed->registerCallback(SET, fastdelegate::MakeDelegate(this, 
							 &AcqDataSourceControl::setstate)); 
  
  
}

void AcqDataSourceControl::modeChange(char){
  sendModeEvent(); 
  
}

void AcqDataSourceControl::linkChange(bool linkup){
  // tell everyone the link has changed has changed!
  sendLinkStatusEvent(); 
  
}

void AcqDataSourceControl::query(Event_t * et)
{
  // generic query dispatch
  switch(et->data[0]) {
  case  LINKSTATUS: 
    sendLinkStatusEvent(); 
    break; 
    
  case MODE:
    sendModeEvent(); 
    break; 
    
  case CHANGAIN: 
    sendChanGainEvent(et->data[1]); 
    break; 
    
  case CHANHPF:
    sendChanHPFEvent(et->data[1]); 
    break; 
  case CHANSEL:
    sendChanSelEvent(); 
    break; 
  } 
  
  
}

void AcqDataSourceControl::setstate(Event_t * et)
{
  // generic query dispatch
  switch(et->data[0]) {
  case MODE:
    setMode(et); 
    break; 
    
  case CHANGAIN: 
    setGain(et); 
    break; 
    
  case CHANHPF:
    setHPF(et); 
    break; 
  case CHANSEL:
    setChanSel(et); 
    break; 
  default: 
    break; 
  } 

}

void AcqDataSourceControl::sendLinkStatusEvent()
{

  bcastEventTX_.event.cmd = CMDRESPBCAST; 
  bcastEventTX_.event.src = pEventTX_->mysrc; 

  bcastEventTX_.event.data[0] = LINKSTATUS; 

  if (pAcqStateControl_->pAcqState_->linkUp) {
    bcastEventTX_.event.data[1] = 1;
  } else {
    bcastEventTX_.event.data[1] = 0;
  }
  pEventTX_->newEvent(bcastEventTX_); 

}

void AcqDataSourceControl::sendModeEvent()
{
  bcastEventTX_.event.cmd = CMDRESPBCAST; 
  bcastEventTX_.event.src = pEventTX_->mysrc; 

  bcastEventTX_.event.data[0] = MODE; 

  bcastEventTX_.event.data[1] = pAcqStateControl_->pAcqState_->mode; 

  pEventTX_->newEvent(bcastEventTX_); 

}


void AcqDataSourceControl::sendChanGainEvent(uint16_t chan)
{
  bcastEventTX_.event.cmd = CMDRESPBCAST; 
  bcastEventTX_.event.src = pEventTX_->mysrc; 

  bcastEventTX_.event.data[0] = CHANGAIN; 
  bcastEventTX_.event.data[1] = chan; 
  
  bcastEventTX_.event.data[2] = pAcqStateControl_->pAcqState_->gain[chan]; 
  bcastEventTX_.event.data[3] = 0x1234;

  pEventTX_->newEvent(bcastEventTX_); 



}

void AcqDataSourceControl::sendChanHPFEvent(uint16_t chan)
{

  bcastEventTX_.event.cmd = CMDRESPBCAST; 
  bcastEventTX_.event.src = pEventTX_->mysrc; 

  bcastEventTX_.event.data[0] = CHANHPF; 
  bcastEventTX_.event.data[1] = chan; 
  
  bcastEventTX_.event.data[2] = pAcqStateControl_->pAcqState_->hpfen[chan]; 

  pEventTX_->newEvent(bcastEventTX_); 


}

void AcqDataSourceControl::sendChanSelEvent()
{
  bcastEventTX_.event.cmd = CMDRESPBCAST; 
  bcastEventTX_.event.src = pEventTX_->mysrc; 

  bcastEventTX_.event.data[0] = CHANSEL; 
  bcastEventTX_.event.data[1] = pAcqStateControl_->pAcqState_->inputSel; 

  pEventTX_->newEvent(bcastEventTX_); 


}


void AcqDataSourceControl::setGain(Event_t * et)
{
  
  uint16_t chanmask = et->data[1]; 
  uint32_t gain = et->data[2];

  uint16_t handle = nextHandle(); 
  bool result = pAcqStateControl_->setGain(chanmask, gain, 
					   fastdelegate::MakeDelegate(this, 
								      &AcqDataSourceControl::setGainDone), 
					   handle); 
  if (!result) {
    sendPendingError(et); 
    return; 
  }

  pendingChanMask_ = chanmask; 
    
}


void AcqDataSourceControl::setGainDone(uint16_t handle, bool success){
  char chanmask = pendingChanMask_; 
  
  for (char i = 0; i < 5; i++) {
    if (chanmask & 0x1) { 
      sendChanGainEvent(i); 
    } 
    chanmask = chanmask >> 1; 
  }
  
}

uint16_t AcqDataSourceControl::nextHandle()
{
  nexthandle_++; 
  return nexthandle_; 
}

void AcqDataSourceControl::setHPF(Event_t * et)
{
  uint16_t chanmask = et->data[1]; 
  uint16_t hpf = et->data[2];

  uint16_t handle = nextHandle(); 
  bool result = pAcqStateControl_->setHPF(chanmask, hpf, 
					  fastdelegate::MakeDelegate(this, 
								     &AcqDataSourceControl::setHPFDone), 
					  handle); 
  if (!result) {
    sendPendingError(et); 
    return; 
  }

  pendingChanMask_ = chanmask; 
  
} 

void AcqDataSourceControl::setHPFDone(uint16_t handle, bool success){
  char chanmask = pendingChanMask_; 
  
  for (char i = 0; i < 5; i++) {
    if (chanmask & 0x1) { 
      sendChanHPFEvent(i); 
    } 
    chanmask = chanmask >> 1; 
  }
  
}


void AcqDataSourceControl::setChanSel(Event_t * et)
{
  // FIXME
}

void AcqDataSourceControl::setMode(Event_t * et)
{
  // no acq state response, just directly set
  uint16_t modeval = et->data[2]; 
  pAcqStateControl_->changeMode(modeval); 
  
} 

void AcqDataSourceControl::sendPendingError(Event_t * et)
{
  // FIXME 
} 

