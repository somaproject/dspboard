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
#include <sinks/rawsink.h>
#include <sinks/tspikesink.h>
#include <filterlinks/delta.h>

#include "echoproc.h" 


AcqSerial * acqserial;  // global so we can get function wrappers for ISR. 


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

  DSPUARTConfig config; 
  
  

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
  //AcqSerial as; 
  acqserial->setup(); 


  DataOut * dataout = new DataSPORT(); 

  EventTX * etx = new EventTX; 
  etx->setup(); 
  etx->mysrc = config.getEventDevice(); 

  
  eventrx = new EventRX(); 
  eventrx->setup(); 

  EventDispatch * ed = new EventDispatch(config.getDSPPos()); 
  
  SystemTimer timer(ed); 
  EventEchoProc * eep = new EventEchoProc(ed, etx, &timer, config.getEventDevice()); 


  eventrx->start(); 

  AcqFrame af; 
  AcqState acqstate; 
  acqstate.linkUp = false; 
  AcqStateControl asc(acqserial, &acqstate); 
  asc.setDSPPos(config.getDSPPos()); 
  // filterlink construction
  AcqDataSource * acqdatasource = new AcqDataSource(&acqstate); 
  acqdatasource->setDSP(config.getDSPPos()); 
  AcqDataSourceControl * adsc = new AcqDataSourceControl(ed, etx, &asc); 

  //  FakeSource * fs = new FakeSource(&timer); 
//   RawSink * pRawSinkForFake = new RawSink(&timer, dataout, config.getDataSrc()); 
//   fs->source.connect(pRawSinkForFake->sink); 
//   RawSink * pRawSinkForFake2 = new RawSink(&timer, dataout, config.getDataSrc()); 
//   fs->source.connect(pRawSinkForFake2->sink); 

  RawSink * pRawSinkA = new RawSink(&timer, dataout, config.getDataSrc(), 0); 
  RawSink * pRawSinkB = new RawSink(&timer, dataout, config.getDataSrc(), 1); 
  RawSink * pRawSinkC = new RawSink(&timer, dataout, config.getDataSrc(), 2); 
  RawSink * pRawSinkD = new RawSink(&timer, dataout, config.getDataSrc(), 3); 
//   TSpikeSink * pTSpikeSink = new TSpikeSink(&timer, dataout, 
// 					    ed, etx, config.getDataSrc()); 
  //   Delta * deltaA = new Delta(); 
  

  //  fs->source.connect(pRawSinkA->sink);
//   acqdatasource->sourceA.connect(pTSpikeSink->sink1); 
//   acqdatasource->sourceB.connect(pTSpikeSink->sink2); 
//   acqdatasource->sourceC.connect(pTSpikeSink->sink3); 
//   acqdatasource->sourceD.connect(pTSpikeSink->sink4); 
//   acqdatasource->sourceSampleCycle.connect(pTSpikeSink->samplesink); 


  acqdatasource->sourceA.connect(pRawSinkA->sink); 
  acqdatasource->sourceB.connect(pRawSinkB->sink); 
  acqdatasource->sourceC.connect(pRawSinkC->sink); 
  acqdatasource->sourceD.connect(pRawSinkD->sink); 

  acqserial->start(); 

  uint16_t *  eventbuf = 0; 
  int framecount = 0; 
  while (1) {

    eep->benchStart(0);
    // ------------------------------------------------------------------
    // Event Processing, RX and TX 
    // ------------------------------------------------------------------

    if (eventbuf == 0 and ! eventrx->empty()){ 
      eventbuf = eventrx->getReadBuffer(); 
      ed->parseECycleBuffer(eventbuf); 
    }

    if( eventbuf != 0 ) {
      if(ed->dispatchEvents())
	{
 	  // do nothing, dispatch all the evnets
	} else {
	  eventrx->doneReadBuffer(); 
	  eventbuf = 0; 
	}
    }
    
    etx->sendEvent();       

    // ------------------------------------------------------------------
    // Fiber interface for acqboard data
    // ------------------------------------------------------------------

    asc.setLinkStatus(acqserial->checkLinkUp()); 
    if (! acqserial->checkRxEmpty())
      {
	//*pFIO_FLAG_T = 0x0100;
	eep->debugdata[0] = af.cmdid; 
	eep->debugdata[1] = asc.sequentialCMDID_; 

	acqserial->getNextFrame(&af); 
	asc.newAcqFrame(&af); 
	// trigger the set of filterlinks
	eep->benchStart(1);
	acqdatasource->newAcqFrame(&af); 
	eep->benchStop(1);
	


// 	framecount++; 
// 	if (framecount %  32000 == 1000) {
// 	  asc.setGain(1, 100, 
// 		      fastdelegate::MakeDelegate(&cfs, &AmpCallbackFuncs::CommandDone), 
// 		      0x1234); 
// 	}
      }

    // -----------------------------------------------------------------
    // Data bus transmission
    // -----------------------------------------------------------------
    dataout->sendPending(); 

    eep->benchStop(0); 

  }
  
   
}

int main()
{

  main_loop(); 
  
}

