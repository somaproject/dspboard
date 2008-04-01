/*
 *
 *
 */


#include <cdefBF533.h>
#include <stdlib.h>
//#include <bf533/acqserial.h> 
#include <hw/memory.h> 

// class TestObject
// {
//  public: 
//   TestObject() : 
//   x(0x1234),
//   y(0x5678){
//   }

//   int x; 
//   int y; 
  

// }; 

#include <hw/uarttx.h>

void do_blink(void); 

void do_DMA_uarttx()
{
  // Test using our UART interfac module
  UARTTX * puart = new UARTTX; 
  puart->setup(); 
  
  char dataout[6]; 

  char byte = 0; 
  while(1) {

    // send in bursts of four
    for (int k = 0; k < 4; k++) {
      for (int i = 0; i < 6; i++) {
	dataout[i] = byte; 
	byte++; 
      }
      
      puart->sendWords(dataout); 
      while(! puart->checkSendDone()) {
// 	// pass 
 	int i = 0; 
	
       }
    }

    for (int i = 0; i < 100000000; i++)
      { // long delay so we can check
	int j = i; 
      }
    
  }

}
void do_DMA_uart()
{

  *pUART_GCTL = UCEN ; 

  *pUART_LCR = 0x0083; 
  // 125 MHz / 9600 = 13020.8 = 13021
  unsigned short NUM = 13021 / 16 ; 
  unsigned short NUML = NUM % 256; 
  unsigned short NUMH = NUM >> 8; 
  *pUART_DLL = NUML; 
  *pUART_DLH = NUMH; 
  
  char * dataout = new char[6]; 

  *pUART_LCR = 0x0003; 
  
  *pDMA7_PERIPHERAL_MAP = 0x7000; 

  // Set up the DMA channel, by default, channel 5 is SPI
  *pDMA7_NEXT_DESC_PTR = 0; 
  *pDMA7_CURR_DESC_PTR = 0; 
  *pDMA7_START_ADDR = 0; 

  *pDMA7_X_COUNT = 6; 
  *pDMA7_X_MODIFY = 1; 

  *pDMA7_Y_COUNT = 0; 
  *pDMA7_Y_MODIFY = 0; 

  *pDMA7_CONFIG = 0x0020; 

  // now set the pointer 
  *pDMA7_START_ADDR = dataout; 

  *pUART_IER = 2; 

  char byte = 0; 
  while(1) {
    for (int i = 0; i < 6; i++) {
      dataout[i] = byte; 
      byte++; 
    }
    *pDMA7_CONFIG |= 1; 
    
    for (int i = 0; i < 100000000; i++)
      {
	int j = i; 
      }
    
  }

}

void do_direct_uart()
{
  /* 
   Simply setup UART and send bytes over and over
    
  */ 
  *pUART_GCTL = UCEN ; 

  *pUART_LCR = 0x0083; 
  // 125 MHz / 9600 = 13020.8 = 13021
  unsigned short NUM = 13021 / 16 ; 
  unsigned short NUML = NUM % 256; 
  unsigned short NUMH = NUM >> 8; 
  *pUART_DLL = NUML; 
  *pUART_DLH = NUMH; 

  *pUART_LCR = 0x0003; 
  

  // now try and send a char or two
  while(1) {
    *pUART_THR = 0xA5; 
    for (int i = 0; i < 100000000; i++)
      {
	int j = i; 
      }
  }

}
int main()
{

  do_DMA_uarttx(); 
  
  while(1){ 
  } 

}

