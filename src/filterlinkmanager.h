#ifndef FILTERLINKMANGER_H
#define FILTERLINKMANAGER_H

#include <datasourcebase.h>
#include <filterlinkbase.h>

class FilterLinkManager
{
  
 public: 
  FilterLinkManager(DataSourceBase * ds); 
  ~FilterLinkManager(); 
  FilterLink * newLink(int type, int channel); 
 private:
  DataSourceBase * ds_; 
  
  
}; 

#endif // FILTERLINKMANAGER_H
