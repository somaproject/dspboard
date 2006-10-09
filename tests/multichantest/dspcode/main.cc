/*
 *
 *
 */

#include <cdefBF533.h>

unsigned short inarray[16][16]; 

int main()
{
  int i = 0; 
  int k = 0; 
  int a, b, c, d, e, f, g, h; 

  // zero memory

  for (int y = 0 ; y < 16; y++) {
    for (int x = 0; x < 16; x++) {
      inarray[y][x] = 0; 
    }
  }
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
  *pSPORT0_MCMC1 = 0x5000; // window size of 48 words -- we do this
                           // so we can capture N * 12-word frames
  *pSPORT0_MRCS0 = 0xFFFFFFFF; // 
  *pSPORT0_MRCS1 = 0x0000FFFF; //
  *pSPORT0_MCMC2 = 0x0010; // enable mode

  // configure SPI DMA
   *pDMA1_PERIPHERAL_MAP = 0x1000; 

   *pDMA1_START_ADDR = &inarray[0]; 
   *pDMA1_X_COUNT = 12; 
   *pDMA1_X_MODIFY = 0x02; // two byte stride 
   *pDMA1_Y_COUNT = 16; // 
   *pDMA1_Y_MODIFY = 10; // 
   *pDMA1_CURR_DESC_PTR = 0x00; 

   *pDMA1_CONFIG = 0x0037;  // start dma, 2D

   *pSPORT0_RCR1 = 0x4001; // enable sport RX
   *pSPORT0_TCR1 = 0x4001; // enable sport TX


  for (int p = 0; p < 100000; p++)
    {
      i++; 
    }
   
  while(1); 

  
}


