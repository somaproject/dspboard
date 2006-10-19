#ifndef RAWSINK_H
#define RAWSINK_H

#include <systemtimer.h>
#include <filterlinkmanager.h>
#include <dataout.h>
#include <eventout.h>
#include <datasinkbase.h>


class RawSink : public DataSinkBase
{
  static const unsigned char DATATYPE = 3; 
  
 public:
  RawSink(int ID, FilterLinkManager * flm, 
	  SystemTimer * st, DataOutFifo * dof, 
	  EventOutFifo* eof); 
  void sampleProcess(void); 
  void onEvent(const Event&); 
  void newFilterLink(unsigned int type, int channel);   
 private: 
  FilterLinkManager * pFilterLinkManager_; 
  SystemTimer * pSystemTimer_; 
  DataOutFifo * pDataOutFifo_; 
  EventOutFifo * pEventOutFifo_; 
  int ID_; 
  

  FilterLink* fl_; 
  int samplePos_; 
  
  DataOutBuffer* pOutBuffer_; 
  
  void sendBuffer(void); 
  unsigned char datasrc_; 
  
}; 


#endif // RAWSINK_H
