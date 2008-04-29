#ifndef RAWSINK_H
#define RAWSINK_H

#include <systemtimer.h>
#include <samplebuffer.hpp>
#include <filterio.h>
#include <dataout.h>

class RawData_t : public Data_t {
public:
  RawData_t (unsigned char src) :
  datasrc(src) 
  {


  }
  void toBuffer(unsigned char * c) {
    const short len = BUFSIZE * sizeof(uint32_t) + 2; 
    *c = len >> 8; 
    c++; 
    *c = len & 0xFF; 
    c++; 
    // type
    *c = TYPE; 
    c++; 
    // source
    *c = datasrc; 
    // now the data, big-endian-style
    c++; 

    for (short i = 0; i < BUFSIZE; i++) {
      sample_t buf =  buffer[i]; 
      *(c+3) = buf & 0xFF; 
      buf = buf >> 8; 
      *(c+2) = buf & 0xFF; 
      buf = buf >> 8; 
      *(c+1) = buf & 0xFF; 
      buf = buf >> 8; 
      *c = buf & 0xFF; 
      c += 4; 
    }
  }
  static const short BUFSIZE = 128; 
  uint32_t buffer[BUFSIZE]; 
  unsigned char datasrc; 
  static const char TYPE = 2; 

}; 


class RawSink 
{
  static const unsigned char DATATYPE = 3; 
  
 public:
  RawSink(SystemTimer * st, DataOut * dout, unsigned char DataSrc); 
  
    
 private: 
  SystemTimer * pSystemTimer_; 
  DataOut * pDataOut_; 
public:
  FilterLinkSink<sample_t> sink; 
private:

  void processSample(sample_t); 
  RawData_t pendingRawData_; 
  short pendingPos_; 
  unsigned char dataSource_; 
  
}; 


#endif // RAWSINK_H
