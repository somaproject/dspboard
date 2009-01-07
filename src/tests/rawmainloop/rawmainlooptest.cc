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
  
  RawMainLoop mainloop; 
  mainloop.setup(&ed, &eventtx, &acqserial, &dataout, &config); 
  
  // set gains
  acqserial.gains_[0] = 1; 
  acqserial.gains_[1] = 1; 
  acqserial.gains_[2] = 1; 
  acqserial.gains_[3] = 1; 
  acqserial.gains_[4] = 1; 

  AcqFrame af; 
  af.mode = 0; 
  af.cmdid = 0;
  af.success = 0; 
  af.loading = 0; 
  af.chksum = 0; 

  for (int j = 0; j < 130; j++) {
    std::vector<int16_t> buff; 
    for (int i = 0; i < 10; i++) {
      buff.push_back(i * 10 + j * 100); 
    }
    acqserial.appendSamples(buff); 
  }
  
  for (int i = 0; i < 200; i++) {
    mainloop.runloop();
  }
  BOOST_CHECK_EQUAL(dataout.dataCount_,  4); 
  // data check -- note that this depends on the order in 
  // which the acqframe fires
  
  for (int bufnum = 0; bufnum < 4; bufnum++) {
    unsigned char * buffer = dataout.allbuffers[bufnum]; 
    const int BUFOFFSET = 4 +  8 + 2 + 4; 
    int LEN = 128 * 4 + BUFOFFSET; 
    BOOST_CHECK_EQUAL(buffer[0], LEN >> 8); 
    BOOST_CHECK_EQUAL(buffer[1], LEN & 0xFF ); 
    
    //   // check SRC and TYP
    const char TYP = 2; 
    BOOST_CHECK_EQUAL(buffer[2], TYP); 
    BOOST_CHECK_EQUAL(buffer[3], SRC); 
    
    
    for (int i = 0; i < RawData_t::BUFSIZE; i++) {
      int32_t hostx, netx = 0 ; 
      memcpy(&netx, &(buffer[i*4 + BUFOFFSET ]), 4); 
      hostx = ntohl(netx); 
      double tgtval = bufnum * 10 + i * 100; 
      double tgtvald = 2.048 / encodeGain(acqserial.gains_[bufnum]) * (tgtval / 32768.0);  
      double vald = double(hostx) / 1000000000.0; 
      BOOST_CHECK_CLOSE(tgtvald, vald, 1.0/32768.0);
    }
  }

  
}



BOOST_AUTO_TEST_SUITE_END(); 

