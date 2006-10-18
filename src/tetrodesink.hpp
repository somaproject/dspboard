#ifndef TETRODESINK_H
#define TETRODESINK_H

#include <datasinkbaseh.h>

class TetrodeSink: public DataSink
{
public: 
  TetrodeSink(filterlinkmanager, 
	      eventout, dataout); 
  
  ~TetrodeSink(); 
  
  void sampleProcess(void); 
  void onEvent(const Event& ); 
  
private:

  const int N_ = 100; 
  OutputRingBuffer<sample_t> outbuffers_[4]; 
    
  FilterLink * filterLinks_[4]; 
  
  const unsigned char outputDelayN = 5; 
  uint8_t outputDelays_[outputDelayN]; 
  
  sample_t threshold_[4]; 
  sample_t getThreshold(uint8_t chan); 
  void setThreshold(uint8_t chan, sample_t value); 

  
  uint8_t waveback_; 
  uint8_t wavelen_; 
  uint8_t notrigger_; 
  void setWaveParam(uint8_t waveback, uint8_t wavelen); 

  FilterLinkManager * flm_; 
  void newLink(char chan, int linkType, int inchan);
  uint8_t linkTypes_[4]; 
  uint8_t linkSources_[4]; 


}; 

#endif // TETRODESINK_H
