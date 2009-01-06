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

BOOST_AUTO_TEST_SUITE(acqdatasource_test); 

BOOST_AUTO_TEST_CASE(acqdatasource_simple)
{
  SystemTimer timer; 
  timer.setTime(0); 
  
  AcqState acqstate; 
  AcqDataSource ads(&acqstate); 
  
  ads.setDSP(DSPA); 

  //FakeSource fs(&timer); 
  HostDataOut dataout; 

  const char SRC =  10; 
  std::vector<RawSink *> rawsinks; 
  for (int i = 0; i < 5; i++) {
    rawsinks.push_back(new RawSink(&timer, &dataout, SRC, i)); 
  }


  // now connect things
  ads.sourceA.connect(rawsinks[0]->sink);
  ads.sourceB.connect(rawsinks[1]->sink);
  ads.sourceC.connect(rawsinks[2]->sink);
  ads.sourceD.connect(rawsinks[3]->sink);
  ads.sourceCont.connect(rawsinks[4]->sink);

  // now setup the acqstate
  acqstate.mode = 0; 
  acqstate.linkUp = true; 
  acqstate.gain[0] = 100; 
  acqstate.gain[1] = 100;
  acqstate.gain[2] = 100;
  acqstate.gain[3] = 100;
  acqstate.gain[4] = 100;

  acqstate.hpfen[0] = false; 
  acqstate.hpfen[1] = false; 
  acqstate.hpfen[2] = false; 
  acqstate.hpfen[3] = false; 
  acqstate.hpfen[4] = false; 
  acqstate.inputSel = 0; 
  
  AcqFrame af; 
  af.mode = 0; 
  af.cmdid = 0;
  af.success = 0; 
  af.loading = 0; 
  af.chksum = 0; 

  for (int j = 0; j < 130; j++) {
    for (int i = 0; i < 10; i++) {
      af.samples[i] = i * 10 + j * 100; 
    }
    ads.newAcqFrame(&af); 
  }


  BOOST_CHECK_EQUAL(dataout.dataCount_,  5); 
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
      double tgtvald = 2.048 / acqstate.gain[bufnum] * (tgtval / 32768.0);  
      double vald = double(hostx) / 1000000000.0; 
      BOOST_CHECK_CLOSE(tgtvald, vald, 1.0/32768.0);
    }
  }

}


BOOST_AUTO_TEST_SUITE_END(); 

