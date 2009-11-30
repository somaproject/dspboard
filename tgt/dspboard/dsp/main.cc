/*
 *
 *
 */


#include <cdefBF533.h>
#include <event.h>
#include <hw/eventtx.h>
#include <hw/eventrx.h>
#include <hw/dspuartconfig.h>
#include <hw/acqserial.h> 
#include <hw/datasport.h> 
#include <hw/memory.h> 
#include <eventdispatch.h>
#include <dataout.h>
#include <acqstatecontrol.h>
#include <acqdatasource.h>
#include <acqdatasourcecontrol.h>
#include <fakesource.h>
#include <mainloops/noopmainloop.h>
#include <mainloops/rawmainloop.h>
#include <mainloops/somamainloop.h>
#include <mainloops/fakerawmainloop.h>
#include <mainloops/somastimmainloop.h>
#include <sinks/rawsink.h>
#include <sinks/tspikesink.h>
#include <filterlinks/delta.h>
#include <hw/misc.h>
#include <filter.h>
#include <memtestproc.h>
dspboard::AcqSerial * acqserial;  // global so we can get function wrappers for ISR. 


extern "C" {

  void __attribute__((interrupt_handler)) rxisr() 
  {
    acqserial->RXDMAdoneISR(); 

    short q = *pSIC_ISR;  // THIS HAS TO BE A SHORT FOR THE LOVE OF GOD

    // clear the relevant DMA bit
    *pDMA1_IRQ_STATUS = 0x1; 

  }
  
} 


class AmpCallbackFuncs
{
public: 
  AmpCallbackFuncs()  :
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

int main_loop()
{

  *pFIO_DIR    = 0x0100;
  *pFIO_FLAG_D = 0x0000;
  *pFIO_INEN   = 0x0000; 
  using namespace dspboard;
  DSPUARTConfig config; 
  
  /*     This code is legacy debugging code for when we find ourselves wanting
	 to write to a location in memory so we can use the ICEbear 
	 register memory dumping code to extract state 

	 uint32_t * ptr; 
	 ptr = (uint32_t *) 0xFF907FF0; 
	 *ptr = 0x12345678; 
	 ptr++; 
  */ 

//   // System interrupt Mask Register
  *pSIC_IMASK = 0x00; 

  *pSIC_IMASK |= 0x00000200;   // interrupt setup for acqserial

//   // System Interrupt Assignhment Registers
//   // This maps the System INterrupts to general-purpose interrupts. 

  // System interrup tassignment registers; assigns a system interrupt
  // to an interrupt hand;er. We zero them to start with. 
   *pSIC_IAR0 = 0x00000000; 
   *pSIC_IAR1 = 0x00000000; 
   *pSIC_IAR2 = 0x00000000; 

   *pSIC_IMASK = 0x00000000; 

   *pSIC_IMASK = 0x00000200;  // enable acqserial SPORT0 RX
   
   // Now set for acqserial
   *pSIC_IAR1 |= 0x00000010; // DMA1 SPORT0 RX is assigned to IVG8

//   // Core Event Controller Registers
   *pIMASK = 0x0000003F; // IVHW enabled
   
   // now also enable acqserial SPORT 0 rx IVG8
   *pIMASK |= 0x100;
  
   acqserial = new AcqSerial(); 
   acqserial->setup(); 


  DataOut * dataout =  new DataSPORT(); 

  EventTX * etx = new EventTX(); 
  etx->setup(); 
  etx->mysrc = config.getEventDevice(); 

  Benchmark * bm = new Benchmark(); 
  
  eventrx = new EventRX(); 
  eventrx->setup(); 

  EventDispatch * ed = new EventDispatch(config.getDSPPos()); 

  SystemTimer * timer = new SystemTimer(ed); 
  EventEchoProc * eep = new EventEchoProc(ed, etx, timer, bm, 
					  config.getEventDevice()); 
  
  // This is a total hack way of accomplishing this, but I don't have
  // the time to properly refactor this at the moment
  #if MAINLOOP == 1
  NoOpMainLoop * pMainLoop = new NoOpMainLoop(); 
  #elif MAINLOOP == 2
  SomaMainLoop * pMainLoop = new SomaMainLoop();
  #elif MAINLOOP == 3
  RawMainLoop * pMainLoop = new RawMainLoop();
  #elif MAINLOOP == 4
  SomaStimMainLoop * pMainLoop = new SomaStimMainLoop();
  #endif
  //MemTestProc * mtp = new MemTestProc(ed, etx, config.getEventDevice()); 
  //FakeRawMainLoop * pMainLoop = new FakeRawMainLoop();

  pMainLoop->setup(ed, etx, acqserial, timer, eep, dataout, &config); 
  acqserial->start(); 

  eventrx->start(); 
  uint16_t *  eventbuf = 0; 
  int framecount = 0; 
  uint16_t lasterror = 0; 
  somatime_t oldtime = timer->getTime(); 

  while (1) {

//     eep->benchStart(0);
    // ------------------------------------------------------------------
    // Event Processing, RX and TX 
    // ------------------------------------------------------------------

    bm->start(4); 
    //    setEventLED(true); 
    if (eventbuf == 0 and ! eventrx->empty()){ 
      eventbuf = eventrx->getReadBuffer(); 
      ed->parseECycleBuffer(eventbuf); 
    }
    
    for (char i = 0; i < 10; i++) { 
      if( eventbuf != 0 ) {
	if(ed->dispatchEvents()) // NOTE THAT DISPATCH EVENTS SHOULD BE CALLED MANY TIMES
	  // PER ECYCLE, so DONT DO MUCH DURING THIS LOOP
	  {
	    // do nothing, dispatch all the evnets
	  } else {
	    eventrx->doneReadBuffer(); 
	    eventbuf = 0; 
	    break; 
	  }
      }
    }
    //setEventLED(false); 

    eep->erx_errors = eventrx->errorCount; 
    bm->stop(4); 
    bm->start(5); 
    etx->sendEvent();       
    bm->stop(5); 

    // ------------------------------------------------------------------
    // Fiber interface for acqboard data
    // ------------------------------------------------------------------
    bm->start(2); 

    pMainLoop->runloop();
    bm->stop(2); 

    // -----------------------------------------------------------------
    // Data bus transmission
    // -----------------------------------------------------------------
    bm->start(3); 
    dataout->sendPending(); 
    bm->stop(3); 
  }
  

  

}

int main()
{

  main_loop(); 
  
}


