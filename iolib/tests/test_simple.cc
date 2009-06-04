#include <boost/test/auto_unit_test.hpp>
#include "boost/filesystem/operations.hpp"
#include "boost/filesystem/fstream.hpp"   
#include <iostream>
#include <vector>
#include <list> 


#include "mockdspboard.h"
#include <somadspio/dspcontrol.h>


BOOST_AUTO_TEST_SUITE(test); 

BOOST_AUTO_TEST_CASE(simpletest)
{
  /*
    Just try initializing the mock dsp board and seeing 
    if gain, etc. information gets propagated to the proxy. 
  */

  MockDSPBoard dspboard(0, 8); 
  dspboard.acqserial.linkUpState_ = true;
  dspiolib::StateProxy stateproxy(0, sigc::mem_fun(dspboard,
						   &MockDSPBoard::sendEvents)); 
  dspboard.setEventCallback(sigc::mem_fun(stateproxy,
					  &dspiolib::StateProxy::newEvent)); 
  
  dspboard_run(dspboard, 10000); 
  // check if the link status update was correctly... uh, updated
  BOOST_CHECK_EQUAL(stateproxy.acqdatasrc.getLinkStatus(), true); 
  BOOST_CHECK_EQUAL(stateproxy.acqdatasrc.getMode(), 0); 
  BOOST_CHECK_EQUAL(stateproxy.acqdatasrc.getGain(0), 0); 
  
}


BOOST_AUTO_TEST_SUITE_END(); 
