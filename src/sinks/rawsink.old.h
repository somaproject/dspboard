#ifndef RAWSINK_H
#define RAWSINK_H

#include <systemtimer.h>
#include <samplebuffer.hpp>
#include <filterio.h>
#include <dataout.h>
#include <hw/memory.h>

class RawData_t : public Data_t {
public:
  RawData_t (unsigned char src) :
  datasrc(src) 
  {
    

  }
  void toBuffer(unsigned char * c) {
    const short len = BUFSIZE * sizeof(uint32_t) + 14; 
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
    //    c = Memcopy::hton_int16(c, chansrc); 
    // c = Memcopy::hton_int32(c, filterid); 

    c = Memcopy::hton_int32array(c, buffer, BUFSIZE); 
  }
  static const short BUFSIZE = 128; 
  int32_t buffer[BUFSIZE]; 
  unsigned char datasrc; 
  unsigned char chansrc; 
  int32_t filterid; 
  somatime_t time; 
  static const char DATATYPE = 2; 

}; 


class RawSink 
{

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
  sample_t pos; 

}; 


#endif // RAWSINK_H
