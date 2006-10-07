/*
 *
 *
 */

#include <cdefBF533.h>

unsigned short inarray[5]; 

int main()
{
  int i = 0; 
  int k = 0; 
  int a, b, c, d, e, f, g, h; 

  // configure the go flag pin, PF4
  *pFIO_DIR = 0x0010; // output
  *pFIO_FLAG_D = 0x0000; // pin is off
  *pSPI_CTL = 0x4000; 
  a = 0; 
  c = 0; 
  *pSPI_CTL = 0x470A; // configure SPI
  
  // clear SPI buffer
  for ( i = 0; i < 16; i++) {
    a = *pSPI_RDBR; 
    b = (*pSPI_STAT >> 5) & 0x1; 
    c += a; 
  }


  
  // configure SPI DMA
  *pDMA5_PERIPHERAL_MAP = 0x5000; 

  *pDMA5_START_ADDR = inarray; 
  *pDMA5_X_COUNT = 0x04;
  *pDMA5_X_MODIFY = 0x02; 
  *pDMA5_Y_COUNT = 0x00; 
  *pDMA5_Y_MODIFY = 0x00; 
  *pDMA5_CURR_DESC_PTR = 0x00; 


  // FLOW = 0: stop
  // DI_EN = 0 : no completion interrupt
  // DI_SEL = 0 : no completion interrupt
  // WDSIZE = 01 : 16-bit transfers
  // enable
  *pDMA5_CONFIG = 0x0007;  // start dma
  *pFIO_FLAG_D = 0x0010; // pin is off


  i = 0; 
  i = 0; 
  i = 0; 
  *pDMA5_CONFIG = 0x0007; 

  i = 0; 
  i = 0; 
  i = 0; 
  *pDMA5_CONFIG = 0x0007; 

  i = 0; 
  i = 0; 
  i = 0; 
   
  while(1); 

  
}


