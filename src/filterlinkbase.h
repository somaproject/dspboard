#ifndef FILTERLINKBASE_H
#define FILTERLINKBASE_H

#include <samplebuffer.hpp> 

template <class sampT, int CHANNUM> 
class FilterLink
{
 public:
  virtual void nextSample() = 0; 

  static const MAXLINK = 4; // max # links per channel. 

  inline int getChanNum(void) { return CHANNUM}; 
 
  FilterLink() {
    for (short i = 0; i < N; i++) {
      for (short j = 0; j < MAXLINK; j++) {
	linktgt_[i][MAXLINK] = 0; 
      }
    }
  }

  void connect(char chan,  char pos, DataSink<sampT> * fl) {
    linktgt_[chan][pos] = fl; 
    
  }
  

 protected:
  SampleBuffer<sampT> * getChannelBuffer(char i)
  {
    return pSampleBuffers_[i]; 
  }

  FilterLink<sampT> * linktgt[N][MAXLINK]; 
  
  void dispatchChannel(char chan) {
    for (int i = 0; i < MAXLINK; i++) {
      if (linktgt_[chan][i] != NULL) {
	linktgt_[chan][i].nextSample(); 
      }
    }
  }
  
  
}; 

#endif //FILTERLINKBASE_H

