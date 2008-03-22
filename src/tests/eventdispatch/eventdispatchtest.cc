#include <boost/test/floating_point_comparison.hpp>
#include <boost/test/unit_test.hpp>
#include <iostream>
#include <vector> 
#include "event.h"
#include "eventdispatch.h"
#include <FastDelegate.h> 


BOOST_AUTO_TEST_SUITE(eventdispatch_test); 

//uint16_t * createEvents(

class EventHandler {
  
public:
  void processEvent(Event_t * e) {
    events_.push_back(*e); 
  }
  
  std::vector<Event_t> events_; 
  
}; 

uint16_t * createEventBuffer(std::vector<bool> amask, std::vector<bool> bmask, 
		       std::vector<bool> cmask, std::vector<bool> dmask, 
		       std::vector<Event_t> events)
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
  for (std::vector<Event_t>::iterator i = events.begin(); i!= events.end(); i++)
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
		       

BOOST_AUTO_TEST_CASE(eventdispatch_compile)
{

  uint16_t testframe[] = {0xbc00, 0x0300, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001, 0x0000,
			  0x0000, 0x0000, 0x0000, 0x0000, 0x0100, 0x0000, 0x0000, 0x0000,
			  0x0000, 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
			  0x1000, 0x0000, 0xde8e, 0x8ce6, 0x0000, 0x0000, 0xa201, 0x0100,
			  0x0003, 0x3df8, 0x0000, 0x0008, 0x9402, 0x0000, 0x0000, 0x0000, 
			  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000}; 
  uint16_t testframe2[512]; 
  
  for (int i = 0; i < 32; i++) {
    testframe2[i] = testframe[i]; 
  }
  
  EventDispatch ed(DSPA);
  EventHandler eh; 
  
  ed.registerCallback(0x10, fastdelegate::MakeDelegate(&eh, &EventHandler::processEvent)); 
  ed.registerCallback(0xa2, fastdelegate::MakeDelegate(&eh, &EventHandler::processEvent)); 

  ed.parseECycleBuffer(testframe2); 
  
  while(ed.dispatchEvents() ); 
  
  BOOST_CHECK_EQUAL(eh.events_.size(), 2); 
  BOOST_CHECK_EQUAL(eh.events_[0].cmd, 0x10); 
  BOOST_CHECK_EQUAL(eh.events_[0].src,  0x00); 
  BOOST_CHECK_EQUAL(eh.events_[0].data[1], 0xde8e); 
  BOOST_CHECK_EQUAL(eh.events_[0].data[2], 0x8ce6); 

}



BOOST_AUTO_TEST_CASE(complexcheck) 
{
  // complex semi-random patterns of events
  std::vector<std::vector<bool> > masks; 
  masks.push_back(std::vector<bool>()); 
  masks.push_back(std::vector<bool>()); 
  masks.push_back(std::vector<bool>()); 
  masks.push_back(std::vector<bool>()); 

  std::vector<Event_t> events; 

  for (int i = 0; i < 78; i++) {
    if (i % 2 == 0) {
      masks[0].push_back(true); 
    } else {
      masks[0].push_back(false); 
    }

    if (i % 3 == 0) {
      masks[1].push_back(true); 
    } else {
      masks[1].push_back(false); 
    }

    if (i % 4 == 0) {
      masks[2].push_back(true); 
    } else {
      masks[2].push_back(false); 
    }

    if (i % 6 == 0) {
      masks[3].push_back(true); 
    } else {
      masks[3].push_back(false); 
    }
    
  }
  masks[0].push_back(false); 
  masks[0].push_back(false); 
  
  masks[1].push_back(false); 
  masks[1].push_back(false); 
  
  masks[2].push_back(false); 
  masks[2].push_back(false); 
  
  masks[3].push_back(false); 
  masks[3].push_back(false); 
  

  // now populate all the events
  for (int i = 0; i < 78; i++) {
    Event_t evt; 
    evt.cmd = (i*2 + 1) % 256; 
    evt.src = (i*2 + 14) % 256; 
    for (int j = 0; j < 5; j++) {
      evt.data[j] = i * 12 + j * 0x1234 + j ;  
    }
    events.push_back(evt); 
  }

  uint16_t * testframe = createEventBuffer(masks[0], masks[1], masks[2], masks[3], events); 
  
  DSP_POSITION dsppos[] = {DSPA, DSPB, DSPC, DSPD}; 

  for (int dspposi = 0; dspposi < 4; dspposi++) {
    EventDispatch ed(dsppos[dspposi]);
    EventHandler eh; 
    
    // register all the callbacks
    for (int i = 0; i < 255; i++) {
      ed.registerCallback(i, fastdelegate::MakeDelegate(&eh, &EventHandler::processEvent)); 
    }
    
    ed.parseECycleBuffer(testframe); 
    
    while(ed.dispatchEvents() ); 
    
    int numevents = 0; 
    for (int i =0; i < 80; i++) {
      if (masks[dspposi][i] == 1)
	numevents++; 
    }
    BOOST_CHECK_EQUAL(eh.events_.size(), numevents); 
    
    for (int i = 0; i < 512; i++) {
      
    } 
    
    int epos = 0;
    for (int i = 0; i < 78; i++) {
      if (masks[dspposi][i] == 1 ) {
	//std::cout << (int)(eh.events_[epos].cmd) << std::endl; 
	BOOST_CHECK_EQUAL(eh.events_[epos].cmd,  i * 2 + 1); 
	BOOST_CHECK_EQUAL(eh.events_[epos].src,  i * 2 + 14); 
	BOOST_CHECK_EQUAL(eh.events_[epos].data[0],  i * 12 ); 
	for (int j = 0; j  < 5 ; j++) { 
	BOOST_CHECK_EQUAL(eh.events_[epos].data[j], i * 12 + j*0x1234   + j ); 
	}
	epos++; 
      }
    }
  }
  
}


BOOST_AUTO_TEST_SUITE_END()
