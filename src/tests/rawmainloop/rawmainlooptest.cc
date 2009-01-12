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
#include <mainloops/rawmainloop.h>
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
  RawMainLoop mainloop; 
  mainloop.setup(&ed, &eventtx, &acqserial, &dataout, &config); 

  AcqFrame af; 
  af.mode = 0; 
  af.cmdid = 0;
  af.success = 0; 
  af.loading = 0; 
  af.chksum = 0; 

  int TGTBUFCOUNT = 20; 
  // REcord all of the data we put in so we can walk
  // backwards through it
  std::vector<std::list<int16_t> > inputDatas; 
  for(int i = 0; i < 10; i++) { 
    inputDatas.push_back(std::list<int16_t>()); 
  }

  // put the data into the mock acqserial buffer
  for (int j = 0; j < 128 * TGTBUFCOUNT; j++) {
    std::vector<int16_t> buff; 
    for (int i = 0; i < 10; i++) {
      int16_t val = i * 10 + j * 100; 
      buff.push_back(val); 
      inputDatas[i].push_back(val); 
    }
    acqserial.appendSamples(buff); 
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
  for (int i = 0; i < 4000; i++) {
    mainloop.runloop();
  }

  BOOST_CHECK_EQUAL(dataout.dataCount_,  4 * TGTBUFCOUNT); 
//   // data check -- note that this depends on the order in 
//   // which the acqframe fires

  // Walk backwards through the recorded buffers, because
  // the beginning of the buffer history is corrupted with gain-change
  // and init leftovers. Hence the bufnum > 40 below
  for (int bufnum = TGTBUFCOUNT* 4 -1; bufnum > 40; bufnum--) {
    unsigned char * buffer = dataout.allbuffers[bufnum]; 
    const int BUFOFFSET = 4 +  8 + 2 + 4; 
    int LEN = 128 * 4 + BUFOFFSET; 
    BOOST_CHECK_EQUAL(buffer[0], LEN >> 8); 
    BOOST_CHECK_EQUAL(buffer[1], LEN & 0xFF ); 
    
    const char TYP = 2; 
    BOOST_CHECK_EQUAL(buffer[2], TYP); 
    BOOST_CHECK_EQUAL(buffer[3], SRC); 
    
    // check which buffer this is
    uint16_t chansrcn, chansrch; 
    memcpy(&chansrcn, &buffer[12], sizeof(int16_t)); 
    chansrch = ntohs(chansrcn); 
//     std::cout << " chansrch= " << chansrch << std::endl; 
//     std::cout << " --------------------------------------------------" 
// 	      << std::endl; 
    for (int i = RawData_t::BUFSIZE - 1; i > -1; --i) {
      int32_t hostx, netx = 0 ; 
      memcpy(&netx, &(buffer[i*4 + BUFOFFSET ]), 4); 
      hostx = ntohl(netx); 
      int16_t tgtval = inputDatas[chansrch].back(); 
      inputDatas[chansrch].pop_back(); 

      double tgtvald = 2.048 / encodeGain(acqserial.gains_[chansrch]) * (tgtval / 32768.0);  
      double vald = double(hostx) / 1000000000.0; 
//       std::cout << "Gain is " << encodeGain(acqserial.gains_[chansrch])  << std::endl; 
//       std::cout << " tgtval = " << tgtval 
// 		<< " tgtvald=" << tgtvald 
// 		<< " vald = " << vald << std::endl;

      BOOST_CHECK_CLOSE(tgtvald, vald, 1.0/32768.0);
    }
  }

  
}



BOOST_AUTO_TEST_SUITE_END(); 

