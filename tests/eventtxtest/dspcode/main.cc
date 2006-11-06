/*
 *
 *
 */

#include <cdefBF533.h>

unsigned char outarray[600]; 

void sendSPORTBurst(unsigned char * x) 
{
  // first, make sure we can modify the registers
  *pSPORT0_TCR1 = 0x0000; 

  *pSPORT0_TCR2 = 0x0007; // 8-bit word length
  *pSPORT0_MCMC2  = 0x0000; // make sure multichannel mode is disabled


  // configure SPI DMA
  *pDMA2_PERIPHERAL_MAP = 0x2000; 
  
  *pDMA2_START_ADDR = x; 
  *pDMA2_X_COUNT = 600; 
  *pDMA2_X_MODIFY = 0x01; //  one-byte stride
  *pDMA2_Y_COUNT = 0; // 
  *pDMA2_Y_MODIFY = 0; // 
  *pDMA2_CURR_DESC_PTR = 0x00; 
  
  *pDMA2_CONFIG = 0x0001;  // start dma, 2D
  
  *pSPORT0_TFSDIV = 0x0000; 
  *pSPORT0_TCR1 = 0x4211; // enable sport TX// TEST TO USE TFS ON EACH FRAME

  

  for (int p = 0; p < 100000; p++)
    {
      p++; 
    }
}

int main()
{
  int i = 0; 
  int k = 0; 
  int a, b, c, d, e, f, g, h; 

  // zero memory

  for (int y = 0 ; y < 600; y++) {
    outarray[y] = y % 256; 
  }

  sendSPORTBurst(outarray) ; 
    
  for (int y = 0 ; y < 600; y++) {
    outarray[y] = (2*y) % 256; 
  }
  sendSPORTBurst(outarray) ; 
    

   
  while(1); 

  
}


