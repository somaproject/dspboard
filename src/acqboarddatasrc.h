#ifndef ACQBOARDDATASRC_H
#define ACQBOARDDATASRC_H

#include <bf533/acqserial.h>

enum ChanSets {CHANSET_A, CHANSET_B}; 

class AcqboardDataSrc :  DataSourceBase
{
  const int BUFLEN = 256; 
  const int CHANNUM = 5; 
  
  const unsigned short ACQGAINS[] = {0, 100, 200, 500, 
				     1000, 2000, 5000, 10000}; 
  

 public: 
  // constructor:
  AcqboardDataSrc(AcqSerial *, ChanSet);

  // overridden functions
  void sampleProcess();
  int getChanNum(void); 
  sampleBuffer* getChannelBuffer(int i); 
  void onEvent(const Event &); 
  
 private: 
  AcqSerial * pAcqSerial_; 
  SampleRingBuffer<sample_t> * channels_[CHANNUM]; 
  ChanSet cs_; 

}
 

#endif //ACQBOARDDATASRC_H
