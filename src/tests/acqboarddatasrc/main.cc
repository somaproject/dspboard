#include <boost/test/unit_test.hpp>
#include <iostream>
#include <vector>

#include <nohw/acqserial.h>
#include <acqboarddatasrc.h>

using boost::unit_test::test_suite;
using namespace std; 

void acqboard_testset(void)
{
  AcqSerial as; 
  
  AcqboardDataSrc ads((AcqSerialBase*) &as, CHANSET_A); 
  ads.sampleProcess(); 
  ads.setGain(0, 100); 
  BOOST_CHECKPOINT("About to try gain reading loop!"); 
  while (ads.getGain(0) != 100) {
    ads.sampleProcess(); 
  }
  
}

test_suite*
init_unit_test_suite( int argc, char* argv[] )
{
  
  test_suite* test= BOOST_TEST_SUITE( "Callback test" );
  
  test->add( BOOST_TEST_CASE( &acqboard_testset ), 0, 1 ); 

  return test;
	     
}
