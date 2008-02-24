/*
 *
 *
 */


#include <cdefBF533.h>
//#include <bf533/acqserial.h> 
//#include <bf533/memory.h> 

void do_blink(void); 

class Silly
{
public: 
  Silly() {
    int x; 
  } 

}; 
int main()
{
  int i = 0; 
  int k = 0; 
  Silly s; 
  
  while(1){ 
    do_blink();
    int i = 0; 
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

        i = 0;
        while (i < 10000) {
                *pFIO_FLAG_T = 0x0100;
                delay();
                i++;
        }
}

