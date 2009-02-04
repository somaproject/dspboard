#ifndef TSPIKESINK_H
#define TSPIKESINK_H

#include <systemtimer.h>
#include <samplebuffer.hpp>
#include <filterio.h>
#include <dataout.h>
#include <eventdispatch.h>
#include <filterlinkcontroller.h>

#include <hw/eventtx.h>
#include <hw/memory.h>

class TSpikeData_t : public Data_t {
public:

  static const unsigned char PRETRIGGER = 8; 
  static const unsigned char POSTTRIGGER = 24;
  static const unsigned char PENDINGDELAY = 24;  
  static const unsigned char BUFSIZE = 64; 
  
  static const unsigned char CHANNUM = 4; 

  static const uint16_t TSPIKE_DATA_VERSION = 0x0100; 

  int32_t buffer[CHANNUM][BUFSIZE]; 
  
  int32_t threshold[CHANNUM]; 
  filterid_t filterid[CHANNUM]; 
  somatime_t time; 
  short offset; 
  char datasrc; 

  TSpikeData_t (unsigned char src) :
    datasrc(src)
  {
    // zero the relevant data
    for(char chan = 0; chan < CHANNUM; chan++) {
      for (short i = 0; i<BUFSIZE; i++) {
	buffer[chan][i] = 0; 
      }
      threshold[chan] = 0; 
    }
    
    
  }
  
  void toBuffer(unsigned char *c) 
  {
    const short len = 
      CHANNUM * ((POSTTRIGGER + PRETRIGGER) * sizeof(int32_t) + 12) + 
      8 + 4  +  2 +4; 
    *c = len >> 8; 
    c++; 
    *c = len & 0xFF; 
    c++; 
    //type
    *c = TYPE; 
    c++; 
    //source
    *c = datasrc; 
    c++; 
    //chanllen

    c += 2; 
    
    c = Memcopy::hton_int64(c, time); 
    
    // offset points to the last sample, so to figure
    // out where to start sampling from, we need to subtract 
    // total buffer size
    char pos = offset - (POSTTRIGGER + PRETRIGGER) + 1; 
    bool twopass = false; 
    if (pos < 0) {
      twopass = true; 
      pos += BUFSIZE; 
    }
    c = Memcopy::hton_int16(c, TSPIKE_DATA_VERSION); 
    // for each channel
    for (short i = 0; i < CHANNUM; i++) {
      // FIXME incorporate VALID field
      c++;  // VALID FIELD
      c++;
      c++; 
      c++; 
      c = Memcopy::hton_int32(c, filterid[i]); 
      c = Memcopy::hton_int32(c, threshold[i]); 
      
      if (!twopass) {
  	c = Memcopy::hton_int32array(c, &(buffer[i][pos]), 
  				     POSTTRIGGER+PRETRIGGER); 
      } else {

 	c = Memcopy::hton_int32array(c, &(buffer[i][pos]), BUFSIZE - pos); 
 	c = Memcopy::hton_int32array(c, &(buffer[i][0]), offset + 1); 
	//c += 32 * 4; 
      }
    }
    
  }

  static const char TYPE = 0; 


}; 


class TSpikeSink 
{
  static const unsigned char DATATYPE = 0; 
 public:
  TSpikeSink(SystemTimer * st, DataOut * dout, 
	     EventDispatch * ed, EventTX* etx, 
	     FilterLinkController * fl, // At the moment we need this hack 
	     unsigned char DataSrc); 

 private: 
  SystemTimer * pSystemTimer_; 
  DataOut * pDataOut_; 
  EventDispatch * pEventDispatch_; 
  EventTX * pEventTX_; 
public:
  FilterLinkSink<sample_t> sink1; 
  FilterLinkSink<sample_t> sink2; 
  FilterLinkSink<sample_t> sink3; 
  FilterLinkSink<sample_t> sink4; 

  FilterLinkSink<char> samplesink; 

  void setThreshold(char chan, int32_t value); 
  int32_t getThreshold(char chan); 

  enum INCMDS { 
    ECMD_QUERY = 0x43, 
    ECMD_SET = 0x44,   
    ECMD_RESPONSE = 0x13
  }; 

  //  static const char CMDRESPBCAST = 0x45; 

  enum PARAMETERS { 
    THRESHOLD = 1, 
    FILTERID = 2
  }; 

private: 
  void processSample1(sample_t); 
  void processSample2(sample_t); 
  void processSample3(sample_t); 
  void processSample4(sample_t); 

  void processSampleCycle(char); 

  TSpikeData_t pendingTSpikeData_ __attribute__ ((aligned (4))); 
  short pendingPos_  __attribute__ ((aligned (4))); 
  unsigned char dataSource_  __attribute__ ((aligned (4))); 
  
  short pending_  __attribute__ ((aligned (4))); 

  void sendSpike(); 

  // event processing

  
  void query(dsp::Event_t* et); 
  void setstate(dsp::Event_t* et); 
  void sendThresholdResponse(char chan); 
  void sendFilterIDResponse(char chan); 

  dsp::EventTX_t bcastEventTX_  __attribute__ ((aligned (4))); 

}; 


#endif // TSPIKESINK_H
