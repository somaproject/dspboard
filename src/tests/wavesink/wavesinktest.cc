#include <boost/test/unit_test.hpp>

#include <boost/test/auto_unit_test.hpp>

#include <filterio.h>
#include <systemtimer.h>
#include <fakesource.h>
#include <sinks/wavesink.h>
#include <hostdataout.h>
#include <hw/eventtx.h>
#include <somanetwork/wave.h>
#include <somanetwork/datapacket.h>
#include <tests/utils/util.h>


BOOST_AUTO_TEST_SUITE(wavesink_test); 

class SourceObject : public FilterLink{
public:
  SampleRingBuffer<int> buf_; 
  FilterLinkSource<int> source; 

  filterid_t getFilterID() {
    return 7; 
  }
  
  bool setFilterID(filterid_t) {
    return true; 
  }
  
  SourceObject() :
    buf_(100), 
    source(&buf_, this)
  {

    
  }
  
  
  void sendSample(int x) {
    source.newSample(x); 
  }
  
}; 

BOOST_AUTO_TEST_CASE(simple_compile_test)
{
  /*
    simply send out test data, at many 
    different downsamp rates

  */
  int DOWNSAMPLEN = 6; 
  uint16_t downsamples[] = {1, 2, 4, 8, 16, 32}; 
  for (int dsi = 0; dsi < DOWNSAMPLEN; dsi++) {
    SourceObject source; 
    SystemTimer timer; 
    timer.setTime(0x123456789A); 
    EventDispatch ed(DSPA); 
    HostDataOut dataout; 
    EventTX etx; 
    AvailableFIRs firs;
    FilterLinkController flc(&ed, &etx, &firs); 
    WaveSink wsink(&timer, &dataout, &ed, &etx, &flc, 17); 
  
    // set the downsample rate, see if we get the response we expect. 
    source.source.connect(wsink.sink); 
  
    // 
    int DSN = downsamples[dsi]; 
    dsp::Event_t e; 
    e.src = 0; 
    e.cmd = 47; 
    e.data[0] = 1; 
    e.data[1] = DSN; 
  
    wsink.setstate(&e); 
    BOOST_CHECK_EQUAL(etx.eventBuffer_.size(), 2); 
    for (int i = 0; i < 128 * DSN; i++) {
      source.sendSample(i); 
    }
  
    BOOST_CHECK_EQUAL(dataout.dataCount_, 1); 
    int offset = 28; 
    int32_t * data = (int32_t*)&(dataout.mostrecentbuffer[offset]); 
    for(int i = 0; i< 128; i++) {
      int32_t hdatum = ntohl(data[i]); 
      BOOST_CHECK_EQUAL(hdatum, i * DSN); 
    }
  }
}


BOOST_AUTO_TEST_CASE(abort_test)
{
  /*
    put in data, and then change the downsample
    ratio, and see if it is aborted
    
  */
  int DOWNSAMPLEN = 6; 
  uint16_t downsamples[] = {1, 2, 4, 8, 16, 32}; 
  for (int dsi = 1; dsi < DOWNSAMPLEN; dsi++) {
    SourceObject source; 
    SystemTimer timer; 
    timer.setTime(0x123456789A); 
    EventDispatch ed(DSPA); 
    HostDataOut dataout; 
    EventTX etx; 
    AvailableFIRs firs;
    FilterLinkController flc(&ed, &etx, &firs); 
    WaveSink wsink(&timer, &dataout, &ed, &etx, &flc, 17); 
  
    // set the downsample rate, see if we get the response we expect. 
    source.source.connect(wsink.sink); 

    int DSN = downsamples[dsi]; 
    int oldds = downsamples[dsi -1]; 

    dsp::Event_t e; 
    e.src = 0; 
    e.cmd = 47; 
    e.data[0] = 1; 
    e.data[1] = oldds; 
  
    wsink.setstate(&e); 

    BOOST_CHECK_EQUAL(etx.eventBuffer_.size(), 2); 

    // This is the data that's going to be thrown away
    for (int i = 0; i < 126 * oldds; i++) {
      source.sendSample(i); 
    }  


    e.src = 0; 
    e.cmd = 47; 
    e.data[0] = 1; 
    e.data[1] = DSN; 
  
    wsink.setstate(&e); 

    // This is the data that's going to be thrown away
    for (int i = 0; i < 128 * DSN; i++) {
      source.sendSample(i); 
    }  

  
    BOOST_CHECK_EQUAL(dataout.dataCount_, 1); 
    int offset = 28; 
    int32_t * data = (int32_t*)&(dataout.mostrecentbuffer[offset]); 
    for(int i = 0; i< 128; i++) {
      int32_t hdatum = ntohl(data[i]); 
      BOOST_CHECK_EQUAL(hdatum, i * DSN); 
    }
  }
}



BOOST_AUTO_TEST_SUITE_END(); 

