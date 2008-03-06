/*
 *
 *
 */

#include <cdefBF533.h>

unsigned short inarray[120]; 



int main()
{
  int i = 0; 
  int k = 0; 
  int a, b, c, d, e, f, g, h; 
  

  *pFIO_DIR    = 0x0001;
  *pFIO_FLAG_D = 0x0000;
  *pFIO_INEN   = 0x0000; // enable input for buttons

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
  *pDMA0_X_COUNT = 60; 
  *pDMA0_X_MODIFY = 0x02; //  two-byte stride
  *pDMA0_Y_COUNT = 0; // 
  *pDMA0_Y_MODIFY = 0; // 
  *pDMA0_CURR_DESC_PTR = 0x00; 
  
  *pDMA0_CONFIG = 0x0027;  // start dma, 1D, memory write operation
  
  *pPPI_COUNT = 0x000B; 
  *pPPI_DELAY = 0x0000; 

  *pPPI_CONTROL = 0xC08D; 

  *pDMA0_CONFIG = 0x0000; 

  *pDMA0_PERIPHERAL_MAP = 0x0000; 
  
  *pDMA0_START_ADDR = inarray; 
  *pDMA0_X_COUNT = 60; 
  *pDMA0_X_MODIFY = 0x02; //  two-byte stride
  *pDMA0_Y_COUNT = 0; // 
  *pDMA0_Y_MODIFY = 0; // 
  *pDMA0_CURR_DESC_PTR = 0x00; 

  // zero memory
  for (int y = 0 ; y < 120; y++) {
    inarray[y] = 0;  
  }

  *pDMA0_CONFIG = 0x0027;  // start dma, 1D, memory write operation

  // enable output
  *pFIO_DIR    = 0x0001;
  *pFIO_FLAG_D = 0x0001;
  *pFIO_INEN   = 0x0000; // enable input for buttons


  for (int p = 0; p < 100000; p++)
    {
      p++; 
      p++; 
	
    }

  while(1) {

    int x; 
    x = x + 1; 
    
  }

  
}


