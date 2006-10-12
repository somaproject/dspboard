/*
 *
 *
 */


#include <cdefBF533.h>
#include <bf533/acqserial.h> 

AcqSerial as;  // global so we can get function wrappers

extern "C" {

  void __attribute__((interrupt_handler)) rxisr() 
  {
    //as.RXDMAdoneISR(); 
    int a; 
    int x = *pIPEND; 
    int y = *pILAT; 
    int q = *pSIC_ISR; 
    // try and clear our bit? 
    q &= 0xFFFFFDFF;
    *pSIC_ISR = q; 
    a = 0; 
    a = 1; 
    q = *pSIC_ISR; 

    short z = *pDMA1_IRQ_STATUS; 
    z &= 0x01; // clear dma done bit; 
    *pDMA1_IRQ_STATUS = z; 
    z = *pDMA1_IRQ_STATUS; 

    a = *pDMA1_X_COUNT;
    a = *pDMA1_X_MODIFY; // two byte stride
    a = *pDMA1_Y_COUNT;
    a = *pDMA1_Y_MODIFY;
    a = *pDMA1_CURR_Y_COUNT; 
    a = *pDMA1_CONFIG; 
    a = *pDMA1_PERIPHERAL_MAP; 

    
    //*pDMA1_CONFIG = 0x0000;  // start input dma, 2D
    //a = *pDMA1_CONFIG; 
    
  }
  

  void  __attribute__((interrupt_handler))  txisr()
  {
    int x = 0; 
    //as.TXDMAdoneISR();
  }
  
} 

int main()
{
  int i = 0; 
  int k = 0; 
  
  
  as.setupSPORT(); 
  as.setupDMA(); 
  // configure interrupts
  *pSIC_IAR0 = 0x00000000; 
  *pSIC_IAR1 = 0x00000210; 
  *pSIC_IAR2 = 0x00000000; 
  *pSIC_IMASK = 0x00000200; 
  as.start(); 


  while(1) {
  i = *pSIC_ISR; 
  }


  
}


