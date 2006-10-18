#include <dataout.h>
#include <stdexcept>

DataOutFifo::DataOutFifo(DSPDataOut * ddo) :
  buffers_(BUFNUM, DataOutBuffer(this)), 
  sendList(), 
  nextNew_(0), 
  pddo_(ddo)
{

}

DataOutBuffer* DataOutFifo::request() {
  // sanity check 
  
  if (buffers_[nextNew_].state_ != DOB_NONE) {
    throw std::runtime_error("No available buffers"); 
  } else {
    buffers_[nextNew_].state_ != DOB_WRITING; 
    nextNew_ = (nextNew_ + 1) % BUFNUM; 
  }
  
}

void DataOutFifo::commit(DataOutBuffer* dob)
{
  sendList_.push_back(dob); 

}

void DataOutFifo::sendBuffer()
{
  // should always take finite time
  //
  if (not DSPDataOut.done() ) {
    throw std::runtime_error("sendBuffer() with buffer pending"); 
  } else {

    if (currentTXBuffer_ != NULL) {
      currentTXBuffer_.state = DOB_NONE; 
    }
    
    if (sendList_.size() > 0 ) {

      currentTXBuffer_ = sendList.front(); 
      currentTXBuffer_.state = DOB_SENDING; 
      
      
      DSPDataOut.send( currentTXBuffer_.buffer, BUFSIZE); 
      sendList_.pop_front(); 
      
    }
    
  } 
  
}
