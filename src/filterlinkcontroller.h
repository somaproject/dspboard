#ifndef FILTERLINKCONTROLLER_H
#define FILTERLINKCONTROLLER_H

#include "filterio.h"
#include "hw/eventtx.h"
#include "eventdispatch.h"
#include "filterlinks/availablefirs.h"
/*
  Manage the suite of possible filterlinks. 
  At the moment we only have FIR and delta. 

  Commands include: 
      1. getFilterID
      2. setFilterID
  and then filter configuration information for filter vectors/etc. 
  setCoefficientNforFilter7
  
  
*/ 

class FilterLinkController
{
public:
  FilterLinkController(EventDispatch * ed, EventTX* etx, AvailableFIRs * ); 

  enum FIR_COMMANDS { 
    SET_COEFFICIENT = 0, 
    GET_COEFFICIENT = 1, 
    GET_STATUS = 2, 
    SET_STATUS = 3
  }; 
  
  enum FIR_ECMDS { 
    FIR_CMD = 0x47, 
    FIR_RESP = 0x48
  }; 
  
private:
  // FIR CONTROL

  EventDispatch * pEventDispatch_; 
  EventTX * pEventTX_; 
  AvailableFIRs * pFIRs_; 
  //void query(dsp::Event_t* et); 
  void fir_cmd(dsp::Event_t* et); 
  void fir_send_coefficient(dsp::Event_t * et); 
  void fir_send_status(dsp::Event_t * et); 
  void fir_set_coefficient(dsp::Event_t  * et);
  void fir_set_status(dsp::Event_t * et); 
  void fir_recompute_id(char fir); 

}; 


#endif // FILTERLINK_CONTROLLER
