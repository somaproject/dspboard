#include <dataout.h>
#include <stdexcept>

DataOutFifo::DataOutFifo(DSPDataOut * ddo) :
  buffers_(BUFNUM, DataOutBuffer(this)), 
  sendList_(), 
  nextNew_(0), 
  pddo_(ddo), 
  currentTX_(0)
{

}

DataOutBuffer* DataOutFifo::request() {
  // sanity check 
  
  if (buffers_[nextNew_].state_ != DOB_NONE) {
    throw std::runtime_error("No available buffers"); 
  } else {
    DataOutBuffer* rv = &buffers_[nextNew_]; 
    rv->state_ = DOB_WRITING; 
    nextNew_ = (nextNew_ + 1) % BUFNUM; 
    
    return rv; 
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
  if (not pddo_->done() ) {
    throw std::runtime_error("sendBuffer() with buffer pending"); 
  } else {

    if (currentTX_ != NULL) {
      currentTX_->state_ = DOB_NONE; 
    }
    
    if (sendList_.size() > 0 ) {

      currentTX_ = sendList_.front(); 
      currentTX_->state_ = DOB_SENDING; 
      
      
      pddo_->send( currentTX_->buffer, BUFSIZE); 
      sendList_.pop_front(); 
      
    }
    
  } 
  
}

void DataOutBuffer::commit() {
  state_ = DOB_TXREADY; 
  pDataOutFifo_->commit(this); 
}

