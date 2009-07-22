#include <cdefBF533.h>
#include "dspuartconfig.h"

namespace dspboard { 

DSPUARTConfig::DSPUARTConfig() :
  pos_(DSPNONE), 
  device_(255)
{
  // set up serial , read in N bytes, parse, done
  enableSerial(); 
  readAndParseBytes(); 
  disableSerial(); 
}

void DSPUARTConfig::enableSerial()
{

  *pUART_LCR = 0x0083; 
  // 125 MHz / 9600 = 13020.8 = 13021
  unsigned short NUM = 13021 / 16 ; 
  unsigned short NUML = NUM % 256; 
  unsigned short NUMH = NUM >> 8; 
  *pUART_DLL = NUML; 
  *pUART_DLH = NUMH; 
  
  *pUART_LCR = 0x0003; 

  *pUART_IER = 0; 

  *pUART_GCTL = UCEN ; 
 
}

void DSPUARTConfig::disableSerial()
{
  *pUART_GCTL = ~UCEN ; 


}

void DSPUARTConfig::readAndParseBytes()
{
  // should block here to get config information from FPGA via UART
  const int BYTENUM = 1; 
  unsigned char buffer[BYTENUM]; 

  for (short i = 0; i < BYTENUM; i++) {
    while(! (*pUART_LSR & DR) ) 
      {// spin
      }
    unsigned char tmp; 
    tmp = *pUART_RBR; 
    buffer[i] = tmp; 
  }
  
  device_ = buffer[0];  
  datasrc_ = device_ - 8; // data devices are offset 8

  switch (device_ % 4) {
  case 0:
    pos_ = DSPA; 
    break; 
  case 1:
    pos_ = DSPB; 
    break; 
  case 2:
    pos_ = DSPC; 
    break; 
  case 3:
    pos_ = DSPD; 
    break; 
  default:
    pos_ = DSPNONE; 
  }

  
}

unsigned char DSPUARTConfig::getEventDevice()
{
  return device_; 
}

unsigned char DSPUARTConfig::getDataSrc()
{
  return datasrc_; 
}

}
