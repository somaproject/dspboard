#ifndef MOCK_RECEIVER
#define MOCK_RECEIVER

#include <list>
#include <vector>
#include "acqstatereceiver.h"

class MockReceiver : public AcqStateReceiver
{
public:
  MockReceiver(); 
  void onLinkChange(bool); 
  void onModeChange(char mode); 
  void onGainChange(chanmask_t *  chanmask, int gain); 
  void onHPFChange(chanmask_t * chanmask, bool enabled); 
  void onInputSelChange(char chan); 
  
  std::vector<bool> linkChanges; 
  std::vector<char> modeChanges; 

  std::vector<std::pair<chanmask_t *, int> > gainChanges; 
  std::vector<std::pair<chanmask_t *, bool> > hpfChanges; 
  std::vector<char> inputSelChanges; 
  int count; 
  
}; 

#endif // MOCK_RECEIVER
