#include "datasport.h"
#include <cdefBF533.h>

uint8_t DataSPORT::buffer_[DATABUFLEN][BUFSIZE]  ; 

DataSPORT::DataSPORT() :
  nextFreeData_(0), 
  nextSendData_(0), 
  txPending_(false), 
  delay_(0)
{
  setup(); // automatically setup

}

void DataSPORT::setup()
{
  setupFPGAFIFOFlag(); 
  setupDMA(); 
  setupSPORT(); 

}

void DataSPORT::sendData(Data_t & data)
{
  // copy data into next packet...
  if (! txBufferFull()) {
    data.toBuffer(&buffer_[nextFreeData_][0]); 

    nextFreeData_ = (nextFreeData_+1) % DATABUFLEN; 
  }
  
}

bool DataSPORT::txBufferFull() {
  if (((nextFreeData_ + 2) % DATABUFLEN) == nextSendData_) {
    return true; 
  }
  return false; 
}

bool DataSPORT::isFPGAFIFOFull() 
{
  return (*pFIO_FLAG_D & DATAFIFOFULL_MASK); 
}

bool DataSPORT::isSPORTHoldRegEmpty()
{
  /*
    
  
  */
  if(SPORT1_STAT & TXHRE == 0) {
    return false; 
  } else {
    return true;
  }
}

void DataSPORT::sendPending()
{
  if (txPending_) {
    if (isDMADone()) {
      txPending_ = false; 
      // FIXME DEBUGGING LED flashes when DMA is done
      *pFIO_DIR    |= 0x0100;
      *pFIO_FLAG_D |= 0x0100;
      delay_ = 9; 
    } else {
      return;  // DMA still pending
    } 
  }
//   if (delay_ > 0) {
//     delay_--; 
//     return; 
//   } 
  if (!isSPORTHoldRegEmpty()) {
    return; 
  }

  *pFIO_FLAG_D &= ~0x0100;

  if (isFPGAFIFOFull() ) {
    return; 
  }

  // else, we're good to send! 
  if ( nextSendData_ != nextFreeData_) {
    sendDataNum(nextSendData_); 
    txPending_ = true; 
    nextSendData_ = (nextSendData_ + 1) % DATABUFLEN; 
  }
}



void DataSPORT::sendDataNum(int n)
{
  // reset the counters
  *pSPORT1_TCR1 = 0x0000; 
  
  *pDMA4_START_ADDR = &buffer_[n][0]; 

  *pDMA4_CONFIG = 0x0081; 
  
  *pSPORT1_TCR2 = 0x0007; // 8-bit length
  *pSPORT1_TCR1 = 0x4211; // enable sport TX
  
}


void DataSPORT::setupDMA()
{
  
  *pDMA4_CONFIG = 0x0080; 

  *pDMA4_PERIPHERAL_MAP = 0x4000; 
  
  *pDMA4_X_COUNT = 1024; 
  *pDMA4_X_MODIFY = 0x01; //  one-byte stride
  *pDMA4_Y_COUNT = 0; // 
  *pDMA4_Y_MODIFY = 0; // 
  *pDMA4_CURR_DESC_PTR = 0x00; 
  
}

void DataSPORT::setupSPORT()
{

  *pSPORT1_TCR2 = 0x0000; // 8-bit word length
  *pSPORT1_MCMC2  = 0x0000; 
  *pSPORT1_TFSDIV = 0x0000; 

}

void DataSPORT::setupFPGAFIFOFlag()
{

  *pFIO_DIR    &= ~DATAFIFOFULL_MASK; 
  *pFIO_INEN   |= DATAFIFOFULL_MASK; 

}

bool DataSPORT::isDMADone()
{
  if ( !(*pDMA4_IRQ_STATUS & DMA_DONE) ) {
    return false;
  } else {
    *pDMA4_IRQ_STATUS = 0x01; // clear IRQ status

    return true; 
  }

}
