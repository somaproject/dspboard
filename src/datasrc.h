#ifndef DATASRC_H
#define DATASRC_H

class DataSourceBase
{
  void sampleProcess() = 0; 
  bool readySample() = 0; 
  int getChanNum(void) = 0; 
  sampleBuffer* getchannelBuffer(int i) = 0; 
  void onEvent(const Event &); 

}; 

#endif // DATASRC_H
