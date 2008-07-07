#ifndef RAWSINK_H
#define RAWSINK_H

#include <systemtimer.h>
#include <samplebuffer.hpp>
#include <filterio.h>
#include <dataout.h>
#include <hw/memory.h>

class RawData_t : public Data_t {
public:
  RawData_t (unsigned char src, unsigned char chansrc) :
    datasrc(src) ,
    chansrc(chansrc)
  {
    

  }
  void toBuffer(unsigned char * c) {
    const short len = BUFSIZE * sizeof(uint32_t) + 4 + (8 + 2 + 4); 
    *c = len >> 8; 
    c++; 
    *c = len & 0xFF; 
    c++; 
    // type
    *c = DATATYPE; 
    c++; 
    // source
    *c = datasrc; 
    // now the data, big-endian-style
    c++; 
    c = Memcopy::hton_int64(c, time); 
    c = Memcopy::hton_int16(c, chansrc); 
    c = Memcopy::hton_int32(c, filterid); 
    
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
  somatime_t time; 
  uint16_t chansrc; 
  uint32_t filterid; 

  static const char DATATYPE = 2; 
  
}; 


class RawSink 
{

 public:
  RawSink(SystemTimer * st, DataOut * dout, unsigned char DataSrc, 
	  unsigned char chansrc); 
  
    
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
  sample_t pos; 

}; 


#endif // RAWSINK_H
