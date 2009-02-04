#include <boost/test/unit_test.hpp>

#include <boost/test/auto_unit_test.hpp>

#include <hw/acqserial.h>
#include <acqstatecontrol.h>
#include "mock_receiver.h"

BOOST_AUTO_TEST_SUITE(acqstatecontrol_test); 


BOOST_AUTO_TEST_CASE(simple_linkup_test)
{
  AcqSerial acqs(true); 
  AcqState as; 
  
  MockReceiver mockReceiver; 

  AcqStateControl asc(&acqs, &as); 
  asc.setAcqStateReceiver(&mockReceiver); 
  asc.setDSPPos(DSPA); 
  
  asc.setLinkStatus(true); 
  for (int i = 0; i < 10; i++) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      if(asc.isReady() == true) {
	break; 
      }
      
    }
    
  }
  
  BOOST_CHECK_EQUAL(mockReceiver.linkChanges.size(), 
		    1); 
  BOOST_CHECK_EQUAL(mockReceiver.linkChanges[0], true); 
}


BOOST_AUTO_TEST_CASE(simple_linkup_state_initialize)
{
  /*
    1. set the acqstate to some random values. 
    2. set the link up
    3. check if the acqstates have been reset

  */ 
  AcqSerial acqs(true); 
  AcqState as; 

  // Set to a bunch of wrong values
  as.mode = 7; 
  as.gain[0] = -1; 
  as.gain[1] = -1; 
  as.gain[2] = -1; 
  as.gain[3] = -1; 
  as.gain[4] = -1; 

  as.hpfen[0] = false; 
  as.hpfen[1] = true; 
  as.hpfen[2] = false; 
  as.hpfen[3] = true; 
  as.hpfen[4] = true; 

  as.inputSel = 7; 

  MockReceiver mockReceiver; 

  AcqStateControl asc(&acqs, &as); 
  asc.setAcqStateReceiver(&mockReceiver); 

  asc.setDSPPos(DSPA); 
  
  // call the linkups
  asc.setLinkStatus(true); 

  
  while(1) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      if(asc.isReady() == true) {
	break; 
      }
      
    }

  }

  BOOST_CHECK_EQUAL(mockReceiver.linkChanges.size(), 1);
  if (mockReceiver.linkChanges.size() > 0) {
    BOOST_CHECK_EQUAL(mockReceiver.linkChanges[0], true); 
  }
  BOOST_CHECK_EQUAL(as.mode, 0); 
  for (int i = 0; i < 5; i++) {
    BOOST_CHECK_EQUAL(as.gain[i], 0); 
    BOOST_CHECK_EQUAL(as.hpfen[i], false); 
  }
  
  BOOST_CHECK_EQUAL(as.inputSel, 0); 

  
}




BOOST_AUTO_TEST_CASE(simple_gain_test)
{
  AcqSerial acqs(true); 
  AcqState as; 
  
  MockReceiver mockReceiver; 

  AcqStateControl asc(&acqs, &as); 
  asc.setAcqStateReceiver(&mockReceiver); 

  asc.setDSPPos(DSPA); 
  
  asc.setLinkStatus(true); // bring up the interface

  AcqFrame af;  // update mode
  acqs.getNextFrame(&af); 
  asc.newAcqFrame(&af); 

  bool enables[5]; 
  enables[0] = true; 
  enables[1] = false; 
  enables[2] = true; 
  enables[3] = false; 
  enables[4] = true; 

  while(1) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      if(mockReceiver.count > 1 and asc.isReady()) {
	break; 
      }
    }

  }
  std::cout << "ABOUT TO SET ---------------------------------------------------"
	    << std::endl; 

  std::cout << "-------------------------------------------------------"
	    << std::endl; 

  // now, setup the callbacks
  BOOST_CHECK_EQUAL(asc.setGain(enables, 100), true); 

  while(1) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      std::cout << "mockReceiver.count = " << mockReceiver.count << std::endl; 
      if(mockReceiver.count > 5) {
	break; 
      }
    }

  }
  BOOST_CHECK_EQUAL(acqs.gains_[0], 1); 
  BOOST_CHECK_EQUAL(acqs.gains_[1], 0); 
  BOOST_CHECK_EQUAL(acqs.gains_[2], 1); 
  BOOST_CHECK_EQUAL(acqs.gains_[3], 0); 
  BOOST_CHECK_EQUAL(acqs.gains_[4], 1); 

  
}


BOOST_AUTO_TEST_CASE(simple_hpf_test)
{
  AcqSerial acqs(true); 
  AcqState as; 


  MockReceiver mockReceiver; 

  AcqStateControl asc(&acqs, &as); 
  asc.setAcqStateReceiver(&mockReceiver); 

  asc.setDSPPos(DSPA); 
  
  asc.setLinkStatus(true); // bring up the interface

  AcqFrame af;  // update mode
  acqs.getNextFrame(&af); 
  asc.newAcqFrame(&af); 

  bool enables[5]; 
  enables[0] = true; 
  enables[1] = false; 
  enables[2] = true; 
  enables[3] = false; 
  enables[4] = true; 

  while(1) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      if(mockReceiver.count > 1 and asc.isReady()) {
	break; 
      }
    }

  }

  // now, setup the callbacks
  asc.setHPF(enables, true); 

  while(1) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      if(mockReceiver.count > 5) {
	break; 
      }
    }

  }
  BOOST_CHECK_EQUAL(acqs.hpfs_[0], 1); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[1], 0); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[2], 1); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[3], 0); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[4], 1); 

  asc.setHPF(enables, false); 

  while(1) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      if(mockReceiver.count > 6) {
	break; 
      }
    }

  }
  BOOST_CHECK_EQUAL(acqs.hpfs_[0], 0); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[1], 0); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[2], 0); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[3], 0); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[4], 0); 


}



// BOOST_AUTO_TEST_CASE(simple_hpf_test_linkdown)
// {
//   // what happens when we disconnect the link in the middle of all 
//   // of this

//   AcqSerial acqs(true); 
//   AcqState as; 


//   MockReceiver mockReceiver; 

//   AcqStateControl asc(&acqs, &as); 

//   asc.setDSPPos(DSPA); 
  
//   asc.setLinkStatus(true); // bring up the interface

//   AcqFrame af;  // update mode
//   acqs.getNextFrame(&af); 
//   asc.newAcqFrame(&af); 

//   acqs.hpfs_[0] = 0; 
//   acqs.hpfs_[1] = 0; 
//   acqs.hpfs_[2] = 0; 
//   acqs.hpfs_[3] = 0; 
//   acqs.hpfs_[4] = 0; 

//   bool enables[5]; 
//   enables[0] = true; 
//   enables[1] = false; 
//   enables[2] = true; 
//   enables[3] = false; 
//   enables[4] = true; 

//   while(1) {
//     if (! acqs.checkRxEmpty()){
//       AcqFrame af; 
//       acqs.getNextFrame(&af); 
//       asc.newAcqFrame(&af); 
//       if(mockReceiver.count > 1 and asc.isReady()) {
// 	break; 
//       }
//     }

//   }

//   // now, setup the callbacks
//   asc.setHPF(enables, true); 

//   while(1) {
//     if (! acqs.checkRxEmpty()){
//       AcqFrame af; 
//       acqs.getNextFrame(&af); 
//       asc.newAcqFrame(&af); 
//       if (acqs.hpfs_[1]) {
// 	asc.setLinkStatus(false); 
//       }

//       if(mockReceiver.count > 1) {
// 	break; 
//       }
//     }

//   }

//   //BOOST_CHECK_EQUAL(cfs.lastSuccess_, false); 
//   BOOST_CHECK_EQUAL(acqs.hpfs_[0], true); 
//   BOOST_CHECK_EQUAL(acqs.hpfs_[1], false); 
//   BOOST_CHECK_EQUAL(acqs.hpfs_[2], true); 
//   BOOST_CHECK_EQUAL(acqs.hpfs_[3], false); 
//   BOOST_CHECK_EQUAL(acqs.hpfs_[4], true); 


// }


BOOST_AUTO_TEST_SUITE_END(); 

