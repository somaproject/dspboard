#include "mock_receiver.h"

MockReceiver::MockReceiver() :
  count(0)
{

}

void  MockReceiver::onLinkChange(bool val)
{
  linkChanges.push_back(val); 
  count++; 
}

void MockReceiver::onModeChange(char mode)
{
  modeChanges.push_back(mode); 
  count++; 

}

void MockReceiver::onGainChange(chanmask_t *  chanmask, int gain)
{
  chanmask_t * cm = new bool[AcqState::CHANNUM]; 
  memcpy(cm, chanmask, sizeof(bool) * AcqState::CHANNUM); 
  
  gainChanges.push_back(std::make_pair(chanmask, gain)); 
  count++; 
}

void MockReceiver::onHPFChange(chanmask_t * chanmask, bool enabled)
{

  chanmask_t *  cm = new bool[AcqState::CHANNUM]; 
  memcpy(cm, chanmask, sizeof(bool) * AcqState::CHANNUM); 

  hpfChanges.push_back(std::make_pair(chanmask, enabled)); 
  count++; 
}

void MockReceiver::onInputSelChange(char chan)
{
  inputSelChanges.push_back(chan); 
  count++; 

}
