#ifndef ACQDATASOURCECONTROL_H
#define ACQDATASOURCECONTROL_H

#include <eventdispatch.h>
#include <hw/eventtx.h>
#include <acqstatecontrol.h>
#include "acqstatereceiver.h"
class AcqDataSourceControl : public AcqStateReceiver
{
  enum INCMDS {
    QUERY =0x40,
    SET = 0x41,
  }; 

  enum PARAMETERS {
    LINKSTATUS = 0, 
    MODE = 1, 
    CHANGAIN = 2, 
    CHANHPF = 3,
    CHANSEL = 4, 
    RANGE = 5
  };
      
  static const char CMDRESPBCAST = 0x60; 
  
 public:
  AcqDataSourceControl(EventDispatch * ed, EventTX* etx, 
		       AcqStateControl *); 

 private:
  EventTX* pEventTX_; 
  AcqStateControl * pAcqStateControl_; 
  
  void modeChange(char); 
  void linkChange(bool); 
  void commandDone(short, bool); 
  
  EventTX_t bcastEventTX_; 
  
  void query(Event_t * et); 
  void sendLinkStatusEvent(); 
  void sendModeEvent(); 
  void sendChanGainEvent(uint16_t); 
  void sendChanHPFEvent(uint16_t); 
  void sendChanSelEvent(); 

  void setMode(Event_t* et); 

  void setGain(Event_t* et); 
  void setGainDone(uint16_t handle, bool success); 

  void setHPF(Event_t* et); 
  void setHPFDone(uint16_t handle, bool success); 

  void setChanSel(Event_t* et); 
  void setChanSelDone(uint16_t handle, bool success); 
  
  void sendPendingError(Event_t * et); 

  void setstate(Event_t * et);

  void set(Event_t * et); 

  void onLinkChange(bool); 
  void onModeChange(char mode); 
  void onGainChange(chanmask_t * chanmask, int gain); 
  void onHPFChange(chanmask_t *  chanmask, bool enabled); 
  void onInputSelChange(char chan); 
  
  void decodeChanMask(uint16_t cm, chanmask_t *  cmout); 

}; 


#endif // ACQDATASOURCECONTROL_H
