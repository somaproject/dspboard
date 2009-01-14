#ifndef FILTERLINKCONTROLLER_H
#define FILTERLINKCONTROLLER_H

#include "filterio.h"
#include "hw/eventtx.h"
#include "eventdispatch.h"

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
  FilterLinkController(EventDispatch * ed, EventTX* etx); 
  
  FilterLink * createFilterLink(); 
  
private:
  EventDispatch * pEventDispatch_; 
  EventTX * pEventTX_; 
  void query(dsp::Event_t* et); 


}; 


#endif // FILTERLINK_CONTROLLER
