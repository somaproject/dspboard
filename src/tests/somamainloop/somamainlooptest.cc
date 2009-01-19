#include <boost/test/unit_test.hpp>

#include <boost/test/auto_unit_test.hpp>
#include <boost/test/floating_point_comparison.hpp>
#include <arpa/inet.h>

#include <filterio.h>
#include <systemtimer.h>
#include <acqdatasource.h>
#include <sinks/rawsink.h>
#include <hostdataout.h>
#include <vector>
#include <iostream>
#include <mainloops/somamainloop.h>
#include <dspfixedconfig.h>

BOOST_AUTO_TEST_SUITE(rawmainloop_test)

BOOST_AUTO_TEST_CASE(rawmainloop_simple)
{
  /*
    Generic set-up of the raw loop, where we
    then attempt to put in fake data and get out reasonable values. 

  */
  SystemTimer timer; 
  timer.setTime(0); 
  
  HostDataOut dataout; 
  int SRC = 0; 
  
  DSPFixedConfig config(DSPA, 8, SRC); 

  EventDispatch ed(config.getDSPPos()); 
  EventTX eventtx; 
  
  AcqSerial acqserial(false); 
  acqserial.linkUpState_ = true; 


  SomaMainLoop mainloop; 
  mainloop.setup(&ed, &eventtx, &acqserial, &dataout, &config); 

  AcqFrame af; 
  af.mode = 0; 
  af.cmdid = 0;
  af.success = 0; 
  af.loading = 0; 
  af.chksum = 0; 

  int CYCLECNT = 2000; 
  int CYCLEMIN = -128; 
  int CYCLEMAX = 128; 
  int CYCLEDELTA = 1; 

  // REcord all of the data we put in so we can walk
  // backwards through it
  std::vector<std::list<int16_t> > inputDatas; 
  for(int i = 0; i < 10; i++) { 
    inputDatas.push_back(std::list<int16_t>()); 
  }

  // put the data into the mock acqserial buffer
  for (int j = 0; j < CYCLECNT; j++) {
    int val = CYCLEMIN; 
    while (val < CYCLEMAX) {
      std::vector<int16_t> buff; 
      for (int i = 0; i < 10; i++) {
	buff.push_back(val); 
	inputDatas[i].push_back(val); 
      }
      acqserial.appendSamples(buff); 
      val += CYCLEDELTA; 
    }
  }

  // bleed off some cycles for initialization
  for (int i = 0; i < 1000; i++) {
    mainloop.runloop();
  }
  chanmask_t chanmask[5]; 
  chanmask[0] = true; 
  chanmask[1] = true; 
  chanmask[2] = true; 
  chanmask[3] = true; 
  chanmask[4] = true; 

  // Set the gain to a non-zero value and bleed off some more cycles
  mainloop.pAcqStateControl_->setGain(chanmask, 100); 
  for (int i = 0; i < 4000000; i++) {
    mainloop.runloop();
  }

  BOOST_CHECK(dataout.dataCount_  > 1); 
//   // data check -- note that this depends on the order in 
//   // which the acqframe fires

  // ignore first few buffers because we're not sure where
  // the acqgain set took effect
  for (int bufnum = 50; bufnum  < dataout.dataCount_ ; bufnum++) {
    unsigned char * buffer = dataout.allbuffers[bufnum]; 
    const int BUFOFFSET = 4 + 2 +  8; 
    int LEN = (2 + 4 + 4 + 32*4) * 4 + BUFOFFSET; 
    BOOST_CHECK_EQUAL(buffer[0], LEN >> 8); 
    BOOST_CHECK_EQUAL(buffer[1], LEN & 0xFF ); 
    
    const char TYP = 0; 
    BOOST_CHECK_EQUAL(buffer[2], TYP); 
    BOOST_CHECK_EQUAL(buffer[3], SRC); 
    
    int len = TSpikeData_t::PRETRIGGER + TSpikeData_t::POSTTRIGGER; 
    for (int chan = 0; chan < 1; chan++ )// FIXME chan < 4
      {
	int32_t inputval = -(TSpikeData_t::PRETRIGGER -1);  // the value we originally put in
	for (int i = 0; i < len; i++) {
	  int32_t hostx, netx = 0 ; 
	  int bpos = BUFOFFSET + i*4 + (2 + 4 + 4) * (chan +1) + (len * 4) * chan; 
	  
	  memcpy(&netx, &(buffer[bpos]), 4); 
	  hostx = ntohl(netx); 
	  double tgtvald = 2.048 / encodeGain(acqserial.gains_[chan]) * (inputval / 32768.0);  
	  double vald = double(hostx) / 1000000000.0; 
// 	  std::cout << " inputval = " << inputval
// 		    << " tgtvald=" << tgtvald 
// 		    << " vald = " << vald << std::endl;
	  
	  BOOST_CHECK_CLOSE(tgtvald, vald, 1.0/32768.0);
	  inputval += 1; 
	}
      }
  }

  
}



BOOST_AUTO_TEST_SUITE_END(); 

