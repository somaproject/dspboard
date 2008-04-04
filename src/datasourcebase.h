#ifndef DATASRC_H
#define DATASRC_H

#include <samplebuffer.hpp>
#include <filterlinkbase.h>

template<class sampT, int CHANNUM> 
class DataSourceBase
{
  
 public: 
  DataSourceBase() {
    for (short i = 0; i < N; i++) {
      for (short j = 0; j < MAXLINK; j++) {
	linktgt_[i][MAXLINK] = 0; 
      }
    }
  }

  static const MAXLINK = 4; // max # links per channel. 
  inline int getChanNum(void) { return N}; 
 
  virtual SampleBuffer<sampT> * getChannelBuffer(char i) {
    return pSampleBuffers_[i]; 
  }
  
  SampleBuffer<sampT> * pSampleBuffers_[N]; 

  //virtual void onEvent(const Event &) = 0; 
  void connect(char chan,  char pos, FilterLink<sampT> * fl) {
    linktgt_[chan][pos] = fl; 
  }
  
  
protected:
  FilterLink<sampT> * linktgt[N][MAXLINK]; 

  void dispatchChannel(char chan) {
    for (int i = 0; i < MAXLINK; i++) {
      if (linktgt_[chan][i] != NULL) {
	linktgt_[chan][i].nextSample(); 
      }
    }
  }
  
}; 

#endif // DATASRC_H

