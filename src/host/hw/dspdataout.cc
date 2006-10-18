#include <hw/dspdataout.h>
#include <iostream>


DSPDataOut::DSPDataOut():
  doneState(true)
{

}

void DSPDataOut::send(char* bufin, int N)
{
  for (int i = 0; i < N; i++)
    {
      outbuf[i] = bufin[i];
    }
  doneState = false; 
}
  
bool DSPDataOut::done()
{
  return doneState; 
}


