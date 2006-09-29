#include <filterlinkmanager.h>

#include <filterlinks/delta.h>
#include <filterlinks/fir.h>
#include <filterlinks/iir.h>


FilterLinkManager::FilterLinkManager(DataSource * ds) :
  ds_(ds)
{
}

FilterLinkManager::newLink(int type, int channel)
{
  SampleBuffer<sample_t> * sb = ds_->getChannel(channel); 
  
  switch(type)
    {
    case 0:
      return new Delta(sb); 
      break; 
    case 1:
      return new FIR(sb, h1); 
      break;
    case 2:
      return new FIR(sb, h2); 
      break; 
    case 3:
      break; 
    }; 
}
