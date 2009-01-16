#include <boost/test/unit_test.hpp>

#include <boost/test/auto_unit_test.hpp>

#include <filterio.h>
#include <systemtimer.h>
#include <fakesource.h>
#include <sinks/tspikesink.h>
#include <hostdataout.h>
#include <hw/eventtx.h>
#include <somanetwork/tspike.h>
#include <somanetwork/datapacket.h>
#include <tests/utils/util.h>


BOOST_AUTO_TEST_SUITE(tspikesink_test); 

class SourceObject : public FilterLink{
public:
  SampleRingBuffer<int> buf1_; 
  SampleRingBuffer<int> buf2_; 
  SampleRingBuffer<int> buf3_; 
  SampleRingBuffer<int> buf4_; 

  SampleRingBuffer<char> bufCycle_; 

  FilterLinkSource<int> source1; 
  FilterLinkSource<int> source2;
  FilterLinkSource<int> source3; 
  FilterLinkSource<int> source4; 
  
  FilterLinkSource<char> sourceCycle; 

  filterid_t getFilterID() {
    return 7; 
  }
  
  bool setFilterID(filterid_t) {
    return true; 
  }
  
  SourceObject() :
    buf1_(100), 
    buf2_(100), 
    buf3_(100), 
    buf4_(100), 
    bufCycle_(1), 
    source1(&buf1_, this), 
    source2(&buf2_, this), 
    source3(&buf3_, this), 
    source4(&buf4_, this), 
    sourceCycle(&bufCycle_, this)
  {

    
  }
  
  
  void sendSample(int x) {
    source1.newSample(x); 
    source2.newSample(x); 
    source3.newSample(x); 
    source4.newSample(x); 
    sourceCycle.newSample(0); 

  }

}; 

BOOST_AUTO_TEST_CASE(simple_compile_test)
{
  /*
    Configure the TSpikeSink and put in fake data; 
    then extract out with Network's raw->tspike converter
    and verify the data

  */
  SourceObject source; 
  SystemTimer timer; 
  timer.setTime(0x123456789A); 
  EventDispatch ed(DSPA); 
  HostDataOut dataout; 
  EventTX etx; 
  AvailableFIRs firs;
  FilterLinkController flc(&ed, &etx, &firs); 
  TSpikeSink sink(&timer, &dataout, &ed, &etx, &flc, 17); 
  int32_t filtids[] = {0x12340000, 0x77881122, 0x00001111, 
		       0x00001234}; 

  source.source1.connect(sink.sink1); 
  source.source1.id = filtids[0]; 
  source.source2.connect(sink.sink2); 
  source.source2.id = filtids[1]; 

  source.source3.connect(sink.sink3); 
  source.source3.id = filtids[2]; 

  source.source4.connect(sink.sink4); 
  source.source4.id = filtids[3]; 

  source.sourceCycle.connect(sink.samplesink); 
  sink.setThreshold(0, 1000); 
  sink.setThreshold(1, 1000); 
  sink.setThreshold(2, 1000); 
  sink.setThreshold(3, 1000); 

  // fill the buffer with data
  source.sendSample(100); 
  BOOST_CHECK_EQUAL(dataout.dataCount_, 0); 
  
  for(int i = 0; i < TSpikeData_t::PRETRIGGER - 1; i++) {
    source.sendSample(0); 
  }

  for(int i = 0; i < TSpikeData_t::POSTTRIGGER + 1; i++) {
    source.sendSample((i+1) * 2000); 
  }

  
  // now it should have generated a tspike
  BOOST_CHECK_EQUAL(dataout.dataCount_, 1); 
  

  // now we try and decode
  somanetwork::pDataPacket_t dp( new somanetwork::DataPacket_t()); 
  dp->seq = 0; 
  dp->src = 0; 
  dp->typ = somanetwork::TSPIKE; 
  dp->missing = false; 
  memcpy(&dp->body[0], &(dataout.mostrecentbuffer[2]), 1000); 

  // construct a datapacket
  
  somanetwork::TSpike_t ts = somanetwork::rawToTSpike(dp); 
  BOOST_CHECK_EQUAL(ts.src, 17); 
  BOOST_CHECK_EQUAL(ts.time, 0x123456789A); 

  
  // now check the data? 
  BOOST_CHECK_EQUAL(ts.x.filtid, filtids[0]); 
  BOOST_CHECK_EQUAL(ts.y.filtid, filtids[1]); 
  BOOST_CHECK_EQUAL(ts.a.filtid, filtids[2]); 
  BOOST_CHECK_EQUAL(ts.b.filtid, filtids[3]);   

  BOOST_CHECK_EQUAL(ts.x.threshold, 1000); 
  BOOST_CHECK_EQUAL(ts.y.threshold, 1000); 
  BOOST_CHECK_EQUAL(ts.a.threshold, 1000); 
  BOOST_CHECK_EQUAL(ts.b.threshold, 1000); 

  somanetwork::TSpikeWave_t * waveptrs[] = {&ts.x, &ts.y, &ts.a, &ts.b}; 

  for (int chan = 0; chan < TSpikeData_t::CHANNUM; chan++) {
    
    for(int i = 0; i < TSpikeData_t::PRETRIGGER - 1; i++) {
      BOOST_CHECK_EQUAL(waveptrs[chan]->wave[i], 0); 
    }
    
    for(int i = 0; i < TSpikeData_t::POSTTRIGGER + 1; i++) {
      BOOST_CHECK_EQUAL(waveptrs[chan]->wave[i + TSpikeData_t::PRETRIGGER-1],   
			((i+1) * 2000)); 
    }

  }

}

BOOST_AUTO_TEST_CASE(varying_startpoint_test)
{
  /*
    Configure the TSpikeSink and put in fake data; 
    then extract out with Network's raw->tspike converter
    and verify the data

    The same as the previous test, except we explicitly 
    engage the wrap-around in the TSPIKE internal buffer, with a range
    of start points

  */
  for (int leadingsamples = 9; leadingsamples < 2000; leadingsamples++) {
    SourceObject source; 
    SystemTimer timer; 
    timer.setTime(0x123456789A); 
    EventDispatch ed(DSPA); 
    HostDataOut dataout; 
    EventTX etx; 
    AvailableFIRs firs;
    FilterLinkController flc(&ed, &etx, &firs);
  
    TSpikeSink sink(&timer, &dataout, &ed, &etx, &flc,  17); 
    int32_t filtids[] = {0x12340000, 0x77881122, 0x00001111, 
			 0x00001234}; 

    source.source1.connect(sink.sink1); 
    source.source1.id = filtids[0]; 
    source.source2.connect(sink.sink2); 
    source.source2.id = filtids[1]; 

    source.source3.connect(sink.sink3); 
    source.source3.id = filtids[2]; 

    source.source4.connect(sink.sink4); 
    source.source4.id = filtids[3]; 

    source.sourceCycle.connect(sink.samplesink); 
    sink.setThreshold(0, 1000); 
    sink.setThreshold(1, 1000); 
    sink.setThreshold(2, 1000); 
    sink.setThreshold(3, 1000); 

    // fill the buffer with data
    source.sendSample(100); 
    BOOST_CHECK_EQUAL(dataout.dataCount_, 0); 
  
    for(int i = 0; i < leadingsamples; i++) {
      source.sendSample(0); 
    }
  
    for(int i = 0; i < TSpikeData_t::POSTTRIGGER + 1; i++) {
      source.sendSample((i+1) * 2000); 
    }

  
    // now it should have generated a tspike
    BOOST_CHECK_EQUAL(dataout.dataCount_, 1); 
  

    // now we try and decode
    somanetwork::pDataPacket_t dp( new somanetwork::DataPacket_t()); 
    dp->seq = 0; 
    dp->src = 0; 
    dp->typ = somanetwork::TSPIKE; 
    dp->missing = false; 
    memcpy(&dp->body[0], &(dataout.mostrecentbuffer[2]), 1000); 

    // construct a datapacket
  
    somanetwork::TSpike_t ts = somanetwork::rawToTSpike(dp); 
    BOOST_CHECK_EQUAL(ts.src, 17); 
    BOOST_CHECK_EQUAL(ts.time, 0x123456789A); 

  
    // now check the data? 
    BOOST_CHECK_EQUAL(ts.x.filtid, filtids[0]); 
    BOOST_CHECK_EQUAL(ts.y.filtid, filtids[1]); 
    BOOST_CHECK_EQUAL(ts.a.filtid, filtids[2]); 
    BOOST_CHECK_EQUAL(ts.b.filtid, filtids[3]);   

    BOOST_CHECK_EQUAL(ts.x.threshold, 1000); 
    BOOST_CHECK_EQUAL(ts.y.threshold, 1000); 
    BOOST_CHECK_EQUAL(ts.a.threshold, 1000); 
    BOOST_CHECK_EQUAL(ts.b.threshold, 1000); 

    somanetwork::TSpikeWave_t * waveptrs[] = {&ts.x, &ts.y, &ts.a, &ts.b}; 

    for (int chan = 0; chan < TSpikeData_t::CHANNUM; chan++) {
    
      for(int i = 0; i < TSpikeData_t::PRETRIGGER - 1; i++) {
	BOOST_CHECK_EQUAL(waveptrs[chan]->wave[i], 0); 
      }
    
      for(int i = 0; i < TSpikeData_t::POSTTRIGGER + 1; i++) {
	BOOST_CHECK_EQUAL(waveptrs[chan]->wave[i + TSpikeData_t::PRETRIGGER-1],   
			  ((i+1) * 2000)); 
      }

    }
  }
}

BOOST_AUTO_TEST_CASE(set_state_test)
{
  /*
    EVENT TEST: 

    Query the threshold and then set it and check for update broadcast

  */

    SourceObject source; 
    SystemTimer timer; 
    timer.setTime(0x123456789A); 
    EventDispatch ed(DSPA); 
    HostDataOut dataout; 
    EventTX etx;
    AvailableFIRs firs;
    FilterLinkController flc(&ed, &etx, &firs); 
  
    TSpikeSink sink(&timer, &dataout, &ed, &etx, &flc,  17); 
    int32_t filtids[] = {0x12340000, 0x77881122, 0x00001111, 
			 0x00001234}; 

    source.source1.connect(sink.sink1); 
    source.source1.id = filtids[0]; 
    source.source2.connect(sink.sink2); 
    source.source2.id = filtids[1]; 

    source.source3.connect(sink.sink3); 
    source.source3.id = filtids[2]; 

    source.source4.connect(sink.sink4); 
    source.source4.id = filtids[3]; 

    source.sourceCycle.connect(sink.samplesink); 
    sink.setThreshold(0, 1000); 
    sink.setThreshold(1, 1000); 
    sink.setThreshold(2, 1000); 
    sink.setThreshold(3, 1000); 

    // First, query the threshold


    // fill the buffer with data
    source.sendSample(100); 
    BOOST_CHECK_EQUAL(dataout.dataCount_, 0); 
  
    // Now we change the threshold 
    dsp::Event_t etx1; 
    etx1.cmd = 0x43; 
    etx1.src = 0x10; 
    etx1.data[0] = 1; 
    etx1.data[1] = 2; 
//     etx1.data[2] = 0x1234; 
//     etx1.data[3] = 0x5678; 
    
    //masks
    std::vector<bool> amask(80), bmask(80), cmask(80), dmask(80); 
    amask[0] = 1; 
    std::vector<dsp::Event_t> events(80); 
    events[0] = etx1; 
    
    uint16_t * buf = createEventBuffer(amask, bmask, cmask, dmask, events); 
    ed.parseECycleBuffer(buf); 
    while(ed.dispatchEvents()) {}; 
    
    BOOST_CHECK_EQUAL(etx.eventBuffer_.size(), 1); 
    // verify the query event
    dsp::EventTX_t eventtx = etx.eventBuffer_.front(); 
    BOOST_CHECK_EQUAL(eventtx.event.cmd, 0x45); 
    BOOST_CHECK_EQUAL(eventtx.event.data[0], 1); 
    BOOST_CHECK_EQUAL(eventtx.event.data[1], 2); 
    BOOST_CHECK_EQUAL(eventtx.event.data[2], 0000); 
    BOOST_CHECK_EQUAL(eventtx.event.data[3], 1000); 

    etx.eventBuffer_.clear(); 

    // now set the event cmd
    events[0].cmd = 0x44; 
    events[0].src = 0x10; 
    events[0].data[0] = 1; 
    events[0].data[1] = 3; 
    events[0].data[2] = 0x1234; 
    events[0].data[3] = 0x5678; 
    
    buf = createEventBuffer(amask, bmask, cmask, dmask, events); 
    ed.parseECycleBuffer(buf); 
    while(ed.dispatchEvents()) {}; 
    
    BOOST_CHECK_EQUAL(etx.eventBuffer_.size(), 1); 

    eventtx = etx.eventBuffer_.front(); 
    BOOST_CHECK_EQUAL(eventtx.event.cmd, 0x45); 
    BOOST_CHECK_EQUAL(eventtx.event.data[0], 1); 
    BOOST_CHECK_EQUAL(eventtx.event.data[1], 3); 
    BOOST_CHECK_EQUAL(eventtx.event.data[2], 0x1234);
    BOOST_CHECK_EQUAL(eventtx.event.data[3], 0x5678); 

    etx.eventBuffer_.clear(); 

    
}



BOOST_AUTO_TEST_SUITE_END(); 

