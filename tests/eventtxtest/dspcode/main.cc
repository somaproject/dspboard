/*
 *
 *
 */

#include <cdefBF533.h>

int main()
{
  int i = 0; 
  int k = 0; 
  int a, b, c, d, e, f, g, h; 
  
  unsigned short * buffer = new unsigned short[512*4]; 

  *pFIO_DIR    = 0x0001;
  *pFIO_FLAG_D = 0x0000;
  *pFIO_INEN   = 0x0000; // enable input for buttons

  // zero memory
  for (int y = 0 ; y < 512*4; y++) {
    buffer[y] = 0;  
  }
  
  // disable PPI
  *pPPI_CONTROL = 0x0000; 
  // configure PPI DMA
  *pDMA0_CONFIG = 0x0000; 

  *pDMA0_PERIPHERAL_MAP = 0x0000; 
  
  *pDMA0_START_ADDR = buffer; 
  *pDMA0_X_COUNT = 496; 
  *pDMA0_X_MODIFY = 0x02; //  two-byte stride
  *pDMA0_Y_COUNT = 0; // 
  *pDMA0_Y_MODIFY = 0; // 
  *pDMA0_CURR_DESC_PTR = 0x00; 
  
  *pDMA0_CONFIG = 0x0027;  // start dma, 1D, memory write operation
  
  *pPPI_COUNT = 495; 
  *pPPI_DELAY = 0x0000; 

  *pPPI_CONTROL = 0x408D; 

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


