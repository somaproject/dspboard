#ifndef ACQDATASOURCECONTROL_H
#define ACQDATASOURCECONTROL_H

#include <eventdispatch.h>
#include <hw/eventtx.h>
#include <acqstatecontrol.h>

class AcqDataSourceControl
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
    CHANSEL = 4
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

  char pendingChanMask_; 
  uint16_t nextHandle(); 
  void set(Event_t * et); 
  bool pendinghandle_; 
  uint16_t nexthandle_; 

}; 


#endif // ACQDATASOURCECONTROL_H
