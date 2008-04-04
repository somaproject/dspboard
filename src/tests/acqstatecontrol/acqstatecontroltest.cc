#include <boost/test/unit_test.hpp>

#include <boost/test/auto_unit_test.hpp>

#include <hw/acqserial.h>
#include <acqstatecontrol.h>

BOOST_AUTO_TEST_SUITE(acqstatecontrol_test); 

class CallbackFuncs
{
public: 
  CallbackFuncs()  :
    linkUp_(false), 
    linkChangeNum_(0), 
    latestHandle_(0)
  { } 
  bool linkUp_; 
  int linkChangeNum_; 
  void LinkChange(bool lu) {
    linkUp_ = lu; 
    linkChangeNum_++; 
  }
  
  short latestHandle_; 
  bool lastSuccess_; 
  int doneNum_; 
  
  void CommandDone(short handle, bool success) {
    latestHandle_ = handle; 
    lastSuccess_ = success; 
    doneNum_++; 
  }

}; 

BOOST_AUTO_TEST_CASE(simple_linkup_test)
{
  AcqSerial acqs; 
  AcqState as; 

  AcqStateControl asc(&acqs, &as); 
  asc.setDSPPos(DSPA); 
  
  CallbackFuncs cfs; 
  // now, setup the callbacks
  
  asc.setLinkChangeCallback(fastdelegate::MakeDelegate(&cfs, 
						       &CallbackFuncs::LinkChange)); 
  

  asc.setLinkStatus(true); 
  BOOST_CHECK_EQUAL(cfs.linkUp_, true); 
  BOOST_CHECK_EQUAL(cfs.linkChangeNum_, 1); 

}


BOOST_AUTO_TEST_CASE(simple_gain_test)
{
  AcqSerial acqs; 
  AcqState as; 

  AcqStateControl asc(&acqs, &as); 
  asc.setDSPPos(DSPA); 
  
  CallbackFuncs cfs; 

  asc.setLinkStatus(true); // bring up the interface

  AcqFrame af;  // update mode
  acqs.getNextFrame(&af); 
  asc.newAcqFrame(&af); 


  // now, setup the callbacks
  asc.setGain((char)0x0F, 100, 
	      fastdelegate::MakeDelegate(&cfs, &CallbackFuncs::CommandDone), 
	      0x1234); 

  while(1) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      if (cfs.latestHandle_ == 0x1234) {
	break; 
      }
    }

  }
  BOOST_CHECK_EQUAL(acqs.gains_[0], 1); 
  BOOST_CHECK_EQUAL(acqs.gains_[1], 1); 
  BOOST_CHECK_EQUAL(acqs.gains_[2], 1); 
  BOOST_CHECK_EQUAL(acqs.gains_[3], 1); 


}

BOOST_AUTO_TEST_CASE(simple_hpf_test)
{
  AcqSerial acqs; 
  AcqState as; 

  AcqStateControl asc(&acqs, &as); 
  asc.setDSPPos(DSPA); 
  
  CallbackFuncs cfs; 

  asc.setLinkStatus(true); // bring up the interface


  AcqFrame af;  // update mode
  acqs.getNextFrame(&af); 
  asc.newAcqFrame(&af); 



  // now, setup the callbacks
  asc.setHPF((char)0x05, 1, 
	      fastdelegate::MakeDelegate(&cfs, &CallbackFuncs::CommandDone), 
	      0x1122); 

  while(1) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      if (cfs.latestHandle_ == 0x1122) {
	break; 
      }
    }

  }
  BOOST_CHECK_EQUAL(acqs.hpfs_[0], 1); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[1], 0); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[2], 1); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[3], 0); 


}

BOOST_AUTO_TEST_CASE(simple_hpf_test_linkdown)
{
  // what happens when we disconnect the link in the middle of all 
  // of this

  AcqSerial acqs; 
  AcqState as; 

  AcqStateControl asc(&acqs, &as); 
  asc.setDSPPos(DSPA); 
  
  CallbackFuncs cfs; 

  asc.setLinkStatus(true); // bring up the interface

  AcqFrame af;  // update mode
  acqs.getNextFrame(&af); 
  asc.newAcqFrame(&af); 

  acqs.hpfs_[0] = 0; 
  acqs.hpfs_[1] = 0; 
  acqs.hpfs_[2] = 0; 
  acqs.hpfs_[3] = 0; 

  // now, setup the callbacks
  asc.setHPF((char)0x07, 1, 
	      fastdelegate::MakeDelegate(&cfs, &CallbackFuncs::CommandDone), 
	      0x1122); 
  while(1) {
    if (! acqs.checkRxEmpty()){
      AcqFrame af; 
      acqs.getNextFrame(&af); 
      asc.newAcqFrame(&af); 
      if (acqs.hpfs_[1] == 1) {
	asc.setLinkStatus(false); 
      }
      if (cfs.latestHandle_ == 0x1122) {
	break; 
      }
    }

  }

  BOOST_CHECK_EQUAL(cfs.lastSuccess_, false); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[0], 1); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[1], 1); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[2], 0); 
  BOOST_CHECK_EQUAL(acqs.hpfs_[3], 0); 


}


BOOST_AUTO_TEST_SUITE_END(); 

