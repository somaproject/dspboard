#ifndef RAWSINK_H
#define RAWSINK_H

#include <systemtimer.h>
#include <filterlinkmanager.h>
#include <dataoutfifo.h>
#include <eventoutfifo.h>



class RawSink : public DataSinkBase
{
  static const unsigned char DATATYPE = 3; 
  
 public:
  RawSink(int ID, FilterLinkManager * flm, 
	  SystemTimer * st, DataOutFifo * dof, 
	  EventOutFifo* eof); 
  void sampleProcess(void); 
  void onEvent(const Event&); 
  
 private: 
  FilterLinkManager * pFilterLinkManager_; 
  SystemTimer * pSystemTimer_; 
  DataOutFifo * pDataOutFifo_; 
  EventOutFifo * pEventOutFifo_; 
  int ID_; 
  
  void newFilterLink(unsigned int type, int channel); 
  FilterLink* fl_; 
  int samplePos_; 
  
  DataOutBuffer* pOutBuffer_; 
  
  void sendBuffer(void); 
  unsigned char datasrc_ = 0; 
  
}; 


#endif // RAWSINK_H
