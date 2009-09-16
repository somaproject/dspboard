#include <boost/test/unit_test.hpp>

#include <boost/test/auto_unit_test.hpp>

#include <filterio.h>
#include <systemtimer.h>
#include <fakesource.h>
#include <audiomon.h>
#include <hostdataout.h>
#include <hw/eventtx.h>
#include <somanetwork/wave.h>
#include <somanetwork/datapacket.h>
#include <tests/utils/util.h>
#include <event.h>


BOOST_AUTO_TEST_SUITE(audiomon_test); 
using namespace dspboard; 

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


uint16_t * createEventBuffer(std::vector<bool> amask, std::vector<bool> bmask, 
			     std::vector<bool> cmask, std::vector<bool> dmask, 
			     std::vector<dsp::Event_t> events)
{
  /* A helper function that creates a buffer and copies the relevant
     events into it for debugging
     
  */ 
  uint16_t * buffer = new uint16_t[512]; 
  for (int i = 0; i < 512; i++) 
    buffer[i] = 0; 

  buffer[0] = 0xBC00; 

  // A MASK

  for(int i = 0; i < 5; i++) {
    uint8_t byteh = 0; 
    uint8_t bytel = 0; 
    for (int j = 0; j < 8; j++) {
      if(amask[i * 16 + j]) {
	byteh |= (1 << j); 
      }
      
      if(amask[i * 16 + j + 8]) {
	bytel |= (1 << j); 
      }
    }
    
    buffer[i + 1] = (byteh << 8) | bytel; 
  }

  // B MASK

  for(int i = 0; i < 5; i++) {
    uint8_t byteh = 0; 
    uint8_t bytel = 0; 
    for (int j = 0; j < 8; j++) {
      if(bmask[i * 16 + j]) {
	byteh |= (1 << j); 
      }
      
      if(bmask[i * 16 + j + 8]) {
	bytel |= (1 << j); 
      }
    }
    
    buffer[i + 6] |= byteh; 
    buffer[i + 7] |= (bytel << 8); 
  }

  // C MASK

  for(int i = 0; i < 5; i++) {
    uint8_t byteh = 0; 
    uint8_t bytel = 0; 
    for (int j = 0; j < 8; j++) {
      if(cmask[i * 16 + j]) {
	byteh |= (1 << j); 
      }
      
      if(cmask[i * 16 + j + 8]) {
	bytel |= (1 << j); 
      }
    }
    buffer[i + 1 + 5 + 5 + 1] = (byteh << 8) | bytel; 
    

  }

  // D MASK

  for(int i = 0; i < 5; i++) {
    uint8_t byteh = 0; 
    uint8_t bytel = 0; 
    for (int j = 0; j < 8; j++) {
      if(dmask[i * 16 + j]) {
	byteh |= (1 << j); 
      }
      
      if(dmask[i * 16 + j + 8]) {
	bytel |= (1 << j); 
      }
    }
    
    buffer[i + 17] |= byteh; 
    buffer[i + 18] |= (bytel << 8); 
  }

  int bpos = 24; 
  for (std::vector<dsp::Event_t>::iterator i = events.begin(); i!= events.end(); i++)
    {
      uint16_t newcmd = (*i).cmd; 
      
      buffer[bpos] = (newcmd << 8 )| (*i).src; 
      bpos++; 
      for (int j = 0; j < 5; j++) {
	buffer[bpos] = (*i).data[j]; 
	bpos++; 
      }
    }
  return buffer; 

}
		       

BOOST_AUTO_TEST_CASE(simple_compile_test)
{
  /*
    Put in some data, and see if we get output events
  */
  SourceObject source1; 
  SourceObject source4; 
  EventDispatch ed(DSPA); 
  EventTX etx; 
  AudioMonitor mon(&ed, &etx); 
  
  source1.source.connect(mon.sink1); 
  source4.source.connect(mon.sink4); 
  
  for (int i = 0; i < 128 ; i++) {
    source1.sendSample(i); 
    source4.sendSample(i);  
 }
  
  std::vector<dsp::Event_t> evts; 
  std::vector<bool> en; 
  evts.push_back(dsp::Event_t()); 
  
  en.push_back(true); 
  evts[0].src = 10; 
  evts[0].cmd = 0x30;
  evts[0].data[0] = 1; 
  evts[0].data[1] = 1; // turn on
  evts[0].data[2] = 3; // enable channel A.4

  
  uint16_t * event_buffer = createEventBuffer(en, en, en, en, evts); 
  ed.parseECycleBuffer(event_buffer); 
  while(ed.dispatchEvents()); 

  BOOST_CHECK_EQUAL(etx.eventBuffer_.size(), 1); 

  for (int i = 0; i < 128 ; i++) {
    source1.sendSample(i); 
    source4.sendSample(i * 0x1000);  
  }
  
  BOOST_CHECK_EQUAL(etx.eventBuffer_.size(), 1 + 128/4); 

  BOOST_CHECK_EQUAL(etx.eventBuffer_.front().event.cmd, 0x18); 
  std::list<dsp::EventTX_t>::iterator ei; 
  ei = etx.eventBuffer_.begin(); 
  ei++; 
  int pos = 0; 
  for(; ei != etx.eventBuffer_.end(); ei++) {
    BOOST_CHECK_EQUAL(ei->event.cmd, 0x18); 
    BOOST_CHECK_EQUAL(ei->event.data[1], (pos * 0x1000) >> 8); 
    pos += 4; 
  }

  // now send the "enable data source 1"  event

//     BOOST_CHECK_EQUAL(dataout.dataCount_, 1); 
//     int offset = 28; 
//     int32_t * data = (int32_t*)&(dataout.mostrecentbuffer[offset]); 
//     for(int i = 0; i< 128; i++) {
//       int32_t hdatum = ntohl(data[i]); 
//       BOOST_CHECK_EQUAL(hdatum, i * DSN); 
//     }
//   }
}


// BOOST_AUTO_TEST_CASE(abort_test)
// {
//   /*
//     put in data, and then change the downsample
//     ratio, and see if it is aborted
    
//   */
//   int DOWNSAMPLEN = 6; 
//   uint16_t downsamples[] = {1, 2, 4, 8, 16, 32}; 
//   for (int dsi = 1; dsi < DOWNSAMPLEN; dsi++) {
//     SourceObject source; 
//     SystemTimer timer; 
//     timer.setTime(0x123456789A); 
//     EventDispatch ed(DSPA); 
//     HostDataOut dataout; 
//     EventTX etx; 
//     AvailableFIRs firs;
//     FilterLinkController flc(&ed, &etx, &firs); 
//     Audiomon wsink(&timer, &dataout, &ed, &etx, &flc, 17); 
  
//     // set the downsample rate, see if we get the response we expect. 
//     source.source.connect(wsink.sink); 

//     int DSN = downsamples[dsi]; 
//     int oldds = downsamples[dsi -1]; 

//     dsp::Event_t e; 
//     e.src = 0; 
//     e.cmd = 47; 
//     e.data[0] = 1; 
//     e.data[1] = oldds; 
  
//     wsink.setstate(&e); 

//     BOOST_CHECK_EQUAL(etx.eventBuffer_.size(), 2); 

//     // This is the data that's going to be thrown away
//     for (int i = 0; i < 126 * oldds; i++) {
//       source.sendSample(i); 
//     }  


//     e.src = 0; 
//     e.cmd = 47; 
//     e.data[0] = 1; 
//     e.data[1] = DSN; 
  
//     wsink.setstate(&e); 

//     // This is the data that's going to be thrown away
//     for (int i = 0; i < 128 * DSN; i++) {
//       source.sendSample(i); 
//     }  

  
//     BOOST_CHECK_EQUAL(dataout.dataCount_, 1); 
//     int offset = 28; 
//     int32_t * data = (int32_t*)&(dataout.mostrecentbuffer[offset]); 
//     for(int i = 0; i< 128; i++) {
//       int32_t hdatum = ntohl(data[i]); 
//       BOOST_CHECK_EQUAL(hdatum, i * DSN); 
//     }
//   }
// }



BOOST_AUTO_TEST_SUITE_END(); 

