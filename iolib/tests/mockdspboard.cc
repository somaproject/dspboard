
#include "mockdspboard.h"
#include <vector>
#include <list>
#include "eventutil.h" 


void dspboard_run(MockDSPBoard & dspboard, int iters) {
  for (int i = 0; i < iters; i++) {
    dspboard.runloop(); 
  }

}

MockDSPBoard::MockDSPBoard(char dsrc, dsp::eventsource_t esrc):
  dsrc_(dsrc), 
  esrc_(esrc), 
  timer(), 
  dataout(), 
  config(DSPA, dsrc_, esrc_), 
  ed(config.getDSPPos()), 
  eventtx(), 
  acqserial(true), 
  mainloop()
  //  sp(dsrc_, sigc::mem_fun(*this, &MockDSPBoard::sendEvents)))
{
  timer.setTime(0); 
  mainloop.setup(&ed, &eventtx, &acqserial, &dataout, &config); 
  acqserial.linkUpState_ = true; 
  
}

void MockDSPBoard::setEventCallback(sigc::slot<void, somanetwork::Event_t> eventcb)
{
  eventcb_ = eventcb; 
}

void MockDSPBoard::sendEvents(const somanetwork::EventTX_t & etx)
{

  // convert from network EventTX to dsp EventTX
  dsp::Event_t detx; 
  detx.cmd = etx.event.cmd; 
  detx.src = etx.event.src; 
  for(int i = 0; i < 5; i++) {
    detx.data[i]= etx.event.data[i]; 
  }

  // send the actual event to the mock DSP
  std::vector<bool> amask, bmask, cmask, dmask; 
  std::vector<dsp::Event_t> events; 
  for (int i = 0; i < 80; i++) {
    amask.push_back(false); 
    bmask.push_back(false); 
    cmask.push_back(false); 
    dmask.push_back(false); 
    events.push_back(dsp::Event_t()); 
  }
  amask[2] = true; 
  events[2] = detx; 
  uint16_t * buf = createEventBuffer(amask, bmask, cmask, dmask, events); 
  ed.parseECycleBuffer(buf); 
  //delete[] buf; fIXME WE SHOULD DELETE THESE AT SOME POINT

}

void MockDSPBoard::runloop()
{
  mainloop.runloop(); 
  if (eventtx.eventBuffer_.size() > 0) {
    // convert 
    dsp::EventTX_t et = eventtx.eventBuffer_.front(); 
    
    somanetwork::Event_t sn_etx; 
    sn_etx.cmd = et.event.cmd; 
    sn_etx.src = et.event.src; 
    for (int i = 0; i < 5; i++) {
      sn_etx.data[i] = et.event.data[i];
    }
    //std::cout << "Event cmd=" << (int)sn_etx.cmd << std::endl; 
    eventcb_(sn_etx); 
    eventtx.eventBuffer_.pop_front(); 
    
  }
  for (int i = 0; i < 10; i++) {
    ed.dispatchEvents(); 
  }
}
