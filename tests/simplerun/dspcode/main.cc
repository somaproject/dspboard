/*
 *
 *
 */


#include <cdefBF533.h>
#include <stdlib.h>
//#include <bf533/acqserial.h> 
#include <hw/memory.h> 

// class TestObject
// {
//  public: 
//   TestObject() : 
//   x(0x1234),
//   y(0x5678){
//   }

//   int x; 
//   int y; 
  

// }; 

void do_blink(void); 

int main()
{
  //ctor_call();
  int i = 0; 
  int k = 0; 
//   TestObject * t2 = new TestObject(); 
//   TestObject * t3 = new TestObject(); 
//   TestObject * t4 = new TestObject(); 
  
  char s[10]; 
  
  while(1){ 
    do_blink(); 

  } 

}


int delay()
{
  int y = 0; 
  for (int x = 0; x < 1000000; x++) {
    y = x+1; 

  }
  return y; 
}

void do_blink(void)
{
  int i;
  
  *pFIO_DIR    = 0x0100;
  *pFIO_FLAG_D = 0x0100;
  *pFIO_INEN   = 0x0000; // enable input for buttons
  
  float x = float(i); 
  uint64_t longx = i; 
  
  i = 0;
  while (i < x) {
    *pFIO_FLAG_T = 0x0100;
    
    delay();
    i++;
  }
}

