#ifndef DATAOUT_H
#define DATAOUT_H

#include <vector>
#include <list>
#include <hw/dspdataout.h>


const int BUFSIZE = 600; 
const int BUFNUM = 10; 

enum dobstat { DOB_NONE, DOB_WRITING, DOB_TXREADY, DOB_SENDING}; 

class DataOutFifo; 

class DataOutBuffer
{
  friend class DataOutFifo; 

public:
  DataOutBuffer(DataOutFifo* dof) :
    pDataOutFifo_(dof), 
    state_(DOB_NONE) {}; 
  char buffer[BUFSIZE]; 
  void commit(); 

private:
  dobstat state_; 
  DataOutFifo * pDataOutFifo_; 
  
}; 

class DataOutFifo 
{
public: 
  DataOutFifo(DSPDataOut* ddo); 
  DataOutBuffer* request(); 
  void commit(DataOutBuffer *); 
  void sendBuffer(); 

private:
  std::vector<DataOutBuffer> buffers_; 
  std::list<DataOutBuffer*> sendList_; 
  int nextNew_; 
  DataOutBuffer* currentTX_; 
  DSPDataOut * pddo_; 

}; 




#endif // DATAOUT_H
