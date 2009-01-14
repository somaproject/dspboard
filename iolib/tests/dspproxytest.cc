
#include "mockdspboard.h"

MockDSPBoard::MockDSPBoard(datasource_t dsrc, eventsource_t esrc) :
  dsrc_(dsrc), 
  esrc_(esrc), 
  timer(), 
  dataout(), 
  config(DSPA, dsrc_, esrc_), 
  ed(config.getDSPPos()), 
  eventtx(), 
  acqserial(false), 
  mainloop()
  //  sp(dsrc_, sigc::mem_fun(*this, &MockDSPBoard::sendEvents)))
{
  timer.setTime(0); 
  acqserial.linkUpState = true; 
  mainloop.setup(&ed, &eventtx, &acqserial, &dataout, &config); 
  
}

void MockDSPBoard::sendEvents(const EventTX_t & etx)
{
  // send the actual event to the mock DSP


}
