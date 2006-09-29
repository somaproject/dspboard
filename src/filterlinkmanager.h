#ifndef FILTERLINKMANGER_H
#define FILTERLINKMANAGER_H



class FilterLinkManager
{

 public: 
  FilterLinkManager(DataSource * ds); 
  ~FilterLinkManager(); 
  FilterLink * newLink(unsigned int type, int channel); 
 private:
  DataSource * ds_; 
  

}; 

#endif // FILTERLINKMANAGER_H
