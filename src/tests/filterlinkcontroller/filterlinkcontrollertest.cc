#include <boost/test/unit_test.hpp>

#include <boost/test/auto_unit_test.hpp>

#include <filterio.h>
#include <systemtimer.h>
#include <hw/eventtx.h>
#include <filterlinks/availablefirs.h>
#include <filterlinkcontroller.h>
#include <tests/utils/util.h>


BOOST_AUTO_TEST_SUITE(filterlinkcontroller_test); 

BOOST_AUTO_TEST_CASE(filter_link_control_test)
{
  /*
    Check initialization of availableFIRs

    
  */
  std::vector<filterid_t> filterids; 

  SystemTimer timer; 
  timer.setTime(0x123456789A); 
  EventDispatch ed(DSPA); 
  EventTX etx;
  AvailableFIRs firs;
  FilterLinkController flc(&ed, &etx, &firs); 
  
  for (int i = 0; i < AvailableFIRs::FILTERNUM; i++) {
    BOOST_CHECK_EQUAL(firs.filterlens[i] ,  0); 
    BOOST_CHECK_EQUAL(firs.filterset[i], false); 
    BOOST_CHECK_EQUAL(firs.filterids[i], 0); 
    
    for (int j = 0; j < AvailableFIRs::MAXFILTERLEN; j++) {
      BOOST_CHECK_EQUAL(firs.filters[i][j], 0); 	
    }
  }
  
  /* 
       Now, we go through and set _every_ coefficient in every filter
    */
  for (int i = 0; i < AvailableFIRs::FILTERNUM; i++) {
    filterid_t fid(0);

    for (int j = 0; j < AvailableFIRs::MAXFILTERLEN; j++) {
      
      dsp::Event_t etx1; 
      etx1.cmd = 0x47; 
      etx1.src = 0x10; 
      etx1.data[0] = 0; 
      etx1.data[1] = i; 
      etx1.data[2] = j; 
      etx1.data[3] = i; 
      etx1.data[4] = j; 
      sample_t firtgt = (i << 16) | (j  & 0xFFFF); 

      std::vector<bool> amask(80), bmask(80), cmask(80), dmask(80); 
      amask[0] = 1; 
      std::vector<dsp::Event_t> events(80); 
      events[0] = etx1; 
      
      uint16_t * buf = createEventBuffer(amask, bmask, cmask, dmask, events); 
      ed.parseECycleBuffer(buf); 
      while(ed.dispatchEvents()) {}; 
      fid ^= firtgt; 
    }
    filterids.push_back(fid); 

  }

    /* 
       Now verify the results with explict queries and checks of the 
       actual filter coefficients. 
    
    */


    for (int i = 0; i < AvailableFIRs::FILTERNUM; i++) {
      for (int j = 0; j < AvailableFIRs::MAXFILTERLEN; j++) {

	// Directly check the fir coefficient
	sample_t firtgt = (i << 16) | (j  & 0xFFFF); 
	BOOST_CHECK_EQUAL(firs.filters[i][j], firtgt); 


	dsp::Event_t etx1; 
	etx1.cmd = 0x47; 
	etx1.src = 0x10; 
	etx1.data[0] = 1; 
	etx1.data[1] = i; 
	etx1.data[2] = j; 
	etx1.data[3] = 0; 
	etx1.data[4] = 0; 
	
	std::vector<bool> amask(80), bmask(80), cmask(80), dmask(80); 
	amask[0] = 1; 
	std::vector<dsp::Event_t> events(80); 
	events[0] = etx1; 
    
	uint16_t * buf = createEventBuffer(amask, bmask, cmask, dmask, events); 
	ed.parseECycleBuffer(buf); 
	while(ed.dispatchEvents()) {}; 
	
 	BOOST_CHECK_EQUAL(etx.eventBuffer_.size(), 1); 
 	dsp::EventTX_t eventin = etx.eventBuffer_.front(); 
 	etx.eventBuffer_.pop_front(); 
	
	BOOST_CHECK_EQUAL(eventin.event.cmd, FilterLinkController::FIR_RESP); 
	BOOST_CHECK_EQUAL(eventin.event.data[0], 1); 
	BOOST_CHECK_EQUAL(eventin.event.data[1], i); 
	BOOST_CHECK_EQUAL(eventin.event.data[2], j); 
	
	BOOST_CHECK_EQUAL(eventin.event.data[3], firtgt >> 16); 
	BOOST_CHECK_EQUAL(eventin.event.data[4], firtgt &  0xFFFF); 

      }
    }


    /*
      Now, we set the status: 

    */ 
    for (int i = 0; i < AvailableFIRs::FILTERNUM; i++) {

	dsp::Event_t etx1; 
	etx1.cmd = 0x47; 
	etx1.src = 0x10; 
	etx1.data[0] = 3; 
	etx1.data[1] = i; 
	etx1.data[2] = true; 
	etx1.data[3] = 255; 
	etx1.data[4] = 0; 
	
	std::vector<bool> amask(80), bmask(80), cmask(80), dmask(80); 
	amask[0] = 1; 
	std::vector<dsp::Event_t> events(80); 
	events[0] = etx1; 
    
	uint16_t * buf = createEventBuffer(amask, bmask, cmask, dmask, events); 
	ed.parseECycleBuffer(buf); 
	while(ed.dispatchEvents()) {}; 
	BOOST_CHECK_EQUAL(firs.filterlens[i] & 0xFF, 0xFF); 
    }

    /* 
       Now verify  len, status, and filterid
    */


    for (int i = 0; i < AvailableFIRs::FILTERNUM; i++) {
      dsp::Event_t etx1; 
	etx1.cmd = 0x47; 
	etx1.src = 0x10; 
	etx1.data[0] = 2; 
	etx1.data[1] = i; 
	etx1.data[2] = 0; 
	etx1.data[3] = 0; 
	etx1.data[4] = 0; 
	
	std::vector<bool> amask(80), bmask(80), cmask(80), dmask(80); 
	amask[0] = 1; 
	std::vector<dsp::Event_t> events(80); 
	events[0] = etx1; 
    
	uint16_t * buf = createEventBuffer(amask, bmask, cmask, dmask, events); 
	ed.parseECycleBuffer(buf); 
	while(ed.dispatchEvents()) {}; 
	
 	BOOST_CHECK_EQUAL(etx.eventBuffer_.size(), 1); 
 	dsp::EventTX_t eventin = etx.eventBuffer_.front(); 
 	etx.eventBuffer_.pop_front(); 
	
 	BOOST_CHECK_EQUAL(eventin.event.cmd, FilterLinkController::FIR_RESP); 
	BOOST_CHECK_EQUAL(eventin.event.data[0], FilterLinkController::GET_STATUS); 
	BOOST_CHECK_EQUAL(eventin.event.data[1], i); 
 	BOOST_CHECK_EQUAL(eventin.event.data[2] & 0xFF, 255); 

	filterid_t fidtgt = filterids[i]; 
 	BOOST_CHECK_EQUAL(eventin.event.data[3], fidtgt >> 16); 
 	BOOST_CHECK_EQUAL(eventin.event.data[4], fidtgt & 0xFFFF); 
    }

}



BOOST_AUTO_TEST_SUITE_END(); 

