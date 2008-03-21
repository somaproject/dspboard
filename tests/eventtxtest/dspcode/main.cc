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
  
  unsigned short * buffer = new unsigned short[512*6]; 

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
  
  int LEN = 512;  // len is in words
  int BURST = 508;  // burst is in words

  *pDMA0_START_ADDR = buffer; 
  *pDMA0_X_COUNT = BURST; 
  *pDMA0_X_MODIFY = 0x02; //  two-byte stride
  *pDMA0_Y_COUNT = 6; // 
  *pDMA0_Y_MODIFY = 2*(LEN-BURST)+2; // 
  *pDMA0_CURR_DESC_PTR = 0x00; 
  
  //*pDMA0_CONFIG = 0x0037;  // start dma, 2D, memory write operation
  *pDMA0_CONFIG = 0x0017;  // start dma, 2D, memory write operation
  
  *pPPI_COUNT = BURST-1; 
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


