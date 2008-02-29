/*
 *
 *
 */


#include <cdefBF533.h>
//#include <bf533/acqserial.h> 
//#include <bf533/memory.h> 

void do_blink(void); 

typedef unsigned int uint32_t; 
typedef unsigned short uint16_t; 
typedef unsigned char uint8_t; 

uint16_t htons(uint16_t x) {

  return (( x << 8) & 0xFF00) | ((x >> 8) & 0xFF); 
}


const unsigned short FIFOFULL_MASK = 0x0001; 
const unsigned short SENDEVENT_MASK = 0x0004; 

struct Event_t {
  unsigned char cmd; 
  unsigned char src; 
  unsigned short data[5]; 
}; 

class EventTX_t {
public:
  unsigned char addr[10]; 
  Event_t event; 
  EventTX_t() {
    for (int i = 0; i < 10; i++) {
      addr[i] = 0; 
    }
    event.cmd = 0; 
    event.src = 0; 
    event.data[0] = 0; 
    event.data[1] = 0; 
    event.data[2] = 0; 
    event.data[3] = 0; 
    event.data[4] = 0; 
  }
  
  void toBuffer(char *p) {
    // copy the data into the correct order
    // note buffer must be of correct length
    for (int i = 0; i < 5; i++) {
      *p = addr[i * 2 + 1]; 
      p++; 
      *p = addr[i * 2 + 0]; 
      p++; 
    }
    
    *p = event.cmd; 
    p++; 
    *p = event.src; 
    p++; 

    for (int i = 0; i < 5; i++)
      {
	uint16_t s = htons(event.data[i]); 
	*(uint16_t *)p =s; 
	p+= 2; 
      }
    
  }

};

uint16_t  global_irq_status_read; 

void sendWordBlock(unsigned short data)
{
  *pSPI_TDBR = data; 
  while ( !(*pSPI_STAT & 0x1)) {
    // loop until done
    int x = 0; 
    x = *pSPI_STAT; 
  }

}


void sendEvent(EventTX_t & e) {
  uint16_t buffer[11]; 
  e.toBuffer((char *)buffer); 

  for (int i = 0; i < 11; i++) {
    sendWordBlock(buffer[i]); 
  }
}

void setupDMA()
{
  // Set up the DMA channel, by default, channel 5 is SPI
  *pDMA5_NEXT_DESC_PTR = 0; 
  *pDMA5_CURR_DESC_PTR = 0; 
  *pDMA5_START_ADDR = 0; 

  *pDMA5_X_COUNT = 12; 
  *pDMA5_X_MODIFY = 1; 

  *pDMA5_Y_COUNT = 0; 
  *pDMA5_Y_MODIFY = 0; 

  *pDMA5_CONFIG = 0x0020; 
  
}

void startDMA(uint16_t * addr)
{
  char testdata[40] = "Hello worHello worHello worHello wod"; 
  *pDMA5_START_ADDR = testdata; 
  *pDMA5_CONFIG |= 0x01; 

  int i = 0; 
  
  while(! (*pDMA5_IRQ_STATUS & 0x01) ) {
    global_irq_status_read = *pDMA5_IRQ_STATUS; 
    i =(int) *pDMA5_CURR_DESC_PTR; 
    i =(int) *pDMA5_CURR_ADDR; 
    i =(int)  *pDMA5_CURR_X_COUNT; 

    i++; 
  }
  i =(int) *pDMA5_CURR_DESC_PTR; 
  i =(int) *pDMA5_CURR_ADDR; 
  i =(int)  *pDMA5_CURR_X_COUNT; 


  global_irq_status_read = *pDMA5_IRQ_STATUS; 
}

void SPI_dma_setup () 
{
  // set up SPI 
  *pSPI_FLG = 0xFF02; 

  *pSPI_BAUD = 4; 
  //*pSPI_CTL = 0x5903; // correct
  *pSPI_CTL = 0x5803; // correct
}

int main()
{
  int i = 0; 
  int j = 0; 
  int iteration = 0; 
  //Silly * s = new Silly;  

  // setup
  *pFIO_DIR    = 0x0100;
  *pFIO_FLAG_D = 0x0100;
  *pFIO_INEN   = 0x0005; // enable input for buttons
  *pDMA5_IRQ_STATUS = 0; 

  global_irq_status_read = *pDMA5_IRQ_STATUS; 

  
  //setupDMA(); 
  *pDMA5_PERIPHERAL_MAP = 0x5000; 
  global_irq_status_read = *pDMA5_IRQ_STATUS; 


  setupDMA(); 
  global_irq_status_read = *pDMA5_IRQ_STATUS; 


  SPI_dma_setup(); 

  
  uint16_t buffer[11]; 
  startDMA(buffer); 
  
  iteration++; 
    
  while (1) {
      // wait until sendevent is deasserted
    global_irq_status_read = *pDMA5_IRQ_STATUS; 
    
    j = 0; 
  }
  
  
}


int classicEventSend()
{
  int i = 0; 
  int j = 0; 
  int iteration = 0; 
  //Silly * s = new Silly;  

  // setup

  *pFIO_DIR    = 0x0100;
  *pFIO_FLAG_D = 0x0100;
  *pFIO_INEN   = 0x0005; // enable input for buttons


  
  // set up SPI 
  *pSPI_BAUD = 4; 
  *pSPI_CTL = 0x5901; 
  *pSPI_FLG = 0xFF02; 
  
  while(1){ 
    i = *pFIO_FLAG_D; 
    j = i; 

    while (! (*pFIO_FLAG_D & SENDEVENT_MASK) ) {
      // wait until sendevent is sent
      i = 0; 
    }
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

    // send the actual events
    sendEvent(etx); 

    iteration++; 

    while ((*pFIO_FLAG_D & SENDEVENT_MASK)) {
      // wait until sendevent is deasserted
      j = 0; 
    }


  } 
  
}

int simpletest()
{
  int i = 0; 
  int j = 0; 
  int iteration = 0; 
  //Silly * s = new Silly;  

  // setup

  *pFIO_DIR    = 0x0100;
  *pFIO_FLAG_D = 0x0100;
  *pFIO_INEN   = 0x0005; // enable input for buttons


  
  // set up SPI 
  *pSPI_BAUD = 4; 
  *pSPI_CTL = 0x5901; 
  *pSPI_FLG = 0xFF02; 
  
  while(1){ 
    i = *pFIO_FLAG_D; 
    j = i; 

    while (! (*pFIO_FLAG_D & SENDEVENT_MASK) ) {
      // wait until sendevent is sent
      i = 0; 
    }

    for (int i = 0; i < 11; i++) {
      sendWordBlock(iteration << 8 | i); 
    } 
      
    iteration++; 

    while ((*pFIO_FLAG_D & SENDEVENT_MASK)) {
      // wait until sendevent is deasserted
      j = 0; 
    }


  } 
  
}
