#ifndef WAVESINK_H
#define WAVESINK_H

#include <systemtimer.h>
#include <samplebuffer.hpp>
#include <filterio.h>
#include <dataout.h>
#include <eventdispatch.h>
#include <filterlinkcontroller.h>
#include <acqstatecontrol.h> 
#include <hw/eventtx.h>
#include <hw/memory.h>

/*
  Notes: 
  1. need to be notified when the link goes down so buffers can be flushed
  2. need to be notified when the source changes so that buffers can be flushed
  3. FIXME: Should also do this for tspikes

 */ 
class WaveData_t : public Data_t {
public:

  static const unsigned char BUFSIZE = 128; 
  
  static const uint16_t WAVE_DATA_VERSION = 0x0100; 

  int32_t data[BUFSIZE]; 
  
  uint32_t sampratenum; 
  uint32_t samprateden; 
  filterid_t filterid; 
  somatime_t time; 
  char datasrc; 
  uint16_t chansrc; 

  WaveData_t (unsigned char src) :
    datasrc(src)
  {
    // zero the relevant data
    for (short i = 0; i<BUFSIZE; i++) {
      data[i]  = 0; 
    }
    filterid = 0; 
    sampratenum = 0; 
    samprateden = 0; 
  }
  
  void toBuffer(unsigned char *c) 
  {
    const short len =  BUFSIZE * sizeof(int32_t)  + 
      2 + 8 + 2 + 4 + 4 + 4 + 2; 
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
    
    c = Memcopy::hton_int64(c, time); 
    c = Memcopy::hton_int16(c, WAVE_DATA_VERSION); 
    c = Memcopy::hton_int32(c, sampratenum); 
    c = Memcopy::hton_int32(c, samprateden); 
    c = Memcopy::hton_int32(c, filterid); 
    c = Memcopy::hton_int16(c, chansrc); 

    c = Memcopy::hton_int32array(c, data, 128); 
    
  }

  static const char TYPE = 1; 


}; 


class WaveSink 
{
  static const unsigned char DATATYPE = 1; 
  static const unsigned int ACQRATE = 32000; 
  
 public:
  WaveSink(SystemTimer * st, DataOut * dout, 
	   EventDispatch * ed, EventTX* etx, 
	   FilterLinkController * fl, // At the moment we need this hack 
	   unsigned char DataSrc); 
  
 private: 
  SystemTimer * pSystemTimer_; 
  DataOut * pDataOut_; 
  EventDispatch * pEventDispatch_; 
  EventTX * pEventTX_; 
public:
  FilterLinkSink<sample_t> sink; 

//   void setThreshold(char chan, int32_t value); 
//   int32_t getThreshold(char chan); 

  enum INCMDS { 
    ECMD_QUERY = 0x46, 
    ECMD_SET = 0x47,   
    ECMD_RESPONSE = 0x14
  }; 

  //  static const char CMDRESPBCAST = 0x45; 

  enum PARAMETERS { 
    DOWNSAMPFACTOR = 1, 
    SAMPRATE = 2, // READ_ONLY
    FILTERID = 3
  }; 
  
  enum ERRORS { 
    ERROR_INVALID_DOWNSAMPLE = 1, 
    ERROR_INVALID_FILTER_ID = 2
  }; 
  static const uint16_t valid_downsample_N[]; 
  static const uint32_t samprates_num[];
  static const uint32_t samprates_den[]; 

  void setstate(dsp::Event_t* et); 
private: 
  void processSample(sample_t); 

  WaveData_t pendingWaveData_ __attribute__ ((aligned (4))); 
  short bufferPos_  __attribute__ ((aligned (4))); 
  unsigned char dataSource_  __attribute__ ((aligned (4))); 
  
  void sendWave(); 

  // event processing
  void query(dsp::Event_t* et); 


  void sendDownSampleResponse(); 
  void sendSampleRateResponse(); 
  void sendFilterIDResponse(); 

  void sendError(dsp::Event_t * et, ERRORS); 
  void abortCurrentPacket(); 

  AcqStateControl * acqStateControl_; 

  dsp::EventTX_t bcastEventTX_  __attribute__ ((aligned (4))); 

  uint32_t downSampleN_; 
  uint16_t downsamplepos_; 
  uint32_t sampRateNumerator_; 
  uint32_t sampRateDenominator_;
  somatime_t bufferStartTime_; 
  bool isValidDownsample_; 
  uint8_t chansrc_; 
}; 


#endif // WAVESINK_H
