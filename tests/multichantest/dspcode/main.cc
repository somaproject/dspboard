/*
 *
 *
 */

#include <cdefBF533.h>

unsigned short inarray[16]; 

int main()
{
  int i = 0; 
  int k = 0; 
  int a, b, c, d, e, f, g, h; 


  // first, make sure we can modify the registers
  *pSPORT0_TCR1 = 0x0000; 
  *pSPORT0_RCR1 = 0x0000; 

// enable settings

  // require RFS for every word
  // active high RFS
  // rising-edge of RSCLK to sample

  *pSPORT0_RCR2 = 0x000F; // 16-bit word length
  *pSPORT0_TCR2 = 0x000F; // 16-bit word length

  // multichannel
  *pSPORT0_MCMC1 = 0x0000; // window size of 4 16-bit words
  *pSPORT0_MRCS0 = 0x000000FF; // enable lower 8 channels. 
  *pSPORT0_MCMC2 = 0x1010; // enable mode

  // configure SPI DMA
   *pDMA1_PERIPHERAL_MAP = 0x1000; 

   *pDMA1_START_ADDR = &inarray[0]; 
  *pDMA1_X_COUNT = 8;
   *pDMA1_X_MODIFY = 0x02; 
   *pDMA1_Y_COUNT = 0x00; 
   *pDMA1_Y_MODIFY = 0x00; 
   *pDMA1_CURR_DESC_PTR = 0x00; 


  // FLOW = 0: stop
  // DI_EN = 0 : no completion interrupt
  // DI_SEL = 0 : no completion interrupt
  // WDSIZE = 01 : 16-bit transfers
  // enable


  for (int p = 0; p < 100000; p++)
    {
   *pDMA1_CONFIG = 0x0027;  // start dma

   *pSPORT0_RCR1 = 0x4001; // enable sport RX
   *pSPORT0_TCR1 = 0x4001; // enable sport TX

      //a = *pSPORT0_RX16; 
      b = *pDMA1_IRQ_STATUS; 
      c = *pSPORT0_STAT; 
      short z = 0; 
      //z = *pDMA1_START_ADDR; 
      z = *pDMA1_X_COUNT; 
      z = *pDMA1_X_MODIFY; 
      z = *pDMA1_Y_COUNT; 
      z = *pDMA1_Y_MODIFY; 
      //z = *pDMA1_CURR_DESC_PTR; 


   *pSPORT0_RCR1 = 0x0000; // enable sport RX
   *pSPORT0_TCR1 = 0x0000; // enable sport TX


    }
   
  while(1); 

  
}


