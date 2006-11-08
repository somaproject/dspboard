/*
 *
 *
 */

#include <cdefBF533.h>

unsigned char inarray[120]; 



int main()
{
  int i = 0; 
  int k = 0; 
  int a, b, c, d, e, f, g, h; 
  
  // zero memory
  
  for (int y = 0 ; y < 120; y++) {
    inarray[y] = 0;  
  }
  
  // disable PPI
  *pPPI_CONTROL = 0x0000; 
  // configure PPI DMA
  *pDMA0_CONFIG = 0x0000; 

  *pDMA0_PERIPHERAL_MAP = 0x0000; 
  
  *pDMA0_START_ADDR = inarray; 
  *pDMA0_X_COUNT = 120; 
  *pDMA0_X_MODIFY = 0x02; //  one-byte stride
  *pDMA0_Y_COUNT = 0; // 
  *pDMA0_Y_MODIFY = 0; // 
  *pDMA0_CURR_DESC_PTR = 0x00; 
  
  *pDMA0_CONFIG = 0x0027;  // start dma, 1D, memory write operation
  
  *pPPI_COUNT = 0x000B; 
  *pPPI_DELAY = 0x0000; 
  *pPPI_CONTROL = 0xC08D; 
  


  for (int p = 0; p < 100000; p++)
    {
      p++; 
    }

  while(1); 

  
}


