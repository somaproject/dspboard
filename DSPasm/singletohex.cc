#include <iostream>
#include <string>
#include <sstream>
#include <stdio.h>

union floathex {
  float f;
  unsigned char val[4];
};

int main(int argc, char* argv[])
{
  string number; 
  number = argv[1];
  istringstream snumber(number);

  floathex result; 
  float fresult;
  snumber >> fresult;
  result.f = fresult; 

  
  
  for(int i=3; i>=0; i--) {
    printf("%0.2X", result.val[i]);
  } 
  return(0);
}
