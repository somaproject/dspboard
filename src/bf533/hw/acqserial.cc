#include <hw/acqserial.h>
#include <hw/memory.h>
#include <types.h>
#include <cdefBF533.h>

AcqSerial::AcqSerial() :
  curRXpos_(0), 
  curReadPos_(0),
		       totalRXBufCnt_(0)//,
  //  pUARTTX_(new UARTTX)
{
  curRXpos_ = 0; 
  curReadPos_ = 0; 

}

void AcqSerial::setup()
{
  setupLink(); 
  setupSPORT(); 
  setupDMA(); 
  //  pUARTTX_->setup(); 
  pUARTTX_.setup(); 

}
void AcqSerial::setupSPORT()
{
  // first, make sure we can modify the registers
  *pSPORT0_TCR1 = 0x0000;
  *pSPORT0_RCR1 = 0x0000;

  // configure SPORT
  *pSPORT0_RCR2 = 0x000F; // 16-bit word length
  *pSPORT0_TCR2 = 0x000F; // 16-bit word length
  
  // multichannel
  *pSPORT0_MCMC1 = 0x1000; // window size of 16 words
  *pSPORT0_MRCS0 = 0x0000FFFF; //
  *pSPORT0_MRCS1 = 0x00000000; //
  *pSPORT0_MTCS0 = 0x0000FFFF; 
  *pSPORT0_MTCS1 = 0x00000000; 
  *pSPORT0_MCMC2 = 0x1010; // enable mode, one bit after 

} 

void AcqSerial::setupDMA()
{

    // configure SPORT DMA input channel

   *pDMA1_PERIPHERAL_MAP = 0x1000;

   *pDMA1_START_ADDR = &RXbuffer_[0]; 
   *pDMA1_X_COUNT = 16;
   *pDMA1_X_MODIFY = 0x02; // two byte stride
   *pDMA1_Y_COUNT = RXBUFLEN_; //
   *pDMA1_Y_MODIFY = 2; //
   *pDMA1_CURR_DESC_PTR = 0x00;

    // configure SPORT DMA output channel
//    *pDMA2_PERIPHERAL_MAP = 0x2000;

//    *pDMA2_START_ADDR = &TXBuffer_[0]; 
//    *pDMA2_X_COUNT = 4;
//    *pDMA2_X_MODIFY = 0x02; // two byte stride
//    *pDMA2_Y_COUNT = 0;  //
//    *pDMA2_Y_MODIFY = 0; //
//    *pDMA2_CURR_DESC_PTR = 0x00;
   
}

void AcqSerial::start() 
{

  // because the blackfin likes to kick me, 
  // we very clearly have to do a short assignment here
  // to avoid triggering a hardware interrupt

  *pDMA1_CONFIG = 0x10F7;  // start input dma, 2D, autobufferin

  *pSPORT0_RCR1 = 0x4011; // enable sport RX
  *pSPORT0_TCR1 = 0x4011; // enable sport TX//   outbuf[0] = 0xAA; 
//   outbuf[1] = 0xBB; 
//   outbuf[2] = 0xCC; 
//   outbuf[3] = 0xDD; 
//   outbuf[4] = 0xEE; 
//   outbuf[5] = 0xFF; 

}

void AcqSerial::stop()
{
   *pSPORT0_RCR1 = 0x0000; // disable sport RX
   *pSPORT0_TCR1 = 0x0000; // disable sport TX

}
bool AcqSerial::checkLinkUp()
{
  return (*pFIO_FLAG_D & FIBERLINKUP_MASK); 

}


bool AcqSerial::checkRxEmpty()
{
  if (curRXpos_ == curReadPos_) {
    return true; 
  }    else {
    return false; 
  }
}

void AcqSerial::getNextFrame(AcqFrame * af)
{
  // perform the copy 
  unsigned char cmdstsbyte = RXbuffer_[curReadPos_ * 16] & 0xFF; 
  af->mode = cmdstsbyte >> 1; 
  af->loading = cmdstsbyte & 0x1; 
  
  unsigned char cmdidbyte =  (RXbuffer_[curReadPos_ * 16] >> 8)  & 0xFF; 
  af->cmdid = cmdidbyte & 0xF; 

  if (cmdidbyte & 0x80) {
    af->success = true; 
  } else {
    af->success = false;
  }
  
  for(short i = 0; i <10; i++){
    af->samples[i] = RXbuffer_[curReadPos_ * 16 + i +1]; 
  }
  
  curReadPos_ = (curReadPos_ +1) % RXBUFLEN_; 
  
  
}

void AcqSerial::sendCommand(AcqCommand * ac)
{
  
  char outbuf[6]; 


  outbuf[0] =  ((ac->cmdid & 0xF) << 4) | (ac->cmd & 0xF); 
  outbuf[1] = (ac->data >> 24) & 0xFF; 
  outbuf[2] = (ac->data >> 16) & 0xFF; 
  outbuf[3] = (ac->data >> 8) & 0xFF; 
  outbuf[4] = (ac->data >> 0) & 0xFF; 

  pUARTTX_.sendWords(outbuf); 

}

bool AcqSerial::sendCommandDone()
{
  return pUARTTX_.checkSendDone(); 
}

void AcqSerial::setupLink()
{

  *pFIO_DIR    &= ~FIBERLINKUP_MASK; 
  *pFIO_INEN   |= FIBERLINKUP_MASK; 

}
