#include "uarttx.h"

namespace dspboard { 
UARTTX::UARTTX() {
}

void UARTTX::setup() {
  setupUART(); 
  setupDMA(); 

}

void UARTTX::setupUART()
{
  *pUART_GCTL = UCEN ; 

  *pUART_LCR = 0x0083; 
  // 125 MHz / 9600 = 13020.8 = 13021
  unsigned short NUM = 13021 / 16 ; 
  unsigned short NUML = NUM % 256; 
  unsigned short NUMH = NUM >> 8; 
  *pUART_DLL = NUML; 
  *pUART_DLH = NUMH; 
  
  *pUART_LCR = 0x0003; 
  

}

void UARTTX::setupDMA()
{
  *pDMA7_CONFIG = 0; 

  *pDMA7_PERIPHERAL_MAP = 0x7000; 

  // Set up the DMA channel, by default, channel 7 is UART TX
  *pDMA7_NEXT_DESC_PTR = 0; 
  *pDMA7_CURR_DESC_PTR = 0; 

  *pDMA7_X_COUNT = 6; 
  *pDMA7_X_MODIFY = 1; 

  *pDMA7_Y_COUNT = 0; 
  *pDMA7_Y_MODIFY = 0; 

  *pDMA7_CONFIG = 0x00A0; 

  // now set the pointer 
  *pDMA7_START_ADDR = &txBuffer_[0]; 

  *pUART_IER = 2; 

}

void UARTTX::sendWords(char * c)
{

  for (int i = 0; i < 6; i++) {
    txBuffer_[i] = *c;
    ++c; 
  }
   
  *pDMA7_CONFIG |= 1; 
  

}

bool UARTTX::checkSendDone()
{
  if ((*pDMA7_IRQ_STATUS & 0xF) == 0x1) {
    // if done and not running
    *pDMA7_IRQ_STATUS |= 0x01; 
    return true; 
  } else {
    return false;     
  }


}

}
