#ifndef ACQBOARDDATASRC_H
#define ACQBOARDDATASRC_H

#include <datasourcebase.h>

#include <acqboardif.h>

enum ChanSets {CHANSET_A, CHANSET_B}; 
enum PendingOps {SETGAIN, SETHPF}; 

class AcqboardDataSrc : public DataSourceBase
{
  static const int BUFLEN = 256; 
  static const int CHANNUM = 5; 
  static const float ACQV_RANGE= 4.096; 

  
  static const unsigned short ACQGAINS[]; 
  

 public: 
  // constructor:
  AcqboardDataSrc(AcqSerialBase *, ChanSets);

  // overridden functions
  bool readySample(); 

  void sampleProcess();
  int getChanNum(void); 
  SampleBuffer<sample_t> * getChannelBuffer(int i); 
  //void onEvent(const Event &); 
  
  void setGain(int chan, int value); 
  int getGain(int chan); 
  
  void setHPFFilter(int chan, bool state); 
  int getHPFFilter(int chan); 
  
  
 private: 
  AcqSerialBase * pAcqSerial_; 
  SampleRingBuffer<sample_t> * channels_[CHANNUM]; 
  ChanSets cs_; 
  int gains_[CHANNUM]; 
  bool hpfs_[CHANNUM]; 
 
  bool pendingCommand_; 
  char currentCMDID_; 
  PendingOps pendingOp_;
  int pendingChannel_; 
  int pendingValue_; 
  // sendSetGainCMD(int chan, int gainsetting); 
  
  void sendCmd(char cmd, uint32_t data); 

}; 
 

#endif //ACQBOARDDATASRC_H
