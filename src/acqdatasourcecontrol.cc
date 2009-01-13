#include "acqdatasourcecontrol.h"
#include "FastDelegate.h"
#include <iostream>

AcqDataSourceControl::AcqDataSourceControl(EventDispatch * ed, EventTX* etx, 
					   AcqStateControl * as):
  pEventTX_(etx), 
  pAcqStateControl_(as)
{
  
  // prime broadcast event (to save time)
  bcastEventTX_.clear(); 
  bcastEventTX_.setall();   

  ed->registerCallback(QUERY, fastdelegate::MakeDelegate(this,
							 &AcqDataSourceControl::query)); 
  
  
  ed->registerCallback(SET, fastdelegate::MakeDelegate(this,
							 &AcqDataSourceControl::setstate)); 
  
  
}

void AcqDataSourceControl::onModeChange(char mode){
  sendModeEvent(); 
  
}

void AcqDataSourceControl::onLinkChange(bool linkup){
  // tell everyone the link has changed has changed!
  sendLinkStatusEvent(); 
  
}

void AcqDataSourceControl::query(dsp::Event_t * et)
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

void AcqDataSourceControl::setstate(dsp::Event_t * et)
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

  bcastEventTX_.event.data[2] = 0;  
  bcastEventTX_.event.data[3] = pAcqStateControl_->pAcqState_->gain[chan]; 


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


void AcqDataSourceControl::setGain(dsp::Event_t * et)
{
  uint16_t chanmask = et->data[1]; 
  chanmask_t cmout[AcqState::CHANNUM]; 
  decodeChanMask(chanmask, cmout); 

  uint32_t gain = et->data[2];
  gain =  gain << 16; 
  gain |= et->data[3]; 

  bool result = pAcqStateControl_->setGain(cmout, gain); 
					 
  if (!result) {
    sendPendingError(et); 
    return; 
  }
    
}


void AcqDataSourceControl::onGainChange(chanmask_t * chanmask, int gain) {

  for (char i = 0; i < AcqState::CHANNUM; i++) {
    if (chanmask[i]) { 
      sendChanGainEvent(i); 
    } 
  }
}

void AcqDataSourceControl::setHPF(dsp::Event_t * et)
{
  uint16_t chanmask = et->data[1]; 
  chanmask_t cmout[AcqState::CHANNUM]; 
  decodeChanMask(chanmask, cmout); 

  uint16_t hpf = et->data[2];

  bool result = pAcqStateControl_->setHPF(cmout, hpf); 
  
  if (!result) {
    sendPendingError(et); 
    return; 
  }

} 

void AcqDataSourceControl::onHPFChange(chanmask_t * chanmask, bool enabled) 
{
  for (char i = 0; i < AcqState::CHANNUM; i++) {
    if (chanmask[i]) { 
      sendChanHPFEvent(i); 
    }
  } 
}


void AcqDataSourceControl::setChanSel(dsp::Event_t * et)
{
  // FIXME
}

void AcqDataSourceControl::setMode(dsp::Event_t * et)
{
  // no acq state response, just directly set
  uint16_t modeval = et->data[2]; 
  pAcqStateControl_->changeMode(modeval); 
  
} 

void AcqDataSourceControl::sendPendingError(dsp::Event_t * et)
{
  // FIXME 
} 

void AcqDataSourceControl::onInputSelChange(char chan)
{
  //FIXME
}

void  AcqDataSourceControl::decodeChanMask(uint16_t chanmask, chanmask_t * cmout)
{
  for(int i = 0; i < AcqState::CHANNUM; i++) {
    if(chanmask & 0x1) {
      cmout[i] = true; 
    } else {
      cmout[i] = false; 
    }
    chanmask = chanmask >> 1; 
  }
}
