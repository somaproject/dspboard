/*
 *
 *
 */

#include <cdefBF533.h>
#include <hw/datasport.h>


unsigned char outarray[1024]; 

int sendSPORTBurst(unsigned char * x) 
{
  // first, make sure we can modify the registers
  *pSPORT1_TCR1 = 0x0000; 

  *pSPORT1_TCR2 = 0x0000; // 8-bit word length
  *pSPORT1_MCMC2  = 0x0000; // make sure multichannel mode is disabled
  
  *pDMA4_CONFIG = 0x0080; 

  // configure SPI DMA
  *pDMA4_PERIPHERAL_MAP = 0x4000; 
  
  *pDMA4_START_ADDR = x; 
  *pDMA4_X_COUNT = 1024; 
  *pDMA4_X_MODIFY = 0x01; //  one-byte stride
  *pDMA4_Y_COUNT = 0; // 
  *pDMA4_Y_MODIFY = 0; // 
  *pDMA4_CURR_DESC_PTR = 0x00; 
  
  *pDMA4_CONFIG = 0x0081; // is interrupt necessary for pDMA IRQ status? 
  
  *pSPORT1_TFSDIV = 0x0000; // uh, what? 
  *pSPORT1_TCR2 = 0x0007; // 8-bit length
  *pSPORT1_TCR1 = 0x4211; // enable sport TX
  
  int y = 0; 
  while ((*pDMA4_IRQ_STATUS & DMA_RUN) or  !(*pDMA4_IRQ_STATUS & DMA_DONE) ) {
    y++; 
  }
  return y; 
}


void outloop()
{
  
  int N = 1024; 

  int DATAFIFOFULL_MASK = 0x0010; 

  *pFIO_DIR    &= ~DATAFIFOFULL_MASK; 
  *pFIO_INEN   |= DATAFIFOFULL_MASK; 

  for (int i = 0; i < 20; i++) {
    unsigned char * noutarray = new unsigned char[N]; 
    // Spin waiting for input FULL to be low
    int q = 0; 
    q = *pFIO_FLAG_D; 

    while (*pFIO_FLAG_D & DATAFIFOFULL_MASK) {

      q = *pFIO_FLAG_D; 
      
    }

    for (int y = 0 ; y < N; y++) {
      noutarray[y] = i; 
    }
    // set length
    noutarray[0] = 0; 
    noutarray[1] = 0x40; 
    //
    int res = sendSPORTBurst(noutarray) ; 
    q = res; 
  }
  
}

void singleout()
{
  int i = 0; 
  int k = 0; 
  int a, b, c, d, e, f, g, h; 
  int N = 1024; 
  
  for (int y = 0 ; y < N; y++) {
    outarray[y] = 0xCC; 
  }
  outarray[0] = 0; 
  outarray[1] = 0x10; 
  sendSPORTBurst(outarray) ; 
}

class TestData : public Data_t
{
public:
  TestData(int num) : 
    num_(num) {}
  int num_; 

  void toBuffer(unsigned char *c) {
    // let's say our length is 128 bytes
    *c = 0x00; 
    c++; 
    *c = 128; 
    c++; 
    // now we copy
    for (int i = 0; i < 126; i++) {
      *c = num_; 
      c++; 
    }

  } 
}; 

void testData()
{
  /* 
     
  we just loop for a bit, sticking events in the fifo
  
  */ 
  DataSPORT * pDataSPORT = new DataSPORT(); 
  pDataSPORT->setup(); 

  for (int i = 0; i < 20; i++) {
    TestData td(i); 

    // wait until the buffer is empty
    while(pDataSPORT->txBufferFull()) {
      pDataSPORT->sendPending(); 

    }
    pDataSPORT->sendData(td); 
      pDataSPORT->sendPending(); 
    

  }
  while(1) {
    pDataSPORT->sendPending(); 

  }



}
int main()
{

  //outloop(); 
  //singleout(); 
//   singleout(); 
  testData(); 

  while(1); 

  
}


