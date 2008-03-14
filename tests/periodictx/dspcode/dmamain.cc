/*
 *
 *
 */


#include <cdefBF533.h>
//#include <bf533/acqserial.h> 
//#include <bf533/memory.h> 


typedef unsigned int uint32_t; 
typedef unsigned short uint16_t; 
typedef unsigned char uint8_t; 

uint16_t htons(uint16_t x) {

  return (( x << 8) & 0xFF00) | ((x >> 8) & 0xFF); 
}

uint16_t htons_dma(uint16_t x) {

  return x; 
}

short testdata[40] = {0xAABB, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
		      15, 16, 17, 18}; 

const unsigned short FIFOFULL_MASK = 0x0001; 
const unsigned short SENDEVENT_MASK = 0x0004; 

uint16_t  global_irq_status_read; 

void setupDMA()
{

  *pDMA5_PERIPHERAL_MAP = 0x5000; 

  // Set up the DMA channel, by default, channel 5 is SPI
  *pDMA5_NEXT_DESC_PTR = 0; 
  *pDMA5_CURR_DESC_PTR = 0; 
  *pDMA5_START_ADDR = 0; 

  *pDMA5_X_COUNT = 11; 
  *pDMA5_X_MODIFY = 2; 

  *pDMA5_Y_COUNT = 0; 
  *pDMA5_Y_MODIFY = 0; 

  *pDMA5_CONFIG = 0x0024; 
  
}


void eventTX_to_DMA_buffer(const EventTX_t & etx, uint16_t * tgtbuff) {
  // copy the data into the correct order
  // note buffer must be of correct length, and 2-byte-aligned
  
  char * p = (char*)tgtbuff; 
  
  for (int i = 0; i < 5; i++) {
    *p = etx.addr[i * 2 + 1]; 
    p++; 
    *p = etx.addr[i * 2 + 0]; 
    p++; 
  }
  
  
  *p = etx.event.src; 
  p++; 

  *p = etx.event.cmd; 
  p++; 
  
  for (int i = 0; i < 5; i++)
    {
      uint16_t s = etx.event.data[i]; 
      *(uint16_t *)p =s; 
      p+= 2; 
    }
  
}



void startDMA(EventTX_t & etx)
{
  *pDMA5_IRQ_STATUS = 0; // reset
  global_irq_status_read = *pDMA5_IRQ_STATUS; 

  
  static uint16_t tempbuffer[16]; 
  eventTX_to_DMA_buffer(etx, tempbuffer);

  *pDMA5_START_ADDR = tempbuffer;
  *pDMA5_CONFIG |= 0x01; 
  
  while(! (*pDMA5_IRQ_STATUS & 0x01) ) {
  }

}

void SPI_dma_setup () 
{
  // set up SPI 
  *pSPI_FLG = 0xFF02; 

  *pSPI_BAUD = 4; 
  *pSPI_CTL = 0x0040; 
  *pSPI_CTL = 0x5903; // correct
  //*pSPI_CTL = 0x5803; 
}



int dma_main()
{
  int i = 0; 
  int j = 0; 
  int iteration = 0; 

  // FLAG setup
  *pFIO_DIR    = 0x0100;
  *pFIO_FLAG_D = 0x0100;
  *pFIO_INEN   = 0x0005; // enable input for buttons
  

  setupDMA(); 

  SPI_dma_setup();  // spi setup for DMA

  EventTX_t etx; 
  for (int z = 0; z < 10; z++) {
    etx.addr[z] = z+1; 
  }
  etx.event.cmd = iteration; 
  etx.event.src = 0xAB; 
  etx.event.data[0] = 0x1122;
  etx.event.data[1] = 0x3344;
  etx.event.data[2] = 0x5566;
  etx.event.data[3] = 0x7788;
  etx.event.data[4] = 0x99AA;
  
  startDMA(etx); 
  

  iteration++; 
    
  while (1) {
      // wait until sendevent is deasserted
    global_irq_status_read = *pDMA5_IRQ_STATUS; 
    
    j = 0; 
  }
  
  
}




int main()
{
  dma_main();
  
}


