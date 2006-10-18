#include <boost/test/unit_test.hpp>
#include <iostream>
#include <vector>

#include <hw/acqserial.h>
#include <acqboarddatasrc.h>

using boost::unit_test::test_suite;
using namespace std; 

void acqboard_testset(void)
{
  // Test if we can set a single setting, and if the cmdid update logic
  // is working properly
  AcqSerial as; 
  
  AcqboardDataSrc ads((AcqSerialBase*) &as, CHANSET_A); 
  ads.sampleProcess(); 
  ads.setGain(0, 100); 
  BOOST_CHECKPOINT("About to try gain reading loop!"); 
  while (ads.getGain(0) != 100) {
    ads.sampleProcess(); 
  }
  BOOST_CHECK(as.gains_[0] == 1); 

}

void acqboard_gainset(void)
{
  // sequentially set and read back all gains, to check 
  // for gain setting collisions and errors

  AcqSerial as; 
  
  AcqboardDataSrc ads((AcqSerialBase*) &as, CHANSET_A); 
  ads.sampleProcess(); 

  short gains[] = {0, 100, 200, 500, 1000, 2000, 5000, 10000}; 
  
  for (int g = 1; g < 8; g++ ) {
    for (int c = 0; c < 5; c++) { 
      
      ads.setGain(c, gains[g]); 
      BOOST_CHECKPOINT("About to try gain reading loop!"); 
      while (ads.getGain(c) != gains[g]) {
	ads.sampleProcess(); 
      }
      BOOST_CHECK(as.gains_[c] == g); 
    }
  }
}

void acqboard_filterset(void)
{
  // sequentially set and read back all filters, to check 
  // for filter setting collisions and errors

  AcqSerial as; 
  
  AcqboardDataSrc ads((AcqSerialBase*) &as, CHANSET_A); 
  ads.sampleProcess(); 

  for (int c = 0; c < 5; c++) { 
      
      ads.setHPFilter(c, true); 
      BOOST_CHECKPOINT("About to try filter reading loop!"); 
      while (ads.getHPFilter(c) != true) {
	ads.sampleProcess(); 
      }
      BOOST_CHECK(as.hpfs_[c] == true); 
    }
}


bool closecheck(sample_t x, sample_t y) {
  return (x == y) | (x+1 == y) | (x - 1 == y); 
}

void acqboard_testconvvals(void)
{
  // Check if we read in samples properly. 

  AcqSerial as; 
  
  AcqboardDataSrc ads((AcqSerialBase*) &as, CHANSET_A); 
  ads.sampleProcess(); 

  // set all gains to 1000
  
  int GAIN = 1000;
  for (int c = 0; c < 5; c++) { 
    
    ads.setGain(c, GAIN); 
    while (ads.getGain(c) != GAIN) {
      ads.sampleProcess(); 
    }
  }
  
  as.fpos_ = 0; // reset position data
  
  // read in 50 samples
  for (int i = 0; i < 50; i++) {
    ads.sampleProcess(); 
  }
  
  // for each channel , verify output
  for (int i = 0; i < 1; i++) {
    SampleBuffer<sample_t> * sb = ads.getChannelBuffer(0); 
    for (int n = 0; n < 50; n++) {
      BOOST_CHECK (closecheck ((*sb)[50 - n - 1], 
			       sample_t(2.048 / GAIN * 
					float((n << 4) + i)/32768.0 * 1e9) )); 
    }
  }
  
  
}

test_suite*
init_unit_test_suite( int argc, char* argv[] )
{
  
  test_suite* test= BOOST_TEST_SUITE( "Callback test" );
  
  test->add( BOOST_TEST_CASE( &acqboard_testset ), 0, 1 ); 
  test->add( BOOST_TEST_CASE( &acqboard_gainset )); 
  test->add( BOOST_TEST_CASE( &acqboard_filterset )); 
  
  // functional tests
  test->add( BOOST_TEST_CASE( &acqboard_testconvvals)); 

  return test;
	     
}
