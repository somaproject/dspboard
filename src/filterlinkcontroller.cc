#include "filterlinkcontroller.h"
#include "event.h"

namespace dspboard { 
FilterLinkController::FilterLinkController(EventDispatch * ed, EventTX* etx, 
					   AvailableFIRs * firs) :
  pEventDispatch_(ed), 
  pEventTX_(etx), 
  pFIRs_(firs)
{
  ed->registerCallback(FIR_CMD, fastdelegate::MakeDelegate(this,
							 &FilterLinkController::fir_cmd)); 
  
  
}


void FilterLinkController::fir_cmd(dsp::Event_t* et)
{
  FIR_COMMANDS cmd = (FIR_COMMANDS)et->data[0]; 

  char fir_num = et->data[1]; 
  switch (cmd) {

  case SET_COEFFICIENT : 
    {
      fir_set_coefficient(et); 
      break; 
    }

  case GET_COEFFICIENT : 
    {
      fir_send_coefficient(et); 
      break; 
    }
    
  case GET_STATUS : 
    {
      fir_send_status(et); 
      break; 
    }

  case SET_STATUS : 
    {
      fir_set_status(et); 
      break; 
    }

  default: 
    {
      // send_error(); FIXME 
    }
  }

}

void FilterLinkController::fir_send_coefficient(dsp::Event_t * et)
{
  char firnum  = et->data[1]; 
  uint16_t coeffnum = et->data[2]; 

  if(coeffnum < AvailableFIRs::MAXFILTERLEN) 
    {
      sample_t coefficient = pFIRs_->filters[firnum][coeffnum]; 
      dsp::EventTX_t etx; 
      etx.set(et->src); 
      etx.event.cmd = FIR_RESP; 
      etx.event.data[0] = GET_COEFFICIENT; 
      etx.event.data[1] = firnum; 
      etx.event.data[2] = coeffnum; 
      etx.event.data[3] = coefficient >> 16; 
      etx.event.data[4] = coefficient & 0xFFFF; 
      pEventTX_->newEvent(etx); 
    } else {
      
      // send_error(); FIXME
    }
}

void FilterLinkController::fir_set_coefficient(dsp::Event_t * et)
{
  char firnum  = et->data[1]; 
  uint16_t coeffnum = et->data[2]; 
  if(coeffnum < AvailableFIRs::MAXFILTERLEN) 
    {
      
      
      sample_t coefficient = et->data[3]; 
      coefficient = coefficient << 16; 
      coefficient = coefficient | et->data[4]; 
      pFIRs_->filters[firnum][coeffnum] = coefficient; 

    } else {
      
      // send_error(); FIXME
    }
}


void FilterLinkController::fir_send_status(dsp::Event_t * et)
{
  char firnum = et->data[1]; 
  if (firnum >= AvailableFIRs::FILTERNUM) {
    // send_error FIXME
  }

  dsp::EventTX_t etx; 
  etx.set(et->src); 
  etx.event.cmd = FIR_RESP; 
  etx.event.data[0] = GET_STATUS; 
  etx.event.data[1] = firnum; 
  etx.event.data[2] = pFIRs_->filterlens[firnum]; 
  if (pFIRs_->filterset[firnum]) {
    filterid_t fid = pFIRs_->filterids[firnum]; 
    etx.event.data[3] = fid >> 16; 
    etx.event.data[4] = fid & 0xFFFF; 
  }  else {
    etx.event.data[3] = 0; 
    etx.event.data[4] = 0; 
  }
  pEventTX_->newEvent(etx); 

}
  
void FilterLinkController::fir_set_status(dsp::Event_t * et)
{
  char firnum = et->data[1]; 
  char firen = et->data[2]; 
  uint16_t firlen = et->data[3]; 
  if (firnum > AvailableFIRs::FILTERNUM) {
    // send_error FIXME
  }
  pFIRs_->filterlens[firnum] = firlen; 
  pFIRs_->filterset[firnum] = firen; 
  if (firen) {
    fir_recompute_id(firnum); 
  }
  
  

}

void FilterLinkController::fir_recompute_id(char firnum)
{
  filterid_t fid = 0; 
  for (unsigned char i = 0; i < pFIRs_->filterlens[firnum]; i++) {
    fid  ^= pFIRs_->filters[firnum][i]; 
  }
  pFIRs_->filterids[firnum] = fid; 

}

}
