#ifndef UARTTX_H
#define UARTTX_H
#include <cdefBF533.h>
#include <stdlib.h>

#include <hw/memory.h> 
class UARTTX {
public:
  UARTTX(); 
  void setup(); 
  void setupUART(); 

  void setupDMA(); 
  void sendWords(char *); 
  bool checkSendDone(); 

private: 
  char txBuffer_[6]; 

}; 

#endif // UARTTX_H
